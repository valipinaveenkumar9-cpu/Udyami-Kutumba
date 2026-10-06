import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/meeting_model.dart';
import '../../../core/api/ubn/meeting_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CircleMeetingAgendaScreen extends StatefulWidget {
  final MeetingModel meeting;
  const CircleMeetingAgendaScreen({super.key, required this.meeting});

  @override
  State<CircleMeetingAgendaScreen> createState() => _CircleMeetingAgendaScreenState();
}

class _CircleMeetingAgendaScreenState extends State<CircleMeetingAgendaScreen> {
  final MeetingAPI _meetingAPI = MeetingAPI();
  bool _isLoading = false;

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('EEE d MMM · h:mm a').format(date);
    } catch (e) {
      return isoString;
    }
  }

  Future<void> _markAsCompleted() async {
    final user = SessionManager.user;
    if (user == null || user['userId'] == null) return;
    
    setState(() {
      _isLoading = true;
    });

    final payload = {
      "date": widget.meeting.date,
      "venue": widget.meeting.venue,
      "agenda": widget.meeting.agenda,
      "status": "Completed"
    };

    final response = await _meetingAPI.updateMeeting(widget.meeting.meetingId, user['userId'].toString(), payload);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (response != null && response['meetingId'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting marked as completed!')));
        Navigator.pop(context, true); // Return true to refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response?['message'] ?? 'Failed to update meeting')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
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
          "Circle Meeting",
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
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status: ${widget.meeting.status}",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_formatDate(widget.meeting.date)} · ${widget.meeting.venue}",
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade800, fontSize: 13),
                  ),
                ],
              ),
            ),

            Text(
              "Agenda",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                widget.meeting.agenda,
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 32),

            if (widget.meeting.status.toLowerCase() != 'completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _markAsCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white))
                      : Text("Mark as Completed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
