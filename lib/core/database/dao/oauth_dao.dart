import '../database_helper.dart';
import '../../../shared/models/models.dart';
import '../../constants/app_constants.dart';

class OAuthDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(OAuthEntity entity) async {
    final values = {
      'ds_oauth': entity.description ?? '',
      'ds_issuer': entity.issuer,
      'ds_account': entity.account,
      'ds_secret': entity.secret,
      'ds_username': entity.username,
      'ds_provision_code': entity.provisionCode,
      'yn_pin': entity.pin ? 1 : 0,
      'yn_cancel': 0,
      'dt_included': entity.dateIncluded ?? DateTime.now().millisecondsSinceEpoch,
    };

    return await _dbHelper.insert(AppConstants.tableOAuth, values);
  }

  Future<List<OAuthEntity>> getAll() async {
    final maps = await _dbHelper.query(
      AppConstants.tableOAuth,
      where: 'yn_cancel = ?',
      whereArgs: [0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<OAuthEntity?> getById(int id) async {
    final maps = await _dbHelper.query(
      AppConstants.tableOAuth,
      where: 'pk_oauth = ? AND yn_cancel = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<OAuthEntity?> getByIssuerAndAccount(String issuer, String account) async {
    final maps = await _dbHelper.query(
      AppConstants.tableOAuth,
      where: 'ds_issuer = ? AND ds_account = ? AND yn_cancel = ?',
      whereArgs: [issuer, account, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<List<OAuthEntity>> getByIssuer(String issuer) async {
    final maps = await _dbHelper.query(
      AppConstants.tableOAuth,
      where: 'ds_issuer = ? AND yn_cancel = ?',
      whereArgs: [issuer, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<List<OAuthEntity>> getByUsername(String username) async {
    final maps = await _dbHelper.query(
      AppConstants.tableOAuth,
      where: 'ds_username = ? AND yn_cancel = ?',
      whereArgs: [username, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<OAuthEntity?> getByUsernameAndProvisionCode(String username, String provisionCode) async {
    final maps = await _dbHelper.query(
      AppConstants.tableOAuth,
      where: 'ds_username = ? AND ds_provision_code = ? AND yn_cancel = ?',
      whereArgs: [username, provisionCode, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToEntity(maps.first);
    }
    return null;
  }

  Future<List<OAuthEntity>> getPinEnabled() async {
    final maps = await _dbHelper.query(
      AppConstants.tableOAuth,
      where: 'yn_pin = ? AND yn_cancel = ?',
      whereArgs: [1, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<List<OAuthEntity>> getPinDisabled() async {
    final maps = await _dbHelper.query(
      AppConstants.tableOAuth,
      where: 'yn_pin = ? AND yn_cancel = ?',
      whereArgs: [0, 0],
      orderBy: 'dt_included DESC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  Future<int> update(OAuthEntity entity) async {
    final values = {
      'ds_oauth': entity.description ?? '',
      'ds_issuer': entity.issuer,
      'ds_account': entity.account,
      'ds_secret': entity.secret,
      'ds_username': entity.username,
      'ds_provision_code': entity.provisionCode,
      'yn_pin': entity.pin ? 1 : 0,
    };

    return await _dbHelper.update(
      AppConstants.tableOAuth,
      values,
      where: 'pk_oauth = ?',
      whereArgs: [entity.id],
    );
  }

  Future<int> updateSecret(int id, String secret) async {
    return await _dbHelper.update(
      AppConstants.tableOAuth,
      {'ds_secret': secret},
      where: 'pk_oauth = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePinStatus(int id, bool pinEnabled) async {
    return await _dbHelper.update(
      AppConstants.tableOAuth,
      {'yn_pin': pinEnabled ? 1 : 0},
      where: 'pk_oauth = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    // Soft delete by setting yn_cancel = 1
    return await _dbHelper.update(
      AppConstants.tableOAuth,
      {'yn_cancel': 1},
      where: 'pk_oauth = ?',
      whereArgs: [id],
    );
  }

  Future<int> hardDelete(int id) async {
    return await _dbHelper.delete(
      AppConstants.tableOAuth,
      where: 'pk_oauth = ?',
      whereArgs: [id],
    );
  }

  Future<int> count() async {
    return await _dbHelper.count(
      AppConstants.tableOAuth,
      where: 'yn_cancel = ?',
      whereArgs: [0],
    );
  }

  Future<int> countByIssuer(String issuer) async {
    return await _dbHelper.count(
      AppConstants.tableOAuth,
      where: 'ds_issuer = ? AND yn_cancel = ?',
      whereArgs: [issuer, 0],
    );
  }

  Future<void> deleteAll() async {
    await _dbHelper.update(
      AppConstants.tableOAuth,
      {'yn_cancel': 1},
    );
  }

  Future<void> deleteByIssuer(String issuer) async {
    await _dbHelper.update(
      AppConstants.tableOAuth,
      {'yn_cancel': 1},
      where: 'ds_issuer = ?',
      whereArgs: [issuer],
    );
  }

  Future<bool> exists(String issuer, String account) async {
    final count = await _dbHelper.count(
      AppConstants.tableOAuth,
      where: 'ds_issuer = ? AND ds_account = ? AND yn_cancel = ?',
      whereArgs: [issuer, account, 0],
    );
    return count > 0;
  }

  OAuthEntity _mapToEntity(Map<String, dynamic> map) {
    return OAuthEntity(
      id: map['pk_oauth'] as int?,
      description: map['ds_oauth'] as String?,
      issuer: map['ds_issuer'] as String,
      account: map['ds_account'] as String,
      secret: map['ds_secret'] as String,
      username: map['ds_username'] as String,
      provisionCode: map['ds_provision_code'] as String,
      pin: (map['yn_pin'] as int) == 1,
      dateIncluded: map['dt_included'] as int?,
      algorithm: map['ds_algorithm'] as String? ?? 'SHA1',
      digits: map['nr_digits'] as int? ?? 6,
      period: map['nr_period'] as int? ?? 30,
      label: map['ds_label'] as String? ?? map['ds_account'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['dt_created'] as int? ?? 0) * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['dt_updated'] as int? ?? 0) * 1000),
    );
  }
}
