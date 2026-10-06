import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/api/ubn/gratitude_api.dart';
import '../../../core/models/gratitude_model.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class UcnStatsScreen extends StatefulWidget {
  const UcnStatsScreen({super.key});

  @override
  State<UcnStatsScreen> createState() => _UcnStatsScreenState();
}

class _UcnStatsScreenState extends State<UcnStatsScreen> {
  bool _isLoading = true;
  int _givenCount = 0;
  int _receivedCount = 0;
  double _totalValueGiven = 0.0;
  double _totalValueReceived = 0.0;
  String? _currentUserId;

  List<GratitudeModel> _slips = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final userData = SessionManager.user;
      if (userData != null) {
        _currentUserId = userData['userId'];
      }

      if (_currentUserId != null) {
        final slips = await GratitudeAPI.getAllGratitudeSlips();
        
        int given = 0;
        int received = 0;
        double givenValue = 0.0;
        double receivedValue = 0.0;
        
        for (var slip in slips) {
          if (slip.createdUser?.userId == _currentUserId) {
            given++;
            givenValue += slip.businessValue;
          }
          if (slip.thankYouMember?.userId == _currentUserId) {
            received++;
            receivedValue += slip.businessValue;
          }
        }
        
        setState(() {
          _slips = slips.where((s) => s.createdUser?.userId == _currentUserId || s.thankYouMember?.userId == _currentUserId).toList();
          _givenCount = given;
          _receivedCount = received;
          _totalValueGiven = givenValue;
          _totalValueReceived = receivedValue;
        });
      }
    } catch (e) {
      print('DEV DEBUG - error fetching ucn stats: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FC),
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: const Text('UCN Data'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatCard(
                  'Gratitude Given',
                  _givenCount.toString(),
                  '₹${_totalValueGiven.toStringAsFixed(0)}',
                  Icons.arrow_upward,
                  Colors.orange,
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  'Gratitude Received',
                  _receivedCount.toString(),
                  '₹${_totalValueReceived.toStringAsFixed(0)}',
                  Icons.arrow_downward,
                  Colors.green,
                  isDark,
                ),
                const SizedBox(height: 24),
                Text(
                  'Gratitude Slips Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (_slips.isEmpty)
                  const Text('No UCN slips found.')
                else
                  ..._slips.map((s) => _buildSlipCard(s, isDark)),
              ],
            ),
    );
  }

  Widget _buildSlipCard(GratitudeModel slip, bool isDark) {
    bool isGiven = slip.createdUser?.userId == _currentUserId;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGiven ? Icons.arrow_upward : Icons.arrow_downward,
                color: isGiven ? Colors.orange : Colors.green,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isGiven ? 'Given to ${slip.thankYouMember?.name ?? 'Unknown'}' : 'Received from ${slip.createdUser?.name ?? 'Unknown'}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Type: ${slip.type}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Value: ₹${slip.businessValue.toStringAsFixed(0)}',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (slip.utrNo != null && slip.utrNo!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'UTR: ${slip.utrNo}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String amount, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$count slips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
