import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import 'ss_detail_entity.dart';
import 'policy_entity.dart';
import 'security_string_entity.dart';

part 'sas_entity.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class SasEntity {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String provisionCode;

  @HiveField(4)
  final String? pushId;

  @HiveField(5)
  final String? sasId;

  @HiveField(6)
  final int? dateIncluded;

  @HiveField(7)
  final SsDetailEntity? ssDetailEntity;

  @HiveField(8)
  final List<PolicyEntity>? policyList;

  @HiveField(9)
  final List<SecurityStringEntity>? securityStringList;

  @HiveField(10)
  final String accountName;

  @HiveField(11)
  final String serverUrl;

  @HiveField(12)
  final bool isActive;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  const SasEntity({
    this.id,
    this.description,
    required this.username,
    required this.provisionCode,
    this.pushId,
    this.sasId,
    this.dateIncluded,
    this.ssDetailEntity,
    this.policyList,
    this.securityStringList,
    required this.accountName,
    required this.serverUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SasEntity.fromJson(Map<String, dynamic> json) =>
      _$SasEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SasEntityToJson(this);

  SasEntity copyWith({
    int? id,
    String? description,
    String? username,
    String? provisionCode,
    String? pushId,
    String? sasId,
    int? dateIncluded,
    SsDetailEntity? ssDetailEntity,
    List<PolicyEntity>? policyList,
    List<SecurityStringEntity>? securityStringList,
    String? accountName,
    String? serverUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SasEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      username: username ?? this.username,
      provisionCode: provisionCode ?? this.provisionCode,
      pushId: pushId ?? this.pushId,
      sasId: sasId ?? this.sasId,
      dateIncluded: dateIncluded ?? this.dateIncluded,
      ssDetailEntity: ssDetailEntity ?? this.ssDetailEntity,
      policyList: policyList ?? this.policyList,
      securityStringList: securityStringList ?? this.securityStringList,
      accountName: accountName ?? this.accountName,
      serverUrl: serverUrl ?? this.serverUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SasEntity &&
        other.id == id &&
        other.username == username &&
        other.provisionCode == provisionCode;
  }

  @override
  int get hashCode => Object.hash(id, username, provisionCode);

  @override
  String toString() {
    return 'SasEntity(id: $id, username: $username, provisionCode: $provisionCode)';
  }
}
