import 'dart:typed_data';
import 'package:otp/otp.dart';
import '../models/models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/database/dao/oauth_dao.dart';

class OathService {
  static const int _defaultInterval = AppConstants.totpInterval;
  static const int _defaultDigits = AppConstants.totpDigits;

  static final OAuthDao _oauthDao = OAuthDao();

  /// Generate TOTP code from secret
  static String generateTOTP({
    required String secret,
    int? interval,
    int? digits,
    DateTime? time,
  }) {
    try {
      final currentTime = time ?? DateTime.now();
      final timeStep = (currentTime.millisecondsSinceEpoch ~/ 1000) ~/ (interval ?? _defaultInterval);
      
      return OTP.generateTOTPCodeString(
        secret,
        timeStep,
        length: digits ?? _defaultDigits,
        interval: interval ?? _defaultInterval,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
    } catch (e) {
      throw Exception('Failed to generate TOTP: $e');
    }
  }

  /// Generate TOTP code for OAuth entity
  static String generateTOTPForOAuth(OAuthEntity oauthEntity, {DateTime? time}) {
    return generateTOTP(
      secret: oauthEntity.secret,
      time: time,
    );
  }

  /// Validate TOTP code
  static bool validateTOTP({
    required String secret,
    required String code,
    int? interval,
    int? digits,
    DateTime? time,
    int windowSize = 1,
  }) {
    try {
      final currentTime = time ?? DateTime.now();
      final currentTimeStep = (currentTime.millisecondsSinceEpoch ~/ 1000) ~/ (interval ?? _defaultInterval);
      
      // Check current time step and adjacent windows
      for (int i = -windowSize; i <= windowSize; i++) {
        final timeStep = currentTimeStep + i;
        final expectedCode = OTP.generateTOTPCodeString(
          secret,
          timeStep,
          length: digits ?? _defaultDigits,
          interval: interval ?? _defaultInterval,
          algorithm: Algorithm.SHA1,
          isGoogle: true,
        );
        
        if (expectedCode == code) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get remaining time for current TOTP code
  static int getRemainingTime({int? interval}) {
    final currentTime = DateTime.now();
    final timeStep = (currentTime.millisecondsSinceEpoch ~/ 1000) ~/ (interval ?? _defaultInterval);
    final nextTimeStep = (timeStep + 1) * (interval ?? _defaultInterval);
    final nextTime = DateTime.fromMillisecondsSinceEpoch(nextTimeStep * 1000);
    
    return nextTime.difference(currentTime).inSeconds;
  }

  /// Get progress percentage for current TOTP code (0.0 to 1.0)
  static double getProgress({int? interval}) {
    final remainingTime = getRemainingTime(interval: interval);
    final totalTime = interval ?? _defaultInterval;
    return (totalTime - remainingTime) / totalTime;
  }

  /// Parse TOTP URI (otpauth://totp/...)
  static Map<String, String>? parseOTPAuthUri(String uri) {
    try {
      final parsedUri = Uri.parse(uri);
      
      if (parsedUri.scheme != 'otpauth' || parsedUri.host != 'totp') {
        return null;
      }
      
      final pathSegments = parsedUri.pathSegments;
      if (pathSegments.isEmpty) {
        return null;
      }
      
      final label = pathSegments.first;
      final queryParams = parsedUri.queryParameters;
      
      String? issuer;
      String? account;
      
      if (label.contains(':')) {
        final parts = label.split(':');
        issuer = parts[0];
        account = parts[1];
      } else {
        account = label;
        issuer = queryParams['issuer'];
      }
      
      return {
        'issuer': issuer ?? '',
        'account': account,
        'secret': queryParams['secret'] ?? '',
        'algorithm': queryParams['algorithm'] ?? 'SHA1',
        'digits': queryParams['digits'] ?? '6',
        'period': queryParams['period'] ?? '30',
      };
    } catch (e) {
      return null;
    }
  }

  /// Generate TOTP URI
  static String generateOTPAuthUri({
    required String issuer,
    required String account,
    required String secret,
    String algorithm = 'SHA1',
    int digits = 6,
    int period = 30,
  }) {
    final label = '$issuer:$account';
    final uri = Uri(
      scheme: 'otpauth',
      host: 'totp',
      path: '/$label',
      queryParameters: {
        'secret': secret,
        'issuer': issuer,
        'algorithm': algorithm,
        'digits': digits.toString(),
        'period': period.toString(),
      },
    );
    
    return uri.toString();
  }

  /// Generate random secret for TOTP
  static String generateSecret({int length = 32}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    
    for (int i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  /// Convert base32 secret to bytes
  static Uint8List base32Decode(String base32) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleanInput = base32.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    
    if (cleanInput.isEmpty) {
      return Uint8List(0);
    }
    
    final bits = <bool>[];
    for (final char in cleanInput.split('')) {
      final index = alphabet.indexOf(char);
      if (index == -1) continue;
      
      for (int i = 4; i >= 0; i--) {
        bits.add((index >> i) & 1 == 1);
      }
    }
    
    final bytes = <int>[];
    for (int i = 0; i < bits.length; i += 8) {
      if (i + 7 < bits.length) {
        int byte = 0;
        for (int j = 0; j < 8; j++) {
          if (bits[i + j]) {
            byte |= 1 << (7 - j);
          }
        }
        bytes.add(byte);
      }
    }
    
    return Uint8List.fromList(bytes);
  }

  /// Convert bytes to base32
  static String base32Encode(Uint8List bytes) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final bits = <bool>[];
    
    for (final byte in bytes) {
      for (int i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1 == 1);
      }
    }
    
    final result = StringBuffer();
    for (int i = 0; i < bits.length; i += 5) {
      int value = 0;
      for (int j = 0; j < 5 && i + j < bits.length; j++) {
        if (bits[i + j]) {
          value |= 1 << (4 - j);
        }
      }
      result.write(alphabet[value]);
    }
    
    return result.toString();
  }

  /// Verify secret format
  static bool isValidSecret(String secret) {
    try {
      final cleanSecret = secret.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
      return cleanSecret.isNotEmpty && cleanSecret.length >= 16;
    } catch (e) {
      return false;
    }
  }

  /// Get current time step
  static int getCurrentTimeStep({int? interval}) {
    final currentTime = DateTime.now();
    return (currentTime.millisecondsSinceEpoch ~/ 1000) ~/ (interval ?? _defaultInterval);
  }

  /// Get time step for specific time
  static int getTimeStepForTime(DateTime time, {int? interval}) {
    return (time.millisecondsSinceEpoch ~/ 1000) ~/ (interval ?? _defaultInterval);
  }

  /// Parse OATH URI from QR code
  static Future<OAuthEntity> parseOATHUri(String uri) async {
    try {
      final parsedUri = Uri.parse(uri);

      if (parsedUri.scheme != 'otpauth') {
        throw Exception('Invalid OATH URI scheme');
      }

      if (parsedUri.host != 'totp' && parsedUri.host != 'hotp') {
        throw Exception('Unsupported OATH type: ${parsedUri.host}');
      }

      final pathSegments = parsedUri.pathSegments;
      if (pathSegments.isEmpty) {
        throw Exception('Missing account information in OATH URI');
      }

      // Extract account name (may include issuer)
      final accountInfo = pathSegments.first;
      String issuer = '';
      String accountName = accountInfo;

      // Check if account info contains issuer
      if (accountInfo.contains(':')) {
        final parts = accountInfo.split(':');
        issuer = parts[0];
        accountName = parts.sublist(1).join(':');
      }

      // Extract parameters
      final queryParams = parsedUri.queryParameters;
      final secret = queryParams['secret'];
      if (secret == null || secret.isEmpty) {
        throw Exception('Missing secret in OATH URI');
      }

      // Override issuer if provided as parameter
      if (queryParams['issuer'] != null) {
        issuer = queryParams['issuer']!;
      }

      final digits = int.tryParse(queryParams['digits'] ?? '6') ?? 6;
      final period = int.tryParse(queryParams['period'] ?? '30') ?? 30;
      final algorithm = queryParams['algorithm']?.toUpperCase() ?? 'SHA1';

      // Validate algorithm
      if (!['SHA1', 'SHA256', 'SHA512'].contains(algorithm)) {
        throw Exception('Unsupported algorithm: $algorithm');
      }

      // Create OAuth entity
      return OAuthEntity(
        issuer: issuer.isNotEmpty ? issuer : 'Unknown',
        account: accountName,
        secret: secret,
        username: accountName, // Use account name as username for OATH tokens
        provisionCode: '', // Not applicable for OATH tokens
        digits: digits,
        period: period,
        algorithm: algorithm,
        label: accountInfo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to parse OATH URI: $e');
    }
  }

  /// Add OATH token from parsed entity
  static Future<int> addOATHToken(OAuthEntity oauthEntity) async {
    try {
      // Check if token already exists
      final existing = await _oauthDao.getByIssuerAndAccount(
        oauthEntity.issuer,
        oauthEntity.account,
      );

      if (existing != null) {
        throw Exception('OATH token already exists for this account');
      }

      // Insert new token
      return await _oauthDao.insert(oauthEntity);
    } catch (e) {
      throw Exception('Failed to add OATH token: $e');
    }
  }

  /// Generate QR code for OATH token
  static String generateOATHUri(OAuthEntity oauth) {
    final issuerPrefix = oauth.issuer.isNotEmpty ? '${oauth.issuer}:' : '';
    final label = '$issuerPrefix${oauth.account}';

    final uri = Uri(
      scheme: 'otpauth',
      host: 'totp', // Default to TOTP
      path: '/$label',
      queryParameters: {
        'secret': oauth.secret,
        'issuer': oauth.issuer,
        'digits': oauth.digits.toString(),
        'period': oauth.period.toString(),
        'algorithm': oauth.algorithm,
      },
    );

    return uri.toString();
  }
}
