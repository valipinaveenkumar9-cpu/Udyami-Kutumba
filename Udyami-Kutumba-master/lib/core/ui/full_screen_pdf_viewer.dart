import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenPdfViewer extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;

  const FullScreenPdfViewer({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  State<FullScreenPdfViewer> createState() => _FullScreenPdfViewerState();
}

class _FullScreenPdfViewerState extends State<FullScreenPdfViewer> {
  Future<void> _downloadAndSavePdf() async {
    try {
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.request().isGranted || 
            await Permission.storage.request().isGranted) {
          // Permission granted
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Storage permission is required for downloading.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'App Settings',
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving document...'), duration: Duration(seconds: 1)),
        );
      }

      // Generate a clean file name
      final sanitizedTitle = widget.title.replaceAll(RegExp(r'[^\w\s\-]'), '_').replaceAll(' ', '_');
      final fileName = "${sanitizedTitle}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      
      String? path;
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download/Udyami Kutumba/Payment Slips');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        path = "${downloadDir.path}/$fileName";
      } else {
        // Fallback or iOS logic if needed, but per request focusing on Android storage
        return;
      }

      final file = File(path);
      await file.writeAsBytes(widget.pdfBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to Download/Udyami Kutumba/Payment Slips/$fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: _downloadAndSavePdf,
          ),
        ],
      ),
      body: SafeArea(
        child: SfPdfViewer.memory(
          widget.pdfBytes,
          canShowPaginationDialog: true,
          canShowScrollHead: true,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load PDF: ${details.error}')),
            );
          },
        ),
      ),
    );
  }
}
