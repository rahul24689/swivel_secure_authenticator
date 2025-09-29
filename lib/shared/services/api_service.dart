import 'package:dio/dio.dart';
import '../models/models.dart';
import '../../core/network/http_client.dart';
import '../../core/constants/app_constants.dart';

class ApiService {
  static const String _provisionPath = '/provision';
  static const String _authPath = '/auth';
  static const String _pushPath = '/push';
  static const String _oathPath = '/oath';
  static const String _statusPath = '/status';

  /// Build base URL from server details
  static String _buildBaseUrl(SsDetailEntity serverDetail) {
    final protocol = serverDetail.usingSsl ? 'https' : 'http';
    return '$protocol://${serverDetail.hostname}:${serverDetail.port}';
  }

  /// Configure HTTP client for server
  static void _configureForServer(SsDetailEntity serverDetail) {
    final baseUrl = _buildBaseUrl(serverDetail);
    HttpClient.updateBaseUrl(baseUrl);
    
    // Add server-specific headers
    HttpClient.addHeader('X-Site-ID', serverDetail.siteId);
    HttpClient.addHeader('X-Connection-Type', serverDetail.connectionType);
  }

  /// Provision device with server
  static Future<ProvisionResponse> provisionDevice({
    required SsDetailEntity serverDetail,
    required ProvisionInfoEntity provisionInfo,
  }) async {
    try {
      _configureForServer(serverDetail);

      final requestData = {
        'siteId': provisionInfo.siteId,
        'username': provisionInfo.username,
        'provisionCode': provisionInfo.provisionCode,
        'deviceInfo': await _getDeviceInfo(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await HttpClient.post(
        _provisionPath,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ProvisionResponse.fromJson(data);
      } else {
        throw ApiException(
          'Provisioning failed',
          'PROVISION_FAILED',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Provisioning failed');
    } catch (e) {
      throw ApiException('Unexpected error during provisioning: $e');
    }
  }

  /// Authenticate with security string
  static Future<AuthResponse> authenticateWithSecurityString({
    required SsDetailEntity serverDetail,
    required SasEntity sasEntity,
    required String securityString,
    required int tokenIndex,
  }) async {
    try {
      _configureForServer(serverDetail);

      final requestData = {
        'username': sasEntity.username,
        'sasId': sasEntity.sasId,
        'securityString': securityString,
        'tokenIndex': tokenIndex,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await HttpClient.post(
        _authPath,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        throw ApiException(
          'Authentication failed',
          'AUTH_FAILED',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Authentication failed');
    } catch (e) {
      throw ApiException('Unexpected error during authentication: $e');
    }
  }

  /// Authenticate with OATH TOTP
  static Future<AuthResponse> authenticateWithOATH({
    required SsDetailEntity serverDetail,
    required OAuthEntity oauthEntity,
    required String totpCode,
  }) async {
    try {
      _configureForServer(serverDetail);

      final requestData = {
        'username': oauthEntity.username,
        'issuer': oauthEntity.issuer,
        'account': oauthEntity.account,
        'totpCode': totpCode,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await HttpClient.post(
        '$_oathPath/auth',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        throw ApiException(
          'OATH authentication failed',
          'OATH_AUTH_FAILED',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'OATH authentication failed');
    } catch (e) {
      throw ApiException('Unexpected error during OATH authentication: $e');
    }
  }

  /// Register for push notifications
  static Future<PushRegistrationResponse> registerForPush({
    required SsDetailEntity serverDetail,
    required SasEntity sasEntity,
    required String firebaseToken,
  }) async {
    try {
      _configureForServer(serverDetail);

      final requestData = {
        'username': sasEntity.username,
        'sasId': sasEntity.sasId,
        'firebaseToken': firebaseToken,
        'deviceInfo': await _getDeviceInfo(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await HttpClient.post(
        '$_pushPath/register',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return PushRegistrationResponse.fromJson(data);
      } else {
        throw ApiException(
          'Push registration failed',
          'PUSH_REGISTRATION_FAILED',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Push registration failed');
    } catch (e) {
      throw ApiException('Unexpected error during push registration: $e');
    }
  }

  /// Respond to push authentication
  static Future<PushResponse> respondToPush({
    required SsDetailEntity serverDetail,
    required PushDto pushRequest,
    required bool approved,
    String? reason,
  }) async {
    try {
      _configureForServer(serverDetail);

      final requestData = {
        'pushId': pushRequest.pushId,
        'approved': approved,
        'reason': reason,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await HttpClient.post(
        '$_pushPath/respond',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return PushResponse.fromJson(data);
      } else {
        throw ApiException(
          'Push response failed',
          'PUSH_RESPONSE_FAILED',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Push response failed');
    } catch (e) {
      throw ApiException('Unexpected error during push response: $e');
    }
  }

  /// Check server status
  static Future<ServerStatus> checkServerStatus(SsDetailEntity serverDetail) async {
    try {
      _configureForServer(serverDetail);

      final response = await HttpClient.get(_statusPath);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ServerStatus.fromJson(data);
      } else {
        throw ApiException(
          'Server status check failed',
          'STATUS_CHECK_FAILED',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Server status check failed');
    } catch (e) {
      throw ApiException('Unexpected error during server status check: $e');
    }
  }

  /// Get server capabilities
  static Future<ServerCapabilities> getServerCapabilities(SsDetailEntity serverDetail) async {
    try {
      _configureForServer(serverDetail);

      final response = await HttpClient.get('$_statusPath/capabilities');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ServerCapabilities.fromJson(data);
      } else {
        throw ApiException(
          'Server capabilities check failed',
          'CAPABILITIES_CHECK_FAILED',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'Server capabilities check failed');
    } catch (e) {
      throw ApiException('Unexpected error during server capabilities check: $e');
    }
  }

  /// Test server connection
  static Future<bool> testConnection(SsDetailEntity serverDetail) async {
    try {
      await checkServerStatus(serverDetail);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get device information for API requests
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': 'flutter',
      'version': AppConstants.appVersion,
      'buildNumber': AppConstants.buildNumber,
      'deviceId': await _getDeviceId(),
    };
  }

  /// Get device ID
  static Future<String> _getDeviceId() async {
    // This should be implemented using device_info_plus
    // For now, return a placeholder
    return 'flutter_device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Handle Dio exceptions
  static ApiException _handleDioException(DioException e, String defaultMessage) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return ApiException(
          data['message'] ?? defaultMessage,
          data['code'] ?? 'API_ERROR',
          e.response!.statusCode,
        );
      }
    }

    return ApiException(
      e.message ?? defaultMessage,
      'NETWORK_ERROR',
      e.response?.statusCode,
    );
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  ApiException(this.message, [this.code = 'API_ERROR', this.statusCode]);

  @override
  String toString() {
    return 'ApiException(message: $message, code: $code, statusCode: $statusCode)';
  }
}



class ServerStatus {
  final bool online;
  final String version;
  final DateTime timestamp;

  ServerStatus({
    required this.online,
    required this.version,
    required this.timestamp,
  });

  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    return ServerStatus(
      online: json['online'] ?? false,
      version: json['version'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }
}

class ServerCapabilities {
  final bool pushSupport;
  final bool oathSupport;
  final bool biometricSupport;
  final List<String> supportedAuthMethods;

  ServerCapabilities({
    required this.pushSupport,
    required this.oathSupport,
    required this.biometricSupport,
    required this.supportedAuthMethods,
  });

  factory ServerCapabilities.fromJson(Map<String, dynamic> json) {
    return ServerCapabilities(
      pushSupport: json['pushSupport'] ?? false,
      oathSupport: json['oathSupport'] ?? false,
      biometricSupport: json['biometricSupport'] ?? false,
      supportedAuthMethods: json['supportedAuthMethods']?.cast<String>() ?? [],
    );
  }
}
