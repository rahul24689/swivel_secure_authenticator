/// Action enumeration for different types of actions
/// Converted from ActionEn.java
enum ActionEnum {
  provision,
  securityString;

  @override
  String toString() {
    switch (this) {
      case ActionEnum.provision:
        return 'Provision';
      case ActionEnum.securityString:
        return 'SecurityStrings';
    }
  }

  /// Get display name for the action
  String get displayName => toString();
}
