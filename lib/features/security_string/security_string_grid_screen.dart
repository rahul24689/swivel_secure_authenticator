import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/models/models.dart';
import '../../shared/services/security_string_service.dart';
import '../../shared/services/biometric_service.dart';
import '../../core/database/dao/ss_detail_dao.dart';

class SecurityStringGridScreen extends StatefulWidget {
  final SasEntity sas;

  const SecurityStringGridScreen({
    super.key,
    required this.sas,
  });

  @override
  State<SecurityStringGridScreen> createState() => _SecurityStringGridScreenState();
}

class _SecurityStringGridScreenState extends State<SecurityStringGridScreen> {
  final SsDetailDao _ssDetailDao = SsDetailDao();
  final SecurityStringService _securityStringService = SecurityStringService();
  
  SsDetailEntity? _ssDetail;
  List<String> _securityCodes = [];
  Set<int> _usedIndices = {};
  bool _isLoading = true;
  bool _showPinDialog = false;
  String _enteredPin = '';

  @override
  void initState() {
    super.initState();
    _authenticateAndLoad();
  }

  Future<void> _authenticateAndLoad() async {
    try {
      // Check if biometric authentication is available and enabled
      final biometricCapability = await BiometricService.getBiometricCapability();

      if (biometricCapability.canAuthenticate) {
        final isAuthenticated = await BiometricService.authenticateForSecurityStrings();
        if (!isAuthenticated) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric authentication required to access security strings'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      await _loadSecurityString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _loadSecurityString() async {
    try {
      final ssDetails = await _ssDetailDao.getBySasId(widget.sas.id!);
      if (ssDetails.isNotEmpty) {
        final ssDetail = ssDetails.first;
        setState(() {
          _ssDetail = ssDetail;
          _securityCodes = _generateSecurityCodes(ssDetail.securityString);
          _isLoading = false;
        });
        
        // Load used indices
        await _loadUsedIndices();
        
        // Check if PIN is required
        if (!ssDetail.isPinFree) {
          _showPinDialog = true;
          _showPinAuthDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading security string: $e')),
        );
      }
    }
  }

  Future<void> _loadUsedIndices() async {
    try {
      final usedStrings = await _securityStringService.getUsedSecurityStrings(widget.sas.id!);
      setState(() {
        _usedIndices = usedStrings.map((s) => s.tokenIndex).toSet();
      });
    } catch (e) {
      // Handle error silently
    }
  }

  List<String> _generateSecurityCodes(String securityString) {
    if (securityString.length != 99) {
      return List.generate(99, (index) => '?');
    }
    
    List<String> codes = [];
    for (int i = 0; i < 99; i += 2) {
      if (i + 1 < securityString.length) {
        codes.add(securityString.substring(i, i + 2));
      } else {
        codes.add(securityString.substring(i));
      }
    }
    return codes;
  }

  void _showPinAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('PIN Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your PIN to access the security string:'),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _enteredPin = value;
              },
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_enteredPin == _ssDetail?.pinValue) {
                Navigator.of(context).pop();
                setState(() {
                  _showPinDialog = false;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN')),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _onCodeTap(int index) {
    if (_showPinDialog) {
      _showPinAuthDialog();
      return;
    }

    final code = _securityCodes[index];
    
    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: code));
    
    // Mark as used
    _markCodeAsUsed(index);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code $code copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _markCodeAsUsed(int index) async {
    try {
      // Find or create security string entity for this index
      final securityStrings = await _securityStringService.getAllSecurityStrings(widget.sas.id!);
      SecurityStringEntity? targetString;

      for (final ss in securityStrings) {
        if (ss.tokenIndex == index) {
          targetString = ss;
          break;
        }
      }

      if (targetString != null && targetString.id != null) {
        await _securityStringService.markSecurityStringAsUsed(targetString.id!);
        setState(() {
          _usedIndices.add(index);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.sas.accountName),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_ssDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.sas.accountName),
        ),
        body: const Center(
          child: Text('Security string not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sas.accountName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Security String Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account: ${widget.sas.accountName}'),
                      Text('Username: ${widget.sas.username}'),
                      Text('Server: ${widget.sas.serverUrl}'),
                      Text('Mode: ${_ssDetail!.isPinFree ? 'PIN-Free' : 'PIN Protected'}'),
                      Text('Used Codes: ${_usedIndices.length}/99'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _showPinDialog
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'PIN Required',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please enter your PIN to access the security codes',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap any code to copy it to clipboard. Used codes are marked in red.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                        childAspectRatio: 1,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _securityCodes.length,
                      itemBuilder: (context, index) {
                        final isUsed = _usedIndices.contains(index);
                        final code = _securityCodes[index];
                        
                        return GestureDetector(
                          onTap: () => _onCodeTap(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isUsed 
                                  ? Colors.red.withOpacity(0.1)
                                  : Theme.of(context).colorScheme.primaryContainer,
                              border: Border.all(
                                color: isUsed 
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                code,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isUsed 
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
