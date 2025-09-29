import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/models.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/cache_config.dart';
import 'api_service.dart';
import 'firebase_service.dart';

class PushNotificationService {
  static PushNotificationService? _instance;
  static PushNotificationService get instance {
    _instance ??= PushNotificationService._internal();
    return _instance!;
  }

  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final StreamController<PushDto> _pushRequestController = StreamController<PushDto>.broadcast();
  final List<PushDto> _pendingRequests = [];

  bool _isInitialized = false;
  Function(PushDto)? _pushRequestCallback;

  /// Stream of incoming push authentication requests
  Stream<PushDto> get pushRequestStream => _pushRequestController.stream;

  /// Initialize push notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeLocalNotifications();
      await _setupFirebaseHandlers();
      _isInitialized = true;
      debugPrint('Push notification service initialized');
    } catch (e) {
      debugPrint('Failed to initialize push notification service: $e');
      rethrow;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createNotificationChannels();
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const pushChannel = AndroidNotificationChannel(
      'push_auth_channel',
      'Push Authentication',
      description: 'Notifications for push authentication requests',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const generalChannel = AndroidNotificationChannel(
      'general_channel',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(pushChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  /// Setup Firebase message handlers
  Future<void> _setupFirebaseHandlers() async {
    // Set custom notification callback for Firebase service
    FirebaseService.instance.setNotificationCallback(_handleFirebaseMessage);
  }

  /// Handle Firebase message
  void _handleFirebaseMessage(RemoteMessage message) {
    debugPrint('Handling Firebase message: ${message.messageId}');

    final pushDto = _parsePushMessage(message);
    if (pushDto != null) {
      _handlePushAuthenticationRequest(pushDto);
    } else {
      // Handle general notification
      _showGeneralNotification(message);
    }
  }

  /// Parse Firebase message to PushDto
  PushDto? _parsePushMessage(RemoteMessage message) {
    try {
      final data = message.data;
      
      // Check if this is a push authentication request
      if (data.containsKey('pushId') && data.containsKey('username')) {
        return PushDto(
          pushId: data['pushId'] as String,
          username: data['username'] as String,
          answer: '', // Will be set when user responds
          code: data['confKey'] as String? ?? data['code'] as String? ?? '',
          userId: data['provisioncode'] as String? ?? data['userId'] as String? ?? '',
        );
      }
    } catch (e) {
      debugPrint('Failed to parse push message: $e');
    }
    return null;
  }

  /// Handle push authentication request
  void _handlePushAuthenticationRequest(PushDto pushDto) {
    debugPrint('Handling push authentication request: ${pushDto.pushId}');

    // Store the request
    _pendingRequests.add(pushDto);

    // Show local notification
    _showPushAuthenticationNotification(pushDto);

    // Emit to stream for UI handling
    _pushRequestController.add(pushDto);

    // Trigger callback if set
    _pushRequestCallback?.call(pushDto);
  }

  /// Show push authentication notification
  Future<void> _showPushAuthenticationNotification(PushDto pushDto) async {
    const androidDetails = AndroidNotificationDetails(
      'push_auth_channel',
      'Push Authentication',
      channelDescription: 'Notifications for push authentication requests',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      autoCancel: false,
      ongoing: true,
      actions: [
        AndroidNotificationAction(
          'approve',
          'Approve',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_check'),
        ),
        AndroidNotificationAction(
          'deny',
          'Deny',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_close'),
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'push_auth_category',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      pushDto.pushId.hashCode,
      'Authentication Request',
      'Approve login for ${pushDto.username}?',
      notificationDetails,
      payload: jsonEncode(pushDto.toJson()),
    );
  }

  /// Show general notification
  Future<void> _showGeneralNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Swivel Secure',
      message.notification?.body ?? 'New notification',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.actionId}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        
        // Check if this is a push authentication notification
        if (data.containsKey('pushId')) {
          final pushDto = PushDto.fromJson(data);
          
          if (response.actionId == 'approve') {
            respondToPushRequest(pushDto, true);
          } else if (response.actionId == 'deny') {
            respondToPushRequest(pushDto, false);
          } else {
            // Open app to handle the request
            _pushRequestController.add(pushDto);
          }
        }
      } catch (e) {
        debugPrint('Failed to handle notification tap: $e');
      }
    }
  }

  /// Respond to push authentication request
  Future<void> respondToPushRequest(PushDto pushDto, bool approved) async {
    try {
      debugPrint('Responding to push request: ${pushDto.pushId}, approved: $approved');

      // Remove from pending requests
      _pendingRequests.removeWhere((p) => p.pushId == pushDto.pushId);

      // Dismiss notification
      await _localNotifications.cancel(pushDto.pushId.hashCode);

      // Get server details for the user
      final db = DatabaseHelper.instance;
      final sasEntities = await db.sasDao.getByUsername(pushDto.username);
      
      if (sasEntities.isEmpty) {
        debugPrint('No SAS entity found for username: ${pushDto.username}');
        return;
      }

      final sasEntity = sasEntities.first;
      final sasIdString = sasEntity.sasId;
      if (sasIdString == null) {
        debugPrint('SAS ID is null for entity: ${sasEntity.id}');
        return;
      }

      final sasIdInt = int.tryParse(sasIdString);
      if (sasIdInt == null) {
        debugPrint('Invalid SAS ID format: $sasIdString');
        return;
      }

      final serverDetails = await db.ssDetailDao.getBySasId(sasIdInt);
      
      if (serverDetails.isEmpty) {
        debugPrint('No server details found for SAS ID: ${sasEntity.sasId}');
        return;
      }

      final serverDetail = serverDetails.first;

      // Send response to server
      final response = await ApiService.respondToPush(
        serverDetail: serverDetail,
        pushRequest: pushDto.copyWith(answer: approved ? 'yes' : 'no'),
        approved: approved,
        reason: approved ? null : 'User denied',
      );

      if (response.success) {
        debugPrint('Push response sent successfully');
        
        // Log the response
        await _logPushResponse(pushDto, approved, 'success');
      } else {
        debugPrint('Push response failed: ${response.message}');
        await _logPushResponse(pushDto, approved, 'failed');
      }
    } catch (e) {
      debugPrint('Failed to respond to push request: $e');
      await _logPushResponse(pushDto, approved, 'error');
    }
  }

  /// Log push response for audit trail
  Future<void> _logPushResponse(PushDto pushDto, bool approved, String status) async {
    try {
      final logData = {
        'pushId': pushDto.pushId,
        'username': pushDto.username,
        'approved': approved,
        'status': status,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await CacheConfig.setPushResponseLog(jsonEncode(logData));
    } catch (e) {
      debugPrint('Failed to log push response: $e');
    }
  }

  /// Get pending push requests
  List<PushDto> get pendingRequests => List.unmodifiable(_pendingRequests);

  /// Set push request callback
  void setPushRequestCallback(Function(PushDto) callback) {
    _pushRequestCallback = callback;
  }

  /// Clear all pending requests
  void clearPendingRequests() {
    _pendingRequests.clear();
  }

  /// Dispose resources
  void dispose() {
    _pushRequestController.close();
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
