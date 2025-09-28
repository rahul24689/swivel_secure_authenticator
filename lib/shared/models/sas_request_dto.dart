import 'package:json_annotation/json_annotation.dart';

part 'sas_request_dto.g.dart';

@JsonSerializable()
class SasRequestDto {
  @JsonKey(name: 'Version')
  final String version;

  @JsonKey(name: 'Action')
  final String action;

  @JsonKey(name: 'Username')
  final String username;

  @JsonKey(name: 'ProvisionCode')
  final String? provisionCode;

  @JsonKey(name: 'PushId')
  final String? pushId;

  @JsonKey(name: 'DeviceOS')
  final String deviceOs;

  @JsonKey(name: 'Id')
  final String? id;

  const SasRequestDto({
    this.version = '3.6',
    this.action = 'Provision',
    required this.username,
    this.provisionCode,
    this.pushId,
    this.deviceOs = 'FLUTTER',
    this.id,
  });

  factory SasRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SasRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SasRequestDtoToJson(this);

  SasRequestDto copyWith({
    String? version,
    String? action,
    String? username,
    String? provisionCode,
    String? pushId,
    String? deviceOs,
    String? id,
  }) {
    return SasRequestDto(
      version: version ?? this.version,
      action: action ?? this.action,
      username: username ?? this.username,
      provisionCode: provisionCode ?? this.provisionCode,
      pushId: pushId ?? this.pushId,
      deviceOs: deviceOs ?? this.deviceOs,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SasRequestDto &&
        other.username == username &&
        other.action == action;
  }

  @override
  int get hashCode => Object.hash(username, action);

  @override
  String toString() {
    return 'SasRequestDto(username: $username, action: $action, version: $version)';
  }
}
