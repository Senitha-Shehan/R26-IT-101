class RegionModelConfig {
  final String regionId;
  final String displayName;
  final String modelAssetPath;
  final List<String> classLabels;

  const RegionModelConfig({
    required this.regionId,
    required this.displayName,
    required this.modelAssetPath,
    required this.classLabels,
  });
}
