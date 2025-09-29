import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

/// Migration configuration for handling data migration from previous versions
/// Converted from MigrationConfig.java
class MigrationConfig {
  static String? _code;
  static bool isFirstTime = true;
  
  /// Get migration code
  static String? get code => _code;
  
  /// Generate random migration code
  static void setCode() {
    try {
      final random = Random();
      final randomNumber = random.nextInt(899999) + 100000; // 6-digit number between 100000-999999
      _code = randomNumber.toString();
    } catch (e) {
      debugPrint('Error setting migration code: $e');
    }
  }
  
  /// Call migration process
  static void callMigration(BuildContext context, String backStack) {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushNamed('/auto_migration');
    });
  }
  
  /// Read shared info and determine if migration is needed
  static Future<bool> callReadSharedInfo(BuildContext context, String backStack) async {
    try {
      if (!isFirstTime) {
        return false;
      }
      
      isFirstTime = false;
      
      // Check if migration has already been performed
      final migrationStatus = await _checkMigrationStatus();
      
      if (migrationStatus > 0) {
        return false; // Migration already completed
      }
      
      // Show migration screen
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushNamed(
          '/auto_migration',
          arguments: {'backStack': backStack},
        );
      });
      
      return true;
    } catch (e) {
      debugPrint('Error in callReadSharedInfo: $e');
      return false;
    }
  }
  
  /// Check migration status from database
  static Future<int> _checkMigrationStatus() async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Check if migration table exists and get status
      final result = await db.rawQuery('''
        SELECT yn_migrate FROM migration_status 
        WHERE id = 1
      ''');
      
      if (result.isNotEmpty) {
        return result.first['yn_migrate'] as int? ?? 0;
      }
      
      return 0; // No migration status found
    } catch (e) {
      debugPrint('Error checking migration status: $e');
      return 0;
    }
  }
  
  /// Set migration status
  static Future<void> setMigrationStatus(int status) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      await db.rawInsert('''
        INSERT OR REPLACE INTO migration_status (id, yn_migrate, created_at)
        VALUES (1, ?, ?)
      ''', [status, DateTime.now().millisecondsSinceEpoch]);
      
      debugPrint('Migration status set to: $status');
    } catch (e) {
      debugPrint('Error setting migration status: $e');
    }
  }
  
  /// Check if migration is needed
  static Future<bool> isMigrationNeeded() async {
    try {
      final status = await _checkMigrationStatus();
      return status == 0;
    } catch (e) {
      debugPrint('Error checking if migration is needed: $e');
      return false;
    }
  }
  
  /// Complete migration
  static Future<void> completeMigration() async {
    try {
      await setMigrationStatus(1);
      isFirstTime = false;
      debugPrint('Migration completed successfully');
    } catch (e) {
      debugPrint('Error completing migration: $e');
    }
  }
  
  /// Reset migration status (for testing)
  static Future<void> resetMigration() async {
    try {
      await setMigrationStatus(0);
      isFirstTime = true;
      debugPrint('Migration status reset');
    } catch (e) {
      debugPrint('Error resetting migration: $e');
    }
  }
  
  /// Get migration info
  static Map<String, dynamic> getMigrationInfo() {
    return {
      'isFirstTime': isFirstTime,
      'code': _code,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
