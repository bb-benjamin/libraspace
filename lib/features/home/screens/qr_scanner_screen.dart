import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/models/visit_record_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  final String libraryId;
  final String libraryName;

  const QrScannerScreen({
    required this.libraryId,
    required this.libraryName,
    Key? key,
  }) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _camera = MobileScannerController();
  bool _processing = false;

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void _onQrDetected(BarcodeCapture capture) async {
    if (_processing) return;

    final String? rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null) return;

    const String prefix = 'LIBRASPACE:LIB:';

    if (!rawValue.startsWith(prefix)) {
      _showMsg('This is not a LibraSpace QR code.', isError: true);
      return;
    }

    final String scannedLibraryId = rawValue.replaceFirst(prefix, '');

    if (scannedLibraryId != widget.libraryId) {
      _showMsg(
        'Wrong library! Please scan THIS library\'s QR code.',
        isError: true,
      );
      return;
    }

    setState(() => _processing = true);
    await _camera.stop();

    try {
      final auth = context.read<AuthProvider>();
      final String userId = auth.currentUser?.uid ?? '';

      if (userId.isEmpty) {
        _showMsg('You must be logged in to check in.', isError: true);
        return;
      }

      final service = FirebaseService();
      final DateTime now = DateTime.now();

      await service.checkIn(userId: userId, libraryId: widget.libraryId);

      final String recordId = '${userId}_${now.millisecondsSinceEpoch}';

      await service.saveVisitRecord(
        VisitRecord(
          recordId: recordId,
          userId: userId,
          libraryId: widget.libraryId,
          libraryName: widget.libraryName,
          checkInTime: now,
        ),
      );

      await service.recordVisitForPrediction(
        libraryId: widget.libraryId,
        hour: now.hour,
        dayOfWeek: now.weekday,
      );

      _showMsg('✅ Checked in to ${widget.libraryName}!', isError: false);

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      final String errorMsg = e.toString().contains('full')
          ? 'Sorry, this library is now full.'
          : 'Check-in failed. Please try again.';
      _showMsg(errorMsg, isError: true);
      setState(() => _processing = false);
      await _camera.start();
    }
  }

  void _showMsg(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.heatRed : AppColors.heatGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _camera.toggleTorch(),
            tooltip: 'Toggle flashlight',
          ),
        ],
      ),

      body: Stack(
        children: [
          MobileScanner(controller: _camera, onDetect: _onQrDetected),

          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.black.withValues(alpha: 0.6),
              child: const Text(
                'Point the camera at the library\'s QR code',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          if (_processing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
