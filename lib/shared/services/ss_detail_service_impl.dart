import '../../core/database/database_helper.dart';
import '../../core/database/dao/ss_detail_dao.dart';
import '../../core/database/dao/provision_info_dao.dart';
import '../../core/database/dao/sas_dao.dart';
import '../../core/database/dao/policy_dao.dart';
import '../../core/database/dao/security_string_dao.dart';
import '../models/models.dart';
import 'ss_detail_service.dart';

/// Implementation of SsDetailService
/// Converted from SsDetailBusinessImpl.java
class SsDetailServiceImpl extends SsDetailService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  late final SsDetailDao _ssDetailDao;
  late final ProvisionInfoDao _provisionInfoDao;
  late final SasDao _sasDao;
  late final PolicyDao _policyDao;
  late final SecurityStringDao _securityStringDao;

  SsDetailServiceImpl() {
    _ssDetailDao = SsDetailDao();
    _provisionInfoDao = ProvisionInfoDao();
    _sasDao = SasDao();
    _policyDao = PolicyDao();
    _securityStringDao = SecurityStringDao();
  }

  @override
  Future<void> delete(SsDetailEntity entity) async {
    try {
      await _ssDetailDao.delete(entity);
    } catch (e) {
      throw Exception('Failed to delete SsDetail entity: $e');
    }
  }

  @override
  Future<SsDetailEntity?> getFirst() async {
    try {
      return await _ssDetailDao.getFirst();
    } catch (e) {
      throw Exception('Failed to get first SsDetail entity: $e');
    }
  }

  @override
  Future<SsDetailEntity?> getById(int id) async {
    try {
      final entity = await _ssDetailDao.getById(id);
      if (entity != null) {
        // Load related entities
        entity.provisionInfoEntity = await _provisionInfoDao.getById(id);
        entity.sasEntity = await _sasDao.getBySsDetail(entity);
      }
      return entity;
    } catch (e) {
      throw Exception('Failed to get SsDetail entity by ID: $e');
    }
  }

  @override
  Future<SsDetailEntity?> getEntity(int id) async {
    try {
      return await _ssDetailDao.getById(id);
    } catch (e) {
      throw Exception('Failed to get SsDetail entity: $e');
    }
  }

  @override
  Future<void> insert(SsDetailEntity entity) async {
    try {
      final lastId = await _ssDetailDao.getLastId();
      final newId = lastId + 1;
      
      entity.id = newId;
      
      if (entity.provisionInfoEntity != null) {
        entity.provisionInfoEntity!.id = entity.id;
        entity.provisionInfoEntity!.ssDetailEntity = entity;
      }

      await _ssDetailDao.insert(entity);
      
      if (entity.provisionInfoEntity != null) {
        await _provisionInfoDao.insert(entity.provisionInfoEntity!);
      }
    } catch (e) {
      throw Exception('Failed to insert SsDetail entity: $e');
    }
  }

  @override
  Future<List<SsDetailEntity>> list() async {
    try {
      return await _ssDetailDao.getAll();
    } catch (e) {
      throw Exception('Failed to list SsDetail entities: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _ssDetailDao.count();
    } catch (e) {
      throw Exception('Failed to count SsDetail entities: $e');
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _provisionInfoDao.deleteAll();
      await _ssDetailDao.deleteAll();
    } catch (e) {
      throw Exception('Failed to delete all SsDetail entities: $e');
    }
  }

  @override
  Future<bool> existsBySiteId(String siteId) async {
    try {
      final entity = SsDetailEntity(siteId: siteId);
      return await _ssDetailDao.exists(entity);
    } catch (e) {
      throw Exception('Failed to check if SsDetail exists by site ID: $e');
    }
  }

  @override
  Future<bool> exists(SsDetailEntity entity) async {
    try {
      return await _ssDetailDao.exists(entity);
    } catch (e) {
      throw Exception('Failed to check if SsDetail exists: $e');
    }
  }

  @override
  Future<bool> hasNoCategory() async {
    try {
      final entities = await listNoCategory();
      return entities.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if has no category: $e');
    }
  }

  @override
  Future<List<SsDetailEntity>> listByProvisionType(ProvisionType provisionType) async {
    try {
      return await _ssDetailDao.getByProvisionType(provisionType);
    } catch (e) {
      throw Exception('Failed to list SsDetail entities by provision type: $e');
    }
  }

  @override
  Future<List<SsDetailEntity>> listByCategory(CategoryEntity category) async {
    try {
      return await _ssDetailDao.getByCategory(category);
    } catch (e) {
      throw Exception('Failed to list SsDetail entities by category: $e');
    }
  }

  @override
  Future<List<SsDetailEntity>> listNoCategory() async {
    try {
      return await _ssDetailDao.getWithNoCategory();
    } catch (e) {
      throw Exception('Failed to list SsDetail entities with no category: $e');
    }
  }

  @override
  Future<void> saveOrUpdate(ServerDetailDto dto) async {
    try {
      // Convert DTO to entity and save/update
      final entity = _convertFromDto(dto);
      
      final existingEntity = await _ssDetailDao.getBySiteId(entity.siteId!);
      if (existingEntity != null) {
        entity.id = existingEntity.id;
        await update(entity);
      } else {
        await insert(entity);
      }
    } catch (e) {
      throw Exception('Failed to save or update from DTO: $e');
    }
  }

  @override
  Future<void> update(SsDetailEntity entity) async {
    try {
      await _ssDetailDao.update(entity);
      
      if (entity.provisionInfoEntity != null) {
        await _provisionInfoDao.update(entity.provisionInfoEntity!);
      }
    } catch (e) {
      throw Exception('Failed to update SsDetail entity: $e');
    }
  }

  /// Convert ServerDetailDto to SsDetailEntity
  SsDetailEntity _convertFromDto(ServerDetailDto dto) {
    return SsDetailEntity(
      siteId: dto.siteId,
      hostname: dto.hostname,
      port: dto.port,
      connectionType: dto.connectionType,
      isUsingSsl: dto.isUsingSsl,
      // Add other fields as needed
    );
  }
}
