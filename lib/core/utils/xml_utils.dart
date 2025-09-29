import 'dart:convert';
import 'dart:typed_data';
import 'package:xml/xml.dart';

/// XML utility functions
/// Converted from XmlUtils.java
class XmlUtils {
  static const String defaultNamespaceUri = 'https://www.swivelsecure.com/xsd';
  static const String defaultPrefix = 'ns';

  /// Get node value from XML using XPath-like expression
  static String? getNodeValue(String xmlString, String expression) {
    try {
      final document = XmlDocument.parse(xmlString);
      
      // Simple XPath-like navigation
      final parts = expression.split('/').where((part) => part.isNotEmpty).toList();
      XmlNode? current = document;
      
      for (final part in parts) {
        if (current is XmlDocument) {
          current = current.rootElement;
        }
        
        if (current is XmlElement) {
          // Handle namespace prefix
          String elementName = part;
          if (part.contains(':')) {
            elementName = part.split(':').last;
          }
          
          current = current.children
              .whereType<XmlElement>()
              .firstWhere(
                (element) => element.name.local == elementName,
                orElse: () => throw Exception('Element not found: $elementName'),
              );
        }
      }
      
      if (current is XmlElement) {
        return current.innerText;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get node value: $e');
    }
  }

  /// Get node value with custom namespace
  static String? getNodeValueWithNamespace(
    String xmlString, 
    String expression, 
    String namespaceUri, 
    String prefix
  ) {
    try {
      final document = XmlDocument.parse(xmlString);
      
      // For now, use the same logic as getNodeValue
      // In a full implementation, you'd handle namespaces properly
      return getNodeValue(xmlString, expression);
    } catch (e) {
      throw Exception('Failed to get node value with namespace: $e');
    }
  }

  /// Convert byte array to formatted XML string
  static String formatXml(Uint8List bytes) {
    try {
      final xmlString = utf8.decode(bytes);
      final document = XmlDocument.parse(xmlString);
      return document.toXmlString(pretty: true, indent: '  ');
    } catch (e) {
      throw Exception('Failed to format XML: $e');
    }
  }

  /// Convert input stream to formatted XML string
  static String formatXmlFromStream(Stream<List<int>> stream) {
    // This would need to be async in a real implementation
    throw UnimplementedError('Stream processing not implemented');
  }

  /// Parse XML and return list of elements
  static List<XmlElement> parseToList(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      return document.descendants.whereType<XmlElement>().toList();
    } catch (e) {
      throw Exception('Failed to parse XML to list: $e');
    }
  }

  /// Validate XML string
  static bool isValidXml(String xmlString) {
    try {
      XmlDocument.parse(xmlString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extract text content from XML
  static String extractTextContent(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      return document.rootElement.innerText;
    } catch (e) {
      throw Exception('Failed to extract text content: $e');
    }
  }

  /// Get all elements with specific tag name
  static List<XmlElement> getElementsByTagName(String xmlString, String tagName) {
    try {
      final document = XmlDocument.parse(xmlString);
      return document.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == tagName)
          .toList();
    } catch (e) {
      throw Exception('Failed to get elements by tag name: $e');
    }
  }

  /// Get attribute value from element
  static String? getAttributeValue(XmlElement element, String attributeName) {
    try {
      return element.getAttribute(attributeName);
    } catch (e) {
      return null;
    }
  }

  /// Create XML element
  static XmlElement createElement(String name, {String? text, Map<String, String>? attributes}) {
    final element = XmlElement(XmlName(name));
    
    if (text != null) {
      element.children.add(XmlText(text));
    }
    
    if (attributes != null) {
      for (final entry in attributes.entries) {
        element.setAttribute(entry.key, entry.value);
      }
    }
    
    return element;
  }

  /// Convert XML document to string
  static String documentToString(XmlDocument document, {bool pretty = false}) {
    return document.toXmlString(pretty: pretty, indent: pretty ? '  ' : null);
  }

  /// Parse XML with namespace handling
  static XmlDocument parseWithNamespace(String xmlString) {
    try {
      return XmlDocument.parse(xmlString);
    } catch (e) {
      throw Exception('Failed to parse XML with namespace: $e');
    }
  }
}
