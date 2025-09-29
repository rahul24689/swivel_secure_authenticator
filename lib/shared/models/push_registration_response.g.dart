// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushRegistrationResponse _$PushRegistrationResponseFromJson(
        Map<String, dynamic> json) =>
    PushRegistrationResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      pushId: json['pushId'] as String?,
      errorCode: json['errorCode'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PushRegistrationResponseToJson(
        PushRegistrationResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'pushId': instance.pushId,
      'errorCode': instance.errorCode,
      'metadata': instance.metadata,
    };
