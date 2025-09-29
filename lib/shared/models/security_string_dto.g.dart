// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_string_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityStringDto _$SecurityStringDtoFromJson(Map<String, dynamic> json) =>
    SecurityStringDto(
      id: (json['id'] as num?)?.toInt(),
      value: json['value'] as String?,
      index: (json['index'] as num?)?.toInt(),
      position: (json['position'] as num?)?.toInt(),
      used: json['used'] as bool?,
      color: json['color'] as String?,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
      sasId: (json['sasId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SecurityStringDtoToJson(SecurityStringDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'index': instance.index,
      'position': instance.position,
      'used': instance.used,
      'color': instance.color,
      'dateIncluded': instance.dateIncluded,
      'sasId': instance.sasId,
    };
