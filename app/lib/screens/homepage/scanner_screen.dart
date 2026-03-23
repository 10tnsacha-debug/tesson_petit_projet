import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isHandlingScan = false;
  String? _errorMessage;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isHandlingScan) return;

    final Barcode? barcode = capture.barcodes.isNotEmpty
        ? capture.barcodes.first
        : null;

    final String? rawValue = barcode?.rawValue;

    if (rawValue == null || rawValue.isEmpty) {
      setState(() {
        _errorMessage = 'Code-barres invalide.';
      });
      return;
    }

    _isHandlingScan = true;

    try {
      await _controller.stop();

      if (!mounted) return;
      Navigator.of(context).pop(rawValue);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erreur lors du scan : $e';
      });

      _isHandlingScan = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Scanner un produit')),
      body: Stack(
        children: <Widget>[
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_errorMessage != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Placez le code-barres dans le cadre',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
