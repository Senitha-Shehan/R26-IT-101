import 'dart:io';

class ApiConfig {
  /// Centralized base URL configuration for CropGuard backend REST API.
  /// Override with --dart-define=CROPGUARD_API_BASE_URL=http://HOST:8000.
  static String _overrideBaseUrl = '';
  static const _configuredBaseUrl = String.fromEnvironment(
    'CROPGUARD_API_BASE_URL',
  );

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceAll(RegExp(r'/$'), '');
    }
    if (Platform.isAndroid) {
      return 'http://192.168.8.121:8000';
    }
    return 'http://localhost:8000';
  }

  static set baseUrl(String url) {
    _overrideBaseUrl = url.replaceAll(RegExp(r'/$'), '');
  }

  static String get healthEndpoint => '$baseUrl/api/health';
  static String get uploadUncertainSampleEndpoint =>
      '$baseUrl/api/uncertain-samples';

  /// RAG treatment recommendation endpoint (POST, JSON body).
  static String get treatmentEndpoint => '$baseUrl/api/disease/treatment';

  /// Gemini-backed translation endpoint (POST, JSON body).
  static String get translationEndpoint => '$baseUrl/api/translation/translate';
}
