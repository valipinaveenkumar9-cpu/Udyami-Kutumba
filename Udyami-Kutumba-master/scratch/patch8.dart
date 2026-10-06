import 'dart:io';

void main() {
  File file = File('d:\\DigiNik\\Apps\\udyamikutumba\\lib\\features\\ucn\\ucnsubscreens\\meetings_screen.dart');
  String content = file.readAsStringSync();

  // 1. Update _meetingCard signature
  content = content.replaceAll(
    'required VoidCallback onTap,\n  }) {',
    'required VoidCallback onTap,\n    Widget? actionButton,\n  }) {'
  );

  // 2. Update _meetingCard body
  content = content.replaceAll(
'''                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),''',
'''                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (actionButton != null) ...[
                    const SizedBox(height: 8),
                    actionButton,
                  ],
                ],
              ),
            ),
            if (actionButton == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),'''
  );

  // 3. Update upcoming meetings
  content = content.replaceAll(
'''                    badgeText: "RSVP",
                    badgeColor: Colors.grey,
                    onTap: () async {
                      final currentUser = SessionManager.user;
                      final currentUserId = currentUser?['userId']?.toString();
                      final creatorId = meeting.createdUser?['userId']
                          ?.toString();

                      bool isManager = false;
                      // If I created it, I manage it
                      if (currentUserId != null &&
                          creatorId != null &&
                          currentUserId == creatorId) {
                        isManager = true;
                      }
                      // Otherwise, check role scopes
                      else if (_isAssemblyRole &&
                          meeting.talukaId != null &&
                          (meeting.wardId == null || meeting.wardId!.isEmpty)) {
                        // Assembly President manages Assembly Meetings
                        isManager = true;
                      } else if (_isWardRole &&
                          meeting.wardId != null &&
                          meeting.wardId!.isNotEmpty &&
                          widget.userRole.toLowerCase().contains(
                            'circle leader',
                          )) {
                        // Circle Leader manages Ward Meetings
                        isManager = true;
                      }''',
'''                    badgeText: meeting.status,
                    badgeColor: meeting.status == 'Started' ? Colors.green : Colors.orange,
                    actionButton: (() {
                      final currentUser = SessionManager.user;
                      final currentUserId = currentUser?['userId']?.toString();
                      final creatorId = meeting.createdUser?['userId']?.toString();

                      bool isManager = false;
                      if (currentUserId != null && creatorId != null && currentUserId == creatorId) {
                        isManager = true;
                      } else if (_isAssemblyRole && meeting.talukaId != null && (meeting.wardId == null || meeting.wardId!.isEmpty)) {
                        isManager = true;
                      } else if (_isWardRole && meeting.wardId != null && meeting.wardId!.isNotEmpty && widget.userRole.toLowerCase().contains('circle leader')) {
                        isManager = true;
                      }

                      return isManager ? ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CircleMeetingAgendaScreen(meeting: meeting)),
                          );
                          if (result == true) {
                            _fetchMeetings();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: meeting.status == 'Started' ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(meeting.status == 'Started' ? 'End Meeting' : 'Start Meeting'),
                      ) : null;
                    })(),
                    onTap: () async {
                      final currentUser = SessionManager.user;
                      final currentUserId = currentUser?['userId']?.toString();
                      final creatorId = meeting.createdUser?['userId']?.toString();

                      bool isManager = false;
                      if (currentUserId != null && creatorId != null && currentUserId == creatorId) {
                        isManager = true;
                      } else if (_isAssemblyRole && meeting.talukaId != null && (meeting.wardId == null || meeting.wardId!.isEmpty)) {
                        isManager = true;
                      } else if (_isWardRole && meeting.wardId != null && meeting.wardId!.isNotEmpty && widget.userRole.toLowerCase().contains('circle leader')) {
                        isManager = true;
                      }'''
  );

  // 4. Update past meetings
  content = content.replaceAll(
'''                    badgeText: "Completed",
                    badgeColor: Colors.green,
                    onTap: () {},''',
'''                    badgeText: "Completed",
                    badgeColor: Colors.green,
                    actionButton: ElevatedButton(
                      onPressed: () {
                        if (meeting.summary != null) {
                          // Note: Make sure MeetingSummaryScreen is imported if used, else fallback.
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MeetingDetailScreen(type: 'Circle', meeting: meeting)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MeetingDetailScreen(type: 'Circle', meeting: meeting)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Summary'),
                    ),
                    onTap: () {},'''
  );

  file.writeAsStringSync(content);
  print("Patched meetings_screen.dart");
}
