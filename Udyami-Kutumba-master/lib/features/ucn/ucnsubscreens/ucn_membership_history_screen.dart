import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api/membership/membership_purchase_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/ui/full_screen_pdf_viewer.dart';

class UcnMembershipHistoryScreen extends StatefulWidget {
  const UcnMembershipHistoryScreen({super.key});

  @override
  State<UcnMembershipHistoryScreen> createState() => _UcnMembershipHistoryScreenState();
}

class _UcnMembershipHistoryScreenState extends State<UcnMembershipHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _history = [];
  Map<String, dynamic>? _activePlan;
  final _api = MembershipPurchaseAPI();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final userId = SessionManager.user?['userId']?.toString();
    if (userId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      }
      return;
    }

    try {
      debugPrint('DEV DEBUG - HistoryScreen - Fetching history for user: $userId');
      final response = await _api.getMembershipHistory(userId);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        debugPrint('DEV DEBUG - HistoryScreen - History API Response Data: $data');

        // Find currently active plan
        Map<String, dynamic>? currentActive;
        final now = DateTime.now();

        for (var item in data) {
          if (item['endDate'] != null) {
            final endDate = DateTime.tryParse(item['endDate'].toString());
            if (endDate != null && endDate.isAfter(now)) {
              if (currentActive == null || endDate.isAfter(DateTime.parse(currentActive['endDate'].toString()))) {
                currentActive = item;
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            _history = data;
            _activePlan = currentActive;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(response?['message'] ?? 'Failed to load history');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _downloadReceipt(Map<String, dynamic> transaction) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fetching receipt from server...')));

      final payment = transaction['payment'] ?? {};
      final paymentId = payment['paymentId']?.toString();

      if (paymentId == null || paymentId.isEmpty) {
        throw Exception("Payment ID not found for this transaction.");
      }

      final pdfBytes = await _api.downloadReceipt(paymentId);

      if (pdfBytes != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenPdfViewer(
                pdfBytes: pdfBytes,
                title: 'Receipt_$paymentId',
              ),
            ),
          );
        }
      } else {
        throw Exception("Failed to download receipt from server.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load receipt: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // OTT Dark Theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Membership History",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
          : _history.isEmpty
          ? _buildEmptyState()
          : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          const Text(
            "No active plans or purchase history.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        if (_activePlan != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildActivePlanCard(_activePlan!),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Transaction History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildHistoryCard(_history[index]);
              },
              childCount: _history.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildActivePlanCard(Map<String, dynamic> activePlan) {
    final plan = activePlan['plan'] ?? {};
    final planName = plan['planName'] ?? 'Unknown Plan';
    final isPrime = plan['membershipType']?.toString().toUpperCase() == 'PRIME';

    final startDateStr = activePlan['startDate']?.toString();
    final endDateStr = activePlan['endDate']?.toString();

    final startDate = startDateStr != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(startDateStr)) : 'N/A';
    final endDate = endDateStr != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(endDateStr)) : 'N/A';

    final daysLeft = endDateStr != null ? DateTime.parse(endDateStr).difference(DateTime.now()).inDays : 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPrime
              ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
              : [const Color(0xFF14B8A6), const Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPrime ? Colors.orange : Colors.teal).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.star_rounded,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "CURRENTLY ACTIVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (daysLeft > 0)
                      Text(
                        "$daysLeft days left",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  planName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateColumn("Activated On", startDate),
                    _buildDateColumn("Valid Until", endDate),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final plan = item['plan'] ?? {};
    final planName = plan['planName'] ?? 'Unknown Plan';
    final priceStr = item['amount']?.toString() ?? plan['price']?.toString() ?? '0';

    final dateStr = item['createdAt']?.toString();
    final date = dateStr != null ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(dateStr)) : 'N/A';

    final isPrime = plan['membershipType']?.toString().toUpperCase() == 'PRIME';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isPrime ? Colors.orange : Colors.teal).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPrime ? Icons.workspace_premium : Icons.stars_rounded,
                    color: isPrime ? Colors.amberAccent : Colors.tealAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹$priceStr",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _downloadReceipt(item),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text("Download Receipt"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade300,
                  side: BorderSide(color: Colors.grey.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}