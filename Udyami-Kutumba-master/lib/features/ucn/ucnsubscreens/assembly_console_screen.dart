import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/session_manager.dart';
import '../../../core/api/ubn/application/application_api.dart';
import 'applications_screen.dart';
import 'lead_appeals_screen.dart';
import 'new_meeting_screen.dart';
import 'attendance_screen.dart';
import 'assembly_roles_screen.dart';
import 'coordinators_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class AssemblyConsoleScreen extends StatefulWidget {
  const AssemblyConsoleScreen({super.key, this.assemblyName = 'Assembly'});
  final String assemblyName;

  @override
  State<AssemblyConsoleScreen> createState() => _AssemblyConsoleScreenState();
}

class _AssemblyConsoleScreenState extends State<AssemblyConsoleScreen> {
  bool _isLoading = true;
  String _memberCount = "0";
  int _pendingAppCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchMemberCount();
    _fetchPendingApplications();
  }

  Future<void> _fetchMemberCount() async {
    try {
      final token = SessionManager.token;
      final url = Uri.parse('https://udyami-circle-db.onrender.com/auth/getAllUsers');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['counts'] != null) {
          final counts = data['counts'];
          final basic = counts['basicUsers'] ?? 0;
          final prime = counts['primeUsers'] ?? 0;
          print('DEV DEBUG - get - circle_console_screen.dart - Fetched counts: $counts');
          print('DEV DEBUG - get - circle_console_screen.dart - basicUsers: $basic, primeUsers: $prime, Total parsed: ${basic + prime}');
          if (mounted) {
            setState(() {
              _memberCount = (basic + prime).toString();
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      print('DEV DEBUG - get - circle_console_screen.dart - Exception: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _memberCount = "-";
      });
    }
  }

  Future<void> _fetchPendingApplications() async {
    try {
      final res = await ApplicationAPI.getStatistics();
      if (res != null && res['success'] == true && res['data'] != null) {
        final pending = res['data']['pendingApplications'];
        if (mounted) {
          setState(() {
            _pendingAppCount = pending is int ? pending : int.tryParse(pending.toString()) ?? 0;
          });
        }
      }
    } catch (e) {
      print('DEV DEBUG - get - circle_console_screen.dart - Pending apps fetch error: $e');
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
          widget.assemblyName.trim().isNotEmpty ? "${widget.assemblyName} Console" : "Console",
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
            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard("Members", _isLoading ? "..." : _memberCount)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Attendance", "78%")),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Start Meeting Attendance", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Needs your action",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Membership Apps Action Row (Amber)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApplicationsScreen()),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$_pendingAppCount membership application${_pendingAppCount == 1 ? '' : 's'}",
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "check category fit",
                            style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.orange.shade300, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Disputed Lead Action Row
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeadAppealsScreen()),
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
                            "1 disputed lead",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Vani Silks · appealed",
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

            const SizedBox(height: 24),

            // Launch Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95, // Matching the existing UCN home launch grid
              children: [
                _buildLaunchTile(Icons.calendar_month, "New meeting", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewMeetingScreen()),
                  );
                }),
                _buildLaunchTile(Icons.content_paste_rounded, "Attendance", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                  );
                }),
                _buildLaunchTile(Icons.account_tree_rounded, widget.assemblyName.trim().isNotEmpty ? "${widget.assemblyName} Roles" : "Roles", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AssemblyRolesScreen(assemblyName: widget.assemblyName)),
                  );
                }),
                _buildLaunchTile(Icons.more_horiz_rounded, "Coordinators", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoordinatorsScreen()),
                  );
                }),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildLaunchTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.withAlpha(26),
              child: Icon(icon, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

