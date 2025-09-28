// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ss_detail_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SsDetailEntityAdapter extends TypeAdapter<SsDetailEntity> {
  @override
  final int typeId = 0;

  @override
  SsDetailEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SsDetailEntity(
      id: fields[0] as int?,
      description: fields[1] as String?,
      hostname: fields[2] as String,
      usingSsl: fields[3] as bool,
      pushSupport: fields[4] as bool,
      local: fields[5] as bool,
      pin: fields[6] as bool,
      oath: fields[7] as bool,
      port: fields[8] as int,
      connectionType: fields[9] as String,
      siteId: fields[10] as String,
      dateIncluded: fields[11] as int?,
      provisionInfoEntity: fields[12] as ProvisionInfoEntity?,
      sasEntity: fields[13] as SasEntity?,
      sasList: (fields[14] as List?)?.cast<SasEntity>(),
      sasId: fields[15] as int,
      securityString: fields[16] as String,
      pinValue: fields[17] as String?,
      isPinFree: fields[18] as bool,
      isActive: fields[19] as bool,
      createdAt: fields[20] as DateTime,
      updatedAt: fields[21] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SsDetailEntity obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.hostname)
      ..writeByte(3)
      ..write(obj.usingSsl)
      ..writeByte(4)
      ..write(obj.pushSupport)
      ..writeByte(5)
      ..write(obj.local)
      ..writeByte(6)
      ..write(obj.pin)
      ..writeByte(7)
      ..write(obj.oath)
      ..writeByte(8)
      ..write(obj.port)
      ..writeByte(9)
      ..write(obj.connectionType)
      ..writeByte(10)
      ..write(obj.siteId)
      ..writeByte(11)
      ..write(obj.dateIncluded)
      ..writeByte(12)
      ..write(obj.provisionInfoEntity)
      ..writeByte(13)
      ..write(obj.sasEntity)
      ..writeByte(14)
      ..write(obj.sasList)
      ..writeByte(15)
      ..write(obj.sasId)
      ..writeByte(16)
      ..write(obj.securityString)
      ..writeByte(17)
      ..write(obj.pinValue)
      ..writeByte(18)
      ..write(obj.isPinFree)
      ..writeByte(19)
      ..write(obj.isActive)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SsDetailEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SsDetailEntity _$SsDetailEntityFromJson(Map<String, dynamic> json) =>
    SsDetailEntity(
      id: (json['id'] as num?)?.toInt(),
      description: json['description'] as String?,
      hostname: json['hostname'] as String,
      usingSsl: json['usingSsl'] as bool? ?? false,
      pushSupport: json['pushSupport'] as bool? ?? false,
      local: json['local'] as bool? ?? false,
      pin: json['pin'] as bool? ?? false,
      oath: json['oath'] as bool? ?? false,
      port: (json['port'] as num).toInt(),
      connectionType: json['connectionType'] as String,
      siteId: json['siteId'] as String,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
      provisionInfoEntity: json['provisionInfoEntity'] == null
          ? null
          : ProvisionInfoEntity.fromJson(
              json['provisionInfoEntity'] as Map<String, dynamic>),
      sasEntity: json['sasEntity'] == null
          ? null
          : SasEntity.fromJson(json['sasEntity'] as Map<String, dynamic>),
      sasList: (json['sasList'] as List<dynamic>?)
          ?.map((e) => SasEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      sasId: (json['sasId'] as num).toInt(),
      securityString: json['securityString'] as String,
      pinValue: json['pinValue'] as String?,
      isPinFree: json['isPinFree'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SsDetailEntityToJson(SsDetailEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'hostname': instance.hostname,
      'usingSsl': instance.usingSsl,
      'pushSupport': instance.pushSupport,
      'local': instance.local,
      'pin': instance.pin,
      'oath': instance.oath,
      'port': instance.port,
      'connectionType': instance.connectionType,
      'siteId': instance.siteId,
      'dateIncluded': instance.dateIncluded,
      'provisionInfoEntity': instance.provisionInfoEntity,
      'sasEntity': instance.sasEntity,
      'sasList': instance.sasList,
      'sasId': instance.sasId,
      'securityString': instance.securityString,
      'pinValue': instance.pinValue,
      'isPinFree': instance.isPinFree,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
