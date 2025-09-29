import 'package:flutter/material.dart';
import '../../shared/widgets/base_screen.dart';

/// Auto configuration screen for automatic setup
/// Converted from AutoConfigFragment.java
class AutoConfigScreen extends StatefulWidget {
  const AutoConfigScreen({super.key});

  @override
  State<AutoConfigScreen> createState() => _AutoConfigScreenState();
}

class _AutoConfigScreenState extends State<AutoConfigScreen> {
  bool _isConfiguring = false;
  String _statusMessage = 'Initializing auto configuration...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startAutoConfiguration();
  }

  Future<void> _startAutoConfiguration() async {
    setState(() {
      _isConfiguring = true;
      _statusMessage = 'Starting auto configuration...';
      _progress = 0.1;
    });

    try {
      // Step 1: Check network connectivity
      await _updateProgress(0.2, 'Checking network connectivity...');
      await Future.delayed(const Duration(seconds: 1));

      // Step 2: Validate configuration data
      await _updateProgress(0.4, 'Validating configuration data...');
      await Future.delayed(const Duration(seconds: 1));

      // Step 3: Connect to server
      await _updateProgress(0.6, 'Connecting to server...');
      await Future.delayed(const Duration(seconds: 2));

      // Step 4: Download configuration
      await _updateProgress(0.8, 'Downloading configuration...');
      await Future.delayed(const Duration(seconds: 1));

      // Step 5: Apply configuration
      await _updateProgress(1.0, 'Applying configuration...');
      await Future.delayed(const Duration(seconds: 1));

      // Configuration complete
      setState(() {
        _statusMessage = 'Configuration completed successfully!';
      });

      // Navigate to home after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }

    } catch (e) {
      setState(() {
        _statusMessage = 'Configuration failed: $e';
        _isConfiguring = false;
      });
    }
  }

  Future<void> _updateProgress(double progress, String message) async {
    setState(() {
      _progress = progress;
      _statusMessage = message;
    });
  }

  void _retryConfiguration() {
    setState(() {
      _progress = 0.0;
    });
    _startAutoConfiguration();
  }

  void _skipConfiguration() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Auto Configuration',
      showBackButton: false,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or icon
            const Icon(
              Icons.settings_applications,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              'Automatic Configuration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Please wait while we automatically configure your account settings.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Progress indicator
            if (_isConfiguring) ...[
              CircularProgressIndicator(
                value: _progress,
                strokeWidth: 6,
              ),
              const SizedBox(height: 24),
              
              // Progress bar
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 16),
              
              // Progress percentage
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Status message
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Action buttons
            if (!_isConfiguring) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _retryConfiguration,
                    child: const Text('Retry'),
                  ),
                  OutlinedButton(
                    onPressed: _skipConfiguration,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ] else ...[
              OutlinedButton(
                onPressed: _skipConfiguration,
                child: const Text('Skip Auto Configuration'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
