import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' hide Key;


class EncryptionService {
  static const String _keyStorageKey = 'encryption_key';
  static const String _ivStorageKey = 'encryption_iv';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Encrypter? _encrypter;
  static IV? _iv;

  /// Initialize encryption service
  static Future<void> initialize() async {
    await _loadOrCreateKey();
  }

  /// Load existing key or create new one
  static Future<void> _loadOrCreateKey() async {
    try {
      // Try to load existing key
      final keyString = await _secureStorage.read(key: _keyStorageKey);
      final ivString = await _secureStorage.read(key: _ivStorageKey);

      if (keyString != null && ivString != null) {
        final key = Key.fromBase64(keyString);
        _iv = IV.fromBase64(ivString);
        _encrypter = Encrypter(AES(key));
      } else {
        // Create new key and IV
        await _createNewKey();
      }
    } catch (e) {
      // If there's any error, create a new key
      await _createNewKey();
    }
  }

  /// Create new encryption key and IV
  static Future<void> _createNewKey() async {
    final key = Key.fromSecureRandom(32); // 256-bit key
    _iv = IV.fromSecureRandom(16); // 128-bit IV
    _encrypter = Encrypter(AES(key));

    // Store securely
    await _secureStorage.write(key: _keyStorageKey, value: key.base64);
    await _secureStorage.write(key: _ivStorageKey, value: _iv!.base64);
  }

  /// Encrypt string data
  static Future<String> encrypt(String plainText) async {
    if (_encrypter == null || _iv == null) {
      await initialize();
    }

    try {
      final encrypted = _encrypter!.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypt string data
  static Future<String> decrypt(String encryptedText) async {
    if (_encrypter == null || _iv == null) {
      await initialize();
    }

    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter!.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw EncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Encrypt with custom key (for specific use cases)
  static String encryptWithKey(String plainText, String keyString) {
    try {
      final key = Key.fromBase64(keyString);
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key));
      
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // Combine IV and encrypted data
      final combined = iv.bytes + encrypted.bytes;
      return base64Encode(combined);
    } catch (e) {
      throw EncryptionException('Failed to encrypt with custom key: $e');
    }
  }

  /// Decrypt with custom key
  static String decryptWithKey(String encryptedText, String keyString) {
    try {
      final key = Key.fromBase64(keyString);
      final encrypter = Encrypter(AES(key));
      
      final combined = base64Decode(encryptedText);
      final iv = IV(Uint8List.fromList(combined.take(16).toList()));
      final encryptedBytes = Uint8List.fromList(combined.skip(16).toList());
      final encrypted = Encrypted(encryptedBytes);
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw EncryptionException('Failed to decrypt with custom key: $e');
    }
  }

  /// Generate hash of data
  static String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate HMAC
  static String generateHMAC(String data, String key) {
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(data);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(dataBytes);
    return digest.toString();
  }

  /// Verify HMAC
  static bool verifyHMAC(String data, String key, String expectedHmac) {
    final calculatedHmac = generateHMAC(data, key);
    return calculatedHmac == expectedHmac;
  }

  /// Generate secure random string
  static String generateSecureRandom(int length) {
    final key = Key.fromSecureRandom(length);
    return key.base64;
  }

  /// Generate key from password and salt
  static Key deriveKeyFromPassword(String password, String salt) {
    final saltBytes = utf8.encode(salt);
    final passwordBytes = utf8.encode(password);
    
    // Simple PBKDF2 implementation
    var result = passwordBytes;
    for (int i = 0; i < 10000; i++) {
      final hmac = Hmac(sha256, result);
      result = Uint8List.fromList(hmac.convert(saltBytes + result).bytes);
    }
    
    return Key(Uint8List.fromList(result.take(32).toList()));
  }

  /// Encrypt sensitive data for storage
  static Future<String> encryptForStorage(String data) async {
    return await encrypt(data);
  }

  /// Decrypt sensitive data from storage
  static Future<String> decryptFromStorage(String encryptedData) async {
    return await decrypt(encryptedData);
  }

  /// Encrypt username with Firebase token (similar to Android version)
  static Future<String> encryptUsername(String username, String firebaseToken) async {
    if (firebaseToken.isEmpty) {
      throw EncryptionException('Firebase token is required for username encryption');
    }
    
    return encryptWithKey(username, _generateKeyFromToken(firebaseToken));
  }

  /// Decrypt username with Firebase token
  static Future<String> decryptUsername(String encryptedUsername, String firebaseToken) async {
    if (firebaseToken.isEmpty) {
      throw EncryptionException('Firebase token is required for username decryption');
    }
    
    return decryptWithKey(encryptedUsername, _generateKeyFromToken(firebaseToken));
  }

  /// Generate encryption key from Firebase token
  static String _generateKeyFromToken(String token) {
    final hash = sha256.convert(utf8.encode(token));
    return base64Encode(hash.bytes.take(32).toList());
  }

  /// Clear all encryption keys (for logout/reset)
  static Future<void> clearKeys() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
    _encrypter = null;
    _iv = null;
  }

  /// Check if encryption is initialized
  static bool get isInitialized => _encrypter != null && _iv != null;

  /// Get encryption key for backup purposes (use with caution)
  static Future<String?> getEncryptionKeyForBackup() async {
    return await _secureStorage.read(key: _keyStorageKey);
  }

  /// Restore encryption key from backup
  static Future<void> restoreEncryptionKeyFromBackup(String keyBase64, String ivBase64) async {
    await _secureStorage.write(key: _keyStorageKey, value: keyBase64);
    await _secureStorage.write(key: _ivStorageKey, value: ivBase64);
    await _loadOrCreateKey();
  }

  /// Encrypt binary data
  static Future<Uint8List> encryptBytes(Uint8List data) async {
    if (_encrypter == null || _iv == null) {
      await initialize();
    }

    try {
      final encrypted = _encrypter!.encryptBytes(data, iv: _iv);
      return encrypted.bytes;
    } catch (e) {
      throw EncryptionException('Failed to encrypt bytes: $e');
    }
  }

  /// Decrypt binary data
  static Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    if (_encrypter == null || _iv == null) {
      await initialize();
    }

    try {
      final encrypted = Encrypted(encryptedData);
      return Uint8List.fromList(_encrypter!.decryptBytes(encrypted, iv: _iv));
    } catch (e) {
      throw EncryptionException('Failed to decrypt bytes: $e');
    }
  }
}

/// Exception class for encryption errors
class EncryptionException implements Exception {
  final String message;

  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
