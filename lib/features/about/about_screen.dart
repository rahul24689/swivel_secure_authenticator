import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/services/biometric_service.dart';
import '../../shared/widgets/base_screen.dart';

/// About screen showing app information
/// Converted from AboutFragment.java
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _buildVersion = '';
  String _copyright = '';
  final BiometricService _biometricService = BiometricService();
  
  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      setState(() {
        _buildVersion = '${packageInfo.buildNumber} (${packageInfo.version})';
        _copyright = 'Swivel Secure Ltd. ${DateUtils.getCurrentYear()}';
      });
    } catch (e) {
      debugPrint('Error loading app info: $e');
    }
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  Future<void> _showBiometricPrompt() async {
    try {
      final isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric authentication not available')),
          );
        }
        return;
      }

      final result = await _biometricService.authenticate(
        reason: 'Authenticate to access app features',
        title: 'Biometric login for my app',
        subtitle: 'Log in using your biometric credential',
        negativeButtonText: 'Use account password',
      );

      if (mounted) {
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication succeeded!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication failed')),
          );
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: $e')),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'About',
      showBackButton: true,
      onBackPressed: _onBackPressed,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Title
            const Text(
              'Swivel Secure Mobile Authenticator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Build Version
            Text(
              'Version: $_buildVersion',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            const Text(
              'Swivel Secure Mobile Authenticator provides secure two-factor authentication '
              'using OATH TOTP tokens and Security String authentication.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            // Features
            const Text(
              'Features:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('• OATH TOTP token generation'),
            const Text('• Security String authentication'),
            const Text('• QR code provisioning'),
            const Text('• Push notifications'),
            const Text('• Biometric authentication'),
            const Text('• Secure encrypted storage'),
            
            const Spacer(),
            
            // Copyright
            Center(
              child: Text(
                _copyright,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Test Biometric Button (for development)
            if (Theme.of(context).brightness == Brightness.light)
              Center(
                child: ElevatedButton(
                  onPressed: _showBiometricPrompt,
                  child: const Text('Test Biometric'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
