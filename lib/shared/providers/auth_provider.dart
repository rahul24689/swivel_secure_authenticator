import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/security_string_service.dart';
import '../services/oath_service.dart';
import '../services/biometric_service.dart';
import '../../core/database/repositories/ss_detail_repository.dart';

class AuthProvider extends ChangeNotifier {
  final SecurityStringService _securityStringService = SecurityStringService();
  final SsDetailRepository _ssDetailRepository = SsDetailRepository();

  // State
  List<SsDetailEntity> _servers = [];
  List<SecurityStringEntity> _securityStrings = [];
  List<OAuthEntity> _oauthTokens = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SsDetailEntity> get servers => _servers;
  List<SecurityStringEntity> get securityStrings => _securityStrings;
  List<OAuthEntity> get oauthTokens => _oauthTokens;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Authentication state
  bool _isAuthenticated = false;
  SsDetailEntity? _currentServer;
  SasEntity? _currentSas;

  bool get isAuthenticated => _isAuthenticated;
  SsDetailEntity? get currentServer => _currentServer;
  SasEntity? get currentSas => _currentSas;

  /// Initialize provider
  Future<void> initialize() async {
    await loadServers();
  }

  /// Load all servers
  Future<void> loadServers() async {
    _setLoading(true);
    try {
      _servers = await _ssDetailRepository.getAllWithSasEntities();
      _clearError();
    } catch (e) {
      _setError('Failed to load servers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load security strings for a specific SAS
  Future<void> loadSecurityStrings(int sasId) async {
    _setLoading(true);
    try {
      _securityStrings = await _securityStringService.getAllSecurityStrings(sasId);
      _clearError();
    } catch (e) {
      _setError('Failed to load security strings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Authenticate with security string
  Future<bool> authenticateWithSecurityString({
    required int sasId,
    required int tokenIndex,
    required String securityCode,
  }) async {
    _setLoading(true);
    try {
      final result = await _securityStringService.authenticateWithSecurityString(
        sasId,
        tokenIndex,
        securityCode,
      );

      if (result.success) {
        _isAuthenticated = true;
        await loadSecurityStrings(sasId); // Refresh to show updated usage
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Authentication failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAuthenticated = await BiometricService.authenticate(
        localizedReason: 'Please authenticate to access your security strings',
      );

      if (isAuthenticated) {
        _isAuthenticated = true;
        _clearError();
        notifyListeners();
      }

      return isAuthenticated;
    } catch (e) {
      _setError('Biometric authentication failed: $e');
      return false;
    }
  }

  /// Generate OATH TOTP code
  String generateOATHCode(OAuthEntity oauthEntity) {
    try {
      return OathService.generateTOTPForOAuth(oauthEntity);
    } catch (e) {
      _setError('Failed to generate OATH code: $e');
      return '';
    }
  }

  /// Get next available security string
  Future<SecurityStringEntity?> getNextSecurityString(int sasId) async {
    try {
      return await _securityStringService.getNextUnusedSecurityString(sasId);
    } catch (e) {
      _setError('Failed to get next security string: $e');
      return null;
    }
  }

  /// Get security string statistics
  Future<SecurityStringStats?> getSecurityStringStats(int sasId) async {
    try {
      return await _securityStringService.getSecurityStringStats(sasId);
    } catch (e) {
      _setError('Failed to get security string statistics: $e');
      return null;
    }
  }

  /// Set current server
  void setCurrentServer(SsDetailEntity server) {
    _currentServer = server;
    notifyListeners();
  }

  /// Set current SAS
  void setCurrentSas(SasEntity sas) {
    _currentSas = sas;
    notifyListeners();
  }

  /// Logout
  void logout() {
    _isAuthenticated = false;
    _currentServer = null;
    _currentSas = null;
    _clearError();
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadServers();
    if (_currentSas?.id != null) {
      await loadSecurityStrings(_currentSas!.id!);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
