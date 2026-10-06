import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/api/communications/communications_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CommunicationStatsScreen extends StatefulWidget {
  const CommunicationStatsScreen({super.key});

  @override
  State<CommunicationStatsScreen> createState() => _CommunicationStatsScreenState();
}

class _CommunicationStatsScreenState extends State<CommunicationStatsScreen> {
  bool _isLoading = true;
  int _totalCampaigns = 0;
  List<dynamic> _campaigns = [];
  String? _currentUserId;

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
        final response = await CommunicationsAPI().getAllCampaigns(userId: _currentUserId, limit: 100);
        
        if (response != null && response is Map && response['success'] == true) {
          setState(() {
            _campaigns = response['data'] ?? [];
            _totalCampaigns = _campaigns.length;
          });
        }
      }
    } catch (e) {
      print('DEV DEBUG - error fetching comm stats: $e');
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
            title: const Text('Communication Stats'),
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
                  'Total Campaigns',
                  _totalCampaigns.toString(),
                  Icons.campaign,
                  Colors.blue,
                  isDark,
                ),
                const SizedBox(height: 24),
                Text(
                  'Campaign Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (_campaigns.isEmpty)
                  const Text('No campaigns found.')
                else
                  ..._campaigns.map((c) => _buildCampaignCard(c, isDark)),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
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
          Column(
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
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(dynamic campaign, bool isDark) {
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
          Text(
            campaign['name'] ?? 'Unnamed Campaign',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Channel: ${campaign['channel'] ?? 'Unknown'}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${campaign['status'] ?? 'Unknown'}',
            style: TextStyle(
              color: campaign['status'] == 'completed' ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
