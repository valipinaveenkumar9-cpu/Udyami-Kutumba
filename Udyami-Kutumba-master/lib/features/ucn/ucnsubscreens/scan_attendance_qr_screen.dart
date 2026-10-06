import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/api/ubn/attendance_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class ScanAttendanceQrScreen extends StatefulWidget {
  const ScanAttendanceQrScreen({super.key});

  @override
  State<ScanAttendanceQrScreen> createState() => _ScanAttendanceQrScreenState();
}

class _ScanAttendanceQrScreenState extends State<ScanAttendanceQrScreen> {
  final AttendanceAPI _attendanceAPI = AttendanceAPI();
  bool _isProcessing = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return null;
    } 

    return await Geolocator.getCurrentPosition();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;
    
    final rawValue = barcodes.first.rawValue!;
    
    setState(() => _isProcessing = true);
    
    // Stop the camera while processing
    cameraController.stop();

    try {
      final qrData = jsonDecode(rawValue);
      final attendanceSessionId = qrData['attendanceSessionId'];
      final qrToken = qrData['qrToken'];

      if (attendanceSessionId == null || qrToken == null) {
        throw const FormatException("Invalid QR format");
      }

      // Get GPS
      final position = await _determinePosition();
      if (position == null) {
        setState(() => _isProcessing = false);
        cameraController.start();
        return;
      }

      final userId = SessionManager.user?['userId'];
      if (userId == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User session not found')));
        setState(() => _isProcessing = false);
        cameraController.start();
        return;
      }

      final payload = {
        "userId": userId,
        "attendanceSessionId": attendanceSessionId,
        "qrToken": qrToken,
        "latitude": position.latitude,
        "longitude": position.longitude
      };

      final response = await _attendanceAPI.scanQR(payload);
      
      if (mounted) {
        if (response != null && response['success'] == true) {
          // Success
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => AlertDialog(
              title: const Text('Success'),
              content: Text(response['message'] ?? 'Attendance marked successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                    Navigator.pop(context); // close scanner
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Failure
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => AlertDialog(
              title: const Text('Scan Failed'),
              content: Text(response?['message'] ?? 'Could not mark attendance.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                    setState(() => _isProcessing = false);
                    cameraController.start(); // Resume scanning
                  },
                  child: const Text('Try Again'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        }
      }

    } catch (e) {
      print('Invalid QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid QR code format. Not an attendance QR.')));
      }
      setState(() => _isProcessing = false);
      cameraController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Attendance QR'),
        actions: [
              const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text(
                      'Validating QR and Location...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
