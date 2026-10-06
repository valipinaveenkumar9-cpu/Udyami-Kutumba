import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/session_manager.dart';

class CommunicationsManagementDashboardScreen extends StatefulWidget {
  const CommunicationsManagementDashboardScreen({super.key});

  @override
  State<CommunicationsManagementDashboardScreen> createState() => _CommunicationsManagementDashboardScreenState();
}

class _CommunicationsManagementDashboardScreenState extends State<CommunicationsManagementDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    "Send Campaign",
    "Analytics",
    "Bulk SMS / Email",
    "Auto Dialer",
    "WhatsApp Outreach",
    "AI IVR Calling",
    "WhatsApp AI Chatbot",
    "Credits",
  ];

  String _activeStatus = 'PENDING';
  final List<String> _statusTabs = ['PENDING', 'IN_PROGRESS', 'COMPLETED'];
  List<dynamic> _campaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() => _isLoading = true);
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/bulk-campagin/getAllCampaigns?adminStatus=$_activeStatus&page=1&limit=50");
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      
      print('DEV DEBUG - Communications API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('DEV DEBUG - Communications API RAW JSON: ${response.body}');
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            _campaigns = data['data'];
          });
          print('DEV DEBUG - Parsed Rows Count: ${_campaigns.length}');
          if (_campaigns.isNotEmpty) {
            final firstRow = _campaigns[0];
            final user = firstRow['user'] ?? {};
            print('DEV DEBUG - First Row UI Mapped Data: '
                  'User Name=${user['name']}, '
                  'User Email=${user['email']}, '
                  'Mobile=${user['mobileNumber']}, '
                  'Recipients=${firstRow['totalRecipients']}, '
                  'Channel=${firstRow['channel']}, '
                  'Status=${firstRow['status']}');
          }
        }
      } else {
        print('DEV DEBUG - Communications API Error: ${response.body}');
      }
    } catch (e) {
      print('DEV DEBUG - Communications API Exception: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _reviewCampaign(String campaignId, String status) async {
    try {
      final token = SessionManager.token;
      final adminUserId = SessionManager.user?['id'] ?? SessionManager.user?['_id'] ?? SessionManager.user?['userId'];
      final url = Uri.parse("https://backend.udyamikutumba.com/bulk-campagin/reviewMemberCampagin");
      
      final payload = {
        "campaignId": campaignId,
        "adminUserId": adminUserId,
        "status": status,
        "remark": "Reviewed via Mobile App",
      };
      
      print('DEV DEBUG - Review Campaign Payload: $payload');
      
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      print('DEV DEBUG - Review Campaign Response Status: ${response.statusCode}');
      print('DEV DEBUG - Review Campaign Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Campaign $status successfully')));
        _fetchCampaigns();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: ${response.body}')));
      }
    } catch (e) {
      print('DEV DEBUG - Review Campaign Exception: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating campaign: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Communications'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(12),
          ),
          tabs: _tabs.map((t) => Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          if (tab == "Send Campaign") {
            return _buildAdminCsvSection();
          }
          return Center(child: Text("$tab Dashboard - Coming Soon"));
        }).toList(),
      ),
    );
  }

  Widget _buildAdminCsvSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-tabs
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusTabs.map((status) {
                final isActive = _activeStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() => _activeStatus = status);
                      _fetchCampaigns();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.blue.shade600 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.black12),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _campaigns.isEmpty
                  ? Center(child: Text("No ${_activeStatus.replaceAll('_', ' ').toLowerCase()} campaigns found."))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                          columns: [
                            const DataColumn(label: Text('USER / EMAIL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                            const DataColumn(label: Text('MOBILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                            const DataColumn(label: Text('RECIPIENTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                            const DataColumn(label: Text('CHANNEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                            const DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                            const DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                            if (_activeStatus == 'PENDING')
                              const DataColumn(label: Text('ACTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                          ],
                          rows: _campaigns.map((row) {
                            final user = row['user'] ?? {};
                            
                            return DataRow(
                              cells: [
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(user['name']?.toString().isNotEmpty == true ? user['name'] : '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(user['email']?.toString().isNotEmpty == true ? user['email'] : '—', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                DataCell(Text(user['mobileNumber']?.toString().isNotEmpty == true ? user['mobileNumber'] : '—', style: const TextStyle(color: Colors.grey))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      border: Border.all(color: Colors.blue.shade100),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.people, size: 12, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        Text('${row['totalRecipients'] ?? 0}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(row['channel']?.toString().isNotEmpty == true ? row['channel'] : '—', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      border: Border.all(color: Colors.orange.shade200),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      row['status']?.toString().replaceAll('_', ' ') ?? 'PENDING',
                                      style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row['createdAt'] != null ? row['createdAt'].toString().substring(0, 10) : '—',
                                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                                ),
                                if (_activeStatus == 'PENDING')
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.green.shade50,
                                            foregroundColor: Colors.green.shade700,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.check, size: 12),
                                          label: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            final campaignId = row['campaignId'] ?? row['id'] ?? row['_id'];
                                            if (campaignId != null) {
                                              _reviewCampaign(campaignId.toString(), 'APPROVED');
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.red.shade50,
                                            foregroundColor: Colors.red.shade700,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.close, size: 12),
                                          label: const Text('Reject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            final campaignId = row['campaignId'] ?? row['id'] ?? row['_id'];
                                            if (campaignId != null) {
                                              _reviewCampaign(campaignId.toString(), 'REJECTED');
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
