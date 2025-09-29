/// Application code enumeration for different app versions
/// Converted from AppCodeEn.java
enum AppCodeEnum {
  ams,
  amsAndV5;

  @override
  String toString() {
    switch (this) {
      case AppCodeEnum.ams:
        return '10061985';
      case AppCodeEnum.amsAndV5:
        return '28121958';
    }
  }

  /// Get the application code value
  String get code => toString();
}
