import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/cache_config.dart';

class RootDetectionService {
  static const MethodChannel _channel = MethodChannel('com.ss.ams/security');
  
  // Common root detection file paths
  static const List<String> _rootPaths = [
    '/system/app/Superuser.apk',
    '/sbin/su',
    '/system/bin/su',
    '/system/xbin/su',
    '/data/local/xbin/su',
    '/data/local/bin/su',
    '/system/sd/xbin/su',
    '/system/bin/failsafe/su',
    '/data/local/su',
    '/su/bin/su',
    '/system/xbin/busybox',
    '/system/bin/busybox',
    '/data/local/xbin/busybox',
    '/data/local/bin/busybox',
    '/system/xbin/daemonsu',
    '/system/etc/init.d/99SuperSUDaemon',
    '/dev/com.koushikdutta.superuser.daemon/',
    '/system/app/SuperSU.apk',
    '/system/app/SuperSU',
    '/system/app/SuperUser.apk',
    '/system/app/SuperUser',
    '/cache/su',
    '/data/su',
    '/dev/su',
  ];

  // Common root management apps
  static const List<String> _rootApps = [
    'com.noshufou.android.su',
    'com.noshufou.android.su.elite',
    'eu.chainfire.supersu',
    'com.koushikdutta.superuser',
    'com.thirdparty.superuser',
    'com.yellowes.su',
    'com.koushikdutta.rommanager',
    'com.koushikdutta.rommanager.license',
    'com.dimonvideo.luckypatcher',
    'com.chelpus.lackypatch',
    'com.ramdroid.appquarantine',
    'com.ramdroid.appquarantinepro',
    'com.android.vending.billing.InAppBillingService.COIN',
    'com.android.vending.billing.InAppBillingService.LUCK',
    'com.chelpus.luckypatcher',
    'com.blackmartalpha',
    'org.blackmart.market',
    'com.allinone.free',
    'com.repodroid.app',
    'org.creeplays.hack',
    'com.baseappfull.fwd',
    'com.zmapp',
    'com.dv.adm',
    'org.sbtools.gamehack',
    'com.skgames.traffikrider',
    'com.android.vending.billing.InAppBillingService.LACK',
    'com.android.vendinc',
    'uret.jasi2169.patcher',
    'com.dimonvideo.luckypatcher',
    'com.forpda.lp',
    'com.android.vending.billing.InAppBillingService.RUSAPP',
    'com.zacharee1.systemuituner',
    'com.topjohnwu.magisk',
  ];

  // Dangerous properties
  static const List<String> _dangerousProps = [
    'ro.debuggable',
    'ro.secure',
    'service.adb.root',
    'ro.build.selinux',
  ];

  /// Check if device is rooted/jailbroken
  static Future<bool> isDeviceRooted() async {
    try {
      // Check cached result first
      if (CacheConfig.contain('root_check_result')) {
        return CacheConfig.isRooted();
      }

      bool isRooted = false;

      if (Platform.isAndroid) {
        isRooted = await _checkAndroidRoot();
      } else if (Platform.isIOS) {
        isRooted = await _checkIOSJailbreak();
      }

      // Cache the result
      await CacheConfig.setRooted(isRooted);
      
      return isRooted;
    } catch (e) {
      // If detection fails, assume not rooted but log the error
      return false;
    }
  }

  /// Check Android root
  static Future<bool> _checkAndroidRoot() async {
    // Check 1: Look for common root files
    if (await _checkRootFiles()) {
      return true;
    }

    // Check 2: Look for root management apps
    if (await _checkRootApps()) {
      return true;
    }

    // Check 3: Check system properties
    if (await _checkSystemProperties()) {
      return true;
    }

    // Check 4: Try to execute su command
    if (await _checkSuCommand()) {
      return true;
    }

    // Check 5: Check build tags
    if (await _checkBuildTags()) {
      return true;
    }

    // Check 6: Use native method if available
    try {
      final result = await _channel.invokeMethod('isRooted');
      if (result == true) {
        return true;
      }
    } catch (e) {
      // Native method not available, continue with other checks
    }

    return false;
  }

