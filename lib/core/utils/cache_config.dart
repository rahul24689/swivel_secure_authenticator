import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/enums.dart';
import '../constants/app_constants.dart';

class CacheConfig {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('CacheConfig not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Basic get/set operations
  static Future<void> add(String key, dynamic value, ObjectType type) async {
    await initialize();
    
    switch (type) {
      case ObjectType.boolean:
        await _preferences.setBool(key, value as bool);
        break;
      case ObjectType.integer:
        await _preferences.setInt(key, value as int);
        break;
      case ObjectType.string:
        await _preferences.setString(key, value as String);
        break;
    }
  }

  static dynamic get(String key, ObjectType type) {
    if (_prefs == null) return _getDefaultValue(type);
    
    switch (type) {
      case ObjectType.boolean:
        return _preferences.getBool(key) ?? false;
      case ObjectType.integer:
        return _preferences.getInt(key) ?? 0;
      case ObjectType.string:
        return _preferences.getString(key) ?? '';
    }
  }

  static dynamic _getDefaultValue(ObjectType type) {
    switch (type) {
      case ObjectType.boolean:
        return false;
      case ObjectType.integer:
        return 0;
      case ObjectType.string:
        return '';
    }
  }

  static Future<void> remove(String key) async {
    await initialize();
    await _preferences.remove(key);
  }

  static bool contain(String key) {
    if (_prefs == null) return false;
    return _preferences.containsKey(key);
  }

  static Future<void> clear() async {
    await initialize();
    await _preferences.clear();
  }

  // Convenience methods for common cache operations
  static Future<void> setRooted(bool isRooted) async {
    await add(AppConstants.keyRooted, isRooted, ObjectType.boolean);
  }

  static bool isRooted() {
    return get(AppConstants.keyRooted, ObjectType.boolean) as bool;
  }

  static Future<void> setProvisioningOk(bool isOk) async {
    await add(AppConstants.keyProvisioningOk, isOk, ObjectType.boolean);
  }

  static bool isProvisioningOk() {
    return get(AppConstants.keyProvisioningOk, ObjectType.boolean) as bool;
  }

  static Future<void> setOathOk(bool isOk) async {
    await add(AppConstants.keyOathOk, isOk, ObjectType.boolean);
  }

  static bool isOathOk() {
    return get(AppConstants.keyOathOk, ObjectType.boolean) as bool;
  }

  static Future<void> setPermissionGranted(bool isGranted) async {
    await add(AppConstants.keyPermission, isGranted, ObjectType.boolean);
  }

  static bool isPermissionGranted() {
    return get(AppConstants.keyPermission, ObjectType.boolean) as bool;
  }

  static Future<void> setBiometricKey(String key) async {
    await add(AppConstants.keyBiometric, key, ObjectType.string);
  }

  static String getBiometricKey() {
    return get(AppConstants.keyBiometric, ObjectType.string) as String;
  }

  static Future<void> setFirebaseToken(String token) async {
    await add(AppConstants.keyFirebaseToken, token, ObjectType.string);
  }

  static String getFirebaseToken() {
    return get(AppConstants.keyFirebaseToken, ObjectType.string) as String;
  }

  // File-based cache operations (similar to Android version)
  static Future<void> writeToFile(String filename, dynamic object) async {
    try {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/$filename');
      
      final jsonString = jsonEncode(object);
      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Failed to write to file: $e');
    }
  }

  static Future<dynamic> readFromFile(String filename) async {
    try {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/$filename');
      
      if (!await file.exists()) {
        throw FileSystemException('File does not exist', filename);
      }
      
      final jsonString = await file.readAsString();
      return jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Failed to read from file: $e');
    }
  }

  static Future<bool> fileExists(String filename) async {
    try {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/$filename');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  static Future<void> createFile(String filename) async {
    try {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/$filename');
      await file.create(recursive: true);
    } catch (e) {
      throw Exception('Failed to create file: $e');
    }
  }

  static Future<void> deleteFile(String filename) async {
    try {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/$filename');
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Application state management
  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await add(AppConstants.prefFirstLaunch, isFirstLaunch, ObjectType.boolean);
  }

  static bool isFirstLaunch() {
    return get(AppConstants.prefFirstLaunch, ObjectType.boolean) as bool;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await add(AppConstants.prefBiometricEnabled, enabled, ObjectType.boolean);
  }

  static bool isBiometricEnabled() {
    return get(AppConstants.prefBiometricEnabled, ObjectType.boolean) as bool;
  }

  static Future<void> setPushEnabled(bool enabled) async {
    await add(AppConstants.prefPushEnabled, enabled, ObjectType.boolean);
  }

  static bool isPushEnabled() {
    return get(AppConstants.prefPushEnabled, ObjectType.boolean) as bool;
  }

  static Future<void> setPushResponseLog(String log) async {
    await add('push_response_log', log, ObjectType.string);
  }

  static String getPushResponseLog() {
    return get('push_response_log', ObjectType.string) as String? ?? '';
  }

  static Future<void> setLastSync(int timestamp) async {
    await add(AppConstants.prefLastSync, timestamp, ObjectType.integer);
  }

  static int getLastSync() {
    return get(AppConstants.prefLastSync, ObjectType.integer) as int;
  }

  // Debug and development helpers
  static Future<Map<String, dynamic>> getAllPreferences() async {
    await initialize();
    final keys = _preferences.getKeys();
    final Map<String, dynamic> allPrefs = {};
    
    for (final key in keys) {
      allPrefs[key] = _preferences.get(key);
    }
    
    return allPrefs;
  }

  static Future<void> exportPreferences(String filePath) async {
    final allPrefs = await getAllPreferences();
    final file = File(filePath);
    await file.writeAsString(jsonEncode(allPrefs));
  }

  static Future<void> importPreferences(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Import file does not exist', filePath);
    }
    
    final jsonString = await file.readAsString();
    final Map<String, dynamic> prefs = jsonDecode(jsonString);
    
    await initialize();
    await _preferences.clear();
    
    for (final entry in prefs.entries) {
      final value = entry.value;
      if (value is bool) {
        await _preferences.setBool(entry.key, value);
      } else if (value is int) {
        await _preferences.setInt(entry.key, value);
      } else if (value is double) {
        await _preferences.setDouble(entry.key, value);
      } else if (value is String) {
        await _preferences.setString(entry.key, value);
      } else if (value is List<String>) {
        await _preferences.setStringList(entry.key, value);
      }
    }
  }

  /// Get last sync time for a SAS account
  static DateTime? getLastSyncTime(int sasId) {
    final timestamp = _preferences.getInt('last_sync_$sasId');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Set last sync time for a SAS account
  static Future<void> setLastSyncTime(int sasId, DateTime time) async {
    await _preferences.setInt('last_sync_$sasId', time.millisecondsSinceEpoch);
  }

  /// Get sync enabled status for a SAS account
  static bool isSyncEnabledForAccount(int sasId) {
    return _preferences.getBool('sync_enabled_$sasId') ?? true;
  }

  /// Set sync enabled status for a SAS account
  static Future<void> setSyncEnabledForAccount(int sasId, bool enabled) async {
    await _preferences.setBool('sync_enabled_$sasId', enabled);
  }

  /// Get auto sync interval in minutes
  static int getAutoSyncInterval() {
    return _preferences.getInt('auto_sync_interval') ?? 30; // Default 30 minutes
  }

  /// Set auto sync interval in minutes
  static Future<void> setAutoSyncInterval(int minutes) async {
    await _preferences.setInt('auto_sync_interval', minutes);
  }

  /// Check if auto sync is enabled
  static bool isAutoSyncEnabled() {
    return _preferences.getBool('auto_sync_enabled') ?? false;
  }

  /// Set auto sync enabled status
  static Future<void> setAutoSyncEnabled(bool enabled) async {
    await _preferences.setBool('auto_sync_enabled', enabled);
  }
}
