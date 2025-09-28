import '../models/models.dart';
import '../../core/database/dao/security_string_dao.dart';
import '../../core/database/dao/sas_dao.dart';


class SecurityStringService {
  final SecurityStringDao _securityStringDao = SecurityStringDao();
  final SasDao _sasDao = SasDao();

  /// Get security string by token index for a specific SAS
  Future<SecurityStringEntity?> getSecurityStringByIndex(int sasId, int tokenIndex) async {
    return await _securityStringDao.getByTokenIndex(sasId, tokenIndex);
  }

  /// Get next unused security string for a SAS
  Future<SecurityStringEntity?> getNextUnusedSecurityString(int sasId) async {
    return await _securityStringDao.getNextUnusedBySasId(sasId);
  }

  /// Get all security strings for a SAS
  Future<List<SecurityStringEntity>> getAllSecurityStrings(int sasId) async {
    return await _securityStringDao.getBySasId(sasId);
  }

  /// Get unused security strings for a SAS
  Future<List<SecurityStringEntity>> getUnusedSecurityStrings(int sasId) async {
    return await _securityStringDao.getUnusedBySasId(sasId);
  }

  /// Get used security strings for a SAS
  Future<List<SecurityStringEntity>> getUsedSecurityStrings(int sasId) async {
    return await _securityStringDao.getUsedBySasId(sasId);
  }

  /// Get count of unused security strings
  Future<int> getUnusedCount(int sasId) async {
    return await _securityStringDao.getUnusedCountBySasId(sasId);
  }

  /// Mark a security string as used
  Future<bool> markSecurityStringAsUsed(int securityStringId) async {
    final result = await _securityStringDao.markAsUsed(securityStringId);
    return result > 0;
  }

  /// Mark a security string as unused (for testing or reset purposes)
  Future<bool> markSecurityStringAsUnused(int securityStringId) async {
    final result = await _securityStringDao.markAsUnused(securityStringId);
    return result > 0;
  }

  /// Use security string by token index
  Future<SecurityStringEntity?> useSecurityStringByIndex(int sasId, int tokenIndex) async {
    final securityString = await _securityStringDao.getByTokenIndex(sasId, tokenIndex);
    if (securityString != null && !securityString.usedCode) {
      await _securityStringDao.markAsUsed(securityString.id!);
      return securityString.copyWith(usedCode: true);
    }
    return null;
  }

  /// Use next available security string
  Future<SecurityStringEntity?> useNextSecurityString(int sasId) async {
    final securityString = await _securityStringDao.getNextUnusedBySasId(sasId);
    if (securityString != null) {
      await _securityStringDao.markAsUsed(securityString.id!);
      return securityString.copyWith(usedCode: true);
    }
    return null;
  }

  /// Get security string for authentication (without marking as used)
  Future<SecurityStringEntity?> getSecurityStringForAuth(int sasId, int tokenIndex) async {
    return await _securityStringDao.getByTokenIndex(sasId, tokenIndex);
  }

  /// Validate security string code
  Future<bool> validateSecurityString(int sasId, int tokenIndex, String inputCode) async {
    final securityString = await _securityStringDao.getByTokenIndex(sasId, tokenIndex);
    if (securityString != null && !securityString.usedCode) {
      return securityString.securityCode == inputCode;
    }
    return false;
  }

  /// Authenticate with security string and mark as used if valid
  Future<AuthenticationResult> authenticateWithSecurityString(
    int sasId, 
    int tokenIndex, 
    String inputCode
  ) async {
    final securityString = await _securityStringDao.getByTokenIndex(sasId, tokenIndex);
    
    if (securityString == null) {
      return AuthenticationResult(
        success: false,
        message: 'Security string not found for token index $tokenIndex',
        errorCode: 'NOT_FOUND',
      );
    }

    if (securityString.usedCode) {
      return AuthenticationResult(
        success: false,
        message: 'Security string has already been used',
        errorCode: 'ALREADY_USED',
      );
    }

    if (securityString.securityCode != inputCode) {
      return AuthenticationResult(
        success: false,
        message: 'Invalid security string code',
        errorCode: 'INVALID_CODE',
      );
    }

    // Mark as used
    await _securityStringDao.markAsUsed(securityString.id!);

    return AuthenticationResult(
      success: true,
      message: 'Authentication successful',
      securityString: securityString.copyWith(usedCode: true),
    );
  }

