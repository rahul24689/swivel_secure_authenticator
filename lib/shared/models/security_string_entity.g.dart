// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_string_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecurityStringEntityAdapter extends TypeAdapter<SecurityStringEntity> {
  @override
  final int typeId = 2;

  @override
  SecurityStringEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SecurityStringEntity(
      id: fields[0] as int?,
      description: fields[1] as String?,
      securityCode: fields[2] as String,
      tokenIndex: fields[3] as int,
      usedCode: fields[4] as bool,
      dateIncluded: fields[5] as int?,
      sasEntity: fields[6] as SasEntity?,
    );
  }

  @override
  void write(BinaryWriter writer, SecurityStringEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.securityCode)
      ..writeByte(3)
      ..write(obj.tokenIndex)
      ..writeByte(4)
      ..write(obj.usedCode)
      ..writeByte(5)
      ..write(obj.dateIncluded)
      ..writeByte(6)
      ..write(obj.sasEntity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityStringEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityStringEntity _$SecurityStringEntityFromJson(
        Map<String, dynamic> json) =>
    SecurityStringEntity(
      id: (json['id'] as num?)?.toInt(),
      description: json['description'] as String?,
      securityCode: json['securityCode'] as String,
      tokenIndex: (json['tokenIndex'] as num).toInt(),
      usedCode: json['usedCode'] as bool? ?? false,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
      sasEntity: json['sasEntity'] == null
          ? null
          : SasEntity.fromJson(json['sasEntity'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SecurityStringEntityToJson(
        SecurityStringEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'securityCode': instance.securityCode,
      'tokenIndex': instance.tokenIndex,
      'usedCode': instance.usedCode,
      'dateIncluded': instance.dateIncluded,
      'sasEntity': instance.sasEntity,
    };
