import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Allows passing custom base URL at compile-time:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Runtime custom override (e.g. set by user or settings)
  static String? _customBaseUrl;

  static void setCustomBaseUrl(String? url) {
    _customBaseUrl = url?.trim().isNotEmpty == true ? url!.trim() : null;
  }

  /// Resolves the appropriate base URL according to platform and environment:
  /// - Android Emulator: 10.0.2.2 points to host machine localhost
  /// - iOS Simulator / Web / Desktop: localhost
  /// - Physical device: uses --dart-define or customBaseUrl
  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }

    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    try {
      if (Platform.isAndroid) {
        // Android Emulator host loopback alias
        return 'http://10.0.2.2:3000';
      } else if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return 'http://localhost:3000';
      }
    } catch (_) {
      // Fallback if Platform check fails
    }

    return 'http://localhost:3000';
  }

  // Endpoints
  static Uri get healthUri => Uri.parse('$baseUrl/health');
  static Uri get wordsUri => Uri.parse('$baseUrl/api/words');
  static Uri wordUri(int id) => Uri.parse('$baseUrl/api/words/$id');
  static Uri get categoriesUri => Uri.parse('$baseUrl/api/categories');
  static Uri categoryUri(int id) => Uri.parse('$baseUrl/api/categories/$id');
  static Uri get statsUri => Uri.parse('$baseUrl/api/stats');

  // Request timeout duration for offline-first responsiveness
  static const Duration requestTimeout = Duration(seconds: 4);
}
