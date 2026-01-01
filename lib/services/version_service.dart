import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfo {
  final String currentVersion;
  final String minimumVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String? updateUrl;
  final String? updateMessage;

  VersionInfo({
    required this.currentVersion,
    required this.minimumVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.updateUrl,
    this.updateMessage,
  });

  bool get needsUpdate {
    return _compareVersions(currentVersion, minimumVersion) < 0;
  }

  bool get hasNewVersion {
    return _compareVersions(currentVersion, latestVersion) < 0;
  }

  // Compare version strings (e.g., "1.0.0" vs "1.0.1")
  // Returns: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    // Pad with zeros to make same length
    while (parts1.length < parts2.length) {
      parts1.add(0);
    }
    while (parts2.length < parts1.length) {
      parts2.add(0);
    }
    
    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    return 0;
  }
}

class VersionService {
  static const String _defaultApiUrl = 'https://api-deploy-9so9.onrender.com';
  
  static Future<VersionInfo> checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g., "1.0.0"
      
      // Get version info from server
      final customApiUrl = const String.fromEnvironment('API_URL');
      final apiUrl = customApiUrl.isNotEmpty 
          ? '$customApiUrl/api/version'
          : '$_defaultApiUrl/api/version';
      
      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return VersionInfo(
            currentVersion: currentVersion,
            minimumVersion: data['minimumVersion'] ?? currentVersion,
            latestVersion: data['latestVersion'] ?? currentVersion,
            forceUpdate: data['forceUpdate'] ?? false,
            updateUrl: data['updateUrl'],
            updateMessage: data['updateMessage'],
          );
        }
      } catch (e) {
        // If version check fails, allow app to continue
        // This prevents blocking users if version endpoint is down
      }
      
      // Default: no update required if server check fails
      return VersionInfo(
        currentVersion: currentVersion,
        minimumVersion: currentVersion,
        latestVersion: currentVersion,
        forceUpdate: false,
      );
    } catch (e) {
      // Fallback if package info fails
      return VersionInfo(
        currentVersion: '1.0.0',
        minimumVersion: '1.0.0',
        latestVersion: '1.0.0',
        forceUpdate: false,
      );
    }
  }
}
