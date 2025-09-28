// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sas_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SasEntityAdapter extends TypeAdapter<SasEntity> {
  @override
  final int typeId = 1;

  @override
  SasEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SasEntity(
      id: fields[0] as int?,
      description: fields[1] as String?,
      username: fields[2] as String,
      provisionCode: fields[3] as String,
      pushId: fields[4] as String?,
      sasId: fields[5] as String?,
      dateIncluded: fields[6] as int?,
      ssDetailEntity: fields[7] as SsDetailEntity?,
      policyList: (fields[8] as List?)?.cast<PolicyEntity>(),
      securityStringList: (fields[9] as List?)?.cast<SecurityStringEntity>(),
      accountName: fields[10] as String,
      serverUrl: fields[11] as String,
      isActive: fields[12] as bool,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SasEntity obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.provisionCode)
      ..writeByte(4)
      ..write(obj.pushId)
      ..writeByte(5)
      ..write(obj.sasId)
      ..writeByte(6)
      ..write(obj.dateIncluded)
      ..writeByte(7)
      ..write(obj.ssDetailEntity)
      ..writeByte(8)
      ..write(obj.policyList)
      ..writeByte(9)
      ..write(obj.securityStringList)
      ..writeByte(10)
      ..write(obj.accountName)
      ..writeByte(11)
      ..write(obj.serverUrl)
      ..writeByte(12)
      ..write(obj.isActive)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SasEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SasEntity _$SasEntityFromJson(Map<String, dynamic> json) => SasEntity(
      id: (json['id'] as num?)?.toInt(),
      description: json['description'] as String?,
      username: json['username'] as String,
      provisionCode: json['provisionCode'] as String,
      pushId: json['pushId'] as String?,
      sasId: json['sasId'] as String?,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
      ssDetailEntity: json['ssDetailEntity'] == null
          ? null
          : SsDetailEntity.fromJson(
              json['ssDetailEntity'] as Map<String, dynamic>),
      policyList: (json['policyList'] as List<dynamic>?)
          ?.map((e) => PolicyEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      securityStringList: (json['securityStringList'] as List<dynamic>?)
          ?.map((e) => SecurityStringEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountName: json['accountName'] as String,
      serverUrl: json['serverUrl'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SasEntityToJson(SasEntity instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'username': instance.username,
      'provisionCode': instance.provisionCode,
      'pushId': instance.pushId,
      'sasId': instance.sasId,
      'dateIncluded': instance.dateIncluded,
      'ssDetailEntity': instance.ssDetailEntity,
      'policyList': instance.policyList,
      'securityStringList': instance.securityStringList,
      'accountName': instance.accountName,
      'serverUrl': instance.serverUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
