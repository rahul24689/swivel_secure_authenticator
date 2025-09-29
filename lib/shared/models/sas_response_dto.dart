import 'package:json_annotation/json_annotation.dart';
import 'policy_dto.dart';
import 'security_string_dto.dart';
import 'sas_request_dto.dart';

part 'sas_response_dto.g.dart';

@JsonSerializable()
class SasResponseDto {
  @JsonKey(name: 'Version')
  final String? version;
  
  @JsonKey(name: 'RequestID')
  final String? requestId;
  
  @JsonKey(name: 'Result')
  final String? result;
  
  @JsonKey(name: 'Id')
  final String? id;
  
  @JsonKey(name: 'SecurityStrings')
  final String? securityString;
  
  @JsonKey(name: 'Policy')
  final List<PolicyDto>? policyList;
  
  final List<SecurityStringDto>? securityStringList;
  final SasRequestDto? sasRequestDto;

  const SasResponseDto({
    this.version,
    this.requestId,
    this.result,
    this.id,
    this.securityString,
    this.policyList,
    this.securityStringList,
    this.sasRequestDto,
  });

  factory SasResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SasResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SasResponseDtoToJson(this);

  SasResponseDto copyWith({
    String? version,
    String? requestId,
    String? result,
    String? id,
    String? securityString,
    List<PolicyDto>? policyList,
    List<SecurityStringDto>? securityStringList,
    SasRequestDto? sasRequestDto,
  }) {
    return SasResponseDto(
      version: version ?? this.version,
      requestId: requestId ?? this.requestId,
      result: result ?? this.result,
      id: id ?? this.id,
      securityString: securityString ?? this.securityString,
      policyList: policyList ?? this.policyList,
      securityStringList: securityStringList ?? this.securityStringList,
      sasRequestDto: sasRequestDto ?? this.sasRequestDto,
    );
  }

  // Helper methods
  bool get isSuccess => result?.toLowerCase() == 'success';
  bool get isFailure => result?.toLowerCase() == 'failure';
  
  /// Parse security strings from the semicolon-separated string
  List<String> get parsedSecurityStrings {
    if (securityString == null || securityString!.isEmpty) {
      return [];
    }
    
    return securityString!
        .replaceAll('"', '') // Remove quotes
        .split(';')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SasResponseDto &&
        other.requestId == requestId &&
        other.result == result &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(requestId, result, id);

  @override
  String toString() {
    return 'SasResponseDto(requestId: $requestId, result: $result, id: $id, version: $version)';
  }
}
