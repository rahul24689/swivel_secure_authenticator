import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/security_status_widget.dart';
import '../../shared/services/sync_service.dart';
import '../settings/settings_screen.dart';
import '../qr_scanner/qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SecurityStringTab(),
    const OATHTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Security status banner
          const Padding(
            padding: EdgeInsets.all(16),
            child: SecurityStatusWidget(),
          ),
          // Main content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Security Strings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'OATH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Authentication'),
        content: const Text('Choose how to add authentication:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _scanQRCode(QRScanType.oath);
            },
            child: const Text('Scan OATH QR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _scanQRCode(QRScanType.provision);
            },
            child: const Text('Scan Provision QR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addManually();
            },
            child: const Text('Add Manually'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync'),
            onTap: () {
              Navigator.pop(context);
              _syncData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup'),
            onTap: () {
              Navigator.pop(context);
              _backupData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAbout();
            },
          ),
        ],
      ),
    );
  }

  void _scanQRCode(QRScanType scanType) async {
    try {
      final result = await Navigator.push<dynamic>(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(scanType: scanType),
        ),
      );

      if (result != null && mounted) {
        String message;
        switch (scanType) {
          case QRScanType.oath:
            message = 'OATH token added successfully';
            break;
          case QRScanType.provision:
            message = 'Account provisioned successfully';
            break;
          case QRScanType.securityString:
            message = 'Security string added successfully';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addManually() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Manually'),
        content: const Text('Choose authentication type to add manually:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addSecurityString();
            },
            child: const Text('Security String'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addOATH();
            },
            child: const Text('OATH Token'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addSecurityString() {
    // Navigate to security string tab
    setState(() {
      _selectedIndex = 0; // Security String tab is at index 0
    });
  }

  void _addOATH() {
    // Navigate to OATH tab
    setState(() {
      _selectedIndex = 1; // OATH tab is at index 1
    });
  }

  void _syncData() async {
    if (!mounted) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Syncing...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final syncResult = await SyncService.instance.syncAllTokenIndexes();

      if (!mounted) return;

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (syncResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(syncResult.message ?? 'Sync completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(syncResult.error ?? 'Sync failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _backupData() {
    // Navigate to settings tab where backup functionality is available
    setState(() {
      _selectedIndex = 2; // Settings tab is at index 2
    });
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.security, size: 48),
      children: [
        const Text('Swivel Secure Mobile Authenticator'),
        const Text('Enterprise-grade multi-factor authentication'),
      ],
    );
  }
}

class SecurityStringTab extends StatelessWidget {
  const SecurityStringTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Security Strings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first security string',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class OATHTab extends StatelessWidget {
  const OATHTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No OATH Tokens',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first OATH token',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Biometric Authentication'),
                subtitle: const Text('Use fingerprint or face recognition'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Handle biometric toggle
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive push authentication requests'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Handle push notifications toggle
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security'),
                subtitle: const Text('Security settings and device status'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                subtitle: const Text('Get help and contact support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to help screen
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
