import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrollcall/pages/report_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedCode;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.purple,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/qrollcall-logo.jpeg',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.view_agenda_outlined),
                  color: Colors.white,
                  onPressed: () async {
                    // Pause scanning
                    controller?.pauseCamera();

                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportPage()),
                    );

                    // Resume scanning when ReportPage is popped
                    controller?.resumeCamera();
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              // color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Created by Shaun Niel Ochavo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  bool isProcessing = false;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isProcessing) {
        isProcessing = true;
        if (scanData.code!.length <= 15) {
          setState(() {
            scannedCode = scanData.code;
          });
          _showDialog(context, 'QR Code Scanned', 'Scanned Code: $scannedCode');

          // Save the QR code, date, and time to the local storage
          final prefs = await SharedPreferences.getInstance();
          final now = DateTime.now();
          final dateFormat = DateFormat('yyyy-MM-dd');
          final timeFormat = DateFormat('HH:mm:ss');

          final scanStr =
              '${dateFormat.format(now)},${timeFormat.format(now)},$scannedCode';
          final scans = prefs.getStringList('scans') ?? [];
          scans.add(scanStr);

          // Save the updated list back to SharedPreferences
          await prefs.setStringList('scans', scans);
        } else {
          _showDialog(
              context, 'Invalid QR Code', 'The provided QR code is invalid.');
        }
      }
    });
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                isProcessing = false;
              },
            ),
          ],
        );
      },
    );
  }
}
