import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PlatformChannelService {
  static const MethodChannel _channel = MethodChannel('com.ss.ams/platform');
  static const MethodChannel _securityChannel = MethodChannel('com.ss.ams/security');

  /// Get device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'id': androidInfo.id,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'androidId': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      }
      
      return {'platform': 'unknown'};
    } catch (e) {
      throw PlatformException(
        code: 'DEVICE_INFO_ERROR',
        message: 'Failed to get device info: $e',
      );
    }
  }

  /// Check if device is rooted/jailbroken (native implementation)
  static Future<bool> isDeviceRooted() async {
    try {
      final result = await _securityChannel.invokeMethod('isRooted');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      // If native method is not available, return false
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Check if device is jailbroken (iOS specific)
  static Future<bool> isDeviceJailbroken() async {
    if (!Platform.isIOS) return false;
    
    try {
      final result = await _securityChannel.invokeMethod('isJailbroken');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Check for root management apps (Android specific)
  static Future<bool> hasRootApps() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _securityChannel.invokeMethod('hasRootApps');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Check system properties (Android specific)
  static Future<Map<String, String>> getSystemProperties() async {
    if (!Platform.isAndroid) return {};
    
    try {
      final result = await _securityChannel.invokeMethod('getSystemProperties');
      return Map<String, String>.from(result as Map? ?? {});
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return {};
      }
      rethrow;
    }
  }

  /// Get app signature (Android specific)
  static Future<String?> getAppSignature() async {
    if (!Platform.isAndroid) return null;
    
    try {
      final result = await _channel.invokeMethod('getAppSignature');
      return result as String?;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return null;
      }
      rethrow;
    }
  }

  /// Check if app is installed from Play Store (Android specific)
  static Future<bool> isInstalledFromPlayStore() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('isInstalledFromPlayStore');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Check if app is installed from App Store (iOS specific)
  static Future<bool> isInstalledFromAppStore() async {
    if (!Platform.isIOS) return false;
    
    try {
      final result = await _channel.invokeMethod('isInstalledFromAppStore');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Get network information
  static Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      final result = await _channel.invokeMethod('getNetworkInfo');
      return Map<String, dynamic>.from(result as Map? ?? {});
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return {};
      }
      rethrow;
    }
  }

  /// Check if VPN is active
  static Future<bool> isVpnActive() async {
    try {
      final result = await _channel.invokeMethod('isVpnActive');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Get battery information
  static Future<Map<String, dynamic>> getBatteryInfo() async {
    try {
      final result = await _channel.invokeMethod('getBatteryInfo');
      return Map<String, dynamic>.from(result as Map? ?? {});
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return {};
      }
      rethrow;
    }
  }

  /// Check if device has secure lock screen
  static Future<bool> hasSecureLockScreen() async {
    try {
      final result = await _securityChannel.invokeMethod('hasSecureLockScreen');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Check if screen recording is active (iOS specific)
  static Future<bool> isScreenRecording() async {
    if (!Platform.isIOS) return false;
    
    try {
      final result = await _securityChannel.invokeMethod('isScreenRecording');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Check if screenshot is being taken (Android specific)
  static Future<bool> isScreenshotDetected() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _securityChannel.invokeMethod('isScreenshotDetected');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Prevent screenshots (Android specific)
  static Future<void> preventScreenshots(bool prevent) async {
    if (!Platform.isAndroid) return;
    
    try {
      await _securityChannel.invokeMethod('preventScreenshots', {'prevent': prevent});
    } on PlatformException catch (e) {
      if (e.code != 'UNIMPLEMENTED') {
        rethrow;
      }
    }
  }

  /// Get installed apps (Android specific)
  static Future<List<String>> getInstalledApps() async {
    if (!Platform.isAndroid) return [];
    
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      return List<String>.from(result as List? ?? []);
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return [];
      }
      rethrow;
    }
  }

  /// Check if specific app is installed
  static Future<bool> isAppInstalled(String packageName) async {
    try {
      final result = await _channel.invokeMethod('isAppInstalled', {'packageName': packageName});
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return false;
      }
      rethrow;
    }
  }

  /// Get app version
  static Future<String?> getAppVersion() async {
    try {
      final result = await _channel.invokeMethod('getAppVersion');
      return result as String?;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return null;
      }
      rethrow;
    }
  }

  /// Get build number
  static Future<String?> getBuildNumber() async {
    try {
      final result = await _channel.invokeMethod('getBuildNumber');
      return result as String?;
    } on PlatformException catch (e) {
      if (e.code == 'UNIMPLEMENTED') {
        return null;
      }
      rethrow;
    }
  }

  /// Check if method is available
  static Future<bool> isMethodAvailable(String methodName) async {
    try {
      await _channel.invokeMethod(methodName);
      return true;
    } on PlatformException catch (e) {
      return e.code != 'UNIMPLEMENTED';
    } catch (e) {
      return true; // Method exists but might have failed for other reasons
    }
  }
}
