import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/services/oath_service.dart';
import '../../shared/models/models.dart';

class QRScannerScreen extends StatefulWidget {
  final QRScanType scanType;
  
  const QRScannerScreen({
    super.key,
    this.scanType = QRScanType.oath,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _hasPermission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        setState(() {
          _hasPermission = true;
          _controller = MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates,
            facing: CameraFacing.back,
            torchEnabled: false,
          );
        });
      } else {
        setState(() {
          _errorMessage = 'Camera permission is required to scan QR codes';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_hasPermission && _controller != null)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _controller!.toggleTorch(),
            ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  String _getTitle() {
    switch (widget.scanType) {
      case QRScanType.oath:
        return 'Scan OATH QR Code';
      case QRScanType.provision:
        return 'Scan Provision QR Code';
      case QRScanType.securityString:
        return 'Scan Security String QR Code';
    }
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_hasPermission) {
      return _buildPermissionWidget();
    }

    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _controller!,
          onDetect: _onQRCodeDetected,
        ),
        _buildOverlay(),
        if (_isProcessing) _buildProcessingOverlay(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Scanner Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializeScanner();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Permission Required',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please grant camera permission to scan QR codes',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeScanner,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QRScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getInstructions(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Processing QR Code...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInstructions() {
    switch (widget.scanType) {
      case QRScanType.oath:
        return 'Position the OATH QR code within the frame to add a new token';
      case QRScanType.provision:
        return 'Position the provision QR code within the frame to set up your account';
      case QRScanType.securityString:
        return 'Position the security string QR code within the frame';
    }
  }

  void _onQRCodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _processQRCode(code);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to process QR code: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processQRCode(String code) async {
    switch (widget.scanType) {
      case QRScanType.oath:
        await _processOATHCode(code);
        break;
      case QRScanType.provision:
        await _processProvisionCode(code);
        break;
      case QRScanType.securityString:
        await _processSecurityStringCode(code);
        break;
    }
  }

  Future<void> _processOATHCode(String code) async {
    try {
      // Parse OATH URI (otpauth://totp/...)
      final uri = Uri.parse(code);
      
      if (uri.scheme != 'otpauth') {
        throw Exception('Invalid OATH QR code format');
      }

      final oauthEntity = await OathService.parseOATHUri(code);
      await OathService.addOATHToken(oauthEntity);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OATH token added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      throw Exception('Failed to add OATH token: $e');
    }
  }

  Future<void> _processProvisionCode(String code) async {
    try {
      // Parse provision QR code format
      final parts = code.split('|');
      if (parts.length < 3) {
        throw Exception('Invalid provision QR code format');
      }

      final provisionInfo = ProvisionInfoEntity(
        siteId: parts[0],
        username: parts[1],
        provisionCode: parts[2],
      );

      // For now, we'll just return the provision info
      // In a full implementation, this would call the provision API

      if (mounted) {
        Navigator.pop(context, provisionInfo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Provision QR code scanned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      throw Exception('Failed to provision account: $e');
    }
  }

  Future<void> _processSecurityStringCode(String code) async {
    try {
      // Process security string QR code
      // This would depend on the specific format used
      
      if (mounted) {
        Navigator.pop(context, code);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security string scanned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      throw Exception('Failed to process security string: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// QR Scanner overlay shape
class QRScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QRScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path cutOut = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      );
    return Path.combine(PathOperation.difference, path, cutOut);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final mBorderLength = borderLength > cutOutSize / 2 + borderOffset
        ? borderWidthSize / 2
        : borderLength;
    final mCutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - mCutOutSize / 2 + borderOffset,
      rect.top + height / 2 - mCutOutSize / 2 + borderOffset,
      mCutOutSize - borderOffset * 2,
      mCutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        boxPaint,
      )
      ..restore();

    // Draw corner borders
    final path = Path()
      // Top left
      ..moveTo(cutOutRect.left - borderOffset, cutOutRect.top + mBorderLength)
      ..lineTo(cutOutRect.left - borderOffset, cutOutRect.top)
      ..lineTo(cutOutRect.left + mBorderLength, cutOutRect.top)
      // Top right
      ..moveTo(cutOutRect.right - mBorderLength, cutOutRect.top)
      ..lineTo(cutOutRect.right + borderOffset, cutOutRect.top)
      ..lineTo(cutOutRect.right + borderOffset, cutOutRect.top + mBorderLength)
      // Bottom right
      ..moveTo(cutOutRect.right + borderOffset, cutOutRect.bottom - mBorderLength)
      ..lineTo(cutOutRect.right + borderOffset, cutOutRect.bottom)
      ..lineTo(cutOutRect.right - mBorderLength, cutOutRect.bottom)
      // Bottom left
      ..moveTo(cutOutRect.left + mBorderLength, cutOutRect.bottom)
      ..lineTo(cutOutRect.left - borderOffset, cutOutRect.bottom)
      ..lineTo(cutOutRect.left - borderOffset, cutOutRect.bottom - mBorderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QRScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

/// Types of QR codes that can be scanned
enum QRScanType {
  oath,
  provision,
  securityString,
}
