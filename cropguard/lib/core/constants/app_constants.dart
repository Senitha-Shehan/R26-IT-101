class AppConstants {
  /// Uncertainty threshold for active learning trigger.
  /// Predictions with confidence < 0.80 will be marked as uncertain.
  static const double confidenceThreshold = 0.80;

  /// Input image dimensions required by MobileNetV2 architecture.
  static const int inputImageSize = 224;
  static const int inputChannels = 3;

  /// Human readable alert message for uncertain results.
  static const String lowConfidenceMessage =
      'Low confidence — sample will be considered for expert review.';
}
