import 'package:flutter/material.dart';
import '../../../../core/utils/session_manager.dart';
import 'face_to_face_invite_screen.dart';
import '../../../core/api/ubn/face_to_face_api.dart';
import '../../../../core/models/face_to_face_model.dart';
import '../../../../core/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'face_to_face_detail_screen.dart';

class FaceToFaceScreen extends StatefulWidget {
  final String? targetUserId;
  const FaceToFaceScreen({super.key, this.targetUserId});

  @override
  State<FaceToFaceScreen> createState() => _FaceToFaceScreenState();
}

class _FaceToFaceScreenState extends State<FaceToFaceScreen> {
  int selectedTab = 0;
  List<FaceToFaceModel> givenInvites = [];
  List<FaceToFaceModel> receivedInvites = [];
  bool isLoading = true;
  String? currentUserId;
  String? currentUserName;

  @override
  void initState() {
    super.initState();
    _fetchF2f();
  }

  Future<void> _fetchF2f() async {
    setState(() {
      isLoading = true;
    });

    final userData = SessionManager.user;
    if (userData != null) {
      final user = UserModel.fromJson(userData);
      currentUserId = widget.targetUserId ?? user.userId;
      currentUserName = user.name.toLowerCase().trim();

      if (currentUserId != null) {
        final allMeetings = await FaceToFaceAPI.getAllFaceToFaceMeetings();
        
        if (!mounted) return;
        setState(() {
          givenInvites = allMeetings.where((m) {
            return m.createdUser != null && m.createdUser!['userId'] == currentUserId;
          }).toList();
          
          receivedInvites = allMeetings.where((m) {
            if (m.invitedMember != null) {
              return m.invitedMember!['userId'] == currentUserId;
            }
            return m.memberName.toLowerCase().trim() == currentUserName;
          }).toList();
        });

        int givenCompleted = givenInvites.where((m) => m.status.toLowerCase() == 'completed').length;
        int receivedCompleted = receivedInvites.where((m) => m.status.toLowerCase() == 'completed').length;
        print('DEV DEBUG - UCN Action Screen (FACE_TO_FACE) - Data fetched successfully.');
        print('DEV DEBUG - UCN Action Screen (FACE_TO_FACE) - Given: ${givenInvites.length} (Completed: $givenCompleted)');
        print('DEV DEBUG - UCN Action Screen (FACE_TO_FACE) - Received: ${receivedInvites.length} (Completed: $receivedCompleted)');
      }
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void _showStatusUpdateDialog(FaceToFaceModel meeting) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update F2F Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.blue),
                title: Text("Completed"),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateStatus(meeting.id, "Completed");
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text("Cancelled"),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateStatus(meeting.id, "Cancelled");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(String meetingId, String newStatus) async {
    if (currentUserId == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Updating status...")),
    );

    final success = await FaceToFaceAPI.updateFaceToFaceStatus(meetingId, newStatus, currentUserId!);
    
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status updated!")),
        );
        _fetchF2f(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update status.")),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.teal;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'accepted':
        return Colors.blue;
      case 'pending':
      case 'requested':
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('EEE dd MMM • yyyy').format(dt); // e.g. Wed 23 Jul • 2026
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Face to Face",
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
                MaterialPageRoute(builder: (_) => const FaceToFaceInviteScreen()),
              );
              _fetchF2f();
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
                            height: 42,
                            decoration: BoxDecoration(
                              color: selectedTab == 0 ? Colors.teal : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                            ),
                            child: Center(
                              child: Text(
                                "Given ${givenInvites.length}",
                                style: TextStyle(
                                  color: selectedTab == 0 ? Theme.of(context).colorScheme.surface : Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = 1;
                            });
                          },
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: selectedTab == 1 ? Colors.teal : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                            ),
                            child: Center(
                              child: Text(
                                "Received ${receivedInvites.length}",
                                style: TextStyle(
                                  color: selectedTab == 1 ? Theme.of(context).colorScheme.surface : Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  if (selectedTab == 1 && receivedInvites.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No received invites yet.", style: TextStyle(color: Colors.grey)),
                    ))
                  else if (selectedTab == 0 && givenInvites.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No given invites yet.", style: TextStyle(color: Colors.grey)),
                    ))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedTab == 0 ? givenInvites.length : receivedInvites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final meeting = selectedTab == 0 ? givenInvites[index] : receivedInvites[index];
                        final statusColor = _getStatusColor(meeting.status);

                        String title = selectedTab == 0
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
                              _fetchF2f();
                            }
                          },
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
                                        String nameStr = selectedTab == 0 ? meeting.memberName : (meeting.createdUser?['name']?.toString() ?? 'U');
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
                      },
                    ),
                ],
              ),
            ),
    );
  }
}