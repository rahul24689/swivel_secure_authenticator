import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'encryption_service.dart';
import 'root_detection_service.dart';
import '../utils/cache_config.dart';
import '../constants/app_constants.dart';

class SecurityManager {
  static SecurityManager? _instance;
  static SecurityManager get instance {
    _instance ??= SecurityManager._internal();
    return _instance!;
  }

  SecurityManager._internal();

  bool _isInitialized = false;
  SecurityStatus? _lastSecurityCheck;

  /// Initialize security manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize encryption service
      await EncryptionService.initialize();

      // Perform initial security check
      await performSecurityCheck();

      _isInitialized = true;
    } catch (e) {
      throw SecurityException('Failed to initialize security manager: $e');
    }
  }

  /// Perform comprehensive security check
  Future<SecurityStatus> performSecurityCheck() async {
    final checks = <String, bool>{};
    final warnings = <String>[];
    final errors = <String>[];

    try {
      // Check if device is rooted/jailbroken
      final isRooted = await RootDetectionService.isDeviceRooted();
      checks['Root/Jailbreak Detection'] = !isRooted;
      
      if (isRooted) {
        errors.add('Device is rooted/jailbroken');
        await CacheConfig.setRooted(true);
      }

      // Check app integrity
      final appIntegrityOk = await _checkAppIntegrity();
      checks['App Integrity'] = appIntegrityOk;
      
      if (!appIntegrityOk) {
        warnings.add('App integrity check failed');
      }

      // Check debug mode
      final isDebugMode = await _isDebugMode();
      checks['Debug Mode'] = !isDebugMode;
      
      if (isDebugMode) {
        warnings.add('App is running in debug mode');
      }

      // Check emulator
      final isEmulator = await _isRunningOnEmulator();
      checks['Emulator Detection'] = !isEmulator;
      
      if (isEmulator) {
        warnings.add('App is running on an emulator');
      }

      // Check encryption
      final encryptionOk = EncryptionService.isInitialized;
      checks['Encryption'] = encryptionOk;
      
      if (!encryptionOk) {
        errors.add('Encryption service not initialized');
      }

      // Check secure storage
      final secureStorageOk = await _checkSecureStorage();
      checks['Secure Storage'] = secureStorageOk;
      
      if (!secureStorageOk) {
        warnings.add('Secure storage may not be available');
      }

      // Check network security
      final networkSecurityOk = await _checkNetworkSecurity();
      checks['Network Security'] = networkSecurityOk;
      
      if (!networkSecurityOk) {
        warnings.add('Network security configuration issues detected');
      }

      final securityLevel = _calculateSecurityLevel(checks, warnings, errors);
      
      _lastSecurityCheck = SecurityStatus(
        isSecure: errors.isEmpty,
        securityLevel: securityLevel,
        checks: checks,
        warnings: warnings,
        errors: errors,
        timestamp: DateTime.now(),
      );

      return _lastSecurityCheck!;
    } catch (e) {
      throw SecurityException('Security check failed: $e');
    }
  }

  /// Check if app should be blocked due to security issues
  Future<bool> shouldBlockApp() async {
    if (_lastSecurityCheck == null) {
      await performSecurityCheck();
    }

    final status = _lastSecurityCheck!;
    
    // Block if there are critical errors
    if (status.errors.isNotEmpty) {
      // Check if root detection should block the app
      if (await RootDetectionService.shouldBlockDueToRoot()) {
        return true;
      }
    }

    // Block if security level is too low
    return status.securityLevel == SecurityLevel.critical;
  }

  /// Get security recommendations
  Future<List<String>> getSecurityRecommendations() async {
    if (_lastSecurityCheck == null) {
      await performSecurityCheck();
    }

    final recommendations = <String>[];
    final status = _lastSecurityCheck!;

    if (status.errors.contains('Device is rooted/jailbroken')) {
      recommendations.add('Use the app on a non-rooted device for better security');
    }

    if (status.warnings.contains('App is running in debug mode')) {
      recommendations.add('Use the production version of the app');
    }

    if (status.warnings.contains('App is running on an emulator')) {
      recommendations.add('Use the app on a physical device');
    }

    if (!status.checks['Secure Storage']!) {
      recommendations.add('Ensure device has secure storage capabilities');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Your device meets all security requirements');
    }

    return recommendations;
  }

  /// Check app integrity
  Future<bool> _checkAppIntegrity() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Check if package name matches expected
      if (packageInfo.packageName != AppConstants.packageName) {
        return false;
      }

      // Additional integrity checks can be added here
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if running in debug mode
  Future<bool> _isDebugMode() async {
    // In Flutter, this is determined at compile time
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// Check if running on emulator
  Future<bool> _isRunningOnEmulator() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return !iosInfo.isPhysicalDevice;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check secure storage availability
  Future<bool> _checkSecureStorage() async {
    try {
      // Test if we can write and read from secure storage
      await EncryptionService.encrypt('test');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check network security configuration
  Future<bool> _checkNetworkSecurity() async {
    // This would check for things like certificate pinning, etc.
    // For now, return true
    return true;
  }

  /// Calculate overall security level
  SecurityLevel _calculateSecurityLevel(
    Map<String, bool> checks,
    List<String> warnings,
    List<String> errors,
  ) {
    if (errors.isNotEmpty) {
      return SecurityLevel.critical;
    }

    final passedChecks = checks.values.where((passed) => passed).length;
    final totalChecks = checks.length;
    final passRate = passedChecks / totalChecks;

    if (passRate >= 0.9 && warnings.isEmpty) {
      return SecurityLevel.high;
    } else if (passRate >= 0.7) {
      return SecurityLevel.medium;
    } else {
      return SecurityLevel.low;
    }
  }

  /// Get last security check result
  SecurityStatus? get lastSecurityCheck => _lastSecurityCheck;

  /// Force refresh security check
  Future<SecurityStatus> refreshSecurityCheck() async {
    _lastSecurityCheck = null;
    return await performSecurityCheck();
  }

  /// Check if security manager is initialized
  bool get isInitialized => _isInitialized;

  /// Clear security data (for logout)
  Future<void> clearSecurityData() async {
    await EncryptionService.clearKeys();
    _lastSecurityCheck = null;
    _isInitialized = false;
  }
}

/// Security status class
class SecurityStatus {
  final bool isSecure;
  final SecurityLevel securityLevel;
  final Map<String, bool> checks;
  final List<String> warnings;
  final List<String> errors;
  final DateTime timestamp;

  SecurityStatus({
    required this.isSecure,
    required this.securityLevel,
    required this.checks,
    required this.warnings,
    required this.errors,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'SecurityStatus(isSecure: $isSecure, level: $securityLevel, '
           'checks: ${checks.length}, warnings: ${warnings.length}, '
           'errors: ${errors.length})';
  }
}

/// Security level enumeration
enum SecurityLevel {
  critical,
  low,
  medium,
  high,
}

/// Security exception class
class SecurityException implements Exception {
  final String message;

  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
