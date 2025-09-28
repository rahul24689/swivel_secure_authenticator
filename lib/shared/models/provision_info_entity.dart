import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'provision_info_entity.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class ProvisionInfoEntity {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String siteId;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String provisionCode;

  @HiveField(5)
  final int? dateIncluded;

  const ProvisionInfoEntity({
    this.id,
    this.description,
    required this.siteId,
    required this.username,
    required this.provisionCode,
    this.dateIncluded,
  });

  factory ProvisionInfoEntity.fromJson(Map<String, dynamic> json) =>
      _$ProvisionInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProvisionInfoEntityToJson(this);

  ProvisionInfoEntity copyWith({
    int? id,
    String? description,
    String? siteId,
    String? username,
    String? provisionCode,
    int? dateIncluded,
  }) {
    return ProvisionInfoEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      siteId: siteId ?? this.siteId,
      username: username ?? this.username,
      provisionCode: provisionCode ?? this.provisionCode,
      dateIncluded: dateIncluded ?? this.dateIncluded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProvisionInfoEntity &&
        other.id == id &&
        other.siteId == siteId &&
        other.username == username;
  }

  @override
  int get hashCode => Object.hash(id, siteId, username);

  @override
  String toString() {
    return 'ProvisionInfoEntity(id: $id, siteId: $siteId, username: $username)';
  }
}
