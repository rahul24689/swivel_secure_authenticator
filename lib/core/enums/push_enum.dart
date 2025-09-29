/// Push notification category enumeration
/// Converted from PushEn.java
enum PushEnum {
  samsCategory,
  samsBiometricsCategory,
  samsBioplusCategory;

  @override
  String toString() {
    switch (this) {
      case PushEnum.samsCategory:
        return 'sams-category';
      case PushEnum.samsBiometricsCategory:
        return 'sams-biometric-category';
      case PushEnum.samsBioplusCategory:
        return 'sams-bioplus-category';
    }
  }

  /// Get PushEnum from string value
  static PushEnum? fromString(String text) {
    for (final value in PushEnum.values) {
      if (value.toString().toLowerCase() == text.toLowerCase()) {
        return value;
      }
    }
    return null;
  }

  /// Get display name for the push category
  String get displayName => toString();
}
