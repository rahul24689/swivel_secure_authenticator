class Assets {
  // Images
  static const String _imagesPath = 'assets/images';
  static const String bgPermission = '$_imagesPath/bg_permission.png';
  static const String panelBackground = '$_imagesPath/panel__background.jpg';
  static const String playStore = '$_imagesPath/play_store.png';
  static const String playStoreRound = '$_imagesPath/play_store_round.png';
  static const String swivelPoweredByLarge = '$_imagesPath/swivel_powered_by_large.png';
  static const String swivelPoweredBySmall = '$_imagesPath/swivel_powered_by_small.png';
  static const String swivelSecureLarge = '$_imagesPath/swivel_secure_large.png';
  static const String swivelSecureSmall = '$_imagesPath/swivel_secure_small.png';

  // Lottie animations
  static const String _lottiePath = 'assets/lottie';
  static const String fileTransferAnimation = '$_lottiePath/filestransferlottieanimation.json';
  static const String qrCodeScannerAnimation = '$_lottiePath/qrcodescanneranimation.json';
  static const String qrCodeScanningAnimation = '$_lottiePath/qrcodescanning.json';
  static const String securitySystemAnimation = '$_lottiePath/securitysystem.json';
  static const String syncAnimation = '$_lottiePath/sync.json';

  // Icons (if any custom icons are added)
  static const String _iconsPath = 'assets/icons';

  // Fonts (if any custom fonts are added)
  static const String _fontsPath = 'assets/fonts';

  // Helper methods
  static String getImagePath(String imageName) {
    return '$_imagesPath/$imageName';
  }

  static String getLottiePath(String animationName) {
    return '$_lottiePath/$animationName';
  }

  static String getIconPath(String iconName) {
    return '$_iconsPath/$iconName';
  }

  static String getFontPath(String fontName) {
    return '$_fontsPath/$fontName';
  }

  // Asset validation
  static List<String> getAllAssets() {
    return [
      // Images
      bgPermission,
      panelBackground,
      playStore,
      playStoreRound,
      swivelPoweredByLarge,
      swivelPoweredBySmall,
      swivelSecureLarge,
      swivelSecureSmall,
      
      // Lottie animations
      fileTransferAnimation,
      qrCodeScannerAnimation,
      qrCodeScanningAnimation,
      securitySystemAnimation,
      syncAnimation,
    ];
  }

  // Asset categories
  static List<String> getImages() {
    return [
      bgPermission,
      panelBackground,
      playStore,
      playStoreRound,
      swivelPoweredByLarge,
      swivelPoweredBySmall,
      swivelSecureLarge,
      swivelSecureSmall,
    ];
  }

  static List<String> getLottieAnimations() {
    return [
      fileTransferAnimation,
      qrCodeScannerAnimation,
      qrCodeScanningAnimation,
      securitySystemAnimation,
      syncAnimation,
    ];
  }
}
