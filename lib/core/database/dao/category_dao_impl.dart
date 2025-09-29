import 'package:sqflite/sqflite.dart';
import '../../../shared/models/models.dart';
import '../database_helper.dart';
import 'category_dao.dart';

/// Category Data Access Object implementation
/// Converted from CategoryDaoImpl.java
class CategoryDaoImpl implements CategoryDao {
  
  @override
  Future<void> delete(CategoryEntity entity) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.transaction((txn) async {
      await txn.delete(
        CategoryDao.table,
        where: '${CategoryDao.columns[0]} = ?',
        whereArgs: [entity.id],
      );
    });
  }
  
  @override
  Future<CategoryEntity?> getEntity(CategoryEntity entity) async {
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.query(
      CategoryDao.table,
      where: '${CategoryDao.columns[0]} = ? AND yn_cancel = 0',
      whereArgs: [entity.id],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return CategoryEntity.fromMap(result.first);
    }
    
    return null;
  }
  
  @override
  Future<CategoryEntity?> getEntityById(int id) async {
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.query(
      CategoryDao.table,
      where: '${CategoryDao.columns[0]} = ? AND yn_cancel = 0',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return CategoryEntity.fromMap(result.first);
    }
    
    return null;
  }
  
  @override
  Future<void> insert(CategoryEntity entity) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.transaction((txn) async {
      await txn.insert(
        CategoryDao.table,
        {
          'pk_category': entity.id,
          'ds_category': entity.description,
          'yn_cancel': entity.isCancel ? 1 : 0,
          'dt_included': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }
  
  @override
  Future<List<CategoryEntity>> list() async {
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.query(
      CategoryDao.table,
      where: 'yn_cancel = 0',
      orderBy: 'ds_category ASC',
    );
    
    return result.map((map) => CategoryEntity.fromMap(map)).toList();
  }
  
  @override
  Future<void> update(CategoryEntity entity) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.transaction((txn) async {
      await txn.update(
        CategoryDao.table,
        {
          'ds_category': entity.description,
          'yn_cancel': entity.isCancel ? 1 : 0,
        },
        where: '${CategoryDao.columns[0]} = ?',
        whereArgs: [entity.id],
      );
    });
  }
  
  @override
  Future<void> deleteAll() async {
    final db = await DatabaseHelper.instance.database;
    
    await db.transaction((txn) async {
      await txn.delete(CategoryDao.table);
    });
  }
  
  @override
  Future<int?> getLastId() async {
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.rawQuery(
      'SELECT MAX(pk_category) as last_id FROM ${CategoryDao.table}'
    );
    
    if (result.isNotEmpty && result.first['last_id'] != null) {
      return result.first['last_id'] as int;
    }
    
    return null;
  }
  
  /// Get categories by name pattern
  Future<List<CategoryEntity>> searchByName(String pattern) async {
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.query(
      CategoryDao.table,
      where: 'ds_category LIKE ? AND yn_cancel = 0',
      whereArgs: ['%$pattern%'],
      orderBy: 'ds_category ASC',
    );
    
    return result.map((map) => CategoryEntity.fromMap(map)).toList();
  }
  
  /// Count total categories
  Future<int> count() async {
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${CategoryDao.table} WHERE yn_cancel = 0'
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Check if category exists by description
  Future<bool> existsByDescription(String description) async {
    final db = await DatabaseHelper.instance.database;
    
    final result = await db.query(
      CategoryDao.table,
      where: 'ds_category = ? AND yn_cancel = 0',
      whereArgs: [description],
      limit: 1,
    );
    
    return result.isNotEmpty;
  }
}
