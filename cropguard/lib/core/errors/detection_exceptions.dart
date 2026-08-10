/// Base exception class for CropGuard detection pipeline errors.
abstract class DetectionException implements Exception {
  final String message;
  final String? details;

  const DetectionException(this.message, [this.details]);

  @override
  String toString() {
    if (details != null && details!.isNotEmpty) {
      return '$message: $details';
    }
    return message;
  }
}

/// Thrown when loading a TFLite model asset fails or file is missing.
class ModelLoadException extends DetectionException {
  const ModelLoadException(super.message, [super.details]);
}

/// Thrown when an input image is missing, zero bytes, unreadable, or corrupt.
class InvalidImageException extends DetectionException {
  const InvalidImageException(super.message, [super.details]);
}

/// Thrown when TFLite interpreter execution fails during inference.
class InterpreterException extends DetectionException {
  const InterpreterException(super.message, [super.details]);
}

/// Thrown when model tensor input/output shapes do not match expected dimensions.
class TensorShapeMismatchException extends DetectionException {
  const TensorShapeMismatchException(super.message, [super.details]);
}
