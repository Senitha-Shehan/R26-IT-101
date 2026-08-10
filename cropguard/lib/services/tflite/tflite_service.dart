import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../core/errors/detection_exceptions.dart';

class TFLiteService {
  Interpreter? _interpreter;
  String? _loadedModelPath;

  Interpreter? get interpreter => _interpreter;
  String? get loadedModelPath => _loadedModelPath;

  bool isModelLoaded(String assetPath) {
    return _interpreter != null && _loadedModelPath == assetPath;
  }

  /// Loads a TFLite FP16 model from asset path and validates input/output tensor shapes.
  Future<void> loadModel(String modelAssetPath) async {
    if (isModelLoaded(modelAssetPath)) {
      return;
    }

    try {
      _interpreter?.close();
      _interpreter = null;
      _loadedModelPath = null;

      _interpreter = await Interpreter.fromAsset(modelAssetPath);
      _loadedModelPath = modelAssetPath;
      debugPrint('TFLiteService: Successfully loaded asset: $modelAssetPath');

      // Validate input & output tensor shapes
      _validateTensors();
    } catch (e) {
      _interpreter?.close();
      _interpreter = null;
      _loadedModelPath = null;

      if (e is DetectionException) rethrow;
      throw ModelLoadException(
        'Failed to load TFLite model asset',
        'Asset path: $modelAssetPath. Error: $e',
      );
    }
  }

  /// Inspects loaded interpreter input and output tensor metadata.
  void _validateTensors() {
    if (_interpreter == null) return;

    final inputTensors = _interpreter!.getInputTensors();
    final outputTensors = _interpreter!.getOutputTensors();

    if (inputTensors.isEmpty) {
      throw const TensorShapeMismatchException('Model has no input tensors');
    }

    if (outputTensors.isEmpty) {
      throw const TensorShapeMismatchException('Model has no output tensors');
    }

    final inputShape = inputTensors.first.shape;
    final outputShape = outputTensors.first.shape;

    debugPrint('TFLiteService: Input shape: $inputShape, Output shape: $outputShape');

    // Expected input shape: [1, 224, 224, 3]
    if (inputShape.length != 4 ||
        inputShape[1] != 224 ||
        inputShape[2] != 224 ||
        inputShape[3] != 3) {
      throw TensorShapeMismatchException(
        'Unexpected input tensor shape',
        'Expected [1, 224, 224, 3], got $inputShape',
      );
    }

    // Expected output shape: [1, 8]
    if (outputShape.length != 2 || outputShape[1] != 8) {
      throw TensorShapeMismatchException(
        'Unexpected output tensor shape',
        'Expected [1, 8], got $outputShape',
      );
    }
  }

  /// Runs local TFLite inference on preprocessed 4D tensor [1, 224, 224, 3].
  List<double> runInference(
    List<List<List<List<double>>>> inputBuffer,
    int numClasses,
  ) {
    if (_interpreter == null) {
      throw const ModelLoadException('TFLite interpreter is not loaded.');
    }

    final outputBuffer = List.generate(
      1,
      (_) => List<double>.filled(numClasses, 0.0),
    );

    try {
      _interpreter!.run(inputBuffer, outputBuffer);
    } catch (e) {
      throw InterpreterException(
        'Error during TFLite model execution',
        e.toString(),
      );
    }

    return outputBuffer[0];
  }

  /// Closes and releases interpreter resources.
  void close() {
    _interpreter?.close();
    _interpreter = null;
    _loadedModelPath = null;
  }
}
