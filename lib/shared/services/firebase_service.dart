
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../../core/utils/cache_config.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance {
    _instance ??= FirebaseService._internal();
    return _instance!;
  }

  FirebaseService._internal();

  FirebaseMessaging? _messaging;
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  bool _isInitialized = false;
  Function(RemoteMessage)? _notificationCallback;
  final List<RemoteMessage> _storedNotifications = [];

  /// Initialize Firebase services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;
      await _initializeMessaging();

      // Initialize Firebase Analytics
      _analytics = FirebaseAnalytics.instance;
      await _initializeAnalytics();

      // Initialize Firebase Crashlytics
      _crashlytics = FirebaseCrashlytics.instance;
      await _initializeCrashlytics();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  /// Initialize Firebase Messaging
  Future<void> _initializeMessaging() async {
    if (_messaging == null) return;

    // Request permission for notifications
    final settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    final token = await _messaging!.getToken();
    if (token != null) {
      await CacheConfig.setFirebaseToken(token);
      debugPrint('FCM Token: $token');
    }

    // Listen for token refresh
    _messaging!.onTokenRefresh.listen((token) async {
      await CacheConfig.setFirebaseToken(token);
      debugPrint('FCM Token refreshed: $token');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message (app opened from terminated state)
    final initialMessage = await _messaging!.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Initialize Firebase Analytics
  Future<void> _initializeAnalytics() async {
    if (_analytics == null) return;

    // Set analytics collection enabled
    await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);

    // Log app open event
    await _analytics!.logAppOpen();
  }

  /// Initialize Firebase Crashlytics
  Future<void> _initializeCrashlytics() async {
    if (_crashlytics == null) return;

    // Set crashlytics collection enabled
    await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = _crashlytics!.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics!.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');

    // Store notification for later retrieval
    _storeNotification(message);

    final pushDto = _parsePushMessage(message);
    if (pushDto != null) {
      // Handle push authentication request
      _handlePushAuthentication(pushDto);
    }

    // Trigger notification callback if set
    _notificationCallback?.call(message);
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    
    final pushDto = _parsePushMessage(message);
    if (pushDto != null) {
      // Navigate to push authentication screen
      _navigateToPushAuthentication(pushDto);
    }
  }

  /// Parse push message to PushDto
  PushDto? _parsePushMessage(RemoteMessage message) {
    try {
      final data = message.data;
      if (data.containsKey('pushId') && data.containsKey('username')) {
        return PushDto(
          pushId: data['pushId'] as String,
          username: data['username'] as String,
          answer: data['answer'] as String? ?? '',
          code: data['code'] as String? ?? '',
          userId: data['userId'] as String? ?? '',
        );
      }
    } catch (e) {
      debugPrint('Failed to parse push message: $e');
    }
    return null;
  }

  /// Handle push authentication
  void _handlePushAuthentication(PushDto pushDto) {
    debugPrint('Push authentication request: ${pushDto.pushId}');
    // The actual handling is now done by PushNotificationService
    // This method is kept for backward compatibility
  }

  /// Navigate to push authentication
  void _navigateToPushAuthentication(PushDto pushDto) {
    debugPrint('Navigate to push authentication: ${pushDto.pushId}');
    // The actual navigation is now handled by PushNotificationService
    // This method is kept for backward compatibility
  }

  /// Set notification callback for external handling
  void setNotificationCallback(Function(RemoteMessage) callback) {
    _notificationCallback = callback;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    if (_messaging == null) return null;
    return await _messaging!.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) return;
    await _messaging!.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) return;
    await _messaging!.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Log analytics event
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    if (_analytics == null) return;
    await _analytics!.logEvent(name: name, parameters: parameters);
  }

  /// Log authentication event
  Future<void> logAuthentication(String method) async {
    await logEvent('authentication', {
      'method': method,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log security event
  Future<void> logSecurityEvent(String event, Map<String, Object> details) async {
    await logEvent('security_event', {
      'event': event,
      ...details,
    });
  }

  /// Record error
  Future<void> recordError(dynamic exception, StackTrace? stackTrace) async {
    if (_crashlytics == null) return;
    await _crashlytics!.recordError(exception, stackTrace);
  }

  /// Set user identifier
  Future<void> setUserId(String userId) async {
    if (_analytics != null) {
      await _analytics!.setUserId(id: userId);
    }
    if (_crashlytics != null) {
      await _crashlytics!.setUserIdentifier(userId);
    }
  }

  /// Set user property
  Future<void> setUserProperty(String name, String value) async {
    if (_analytics == null) return;
    await _analytics!.setUserProperty(name: name, value: value);
  }

  /// Clear user data
  Future<void> clearUserData() async {
    if (_analytics != null) {
      await _analytics!.setUserId(id: null);
    }
    if (_crashlytics != null) {
      await _crashlytics!.setUserIdentifier('');
    }
  }

  /// Store notification for later retrieval
  void _storeNotification(RemoteMessage message) {
    _storedNotifications.add(message);

    // Keep only the last 50 notifications to prevent memory issues
    if (_storedNotifications.length > 50) {
      _storedNotifications.removeAt(0);
    }
  }



  /// Get stored notifications
  List<RemoteMessage> getStoredNotifications() {
    return List.unmodifiable(_storedNotifications);
  }

  /// Clear stored notifications
  void clearStoredNotifications() {
    _storedNotifications.clear();
  }

  /// Get notification count
  int getNotificationCount() {
    return _storedNotifications.length;
  }

  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Received background message: ${message.messageId}');
  
  // Handle background push authentication
  // This could update local storage or trigger a notification
}
