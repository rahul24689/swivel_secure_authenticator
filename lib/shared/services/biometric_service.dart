import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../../core/utils/cache_config.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  static Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check if device has biometric hardware
  static Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final biometricTypes = <BiometricType>[];

      for (final biometric in availableBiometrics) {
        switch (biometric) {
          case BiometricType.fingerprint:
            biometricTypes.add(BiometricType.fingerprint);
            break;
          case BiometricType.face:
            biometricTypes.add(BiometricType.face);
            break;
          case BiometricType.iris:
            biometricTypes.add(BiometricType.iris);
            break;
          case BiometricType.weak:
          case BiometricType.strong:
            // These are Android-specific, map to fingerprint for simplicity
            if (!biometricTypes.contains(BiometricType.fingerprint)) {
              biometricTypes.add(BiometricType.fingerprint);
            }
            break;
        }
      }

      return biometricTypes;
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  static Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access the application',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
    bool biometricOnly = false,
  }) async {
    try {
      // Check if biometrics are available
      if (!await isAvailable()) {
        return false;
      }

      // Check if biometric authentication is enabled in settings
      if (!CacheConfig.isBiometricEnabled()) {
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: biometricOnly,
        ),
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      // Handle specific platform exceptions
      switch (e.code) {
        case 'NotAvailable':
          return false;
        case 'NotEnrolled':
          return false;
        case 'LockedOut':
          throw BiometricException('Biometric authentication is locked out', e.code);
        case 'PermanentlyLockedOut':
          throw BiometricException('Biometric authentication is permanently locked out', e.code);
        case 'UserCancel':
          throw BiometricException('User cancelled biometric authentication', e.code);
        case 'UserFallback':
          throw BiometricException('User chose fallback authentication', e.code);
        case 'BiometricOnlyNotSupported':
          throw BiometricException('Biometric-only authentication not supported', e.code);
        default:
          throw BiometricException('Biometric authentication failed: ${e.message}', e.code);
      }
    } catch (e) {
      throw BiometricException('Unexpected error during biometric authentication: $e');
    }
  }

  /// Authenticate for specific feature
  static Future<bool> authenticateForFeature(String feature) async {
    final reason = 'Please authenticate to access $feature';
    return await authenticate(localizedReason: reason);
  }

  /// Authenticate for security strings
  static Future<bool> authenticateForSecurityStrings() async {
    return await authenticateForFeature('security strings');
  }

  /// Authenticate for OATH tokens
  static Future<bool> authenticateForOATH() async {
    return await authenticateForFeature('OATH tokens');
  }

  /// Authenticate for settings
  static Future<bool> authenticateForSettings() async {
    return await authenticateForFeature('settings');
  }

  /// Stop authentication (if possible)
  static Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignore errors when stopping authentication
    }
  }

  /// Check if biometric authentication is enrolled
  static Future<bool> isBiometricEnrolled() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Enable biometric authentication in app settings
  static Future<void> enableBiometric() async {
    await CacheConfig.setBiometricEnabled(true);
  }

  /// Disable biometric authentication in app settings
  static Future<void> disableBiometric() async {
    await CacheConfig.setBiometricEnabled(false);
  }

  /// Check if biometric authentication is enabled in app settings
  static bool isBiometricEnabledInSettings() {
    return CacheConfig.isBiometricEnabled();
  }

  /// Get biometric capability summary
  static Future<BiometricCapability> getBiometricCapability() async {
    final isSupported = await isDeviceSupported();
    final isAvailableNow = await isAvailable();
    final isEnrolled = await isBiometricEnrolled();
    final availableTypes = await getAvailableBiometrics();
    final isEnabledInSettings = isBiometricEnabledInSettings();

    return BiometricCapability(
      isSupported: isSupported,
      isAvailable: isAvailableNow,
      isEnrolled: isEnrolled,
      availableTypes: availableTypes,
      isEnabledInSettings: isEnabledInSettings,
    );
  }

  /// Prompt user to set up biometric authentication
  static Future<bool> promptBiometricSetup() async {
    final capability = await getBiometricCapability();
    
    if (!capability.isSupported) {
      throw BiometricException('Biometric authentication is not supported on this device');
    }
    
    if (!capability.isEnrolled) {
      throw BiometricException('No biometric credentials are enrolled on this device');
    }
    
    if (capability.isAvailable && capability.isEnrolled) {
      await enableBiometric();
      return true;
    }
    
    return false;
  }
}

/// Exception class for biometric authentication errors
class BiometricException implements Exception {
  final String message;
  final String? code;

  BiometricException(this.message, [this.code]);

  @override
  String toString() => 'BiometricException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Class to represent biometric capability information
class BiometricCapability {
  final bool isSupported;
  final bool isAvailable;
  final bool isEnrolled;
  final List<BiometricType> availableTypes;
  final bool isEnabledInSettings;

  BiometricCapability({
    required this.isSupported,
    required this.isAvailable,
    required this.isEnrolled,
    required this.availableTypes,
    required this.isEnabledInSettings,
  });

  bool get canAuthenticate => isSupported && isAvailable && isEnrolled && isEnabledInSettings;

  String get statusMessage {
    if (!isSupported) return 'Biometric authentication is not supported';
    if (!isEnrolled) return 'No biometric credentials enrolled';
    if (!isAvailable) return 'Biometric authentication is not available';
    if (!isEnabledInSettings) return 'Biometric authentication is disabled in settings';
    return 'Biometric authentication is ready';
  }

  @override
  String toString() {
    return 'BiometricCapability(supported: $isSupported, available: $isAvailable, '
           'enrolled: $isEnrolled, enabledInSettings: $isEnabledInSettings, '
           'types: $availableTypes)';
  }
}
