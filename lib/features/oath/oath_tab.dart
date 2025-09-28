import 'package:flutter/material.dart';
import 'dart:async';
import '../../shared/models/models.dart';
import '../../shared/services/biometric_service.dart';
import '../../core/database/dao/oauth_dao.dart';
import '../../shared/widgets/oath_card.dart';

class OATHTab extends StatefulWidget {
  const OATHTab({super.key});

  @override
  State<OATHTab> createState() => _OATHTabState();
}

class _OATHTabState extends State<OATHTab> {
  final OAuthDao _oauthDao = OAuthDao();
  List<OAuthEntity> _oauthTokens = [];
  Timer? _refreshTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authenticateAndLoad();
    _startRefreshTimer();
  }

  Future<void> _authenticateAndLoad() async {
    try {
      // Check if biometric authentication is available and enabled
      final biometricCapability = await BiometricService.getBiometricCapability();

      if (biometricCapability.canAuthenticate) {
        final isAuthenticated = await BiometricService.authenticateForOATH();
        if (!isAuthenticated) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric authentication required to access OATH tokens'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      await _loadOAuthTokens();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to update TOTP codes
        });
      }
    });
  }

  Future<void> _loadOAuthTokens() async {
    try {
      final tokens = await _oauthDao.getAll();
      if (mounted) {
        setState(() {
          _oauthTokens = tokens;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading OATH tokens: $e')),
        );
      }
    }
  }

  Future<void> _addOAuthToken() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddOAuthDialog(),
    );

    if (result != null) {
      try {
        final newToken = OAuthEntity(
          id: 0, // Will be auto-generated
          label: result['label']!,
          secret: result['secret']!,
          issuer: result['issuer'] ?? '',
          account: result['label']!,
          username: result['label']!,
          provisionCode: result['secret']!,
          algorithm: 'SHA1',
          digits: 6,
          period: 30,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _oauthDao.insert(newToken);
        await _loadOAuthTokens();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OATH token added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding OATH token: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteOAuthToken(OAuthEntity token) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete OATH Token'),
        content: Text('Are you sure you want to delete "${token.label}"?'),
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
        await _oauthDao.delete(token.id!);
        await _loadOAuthTokens();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OATH token deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting OATH token: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_oauthTokens.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No OATH Tokens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add your first OATH token',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addOAuthToken,
              icon: const Icon(Icons.add),
              label: const Text('Add OATH Token'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOAuthTokens,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _oauthTokens.length,
        itemBuilder: (context, index) {
          final token = _oauthTokens[index];
          return OATHCard(
            token: token,
            onDelete: () => _deleteOAuthToken(token),
          );
        },
      ),
    );
  }
}

class AddOAuthDialog extends StatefulWidget {
  const AddOAuthDialog({super.key});

  @override
  State<AddOAuthDialog> createState() => _AddOAuthDialogState();
}

class _AddOAuthDialogState extends State<AddOAuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _secretController = TextEditingController();
  final _issuerController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _secretController.dispose();
    _issuerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add OATH Token'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., My Account',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a label';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _secretController,
              decoration: const InputDecoration(
                labelText: 'Secret Key',
                hintText: 'Base32 encoded secret',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a secret key';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _issuerController,
              decoration: const InputDecoration(
                labelText: 'Issuer (Optional)',
                hintText: 'e.g., Google, Microsoft',
              ),
            ),
          ],
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
                'label': _labelController.text.trim(),
                'secret': _secretController.text.trim(),
                'issuer': _issuerController.text.trim(),
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
