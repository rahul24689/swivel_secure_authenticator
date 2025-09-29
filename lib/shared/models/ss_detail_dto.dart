import 'package:json_annotation/json_annotation.dart';
import 'sas_request_dto.dart';
import 'sas_response_dto.dart';

part 'ss_detail_dto.g.dart';

@JsonSerializable()
class SsDetailDto {
  final String? hostname;
  
  @JsonKey(name: 'usingSSL')
  final String? usingSsl;
  
  final String? pushSupport;
  final String? local;
  final String? pin;
  final String? oath;
  final int? port;
  final String? connectionType;
  final String? siteId;
  
  // Nested DTOs
  final SasRequestDto? sasRequestDto;
  final SasResponseDto? sasResponseDto;

  const SsDetailDto({
    this.hostname,
    this.usingSsl,
    this.pushSupport,
    this.local,
    this.pin,
    this.oath,
    this.port,
    this.connectionType,
    this.siteId,
    this.sasRequestDto,
    this.sasResponseDto,
  });

  factory SsDetailDto.fromJson(Map<String, dynamic> json) =>
      _$SsDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SsDetailDtoToJson(this);

  SsDetailDto copyWith({
    String? hostname,
    String? usingSsl,
    String? pushSupport,
    String? local,
    String? pin,
    String? oath,
    int? port,
    String? connectionType,
    String? siteId,
    SasRequestDto? sasRequestDto,
    SasResponseDto? sasResponseDto,
  }) {
    return SsDetailDto(
      hostname: hostname ?? this.hostname,
      usingSsl: usingSsl ?? this.usingSsl,
      pushSupport: pushSupport ?? this.pushSupport,
      local: local ?? this.local,
      pin: pin ?? this.pin,
      oath: oath ?? this.oath,
      port: port ?? this.port,
      connectionType: connectionType ?? this.connectionType,
      siteId: siteId ?? this.siteId,
      sasRequestDto: sasRequestDto ?? this.sasRequestDto,
      sasResponseDto: sasResponseDto ?? this.sasResponseDto,
    );
  }

  // Helper methods
  bool get isOath => oath?.toLowerCase() == 'yes' || oath?.toLowerCase() == 'true';
  bool get isLocal => local?.toLowerCase() == 'yes' || local?.toLowerCase() == 'true';
  bool get isPinRequired => pin?.toLowerCase() == 'yes' || pin?.toLowerCase() == 'true';
  bool get isPushSupported => pushSupport?.toLowerCase() == 'yes' || pushSupport?.toLowerCase() == 'true';
  bool get isUsingSsl => usingSsl?.toLowerCase() == 'yes' || usingSsl?.toLowerCase() == 'true';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SsDetailDto &&
        other.hostname == hostname &&
        other.port == port &&
        other.siteId == siteId;
  }

  @override
  int get hashCode => Object.hash(hostname, port, siteId);

  @override
  String toString() {
    return 'SsDetailDto(hostname: $hostname, port: $port, siteId: $siteId, oath: $oath, local: $local)';
  }
}
