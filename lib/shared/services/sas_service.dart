import '../models/models.dart';
import 'abstract_service.dart';

/// Service interface for SAS (Swivel Authentication Server) operations
/// Converted from SasBusiness.java
abstract class SasService extends AbstractService<SasEntity> {
  /// Delete all SAS entities
  Future<void> deleteAll();

  /// Check if SAS entity exists by username and provision code
  Future<bool> existsByUsernameAndProvisionCode(String username, String provisionCode);

  /// Check if SAS entity exists
  Future<bool> exists(SasEntity entity);

  /// Get SAS entity by SAS ID
  Future<SasEntity?> getBySasId(String sasId);

  /// Get SAS entity by username and SAS ID
  Future<SasEntity?> getByUsernameAndSasId(String username, String sasId);

  /// Get SAS entity by SsDetail entity
  Future<SasEntity?> getBySsDetail(SsDetailEntity ssDetailEntity);

  /// List SAS entities by SsDetail entity
  Future<List<SasEntity>> listBySsDetail(SsDetailEntity ssDetailEntity);
}
