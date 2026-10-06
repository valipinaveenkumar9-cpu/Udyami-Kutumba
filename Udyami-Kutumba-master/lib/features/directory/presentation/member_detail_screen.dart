import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'give_appreciation_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'package:udyamikutumba/core/api/ubn/lead_api.dart';
import 'package:udyamikutumba/core/api/ubn/face_to_face_api.dart';
import 'package:udyamikutumba/core/models/lead_model.dart';
import 'package:udyamikutumba/core/models/face_to_face_model.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';

import 'member_leads_screen.dart';
import 'member_face_to_face_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final Map<String, dynamic> member;
  final String initials;
  final String name;
  final String shortTitle;
  final String fullSectorInfo;
  final MaterialColor avatarColor;

  const MemberDetailScreen({
    super.key,
    required this.member,
    required this.initials,
    required this.name,
    required this.shortTitle,
    required this.fullSectorInfo,
    required this.avatarColor,
  });

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  bool _isLoadingActivities = true;
  List<dynamic> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentActivities();
  }

  Future<void> _fetchRecentActivities() async {
    try {
      final currentUserId = SessionManager.token != null ? await _getUserId() : null;
      final currentUserName = SessionManager.user?['name']?.toString().toLowerCase().trim() ?? '';
      
      final memberId = widget.member['userId'] ?? widget.member['id'] ?? '';
      final memberName = widget.name;

      final allLeads = await LeadAPI.getAllLeads();
      final allMeetings = await FaceToFaceAPI.getAllFaceToFaceMeetings();

      List<dynamic> combined = [];

      // Filter leads
      for (var lead in allLeads) {
        final isToMember = lead.memberName.toLowerCase().trim() == memberName.toLowerCase().trim();
        final isFromMember = lead.createdUser?['userId'] == memberId;
        
        final isToMe = lead.memberName.toLowerCase().trim() == currentUserName;
        final isFromMe = lead.createdUser?['userId'] == currentUserId;

        if ((isToMember && isFromMe) || (isFromMember && isToMe)) {
           combined.add({
             'type': 'Lead',
             'title': isToMe ? 'Passed you a lead' : 'You passed a lead',
             'subtitle': '${lead.business} · ${lead.category}',
             'status': lead.status,
             'date': lead.createdAt ?? '',
             'color': Colors.teal,
           });
        }
      }

      // Filter F2F
      for (var m in allMeetings) {
        final isInvitedMember = m.invitedMemberUserId == memberId || m.invitedMember?['userId'] == memberId || m.memberName.toLowerCase().trim() == memberName.toLowerCase().trim();
        final isCreatedMember = m.createdUserId == memberId || m.createdUser?['userId'] == memberId;
        
        final isInvitedMe = m.invitedMemberUserId == currentUserId || m.invitedMember?['userId'] == currentUserId;
        final isCreatedMe = m.createdUserId == currentUserId || m.createdUser?['userId'] == currentUserId;

        if ((isInvitedMember && isCreatedMe) || (isCreatedMember && isInvitedMe)) {
           combined.add({
             'type': 'F2F',
             'title': 'Face to Face Meeting',
             'subtitle': m.purpose,
             'status': m.status,
             'date': m.date,
             'color': Colors.blue,
           });
        }
      }

      // Optional: Add a dummy attendance record if you want
      // combined.add({
      //   'type': 'Attendance',
      //   'title': 'Attendance',
      //   'subtitle': 'Present in last circle meeting',
      //   'status': 'Present',
      //   'date': '',
      //   'color': Colors.indigo,
      // });

      if (mounted) {
        setState(() {
          _recentActivities = combined;
          _isLoadingActivities = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingActivities = false;
        });
      }
      print("Error fetching activities: $e");
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberId = widget.member['userId'] ?? widget.member['id'] ?? '';

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
          "Member",
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
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? widget.avatarColor.withValues(alpha: 0.2) : widget.avatarColor.shade100,
                    child: Text(
                      widget.initials,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? widget.avatarColor.shade200 : widget.avatarColor.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.shortTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.fullSectorInfo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberLeadsScreen(
                              memberId: memberId,
                              memberName: widget.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text("Pass a lead", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberFaceToFaceScreen(
                              memberId: memberId,
                              memberName: widget.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people_alt_rounded, size: 18),
                      label: const Text("Face to Face", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GiveAppreciationScreen(memberName: widget.name),
                    ),
                  );
                },
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text("Give Appreciation", style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Recent Activity
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent activity",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoadingActivities)
               const Center(child: Padding(
                 padding: EdgeInsets.all(20.0),
                 child: CircularProgressIndicator(),
               ))
            else if (_recentActivities.isEmpty)
               Center(
                 child: Padding(
                   padding: const EdgeInsets.symmetric(vertical: 30),
                   child: Text("No recent activity found", style: TextStyle(color: Colors.grey.shade500)),
                 ),
               )
            else
               ..._recentActivities.map((activity) => _buildActivityRow(
                 context,
                 activity['title'],
                 activity['subtitle'],
                 activity['status'],
                 activity['color'] as MaterialColor,
               )).toList(),

          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(BuildContext context, String title, String subtitle, String badgeText, MaterialColor badgeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? badgeColor.withValues(alpha: 0.2) : badgeColor.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor.shade700,
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
