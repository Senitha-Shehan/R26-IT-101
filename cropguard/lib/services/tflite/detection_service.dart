import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/detection_exceptions.dart';
import '../../core/utils/image_utils.dart';
import '../../models/detection_result.dart';
import '../../models/region_model_config.dart';
import '../active_learning/active_learning_queue_service.dart';
import 'model_manager.dart';

class DetectionService {
  final ModelManager _modelManager;
  final ActiveLearningQueueService _queueService;

  DetectionService({
    ModelManager? modelManager,
    ActiveLearningQueueService? queueService,
  })  : _modelManager = modelManager ?? ModelManager(),
        _queueService = queueService ?? ActiveLearningQueueService();

  /// Runs local disease detection for any selected regional model.
  Future<DetectionResult> detectDisease({
    required File imageFile,
    required RegionModelConfig regionConfig,
  }) async {
    try {
      // 1. Load / switch to selected regional model (lazy loading & RAM management)
      await _modelManager.loadRegionalModel(regionConfig);

      // 2. Preprocess image: resize 224x224 RGB, normalize [-1.0, 1.0] MobileNetV2 range
      final inputTensor = ImageUtils.preprocessImageForMobileNetV2(imageFile);

      // 3. Run TFLite inference using the active regional interpreter
      final probabilities = _modelManager.runInference(
        inputTensor,
        regionConfig.classLabels.length,
      );

      // 4. Compute top predicted disease class and confidence score
      int bestIndex = 0;
      double maxConfidence = -1.0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          bestIndex = i;
        }
      }

      final topDiseaseName = (bestIndex < regionConfig.classLabels.length)
          ? regionConfig.classLabels[bestIndex]
          : 'Unknown Disease';

      // 5. Evaluate confidence against threshold (0.80)
      final isUncertain = maxConfidence < AppConstants.confidenceThreshold;

      final result = DetectionResult(
        diseaseName: topDiseaseName,
        confidence: maxConfidence,
        regionId: regionConfig.regionId,
        regionDisplayName: regionConfig.displayName,
        isUncertain: isUncertain,
        allProbabilities: probabilities,
        imagePath: imageFile.path,
        lowConfidenceNotice: isUncertain ? AppConstants.lowConfidenceMessage : null,
      );

      // 6. Automatically archive low confidence sample (< 0.80) to offline Active Learning queue
      if (isUncertain) {
        await _queueService.enqueueSample(result);
      }

      debugPrint(
        'Detection Pipeline Success:\n'
        '  Region: ${regionConfig.displayName} (${regionConfig.regionId})\n'
        '  Model Asset: ${regionConfig.modelAssetPath}\n'
        '  Predicted Class: $topDiseaseName\n'
        '  Confidence: ${(maxConfidence * 100).toStringAsFixed(2)}%\n'
        '  Is Uncertain (< 0.80): $isUncertain',
      );

      return result;
    } catch (e) {
      debugPrint('DetectionService error: $e');
      if (e is DetectionException) rethrow;
      throw InterpreterException('Unexpected error during regional detection', e.toString());
    }
  }

  void dispose() {
    _modelManager.dispose();
  }
}
