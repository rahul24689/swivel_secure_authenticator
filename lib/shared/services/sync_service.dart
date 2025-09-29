import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import '../../core/database/dao/sas_dao.dart';
import '../../core/database/dao/ss_detail_dao.dart';
import '../../core/database/dao/security_string_dao.dart';
import '../../core/database/dao/policy_dao.dart';
import '../../core/network/http_client.dart';
import '../../core/utils/cache_config.dart';
import '../../core/constants/app_constants.dart';
import 'api_service.dart';

/// Service for synchronizing data with Swivel Secure servers
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static SyncService get instance => _instance;

  final SasDao _sasDao = SasDao();
  final SsDetailDao _ssDetailDao = SsDetailDao();
  final SecurityStringDao _securityStringDao = SecurityStringDao();
  final PolicyDao _policyDao = PolicyDao();

  /// Check if sync is enabled for a specific SAS account
  Future<bool> isSyncEnabled(int sasId) async {
    try {
      final policies = await _policyDao.getBySasId(sasId);
      final syncPolicy = policies.firstWhere(
        (policy) => policy.policyId == 'syncIndex',
        orElse: () => PolicyEntity(
          policyId: 'syncIndex',
          content: 'OFF',
          sasId: sasId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return syncPolicy.content.toUpperCase() == 'ON';
    } catch (e) {
      return false;
    }
  }

  /// Sync token index for all SAS accounts
  Future<SyncResult> syncAllTokenIndexes() async {
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return SyncResult(
          success: false,
          error: 'No internet connection available',
        );
      }

      final sasAccounts = await _sasDao.getAll();
      final results = <SyncAccountResult>[];

      for (final sas in sasAccounts) {
        if (sas.id != null) {
          final result = await syncTokenIndex(sas.id!);
          results.add(result);
        }
      }

      final successCount = results.where((r) => r.success).length;
      final totalCount = results.length;

      return SyncResult(
        success: successCount > 0,
        syncedAccounts: successCount,
        totalAccounts: totalCount,
        accountResults: results,
        message: successCount == totalCount 
          ? 'All accounts synced successfully'
          : '$successCount of $totalCount accounts synced',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        error: 'Sync failed: $e',
      );
    }
  }

  /// Sync token index for a specific SAS account
  Future<SyncAccountResult> syncTokenIndex(int sasId) async {
    try {
      final sas = await _sasDao.getById(sasId);
      if (sas == null) {
        return SyncAccountResult(
          sasId: sasId,
          success: false,
          error: 'SAS account not found',
        );
      }

      // Check if sync is enabled for this account
      if (!await isSyncEnabled(sasId)) {
        return SyncAccountResult(
          sasId: sasId,
          success: true,
          skipped: true,
          message: 'Sync disabled for this account',
        );
      }

      // Get server details
      final serverDetails = await _ssDetailDao.getBySasId(sasId);
      if (serverDetails.isEmpty) {
        return SyncAccountResult(
          sasId: sasId,
          success: false,
          error: 'No server details found',
        );
      }

      final serverDetail = serverDetails.first;

      // Get current token index from server
      final currentIndex = await _getTokenIndexFromServer(serverDetail, sas);
      
      if (currentIndex > 0) {
        // Update local security strings with new index
        await _updateSecurityStringIndex(sasId, currentIndex);
        
        return SyncAccountResult(
          sasId: sasId,
          success: true,
          newTokenIndex: currentIndex,
          message: 'Token index updated to $currentIndex',
        );
      } else {
        return SyncAccountResult(
          sasId: sasId,
          success: false,
          error: 'Invalid token index received from server',
        );
      }
    } catch (e) {
      return SyncAccountResult(
        sasId: sasId,
        success: false,
        error: 'Sync failed: $e',
      );
    }
  }

  /// Get token index from server
  Future<int> _getTokenIndexFromServer(SsDetailEntity serverDetail, SasEntity sas) async {
    try {
      final url = 'https://${serverDetail.hostname}:${serverDetail.port}/proxy/TokenIndex';
      
      final response = await HttpClient.get(
        url,
        queryParameters: {
          'username': sas.username,
        },
      );

      if (response.statusCode == 200) {
        final indexString = response.data.toString().trim();
        final index = int.tryParse(indexString) ?? 0;
        return index >= 0 ? index : 0;
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to get token index');
      }
    } catch (e) {
      throw Exception('Failed to get token index from server: $e');
    }
  }

  /// Update security string index locally
  Future<void> _updateSecurityStringIndex(int sasId, int newIndex) async {
    try {
      // Get all security strings for this SAS
      final securityStrings = await _securityStringDao.getBySasId(sasId);
      
      // Mark all strings before the new index as used
      for (final securityString in securityStrings) {
        if (securityString.tokenIndex < newIndex && securityString.id != null) {
          await _securityStringDao.markAsUsed(securityString.id!);
        }
      }

      // Update the SAS entity with the new current index
      final sas = await _sasDao.getById(sasId);
      if (sas != null && sas.id != null) {
        final updatedSas = sas.copyWith(
          updatedAt: DateTime.now(),
        );
        await _sasDao.update(updatedSas);
      }
    } catch (e) {
      throw Exception('Failed to update security string index: $e');
    }
  }

  /// Perform full data sync (provision, security strings, policies)
  Future<SyncResult> performFullSync(int sasId) async {
    try {
      final sas = await _sasDao.getById(sasId);
      if (sas == null) {
        return SyncResult(
          success: false,
          error: 'SAS account not found',
        );
      }

      final serverDetails = await _ssDetailDao.getBySasId(sasId);
      if (serverDetails.isEmpty) {
        return SyncResult(
          success: false,
          error: 'No server details found',
        );
      }

      final serverDetail = serverDetails.first;

      // 1. Sync token index
      final tokenIndexResult = await syncTokenIndex(sasId);
      
      // 2. Sync security strings if needed
      final securityStrings = await _securityStringDao.getBySasId(sasId);
      final hasSecurityStrings = securityStrings.isNotEmpty;
      if (!hasSecurityStrings) {
        await _syncSecurityStrings(serverDetail, sas);
      }

      // 3. Sync policies
      await _syncPolicies(serverDetail, sas);

      return SyncResult(
        success: tokenIndexResult.success,
        syncedAccounts: 1,
        totalAccounts: 1,
        message: 'Full sync completed successfully',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        error: 'Full sync failed: $e',
      );
    }
  }

  /// Sync security strings from server
  Future<void> _syncSecurityStrings(SsDetailEntity serverDetail, SasEntity sas) async {
    try {
      // This would call the security string API endpoint
      // Implementation depends on the specific API structure
      // For now, we'll use the existing API service
      
      final provisionInfo = ProvisionInfoEntity(
        siteId: serverDetail.siteId ?? '',
        username: sas.username,
        provisionCode: sas.provisionCode ?? '',
      );

      // Note: This is a placeholder - actual implementation would depend on API structure
      // await ApiService.getSecurityStrings(serverDetail: serverDetail, provisionInfo: provisionInfo);
    } catch (e) {
      throw Exception('Failed to sync security strings: $e');
    }
  }

  /// Sync policies from server
  Future<void> _syncPolicies(SsDetailEntity serverDetail, SasEntity sas) async {
    try {
      // This would call the policies API endpoint
      // Implementation depends on the specific API structure
      
      // For now, we'll create default policies if they don't exist
      final existingPolicies = await _policyDao.getBySasId(sas.id!);
      
      if (existingPolicies.isEmpty) {
        final defaultPolicies = [
          PolicyEntity(
            policyId: 'syncIndex',
            content: 'ON',
            sasId: sas.id!,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          PolicyEntity(
            policyId: 'biometric',
            content: 'ON',
            sasId: sas.id!,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final policy in defaultPolicies) {
          await _policyDao.insert(policy);
        }
      }
    } catch (e) {
      throw Exception('Failed to sync policies: $e');
    }
  }

  /// Get sync status for all accounts
  Future<List<SyncStatus>> getSyncStatus() async {
    try {
      final sasAccounts = await _sasDao.getAll();
      final statuses = <SyncStatus>[];

      for (final sas in sasAccounts) {
        if (sas.id != null) {
          final isEnabled = await isSyncEnabled(sas.id!);
          final lastSync = CacheConfig.getLastSyncTime(sas.id!);
          
          statuses.add(SyncStatus(
            sasId: sas.id!,
            username: sas.username,
            syncEnabled: isEnabled,
            lastSyncTime: lastSync,
            currentIndex: 0, // Default index
          ));
        }
      }

      return statuses;
    } catch (e) {
      return [];
    }
  }

  /// Enable/disable sync for a specific account
  Future<bool> setSyncEnabled(int sasId, bool enabled) async {
    try {
      final policy = PolicyEntity(
        policyId: 'syncIndex',
        content: enabled ? 'ON' : 'OFF',
        sasId: sasId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _policyDao.insertOrUpdate(policy);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final String? error;
  final String? message;
  final int syncedAccounts;
  final int totalAccounts;
  final List<SyncAccountResult> accountResults;

  SyncResult({
    required this.success,
    this.error,
    this.message,
    this.syncedAccounts = 0,
    this.totalAccounts = 0,
    this.accountResults = const [],
  });
}

/// Result of sync operation for a specific account
class SyncAccountResult {
  final int sasId;
  final bool success;
  final bool skipped;
  final String? error;
  final String? message;
  final int? newTokenIndex;

  SyncAccountResult({
    required this.sasId,
    required this.success,
    this.skipped = false,
    this.error,
    this.message,
    this.newTokenIndex,
  });
}

/// Sync status for an account
class SyncStatus {
  final int sasId;
  final String username;
  final bool syncEnabled;
  final DateTime? lastSyncTime;
  final int? currentIndex;

  SyncStatus({
    required this.sasId,
    required this.username,
    required this.syncEnabled,
    this.lastSyncTime,
    this.currentIndex,
  });
}
