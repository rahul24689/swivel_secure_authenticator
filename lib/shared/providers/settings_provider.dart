import 'package:flutter/foundation.dart';
import '../../core/utils/cache_config.dart';
import '../../core/constants/enums.dart';
import '../../core/security/security_manager.dart';
import '../services/biometric_service.dart';

class SettingsProvider extends ChangeNotifier {
  // Settings state
  bool _biometricEnabled = false;
  bool _pushNotificationsEnabled = false;
  bool _autoLockEnabled = true;
  int _autoLockTimeout = 300; // 5 minutes in seconds
  SecurityStatus? _securityStatus;
  bool _isLoading = false;

  // Getters
  bool get biometricEnabled => _biometricEnabled;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get autoLockEnabled => _autoLockEnabled;
  int get autoLockTimeout => _autoLockTimeout;
  SecurityStatus? get securityStatus => _securityStatus;
  bool get isLoading => _isLoading;

  /// Initialize settings provider
  Future<void> initialize() async {
    await _loadSettings();
    await _loadSecurityStatus();
  }

  /// Load settings from cache
  Future<void> _loadSettings() async {
    _biometricEnabled = CacheConfig.isBiometricEnabled();
    _pushNotificationsEnabled = CacheConfig.isPushEnabled();
    
    // Load other settings from cache
    _autoLockEnabled = CacheConfig.get('auto_lock_enabled', ObjectType.boolean) as bool? ?? true;
    _autoLockTimeout = CacheConfig.get('auto_lock_timeout', ObjectType.integer) as int? ?? 300;
    
    notifyListeners();
  }

  /// Load security status
  Future<void> _loadSecurityStatus() async {
    _setLoading(true);
    try {
      _securityStatus = await SecurityManager.instance.performSecurityCheck();
    } catch (e) {
      debugPrint('Failed to load security status: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    if (enabled) {
      // Check if biometric is available
      final capability = await BiometricService.getBiometricCapability();
      if (!capability.canAuthenticate) {
        throw Exception(capability.statusMessage);
      }

      // Test biometric authentication
      final isAuthenticated = await BiometricService.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
      );

      if (!isAuthenticated) {
        throw Exception('Biometric authentication failed');
      }
    }

    _biometricEnabled = enabled;
    await CacheConfig.setBiometricEnabled(enabled);
    notifyListeners();
  }

  /// Toggle push notifications
  Future<void> togglePushNotifications(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    await CacheConfig.setPushEnabled(enabled);
    notifyListeners();
  }

  /// Toggle auto lock
  Future<void> toggleAutoLock(bool enabled) async {
    _autoLockEnabled = enabled;
    await CacheConfig.add('auto_lock_enabled', enabled, ObjectType.boolean);
    notifyListeners();
  }

  /// Set auto lock timeout
  Future<void> setAutoLockTimeout(int timeoutSeconds) async {
    _autoLockTimeout = timeoutSeconds;
    await CacheConfig.add('auto_lock_timeout', timeoutSeconds, ObjectType.integer);
    notifyListeners();
  }

  /// Refresh security status
  Future<void> refreshSecurityStatus() async {
    await _loadSecurityStatus();
  }

  /// Get biometric capability
  Future<BiometricCapability> getBiometricCapability() async {
    return await BiometricService.getBiometricCapability();
  }

  /// Check if device is secure
  bool get isDeviceSecure => _securityStatus?.isSecure ?? false;

  /// Get security level
  SecurityLevel get securityLevel => _securityStatus?.securityLevel ?? SecurityLevel.critical;

  /// Get security recommendations
  Future<List<String>> getSecurityRecommendations() async {
    return await SecurityManager.instance.getSecurityRecommendations();
  }

  /// Export settings
  Map<String, dynamic> exportSettings() {
    return {
      'biometric_enabled': _biometricEnabled,
      'push_notifications_enabled': _pushNotificationsEnabled,
      'auto_lock_enabled': _autoLockEnabled,
      'auto_lock_timeout': _autoLockTimeout,
    };
  }

  /// Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('biometric_enabled')) {
      await toggleBiometric(settings['biometric_enabled'] as bool);
    }
    
    if (settings.containsKey('push_notifications_enabled')) {
      await togglePushNotifications(settings['push_notifications_enabled'] as bool);
    }
    
    if (settings.containsKey('auto_lock_enabled')) {
      await toggleAutoLock(settings['auto_lock_enabled'] as bool);
    }
    
    if (settings.containsKey('auto_lock_timeout')) {
      await setAutoLockTimeout(settings['auto_lock_timeout'] as int);
    }
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    await toggleBiometric(false);
    await togglePushNotifications(false);
    await toggleAutoLock(true);
    await setAutoLockTimeout(300);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
