import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/api/ubn/lead_api.dart';
import 'package:udyamikutumba/core/models/lead_model.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udyamikutumba/features/ucn/ucnsubscreens/lead_detail_screen.dart';

class MemberLeadsScreen extends StatefulWidget {
  final String memberId;
  final String memberName;

  const MemberLeadsScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<MemberLeadsScreen> createState() => _MemberLeadsScreenState();
}

class _MemberLeadsScreenState extends State<MemberLeadsScreen> {
  bool _isLoading = true;
  List<LeadModel> _leads = [];

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    try {
      final allLeads = await LeadAPI.getAllLeads();
      final currentUserId = SessionManager.token != null ? await _getUserId() : null;
      final currentUserName = SessionManager.user?['name']?.toString().toLowerCase().trim() ?? '';

      setState(() {
        _leads = allLeads.where((lead) {
          final isToMember = lead.memberName.toLowerCase().trim() == widget.memberName.toLowerCase().trim();
          final isFromMember = lead.createdUser?['userId'] == widget.memberId;
          
          final isToMe = lead.memberName.toLowerCase().trim() == currentUserName;
          final isFromMe = lead.createdUser?['userId'] == currentUserId;

          return (isToMember && isFromMe) || (isFromMember && isToMe);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print("Error fetching leads: $e");
    }
  }

  Future<String?> _getUserId() async {
     try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('user_id');
     } catch (e) {
        return null;
     }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.indigo;
      case 'contacted':
        return Colors.orange;
      case 'closed':
      case 'converted':
        return Colors.teal;
      case 'declined':
        return Colors.red;
      case 'pending':
      case 'sent':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Leads with ${widget.memberName}",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leads.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "No leads exchanged with ${widget.memberName}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _leads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final lead = _leads[index];
                    return _buildLeadCard(lead, isDark);
                  },
                ),
    );
  }

  Widget _buildLeadCard(LeadModel lead, bool isDark) {
    final currentUserName = SessionManager.user?['name']?.toString().toLowerCase().trim() ?? '';
    final bool isReceived = lead.memberName.toLowerCase().trim() == currentUserName;
    final statusColor = _getStatusColor(lead.status);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeadDetailScreen(
                  lead: lead,
                  isGiven: !isReceived,
                  onUpdateStatus: () {}, // Optional callback
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      child: Icon(Icons.business_center, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            !isReceived
                                ? "${lead.business} → ${lead.memberName}"
                                : "${lead.business} from ${lead.createdUser?['name'] ?? 'Unknown'}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lead.category,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lead.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 14, color: Colors.orange.shade400),
                        const SizedBox(width: 4),
                        Text(
                          lead.heatLevel,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Tap for details",
                          style: TextStyle(fontSize: 12, color: Colors.teal.shade300, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.teal.shade300),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
