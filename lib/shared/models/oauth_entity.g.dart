// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OAuthEntityAdapter extends TypeAdapter<OAuthEntity> {
  @override
  final int typeId = 5;

  @override
  OAuthEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OAuthEntity(
      id: fields[0] as int?,
      description: fields[1] as String?,
      issuer: fields[2] as String,
      account: fields[3] as String,
      secret: fields[4] as String,
      username: fields[5] as String,
      provisionCode: fields[6] as String,
      pin: fields[7] as bool,
      dateIncluded: fields[8] as int?,
      algorithm: fields[9] as String,
      digits: fields[10] as int,
      period: fields[11] as int,
      label: fields[12] as String,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OAuthEntity obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.issuer)
      ..writeByte(3)
      ..write(obj.account)
      ..writeByte(4)
      ..write(obj.secret)
      ..writeByte(5)
      ..write(obj.username)
      ..writeByte(6)
      ..write(obj.provisionCode)
      ..writeByte(7)
      ..write(obj.pin)
      ..writeByte(8)
      ..write(obj.dateIncluded)
      ..writeByte(9)
      ..write(obj.algorithm)
      ..writeByte(10)
      ..write(obj.digits)
      ..writeByte(11)
      ..write(obj.period)
      ..writeByte(12)
      ..write(obj.label)
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
      other is OAuthEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthEntity _$OAuthEntityFromJson(Map<String, dynamic> json) => OAuthEntity(
      id: (json['id'] as num?)?.toInt(),
      description: json['description'] as String?,
      issuer: json['issuer'] as String,
      account: json['account'] as String,
      secret: json['secret'] as String,
      username: json['username'] as String,
      provisionCode: json['provisionCode'] as String,
      pin: json['pin'] as bool? ?? false,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
      algorithm: json['algorithm'] as String? ?? 'SHA1',
      digits: (json['digits'] as num?)?.toInt() ?? 6,
      period: (json['period'] as num?)?.toInt() ?? 30,
      label: json['label'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OAuthEntityToJson(OAuthEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'issuer': instance.issuer,
      'account': instance.account,
      'secret': instance.secret,
      'username': instance.username,
      'provisionCode': instance.provisionCode,
      'pin': instance.pin,
      'dateIncluded': instance.dateIncluded,
      'algorithm': instance.algorithm,
      'digits': instance.digits,
      'period': instance.period,
      'label': instance.label,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
