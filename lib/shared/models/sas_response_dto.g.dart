// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sas_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SasResponseDto _$SasResponseDtoFromJson(Map<String, dynamic> json) =>
    SasResponseDto(
      version: json['Version'] as String?,
      requestId: json['RequestID'] as String?,
      result: json['Result'] as String?,
      id: json['Id'] as String?,
      securityString: json['SecurityStrings'] as String?,
      policyList: (json['Policy'] as List<dynamic>?)
          ?.map((e) => PolicyDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      securityStringList: (json['securityStringList'] as List<dynamic>?)
          ?.map((e) => SecurityStringDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sasRequestDto: json['sasRequestDto'] == null
          ? null
          : SasRequestDto.fromJson(
              json['sasRequestDto'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SasResponseDtoToJson(SasResponseDto instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'RequestID': instance.requestId,
      'Result': instance.result,
      'Id': instance.id,
      'SecurityStrings': instance.securityString,
      'Policy': instance.policyList,
      'securityStringList': instance.securityStringList,
      'sasRequestDto': instance.sasRequestDto,
    };
