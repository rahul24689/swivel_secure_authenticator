import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/services/oath_service.dart';
import '../../shared/models/models.dart';
import '../../core/utils/date_utils.dart';

/// OATH token list screen
/// Converted from OathListFragment.java
class OathListScreen extends StatefulWidget {
  const OathListScreen({super.key});

  @override
  State<OathListScreen> createState() => _OathListScreenState();
}

class _OathListScreenState extends State<OathListScreen> {
  List<OAuthEntity> _oathTokens = [];
  List<OAuthEntity> _filteredTokens = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadOathTokens();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOathTokens() async {
    setState(() => _isLoading = true);
    
    try {
      final tokens = await OathService.getAllTokens();
      setState(() {
        _oathTokens = tokens;
        _filteredTokens = tokens;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading OATH tokens: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Update remaining time for each token
        });
      }
    });
  }

  void _filterTokens(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTokens = _oathTokens;
      } else {
        _filteredTokens = _oathTokens
            .where((token) => 
                token.issuer.toLowerCase().contains(query.toLowerCase()) ||
                token.accountName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _copyToClipboard(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copied to clipboard')),
      );
    }
  }

  Future<void> _deleteToken(OAuthEntity token) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Token'),
        content: Text('Are you sure you want to delete ${token.issuer}?'),
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
        await OathService.deleteToken(token.id!);
        await _loadOathTokens();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting token: $e')),
          );
        }
      }
    }
  }

  Widget _buildTokenItem(OAuthEntity token) {
    final currentCode = OathService.generateTOTP(token);
    final remainingTime = DateUtils.getTimeUntilNext30Seconds();
    final progress = remainingTime / 30.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(token.issuer.isNotEmpty ? token.issuer[0].toUpperCase() : 'T'),
        ),
        title: Text(
          token.issuer,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(token.accountName),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  currentCode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${remainingTime}s'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'copy':
                _copyToClipboard(currentCode);
                break;
              case 'delete':
                _deleteToken(token);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy',
              child: Text('Copy Code'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () => _copyToClipboard(currentCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'OATH Tokens',
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search tokens...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterTokens,
            ),
          ),
          
          // Token list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTokens.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No OATH tokens found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Scan a QR code to add your first token',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOathTokens,
                        child: ListView.builder(
                          itemCount: _filteredTokens.length,
                          itemBuilder: (context, index) {
                            return _buildTokenItem(_filteredTokens[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/qr_scanner', arguments: {'type': 'oath'});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
