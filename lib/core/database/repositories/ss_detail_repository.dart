import '../dao/ss_detail_dao.dart';
import '../dao/sas_dao.dart';
import '../../../shared/models/models.dart';

class SsDetailRepository {
  final SsDetailDao _ssDetailDao = SsDetailDao();
  final SasDao _sasDao = SasDao();

  // Basic CRUD operations
  Future<int> insert(SsDetailEntity entity) async {
    return await _ssDetailDao.insert(entity);
  }

  Future<List<SsDetailEntity>> getAll() async {
    return await _ssDetailDao.getAll();
  }

  Future<SsDetailEntity?> getById(int id) async {
    return await _ssDetailDao.getById(id);
  }

  Future<SsDetailEntity?> getBySiteId(String siteId) async {
    return await _ssDetailDao.getBySiteId(siteId);
  }

  Future<List<SsDetailEntity>> getByHostname(String hostname) async {
    return await _ssDetailDao.getByHostname(hostname);
  }

  Future<int> update(SsDetailEntity entity) async {
    return await _ssDetailDao.update(entity);
  }

  Future<int> delete(int id) async {
    return await _ssDetailDao.delete(id);
  }

  Future<int> count() async {
    return await _ssDetailDao.count();
  }

  // Business logic methods
  Future<List<SsDetailEntity>> getOathEnabled() async {
    return await _ssDetailDao.getOathEnabled();
  }

  Future<List<SsDetailEntity>> getLocalEnabled() async {
    return await _ssDetailDao.getLocalEnabled();
  }

  Future<List<SsDetailEntity>> getAllWithSasEntities() async {
    final ssDetailList = await _ssDetailDao.getAll();
    
    for (int i = 0; i < ssDetailList.length; i++) {
      final ssDetail = ssDetailList[i];
      if (ssDetail.id != null) {
        final sasList = await _sasDao.getBySsDetailId(ssDetail.id!);
        final latestSas = await _sasDao.getLatestBySsDetailId(ssDetail.id!);
        
        ssDetailList[i] = ssDetail.copyWith(
          sasList: sasList,
          sasEntity: latestSas,
        );
      }
    }
    
    return ssDetailList;
  }

  Future<SsDetailEntity?> getByIdWithSasEntities(int id) async {
    final ssDetail = await _ssDetailDao.getById(id);
    if (ssDetail?.id != null) {
      final sasList = await _sasDao.getBySsDetailId(ssDetail!.id!);
      final latestSas = await _sasDao.getLatestBySsDetailId(ssDetail.id!);
      
      return ssDetail.copyWith(
        sasList: sasList,
        sasEntity: latestSas,
      );
    }
    return ssDetail;
  }

  Future<List<SsDetailEntity>> getNoCategory() async {
    // This would need to be implemented with category relationships
    // For now, return all entities
    return await _ssDetailDao.getAll();
  }

  Future<List<SsDetailEntity>> getByCategory(int categoryId) async {
    // This would need to be implemented with category relationships
    // For now, return empty list
    return [];
  }

  Future<bool> exists(String siteId) async {
    final entity = await _ssDetailDao.getBySiteId(siteId);
    return entity != null;
  }

  Future<bool> existsByHostname(String hostname) async {
    final entities = await _ssDetailDao.getByHostname(hostname);
    return entities.isNotEmpty;
  }

  Future<void> deleteAll() async {
    await _ssDetailDao.deleteAll();
  }

  Future<SsDetailEntity> insertAndReturn(SsDetailEntity entity) async {
    final id = await _ssDetailDao.insert(entity);
    final insertedEntity = await _ssDetailDao.getById(id);
    return insertedEntity!;
  }

  Future<List<SsDetailEntity>> getProvisionedDevices() async {
    final allDevices = await _ssDetailDao.getAll();
    final provisionedDevices = <SsDetailEntity>[];

    for (final device in allDevices) {
      if (device.id != null) {
        final sasCount = await _sasDao.countBySsDetailId(device.id!);
        if (sasCount > 0) {
          provisionedDevices.add(device);
        }
      }
    }

    return provisionedDevices;
  }

  Future<List<SsDetailEntity>> getUnprovisionedDevices() async {
    final allDevices = await _ssDetailDao.getAll();
    final unprovisionedDevices = <SsDetailEntity>[];

    for (final device in allDevices) {
      if (device.id != null) {
        final sasCount = await _sasDao.countBySsDetailId(device.id!);
        if (sasCount == 0) {
          unprovisionedDevices.add(device);
        }
      }
    }

    return unprovisionedDevices;
  }

  Future<bool> isProvisioned(int id) async {
    final sasCount = await _sasDao.countBySsDetailId(id);
    return sasCount > 0;
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final totalCount = await _ssDetailDao.count();
    final oathCount = (await _ssDetailDao.getOathEnabled()).length;
    final localCount = (await _ssDetailDao.getLocalEnabled()).length;
    final provisionedCount = (await getProvisionedDevices()).length;

    return {
      'total': totalCount,
      'oath_enabled': oathCount,
      'local_enabled': localCount,
      'provisioned': provisionedCount,
      'unprovisioned': totalCount - provisionedCount,
    };
  }
}
