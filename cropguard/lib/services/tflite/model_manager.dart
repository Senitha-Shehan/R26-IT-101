import 'package:flutter/foundation.dart';
import '../../core/errors/detection_exceptions.dart';
import '../../models/region_model_config.dart';
import 'tflite_service.dart';

class ModelManager {
  final TFLiteService _tfliteService;
  RegionModelConfig? _activeRegionConfig;

  ModelManager({TFLiteService? tfliteService})
      : _tfliteService = tfliteService ?? TFLiteService();

  /// Gets currently active region configuration.
  RegionModelConfig? get activeRegionConfig => _activeRegionConfig;

  /// Gets currently loaded model asset path.
  String? get activeModelAssetPath => _tfliteService.loadedModelPath;

  /// Loads or switches to the specified regional TFLite FP16 model.
  /// Safely unloads the previous model interpreter before loading the new one
  /// to ensure only 1 regional model is in RAM at a time.
  Future<void> loadRegionalModel(RegionModelConfig regionConfig) async {
    if (_activeRegionConfig?.regionId == regionConfig.regionId &&
        _tfliteService.isModelLoaded(regionConfig.modelAssetPath)) {
      debugPrint('ModelManager: Model ${regionConfig.regionId} already active in memory.');
      return;
    }

    try {
      debugPrint('ModelManager: Switching active region to ${regionConfig.displayName} (${regionConfig.modelAssetPath})');
      
      // Unload previous model if different
      if (_activeRegionConfig != null && _activeRegionConfig!.regionId != regionConfig.regionId) {
        debugPrint('ModelManager: Safely unloading previous region: ${_activeRegionConfig!.displayName}');
        _tfliteService.close();
      }

      // Load new regional model asset
      await _tfliteService.loadModel(regionConfig.modelAssetPath);
      _activeRegionConfig = regionConfig;

      debugPrint('ModelManager: Regional model ${regionConfig.displayName} loaded successfully.');
    } catch (e) {
      _activeRegionConfig = null;
      if (e is DetectionException) rethrow;
      throw ModelLoadException(
        'Failed to initialize model for region ${regionConfig.displayName}',
        e.toString(),
      );
    }
  }

  /// Runs TFLite inference on preprocessed tensor [1, 224, 224, 3].
  List<double> runInference(
    List<List<List<List<double>>>> inputBuffer,
    int numClasses,
  ) {
    if (_activeRegionConfig == null) {
      throw const ModelLoadException('No active regional model is loaded in ModelManager.');
    }
    return _tfliteService.runInference(inputBuffer, numClasses);
  }

  /// Closes active interpreter and releases RAM.
  void dispose() {
    _tfliteService.close();
    _activeRegionConfig = null;
  }
}
