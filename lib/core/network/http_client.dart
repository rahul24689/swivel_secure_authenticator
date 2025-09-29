
import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../utils/cache_config.dart';
import '../security/certificate_pinning_service.dart';

class HttpClient {
  static Dio? _dio;
  static final Connectivity _connectivity = Connectivity();

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio();

    // Configure base options
    dio.options = BaseOptions(
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'SAMS-Flutter/${AppConstants.appVersion}',
      },
    );

    // Add interceptors
    dio.interceptors.add(_createLogInterceptor());
    dio.interceptors.add(_createAuthInterceptor());
    dio.interceptors.add(_createErrorInterceptor());
    dio.interceptors.add(_createRetryInterceptor());

    // Configure certificate pinning
    _configureCertificatePinning(dio);

    return dio;
  }

  static LogInterceptor _createLogInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (object) {
        // In production, you might want to use a proper logging framework
        print('[HTTP] $object');
      },
    );
  }

  static InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authentication headers if available
        final token = CacheConfig.getFirebaseToken();
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Add device-specific headers
        options.headers['X-Device-Platform'] = io.Platform.operatingSystem;
        options.headers['X-App-Version'] = AppConstants.appVersion;
        
        handler.next(options);
      },
    );
  }

  static InterceptorsWrapper _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final httpError = _handleDioError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: httpError,
          type: error.type,
          response: error.response,
        ));
      },
    );
  }

  static InterceptorsWrapper _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          try {
            final response = await _dio!.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // If retry fails, continue with original error
          }
        }
        handler.next(error);
      },
    );
  }

  static void _configureCertificatePinning(Dio dio) {
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = io.HttpClient();

        // Configure certificate pinning
        client.badCertificateCallback = (cert, host, port) {
          // Use certificate pinning service for validation
          final pinningService = CertificatePinningService.instance;

          // Validate certificate pinning
          final isPinValid = pinningService.validateCertificate(cert, host);

          // Validate hostname
          final isHostnameValid = pinningService.validateHostname(cert, host);

          // Check certificate expiry
          final isNotExpired = !pinningService.isCertificateExpired(cert);

          final isValid = isPinValid && isHostnameValid && isNotExpired;

          if (!isValid && kDebugMode) {
            debugPrint('Certificate validation failed for $host:$port');
            debugPrint('Pin valid: $isPinValid, Hostname valid: $isHostnameValid, Not expired: $isNotExpired');
          }

          return isValid;
        };

        return client;
      };
    }
  }

  static HttpError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return HttpError(
          message: 'Connection timeout',
          code: 'CONNECTION_TIMEOUT',
          statusCode: null,
        );
      case DioExceptionType.sendTimeout:
        return HttpError(
          message: 'Send timeout',
          code: 'SEND_TIMEOUT',
          statusCode: null,
        );
      case DioExceptionType.receiveTimeout:
        return HttpError(
          message: 'Receive timeout',
          code: 'RECEIVE_TIMEOUT',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        return HttpError(
          message: error.response?.data?['message'] ?? 'Bad response',
          code: 'BAD_RESPONSE',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return HttpError(
          message: 'Request cancelled',
          code: 'CANCELLED',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return HttpError(
          message: 'Connection error',
          code: 'CONNECTION_ERROR',
          statusCode: null,
        );
      case DioExceptionType.badCertificate:
        return HttpError(
          message: 'Bad certificate',
          code: 'BAD_CERTIFICATE',
          statusCode: null,
        );
      case DioExceptionType.unknown:
        return HttpError(
          message: error.message ?? 'Unknown error',
          code: 'UNKNOWN',
          statusCode: null,
        );
    }
  }

  static bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError;
  }

  // HTTP Methods
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    
    return await instance.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    
    return await instance.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    
    return await instance.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    
    return await instance.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Utility methods
  static Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw HttpError(
        message: 'No internet connection',
        code: 'NO_INTERNET',
        statusCode: null,
      );
    }
  }

  static void updateBaseUrl(String baseUrl) {
    instance.options.baseUrl = baseUrl;
  }

  static void addHeader(String key, String value) {
    instance.options.headers[key] = value;
  }

  static void removeHeader(String key) {
    instance.options.headers.remove(key);
  }

  static void clearHeaders() {
    instance.options.headers.clear();
  }

  static void setTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) {
      instance.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      instance.options.receiveTimeout = receiveTimeout;
    }
    if (sendTimeout != null) {
      instance.options.sendTimeout = sendTimeout;
    }
  }
}

/// HTTP Error class
class HttpError implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  HttpError({
    required this.message,
    required this.code,
    this.statusCode,
  });

  @override
  String toString() {
    return 'HttpError(message: $message, code: $code, statusCode: $statusCode)';
  }
}
