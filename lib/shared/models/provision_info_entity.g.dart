// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provision_info_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProvisionInfoEntityAdapter extends TypeAdapter<ProvisionInfoEntity> {
  @override
  final int typeId = 3;

  @override
  ProvisionInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProvisionInfoEntity(
      id: fields[0] as int?,
      description: fields[1] as String?,
      siteId: fields[2] as String,
      username: fields[3] as String,
      provisionCode: fields[4] as String,
      dateIncluded: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProvisionInfoEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.siteId)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.provisionCode)
      ..writeByte(5)
      ..write(obj.dateIncluded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProvisionInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProvisionInfoEntity _$ProvisionInfoEntityFromJson(Map<String, dynamic> json) =>
    ProvisionInfoEntity(
      id: (json['id'] as num?)?.toInt(),
      description: json['description'] as String?,
      siteId: json['siteId'] as String,
      username: json['username'] as String,
      provisionCode: json['provisionCode'] as String,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProvisionInfoEntityToJson(
        ProvisionInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'siteId': instance.siteId,
      'username': instance.username,
      'provisionCode': instance.provisionCode,
      'dateIncluded': instance.dateIncluded,
    };
