import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/active_learning_sample.dart';
import '../../models/detection_result.dart';
import 'http_active_learning_sync_service.dart';

class ActiveLearningQueueService {
  static const String _queuePrefsKey = 'cropguard_active_learning_queue_v1';
  static ActiveLearningQueueService? _instance;

  ActiveLearningQueueService._internal();

  factory ActiveLearningQueueService() {
    _instance ??= ActiveLearningQueueService._internal();
    return _instance!;
  }

  /// Copies an image file to local persistent storage under `<AppDocDir>/uncertain_samples/`.
  Future<String> _archiveUncertainImage(File sourceFile, String sampleId) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final archiveDir = Directory('${appDocDir.path}/uncertain_samples');
      if (!archiveDir.existsSync()) {
        archiveDir.createSync(recursive: true);
      }

      final targetPath = '${archiveDir.path}/sample_$sampleId.jpg';
      final targetFile = File(targetPath);

      if (!targetFile.existsSync()) {
        await sourceFile.copy(targetPath);
      }

      return targetPath;
    } catch (e) {
      debugPrint('Error archiving uncertain image: $e');
      return sourceFile.path;
    }
  }

  /// Adds a low-confidence detection result (< 0.80) to the persistent local queue.
  /// Deduplicates by image path and timestamp.
  Future<ActiveLearningSample?> enqueueSample(DetectionResult result) async {
    if (!result.isUncertain) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final allSamples = await getAllSamples();

      // Check if duplicate sample already exists for this image path
      final existingIndex = allSamples.indexWhere(
        (s) => s.localImagePath == result.imagePath,
      );
      if (existingIndex != -1) {
        debugPrint('ActiveLearningQueueService: Sample already queued (${allSamples[existingIndex].id}). Skipping duplicate.');
        return allSamples[existingIndex];
      }

      // Generate unique 12-char hex sample ID from timestamp & random offset
      final String sampleId = DateTime.now().microsecondsSinceEpoch.toRadixString(16).padLeft(12, '0');
      final sourceFile = File(result.imagePath);

      // Save image to persistent app storage
      final archivedPath = await _archiveUncertainImage(sourceFile, sampleId);

      final sample = ActiveLearningSample(
        id: sampleId,
        localImagePath: archivedPath,
        predictedDisease: result.diseaseName,
        confidence: result.confidence,
        regionId: result.regionId,
        regionDisplayName: result.regionDisplayName,
        modelName: '${result.regionId}_float16.tflite',
        timestamp: DateTime.now(),
        status: SampleSyncStatus.pending,
      );

      allSamples.insert(0, sample); // newest first

      final jsonList = allSamples.map((s) => s.toJson()).toList();
      await prefs.setString(_queuePrefsKey, jsonEncode(jsonList));

      debugPrint('ActiveLearningQueueService: Enqueued uncertain sample ($sampleId) to persistent offline queue.');
      // Auto-trigger sync in background if internet is available
      syncPendingSamples();
      return sample;
    } catch (e) {
      debugPrint('ActiveLearningQueueService enqueue error: $e');
      return null;
    }
  }

  /// Returns all stored active learning samples.
  Future<List<ActiveLearningSample>> getAllSamples() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_queuePrefsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => ActiveLearningSample.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ActiveLearningQueueService getAllSamples error: $e');
      return [];
    }
  }

  /// Returns all pending samples waiting for future review/sync.
  Future<List<ActiveLearningSample>> getPendingSamples() async {
    final all = await getAllSamples();
    return all.where((s) => s.status == SampleSyncStatus.pending).toList();
  }

  /// Gets a specific sample by ID.
  Future<ActiveLearningSample?> getSampleById(String id) async {
    final all = await getAllSamples();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Updates status of a sample in the local persistent storage.
  Future<void> _updateStatus(String id, SampleSyncStatus newStatus, [String? errorMsg]) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllSamples();

    final index = all.indexWhere((s) => s.id == id);
    if (index != -1) {
      all[index] = all[index].copyWith(
        status: newStatus,
        syncErrorMessage: errorMsg,
      );
      final jsonList = all.map((s) => s.toJson()).toList();
      await prefs.setString(_queuePrefsKey, jsonEncode(jsonList));
    }
  }

  Future<void> markSampleSynced(String id) async {
    await _updateStatus(id, SampleSyncStatus.synced);
  }

  Future<void> markSampleFailed(String id, [String? errorMessage]) async {
    await _updateStatus(id, SampleSyncStatus.failed, errorMessage);
  }

  /// Deletes a sample and its archived image file from local storage.
  Future<void> deleteSample(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllSamples();

    final sample = all.firstWhere((s) => s.id == id, orElse: () => throw Exception('Sample not found'));
    all.removeWhere((s) => s.id == id);

    final jsonList = all.map((s) => s.toJson()).toList();
    await prefs.setString(_queuePrefsKey, jsonEncode(jsonList));

    // Delete archived image file
    try {
      final imgFile = File(sample.localImagePath);
      if (imgFile.existsSync()) {
        imgFile.deleteSync();
      }
    } catch (e) {
      debugPrint('Error deleting archived image file: $e');
    }
  }

  /// Triggers REST API synchronization for all pending/failed samples.
  /// Safe to call anywhere; returns the count of uploaded samples.
  Future<int> syncPendingSamples() async {
    try {
      final pending = await getPendingSamples();
      if (pending.isEmpty) {
        return 0;
      }
      final syncService = HttpActiveLearningSyncService(queueService: this);
      return await syncService.syncPendingSamples(pending);
    } catch (e) {
      debugPrint('ActiveLearningQueueService syncPendingSamples error: $e');
      return 0;
    }
  }
}
