import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'policy_entity.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class PolicyEntity {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String policyId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final int sasId;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  const PolicyEntity({
    this.id,
    required this.policyId,
    required this.content,
    this.description,
    required this.sasId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PolicyEntity.fromJson(Map<String, dynamic> json) =>
      _$PolicyEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyEntityToJson(this);

  PolicyEntity copyWith({
    int? id,
    String? policyId,
    String? content,
    String? description,
    int? sasId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PolicyEntity(
      id: id ?? this.id,
      policyId: policyId ?? this.policyId,
      content: content ?? this.content,
      description: description ?? this.description,
      sasId: sasId ?? this.sasId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PolicyEntity &&
        other.id == id &&
        other.policyId == policyId;
  }

  @override
  int get hashCode => Object.hash(id, policyId);

  @override
  String toString() {
    return 'PolicyEntity(id: $id, policyId: $policyId, content: $content, sasId: $sasId)';
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'policy_id': policyId,
      'content': content,
      'description': description,
      'sas_id': sasId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create from database map
  factory PolicyEntity.fromMap(Map<String, dynamic> map) {
    return PolicyEntity(
      id: map['id'] as int?,
      policyId: map['policy_id'] as String,
      content: map['content'] as String,
      description: map['description'] as String?,
      sasId: map['sas_id'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
