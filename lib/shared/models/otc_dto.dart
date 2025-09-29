import 'package:json_annotation/json_annotation.dart';
import 'policy_dto.dart';

part 'otc_dto.g.dart';

@JsonSerializable()
class OtcDto {
  final int? id;
  final String? siteId;
  final String? username;
  final int? counter;
  final String? otc;
  final String? index;
  final String? provisionCode;
  final String? hostname;
  final int? port;
  final String? otcTemp;
  final int? dateIncluded;
  final String? description;
  
  final List<PolicyDto>? policyList;

  const OtcDto({
    this.id,
    this.siteId,
    this.username,
    this.counter,
    this.otc,
    this.index,
    this.provisionCode,
    this.hostname,
    this.port,
    this.otcTemp,
    this.dateIncluded,
    this.description,
    this.policyList,
  });

  factory OtcDto.fromJson(Map<String, dynamic> json) =>
      _$OtcDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OtcDtoToJson(this);

  OtcDto copyWith({
    int? id,
    String? siteId,
    String? username,
    int? counter,
    String? otc,
    String? index,
    String? provisionCode,
    String? hostname,
    int? port,
    String? otcTemp,
    int? dateIncluded,
    String? description,
    List<PolicyDto>? policyList,
  }) {
    return OtcDto(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      username: username ?? this.username,
      counter: counter ?? this.counter,
      otc: otc ?? this.otc,
      index: index ?? this.index,
      provisionCode: provisionCode ?? this.provisionCode,
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      otcTemp: otcTemp ?? this.otcTemp,
      dateIncluded: dateIncluded ?? this.dateIncluded,
      description: description ?? this.description,
      policyList: policyList ?? this.policyList,
    );
  }

  // Helper methods
  String get otcFormatted {
    if (otc == null || otc!.isEmpty) return '';
    
    return otc!.split('').join(' ');
  }

  /// Get policy by ID
  PolicyDto? getPolicyById(String policyId) {
    return policyList?.firstWhere(
      (policy) => policy.id == policyId,
      orElse: () => PolicyDto(id: policyId, content: 'OFF'),
    );
  }

  /// Check if a policy is enabled
  bool isPolicyEnabled(String policyId) {
    final policy = getPolicyById(policyId);
    return policy?.isEnabled ?? false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtcDto &&
        other.id == id &&
        other.siteId == siteId &&
        other.username == username;
  }

  @override
  int get hashCode => Object.hash(id, siteId, username);

  @override
  String toString() {
    return 'OtcDto(id: $id, siteId: $siteId, username: $username, hostname: $hostname, port: $port)';
  }
}
