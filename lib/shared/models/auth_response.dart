import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String? message;
  final String? sessionToken;
  final String? errorCode;
  final int? tokenIndex;
  final Map<String, dynamic>? metadata;

  const AuthResponse({
    required this.success,
    this.message,
    this.sessionToken,
    this.errorCode,
    this.tokenIndex,
    this.metadata,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  AuthResponse copyWith({
    bool? success,
    String? message,
    String? sessionToken,
    String? errorCode,
    int? tokenIndex,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      sessionToken: sessionToken ?? this.sessionToken,
      errorCode: errorCode ?? this.errorCode,
      tokenIndex: tokenIndex ?? this.tokenIndex,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse &&
        other.success == success &&
        other.message == message &&
        other.sessionToken == sessionToken;
  }

  @override
  int get hashCode => Object.hash(success, message, sessionToken);

  @override
  String toString() {
    return 'AuthResponse(success: $success, message: $message, sessionToken: $sessionToken)';
  }
}
