// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolicyDto _$PolicyDtoFromJson(Map<String, dynamic> json) => PolicyDto(
      id: json['Id'] as String?,
      content: json['Content'] as String?,
      description: json['Description'] as String?,
      dateIncluded: (json['dateIncluded'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PolicyDtoToJson(PolicyDto instance) => <String, dynamic>{
      'Id': instance.id,
      'Content': instance.content,
      'Description': instance.description,
      'dateIncluded': instance.dateIncluded,
    };
