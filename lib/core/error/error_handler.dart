import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../logging/logging_service.dart';

/// Base application error class
abstract class AppError implements Exception {
  final String message;
  final String code;
  final Map<String, dynamic>? metadata;

  const AppError(this.message, this.code, {this.metadata});

  @override
  String toString() => 'AppError($code): $message';
}

/// Authentication related errors
class AuthenticationError extends AppError {
  const AuthenticationError(String message, {String? code, Map<String, dynamic>? metadata})
      : super(message, code ?? 'AUTH_ERROR', metadata: metadata);
}

/// Network related errors
class NetworkError extends AppError {
  final int? statusCode;
  
  const NetworkError(String message, {String? code, this.statusCode, Map<String, dynamic>? metadata})
      : super(message, code ?? 'NETWORK_ERROR', metadata: metadata);
}

/// Database related errors
class DatabaseError extends AppError {
  const DatabaseError(String message, {String? code, Map<String, dynamic>? metadata})
      : super(message, code ?? 'DATABASE_ERROR', metadata: metadata);
}

/// Validation related errors
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationError(String message, {String? code, this.fieldErrors, Map<String, dynamic>? metadata})
      : super(message, code ?? 'VALIDATION_ERROR', metadata: metadata);
}

/// Security related errors
class SecurityError extends AppError {
  const SecurityError(String message, {String? code, Map<String, dynamic>? metadata})
      : super(message, code ?? 'SECURITY_ERROR', metadata: metadata);
}

/// Business logic errors
class BusinessLogicError extends AppError {
  const BusinessLogicError(String message, {String? code, Map<String, dynamic>? metadata})
      : super(message, code ?? 'BUSINESS_ERROR', metadata: metadata);
}

/// System/Platform errors
class SystemError extends AppError {
  const SystemError(String message, {String? code, Map<String, dynamic>? metadata})
      : super(message, code ?? 'SYSTEM_ERROR', metadata: metadata);
}

