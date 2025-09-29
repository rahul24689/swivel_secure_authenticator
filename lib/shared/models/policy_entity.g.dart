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
      sasId: fields[4] as int,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PolicyEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.policyId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.sasId)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
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
      sasId: (json['sasId'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PolicyEntityToJson(PolicyEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'policyId': instance.policyId,
      'content': instance.content,
      'description': instance.description,
      'sasId': instance.sasId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
