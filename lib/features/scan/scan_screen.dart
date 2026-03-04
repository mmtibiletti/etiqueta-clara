import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear producto'),
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          if (_isProcessing) return;

          final barcode = barcodeCapture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            _isProcessing = true;

            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}