import 'package:flutter/material.dart';
import '../../../../core/utils/session_manager.dart';
import 'passleadscreen.dart';
import 'lead_detail_screen.dart';
import '../../../core/api/ubn/lead_api.dart';
import '../../../../core/models/lead_model.dart';
import '../../../../core/models/user_model.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class MyLeadsScreen extends StatefulWidget {
  final String? targetUserId;
  const MyLeadsScreen({super.key, this.targetUserId});

  @override
  State<MyLeadsScreen> createState() => _MyLeadsScreenState();
}

class _MyLeadsScreenState extends State<MyLeadsScreen> {
  int selectedTab = 0;
  List<LeadModel> givenLeads = [];
  List<LeadModel> receivedLeads = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    setState(() {
      isLoading = true;
    });

    final userData = SessionManager.user;
    if (userData != null) {
      final user = UserModel.fromJson(userData);
      currentUserId = widget.targetUserId ?? user.userId;
      final currentUserName = user.name.toLowerCase().trim();

      if (currentUserId != null) {
        final allLeads = await LeadAPI.getAllLeads();
        
        if (!mounted) return;
        setState(() {
          givenLeads = allLeads.where((lead) {
            if (lead.createdUser != null && lead.createdUser!['userId'] == currentUserId) {
              return true;
            }
            return false;
          }).toList();
          
          receivedLeads = allLeads.where((lead) {
            return lead.memberName.toLowerCase().trim() == currentUserName;
          }).toList();
        });

        int givenClosed = givenLeads.where((m) => m.status.toLowerCase() == 'closed' || m.status.toLowerCase() == 'converted').length;
        int receivedClosed = receivedLeads.where((m) => m.status.toLowerCase() == 'closed' || m.status.toLowerCase() == 'converted').length;
        print('DEV DEBUG - UCN Action Screen (LEAD_GIVEN) - Data fetched successfully.');
        print('DEV DEBUG - UCN Action Screen (LEAD_GIVEN) - Given: ${givenLeads.length} (Closed/Converted: $givenClosed)');
        print('DEV DEBUG - UCN Action Screen (LEAD_GIVEN) - Received: ${receivedLeads.length} (Closed/Converted: $receivedClosed)');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showStatusUpdateDialog(LeadModel lead) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "Update Lead Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.indigo),
                title: Text("Accepted", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateStatus(lead.leadId, "Accepted");
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.orange),
                title: Text("Contacted", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateStatus(lead.leadId, "Contacted");
                },
              ),
              ListTile(
                leading: const Icon(Icons.done_all, color: Colors.teal),
                title: Text("Closed", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateStatus(lead.leadId, "Closed");
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: Text("Declined", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateStatus(lead.leadId, "Declined");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(String leadId, String newStatus) async {
    if (currentUserId == null) return;
    
    // Show a loading indicator in snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Updating status...")),
    );

    final success = await LeadAPI.updateLeadStatus(leadId, newStatus, currentUserId!);
    
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lead status updated!")),
        );
        _fetchLeads(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update status.")),
        );
      }
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

  void _navigateToDetail(LeadModel lead, bool isGiven) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeadDetailScreen(
          lead: lead,
          isGiven: isGiven,
          onUpdateStatus: () {
            _showStatusUpdateDialog(lead);
          },
        ),
      ),
    ).then((_) {
      // Refresh leads when returning in case status was updated
      _fetchLeads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "My Leads",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.onSurface),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PassLeadScreen()),
              );
              _fetchLeads();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Top Pills
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = 0;
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: selectedTab == 0 ? Colors.teal : (isDark ? Colors.grey.shade900 : Colors.white),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: selectedTab == 0 ? Colors.transparent : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                            ),
                            child: Center(
                              child: Text(
                                "Given ${givenLeads.length}",
                                style: TextStyle(
                                  color: selectedTab == 0 ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = 1;
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: selectedTab == 1 ? Colors.teal : (isDark ? Colors.grey.shade900 : Colors.white),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: selectedTab == 1 ? Colors.transparent : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                            ),
                            child: Center(
                              child: Text(
                                "Received ${receivedLeads.length}",
                                style: TextStyle(
                                  color: selectedTab == 1 ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  if (selectedTab == 1 && receivedLeads.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("No received leads yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ))
                  else if (selectedTab == 0 && givenLeads.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("No given leads yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedTab == 0 ? givenLeads.length : receivedLeads.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final lead = selectedTab == 0 ? givenLeads[index] : receivedLeads[index];
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
                              onTap: () => _navigateToDetail(lead, selectedTab == 0),
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
                                                selectedTab == 0
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
                      },
                    ),
                  
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      "sent → accepted → contacted → closed",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}