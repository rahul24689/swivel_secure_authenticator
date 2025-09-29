// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerDetailDto _$ServerDetailDtoFromJson(Map<String, dynamic> json) =>
    ServerDetailDto(
      responseCode: (json['responseCode'] as num?)?.toInt(),
      errorDescription: json['errorDescription'] as String?,
      ssDetailDto: json['SSDetails'] == null
          ? null
          : SsDetailDto.fromJson(json['SSDetails'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ServerDetailDtoToJson(ServerDetailDto instance) =>
    <String, dynamic>{
      'responseCode': instance.responseCode,
      'errorDescription': instance.errorDescription,
      'SSDetails': instance.ssDetailDto,
    };
