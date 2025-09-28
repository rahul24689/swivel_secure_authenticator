import '../database_helper.dart';
import '../../../shared/models/models.dart';
import '../../constants/app_constants.dart';

class SsDetailDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(SsDetailEntity entity) async {
    final values = {
      'ds_ss_detail': entity.hostname,
      'ds_hostname': entity.hostname,
      'yn_using_ssl': entity.usingSsl ? 1 : 0,
      'yn_push_support': entity.pushSupport ? 1 : 0,
      'yn_local': entity.local ? 1 : 0,
      'yn_pin': entity.pin ? 1 : 0,
      'yn_oath': entity.oath ? 1 : 0,
      'nr_port': entity.port,
      'ds_connection_type': entity.connectionType,
      'nr_site_id': entity.siteId,
      'yn_cancel': 0,
      'dt_included': entity.dateIncluded ?? DateTime.now().millisecondsSinceEpoch,
    };

    return await _dbHelper.insert(AppConstants.tableSsDetail, values);
  }

  Future<List<SsDetailEntity>> getAll() async {
    final maps = await _dbHelper.query(
      AppConstants.tableSsDetail,
      where: 'yn_cancel = ?',
      whereArgs: [0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<List<SsDetailEntity>> getBySasId(int sasId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSsDetail,
      where: 'fk_sas = ? AND yn_cancel = ?',
      whereArgs: [sasId, 0],
      orderBy: 'dt_included DESC',
    );
    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<SsDetailEntity?> getById(int id) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSsDetail,
      where: 'pk_ss_detail = ? AND yn_cancel = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<SsDetailEntity?> getBySiteId(String siteId) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSsDetail,
      where: 'nr_site_id = ? AND yn_cancel = ?',
      whereArgs: [siteId, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<List<SsDetailEntity>> getByHostname(String hostname) async {
    final maps = await _dbHelper.query(
      AppConstants.tableSsDetail,
      where: 'ds_hostname = ? AND yn_cancel = ?',
      whereArgs: [hostname, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<List<SsDetailEntity>> getOathEnabled() async {
    final maps = await _dbHelper.query(
      AppConstants.tableSsDetail,
      where: 'yn_oath = ? AND yn_cancel = ?',
      whereArgs: [1, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<List<SsDetailEntity>> getLocalEnabled() async {
    final maps = await _dbHelper.query(
      AppConstants.tableSsDetail,
      where: 'yn_local = ? AND yn_cancel = ?',
      whereArgs: [1, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<int> update(SsDetailEntity entity) async {
    final values = {
      'ds_ss_detail': entity.hostname,
      'ds_hostname': entity.hostname,
      'yn_using_ssl': entity.usingSsl ? 1 : 0,
      'yn_push_support': entity.pushSupport ? 1 : 0,
      'yn_local': entity.local ? 1 : 0,
      'yn_pin': entity.pin ? 1 : 0,
      'yn_oath': entity.oath ? 1 : 0,
      'nr_port': entity.port,
      'ds_connection_type': entity.connectionType,
      'nr_site_id': entity.siteId,
    };

    return await _dbHelper.update(
      AppConstants.tableSsDetail,
      values,
      where: 'pk_ss_detail = ?',
      whereArgs: [entity.id],
    );
  }

  Future<int> delete(int id) async {
    // Soft delete by setting yn_cancel = 1
    return await _dbHelper.update(
      AppConstants.tableSsDetail,
      {'yn_cancel': 1},
      where: 'pk_ss_detail = ?',
      whereArgs: [id],
    );
  }

  Future<int> hardDelete(int id) async {
    return await _dbHelper.delete(
      AppConstants.tableSsDetail,
      where: 'pk_ss_detail = ?',
      whereArgs: [id],
    );
  }

  Future<int> count() async {
    return await _dbHelper.count(
      AppConstants.tableSsDetail,
      where: 'yn_cancel = ?',
      whereArgs: [0],
    );
  }

  Future<void> deleteAll() async {
    await _dbHelper.update(
      AppConstants.tableSsDetail,
      {'yn_cancel': 1},
    );
  }

  SsDetailEntity _mapToEntity(Map<String, dynamic> map) {
    return SsDetailEntity(
      id: map['pk_ss_detail'] as int?,
      description: map['ds_ss_detail'] as String?,
      hostname: map['ds_hostname'] as String,
      usingSsl: (map['yn_using_ssl'] as int) == 1,
      pushSupport: (map['yn_push_support'] as int) == 1,
      local: (map['yn_local'] as int) == 1,
      pin: (map['yn_pin'] as int) == 1,
      oath: (map['yn_oath'] as int) == 1,
      port: map['nr_port'] as int,
      connectionType: map['ds_connection_type'] as String,
      siteId: map['nr_site_id'] as String,
      dateIncluded: map['dt_included'] as int?,
      sasId: map['fk_sas'] as int? ?? 0,
      securityString: map['ds_security_string'] as String? ?? '',
      pinValue: map['ds_pin_value'] as String?,
      isPinFree: (map['bl_pin_free'] as int? ?? 1) == 1,
      isActive: (map['bl_active'] as int? ?? 1) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['dt_created'] as int? ?? 0) * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['dt_updated'] as int? ?? 0) * 1000),
    );
  }
}
