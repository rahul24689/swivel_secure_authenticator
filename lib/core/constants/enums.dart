/// Enumeration for object types used in cache configuration
enum ObjectType {
  boolean,
  integer,
  string,
}

/// Enumeration for provision types
enum ProvisionType {
  otc,
  oath,
}

/// Enumeration for application codes
enum AppCode {
  sams,
  alcm,
}

/// Enumeration for actions
enum Action {
  provision,
  securityStrings,
  tokenIndex,
}

/// Enumeration for push notification types
enum PushType {
  samsCategory,
  authentication,
  notification,
}

/// Enumeration for authentication states
enum AuthenticationState {
  notStarted,
  inProgress,
  success,
  failed,
  cancelled,
}

/// Enumeration for connection types
enum ConnectionType {
  https,
  http,
}

/// Enumeration for device security states
enum DeviceSecurityState {
  secure,
  rooted,
  jailbroken,
  unknown,
}

/// Enumeration for biometric authentication types
enum BiometricType {
  fingerprint,
  face,
  iris,
  voice,
  none,
}

/// Enumeration for network connectivity states
enum ConnectivityState {
  connected,
  disconnected,
  unknown,
}

/// Enumeration for database operation results
enum DatabaseResult {
  success,
  failure,
  notFound,
  duplicate,
}

/// Enumeration for authentication methods
enum AuthenticationMethod {
  securityString,
  oath,
  push,
  biometric,
}

/// Extension methods for enums
extension ObjectTypeExtension on ObjectType {
  String get name {
    switch (this) {
      case ObjectType.boolean:
        return 'BOOLEAN';
      case ObjectType.integer:
        return 'INTEGER';
      case ObjectType.string:
        return 'STRING';
    }
  }
}

extension ProvisionTypeExtension on ProvisionType {
  String get name {
    switch (this) {
      case ProvisionType.otc:
        return 'OTC';
      case ProvisionType.oath:
        return 'OATH';
    }
  }
}

extension ActionExtension on Action {
  String get name {
    switch (this) {
      case Action.provision:
        return 'Provision';
      case Action.securityStrings:
        return 'SecurityStrings';
      case Action.tokenIndex:
        return 'TokenIndex';
    }
  }
}

extension PushTypeExtension on PushType {
  String get name {
    switch (this) {
      case PushType.samsCategory:
        return 'SAMS_CATEGORY';
      case PushType.authentication:
        return 'AUTHENTICATION';
      case PushType.notification:
        return 'NOTIFICATION';
    }
  }
}

extension ConnectionTypeExtension on ConnectionType {
  String get name {
    switch (this) {
      case ConnectionType.https:
        return 'HTTPS';
      case ConnectionType.http:
        return 'HTTP';
    }
  }

  bool get isSecure => this == ConnectionType.https;
}

extension AuthenticationMethodExtension on AuthenticationMethod {
  String get displayName {
    switch (this) {
      case AuthenticationMethod.securityString:
        return 'Security String';
      case AuthenticationMethod.oath:
        return 'OATH TOTP';
      case AuthenticationMethod.push:
        return 'Push Authentication';
      case AuthenticationMethod.biometric:
        return 'Biometric Authentication';
    }
  }
}
