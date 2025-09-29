// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ss_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SsDetailDto _$SsDetailDtoFromJson(Map<String, dynamic> json) => SsDetailDto(
      hostname: json['hostname'] as String?,
      usingSsl: json['usingSSL'] as String?,
      pushSupport: json['pushSupport'] as String?,
      local: json['local'] as String?,
      pin: json['pin'] as String?,
      oath: json['oath'] as String?,
      port: (json['port'] as num?)?.toInt(),
      connectionType: json['connectionType'] as String?,
      siteId: json['siteId'] as String?,
      sasRequestDto: json['sasRequestDto'] == null
          ? null
          : SasRequestDto.fromJson(
              json['sasRequestDto'] as Map<String, dynamic>),
      sasResponseDto: json['sasResponseDto'] == null
          ? null
          : SasResponseDto.fromJson(
              json['sasResponseDto'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SsDetailDtoToJson(SsDetailDto instance) =>
    <String, dynamic>{
      'hostname': instance.hostname,
      'usingSSL': instance.usingSsl,
      'pushSupport': instance.pushSupport,
      'local': instance.local,
      'pin': instance.pin,
      'oath': instance.oath,
      'port': instance.port,
      'connectionType': instance.connectionType,
      'siteId': instance.siteId,
      'sasRequestDto': instance.sasRequestDto,
      'sasResponseDto': instance.sasResponseDto,
    };
