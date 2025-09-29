import 'package:flutter/material.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/services/ss_detail_service.dart';
import '../../shared/models/models.dart';

/// OTC (One Time Code) list screen for Security String authentication
/// Converted from OtcListFragment.java
class OtcListScreen extends StatefulWidget {
  const OtcListScreen({super.key});

  @override
  State<OtcListScreen> createState() => _OtcListScreenState();
}

class _OtcListScreenState extends State<OtcListScreen> {
  List<SsDetailEntity> _otcAccounts = [];
  List<SsDetailEntity> _filteredAccounts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOtcAccounts();
  }

  Future<void> _loadOtcAccounts() async {
    setState(() => _isLoading = true);
    
    try {
      final service = SsDetailServiceImpl();
      final accounts = await service.list();
      setState(() {
        _otcAccounts = accounts;
        _filteredAccounts = accounts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading OTC accounts: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterAccounts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredAccounts = _otcAccounts;
      } else {
        _filteredAccounts = _otcAccounts
            .where((account) => 
                account.description.toLowerCase().contains(query.toLowerCase()) ||
                account.hostname.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _deleteAccount(SsDetailEntity account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete ${account.description}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = SsDetailServiceImpl();
        await service.delete(account);
        await _loadOtcAccounts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
  }

  void _openSecurityStringGrid(SsDetailEntity account) {
    Navigator.pushNamed(
      context, 
      '/security_string_grid',
      arguments: account,
    );
  }

  Widget _buildAccountItem(SsDetailEntity account) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: account.usingSsl ? Colors.green : Colors.orange,
          child: Icon(
            account.usingSsl ? Icons.lock : Icons.lock_open,
            color: Colors.white,
          ),
        ),
        title: Text(
          account.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${account.hostname}:${account.port}'),
            if (account.siteId.isNotEmpty)
              Text('Site ID: ${account.siteId}'),
            Row(
              children: [
                if (account.usingSsl)
                  const Chip(
                    label: Text('SSL', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                if (account.pushSupport)
                  const Chip(
                    label: Text('Push', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                if (account.isLocal)
                  const Chip(
                    label: Text('Local', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.grey,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'open':
                _openSecurityStringGrid(account);
                break;
              case 'delete':
                _deleteAccount(account);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Text('Open Security String'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () => _openSecurityStringGrid(account),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'OTC Accounts',
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search accounts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterAccounts,
            ),
          ),
          
          // Account list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAccounts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.security, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No OTC accounts found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Scan a QR code to add your first account',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOtcAccounts,
                        child: ListView.builder(
                          itemCount: _filteredAccounts.length,
                          itemBuilder: (context, index) {
                            return _buildAccountItem(_filteredAccounts[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/qr_scanner', arguments: {'type': 'provision'});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
