import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
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
    // In production, this should be derived from device-specific information
    // and stored securely using flutter_secure_storage
    return 'swivel_secure_db_key_2024';
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add any migration logic here
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.tableCategory} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          date_included INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
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
