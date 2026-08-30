import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/regional_models_config.dart';
import '../models/region_model_config.dart';

class UserPreferences {
  static const String _keySelectedRegionId = 'selected_region_id';
  static const String _keyLocaleCode = 'app_locale_code';

  // ─── Region ───────────────────────────────────────────────────────────────

  static Future<RegionModelConfig> getSelectedRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final regionId = prefs.getString(_keySelectedRegionId);
    if (regionId != null && regionId.isNotEmpty) {
      return RegionalModelsConfig.getById(regionId);
    }
    return RegionalModelsConfig.defaultRegion;
  }

  static Future<void> setSelectedRegion(String regionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedRegionId, regionId);
  }

  // ─── Locale ───────────────────────────────────────────────────────────────

  /// Returns saved locale language code; defaults to 'en' if not set.
  static Future<String> getLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocaleCode) ?? 'en';
  }

  static Future<void> setLocaleCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocaleCode, code);
  }
}
