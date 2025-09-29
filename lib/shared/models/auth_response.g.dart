// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      sessionToken: json['sessionToken'] as String?,
      errorCode: json['errorCode'] as String?,
      tokenIndex: (json['tokenIndex'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'sessionToken': instance.sessionToken,
      'errorCode': instance.errorCode,
      'tokenIndex': instance.tokenIndex,
      'metadata': instance.metadata,
    };
