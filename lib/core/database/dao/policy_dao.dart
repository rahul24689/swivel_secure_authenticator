import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../../shared/models/policy_entity.dart';
import '../../constants/app_constants.dart';

class PolicyDao {
  static const String _tableName = 'policies';

  /// Get database instance
  Future<Database> get _database async => await DatabaseHelper.instance.database;

  /// Insert a new policy
  Future<int> insert(PolicyEntity policy) async {
    final db = await _database;
    return await db.insert(_tableName, policy.toMap());
  }

  /// Insert or update a policy (upsert)
  Future<int> insertOrUpdate(PolicyEntity policy) async {
    final db = await _database;
    
    // Check if policy exists
    final existing = await getByPolicyIdAndSasId(policy.policyId, policy.sasId);
    
    if (existing != null) {
      // Update existing policy
      final updatedPolicy = policy.copyWith(
        id: existing.id,
        updatedAt: DateTime.now(),
      );
      await update(updatedPolicy);
      return existing.id!;
    } else {
      // Insert new policy
      return await insert(policy);
    }
  }

  /// Update an existing policy
  Future<int> update(PolicyEntity policy) async {
    final db = await _database;
    return await db.update(
      _tableName,
      policy.toMap(),
      where: 'id = ?',
      whereArgs: [policy.id],
    );
  }

  /// Delete a policy by ID
  Future<int> delete(int id) async {
    final db = await _database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get policy by ID
  Future<PolicyEntity?> getById(int id) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PolicyEntity.fromMap(maps.first);
    }
    return null;
  }

  /// Get policy by policy ID and SAS ID
  Future<PolicyEntity?> getByPolicyIdAndSasId(String policyId, int sasId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'policy_id = ? AND sas_id = ?',
      whereArgs: [policyId, sasId],
    );

    if (maps.isNotEmpty) {
      return PolicyEntity.fromMap(maps.first);
    }
    return null;
  }

  /// Get all policies for a specific SAS ID
  Future<List<PolicyEntity>> getBySasId(int sasId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'sas_id = ?',
      whereArgs: [sasId],
      orderBy: 'policy_id ASC',
    );

    return maps.map((map) => PolicyEntity.fromMap(map)).toList();
  }

  /// Get all policies
  Future<List<PolicyEntity>> getAll() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      orderBy: 'sas_id ASC, policy_id ASC',
    );

    return maps.map((map) => PolicyEntity.fromMap(map)).toList();
  }

  /// Get policies by policy ID (across all SAS accounts)
  Future<List<PolicyEntity>> getByPolicyId(String policyId) async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      where: 'policy_id = ?',
      whereArgs: [policyId],
      orderBy: 'sas_id ASC',
    );

    return maps.map((map) => PolicyEntity.fromMap(map)).toList();
  }

  /// Check if a policy exists
  Future<bool> exists(String policyId, int sasId) async {
    final policy = await getByPolicyIdAndSasId(policyId, sasId);
    return policy != null;
  }

  /// Get count of policies for a SAS ID
  Future<int> getCountBySasId(int sasId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE sas_id = ?',
      [sasId],
    );
    return result.first['count'] as int;
  }

  /// Delete all policies for a SAS ID
  Future<int> deleteBySasId(int sasId) async {
    final db = await _database;
    return await db.delete(
      _tableName,
      where: 'sas_id = ?',
      whereArgs: [sasId],
    );
  }

  /// Batch insert policies
  Future<void> insertBatch(List<PolicyEntity> policies) async {
    final db = await _database;
    final batch = db.batch();

    for (final policy in policies) {
      batch.insert(_tableName, policy.toMap());
    }

    await batch.commit(noResult: true);
  }

  /// Update policy content
  Future<int> updateContent(String policyId, int sasId, String content) async {
    final db = await _database;
    return await db.update(
      _tableName,
      {
        'content': content,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'policy_id = ? AND sas_id = ?',
      whereArgs: [policyId, sasId],
    );
  }

  /// Get policy content
  Future<String?> getPolicyContent(String policyId, int sasId) async {
    final policy = await getByPolicyIdAndSasId(policyId, sasId);
    return policy?.content;
  }

  /// Check if policy is enabled (content = 'ON')
  Future<bool> isPolicyEnabled(String policyId, int sasId) async {
    final content = await getPolicyContent(policyId, sasId);
    return content?.toUpperCase() == 'ON';
  }

  /// Enable/disable a policy
  Future<int> setPolicyEnabled(String policyId, int sasId, bool enabled) async {
    final content = enabled ? 'ON' : 'OFF';
    
    // Check if policy exists
    if (await exists(policyId, sasId)) {
      return await updateContent(policyId, sasId, content);
    } else {
      // Create new policy
      final policy = PolicyEntity(
        policyId: policyId,
        content: content,
        sasId: sasId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await insert(policy);
    }
  }

  /// Get all unique policy IDs
  Future<List<String>> getAllPolicyIds() async {
    final db = await _database;
    final maps = await db.query(
      _tableName,
      columns: ['policy_id'],
      distinct: true,
      orderBy: 'policy_id ASC',
    );

    return maps.map((map) => map['policy_id'] as String).toList();
  }

  /// Clear all policies
  Future<int> clear() async {
    final db = await _database;
    return await db.delete(_tableName);
  }
}
