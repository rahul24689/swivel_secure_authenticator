import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/security/security_manager.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SecurityStatus? _securityStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    try {
      final status = await SecurityManager.instance.performSecurityCheck();
      setState(() {
        _securityStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSecuritySection(),
                const SizedBox(height: 16),
                _buildAuthenticationSection(),
                const SizedBox(height: 16),
                _buildDataSection(),
                const SizedBox(height: 16),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Security',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          
          // Security status
          ListTile(
            leading: Icon(
              _securityStatus?.isSecure == true
                  ? Icons.security
                  : Icons.warning,
              color: _securityStatus?.isSecure == true
                  ? Colors.green
                  : Colors.orange,
            ),
            title: const Text('Device Security Status'),
            subtitle: Text(
              _securityStatus?.isSecure == true
                  ? 'Device is secure'
                  : 'Security issues detected',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showSecurityDetails,
          ),
          
          // Root detection
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Root/Jailbreak Detection'),
            subtitle: const Text('Check for device modifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _checkRootStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticationSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Authentication',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          
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
          
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive authentication requests'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle push notifications toggle
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Export authentication data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _backupData,
          ),
          
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            subtitle: const Text('Import authentication data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _restoreData,
          ),
          
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Remove all authentication data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearAllData,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: Text(AppConstants.appVersion),
          ),
          
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and contact support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showHelp,
          ),
          
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('View privacy policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  void _showSecurityDetails() {
    if (_securityStatus == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Status'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Security Level: ${_securityStatus!.securityLevel.name.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              if (_securityStatus!.errors.isNotEmpty) ...[
                const Text(
                  'Errors:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                ..._securityStatus!.errors.map(
                  (error) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $error'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              if (_securityStatus!.warnings.isNotEmpty) ...[
                const Text(
                  'Warnings:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                ..._securityStatus!.warnings.map(
                  (warning) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $warning'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshSecurityStatus();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _checkRootStatus() {
    // Show root detection details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Root detection check - Coming Soon')),
    );
  }

  void _backupData() {
    showDialog(
      context: context,
      builder: (context) => _BackupDialog(),
    );
  }

  void _restoreData() async {
    try {
      final filePath = await BackupService.importBackupFile();
      if (filePath == null) return;

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _RestoreDialog(filePath: filePath),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting backup file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all authentication data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // Implement clear all data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear all data - Coming Soon')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support - Coming Soon')),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy - Coming Soon')),
    );
  }

  void _refreshSecurityStatus() async {
    setState(() {
      _isLoading = true;
    });
    await _loadSecurityStatus();
  }
}

class _BackupDialog extends StatefulWidget {
  @override
  State<_BackupDialog> createState() => _BackupDialogState();
}

class _BackupDialogState extends State<_BackupDialog> {
  final _passwordController = TextEditingController();
  bool _includeOAuth = true;
  bool _includeSecurityStrings = true;
  bool _includeSettings = true;
  bool _usePassword = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Backup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select data to backup:'),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('OATH Tokens'),
              value: _includeOAuth,
              onChanged: (value) => setState(() => _includeOAuth = value ?? true),
            ),
            CheckboxListTile(
              title: const Text('Security Strings'),
              value: _includeSecurityStrings,
              onChanged: (value) => setState(() => _includeSecurityStrings = value ?? true),
            ),
            CheckboxListTile(
              title: const Text('Settings'),
              value: _includeSettings,
              onChanged: (value) => setState(() => _includeSettings = value ?? true),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Encrypt backup'),
              subtitle: const Text('Protect backup with password'),
              value: _usePassword,
              onChanged: (value) => setState(() => _usePassword = value ?? false),
            ),
            if (_usePassword) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Backup Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createBackup,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Backup'),
        ),
      ],
    );
  }

  void _createBackup() async {
    if (_usePassword && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await BackupService.createBackup(
        password: _usePassword ? _passwordController.text : null,
        includeOAuth: _includeOAuth,
        includeSecurityStrings: _includeSecurityStrings,
        includeSettings: _includeSettings,
      );

      if (mounted) {
        Navigator.of(context).pop();

        if (result.success) {
          await BackupService.shareBackup(result.filePath!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Backup created successfully (${result.itemCount} items)'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Backup failed: ${result.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

class _RestoreDialog extends StatefulWidget {
  final String filePath;

  const _RestoreDialog({required this.filePath});

  @override
  State<_RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<_RestoreDialog> {
  final _passwordController = TextEditingController();
  bool _replaceExisting = false;
  bool _usePassword = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore Backup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Restore from: ${widget.filePath.split('/').last}'),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Replace existing data'),
              subtitle: const Text('Clear all current data before restore'),
              value: _replaceExisting,
              onChanged: (value) => setState(() => _replaceExisting = value ?? false),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Backup is encrypted'),
              subtitle: const Text('Enter password to decrypt'),
              value: _usePassword,
              onChanged: (value) => setState(() => _usePassword = value ?? false),
            ),
            if (_usePassword) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Backup Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _restoreBackup,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Restore'),
        ),
      ],
    );
  }

  void _restoreBackup() async {
    if (_usePassword && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the backup password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await BackupService.restoreBackup(
        filePath: widget.filePath,
        password: _usePassword ? _passwordController.text : null,
        replaceExisting: _replaceExisting,
      );

      if (mounted) {
        Navigator.of(context).pop();

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup restored successfully (${result.restoredItems} items)'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Restore failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