  /// Get security string statistics for a SAS
  Future<SecurityStringStats> getSecurityStringStats(int sasId) async {
    final totalCount = await _securityStringDao.countBySasId(sasId);
    final unusedCount = await _securityStringDao.getUnusedCountBySasId(sasId);
    final usedCount = totalCount - unusedCount;

    return SecurityStringStats(
      total: totalCount,
      used: usedCount,
      unused: unusedCount,
      usagePercentage: totalCount > 0 ? (usedCount / totalCount) * 100 : 0,
    );
  }

  /// Check if security strings are available for authentication
  Future<bool> hasAvailableSecurityStrings(int sasId) async {
    final unusedCount = await _securityStringDao.getUnusedCountBySasId(sasId);
    return unusedCount > 0;
  }

  /// Get current token index (next unused)
  Future<int?> getCurrentTokenIndex(int sasId) async {
    final nextUnused = await _securityStringDao.getNextUnusedBySasId(sasId);
    return nextUnused?.tokenIndex;
  }

  /// Reset all security strings to unused (for testing purposes)
  Future<void> resetAllSecurityStrings(int sasId) async {
    final allStrings = await _securityStringDao.getBySasId(sasId);
    for (final securityString in allStrings) {
      if (securityString.id != null) {
        await _securityStringDao.markAsUnused(securityString.id!);
      }
    }
  }

  /// Delete all security strings for a SAS
  Future<void> deleteSecurityStrings(int sasId) async {
    await _securityStringDao.deleteBySasId(sasId);
  }

  /// Import security strings from server response
  Future<int> importSecurityStrings(int sasId, List<String> securityCodes) async {
    final entities = <SecurityStringEntity>[];
    
    for (int i = 0; i < securityCodes.length; i++) {
      entities.add(SecurityStringEntity(
        securityCode: securityCodes[i],
        tokenIndex: i,
        usedCode: false,
        dateIncluded: DateTime.now().millisecondsSinceEpoch,
      ));
    }

    return await _securityStringDao.insertBatch(entities, sasId);
  }

  /// Get security string range
  Future<List<SecurityStringEntity>> getSecurityStringRange(
    int sasId, 
    int startIndex, 
    int endIndex
  ) async {
    final allStrings = await _securityStringDao.getBySasId(sasId);
    return allStrings.where((s) => 
      s.tokenIndex >= startIndex && s.tokenIndex <= endIndex
    ).toList();
  }

  /// Check if token index is valid
  Future<bool> isValidTokenIndex(int sasId, int tokenIndex) async {
    final securityString = await _securityStringDao.getByTokenIndex(sasId, tokenIndex);
    return securityString != null;
  }

  /// Get next available token index
  Future<int?> getNextAvailableTokenIndex(int sasId) async {
    final nextUnused = await _securityStringDao.getNextUnusedBySasId(sasId);
    return nextUnused?.tokenIndex;
  }
}

/// Result class for authentication operations
class AuthenticationResult {
  final bool success;
  final String message;
  final String? errorCode;
  final SecurityStringEntity? securityString;

  AuthenticationResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.securityString,
  });

  @override
  String toString() {
    return 'AuthenticationResult(success: $success, message: $message, errorCode: $errorCode)';
  }
}

/// Statistics class for security strings
class SecurityStringStats {
  final int total;
  final int used;
  final int unused;
  final double usagePercentage;

  SecurityStringStats({
    required this.total,
    required this.used,
    required this.unused,
    required this.usagePercentage,
  });

  bool get hasAvailable => unused > 0;
  bool get isExhausted => unused == 0 && total > 0;
  bool get isEmpty => total == 0;

  @override
  String toString() {
    return 'SecurityStringStats(total: $total, used: $used, unused: $unused, '
           'usagePercentage: ${usagePercentage.toStringAsFixed(1)}%)';
  }
}
