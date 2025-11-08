import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/food_api.dart';
import '../models/food_item.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  final _api = FoodApi();
  bool _busy = false;
  String? _lastCode;

  Future<void> _handleCode(String code) async {
    if (_busy || code.isEmpty || code == _lastCode) return;
    setState(() {
      _busy = true;
      _lastCode = code;
    });

    final item = await _api.getFoodByBarcode(code);

    if (!mounted) return;
    if (item != null) {
      Navigator.pop<FoodItem>(context, item);
    } else {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No product found for this barcode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final code = capture.barcodes.first.rawValue ?? '';
              _handleCode(code);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white38, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (_busy)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
