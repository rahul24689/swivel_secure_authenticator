// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PolicyEntityAdapter extends TypeAdapter<PolicyEntity> {
  @override
  final int typeId = 4;

  @override
  PolicyEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PolicyEntity(
      id: fields[0] as int?,
      policyId: fields[1] as String,
      content: fields[2] as String,
      description: fields[3] as String?,
      dateIncluded: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PolicyEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.policyId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.dateIncluded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolicyEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolicyEntity _$PolicyEntityFromJson(Map<String, dynamic> json) => PolicyEntity(
      id: (json['id'] as num?)?.toInt(),
      policyId: json['policyId'] as String,
      content: json['content'] as String,
      description: json['description'] as String?,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PolicyEntityToJson(PolicyEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'policyId': instance.policyId,
      'content': instance.content,
      'description': instance.description,
      'dateIncluded': instance.dateIncluded,
    };
