import 'package:json_annotation/json_annotation.dart';

part 'push_dto.g.dart';

@JsonSerializable()
class PushDto {
  final String answer;
  final String pushId;
  final String code;
  final String username;
  final String userId;

  const PushDto({
    required this.answer,
    required this.pushId,
    required this.code,
    required this.username,
    required this.userId,
  });

  factory PushDto.fromJson(Map<String, dynamic> json) =>
      _$PushDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PushDtoToJson(this);

  PushDto copyWith({
    String? answer,
    String? pushId,
    String? code,
    String? username,
    String? userId,
  }) {
    return PushDto(
      answer: answer ?? this.answer,
      pushId: pushId ?? this.pushId,
      code: code ?? this.code,
      username: username ?? this.username,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PushDto &&
        other.pushId == pushId &&
        other.username == username;
  }

  @override
  int get hashCode => Object.hash(pushId, username);

  @override
  String toString() {
    return 'PushDto(pushId: $pushId, username: $username, answer: $answer)';
  }
}
