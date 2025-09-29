import 'package:json_annotation/json_annotation.dart';

part 'push_registration_response.g.dart';

@JsonSerializable()
class PushRegistrationResponse {
  final bool success;
  final String? message;
  final String? pushId;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  const PushRegistrationResponse({
    required this.success,
    this.message,
    this.pushId,
    this.errorCode,
    this.metadata,
  });

  factory PushRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$PushRegistrationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PushRegistrationResponseToJson(this);

  PushRegistrationResponse copyWith({
    bool? success,
    String? message,
    String? pushId,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return PushRegistrationResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      pushId: pushId ?? this.pushId,
      errorCode: errorCode ?? this.errorCode,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PushRegistrationResponse &&
        other.success == success &&
        other.message == message &&
        other.pushId == pushId;
  }

  @override
  int get hashCode => Object.hash(success, message, pushId);

  @override
  String toString() {
    return 'PushRegistrationResponse(success: $success, message: $message, pushId: $pushId)';
  }
}
