import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:crypto/crypto.dart';
import '../../core/database/dao/oauth_dao.dart';
import '../../core/database/dao/sas_dao.dart';
import '../../core/database/dao/ss_detail_dao.dart';
import '../models/models.dart';
import '../../core/utils/cache_config.dart';
import '../../core/constants/enums.dart';

class BackupService {
  static const String _backupVersion = '1.0';
  static const String _backupFileExtension = '.sams_backup';

  /// Create encrypted backup of all authentication data
  static Future<BackupResult> createBackup({
    String? password,
    bool includeOAuth = true,
    bool includeSecurityStrings = true,
    bool includeSettings = true,
  }) async {
    try {
      final backupData = <String, dynamic>{
        'version': _backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'encrypted': password != null,
      };

      // Backup OAuth tokens
      if (includeOAuth) {
        final oauthDao = OAuthDao();
        final oauthTokens = await oauthDao.getAll();
        backupData['oauth_tokens'] = oauthTokens.map((token) => {
          'id': token.id,
          'description': token.description,
          'issuer': token.issuer,
          'account': token.account,
          'secret': token.secret,
          'username': token.username,
          'provisionCode': token.provisionCode,
          'pin': token.pin,
          'dateIncluded': token.dateIncluded,
          'algorithm': token.algorithm,
          'digits': token.digits,
          'period': token.period,
          'label': token.label,
          'createdAt': token.createdAt.toIso8601String(),
          'updatedAt': token.updatedAt.toIso8601String(),
        }).toList();
      }

      // Backup Security Strings
      if (includeSecurityStrings) {
        final sasDao = SasDao();
        final ssDetailDao = SsDetailDao();
        
        final sasAccounts = await sasDao.getAll();
        final securityStrings = <Map<String, dynamic>>[];
        
        for (final sas in sasAccounts) {
          final ssDetails = await ssDetailDao.getBySasId(sas.id!);
          securityStrings.add({
            'sas': {
              'id': sas.id,
              'accountName': sas.accountName,
              'serverUrl': sas.serverUrl,
              'username': sas.username,
              'provisionCode': sas.provisionCode,
              'isActive': sas.isActive,
              'createdAt': sas.createdAt.toIso8601String(),
              'updatedAt': sas.updatedAt.toIso8601String(),
            },
            'ssDetails': ssDetails.map((detail) => {
              'id': detail.id,
              'sasId': detail.sasId,
              'securityString': detail.securityString,
              'pinValue': detail.pinValue,
              'isPinFree': detail.isPinFree,
              'isActive': detail.isActive,
              'hostname': detail.hostname,
              'port': detail.port,
              'connectionType': detail.connectionType,
              'siteId': detail.siteId,
              'createdAt': detail.createdAt.toIso8601String(),
              'updatedAt': detail.updatedAt.toIso8601String(),
            }).toList(),
          });
        }
        
        backupData['security_strings'] = securityStrings;
      }

      // Backup Settings
      if (includeSettings) {
        final settings = await CacheConfig.getAllPreferences();
        backupData['settings'] = settings;
      }

      // Convert to JSON
      String jsonData = jsonEncode(backupData);

      // Encrypt if password provided
      if (password != null) {
        jsonData = _encryptData(jsonData, password);
      }

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'sams_backup_$timestamp$_backupFileExtension';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonData);

      return BackupResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        fileSize: await file.length(),
        itemCount: _countBackupItems(backupData),
      );
    } catch (e) {
      return BackupResult(
        success: false,
        error: 'Failed to create backup: $e',
      );
    }
  }

  /// Restore data from backup file
  static Future<RestoreResult> restoreBackup({
    required String filePath,
    String? password,
    bool replaceExisting = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return RestoreResult(
          success: false,
          error: 'Backup file not found',
        );
      }

      String jsonData = await file.readAsString();

      // Try to decrypt if password provided
      if (password != null) {
        try {
          jsonData = _decryptData(jsonData, password);
        } catch (e) {
          return RestoreResult(
            success: false,
            error: 'Invalid password or corrupted backup file',
          );
        }
      }

      // Parse JSON
      final Map<String, dynamic> backupData;
      try {
        backupData = jsonDecode(jsonData);
      } catch (e) {
        return RestoreResult(
          success: false,
          error: 'Invalid backup file format',
        );
      }

      // Validate backup version
      final version = backupData['version'] as String?;
      if (version != _backupVersion) {
        return RestoreResult(
          success: false,
          error: 'Unsupported backup version: $version',
        );
      }

      int restoredItems = 0;

      // Clear existing data if requested
      if (replaceExisting) {
        await _clearExistingData();
      }

      // Restore OAuth tokens
      if (backupData.containsKey('oauth_tokens')) {
        final oauthDao = OAuthDao();
        final tokens = backupData['oauth_tokens'] as List;
        
        for (final tokenData in tokens) {
          final token = OAuthEntity(
            id: replaceExisting ? null : tokenData['id'],
            description: tokenData['description'],
            issuer: tokenData['issuer'],
            account: tokenData['account'],
            secret: tokenData['secret'],
            username: tokenData['username'] ?? '',
            provisionCode: tokenData['provisionCode'] ?? '',
            pin: tokenData['pin'] ?? false,
            dateIncluded: tokenData['dateIncluded'],
            algorithm: tokenData['algorithm'] ?? 'SHA1',
            digits: tokenData['digits'] ?? 6,
            period: tokenData['period'] ?? 30,
            label: tokenData['label'],
            createdAt: tokenData['createdAt'] != null
                ? DateTime.parse(tokenData['createdAt'])
                : DateTime.now(),
            updatedAt: tokenData['updatedAt'] != null
                ? DateTime.parse(tokenData['updatedAt'])
                : DateTime.now(),
          );
          
          await oauthDao.insert(token);
          restoredItems++;
        }
      }

      // Restore Security Strings
      if (backupData.containsKey('security_strings')) {
        final sasDao = SasDao();
        final ssDetailDao = SsDetailDao();
        final securityStrings = backupData['security_strings'] as List;
        
        for (final stringData in securityStrings) {
          final sasData = stringData['sas'];
          final ssDetailsData = stringData['ssDetails'] as List;
          
          // Create SS Detail first
          for (final detailData in ssDetailsData) {
            final ssDetail = SsDetailEntity(
              id: replaceExisting ? null : detailData['id'],
              sasId: 0, // Will be updated after SAS creation
              securityString: detailData['securityString'],
              pinValue: detailData['pinValue'],
              isPinFree: detailData['isPinFree'] ?? true,
              isActive: detailData['isActive'] ?? true,
              hostname: detailData['hostname'],
              port: detailData['port'] ?? 443,
              connectionType: detailData['connectionType'] ?? 'HTTPS',
              siteId: detailData['siteId'] ?? 'default',
              createdAt: detailData['createdAt'] != null 
                  ? DateTime.parse(detailData['createdAt']) 
                  : DateTime.now(),
              updatedAt: detailData['updatedAt'] != null 
                  ? DateTime.parse(detailData['updatedAt']) 
                  : DateTime.now(),
            );
            
            final ssDetailId = await ssDetailDao.insert(ssDetail);
            
            // Create SAS account
            final sas = SasEntity(
              id: replaceExisting ? null : sasData['id'],
              accountName: sasData['accountName'],
              serverUrl: sasData['serverUrl'],
              username: sasData['username'],
              provisionCode: sasData['provisionCode'] ?? 'restored',
              isActive: sasData['isActive'] ?? true,
              createdAt: sasData['createdAt'] != null 
                  ? DateTime.parse(sasData['createdAt']) 
                  : DateTime.now(),
              updatedAt: sasData['updatedAt'] != null 
                  ? DateTime.parse(sasData['updatedAt']) 
                  : DateTime.now(),
            );
            
            await sasDao.insert(sas, ssDetailId);
            restoredItems++;
          }
        }
      }

      // Restore Settings
      if (backupData.containsKey('settings')) {
        final settings = backupData['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          if (entry.value is bool) {
            await CacheConfig.add(entry.key, entry.value, ObjectType.boolean);
          } else if (entry.value is int) {
            await CacheConfig.add(entry.key, entry.value, ObjectType.integer);
          } else if (entry.value is String) {
            await CacheConfig.add(entry.key, entry.value, ObjectType.string);
          }
        }
      }

      return RestoreResult(
        success: true,
        restoredItems: restoredItems,
        backupTimestamp: backupData['timestamp'],
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        error: 'Failed to restore backup: $e',
      );
    }
  }

  /// Share backup file
  static Future<void> shareBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await Share.shareXFiles([XFile(filePath)], text: 'SAMS Backup File');
    }
  }

  /// Import backup file from device
  /// Note: For now, this returns null as file picker is not implemented
  /// In a production app, you would implement file picker functionality
  static Future<String?> importBackupFile() async {
    // TODO: Implement file picker functionality
    // For now, return null to indicate no file selected
    return null;
  }

  /// Simple encryption using password
  static String _encryptData(String data, String password) {
    final key = sha256.convert(utf8.encode(password)).toString();
    final bytes = utf8.encode(data);
    final encrypted = <int>[];
    
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ key.codeUnitAt(i % key.length));
    }
    
    return base64.encode(encrypted);
  }

  /// Simple decryption using password
  static String _decryptData(String encryptedData, String password) {
    final key = sha256.convert(utf8.encode(password)).toString();
    final encrypted = base64.decode(encryptedData);
    final decrypted = <int>[];
    
    for (int i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ key.codeUnitAt(i % key.length));
    }
    
    return utf8.decode(decrypted);
  }

  /// Count items in backup
  static int _countBackupItems(Map<String, dynamic> backupData) {
    int count = 0;
    
    if (backupData.containsKey('oauth_tokens')) {
      count += (backupData['oauth_tokens'] as List).length;
    }
    
    if (backupData.containsKey('security_strings')) {
      count += (backupData['security_strings'] as List).length;
    }
    
    return count;
  }

  /// Clear existing data
  static Future<void> _clearExistingData() async {
    final oauthDao = OAuthDao();
    final sasDao = SasDao();
    final ssDetailDao = SsDetailDao();

    // Clear all OAuth tokens
    final oauthTokens = await oauthDao.getAll();
    for (final token in oauthTokens) {
      if (token.id != null) {
        await oauthDao.delete(token.id!);
      }
    }

    // Clear all SAS accounts and their SS details
    final sasAccounts = await sasDao.getAll();
    for (final sas in sasAccounts) {
      if (sas.id != null) {
        // Clear SS details for this SAS account
        final ssDetails = await ssDetailDao.getBySasId(sas.id!);
        for (final detail in ssDetails) {
          if (detail.id != null) {
            await ssDetailDao.delete(detail.id!);
          }
        }
        await sasDao.delete(sas.id!);
      }
    }
  }
}

/// Result of backup operation
class BackupResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final int? itemCount;
  final String? error;

  BackupResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.itemCount,
    this.error,
  });
}

/// Result of restore operation
class RestoreResult {
  final bool success;
  final int? restoredItems;
  final String? backupTimestamp;
  final String? error;

  RestoreResult({
    required this.success,
    this.restoredItems,
    this.backupTimestamp,
    this.error,
  });
}
