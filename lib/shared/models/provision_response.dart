import 'package:json_annotation/json_annotation.dart';
import 'sas_entity.dart';

part 'provision_response.g.dart';

@JsonSerializable()
class ProvisionResponse {
  final bool success;
  final String? message;
  final SasEntity? sasEntity;
  final List<String>? securityStrings;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  const ProvisionResponse({
    required this.success,
    this.message,
    this.sasEntity,
    this.securityStrings,
    this.errorCode,
    this.metadata,
  });

  factory ProvisionResponse.fromJson(Map<String, dynamic> json) =>
      _$ProvisionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProvisionResponseToJson(this);

  ProvisionResponse copyWith({
    bool? success,
    String? message,
    SasEntity? sasEntity,
    List<String>? securityStrings,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return ProvisionResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      sasEntity: sasEntity ?? this.sasEntity,
      securityStrings: securityStrings ?? this.securityStrings,
      errorCode: errorCode ?? this.errorCode,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProvisionResponse &&
        other.success == success &&
        other.message == message &&
        other.sasEntity == sasEntity;
  }

  @override
  int get hashCode => Object.hash(success, message, sasEntity);

  @override
  String toString() {
    return 'ProvisionResponse(success: $success, message: $message, sasEntity: $sasEntity)';
  }
}
