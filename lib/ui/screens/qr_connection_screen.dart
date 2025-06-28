import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class QRConnectionScreen extends StatefulWidget {
  const QRConnectionScreen({super.key});

  @override
  State<QRConnectionScreen> createState() => _QRConnectionScreenState();
}

class _QRConnectionScreenState extends State<QRConnectionScreen> {
  bool _scanned = false;
  String? _error;

  void _onQRViewScanned(String code) async {
    if (_scanned) return; // prevent multiple scans
    setState(() => _scanned = true);

    try {
      final Map<String, dynamic> qrData = Map<String, dynamic>.from(
        jsonDecode(code),
      );

      final response = await http.post(
        Uri.parse('http://192.168.10.149:5000/verify-device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': qrData['device_id'],
          'auth_key': qrData['auth_key'],
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        setState(() {
          _error = 'Invalid QR Code. Please try again.';
          _scanned = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error connecting to fridge: Invalid QR Code. Please try again.';
        _scanned = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Fridge')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  _onQRViewScanned(code);
                }
              }
            },
          ),
          if (_scanned) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 20)),
              ),
            ),
        ],
      ),
    );
  }
}
