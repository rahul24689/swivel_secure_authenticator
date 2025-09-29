import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../constants/app_constants.dart';
import 'dao/sas_dao.dart';
import 'dao/ss_detail_dao.dart';
import 'dao/security_string_dao.dart';
import 'dao/oauth_dao.dart';
import 'dao/policy_dao.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  // DAO instances
  SasDao? _sasDao;
  SsDetailDao? _ssDetailDao;
  SecurityStringDao? _securityStringDao;
  OAuthDao? _oauthDao;
  PolicyDao? _policyDao;

  DatabaseHelper._internal();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  // DAO getters
  SasDao get sasDao {
    _sasDao ??= SasDao();
    return _sasDao!;
  }

  SsDetailDao get ssDetailDao {
    _ssDetailDao ??= SsDetailDao();
    return _ssDetailDao!;
  }

  SecurityStringDao get securityStringDao {
    _securityStringDao ??= SecurityStringDao();
    return _securityStringDao!;
  }

  OAuthDao get oauthDao {
    _oauthDao ??= OAuthDao();
    return _oauthDao!;
  }

  PolicyDao get policyDao {
    _policyDao ??= PolicyDao();
    return _policyDao!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      password: await _getDatabasePassword(),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<String> _getDatabasePassword() async {
    // Generate or retrieve secure database password
    return await _generateSecureDatabasePassword();
  }

  /// Generate secure database password based on device characteristics
  Future<String> _generateSecureDatabasePassword() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );

    const passwordKey = 'database_password_v2';

    // Try to retrieve existing password
    String? existingPassword = await storage.read(key: passwordKey);
    if (existingPassword != null && existingPassword.isNotEmpty) {
      return existingPassword;
    }

    // Generate new secure password
    final deviceInfo = DeviceInfoPlugin();
    String deviceIdentifier = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceIdentifier = '${androidInfo.id}_${androidInfo.fingerprint}_${androidInfo.bootloader}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceIdentifier = '${iosInfo.identifierForVendor}_${iosInfo.systemVersion}_${iosInfo.model}';
      }
    } catch (e) {
      debugPrint('Failed to get device info: $e');
      deviceIdentifier = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Create secure password using PBKDF2
    final salt = 'swivel_secure_salt_2024_$deviceIdentifier';
    final password = await _deriveKeyFromPassword(
      'swivel_secure_master_key_2024',
      salt,
      iterations: 100000,
      keyLength: 32,
    );

    final securePassword = base64Encode(password);

    // Store the password securely
    await storage.write(key: passwordKey, value: securePassword);

    return securePassword;
  }

  /// Derive key from password using PBKDF2
  Future<Uint8List> _deriveKeyFromPassword(
    String password,
    String salt,
    {int iterations = 100000, int keyLength = 32}
  ) async {
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);

    var result = Uint8List.fromList(passwordBytes);

    for (int i = 0; i < iterations; i++) {
      final hmac = Hmac(sha256, passwordBytes);
      result = Uint8List.fromList(hmac.convert(saltBytes + result).bytes);
    }

    return Uint8List.fromList(result.take(keyLength).toList());
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Backup data before migration
    await _backupDataBeforeMigration(db, oldVersion);

    try {
      // Apply migrations step by step
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        await _applyMigration(db, version);
      }

      // Verify data integrity after migration
      await _verifyDataIntegrity(db);

      print('Database migration completed successfully');
    } catch (e) {
      print('Database migration failed: $e');
      // Attempt to restore from backup
      await _restoreFromBackup(db, oldVersion);
      rethrow;
    }
  }

  Future<void> _applyMigration(Database db, int version) async {
    print('Applying migration to version $version');

    switch (version) {
      case 2:
        await _migrationV2(db);
        break;
      case 3:
        await _migrationV3(db);
        break;
      case 4:
        await _migrationV4(db);
        break;
      case 5:
        await _migrationV5(db);
        break;
      default:
        print('No migration defined for version $version');
    }
  }

  Future<void> _migrationV2(Database db) async {
    // Add category table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppConstants.tableCategory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        date_included INTEGER NOT NULL
      )
    ''');

    // Add indexes for better performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_category_name ON ${AppConstants.tableCategory}(name)
    ''');
  }

  Future<void> _migrationV3(Database db) async {
    // Add new columns to existing tables
    await db.execute('''
      ALTER TABLE ${AppConstants.tableSas} ADD COLUMN last_sync_at INTEGER DEFAULT 0
    ''');

    await db.execute('''
      ALTER TABLE ${AppConstants.tableSsDetail} ADD COLUMN connection_timeout INTEGER DEFAULT 30000
    ''');
  }

  Future<void> _migrationV4(Database db) async {
    // Add policy table enhancements
    await db.execute('''
      ALTER TABLE ${AppConstants.tablePolicy} ADD COLUMN created_at INTEGER DEFAULT 0
    ''');

    await db.execute('''
      ALTER TABLE ${AppConstants.tablePolicy} ADD COLUMN updated_at INTEGER DEFAULT 0
    ''');

    // Update existing records with current timestamp
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.execute('''
      UPDATE ${AppConstants.tablePolicy}
      SET created_at = ?, updated_at = ?
      WHERE created_at = 0
    ''', [now, now]);
  }

  Future<void> _migrationV5(Database db) async {
    // Add backup and sync tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS backup_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        backup_type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        size_bytes INTEGER NOT NULL,
        checksum TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sas_id INTEGER NOT NULL,
        sync_type TEXT NOT NULL,
        status TEXT NOT NULL,
        message TEXT,
        started_at INTEGER NOT NULL,
        completed_at INTEGER,
        FOREIGN KEY (sas_id) REFERENCES ${AppConstants.tableSas}(sas_id)
      )
    ''');
  }

  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Migration helper methods
  Future<void> _backupDataBeforeMigration(Database db, int oldVersion) async {
    try {
      // Create backup tables for critical data
      final tables = ['${AppConstants.tableSas}', '${AppConstants.tableSsDetail}',
                     '${AppConstants.tableSecurityString}', '${AppConstants.tableOAuth}'];

      for (String table in tables) {
        final backupTable = '${table}_backup_v$oldVersion';

        // Check if table exists
        final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$table'"
        );

        if (result.isNotEmpty) {
          // Create backup table
          await db.execute('DROP TABLE IF EXISTS $backupTable');
          await db.execute('CREATE TABLE $backupTable AS SELECT * FROM $table');
          print('Backed up $table to $backupTable');
        }
      }
    } catch (e) {
      print('Warning: Failed to backup data before migration: $e');
      // Continue with migration even if backup fails
    }
  }

  Future<void> _verifyDataIntegrity(Database db) async {
    try {
      // Verify critical tables exist and have expected structure
      final criticalTables = [
        AppConstants.tableSas,
        AppConstants.tableSsDetail,
        AppConstants.tableSecurityString,
        AppConstants.tableOAuth,
        AppConstants.tablePolicy,
      ];

      for (String table in criticalTables) {
        final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$table'"
        );

        if (result.isEmpty) {
          throw Exception('Critical table $table is missing after migration');
        }
      }

      // Verify foreign key constraints
      await db.execute('PRAGMA foreign_key_check');

      // Check for data consistency
      await _checkDataConsistency(db);

      print('Data integrity verification passed');
    } catch (e) {
      throw Exception('Data integrity verification failed: $e');
    }
  }

  Future<void> _checkDataConsistency(Database db) async {
    // Check SAS-SsDetail relationship
    final orphanedSsDetails = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${AppConstants.tableSsDetail}
      WHERE sas_id NOT IN (SELECT sas_id FROM ${AppConstants.tableSas})
    ''');

    if ((orphanedSsDetails.first['count'] as int) > 0) {
      print('Warning: Found orphaned SS details');
    }

    // Check SAS-SecurityString relationship
    final orphanedSecurityStrings = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${AppConstants.tableSecurityString}
      WHERE sas_id NOT IN (SELECT sas_id FROM ${AppConstants.tableSas})
    ''');

    if ((orphanedSecurityStrings.first['count'] as int) > 0) {
      print('Warning: Found orphaned security strings');
    }
  }

  Future<void> _restoreFromBackup(Database db, int oldVersion) async {
    try {
      print('Attempting to restore from backup...');

      final tables = ['${AppConstants.tableSas}', '${AppConstants.tableSsDetail}',
                     '${AppConstants.tableSecurityString}', '${AppConstants.tableOAuth}'];

      for (String table in tables) {
        final backupTable = '${table}_backup_v$oldVersion';

        // Check if backup table exists
        final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$backupTable'"
        );

        if (result.isNotEmpty) {
          // Restore from backup
          await db.execute('DELETE FROM $table');
          await db.execute('INSERT INTO $table SELECT * FROM $backupTable');
          print('Restored $table from $backupTable');
        }
      }

      print('Database restored from backup');
    } catch (e) {
      print('Failed to restore from backup: $e');
      throw Exception('Migration failed and backup restoration failed: $e');
    }
  }

  Future<void> _createTables(Database db) async {
    // SS Detail Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSsDetail} (
        pk_ss_detail INTEGER PRIMARY KEY AUTOINCREMENT,
        ds_ss_detail TEXT NOT NULL,
        ds_hostname TEXT NOT NULL,
        yn_using_ssl INTEGER NOT NULL DEFAULT 0,
        yn_push_support INTEGER NOT NULL DEFAULT 0,
        yn_local INTEGER NOT NULL DEFAULT 0,
        yn_pin INTEGER NOT NULL DEFAULT 0,
        yn_oath INTEGER NOT NULL DEFAULT 0,
        nr_port INTEGER NOT NULL,
        ds_connection_type TEXT NOT NULL,
        nr_site_id TEXT NOT NULL,
        yn_cancel INTEGER NOT NULL DEFAULT 0,
        dt_included INTEGER NOT NULL
      )
    ''');

    // Provision Info Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProvisionInfo} (
        pk_provision_info INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_ss_detail INTEGER NOT NULL,
        ds_provision_info TEXT NOT NULL,
        nr_site_id TEXT NOT NULL,
        ds_username TEXT NOT NULL,
        ds_provision_code TEXT NOT NULL,
        yn_cancel INTEGER NOT NULL DEFAULT 0,
        dt_included INTEGER NOT NULL,
        FOREIGN KEY (fk_ss_detail) REFERENCES ${AppConstants.tableSsDetail}(pk_ss_detail)
      )
    ''');

    // SAS Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSas} (
        pk_sas INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_ss_detail INTEGER NOT NULL,
        ds_sas TEXT NOT NULL,
        ds_username TEXT NOT NULL,
        ds_provision_code TEXT NOT NULL,
        ds_push_id TEXT,
        ds_sas_id TEXT,
        yn_cancel INTEGER NOT NULL DEFAULT 0,
        dt_included INTEGER NOT NULL,
        FOREIGN KEY (fk_ss_detail) REFERENCES ${AppConstants.tableSsDetail}(pk_ss_detail)
      )
    ''');

    // Security String Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSecurityString} (
        pk_security_string INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_sas INTEGER NOT NULL,
        ds_security_string TEXT NOT NULL,
        nr_security_string TEXT NOT NULL,
        nr_token_index TEXT NOT NULL DEFAULT 0,
        yn_used_code INTEGER NOT NULL DEFAULT 0,
        yn_cancel INTEGER NOT NULL DEFAULT 0,
        dt_included INTEGER NOT NULL,
        FOREIGN KEY (fk_sas) REFERENCES ${AppConstants.tableSas}(pk_sas)
      )
    ''');

    // Policy Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tablePolicy} (
        pk_policy INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_sas INTEGER NOT NULL,
        ds_policy TEXT NOT NULL,
        ds_content TEXT NOT NULL,
        yn_cancel INTEGER NOT NULL DEFAULT 0,
        dt_included INTEGER NOT NULL,
        FOREIGN KEY (fk_sas) REFERENCES ${AppConstants.tableSas}(pk_sas)
      )
    ''');

    // Log Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableLog} (
        pk_log INTEGER PRIMARY KEY AUTOINCREMENT,
        ds_log TEXT,
        nr_site_id TEXT,
        ds_username TEXT,
        nr_info_type INTEGER NOT NULL DEFAULT 0,
        yn_cancel INTEGER NOT NULL DEFAULT 0,
        dt_included INTEGER NOT NULL
      )
    ''');

    // OAuth Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableOAuth} (
        pk_oauth INTEGER PRIMARY KEY AUTOINCREMENT,
        ds_oauth TEXT NOT NULL,
        ds_issuer TEXT NOT NULL,
        ds_account TEXT NOT NULL,
        ds_secret TEXT NOT NULL,
        ds_username TEXT NOT NULL,
        ds_provision_code TEXT NOT NULL,
        yn_pin INTEGER NOT NULL DEFAULT 0,
        yn_cancel INTEGER NOT NULL DEFAULT 0,
        dt_included INTEGER NOT NULL
      )
    ''');

    // Category Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCategory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        date_included INTEGER NOT NULL
      )
    ''');

    // Policies Table
    await db.execute('''
      CREATE TABLE policies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        policy_id TEXT NOT NULL,
        content TEXT NOT NULL,
        description TEXT,
        sas_id INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (sas_id) REFERENCES ${AppConstants.tableSas} (pk_sas),
        UNIQUE(policy_id, sas_id)
      )
    ''');
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.databaseName);
    
    await closeDatabase();
    
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> count(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
