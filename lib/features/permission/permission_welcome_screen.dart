import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/widgets/base_screen.dart';

/// Permission welcome screen for requesting necessary permissions
/// Converted from PermissionWelcomeFragment.java
class PermissionWelcomeScreen extends StatefulWidget {
  const PermissionWelcomeScreen({super.key});

  @override
  State<PermissionWelcomeScreen> createState() => _PermissionWelcomeScreenState();
}

class _PermissionWelcomeScreenState extends State<PermissionWelcomeScreen> {
  bool _isRequestingPermissions = false;
  
  final List<PermissionInfo> _permissions = [
    PermissionInfo(
      permission: Permission.camera,
      title: 'Camera Access',
      description: 'Required to scan QR codes for account setup',
      icon: Icons.camera_alt,
    ),
    PermissionInfo(
      permission: Permission.notification,
      title: 'Notifications',
      description: 'Receive push notifications for authentication requests',
      icon: Icons.notifications,
    ),
    PermissionInfo(
      permission: Permission.storage,
      title: 'Storage Access',
      description: 'Store encrypted authentication data securely',
      icon: Icons.storage,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Permissions Required',
      showBackButton: false,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Welcome message
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Welcome to Swivel Secure Mobile Authenticator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            const Text(
              'To provide you with the best security experience, we need access to the following permissions:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Permissions list
            Expanded(
              child: ListView.builder(
                itemCount: _permissions.length,
                itemBuilder: (context, index) {
                  return _buildPermissionItem(_permissions[index]);
                },
              ),
            ),

            // Action buttons
            const SizedBox(height: 24),
            
            if (_isRequestingPermissions)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _requestPermissions,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Grant Permissions',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _skipPermissions,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Skip for Now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(PermissionInfo permissionInfo) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(
                permissionInfo.icon,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permissionInfo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    permissionInfo.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    setState(() => _isRequestingPermissions = true);

    try {
      final Map<Permission, PermissionStatus> statuses = 
          await _permissions.map((p) => p.permission).toList().request();

      bool allGranted = true;
      for (final status in statuses.values) {
        if (!status.isGranted) {
          allGranted = false;
          break;
        }
      }

      if (allGranted) {
        _navigateToNextScreen();
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting permissions: $e')),
        );
      }
    } finally {
      setState(() => _isRequestingPermissions = false);
    }
  }

  void _skipPermissions() {
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Some permissions were denied. You can grant them later in the app settings to enable full functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToNextScreen();
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class PermissionInfo {
  final Permission permission;
  final String title;
  final String description;
  final IconData icon;

  PermissionInfo({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
  });
}
