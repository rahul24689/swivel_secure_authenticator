import 'package:flutter/material.dart';
import '../../shared/widgets/base_screen.dart';

/// Extra menu screen with additional options
/// Converted from ExtraMenuListFragment.java
class ExtraMenuScreen extends StatelessWidget {
  const ExtraMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Menu',
      body: ListView(
        children: [
          _buildMenuSection(
            'Account Management',
            [
              _buildMenuItem(
                icon: Icons.qr_code_scanner,
                title: 'Scan QR Code',
                subtitle: 'Add new account or token',
                onTap: () => Navigator.pushNamed(context, '/qr_scanner'),
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Manual Configuration',
                subtitle: 'Configure account manually',
                onTap: () => Navigator.pushNamed(context, '/manual_config'),
              ),
              _buildMenuItem(
                icon: Icons.sync,
                title: 'Migration',
                subtitle: 'Migrate from previous version',
                onTap: () => Navigator.pushNamed(context, '/migration'),
              ),
            ],
          ),
          
          _buildMenuSection(
            'Security',
            [
              _buildMenuItem(
                icon: Icons.fingerprint,
                title: 'Biometric Settings',
                subtitle: 'Configure biometric authentication',
                onTap: () => Navigator.pushNamed(context, '/biometric_settings'),
              ),
              _buildMenuItem(
                icon: Icons.lock,
                title: 'PIN Settings',
                subtitle: 'Set up PIN protection',
                onTap: () => Navigator.pushNamed(context, '/pin_settings'),
              ),
              _buildMenuItem(
                icon: Icons.security,
                title: 'Security Audit',
                subtitle: 'Review security settings',
                onTap: () => Navigator.pushNamed(context, '/security_audit'),
              ),
            ],
          ),
          
          _buildMenuSection(
            'Application',
            [
              _buildMenuItem(
                icon: Icons.settings,
                title: 'App Settings',
                subtitle: 'Configure application preferences',
                onTap: () => Navigator.pushNamed(context, '/app_settings'),
              ),
              _buildMenuItem(
                icon: Icons.history,
                title: 'Activity Log',
                subtitle: 'View application activity',
                onTap: () => Navigator.pushNamed(context, '/activity_log'),
              ),
              _buildMenuItem(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App information and version',
                onTap: () => Navigator.pushNamed(context, '/about'),
              ),
            ],
          ),
          
          _buildMenuSection(
            'Support',
            [
              _buildMenuItem(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and support',
                onTap: () => Navigator.pushNamed(context, '/help'),
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'View privacy policy',
                onTap: () => Navigator.pushNamed(context, '/privacy'),
              ),
              _buildMenuItem(
                icon: Icons.business,
                title: 'Swivel Secure',
                subtitle: 'Learn more about Swivel Secure',
                onTap: () => Navigator.pushNamed(context, '/swivel_secure'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
