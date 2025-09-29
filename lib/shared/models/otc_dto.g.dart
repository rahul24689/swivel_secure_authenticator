// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otc_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtcDto _$OtcDtoFromJson(Map<String, dynamic> json) => OtcDto(
      id: (json['id'] as num?)?.toInt(),
      siteId: json['siteId'] as String?,
      username: json['username'] as String?,
      counter: (json['counter'] as num?)?.toInt(),
      otc: json['otc'] as String?,
      index: json['index'] as String?,
      provisionCode: json['provisionCode'] as String?,
      hostname: json['hostname'] as String?,
      port: (json['port'] as num?)?.toInt(),
      otcTemp: json['otcTemp'] as String?,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
      description: json['description'] as String?,
      policyList: (json['policyList'] as List<dynamic>?)
          ?.map((e) => PolicyDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OtcDtoToJson(OtcDto instance) => <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'username': instance.username,
      'counter': instance.counter,
      'otc': instance.otc,
      'index': instance.index,
      'provisionCode': instance.provisionCode,
      'hostname': instance.hostname,
      'port': instance.port,
      'otcTemp': instance.otcTemp,
      'dateIncluded': instance.dateIncluded,
      'description': instance.description,
      'policyList': instance.policyList,
    };
