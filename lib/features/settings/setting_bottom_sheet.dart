import 'package:flutter/material.dart';
import '../../shared/models/models.dart';
import '../../shared/services/services.dart';
import '../../core/security/encryption_service.dart';

/// Setting bottom sheet dialog for displaying server and policy information
/// Converted from SettingFragment.java
class SettingBottomSheet extends StatefulWidget {
  final OathDto? oathDto;
  final OtcDto? otcDto;

  const SettingBottomSheet({
    super.key,
    this.oathDto,
    this.otcDto,
  });

  @override
  State<SettingBottomSheet> createState() => _SettingBottomSheetState();
}

class _SettingBottomSheetState extends State<SettingBottomSheet> {
  SsDetailEntity? _serverDetail;
  List<PolicyEntity> _policies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Server Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (_serverDetail != null)
            _buildServerInfo(),
        ],
      ),
    );
  }

  Widget _buildServerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Server Information
        _buildInfoCard(),
        const SizedBox(height: 16),

        // Policies List
        if (_policies.isNotEmpty) _buildPoliciesList(),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Server Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow('Server', _getDecryptedHostname()),
            const SizedBox(height: 8),
            
            _buildInfoRow('Application', _serverDetail!.connectionType ?? 'N/A'),
            const SizedBox(height: 8),
            
            _buildInfoRow('Port', _serverDetail!.port?.toString() ?? 'N/A'),
            const SizedBox(height: 8),
            
            _buildSSLRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildSSLRow() {
    final isSSLEnabled = _serverDetail!.isUsingSsl ?? false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 80,
          child: Text(
            'SSL:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            isSSLEnabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              color: isSSLEnabled ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPoliciesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Policies',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _policies.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final policy = _policies[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    policy.description ?? 'Policy ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: Text(
                    policy.content ?? 'No content',
                    style: const TextStyle(color: Colors.blue),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Load server detail and policies data
  Future<void> _loadData() async {
    try {
      final ssDetailService = SsDetailService();
      
      int? detailId;
      if (widget.oathDto != null) {
        detailId = widget.oathDto!.id;
      } else if (widget.otcDto != null) {
        detailId = widget.otcDto!.id;
      }

      if (detailId != null) {
        _serverDetail = await ssDetailService.getById(detailId);
        
        if (_serverDetail?.sasEntity != null) {
          final policyService = PolicyService();
          _policies = await policyService.getBySasEntity(_serverDetail!.sasEntity!);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Get decrypted hostname or fallback to original
  String _getDecryptedHostname() {
    if (_serverDetail?.hostname == null) return 'N/A';
    
    try {
      // Try to decrypt the hostname using the encryption service
      return EncryptionService.decrypt(_serverDetail!.hostname!);
    } catch (e) {
      // If decryption fails, return the original hostname
      return _serverDetail!.hostname!;
    }
  }

  /// Show the setting bottom sheet
  static void show(
    BuildContext context, {
    OathDto? oathDto,
    OtcDto? otcDto,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SettingBottomSheet(
        oathDto: oathDto,
        otcDto: otcDto,
      ),
    );
  }
}
