import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'oauth_entity.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class OAuthEntity {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String issuer;

  @HiveField(3)
  final String account;

  @HiveField(4)
  final String secret;

  @HiveField(5)
  final String username;

  @HiveField(6)
  final String provisionCode;

  @HiveField(7)
  final bool pin;

  @HiveField(8)
  final int? dateIncluded;

  @HiveField(9)
  final String algorithm;

  @HiveField(10)
  final int digits;

  @HiveField(11)
  final int period;

  @HiveField(12)
  final String label;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  const OAuthEntity({
    this.id,
    this.description,
    required this.issuer,
    required this.account,
    required this.secret,
    required this.username,
    required this.provisionCode,
    this.pin = false,
    this.dateIncluded,
    this.algorithm = 'SHA1',
    this.digits = 6,
    this.period = 30,
    required this.label,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OAuthEntity.fromJson(Map<String, dynamic> json) =>
      _$OAuthEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthEntityToJson(this);

  OAuthEntity copyWith({
    int? id,
    String? description,
    String? issuer,
    String? account,
    String? secret,
    String? username,
    String? provisionCode,
    bool? pin,
    int? dateIncluded,
    String? algorithm,
    int? digits,
    int? period,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OAuthEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      issuer: issuer ?? this.issuer,
      account: account ?? this.account,
      secret: secret ?? this.secret,
      username: username ?? this.username,
      provisionCode: provisionCode ?? this.provisionCode,
      pin: pin ?? this.pin,
      dateIncluded: dateIncluded ?? this.dateIncluded,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OAuthEntity &&
        other.id == id &&
        other.issuer == issuer &&
        other.account == account;
  }

  @override
  int get hashCode => Object.hash(id, issuer, account);

  @override
  String toString() {
    return 'OAuthEntity(id: $id, issuer: $issuer, account: $account)';
  }
}
