import '../database_helper.dart';
import '../../../shared/models/models.dart';
import '../../constants/app_constants.dart';

class SasDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(SasEntity entity, int ssDetailId) async {
    final values = {
      'fk_ss_detail': ssDetailId,
      'ds_sas': entity.description ?? '',
      'ds_username': entity.username,
      'ds_provision_code': entity.provisionCode,
      'ds_push_id': entity.pushId,
      'ds_sas_id': entity.sasId,
      'yn_cancel': 0,
      'dt_included': entity.dateIncluded ?? DateTime.now().millisecondsSinceEpoch,
    };

    return await _dbHelper.insert(AppConstants.tableSas, values);
  }

  Future<List<SasEntity>> getAll() async {
    final maps = await _dbHelper.query(
      AppConstants.tableSas,
      where: 'yn_cancel = ?',
      whereArgs: [0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<SasEntity?> getById(int id) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSas,
      where: 'pk_sas = ? AND yn_cancel = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<SasEntity?> getByUsernameAndProvisionCode(String username, String provisionCode) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSas,
      where: 'ds_username = ? AND ds_provision_code = ? AND yn_cancel = ?',
      whereArgs: [username, provisionCode, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<List<SasEntity>> getBySsDetailId(int ssDetailId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSas,
      where: 'fk_ss_detail = ? AND yn_cancel = ?',
      whereArgs: [ssDetailId, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<SasEntity?> getLatestBySsDetailId(int ssDetailId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSas,
      where: 'fk_ss_detail = ? AND yn_cancel = ?',
      whereArgs: [ssDetailId, 0],
      orderBy: 'dt_included DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<List<SasEntity>> getByUsername(String username) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSas,
      where: 'ds_username = ? AND yn_cancel = ?',
      whereArgs: [username, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<List<SasEntity>> getByPushId(String pushId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSas,
      where: 'ds_push_id = ? AND yn_cancel = ?',
      whereArgs: [pushId, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<int> update(SasEntity entity) async {
    final values = {
      'ds_sas': entity.description ?? '',
      'ds_username': entity.username,
      'ds_provision_code': entity.provisionCode,
      'ds_push_id': entity.pushId,
      'ds_sas_id': entity.sasId,
    };

    return await _dbHelper.update(
      AppConstants.tableSas,
      values,
      where: 'pk_sas = ?',
      whereArgs: [entity.id],
    );
  }

  Future<int> updatePushId(int id, String pushId) async {
    return await _dbHelper.update(
      AppConstants.tableSas,
      {'ds_push_id': pushId},
      where: 'pk_sas = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    // Soft delete by setting yn_cancel = 1
    return await _dbHelper.update(
      AppConstants.tableSas,
      {'yn_cancel': 1},
      where: 'pk_sas = ?',
      whereArgs: [id],
    );
  }

  Future<int> hardDelete(int id) async {
    return await _dbHelper.delete(
      AppConstants.tableSas,
      where: 'pk_sas = ?',
      whereArgs: [id],
    );
  }

  Future<int> count() async {
    return await _dbHelper.count(
      AppConstants.tableSas,
      where: 'yn_cancel = ?',
      whereArgs: [0],
    );
  }

  Future<int> countBySsDetailId(int ssDetailId) async {
    return await _dbHelper.count(
      AppConstants.tableSas,
      where: 'fk_ss_detail = ? AND yn_cancel = ?',
      whereArgs: [ssDetailId, 0],
    );
  }

  Future<void> deleteAll() async {
    await _dbHelper.update(
      AppConstants.tableSas,
      {'yn_cancel': 1},
    );
  }

  Future<void> deleteBySsDetailId(int ssDetailId) async {
    await _dbHelper.update(
      AppConstants.tableSas,
      {'yn_cancel': 1},
      where: 'fk_ss_detail = ?',
      whereArgs: [ssDetailId],
    );
  }

  SasEntity _mapToEntity(Map<String, dynamic> map) {
    return SasEntity(
      id: map['pk_sas'] as int?,
      description: map['ds_sas'] as String?,
      username: map['ds_username'] as String,
      provisionCode: map['ds_provision_code'] as String,
      pushId: map['ds_push_id'] as String?,
      sasId: map['ds_sas_id'] as String?,
      dateIncluded: map['dt_included'] as int?,
      accountName: map['ds_account_name'] as String? ?? map['ds_username'] as String,
      serverUrl: map['ds_server_url'] as String? ?? '',
      isActive: (map['bl_active'] as int? ?? 1) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['dt_created'] as int? ?? 0) * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['dt_updated'] as int? ?? 0) * 1000),
    );
  }
}
