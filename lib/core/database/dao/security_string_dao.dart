import '../database_helper.dart';
import '../../../shared/models/models.dart';
import '../../constants/app_constants.dart';

class SecurityStringDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(SecurityStringEntity entity, int sasId) async {
    final values = {
      'fk_sas': sasId,
      'ds_security_string': entity.description ?? '',
      'nr_security_string': entity.securityCode,
      'nr_token_index': entity.tokenIndex.toString(),
      'yn_used_code': entity.usedCode ? 1 : 0,
      'yn_cancel': 0,
      'dt_included': entity.dateIncluded ?? DateTime.now().millisecondsSinceEpoch,
    };

    return await _dbHelper.insert(AppConstants.tableSecurityString, values);
  }

  Future<List<SecurityStringEntity>> getAll() async {
    final maps = await _dbHelper.query(
      AppConstants.tableSecurityString,
      where: 'yn_cancel = ?',
      whereArgs: [0],
      orderBy: 'nr_token_index ASC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<SecurityStringEntity?> getById(int id) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSecurityString,
      where: 'pk_security_string = ? AND yn_cancel = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<List<SecurityStringEntity>> getBySasId(int sasId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSecurityString,
      where: 'fk_sas = ? AND yn_cancel = ?',
      whereArgs: [sasId, 0],
      orderBy: 'nr_token_index ASC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<SecurityStringEntity?> getByTokenIndex(int sasId, int tokenIndex) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSecurityString,
      where: 'fk_sas = ? AND nr_token_index = ? AND yn_cancel = ?',
      whereArgs: [sasId, tokenIndex.toString(), 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<List<SecurityStringEntity>> getUnusedBySasId(int sasId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSecurityString,
      where: 'fk_sas = ? AND yn_used_code = ? AND yn_cancel = ?',
      whereArgs: [sasId, 0, 0],
      orderBy: 'nr_token_index ASC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<List<SecurityStringEntity>> getUsedBySasId(int sasId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSecurityString,
      where: 'fk_sas = ? AND yn_used_code = ? AND yn_cancel = ?',
      whereArgs: [sasId, 1, 0],
      orderBy: 'nr_token_index ASC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<SecurityStringEntity?> getNextUnusedBySasId(int sasId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSecurityString,
      where: 'fk_sas = ? AND yn_used_code = ? AND yn_cancel = ?',
      whereArgs: [sasId, 0, 0],
      orderBy: 'nr_token_index ASC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<int> getUnusedCountBySasId(int sasId) async {
    return await _dbHelper.count(
      AppConstants.tableSecurityString,
      where: 'fk_sas = ? AND yn_used_code = ? AND yn_cancel = ?',
      whereArgs: [sasId, 0, 0],
    );
  }

  Future<int> markAsUsed(int id) async {
    return await _dbHelper.update(
      AppConstants.tableSecurityString,
      {'yn_used_code': 1},
      where: 'pk_security_string = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAsUnused(int id) async {
    return await _dbHelper.update(
      AppConstants.tableSecurityString,
      {'yn_used_code': 0},
      where: 'pk_security_string = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(SecurityStringEntity entity) async {
    final values = {
      'ds_security_string': entity.description ?? '',
      'nr_security_string': entity.securityCode,
      'nr_token_index': entity.tokenIndex.toString(),
      'yn_used_code': entity.usedCode ? 1 : 0,
    };

    return await _dbHelper.update(
      AppConstants.tableSecurityString,
      values,
      where: 'pk_security_string = ?',
      whereArgs: [entity.id],
    );
  }

  Future<int> delete(int id) async {
    // Soft delete by setting yn_cancel = 1
    return await _dbHelper.update(
      AppConstants.tableSecurityString,
      {'yn_cancel': 1},
      where: 'pk_security_string = ?',
      whereArgs: [id],
    );
  }

  Future<int> hardDelete(int id) async {
    return await _dbHelper.delete(
      AppConstants.tableSecurityString,
      where: 'pk_security_string = ?',
      whereArgs: [id],
    );
  }

  Future<int> count() async {
    return await _dbHelper.count(
      AppConstants.tableSecurityString,
      where: 'yn_cancel = ?',
      whereArgs: [0],
    );
  }

  Future<int> countBySasId(int sasId) async {
    return await _dbHelper.count(
      AppConstants.tableSecurityString,
      where: 'fk_sas = ? AND yn_cancel = ?',
      whereArgs: [sasId, 0],
    );
  }

  Future<void> deleteAll() async {
    await _dbHelper.update(
      AppConstants.tableSecurityString,
      {'yn_cancel': 1},
    );
  }

  Future<void> deleteBySasId(int sasId) async {
    await _dbHelper.update(
      AppConstants.tableSecurityString,
      {'yn_cancel': 1},
      where: 'fk_sas = ?',
      whereArgs: [sasId],
    );
  }

  Future<int> insertBatch(List<SecurityStringEntity> entities, int sasId) async {
    final db = await _dbHelper.database;
    int insertedCount = 0;

    await db.transaction((txn) async {
      for (final entity in entities) {
        final values = {
          'fk_sas': sasId,
          'ds_security_string': entity.description ?? '',
          'nr_security_string': entity.securityCode,
          'nr_token_index': entity.tokenIndex.toString(),
          'yn_used_code': entity.usedCode ? 1 : 0,
          'yn_cancel': 0,
          'dt_included': entity.dateIncluded ?? DateTime.now().millisecondsSinceEpoch,
        };

        await txn.insert(AppConstants.tableSecurityString, values);
        insertedCount++;
      }
    });

    return insertedCount;
  }

  SecurityStringEntity _mapToEntity(Map<String, dynamic> map) {
    return SecurityStringEntity(
      id: map['pk_security_string'] as int?,
      description: map['ds_security_string'] as String?,
      securityCode: map['nr_security_string'] as String,
      tokenIndex: int.parse(map['nr_token_index'] as String),
      usedCode: (map['yn_used_code'] as int) == 1,
      dateIncluded: map['dt_included'] as int?,
    );
  }
}
