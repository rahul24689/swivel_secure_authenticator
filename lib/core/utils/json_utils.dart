import 'dart:convert';

/// JSON utility functions
/// Converted from JsonUtils.java
class JsonUtils {
  /// Convert object to JSON string
  static String toJson(dynamic object) {
    try {
      return jsonEncode(object);
    } catch (e) {
      throw Exception('Failed to convert object to JSON: $e');
    }
  }

  /// Parse JSON string to dynamic object
  static dynamic fromJson(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Failed to parse JSON string: $e');
    }
  }

  /// Parse JSON string to Map
  static Map<String, dynamic> fromJsonToMap(String jsonString) {
    try {
      final result = jsonDecode(jsonString);
      if (result is Map<String, dynamic>) {
        return result;
      } else {
        throw Exception('JSON is not a Map');
      }
    } catch (e) {
      throw Exception('Failed to parse JSON to Map: $e');
    }
  }

  /// Parse JSON string to List
  static List<dynamic> fromJsonToList(String jsonString) {
    try {
      final result = jsonDecode(jsonString);
      if (result is List<dynamic>) {
        return result;
      } else {
        throw Exception('JSON is not a List');
      }
    } catch (e) {
      throw Exception('Failed to parse JSON to List: $e');
    }
  }

  /// Check if string is valid JSON
  static bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pretty print JSON string
  static String prettyPrint(dynamic object) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(object);
    } catch (e) {
      throw Exception('Failed to pretty print JSON: $e');
    }
  }

  /// Merge two JSON objects
  static Map<String, dynamic> merge(Map<String, dynamic> json1, Map<String, dynamic> json2) {
    final result = Map<String, dynamic>.from(json1);
    json2.forEach((key, value) {
      result[key] = value;
    });
    return result;
  }

  /// Get value from JSON path (simple dot notation)
  static dynamic getValue(Map<String, dynamic> json, String path) {
    final keys = path.split('.');
    dynamic current = json;
    
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    
    return current;
  }
}
