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
    // Auto-detect default host based on platform
    if (Platform.isAndroid) {
      // 172.20.10.4 is the current dev PC LAN IP (10.0.2.2 for Android Emulator)
      return 'http://172.20.10.4:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  static set baseUrl(String url) {
    _overrideBaseUrl = url.replaceAll(RegExp(r'/$'), '');
  }

  static String get healthEndpoint => '$baseUrl/api/health';
  static String get uploadUncertainSampleEndpoint => '$baseUrl/api/uncertain-samples';
}
