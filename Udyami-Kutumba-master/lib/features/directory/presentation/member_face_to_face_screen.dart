import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/api/ubn/face_to_face_api.dart';
import 'package:udyamikutumba/core/models/face_to_face_model.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udyamikutumba/features/ucn/ucnsubscreens/face_to_face_detail_screen.dart';

class MemberFaceToFaceScreen extends StatefulWidget {
  final String memberId;
  final String memberName;

  const MemberFaceToFaceScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<MemberFaceToFaceScreen> createState() => _MemberFaceToFaceScreenState();
}

class _MemberFaceToFaceScreenState extends State<MemberFaceToFaceScreen> {
  bool _isLoading = true;
  List<FaceToFaceModel> _meetings = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    try {
      final allMeetings = await FaceToFaceAPI.getAllFaceToFaceMeetings();
      final currentUserId = SessionManager.token != null ? await _getUserId() : null;

      setState(() {
        _meetings = allMeetings.where((m) {
          final isInvitedMember = m.invitedMemberUserId == widget.memberId || m.invitedMember?['userId'] == widget.memberId || m.memberName.toLowerCase().trim() == widget.memberName.toLowerCase().trim();
          final isCreatedMember = m.createdUserId == widget.memberId || m.createdUser?['userId'] == widget.memberId;
          
          final isInvitedMe = m.invitedMemberUserId == currentUserId || m.invitedMember?['userId'] == currentUserId;
          final isCreatedMe = m.createdUserId == currentUserId || m.createdUser?['userId'] == currentUserId;

          return (isInvitedMember && isCreatedMe) || (isCreatedMember && isInvitedMe);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print("Error fetching F2F meetings: $e");
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
      case 'completed':
        return Colors.teal;
      case 'scheduled':
        return Colors.indigo;
      case 'declined':
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr;
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
          "Face to Face with ${widget.memberName}",
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
          : _meetings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.handshake_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "No Face to Face meetings with ${widget.memberName}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _meetings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final meeting = _meetings[index];
                    return _buildMeetingCard(meeting, isDark);
                  },
                ),
    );
  }

  Widget _buildMeetingCard(FaceToFaceModel meeting, bool isDark) {
    final statusColor = _getStatusColor(meeting.status);
    final currentUserId = SessionManager.token != null ? SessionManager.token : null; 
    // Just determining who created it for the title
    final bool isCreatedByMe = meeting.createdUserId == currentUserId || meeting.createdUser?['userId'] == currentUserId;

    String title = isCreatedByMe
        ? "With ${meeting.memberName}"
        : "From ${meeting.createdUser?['name'] ?? 'Unknown'}";

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () async {
        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FaceToFaceDetailScreen(meeting: meeting)),
        );
        if (shouldRefresh == true) {
          _fetchMeetings();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: isDark ? Colors.transparent : Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (() {
                        String nameStr = isCreatedByMe ? meeting.memberName : (meeting.createdUser?['name']?.toString() ?? 'U');
                        if (nameStr.trim().isEmpty) nameStr = 'U';
                        return nameStr.substring(0, 1).toUpperCase();
                      })(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_formatDate(meeting.date)} • ${meeting.purpose}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    meeting.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
