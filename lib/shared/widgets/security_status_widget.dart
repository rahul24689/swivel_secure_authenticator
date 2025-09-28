import 'package:flutter/material.dart';
import '../../core/security/root_detection_service.dart';

class SecurityStatusWidget extends StatefulWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SecurityStatusWidget({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<SecurityStatusWidget> createState() => _SecurityStatusWidgetState();
}

class _SecurityStatusWidgetState extends State<SecurityStatusWidget> {
  RootDetectionResult? _rootResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSecurityStatus();
  }

  Future<void> _checkSecurityStatus() async {
    try {
      final result = await RootDetectionService.getDetailedRootInfo();
      if (mounted) {
        setState(() {
          _rootResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Checking device security...'),
            ],
          ),
        ),
      );
    }

    if (_rootResult == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 12),
              Text('Unable to verify device security'),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isSecure = !_rootResult!.isRooted;
    final statusColor = isSecure ? Colors.green : Colors.red;
    final statusIcon = isSecure ? Icons.security : Icons.warning;
    final statusText = isSecure ? 'Device Secure' : 'Security Risk Detected';

    return Card(
      color: isSecure ? null : Colors.red.shade50,
      child: InkWell(
        onTap: widget.onTap ?? () => _showSecurityDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!isSecure)
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              if (!isSecure) ...[
                const SizedBox(height: 8),
                Text(
                  'Root/jailbreak detected. This may compromise app security.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              ],
              if (widget.showDetails && _rootResult!.checks.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Security Checks:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._rootResult!.checks.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        entry.value ? Icons.close : Icons.check,
                        size: 16,
                        color: entry.value ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSecurityDetails(BuildContext context) {
    if (_rootResult == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _rootResult!.isRooted ? Icons.warning : Icons.security,
              color: _rootResult!.isRooted ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(_rootResult!.isRooted ? 'Security Warning' : 'Device Secure'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_rootResult!.isRooted) ...[
              Text(
                'Your device appears to be rooted/jailbroken. This may compromise the security of your authentication data.',
                style: TextStyle(color: Colors.red.shade700),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Platform: ${_rootResult!.platform}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Security Checks:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ..._rootResult!.checks.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    entry.value ? Icons.close : Icons.check,
                    size: 18,
                    color: entry.value ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(entry.key),
                  ),
                  Text(
                    entry.value ? 'FAIL' : 'PASS',
                    style: TextStyle(
                      color: entry.value ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (_rootResult!.isRooted)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _refreshSecurityCheck();
              },
              child: const Text('Recheck'),
            ),
        ],
      ),
    );
  }

  Future<void> _refreshSecurityCheck() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await RootDetectionService.refreshRootDetection();
      final detailedResult = await RootDetectionService.getDetailedRootInfo();
      
      if (mounted) {
        setState(() {
          _rootResult = detailedResult;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result ? 'Security risk still detected' : 'Device security verified',
            ),
            backgroundColor: result ? Colors.red : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking security: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
