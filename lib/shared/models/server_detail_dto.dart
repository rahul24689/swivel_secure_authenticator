import 'package:json_annotation/json_annotation.dart';
import 'ss_detail_dto.dart';

part 'server_detail_dto.g.dart';

@JsonSerializable()
class ServerDetailDto {
  final int? responseCode;
  final String? errorDescription;
  
  @JsonKey(name: 'SSDetails')
  final SsDetailDto? ssDetailDto;

  const ServerDetailDto({
    this.responseCode,
    this.errorDescription,
    this.ssDetailDto,
  });

  factory ServerDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ServerDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerDetailDtoToJson(this);

  ServerDetailDto copyWith({
    int? responseCode,
    String? errorDescription,
    SsDetailDto? ssDetailDto,
  }) {
    return ServerDetailDto(
      responseCode: responseCode ?? this.responseCode,
      errorDescription: errorDescription ?? this.errorDescription,
      ssDetailDto: ssDetailDto ?? this.ssDetailDto,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServerDetailDto &&
        other.responseCode == responseCode &&
        other.errorDescription == errorDescription &&
        other.ssDetailDto == ssDetailDto;
  }

  @override
  int get hashCode => Object.hash(responseCode, errorDescription, ssDetailDto);

  @override
  String toString() {
    return 'ServerDetailDto(responseCode: $responseCode, errorDescription: $errorDescription, ssDetailDto: $ssDetailDto)';
  }
}
