import 'package:connectivity_plus/connectivity_plus.dart';

/// Connection configuration constants and utilities
/// Converted from ConnectionConfig.java
class ConnectionConfig {
  // Timeout constants
  static const int readTimeout = 3000;
  static const int connectTimeout = 3000;
  
  // HTTP headers
  static const String connectAgent = 'USER-AGENT';
  static const String connectAgentValue = 'USER-AGENT';
  static const String connectLang = 'ACCEPT-LANGUAGE';
  static const String connectLangValue = 'en-US,en;0.5';
  
  // HTTP methods
  static const String requestGet = 'GET';
  static const String requestPost = 'POST';
  
  /// Check if network is available
  static Future<bool> isNetworkAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }
  
  /// Get current connectivity status
  static Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      return await Connectivity().checkConnectivity();
    } catch (e) {
      return ConnectivityResult.none;
    }
  }
  
  /// Check if connected to WiFi
  static Future<bool> isWifiConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.wifi;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if connected to mobile data
  static Future<bool> isMobileConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.mobile;
    } catch (e) {
      return false;
    }
  }
  
  /// Get default HTTP headers
  static Map<String, String> getDefaultHeaders() {
    return {
      connectAgent: connectAgentValue,
      connectLang: connectLangValue,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
