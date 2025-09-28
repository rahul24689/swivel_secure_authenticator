/// Application constants
class AppConstants {
  // App Information
  static const String appName = 'Swivel Secure Authenticator';
  static const String appVersion = '6.0.12';
  static const int appBuildNumber = 103;
  static const String packageName = 'com.ss.ams';

  // Database
  static const String databaseName = 'db_ss.db';
  static const int databaseVersion = 2;

  // Table Names
  static const String tableSsDetail = 'tb_ss_detail';
  static const String tableProvisionInfo = 'tb_provision_info';
  static const String tableSas = 'tb_sas';
  static const String tableSecurityString = 'tb_security_string';
  static const String tablePolicy = 'tb_policy';
  static const String tableLog = 'tb_log';
  static const String tableOAuth = 'tb_oauth';
  static const String tableCategory = 'tb_category';

  // Cache Keys
  static const String keyRooted = 'KEY_ROOTED';
  static const String keyProvisioningOk = 'KEY_PROVISIONING_OK';
  static const String keyOathOk = 'KEY_OATH_OK';
  static const String keyPermission = 'KEY_PERMISSION';
  static const String keyBiometric = 'BIO_KEY';
  static const String keyFirebaseToken = 'firebaseToken';

  // Network
  static const String userAgent = 'Swivel Secure Mobile Authenticator Flutter';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int readTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  static const int sendTimeout = 30000; // 30 seconds
  static const String buildNumber = '103';

  // API Endpoints
  static const String agentXmlEndpoint = '/proxy/AgentXML';
  static const String adminApiEndpoint = '/admin/api';
  static const String authApiEndpoint = '/auth/api';

  // Security
  static const int securityStringCount = 99;
  static const int totpInterval = 30; // seconds
  static const int totpDigits = 6;
  static const String encryptionAlgorithm = 'AES';

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 48.0;

  // Timeouts and Delays
  static const int splashDuration = 3000; // milliseconds
  static const int biometricTimeout = 60; // seconds
  static const int pushNotificationTimeout = 300; // seconds

  // Firebase
  static const String firebaseProjectId = 'sentry-messaging';
  static const String firebaseTopic = 'push_notifications';

  // Deep Links
  static const String deepLinkScheme = 'swivel';

  // Permissions
  static const List<String> requiredPermissions = [
    'android.permission.CAMERA',
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.VIBRATE',
    'android.permission.USE_BIOMETRIC',
    'android.permission.POST_NOTIFICATIONS',
  ];

  // Error Messages
  static const String errorGeneric = 'An unexpected error occurred';
  static const String errorNetwork = 'Network connection error';
  static const String errorAuthentication = 'Authentication failed';
  static const String errorBiometric = 'Biometric authentication failed';
  static const String errorDeviceRooted = 'Device is rooted/jailbroken';
  static const String errorProvisioningFailed = 'Provisioning failed';

  // Success Messages
  static const String successProvisioning = 'Device provisioned successfully';
  static const String successAuthentication = 'Authentication successful';
  static const String successBiometric = 'Biometric authentication successful';

  // Validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  static const int provisionCodeLength = 10;
  static const int siteIdMinLength = 1;
  static const int siteIdMaxLength = 20;

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Regex Patterns
  static const String usernamePattern = r'^[a-zA-Z0-9._-]+$';
  static const String siteIdPattern = r'^[a-zA-Z0-9]+$';
  static const String hostnamePattern = r'^[a-zA-Z0-9.-]+$';

  // Default Values
  static const String defaultConnectionType = 'HTTPS';
  static const int defaultPort = 443;
  static const String defaultDeviceOs = 'FLUTTER';
  static const String defaultVersion = '3.6';

  // Hive Box Names
  static const String hiveBoxSsDetail = 'ss_detail_box';
  static const String hiveBoxSas = 'sas_box';
  static const String hiveBoxOAuth = 'oauth_box';
  static const String hiveBoxSettings = 'settings_box';

  // Shared Preferences Keys
  static const String prefBiometricEnabled = 'biometric_enabled';
  static const String prefPushEnabled = 'push_enabled';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefLastSync = 'last_sync';

  // Private constructor to prevent instantiation
  AppConstants._();
}
