import 'package:json_annotation/json_annotation.dart';

part 'push_response.g.dart';

@JsonSerializable()
class PushResponse {
  final bool success;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  const PushResponse({
    required this.success,
    this.message,
    this.errorCode,
    this.metadata,
  });

  factory PushResponse.fromJson(Map<String, dynamic> json) =>
      _$PushResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PushResponseToJson(this);

  PushResponse copyWith({
    bool? success,
    String? message,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return PushResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PushResponse &&
        other.success == success &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(success, message);

  @override
  String toString() {
    return 'PushResponse(success: $success, message: $message)';
  }
}
