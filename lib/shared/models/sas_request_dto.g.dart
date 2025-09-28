// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sas_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SasRequestDto _$SasRequestDtoFromJson(Map<String, dynamic> json) =>
    SasRequestDto(
      version: json['Version'] as String? ?? '3.6',
      action: json['Action'] as String? ?? 'Provision',
      username: json['Username'] as String,
      provisionCode: json['ProvisionCode'] as String?,
      pushId: json['PushId'] as String?,
      deviceOs: json['DeviceOS'] as String? ?? 'FLUTTER',
      id: json['Id'] as String?,
    );

Map<String, dynamic> _$SasRequestDtoToJson(SasRequestDto instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Action': instance.action,
      'Username': instance.username,
      'ProvisionCode': instance.provisionCode,
      'PushId': instance.pushId,
      'DeviceOS': instance.deviceOs,
      'Id': instance.id,
    };
