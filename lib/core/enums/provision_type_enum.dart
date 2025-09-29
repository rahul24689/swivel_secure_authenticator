/// Provision type enumeration for different authentication types
/// Converted from ProvisionTypeEn.java
enum ProvisionType {
  otc,
  oath;

  @override
  String toString() {
    switch (this) {
      case ProvisionType.otc:
        return 'OTC';
      case ProvisionType.oath:
        return 'OATH';
    }
  }

  /// Get display name for the provision type
  String get displayName => toString();
}