/// Error handler service
class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance {
    _instance ??= ErrorHandler._internal();
    return _instance!;
  }

  ErrorHandler._internal();

  final LoggingService _logger = LoggingService.instance;

  /// Handle any error and convert to appropriate AppError
  AppError handleError(dynamic error, {StackTrace? stackTrace, String? context}) {
    final appError = _convertToAppError(error);
    
    // Log the error
    _logError(appError, error, stackTrace, context);
    
    return appError;
  }

  /// Convert any error to AppError
  AppError _convertToAppError(dynamic error) {
    if (error is AppError) {
      return error;
    }
    
    if (error is DioException) {
      return _handleDioError(error);
    }
    
    if (error is FormatException) {
      return ValidationError(
        'Invalid data format: ${error.message}',
        code: 'FORMAT_ERROR',
      );
    }
    
    if (error is ArgumentError) {
      return ValidationError(
        'Invalid argument: ${error.message}',
        code: 'ARGUMENT_ERROR',
      );
    }
    
    if (error is StateError) {
      return SystemError(
        'Invalid state: ${error.message}',
        code: 'STATE_ERROR',
      );
    }
    
    if (error is TypeError) {
      return SystemError(
        'Type error: ${error.toString()}',
        code: 'TYPE_ERROR',
      );
    }
    
    // Generic error
    return SystemError(
      error?.toString() ?? 'Unknown error occurred',
      code: 'UNKNOWN_ERROR',
    );
  }

  /// Handle Dio network errors
  AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkError(
          'Connection timeout. Please check your internet connection.',
          code: 'CONNECTION_TIMEOUT',
        );
        
      case DioExceptionType.sendTimeout:
        return const NetworkError(
          'Request timeout. Please try again.',
          code: 'SEND_TIMEOUT',
        );
        
      case DioExceptionType.receiveTimeout:
        return const NetworkError(
          'Response timeout. Please try again.',
          code: 'RECEIVE_TIMEOUT',
        );
        
      case DioExceptionType.badResponse:
        return _handleHttpError(error);
        
      case DioExceptionType.cancel:
        return const NetworkError(
          'Request was cancelled.',
          code: 'REQUEST_CANCELLED',
        );
        
      case DioExceptionType.connectionError:
        return const NetworkError(
          'Connection error. Please check your internet connection.',
          code: 'CONNECTION_ERROR',
        );
        
      case DioExceptionType.badCertificate:
        return const SecurityError(
          'Invalid SSL certificate. Connection is not secure.',
          code: 'BAD_CERTIFICATE',
        );
        
      case DioExceptionType.unknown:
      default:
        return NetworkError(
          'Network error: ${error.message ?? 'Unknown network error'}',
          code: 'NETWORK_UNKNOWN',
        );
    }
  }

  /// Handle HTTP response errors
  AppError _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    
    switch (statusCode) {
      case 400:
        return NetworkError(
          _extractErrorMessage(responseData) ?? 'Bad request',
          code: 'BAD_REQUEST',
          statusCode: statusCode,
        );
        
      case 401:
        return AuthenticationError(
          _extractErrorMessage(responseData) ?? 'Authentication failed',
          code: 'UNAUTHORIZED',
          metadata: {'statusCode': statusCode},
        );
        
      case 403:
        return AuthenticationError(
          _extractErrorMessage(responseData) ?? 'Access forbidden',
          code: 'FORBIDDEN',
          metadata: {'statusCode': statusCode},
        );
        
      case 404:
        return NetworkError(
          _extractErrorMessage(responseData) ?? 'Resource not found',
          code: 'NOT_FOUND',
          statusCode: statusCode,
        );
        
      case 422:
        return ValidationError(
          _extractErrorMessage(responseData) ?? 'Validation failed',
          code: 'VALIDATION_FAILED',
          metadata: {'statusCode': statusCode},
        );
        
      case 429:
        return NetworkError(
          _extractErrorMessage(responseData) ?? 'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
          statusCode: statusCode,
        );
        
      case 500:
        return NetworkError(
          'Server error. Please try again later.',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
        );
        
      case 502:
      case 503:
      case 504:
        return NetworkError(
          'Service temporarily unavailable. Please try again later.',
          code: 'SERVICE_UNAVAILABLE',
          statusCode: statusCode,
        );
        
      default:
        return NetworkError(
          _extractErrorMessage(responseData) ?? 'HTTP error occurred',
          code: 'HTTP_ERROR',
          statusCode: statusCode,
        );
    }
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;
    
    if (responseData is Map<String, dynamic>) {
      // Try common error message fields
      return responseData['message'] ?? 
             responseData['error'] ?? 
             responseData['detail'] ?? 
             responseData['errorDescription'];
    }
    
    if (responseData is String) {
      return responseData;
    }
    
    return null;
  }

  /// Log error with appropriate level
  void _logError(AppError appError, dynamic originalError, StackTrace? stackTrace, String? context) {
    final logContext = context ?? 'ErrorHandler';
    final metadata = {
      'errorCode': appError.code,
      'originalError': originalError.toString(),
      if (appError.metadata != null) ...appError.metadata!,
    };

    switch (appError.runtimeType) {
      case AuthenticationError:
      case SecurityError:
        _logger.warning(logContext, appError.message, data: metadata);
        break;
        
      case NetworkError:
        final networkError = appError as NetworkError;
        if (networkError.statusCode != null && networkError.statusCode! >= 500) {
          _logger.error(logContext, appError.message, 
                       error: originalError, stackTrace: stackTrace, data: metadata);
        } else {
          _logger.warning(logContext, appError.message, data: metadata);
        }
        break;
        
      case DatabaseError:
      case SystemError:
        _logger.error(logContext, appError.message, 
                     error: originalError, stackTrace: stackTrace, data: metadata);
        break;
        
      case ValidationError:
      case BusinessLogicError:
        _logger.info(logContext, appError.message, data: metadata);
        break;
        
      default:
        _logger.error(logContext, appError.message, 
                     error: originalError, stackTrace: stackTrace, data: metadata);
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(AppError error) {
    switch (error.runtimeType) {
      case NetworkError:
        final networkError = error as NetworkError;
        if (networkError.statusCode == null) {
          return 'Please check your internet connection and try again.';
        }
        return error.message;
        
      case AuthenticationError:
        return 'Authentication failed. Please check your credentials and try again.';
        
      case ValidationError:
        return error.message;
        
      case SecurityError:
        return 'A security error occurred. Please contact support if this persists.';
        
      case DatabaseError:
        return 'A data error occurred. Please try again or contact support.';
        
      case SystemError:
        return 'A system error occurred. Please try again or contact support.';
        
      case BusinessLogicError:
        return error.message;
        
      default:
        return 'An unexpected error occurred. Please try again or contact support.';
    }
  }

  /// Check if error should be retried
  bool shouldRetry(AppError error) {
    if (error is NetworkError) {
      switch (error.code) {
        case 'CONNECTION_TIMEOUT':
        case 'SEND_TIMEOUT':
        case 'RECEIVE_TIMEOUT':
        case 'CONNECTION_ERROR':
        case 'SERVICE_UNAVAILABLE':
          return true;
        default:
          return error.statusCode != null && error.statusCode! >= 500;
      }
    }
    
    return false;
  }

  /// Get retry delay for error
  Duration getRetryDelay(AppError error, int attemptNumber) {
    // Exponential backoff with jitter
    final baseDelay = Duration(seconds: 2 * attemptNumber);
    final jitter = Duration(milliseconds: (baseDelay.inMilliseconds * 0.1).round());
    
    return baseDelay + jitter;
  }
}
