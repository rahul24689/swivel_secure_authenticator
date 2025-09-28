import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import 'provision_info_entity.dart';
import 'sas_entity.dart';

part 'ss_detail_entity.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class SsDetailEntity {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String hostname;

  @HiveField(3)
  final bool usingSsl;

  @HiveField(4)
  final bool pushSupport;

  @HiveField(5)
  final bool local;

  @HiveField(6)
  final bool pin;

  @HiveField(7)
  final bool oath;

  @HiveField(8)
  final int port;

  @HiveField(9)
  final String connectionType;

  @HiveField(10)
  final String siteId;

  @HiveField(11)
  final int? dateIncluded;

  @HiveField(12)
  final ProvisionInfoEntity? provisionInfoEntity;

  @HiveField(13)
  final SasEntity? sasEntity;

  @HiveField(14)
  final List<SasEntity>? sasList;

  @HiveField(15)
  final int sasId;

  @HiveField(16)
  final String securityString;

  @HiveField(17)
  final String? pinValue;

  @HiveField(18)
  final bool isPinFree;

  @HiveField(19)
  final bool isActive;

  @HiveField(20)
  final DateTime createdAt;

  @HiveField(21)
  final DateTime updatedAt;

  const SsDetailEntity({
    this.id,
    this.description,
    required this.hostname,
    this.usingSsl = false,
    this.pushSupport = false,
    this.local = false,
    this.pin = false,
    this.oath = false,
    required this.port,
    required this.connectionType,
    required this.siteId,
    this.dateIncluded,
    this.provisionInfoEntity,
    this.sasEntity,
    this.sasList,
    required this.sasId,
    required this.securityString,
    this.pinValue,
    this.isPinFree = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SsDetailEntity.fromJson(Map<String, dynamic> json) =>
      _$SsDetailEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SsDetailEntityToJson(this);

  SsDetailEntity copyWith({
    int? id,
    String? description,
    String? hostname,
    bool? usingSsl,
    bool? pushSupport,
    bool? local,
    bool? pin,
    bool? oath,
    int? port,
    String? connectionType,
    String? siteId,
    int? dateIncluded,
    ProvisionInfoEntity? provisionInfoEntity,
    SasEntity? sasEntity,
    List<SasEntity>? sasList,
    int? sasId,
    String? securityString,
    String? pinValue,
    bool? isPinFree,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SsDetailEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      hostname: hostname ?? this.hostname,
      usingSsl: usingSsl ?? this.usingSsl,
      pushSupport: pushSupport ?? this.pushSupport,
      local: local ?? this.local,
      pin: pin ?? this.pin,
      oath: oath ?? this.oath,
      port: port ?? this.port,
      connectionType: connectionType ?? this.connectionType,
      siteId: siteId ?? this.siteId,
      dateIncluded: dateIncluded ?? this.dateIncluded,
      provisionInfoEntity: provisionInfoEntity ?? this.provisionInfoEntity,
      sasEntity: sasEntity ?? this.sasEntity,
      sasList: sasList ?? this.sasList,
      sasId: sasId ?? this.sasId,
      securityString: securityString ?? this.securityString,
      pinValue: pinValue ?? this.pinValue,
      isPinFree: isPinFree ?? this.isPinFree,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SsDetailEntity &&
        other.id == id &&
        other.hostname == hostname &&
        other.siteId == siteId;
  }

  @override
  int get hashCode => Object.hash(id, hostname, siteId);

  @override
  String toString() {
    return 'SsDetailEntity(id: $id, hostname: $hostname, siteId: $siteId)';
  }
}
