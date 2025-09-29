import 'dart:convert';

/// Encoding utility functions
/// Converted from EncodeUtils.java
class EncodeUtils {
  /// URL decode a string value
  static String valueOf(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (e) {
      // Return original value if decoding fails
      return value;
    }
  }

  /// URL encode a string value
  static String encode(String value) {
    try {
      return Uri.encodeComponent(value);
    } catch (e) {
      return value;
    }
  }

  /// Base64 encode
  static String base64Encode(String value) {
    try {
      return base64.encode(utf8.encode(value));
    } catch (e) {
      return value;
    }
  }

  /// Base64 decode
  static String base64Decode(String value) {
    try {
      return utf8.decode(base64.decode(value));
    } catch (e) {
      return value;
    }
  }

  /// Check if string is valid base64
  static bool isBase64(String value) {
    try {
      base64.decode(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// HTML encode
  static String htmlEncode(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// HTML decode
  static String htmlDecode(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'");
  }
}
