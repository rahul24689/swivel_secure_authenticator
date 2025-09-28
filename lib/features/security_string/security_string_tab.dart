import 'package:flutter/material.dart';
import '../../shared/models/models.dart';
import '../../core/database/dao/sas_dao.dart';
import '../../core/database/dao/ss_detail_dao.dart';
import '../../shared/widgets/security_string_card.dart';
import 'security_string_grid_screen.dart';

class SecurityStringTab extends StatefulWidget {
  const SecurityStringTab({super.key});

  @override
  State<SecurityStringTab> createState() => _SecurityStringTabState();
}

class _SecurityStringTabState extends State<SecurityStringTab> {
  final SasDao _sasDao = SasDao();
  final SsDetailDao _ssDetailDao = SsDetailDao();
  
  List<SasEntity> _sasAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSasAccounts();
  }

  Future<void> _loadSasAccounts() async {
    try {
      final accounts = await _sasDao.getAll();
      if (mounted) {
        setState(() {
          _sasAccounts = accounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading security strings: $e')),
        );
      }
    }
  }

  Future<void> _addSecurityString() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddSecurityStringDialog(),
    );

    if (result != null) {
      try {
        // Create SS Detail first
        final ssDetail = SsDetailEntity(
          id: 0, // Will be auto-generated
          sasId: 0, // Will be updated after SAS creation
          securityString: result['securityString']!,
          pinValue: result['pin'],
          isPinFree: result['pin']?.isEmpty ?? true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          hostname: result['serverUrl']!,
          port: 443,
          connectionType: 'HTTPS',
          siteId: 'default',
        );

        final ssDetailId = await _ssDetailDao.insert(ssDetail);

        // Create SAS account
        final newSas = SasEntity(
          id: 0, // Will be auto-generated
          accountName: result['accountName']!,
          serverUrl: result['serverUrl']!,
          username: result['username']!,
          provisionCode: 'manual_provision',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _sasDao.insert(newSas, ssDetailId);
        await _loadSasAccounts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Security string added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding security string: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteSecurityString(SasEntity sas) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Security String'),
        content: Text('Are you sure you want to delete "${sas.accountName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _sasDao.delete(sas.id!);
        await _loadSasAccounts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Security string deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting security string: $e')),
          );
        }
      }
    }
  }

  Future<void> _showSecurityStringGrid(SasEntity sas) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SecurityStringGridScreen(sas: sas),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sasAccounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Security Strings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add your first security string',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addSecurityString,
              icon: const Icon(Icons.add),
              label: const Text('Add Security String'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSasAccounts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sasAccounts.length,
        itemBuilder: (context, index) {
          final sas = _sasAccounts[index];
          return SecurityStringCard(
            sas: sas,
            onTap: () => _showSecurityStringGrid(sas),
            onDelete: () => _deleteSecurityString(sas),
          );
        },
      ),
    );
  }
}

class AddSecurityStringDialog extends StatefulWidget {
  const AddSecurityStringDialog({super.key});

  @override
  State<AddSecurityStringDialog> createState() => _AddSecurityStringDialogState();
}

class _AddSecurityStringDialogState extends State<AddSecurityStringDialog> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _securityStringController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isPinFree = true;

  @override
  void dispose() {
    _accountNameController.dispose();
    _serverUrlController.dispose();
    _usernameController.dispose();
    _securityStringController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Security String'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  hintText: 'e.g., My Company Account',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serverUrlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'https://server.example.com',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a server URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _securityStringController,
                decoration: const InputDecoration(
                  labelText: 'Security String',
                  hintText: '99 character security string',
                ),
                maxLength: 99,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a security string';
                  }
                  if (value.length != 99) {
                    return 'Security string must be exactly 99 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('PIN-Free Mode'),
                subtitle: const Text('Use without PIN authentication'),
                value: _isPinFree,
                onChanged: (value) {
                  setState(() {
                    _isPinFree = value;
                  });
                },
              ),
              if (!_isPinFree) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (!_isPinFree && (value == null || value.trim().isEmpty)) {
                      return 'Please enter a PIN';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'accountName': _accountNameController.text.trim(),
                'serverUrl': _serverUrlController.text.trim(),
                'username': _usernameController.text.trim(),
                'securityString': _securityStringController.text.trim(),
                'pin': _isPinFree ? null : _pinController.text.trim(),
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
