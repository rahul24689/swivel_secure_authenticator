// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushDto _$PushDtoFromJson(Map<String, dynamic> json) => PushDto(
      answer: json['answer'] as String,
      pushId: json['pushId'] as String,
      code: json['code'] as String,
      username: json['username'] as String,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$PushDtoToJson(PushDto instance) => <String, dynamic>{
      'answer': instance.answer,
      'pushId': instance.pushId,
      'code': instance.code,
      'username': instance.username,
      'userId': instance.userId,
    };
