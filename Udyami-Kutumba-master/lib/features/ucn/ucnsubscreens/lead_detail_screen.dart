import 'package:flutter/material.dart';
import '../../../../core/models/lead_model.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/api/ubn/lead_api.dart';

class LeadDetailScreen extends StatelessWidget {
  final LeadModel lead;
  final bool isGiven; // True if the current user gave this lead
  final VoidCallback onUpdateStatus;

  const LeadDetailScreen({
    super.key,
    required this.lead,
    required this.isGiven,
    required this.onUpdateStatus,
  });

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

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? iconColor, bool isStatus = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.teal).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? Colors.teal, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                if (isStatus)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(value).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: _getStatusColor(value),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Text(
                    value.isNotEmpty ? value : 'N/A',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine the primary display name based on if it's given or received
    final displayTitle = isGiven ? lead.memberName : (lead.createdUser?['name'] ?? 'Unknown Member');
    final subtitle = isGiven ? "Lead Sent To" : "Lead Received From";

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Lead Details",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.teal.withValues(alpha: 0.15) : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.teal.shade900 : Colors.teal.shade100),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.teal.shade600,
                    child: Text(
                      displayTitle.isNotEmpty ? displayTitle[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayTitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: isDark ? Colors.teal.shade200 : Colors.teal.shade800, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Details Card
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  _buildInfoRow(context, Icons.business_center, "Lead / Business", lead.business, iconColor: Colors.brown),
                  _buildInfoRow(context, Icons.category, "Category", lead.category, iconColor: Colors.purple),
                  _buildInfoRow(context, Icons.phone, "Phone Number", lead.phone, iconColor: Colors.blue),
                  _buildInfoRow(context, Icons.merge_type, "Lead Type", lead.leadType, iconColor: Colors.orange),
                  _buildInfoRow(context, Icons.local_fire_department, "Heat Level", lead.heatLevel, iconColor: Colors.red),
                  _buildInfoRow(context, Icons.info_outline, "Current Status", lead.status, isStatus: true, iconColor: _getStatusColor(lead.status)),
                  
                  if (lead.feedback != null && lead.feedback!.isNotEmpty)
                    _buildInfoRow(context, Icons.comment, "Feedback", lead.feedback!, iconColor: Colors.blueGrey),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onUpdateStatus,
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Update Lead Status",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 10),
            Text(
              "AI Leads",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<LeadModel>>(
              future: _fetchMatchedLeads(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    "No AI leads found.",
                    style: TextStyle(color: Colors.grey.shade600),
                  );
                }
                
                final leads = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final matchedLead = leads[index];
                    return Card(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              matchedLead.business,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              matchedLead.category,
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.teal.shade400),
                                const SizedBox(width: 4),
                                Text(
                                  matchedLead.memberName,
                                  style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<List<LeadModel>> _fetchMatchedLeads() async {
    final targetUserId = lead.createdUser?['userId'];
    if (targetUserId != null && targetUserId.toString().isNotEmpty) {
      return await LeadAPI.getMatchedLeads(targetUserId.toString());
    }

    final userData = SessionManager.user;
    if (userData != null) {
      final user = UserModel.fromJson(userData);
      return await LeadAPI.getMatchedLeads(user.userId);
    }
    return [];
  }
}
