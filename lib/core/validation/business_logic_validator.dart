import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../error/error_handler.dart';
import '../logging/logging_service.dart';
import '../../shared/models/models.dart';

/// Business logic validation service
class BusinessLogicValidator {
  static BusinessLogicValidator? _instance;
  static BusinessLogicValidator get instance {
    _instance ??= BusinessLogicValidator._internal();
    return _instance!;
  }

  BusinessLogicValidator._internal();

  final LoggingService _logger = LoggingService.instance;

  /// Validate OATH token provisioning data
  void validateOathProvisioning(Map<String, dynamic> provisionData) {
    _logger.debug('BusinessLogicValidator', 'Validating OATH provisioning data');

    // Required fields validation
    final requiredFields = ['secret', 'issuer', 'accountName'];
    for (final field in requiredFields) {
      if (!provisionData.containsKey(field) || 
          provisionData[field] == null || 
          provisionData[field].toString().isEmpty) {
        throw ValidationError(
          'Missing required field: $field',
          code: 'MISSING_REQUIRED_FIELD',
          fieldErrors: {field: ['This field is required']},
        );
      }
    }

    // Secret validation
    final secret = provisionData['secret'] as String;
    if (!_isValidBase32(secret)) {
      throw ValidationError(
        'Invalid secret format. Must be valid Base32.',
        code: 'INVALID_SECRET_FORMAT',
        fieldErrors: {'secret': ['Invalid Base32 format']},
      );
    }

    // Secret length validation (minimum 16 characters for security)
    if (secret.length < 16) {
      throw ValidationError(
        'Secret too short. Minimum 16 characters required.',
        code: 'SECRET_TOO_SHORT',
        fieldErrors: {'secret': ['Minimum 16 characters required']},
      );
    }

    // Algorithm validation
    final algorithm = provisionData['algorithm'] as String? ?? 'SHA1';
    if (!['SHA1', 'SHA256', 'SHA512'].contains(algorithm.toUpperCase())) {
      throw ValidationError(
        'Unsupported algorithm: $algorithm',
        code: 'UNSUPPORTED_ALGORITHM',
        fieldErrors: {'algorithm': ['Must be SHA1, SHA256, or SHA512']},
      );
    }

    // Digits validation
    final digits = provisionData['digits'] as int? ?? 6;
    if (![6, 8].contains(digits)) {
      throw ValidationError(
        'Invalid digits count: $digits',
        code: 'INVALID_DIGITS_COUNT',
        fieldErrors: {'digits': ['Must be 6 or 8']},
      );
    }

    // Period validation (for TOTP)
    final period = provisionData['period'] as int? ?? 30;
    if (period < 15 || period > 300) {
      throw ValidationError(
        'Invalid period: $period seconds',
        code: 'INVALID_PERIOD',
        fieldErrors: {'period': ['Must be between 15 and 300 seconds']},
      );
    }

    // Issuer validation
    final issuer = provisionData['issuer'] as String;
    if (issuer.length > 100) {
      throw ValidationError(
        'Issuer name too long',
        code: 'ISSUER_TOO_LONG',
        fieldErrors: {'issuer': ['Maximum 100 characters allowed']},
      );
    }

    // Account name validation
    final accountName = provisionData['accountName'] as String;
    if (accountName.length > 100) {
      throw ValidationError(
        'Account name too long',
        code: 'ACCOUNT_NAME_TOO_LONG',
        fieldErrors: {'accountName': ['Maximum 100 characters allowed']},
      );
    }

    _logger.info('BusinessLogicValidator', 'OATH provisioning data validated successfully');
  }

