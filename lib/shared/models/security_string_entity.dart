import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import 'sas_entity.dart';

part 'security_string_entity.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class SecurityStringEntity {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String securityCode;

  @HiveField(3)
  final int tokenIndex;

  @HiveField(4)
  final bool usedCode;

  @HiveField(5)
  final int? dateIncluded;

  @HiveField(6)
  final SasEntity? sasEntity;

  const SecurityStringEntity({
    this.id,
    this.description,
    required this.securityCode,
    required this.tokenIndex,
    this.usedCode = false,
    this.dateIncluded,
    this.sasEntity,
  });

  factory SecurityStringEntity.fromJson(Map<String, dynamic> json) =>
      _$SecurityStringEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityStringEntityToJson(this);

  SecurityStringEntity copyWith({
    int? id,
    String? description,
    String? securityCode,
    int? tokenIndex,
    bool? usedCode,
    int? dateIncluded,
    SasEntity? sasEntity,
  }) {
    return SecurityStringEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      securityCode: securityCode ?? this.securityCode,
      tokenIndex: tokenIndex ?? this.tokenIndex,
      usedCode: usedCode ?? this.usedCode,
      dateIncluded: dateIncluded ?? this.dateIncluded,
      sasEntity: sasEntity ?? this.sasEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecurityStringEntity &&
        other.id == id &&
        other.securityCode == securityCode &&
        other.tokenIndex == tokenIndex;
  }

  @override
  int get hashCode => Object.hash(id, securityCode, tokenIndex);

  @override
  String toString() {
    return 'SecurityStringEntity(id: $id, tokenIndex: $tokenIndex, usedCode: $usedCode)';
  }
}
