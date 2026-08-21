import 'dart:io';

class ApiConfig {
  /// Centralized base URL configuration for CropGuard backend REST API.
  /// Android Emulator accesses development PC localhost via 10.0.2.2.
  /// For physical devices or production deployments, replace this base URL.
  static String _overrideBaseUrl = '';

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }
    // Auto-detect default host based on platform.
    if (Platform.isAndroid) {
      // Android emulator reaches the host machine's localhost via 10.0.2.2.
      // For a physical Android device, override with the dev PC's LAN IP
      // (currently 10.10.99.20) via ApiConfig.baseUrl = '...'.
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  static set baseUrl(String url) {
    _overrideBaseUrl = url.replaceAll(RegExp(r'/$'), '');
  }

  static String get healthEndpoint => '$baseUrl/api/health';
  static String get uploadUncertainSampleEndpoint => '$baseUrl/api/uncertain-samples';

  /// RAG treatment recommendation endpoint (POST, JSON body).
  static String get treatmentEndpoint => '$baseUrl/api/disease/treatment';

  /// Gemini-backed translation endpoint (POST, JSON body).
  static String get translationEndpoint => '$baseUrl/api/translation/translate';
}
