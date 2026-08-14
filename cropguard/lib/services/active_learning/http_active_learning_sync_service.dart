import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../models/active_learning_sample.dart';
import 'active_learning_queue_service.dart';
import 'active_learning_sync_service.dart';

class HttpActiveLearningSyncService implements ActiveLearningSyncService {
  final ActiveLearningQueueService _queueService;

  HttpActiveLearningSyncService({ActiveLearningQueueService? queueService})
      : _queueService = queueService ?? ActiveLearningQueueService();

  @override
  Future<bool> checkConnection() async {
    final List<String> candidateUrls = [
      ApiConfig.baseUrl,
      if (Platform.isAndroid && !ApiConfig.baseUrl.contains('192.168.1.88')) 'http://192.168.1.88:8000',
      if (Platform.isAndroid && !ApiConfig.baseUrl.contains('10.0.2.2')) 'http://10.0.2.2:8000',
    ];

    for (final base in candidateUrls) {
      try {
        final uri = Uri.parse('$base/api/health');
        debugPrint('HttpActiveLearningSyncService: Pinging health endpoint ($uri)...');
        final response = await http.get(uri).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body is Map && body['status'] == 'ok') {
            ApiConfig.baseUrl = base;
            debugPrint('HttpActiveLearningSyncService: Successfully connected to backend via $base!');
            return true;
          }
        }
      } catch (e) {
        debugPrint('HttpActiveLearningSyncService checkConnection attempt failed for $base: $e');
      }
    }
    debugPrint('HttpActiveLearningSyncService: All candidate endpoints unreachable. Mode: Offline.');
    return false;
  }

  @override
  Future<int> syncPendingSamples(List<ActiveLearningSample> pendingSamples) async {
    if (pendingSamples.isEmpty) {
      return 0;
    }

    final isOnline = await checkConnection();
    if (!isOnline) {
      debugPrint('HttpActiveLearningSyncService: Backend unreachable. Keeping samples stored locally.');
      return 0;
    }

    int syncedCount = 0;

    for (final sample in pendingSamples) {
      // Only attempt pending or failed samples
      if (sample.status == SampleSyncStatus.synced) {
        continue;
      }

      final imgFile = File(sample.localImagePath);
      if (!imgFile.existsSync()) {
        debugPrint('HttpActiveLearningSyncService: Local image file missing for sample ${sample.id} at ${sample.localImagePath}');
        await _queueService.markSampleFailed(sample.id, 'Local image file not found');
        continue;
      }

      try {
        final uri = Uri.parse(ApiConfig.uploadUncertainSampleEndpoint);
        final request = http.MultipartRequest('POST', uri);

        request.fields['sample_id'] = sample.id;
        request.fields['predicted_disease'] = sample.predictedDisease;
        request.fields['confidence'] = sample.confidence.toString();
        request.fields['region'] = sample.regionId;
        request.fields['model_id'] = sample.modelName;
        request.fields['timestamp'] = sample.timestamp.toIso8601String();

        final multipartFile = await http.MultipartFile.fromPath('image', imgFile.path);
        request.files.add(multipartFile);

        debugPrint('HttpActiveLearningSyncService: Uploading sample ${sample.id} to ${uri.toString()}...');
        final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          await _queueService.markSampleSynced(sample.id);
          syncedCount++;
          debugPrint('HttpActiveLearningSyncService: Sample ${sample.id} successfully synced to MongoDB Atlas!');
        } else {
          final errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
          debugPrint('HttpActiveLearningSyncService upload failed for ${sample.id}: $errorMsg');
          await _queueService.markSampleFailed(sample.id, errorMsg);
        }
      } catch (e) {
        final errorMsg = 'Network exception: $e';
        debugPrint('HttpActiveLearningSyncService exception for ${sample.id}: $errorMsg');
        await _queueService.markSampleFailed(sample.id, errorMsg);
        // On network interruption, stop current batch loop
        break;
      }
    }

    return syncedCount;
  }
}
