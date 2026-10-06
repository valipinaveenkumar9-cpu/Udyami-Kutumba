import sys

file_path = 'lib/features/ucn/ucnsubscreens/meeting_detail_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add _meetingStatus state
content = content.replace(
    'class _MeetingDetailScreenState extends State<MeetingDetailScreen> {\n  bool _isSubmitting = false;\n  String? _rsvpStatus;',
    'class _MeetingDetailScreenState extends State<MeetingDetailScreen> {\n  bool _isSubmitting = false;\n  String _meetingStatus = \'Scheduled\';\n  String? _rsvpStatus;'
)

content = content.replace(
    '  @override\n  void initState() {\n    super.initState();\n    _fetchRsvpStatus();\n  }',
    '  @override\n  void initState() {\n    super.initState();\n    if (widget.meeting != null) {\n      _meetingStatus = widget.meeting!.status;\n    }\n    _fetchRsvpStatus();\n  }'
)

# Fix startMeeting API call
content = content.replace(
    "final success = await _meetingAPI.startMeeting(widget.meeting!.meetingId, currentUser['userId'].toString());\n                                setState(() => _isSubmitting = false);\n                                if (success != null) {\n                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting Started')));\n                                  SessionManager.setActiveMeetingId(widget.meeting!.meetingId);\n                                  Navigator.pop(context, true);",
    "final success = await _meetingAPI.startMeeting(widget.meeting!.meetingId, currentUser['userId'].toString(), meetingType: widget.meeting!.meetingType);\n                                setState(() => _isSubmitting = false);\n                                if (success != null) {\n                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting Started')));\n                                  SessionManager.setActiveMeetingId(widget.meeting!.meetingId);\n                                  setState(() {\n                                    _meetingStatus = 'Started';\n                                  });"
)

# Fix endMeeting API call (also passing meetingType if needed)
content = content.replace(
    "final success = await _meetingAPI.endMeeting(\n                                    widget.meeting!.meetingId,\n                                    currentUser['userId'].toString(),\n                                  );\n                                  setState(() => _isSubmitting = false);",
    "final success = await _meetingAPI.endMeeting(\n                                    widget.meeting!.meetingId,\n                                    currentUser['userId'].toString(),\n                                    meetingType: widget.meeting!.meetingType,\n                                  );\n                                  setState(() => _isSubmitting = false);"
)

# Replace widget.meeting!.status with _meetingStatus in UI
content = content.replace("widget.meeting!.status.toLowerCase()", "_meetingStatus.toLowerCase()")
content = content.replace("widget.meeting!.status != 'Started'", "_meetingStatus != 'Started'")
content = content.replace("widget.meeting!.status != 'Ended'", "_meetingStatus != 'Ended'")
content = content.replace("widget.meeting!.status == 'Started'", "_meetingStatus == 'Started'")
content = content.replace("widget.meeting!.status == 'Ended'", "_meetingStatus == 'Ended'")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated meeting_detail_screen.dart")
