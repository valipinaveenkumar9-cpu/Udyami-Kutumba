import 'package:flutter/material.dart';
import 'sector_team_screen.dart';
import 'sector_join_review_screen.dart';
import '../../../core/api/ubn/sector_api.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class SectorDashboardScreen extends StatefulWidget {
  const SectorDashboardScreen({super.key});

  @override
  State<SectorDashboardScreen> createState() => _SectorDashboardScreenState();
}

class _SectorDashboardScreenState extends State<SectorDashboardScreen> {
  final SectorAPI _sectorApi = SectorAPI();
  bool _isLoading = true;
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await _sectorApi.getAllSectorRequests();
      if (mounted && response != null && response['success'] == true) {
        setState(() {
          _requests = response['data'] ?? [];
          // Filter to show only 'Open' or 'Endorsed' requests depending on role
          // For now showing all that are not approved/rejected, or all open
          _requests = _requests.where((r) => r['status'] == 'Open' || r['status'] == 'Endorsed').toList();
        });
      }
    } catch (e) {
      print('Exception in _fetchRequests: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sector dashboard",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coral Banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Color(0xFFFF7F50), // Coral
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Construction & Real Estate",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "6 members · 5 of 31 tags filled",
                    style: TextStyle(color: Color(0xFF5D2417), fontSize: 13),
                  ),
                ],
              ),
            ),

            Text(
              "Tag seats",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildTagSeatRow(context, "Interior designers", "1 filled · Priya S", true),
            _buildTagSeatRow(context, "Cement", "1 filled · Pavithra", true),
            _buildTagSeatRow(context, "TMT steel bars", "open", false),
            _buildTagSeatRow(context, "Waterproofing", "open", false),
            _buildTagSeatRow(context, "Tiles & granite", "open", false),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            Text(
              "Pending in my sector",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Pending Review Rows
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_requests.isEmpty)
              const Text("No pending requests", style: TextStyle(color: Colors.grey))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  final memberName = request['createdUser']?['name'] ?? 'Unknown Member';
                  final sectorName = request['sector']?['sectorName'] ?? 'Sector Request';
                  final status = request['status'] ?? 'Open';
                  
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SectorJoinReviewScreen(sectorJoinRequestId: request['sectorJoinRequestId'])),
                      );
                      // Refresh after returning
                      _fetchRequests();
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$memberName ($status)",
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sectorName,
                                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.orange.shade300, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 12),

            // Manage Sector Team Row
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SectorTeamScreen()),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Manage Sector Team",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Members & meetings",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTagSeatRow(BuildContext context, String title, String subtitle, bool isFull) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isFull ? Colors.red.shade50 : Colors.teal.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isFull ? "Full" : "Open",
              style: TextStyle(
                color: isFull ? Colors.red.shade700 : Colors.teal.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