  /// Validate Security String provisioning data
  void validateSecurityStringProvisioning(Map<String, dynamic> provisionData) {
    _logger.debug('BusinessLogicValidator', 'Validating Security String provisioning data');

    // Required fields validation
    final requiredFields = ['gridData', 'serverUrl', 'username'];
    for (final field in requiredFields) {
      if (!provisionData.containsKey(field) || 
          provisionData[field] == null || 
          provisionData[field].toString().isEmpty) {
        throw ValidationError(
          'Missing required field: $field',
          code: 'MISSING_REQUIRED_FIELD',
          fieldErrors: {field: ['This field is required']},
        );
      }
    }

    // Grid data validation
    final gridData = provisionData['gridData'];
    if (gridData is! List || gridData.length != 99) {
      throw ValidationError(
        'Invalid grid data. Must contain exactly 99 elements.',
        code: 'INVALID_GRID_DATA',
        fieldErrors: {'gridData': ['Must contain exactly 99 elements']},
      );
    }

    // Validate each grid element
    for (int i = 0; i < gridData.length; i++) {
      final element = gridData[i];
      if (element is! String || element.isEmpty || element.length > 10) {
        throw ValidationError(
          'Invalid grid element at position $i',
          code: 'INVALID_GRID_ELEMENT',
          fieldErrors: {'gridData': ['Element at position $i is invalid']},
        );
      }
    }

    // Server URL validation
    final serverUrl = provisionData['serverUrl'] as String;
    if (!_isValidUrl(serverUrl)) {
      throw ValidationError(
        'Invalid server URL format',
        code: 'INVALID_SERVER_URL',
        fieldErrors: {'serverUrl': ['Must be a valid HTTPS URL']},
      );
    }

    // Username validation
    final username = provisionData['username'] as String;
    if (username.length < 3 || username.length > 50) {
      throw ValidationError(
        'Invalid username length',
        code: 'INVALID_USERNAME_LENGTH',
        fieldErrors: {'username': ['Must be between 3 and 50 characters']},
      );
    }

    _logger.info('BusinessLogicValidator', 'Security String provisioning data validated successfully');
  }

  /// Validate OATH token generation
  void validateOathTokenGeneration(OAuthEntity entity) {
    _logger.debug('BusinessLogicValidator', 'Validating OATH token generation');

    if (entity.secret.isEmpty) {
      throw BusinessLogicError(
        'Cannot generate token: Secret is empty',
        code: 'EMPTY_SECRET',
      );
    }

    if (entity.issuer.isEmpty) {
      throw BusinessLogicError(
        'Cannot generate token: Issuer is empty',
        code: 'EMPTY_ISSUER',
      );
    }

    if (entity.account.isEmpty) {
      throw BusinessLogicError(
        'Cannot generate token: Account name is empty',
        code: 'EMPTY_ACCOUNT_NAME',
      );
    }

    // Check if token is not expired (for time-based validation)
    final now = DateTime.now();
    final tokenTime = (now.millisecondsSinceEpoch / 1000).floor();
    final period = entity.period ?? 30;
    final timeStep = (tokenTime / period).floor();
    
    // Validate time step is reasonable (not too far in past/future)
    final currentTimeStep = (DateTime.now().millisecondsSinceEpoch / 1000 / period).floor();
    if ((timeStep - currentTimeStep).abs() > 10) {
      _logger.warning('BusinessLogicValidator', 
        'Token generation with unusual time step: $timeStep vs $currentTimeStep');
    }

    _logger.info('BusinessLogicValidator', 'OATH token generation validated successfully');
  }

  /// Validate Security String authentication request
  void validateSecurityStringAuth(Map<String, dynamic> authData) {
    _logger.debug('BusinessLogicValidator', 'Validating Security String authentication');

    // Required fields validation
    final requiredFields = ['challenge', 'gridPositions'];
    for (final field in requiredFields) {
      if (!authData.containsKey(field) || authData[field] == null) {
        throw ValidationError(
          'Missing required field: $field',
          code: 'MISSING_REQUIRED_FIELD',
          fieldErrors: {field: ['This field is required']},
        );
      }
    }

    // Challenge validation
    final challenge = authData['challenge'] as String;
    if (challenge.isEmpty || challenge.length > 1000) {
      throw ValidationError(
        'Invalid challenge format',
        code: 'INVALID_CHALLENGE',
        fieldErrors: {'challenge': ['Challenge must be between 1 and 1000 characters']},
      );
    }

    // Grid positions validation
    final gridPositions = authData['gridPositions'];
    if (gridPositions is! List || gridPositions.isEmpty || gridPositions.length > 10) {
      throw ValidationError(
        'Invalid grid positions',
        code: 'INVALID_GRID_POSITIONS',
        fieldErrors: {'gridPositions': ['Must contain between 1 and 10 positions']},
      );
    }

    // Validate each position
    for (final position in gridPositions) {
      if (position is! int || position < 0 || position >= 99) {
        throw ValidationError(
          'Invalid grid position: $position',
          code: 'INVALID_GRID_POSITION',
          fieldErrors: {'gridPositions': ['Position must be between 0 and 98']},
        );
      }
    }

    _logger.info('BusinessLogicValidator', 'Security String authentication validated successfully');
  }

