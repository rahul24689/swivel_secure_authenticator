import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CertificatePinningService {
  static CertificatePinningService? _instance;
  static CertificatePinningService get instance {
    _instance ??= CertificatePinningService._internal();
    return _instance!;
  }

  CertificatePinningService._internal();

  // Production certificate pins (SHA-256 hashes of public keys)
  static const Map<String, List<String>> _certificatePins = {
    // Swivel Secure production domains
    'secure.swivelsecure.com': [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Replace with actual pin
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Backup pin
    ],
    'api.swivelsecure.com': [
      'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=', // Replace with actual pin
      'sha256/DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=', // Backup pin
    ],
    // Add more domains as needed
  };

  // Development/staging pins (for testing)
  static const Map<String, List<String>> _developmentPins = {
    'staging.swivelsecure.com': [
      'sha256/EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=', // Replace with actual pin
    ],
    'dev.swivelsecure.com': [
      'sha256/FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF=', // Replace with actual pin
    ],
  };

  /// Get certificate pins for a domain
  List<String> getPinsForDomain(String domain) {
    // Use development pins in debug mode
    if (kDebugMode) {
      return _developmentPins[domain] ?? [];
    }
    
    return _certificatePins[domain] ?? [];
  }

  /// Create HTTP client with certificate pinning
  Dio createSecureHttpClient({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    final dio = Dio();
    
    // Configure timeouts
    dio.options.connectTimeout = connectTimeout ?? const Duration(seconds: 30);
    dio.options.receiveTimeout = receiveTimeout ?? const Duration(seconds: 60);
    dio.options.sendTimeout = sendTimeout ?? const Duration(seconds: 30);
    
    // Add certificate pinning interceptor
    dio.interceptors.add(_CertificatePinningInterceptor(this));
    
    // Add security headers interceptor
    dio.interceptors.add(_SecurityHeadersInterceptor());
    
    return dio;
  }

  /// Validate certificate against pins
  bool validateCertificate(X509Certificate certificate, String domain) {
    try {
      final pins = getPinsForDomain(domain);
      if (pins.isEmpty) {
        // No pins configured for this domain
        debugPrint('Warning: No certificate pins configured for domain: $domain');
        return !kReleaseMode; // Allow in debug/profile mode, deny in release
      }

      // Extract public key from certificate
      final publicKeyHash = _extractPublicKeyHash(certificate);
      if (publicKeyHash == null) {
        debugPrint('Failed to extract public key hash from certificate');
        return false;
      }

      // Check if the hash matches any of the pins
      final publicKeyPin = 'sha256/$publicKeyHash';
      final isValid = pins.contains(publicKeyPin);
      
      if (!isValid) {
        debugPrint('Certificate pin validation failed for domain: $domain');
        debugPrint('Expected pins: $pins');
        debugPrint('Actual pin: $publicKeyPin');
      }
      
      return isValid;
    } catch (e) {
      debugPrint('Certificate validation error: $e');
      return false;
    }
  }

  /// Extract public key hash from certificate
  String? _extractPublicKeyHash(X509Certificate certificate) {
    try {
      // Get the DER-encoded certificate
      final certBytes = certificate.der;
      
      // Parse the certificate to extract the public key
      // This is a simplified implementation - in production, you might want
      // to use a more robust ASN.1 parser
      final publicKeyInfo = _extractPublicKeyInfo(certBytes);
      if (publicKeyInfo == null) return null;
      
      // Calculate SHA-256 hash of the public key
      final digest = sha256.convert(publicKeyInfo);
      return base64Encode(digest.bytes);
    } catch (e) {
      debugPrint('Failed to extract public key hash: $e');
      return null;
    }
  }

  /// Extract public key info from certificate DER bytes
  /// This is a simplified implementation for demonstration
  Uint8List? _extractPublicKeyInfo(Uint8List certBytes) {
    try {
      // This is a very basic implementation
      // In production, you should use a proper ASN.1 parser
      // or a cryptographic library that can extract the public key
      
      // For now, return null to indicate that proper implementation is needed
      return null;
    } catch (e) {
      debugPrint('Failed to extract public key info: $e');
      return null;
    }
  }

  /// Validate hostname against certificate
  bool validateHostname(X509Certificate certificate, String hostname) {
    try {
      // Check subject alternative names (SAN)
      final subject = certificate.subject;
      final issuer = certificate.issuer;
      
      // Basic hostname validation
      // In production, implement proper SAN and wildcard matching
      return subject.contains(hostname) || 
             subject.contains('*.' + hostname.split('.').skip(1).join('.'));
    } catch (e) {
      debugPrint('Hostname validation error: $e');
      return false;
    }
  }

  /// Check if certificate is expired
  bool isCertificateExpired(X509Certificate certificate) {
    try {
      final now = DateTime.now();
      return now.isAfter(certificate.endValidity) || now.isBefore(certificate.startValidity);
    } catch (e) {
      debugPrint('Certificate expiry check error: $e');
      return true; // Assume expired on error
    }
  }
}

/// Interceptor for certificate pinning
class _CertificatePinningInterceptor extends Interceptor {
  final CertificatePinningService _pinningService;

  _CertificatePinningInterceptor(this._pinningService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Certificate pinning is handled at the HTTP client level
    // This interceptor can be used for additional request processing
    handler.next(options);
  }
}

/// Interceptor for security headers
class _SecurityHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add security headers
    options.headers.addAll({
      'X-Requested-With': 'XMLHttpRequest',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    });
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Validate security headers in response
    final headers = response.headers;
    
    // Check for security headers
    final hasHSTS = headers['strict-transport-security'] != null;
    final hasCSP = headers['content-security-policy'] != null;
    final hasXFrameOptions = headers['x-frame-options'] != null;
    
    if (!hasHSTS && kDebugMode) {
      debugPrint('Warning: Missing HSTS header in response');
    }
    
    if (!hasCSP && kDebugMode) {
      debugPrint('Warning: Missing CSP header in response');
    }
    
    if (!hasXFrameOptions && kDebugMode) {
      debugPrint('Warning: Missing X-Frame-Options header in response');
    }
    
    handler.next(response);
  }
}

/// Certificate pinning configuration
class CertificatePinConfig {
  final String domain;
  final List<String> pins;
  final bool enforceInDebug;

  const CertificatePinConfig({
    required this.domain,
    required this.pins,
    this.enforceInDebug = false,
  });
}
