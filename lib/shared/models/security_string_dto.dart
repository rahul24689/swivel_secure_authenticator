import 'package:json_annotation/json_annotation.dart';

part 'security_string_dto.g.dart';

@JsonSerializable()
class SecurityStringDto {
  final int? id;
  final String? value;
  final int? index;
  final int? position;
  final bool? used;
  final String? color;
  final int? dateIncluded;
  final int? sasId;

  const SecurityStringDto({
    this.id,
    this.value,
    this.index,
    this.position,
    this.used,
    this.color,
    this.dateIncluded,
    this.sasId,
  });

  factory SecurityStringDto.fromJson(Map<String, dynamic> json) =>
      _$SecurityStringDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityStringDtoToJson(this);

  SecurityStringDto copyWith({
    int? id,
    String? value,
    int? index,
    int? position,
    bool? used,
    String? color,
    int? dateIncluded,
    int? sasId,
  }) {
    return SecurityStringDto(
      id: id ?? this.id,
      value: value ?? this.value,
      index: index ?? this.index,
      position: position ?? this.position,
      used: used ?? this.used,
      color: color ?? this.color,
      dateIncluded: dateIncluded ?? this.dateIncluded,
      sasId: sasId ?? this.sasId,
    );
  }

  // Helper methods
  bool get isUsed => used ?? false;
  bool get isAvailable => !isUsed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecurityStringDto &&
        other.id == id &&
        other.index == index &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(id, index, position);

  @override
  String toString() {
    return 'SecurityStringDto(id: $id, index: $index, position: $position, value: $value, used: $used)';
  }
}
