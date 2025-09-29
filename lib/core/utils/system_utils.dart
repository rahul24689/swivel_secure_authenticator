import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// System utility functions
/// Converted from SystemUtils.java
class SystemUtils {
  /// Play notification sound
  static Future<void> playSound() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  /// Vibrate device
  static Future<void> vibrate([Duration duration = const Duration(milliseconds: 500)]) async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('Error vibrating: $e');
    }
  }

  /// Play light impact haptic feedback
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error with light impact: $e');
    }
  }

  /// Play medium impact haptic feedback
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error with medium impact: $e');
    }
  }

  /// Play heavy impact haptic feedback
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error with heavy impact: $e');
    }
  }

  /// Play selection click haptic feedback
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error with selection click: $e');
    }
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
    }
  }

  /// Get text from clipboard
  static Future<String?> getFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      debugPrint('Error getting from clipboard: $e');
      return null;
    }
  }

  /// Check if clipboard has text
  static Future<bool> hasClipboardText() async {
    try {
      return await Clipboard.hasStrings();
    } catch (e) {
      debugPrint('Error checking clipboard: $e');
      return false;
    }
  }

  /// Show system notification (requires additional setup)
  static void showNotification(String title, String message) {
    // This would require flutter_local_notifications package
    // For now, just log the notification
    debugPrint('Notification: $title - $message');
  }

  /// Get device orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
