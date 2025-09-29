// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushResponse _$PushResponseFromJson(Map<String, dynamic> json) => PushResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      errorCode: json['errorCode'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PushResponseToJson(PushResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'errorCode': instance.errorCode,
      'metadata': instance.metadata,
    };
