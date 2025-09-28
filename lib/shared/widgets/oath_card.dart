import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/oath_service.dart';

class OATHCard extends StatefulWidget {
  final OAuthEntity token;
  final VoidCallback? onDelete;

  const OATHCard({
    super.key,
    required this.token,
    this.onDelete,
  });

  @override
  State<OATHCard> createState() => _OATHCardState();
}

class _OATHCardState extends State<OATHCard> {
  String _currentCode = '';
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _updateCode();
    _startTimer();
  }

  void _updateCode() {
    try {
      final now = DateTime.now();
      final code = OathService.generateTOTPForOAuth(widget.token, time: now);
      final secondsSinceEpoch = now.millisecondsSinceEpoch ~/ 1000;
      final remaining = widget.token.period - (secondsSinceEpoch % widget.token.period);

      setState(() {
        _currentCode = code;
        _remainingSeconds = remaining;
      });
    } catch (e) {
      setState(() {
        _currentCode = 'ERROR';
        _remainingSeconds = 0;
      });
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateCode();
        _startTimer();
      }
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('TOTP code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _remainingSeconds / widget.token.period;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _copyToClipboard,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Issuer icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Issuer and account info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.token.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.token.issuer.isNotEmpty)
                          Text(
                            widget.token.issuer,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copyToClipboard,
                        tooltip: 'Copy code',
                      ),
                      if (widget.onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: widget.onDelete,
                          color: theme.colorScheme.error,
                          tooltip: 'Delete token',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // TOTP code
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        _formatCode(_currentCode),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Timer
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      children: [
                        // Background circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                        ),
                        
                        // Progress circle
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _remainingSeconds <= 5
                                ? Colors.red
                                : theme.primaryColor,
                          ),
                        ),

                        // Timer text
                        Center(
                          child: Text(
                            '$_remainingSeconds',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _remainingSeconds <= 5
                                  ? Colors.red
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3)}';
    }
    return code;
  }
}
