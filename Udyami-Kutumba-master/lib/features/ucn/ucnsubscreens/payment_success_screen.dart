import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/utils/session_manager.dart';
import '../../home/presentation/main_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String userName;
  final String userPhone;
  final String userEmail;
  final String planName;
  final String priceStr;
  final String paymentId;
  final String dateStr;
  final String memberId;

  const PaymentSuccessScreen({
    super.key,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.planName,
    required this.priceStr,
    required this.paymentId,
    required this.dateStr,
    required this.memberId,
  });

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating receipt...')),
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'PAYMENT RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF1E293B),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 32),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Udyami Kutumba', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                          pw.Text('Membership Subscription'),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 14)),
                          pw.Text('Payment ID: $paymentId', style: const pw.TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 24),
                  pw.Text('Billed To:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  pw.SizedBox(height: 8),
                  pw.Text(userName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Mobile: $userPhone', style: const pw.TextStyle(fontSize: 14)),
                  if (userEmail.isNotEmpty && userEmail != 'N/A')
                    pw.Text('Email: $userEmail', style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 32),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF4F6F9),
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    padding: const pw.EdgeInsets.all(16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Order Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 16),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                            pw.Text('Amount (INR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                          ],
                        ),
                        pw.Divider(color: PdfColors.grey400),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('$planName Subscription', style: const pw.TextStyle(fontSize: 16)),
                            pw.Text('Rs. $priceStr', style: const pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                        pw.SizedBox(height: 16),
                        pw.Divider(color: PdfColors.grey400),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Paid', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1E293B))),
                            pw.Text('Rs. $priceStr', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0F766E))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 16),
                  pw.Center(
                    child: pw.Text('Thank you for being a part of Udyami Kutumba!', style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Receipt generated! Opening share sheet...'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );

        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'Receipt_$paymentId.pdf',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate receipt.')),
        );
      }
    }
  }

  Widget _buildSummaryRow(String title, String value, {bool isCurrency = false, bool isBold = false, Widget? customValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: customValue ?? Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold || isCurrency ? FontWeight.bold : FontWeight.w500,
                  color: isCurrency ? Colors.green.shade700 : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse the date
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(dateStr);
    } catch (_) {
      parsedDate = DateTime.now();
    }
    
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    final validToDate = DateFormat('dd MMM yyyy').format(parsedDate.add(const Duration(days: 365)));
    final validFromDate = DateFormat('dd MMM yyyy').format(parsedDate);
    final validityStr = '$validFromDate – $validToDate';
    
    final displayMemberId = (memberId.isNotEmpty && memberId != 'N/A') ? memberId : 'UKM-${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-00000';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Payment Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _downloadReceipt(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Successful Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Successful!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Thank you for your payment.\nYour membership has been upgraded successfully.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text('Completed', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Payment Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.teal.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Payment Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Transaction ID', paymentId),
                  _buildSummaryRow('Date & Time', formattedDate),
                  _buildSummaryRow('Payment Method', 'Online Payment (Razorpay)'),
                  _buildSummaryRow('Paid By', userName),
                  _buildSummaryRow('Amount Paid', '₹ $priceStr', isCurrency: true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Membership Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.deepPurple.shade400, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Membership Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Plan Name', 
                    planName, 
                    customValue: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        planName,
                        style: TextStyle(color: Colors.deepPurple.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    )
                  ),
                  _buildSummaryRow('Membership ID', displayMemberId),
                  _buildSummaryRow('Validity', validityStr),
                  _buildSummaryRow(
                    'Status', 
                    'Active',
                    customValue: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text('Active', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your membership is now active.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 13),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'You can now access all premium features and services.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadReceipt(context),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Go to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
