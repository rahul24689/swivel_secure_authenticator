import '../models/models.dart';
import 'abstract_service.dart';

/// Service interface for SsDetail operations
/// Converted from SsDetailBusiness.java
abstract class SsDetailService extends AbstractService<SsDetailEntity> {
  /// Count total entities
  Future<int> count();

  /// Delete all entities
  Future<void> deleteAll();

  /// Check if entity exists by site ID
  Future<bool> existsBySiteId(String siteId);

  /// Check if entity exists
  Future<bool> exists(SsDetailEntity entity);

  /// Get first entity
  Future<SsDetailEntity?> getFirst();

  /// Get entity by ID
  Future<SsDetailEntity?> getById(int id);

  /// Get entity by ID (alternative method)
  Future<SsDetailEntity?> getEntity(int id);

  /// Check if there are entities with no category
  Future<bool> hasNoCategory();

  /// List entities by provision type
  Future<List<SsDetailEntity>> listByProvisionType(ProvisionType provisionType);

  /// List entities by category
  Future<List<SsDetailEntity>> listByCategory(CategoryEntity category);

  /// List entities with no category
  Future<List<SsDetailEntity>> listNoCategory();

  /// Save or update from server detail DTO
  Future<void> saveOrUpdate(ServerDetailDto dto);

  /// Update entity
  Future<void> update(SsDetailEntity entity);
}

/// Provision type enumeration
enum ProvisionType {
  oath,
  securityString,
  push,
}