  /// Validate backup data integrity
  void validateBackupData(Map<String, dynamic> backupData) {
    _logger.debug('BusinessLogicValidator', 'Validating backup data integrity');

    // Required fields validation
    final requiredFields = ['version', 'timestamp', 'data', 'checksum'];
    for (final field in requiredFields) {
      if (!backupData.containsKey(field)) {
        throw ValidationError(
          'Invalid backup format: Missing $field',
          code: 'INVALID_BACKUP_FORMAT',
          fieldErrors: {field: ['This field is required in backup data']},
        );
      }
    }

    // Version validation
    final version = backupData['version'];
    if (version is! String || version.isEmpty) {
      throw ValidationError(
        'Invalid backup version',
        code: 'INVALID_BACKUP_VERSION',
        fieldErrors: {'version': ['Version must be a non-empty string']},
      );
    }

    // Timestamp validation
    final timestamp = backupData['timestamp'];
    if (timestamp is! int || timestamp <= 0) {
      throw ValidationError(
        'Invalid backup timestamp',
        code: 'INVALID_BACKUP_TIMESTAMP',
        fieldErrors: {'timestamp': ['Timestamp must be a positive integer']},
      );
    }

    // Data validation
    final data = backupData['data'];
    if (data is! Map) {
      throw ValidationError(
        'Invalid backup data format',
        code: 'INVALID_BACKUP_DATA',
        fieldErrors: {'data': ['Data must be a valid object']},
      );
    }

    // Checksum validation
    final providedChecksum = backupData['checksum'] as String;
    final calculatedChecksum = _calculateBackupChecksum(backupData);
    
    if (providedChecksum != calculatedChecksum) {
      throw SecurityError(
        'Backup data integrity check failed',
        code: 'BACKUP_INTEGRITY_FAILED',
        metadata: {
          'providedChecksum': providedChecksum,
          'calculatedChecksum': calculatedChecksum,
        },
      );
    }

    _logger.info('BusinessLogicValidator', 'Backup data integrity validated successfully');
  }

  /// Validate push authentication request
  void validatePushAuthRequest(Map<String, dynamic> pushData) {
    _logger.debug('BusinessLogicValidator', 'Validating push authentication request');

    // Required fields validation
    final requiredFields = ['requestId', 'message', 'timestamp'];
    for (final field in requiredFields) {
      if (!pushData.containsKey(field) || 
          pushData[field] == null || 
          pushData[field].toString().isEmpty) {
        throw ValidationError(
          'Missing required field: $field',
          code: 'MISSING_REQUIRED_FIELD',
          fieldErrors: {field: ['This field is required']},
        );
      }
    }

    // Request ID validation
    final requestId = pushData['requestId'] as String;
    if (requestId.length < 10 || requestId.length > 100) {
      throw ValidationError(
        'Invalid request ID format',
        code: 'INVALID_REQUEST_ID',
        fieldErrors: {'requestId': ['Must be between 10 and 100 characters']},
      );
    }

    // Timestamp validation (not too old, not in future)
    final timestamp = pushData['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final age = now - timestamp;
    
    if (age < 0) {
      throw ValidationError(
        'Push request timestamp is in the future',
        code: 'FUTURE_TIMESTAMP',
        fieldErrors: {'timestamp': ['Timestamp cannot be in the future']},
      );
    }
    
    if (age > 300000) { // 5 minutes
      throw ValidationError(
        'Push request has expired',
        code: 'EXPIRED_REQUEST',
        fieldErrors: {'timestamp': ['Request is too old']},
      );
    }

    _logger.info('BusinessLogicValidator', 'Push authentication request validated successfully');
  }

  /// Check if string is valid Base32
  bool _isValidBase32(String input) {
    final base32Regex = RegExp(r'^[A-Z2-7]+=*$');
    return base32Regex.hasMatch(input.toUpperCase());
  }

  /// Check if string is valid URL
  bool _isValidUrl(String input) {
    try {
      final uri = Uri.parse(input);
      return uri.hasScheme && 
             (uri.scheme == 'https' || uri.scheme == 'http') && 
             uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Calculate backup checksum
  String _calculateBackupChecksum(Map<String, dynamic> backupData) {
    // Create a copy without the checksum field
    final dataForChecksum = Map<String, dynamic>.from(backupData);
    dataForChecksum.remove('checksum');
    
    // Convert to JSON and calculate SHA-256 hash
    final jsonString = jsonEncode(dataForChecksum);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }
}
