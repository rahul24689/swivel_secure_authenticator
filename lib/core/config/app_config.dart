import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/cache_config.dart';
import '../enums/object_type_enum.dart';
import '../../shared/services/services.dart';

/// Application configuration and lifecycle management
/// Converted from AppConfig.java
class AppConfig with WidgetsBindingObserver {
  static AppConfig? _instance;
  static Timer? _timer;
  
  static bool isForeground = false;
  static int actionCount = 0;
  static bool isRunning = false;
  
  VoidCallback? _progressListener;
  
  AppConfig._();
  
  static AppConfig get instance {
    _instance ??= AppConfig._();
    return _instance!;
  }
  
  /// Initialize app configuration
  void initialize({VoidCallback? progressListener}) {
    _progressListener = progressListener;
    WidgetsBinding.instance.addObserver(this);
    createKeys();
  }
  
  /// Dispose app configuration
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cancelTimer();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onMoveToForeground();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        onMoveToBackground();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
  
  /// Check if provisioning is available
  static Future<bool> checkProvisioning() async {
    try {
      final ssDetailService = SsDetailServiceImpl();
      final count = await ssDetailService.count();
      if (count > 0) {
        debugPrint('APP_CONFIG: Strings available');
        return true;
      }
      
      final oauthService = OAuthServiceImpl();
      final oauthCount = await oauthService.count();
      if (oauthCount > 0) {
        debugPrint('APP_CONFIG: OATH available');
        return true;
      }
    } catch (e) {
      debugPrint('Error checking provisioning: $e');
    }
    return false;
  }
  
  /// Create initial cache keys
  static Future<void> createKeys() async {
    // Check if we have provisions and set keys accordingly
    if (await checkProvisioning()) {
      debugPrint('APP_CONFIG: KEY_PROVISIONING_OK');
      await CacheConfig.update('KEY_PROVISIONING_OK', true, ObjectType.boolean);
    }
    
    if (!CacheConfig.contains('KEY_PERMISSION')) {
      await CacheConfig.add('KEY_PERMISSION', false, ObjectType.boolean);
    }
    
    if (!CacheConfig.contains('KEY_PROVISIONING_OK')) {
      await CacheConfig.add('KEY_PROVISIONING_OK', false, ObjectType.boolean);
      await CacheConfig.add('KEY_OATH_OK', false, ObjectType.boolean);
      await CacheConfig.add('KEY_OTC_OK', false, ObjectType.boolean);
    }
  }
  
  /// Handle app moving to foreground
  void onMoveToForeground() {
    debugPrint('App moved to foreground');
    
    _progressListener?.call();
    
    // Hide progress after delay
    Timer(const Duration(milliseconds: 4000), () {
      // Hide progress logic here
    });
    
    isForeground = true;
    createTimer();
  }
  
  /// Handle app moving to background
  void onMoveToBackground() {
    debugPrint('App moved to background');
    
    isForeground = false;
    cancelTimer();
  }
  
  /// Create timer for background tasks
  static void createTimer() {
    if (_timer == null) {
      _timer = Timer.periodic(
        Duration(milliseconds: isRunning ? 1000 : 4000),
        (timer) {
          try {
            if (!isRunning) {
              return;
            }
            
            if (actionCount > 1) {
              debugPrint('Foreground action triggered');
              // Call biometrics or other action
              _triggerBiometrics();
            }
          } catch (e) {
            debugPrint('Timer error: $e');
          } finally {
            cancelTimer();
          }
        },
      );
    }
  }
  
  /// Cancel the timer
  static void cancelTimer() {
    try {
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
    } catch (e) {
      debugPrint('Error canceling timer: $e');
    }
  }
  
  /// Trigger biometric authentication
  static void _triggerBiometrics() {
    // This would trigger biometric authentication
    // Implementation depends on the biometric service
    debugPrint('Triggering biometric authentication');
  }
  
  /// Increment action count
  static void incrementActionCount() {
    actionCount++;
  }
  
  /// Reset action count
  static void resetActionCount() {
    actionCount = 0;
  }
  
  /// Set running state
  static void setRunning(bool running) {
    isRunning = running;
  }
}
