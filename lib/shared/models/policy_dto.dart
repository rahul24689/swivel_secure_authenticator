import 'package:json_annotation/json_annotation.dart';

part 'policy_dto.g.dart';

@JsonSerializable()
class PolicyDto {
  @JsonKey(name: 'Id')
  final String? id;
  
  @JsonKey(name: 'Content')
  final String? content;
  
  @JsonKey(name: 'Description')
  final String? description;
  
  final int? dateIncluded;

  const PolicyDto({
    this.id,
    this.content,
    this.description,
    this.dateIncluded,
  });

  factory PolicyDto.fromJson(Map<String, dynamic> json) =>
      _$PolicyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyDtoToJson(this);

  PolicyDto copyWith({
    String? id,
    String? content,
    String? description,
    int? dateIncluded,
  }) {
    return PolicyDto(
      id: id ?? this.id,
      content: content ?? this.content,
      description: description ?? this.description,
      dateIncluded: dateIncluded ?? this.dateIncluded,
    );
  }

  // Helper methods
  bool get isEnabled => content?.toUpperCase() == 'ON';
  bool get isDisabled => content?.toUpperCase() == 'OFF';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PolicyDto &&
        other.id == id &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(id, content);

  @override
  String toString() {
    return 'PolicyDto(id: $id, content: $content, description: $description)';
  }
}
