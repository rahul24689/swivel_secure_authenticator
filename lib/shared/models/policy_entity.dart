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
  final int? dateIncluded;

  const PolicyEntity({
    this.id,
    required this.policyId,
    required this.content,
    this.description,
    this.dateIncluded,
  });

  factory PolicyEntity.fromJson(Map<String, dynamic> json) =>
      _$PolicyEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyEntityToJson(this);

  PolicyEntity copyWith({
    int? id,
    String? policyId,
    String? content,
    String? description,
    int? dateIncluded,
  }) {
    return PolicyEntity(
      id: id ?? this.id,
      policyId: policyId ?? this.policyId,
      content: content ?? this.content,
      description: description ?? this.description,
      dateIncluded: dateIncluded ?? this.dateIncluded,
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
    return 'PolicyEntity(id: $id, policyId: $policyId, content: $content)';
  }
}
