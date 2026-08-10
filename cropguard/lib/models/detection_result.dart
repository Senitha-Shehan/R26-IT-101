class DetectionResult {
  final String diseaseName;
  final double confidence;
  final String regionId;
  final String regionDisplayName;
  final bool isUncertain;
  final List<double> allProbabilities;
  final String imagePath;
  final String? lowConfidenceNotice;

  const DetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.regionId,
    required this.regionDisplayName,
    required this.isUncertain,
    required this.allProbabilities,
    required this.imagePath,
    this.lowConfidenceNotice,
  });
}
