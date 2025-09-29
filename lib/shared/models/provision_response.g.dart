// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provision_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProvisionResponse _$ProvisionResponseFromJson(Map<String, dynamic> json) =>
    ProvisionResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      sasEntity: json['sasEntity'] == null
          ? null
          : SasEntity.fromJson(json['sasEntity'] as Map<String, dynamic>),
      securityStrings: (json['securityStrings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      errorCode: json['errorCode'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProvisionResponseToJson(ProvisionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'sasEntity': instance.sasEntity,
      'securityStrings': instance.securityStrings,
      'errorCode': instance.errorCode,
      'metadata': instance.metadata,
    };