  /// Check iOS jailbreak
  static Future<bool> _checkIOSJailbreak() async {
    // Check 1: Look for common jailbreak files
    final jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
      '/private/var/lib/cydia',
      '/private/var/mobile/Library/SBSettings/Themes',
      '/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist',
      '/usr/libexec/ssh-keysign',
      '/var/cache/apt',
      '/var/lib/apt',
      '/var/lib/cydia',
      '/usr/sbin/frida-server',
      '/usr/bin/cycript',
      '/usr/local/bin/cycript',
      '/usr/lib/libcycript.dylib',
      '/System/Library/LaunchDaemons/com.ikey.bbot.plist',
      '/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist',
      '/var/cache/apt/',
      '/var/lib/apt/',
      '/var/lib/cydia/',
      '/usr/sbin/frida-server',
      '/usr/bin/cycript',
      '/usr/local/bin/cycript',
      '/usr/lib/libcycript.dylib',
    ];

    for (final path in jailbreakPaths) {
      if (await File(path).exists()) {
        return true;
      }
    }

    // Check 2: Try to write to system directories
    try {
      final testFile = File('/private/test_jailbreak.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true; // If we can write to /private, device is jailbroken
    } catch (e) {
      // Expected behavior on non-jailbroken device
    }

    // Check 3: Use native method if available
    try {
      final result = await _channel.invokeMethod('isJailbroken');
      if (result == true) {
        return true;
      }
    } catch (e) {
      // Native method not available
    }

    return false;
  }

  /// Check for root files
  static Future<bool> _checkRootFiles() async {
    for (final path in _rootPaths) {
      try {
        if (await File(path).exists()) {
          return true;
        }
      } catch (e) {
        // Continue checking other paths
      }
    }
    return false;
  }

  /// Check for root apps
  static Future<bool> _checkRootApps() async {
    try {
      final result = await _channel.invokeMethod('checkRootApps', {'packages': _rootApps});
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Check system properties
  static Future<bool> _checkSystemProperties() async {
    try {
      final result = await _channel.invokeMethod('checkSystemProperties', {'properties': _dangerousProps});
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Check su command
  static Future<bool> _checkSuCommand() async {
    try {
      final result = await Process.run('which', ['su']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Check build tags
  static Future<bool> _checkBuildTags() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      final tags = androidInfo.tags.toLowerCase();
      return tags.contains('test-keys') || tags.contains('dev-keys');
    } catch (e) {
      return false;
    }
  }

  /// Force refresh root detection
  static Future<bool> refreshRootDetection() async {
    await CacheConfig.remove('root_check_result');
    return await isDeviceRooted();
  }

  /// Get detailed root detection information
  static Future<RootDetectionResult> getDetailedRootInfo() async {
    final checks = <String, bool>{};
    
    if (Platform.isAndroid) {
      checks['Root Files'] = await _checkRootFiles();
      checks['Root Apps'] = await _checkRootApps();
      checks['System Properties'] = await _checkSystemProperties();
      checks['Su Command'] = await _checkSuCommand();
      checks['Build Tags'] = await _checkBuildTags();
    } else if (Platform.isIOS) {
      checks['Jailbreak Files'] = await _checkIOSJailbreak();
    }

    final isRooted = checks.values.any((result) => result);
    
    return RootDetectionResult(
      isRooted: isRooted,
      checks: checks,
      platform: Platform.operatingSystem,
    );
  }

  /// Check if app should block functionality due to root
  static Future<bool> shouldBlockDueToRoot() async {
    final isRooted = await isDeviceRooted();
    // In production, you might want to make this configurable
    return isRooted;
  }
}

/// Result class for detailed root detection information
class RootDetectionResult {
  final bool isRooted;
  final Map<String, bool> checks;
  final String platform;

  RootDetectionResult({
    required this.isRooted,
    required this.checks,
    required this.platform,
  });

  @override
  String toString() {
    return 'RootDetectionResult(isRooted: $isRooted, platform: $platform, checks: $checks)';
  }
}
