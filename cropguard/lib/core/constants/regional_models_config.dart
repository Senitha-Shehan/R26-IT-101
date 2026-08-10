import '../../models/region_model_config.dart';

class RegionalModelsConfig {
  /// The 8 global disease classes detected by CropGuard MobileNetV2 models
  /// (Alphabetical ordering matching Keras ImageDataGenerator & training pipeline).
  static const List<String> globalClassLabels = [
    'Bacterial Leaf Blight',
    'Brown Spot',
    'Healthy Rice Leaf',
    'Leaf Blast',
    'Leaf Scald',
    'Narrow Brown Leaf Spot',
    'Rice Hispa',
    'Sheath Blight',
  ];

  /// Registry of all 9 Sri Lankan regional FP16 TFLite models
  static const List<RegionModelConfig> allRegions = [
    RegionModelConfig(
      regionId: 'central_highlands',
      displayName: 'Central Highlands',
      modelAssetPath: 'assets/models/central_highlands_float16.tflite',
      classLabels: globalClassLabels,
    ),
    RegionModelConfig(
      regionId: 'uva_zone',
      displayName: 'Uva Zone',
      modelAssetPath: 'assets/models/uva_zone_float16.tflite',
      classLabels: globalClassLabels,
    ),
    RegionModelConfig(
      regionId: 'eastern_dry_zone',
      displayName: 'Eastern Dry Zone',
      modelAssetPath: 'assets/models/eastern_dry_zone_float16.tflite',
      classLabels: globalClassLabels,
    ),
    RegionModelConfig(
      regionId: 'north_central_dry_zone',
      displayName: 'North Central Dry Zone',
      modelAssetPath: 'assets/models/north_central_dry_zone_float16.tflite',
      classLabels: globalClassLabels,
    ),
    RegionModelConfig(
      regionId: 'northern_dry_zone',
      displayName: 'Northern Dry Zone',
      modelAssetPath: 'assets/models/northern_dry_zone_float16.tflite',
      classLabels: globalClassLabels,
    ),
    RegionModelConfig(
      regionId: 'northwestern_intermediate',
      displayName: 'Northwestern Intermediate',
      modelAssetPath: 'assets/models/northwestern_intermediate_float16.tflite',
      classLabels: globalClassLabels,
    ),
    RegionModelConfig(
      regionId: 'sabaragamuwa_zone',
      displayName: 'Sabaragamuwa Zone',
      modelAssetPath: 'assets/models/sabaragamuwa_zone_float16.tflite',
      classLabels: globalClassLabels,
    ),
    RegionModelConfig(
      regionId: 'southern_wet_zone',
      displayName: 'Southern Wet Zone',
      modelAssetPath: 'assets/models/southern_wet_zone_float16.tflite',
      classLabels: globalClassLabels,
    ),
    RegionModelConfig(
      regionId: 'western_wet_zone',
      displayName: 'Western Wet Zone',
      modelAssetPath: 'assets/models/western_wet_zone_float16.tflite',
      classLabels: globalClassLabels,
    ),
  ];

  /// Default region for Phase 1 working model
  static RegionModelConfig get defaultRegion => allRegions.first;

  /// Helper to get config by regionId
  static RegionModelConfig getById(String regionId) {
    return allRegions.firstWhere(
      (r) => r.regionId == regionId,
      orElse: () => defaultRegion,
    );
  }
}
