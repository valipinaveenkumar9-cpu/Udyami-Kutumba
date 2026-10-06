import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/meeting_model.dart';
import '../../../core/api/ubn/meeting_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/api/ubn/attendance_api.dart';
import 'dart:convert';
import 'face_to_face_invite_screen.dart';
import 'gratitude_screen.dart';
import 'guests_screen.dart';
import 'meeting_summary_screen.dart';
import 'passleadscreen.dart';
import 'scan_attendance_qr_screen.dart';
import 'attendance_screen.dart';
import 'attendance_summary_list_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class MeetingDetailScreen extends StatefulWidget {
  final String type;
  final MeetingModel? meeting;

  const MeetingDetailScreen({super.key, required this.type, this.meeting});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  final MeetingAPI _meetingAPI = MeetingAPI();
  bool _isSubmitting = false;

  String _meetingStatus = 'Scheduled';
  String? _rsvpStatus;
  bool _isLoadingStatus = true;

  double? _distanceInMeters;
  bool _isCheckingLocation = false;

  int _presentCount = 0;
  int _totalMembers = 0;

  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      _meetingStatus = widget.meeting!.status;
    }
    _fetchRsvpStatus();
    _fetchActiveQR();
    _fetchAttendanceStats();
  }

  Future<void> _fetchAttendanceStats() async {
    if (widget.meeting == null) return;
    try {
      final attendanceAPI = AttendanceAPI();
      final res = await attendanceAPI.getMeetingAttendance(
        widget.meeting!.meetingId,
      );
      dynamic extractData(dynamic r) {
        if (r == null) return null;
        if (r is Map) return r.containsKey('data') ? r['data'] : r;
        return r;
      }

      final data = extractData(res);
      if (data != null && mounted) {
        setState(() {
          if (data is Map) {
            _totalMembers = data['totalMembers'] != null
                ? int.tryParse(data['totalMembers'].toString()) ?? 0
                : 0;
            _presentCount = data['present'] != null
                ? int.tryParse(data['present'].toString()) ?? 0
                : 0;
          } else if (data is List) {
            _totalMembers = data.length;
            _presentCount = data
                .where((e) => e is Map && e['status'] == 'Present')
                .length;
          }
        });
      }
    } catch (e) {
      print("Error fetching attendance stats: $e");
    }
  }

  String? _qrCodeBase64;

  Future<void> _fetchActiveQR() async {
    if (widget.meeting == null) return;
    try {
      final attendanceAPI = AttendanceAPI();
      final res = await attendanceAPI.getActiveSession(
        widget.meeting!.meetingId,
      );

      dynamic extractData(dynamic r) {
        if (r == null) return null;
        if (r is Map) return r.containsKey('data') ? r['data'] : r;
        return r;
      }

      final data = extractData(res);
      if (data is Map && data['isActive'] == true) {
        final sessionId = data['attendanceSessionId'];
        print(
          'DEV DEBUG - MeetingDetailScreen - QR Session ID (attendanceSessionId) fetched: $sessionId for meetingId: ${widget.meeting!.meetingId}',
        );
        if (sessionId != null) {
          final qrRes = await attendanceAPI.generateQR(sessionId);
          final qrData = extractData(qrRes);
          if (qrData is Map && mounted) {
            setState(() {
              _qrCodeBase64 = qrData['qrCode'] ?? qrData['qrImage'];
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching QR in meeting detail screen: $e");
    }
  }

  Future<void> _startAttendanceSession() async {
    if (widget.meeting == null) return;
    setState(() => _isSubmitting = true);

    try {
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception('Location services disabled');

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Location permissions denied');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions permanently denied');
        }

        position = await Geolocator.getCurrentPosition();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Warning: Using fallback location. Please enable GPS.',
              ),
            ),
          );
        }
      }

      final payload = {
        "meetingId": widget.meeting!.meetingId,
        "latitude": position?.latitude ?? 15.3647,
        "longitude": position?.longitude ?? 75.1240,
        "allowedRadius": 100,
      };

      final attendanceAPI = AttendanceAPI();
      final res = await attendanceAPI.createAttendanceSession(payload);
      dynamic extractData(dynamic r) {
        if (r == null) return null;
        if (r is Map) return r.containsKey('data') ? r['data'] : r;
        return r;
      }

      final data = extractData(res);

      if (data is Map && data['attendanceSessionId'] != null) {
        await _fetchActiveQR();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start session.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _fetchRsvpStatus() async {
    if (widget.meeting == null) {
      setState(() => _isLoadingStatus = false);
      return;
    }
    final currentUser = SessionManager.user;
    if (currentUser == null || currentUser['userId'] == null) {
      setState(() => _isLoadingStatus = false);
      return;
    }

    final response = await _meetingAPI.getAcceptedMeetings(
      currentUser['userId'].toString(),
    );
    if (response != null && response is List) {
      for (var rsvp in response) {
        if (rsvp is Map &&
            rsvp['meeting'] != null &&
            rsvp['meeting']['meetingId'] == widget.meeting!.meetingId) {
          if (mounted) {
            setState(() {
              _rsvpStatus = rsvp['status']?.toString();
            });
            if (_rsvpStatus == 'Accepted') {
              _checkLocationDistance();
            }
          }
          break;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingStatus = false;
      });
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('EEE d MMM Â· h:mm a').format(date);
    } catch (e) {
      return isoString;
    }
  }

  Future<void> _respondToMeeting(String status) async {
    if (widget.meeting == null) return;
    final currentUser = SessionManager.user;
    if (currentUser == null || currentUser['userId'] == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final result = await _meetingAPI.respondMemberMeeting(
      currentUser['userId'],
      widget.meeting!.meetingId,
      status,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      if (result != null) {
        setState(() {
          _rsvpStatus = status;
        });
        if (status == 'Accepted') {
          _checkLocationDistance();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully RSVP\'d: $status!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send RSVP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkLocationDistance() async {
    if (widget.meeting == null) return;

    setState(() => _isCheckingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isCheckingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isCheckingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isCheckingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Use actual meeting coords if available, otherwise use a simulated test location
      // (For test purposes, we'll assume the meeting is exactly at the user's location)
      double meetingLat = widget.meeting!.latitude ?? position.latitude;
      double meetingLng = widget.meeting!.longitude ?? position.longitude;

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        meetingLat,
        meetingLng,
      );

      if (mounted) {
        setState(() {
          _distanceInMeters = distance;
          _isCheckingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCircle = widget.type == 'Circle';

    final String title = isCircle ? "Circle Meeting" : "Sector Team Meeting";
    final String datetime = widget.meeting != null
        ? _formatDate(widget.meeting!.date)
        : "Thu 24 Jul · 7:30 AM";
    final String locationInfo = widget.meeting != null
        ? widget.meeting!.venue
        : "Taluka community hall · QR valid 7:15–9:00 AM";

    // Determine if the current user is the creator of the meeting
    final currentUser = SessionManager.user;
    final currentUserId = currentUser != null ? currentUser['userId'] : null;
    final creatorId = widget.meeting?.createdUser != null
        ? widget.meeting!.createdUser!['userId']
        : null;

    print(
      "DEV DEBUG - Meeting Creator Check -> currentUserId: $currentUserId, creatorId: $creatorId, meetingId: ${widget.meeting?.meetingId}",
    );

    bool isManager = false;
    if (currentUserId != null &&
        creatorId != null &&
        currentUserId == creatorId) {
      isManager = true;
    } else if (currentUser != null && currentUser['roles'] != null) {
      final roles = currentUser['roles'] as List;
      final hasAssemblyRole = roles.any((r) {
        if (r is List) return false;
        if (r is String) return r.toLowerCase().contains('assembly');
        if (r is Map)
          return r['roleName']?.toString().toLowerCase().contains('assembly') ??
              false;
        return false;
      });
      final hasWardRole = roles.any((r) {
        if (r is List) return false;
        if (r is String) return r.toLowerCase().contains('ward');
        if (r is Map)
          return r['roleName']?.toString().toLowerCase().contains('ward') ??
              false;
        return false;
      });

      if (hasAssemblyRole &&
          widget.meeting?.talukaId != null &&
          (widget.meeting?.wardId == null || widget.meeting!.wardId!.isEmpty)) {
        isManager = true;
      } else if (hasWardRole &&
          widget.meeting?.wardId != null &&
          widget.meeting!.wardId!.isNotEmpty) {
        isManager = true;
      }
    }

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
          "Meeting",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        datetime,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.blue.shade700,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              locationInfo,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Text(
                  "Agenda",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (widget.meeting != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.transparent
                              : Colors.grey.shade100,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.meeting!.agenda,
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                  )
                else ...[
                  _buildAgendaRow("7:30", "Open networking"),
                  _buildAgendaRow("7:45", "60-sec member pitches"),
                  _buildAgendaRow("8:15", "UC Training slot"),
                  _buildAgendaRow("8:30", "Lead exchange Â· Gratitude Slips"),
                ],

                const SizedBox(height: 24),

                if (isManager &&
                    (widget.meeting == null ||
                        _meetingStatus.toLowerCase() != 'completed'))
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                        ),
                      ),
                      child: _qrCodeBase64 != null
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.memory(
                                base64Decode(_qrCodeBase64!.split(',').last),
                                fit: BoxFit.contain,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _startAttendanceSession,
                                  icon: const Icon(Icons.qr_code_2),
                                  label: const Text(
                                    "Display venue QR (Start Session)",
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.teal.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Tap to start the attendance session",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                const SizedBox(height: 16),

                if (isManager && widget.meeting != null) ...[
                  Card(
                    elevation: 0,
                    color: Colors.teal.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.teal.shade200),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttendanceSummaryListScreen(
                              meetingId: widget.meeting!.meetingId,
                            ),
                          ),
                        ).then((_) {
                          _fetchAttendanceStats();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people, color: Colors.teal.shade700),
                                const SizedBox(width: 12),
                                Text(
                                  "Attendance Summary",
                                  style: TextStyle(
                                    color: Colors.teal.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "$_presentCount/$_totalMembers",
                                  style: TextStyle(
                                    color: Colors.teal.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.teal.shade700,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (isManager && widget.meeting != null)
                  Column(
                    children: [
                      if (_meetingStatus != 'Started' &&
                          _meetingStatus != 'Ended')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() => _isSubmitting = true);
                              final currentUser = SessionManager.user;
                              if (currentUser == null) return;
                              final success = await _meetingAPI.startMeeting(
                                widget.meeting!.meetingId,
                                currentUser['userId'].toString(),
                                meetingType: widget.meeting!.meetingType,
                              );
                              setState(() => _isSubmitting = false);
                              if (success != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Meeting Started'),
                                  ),
                                );
                                SessionManager.setActiveMeetingId(
                                  widget.meeting!.meetingId,
                                );
                                setState(() {
                                  _meetingStatus = 'Started';
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to start meeting. Ensure you are the original creator of this meeting.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Start Meeting',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (_meetingStatus == 'Started')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() => _isSubmitting = true);
                              final currentUser = SessionManager.user;
                              if (currentUser == null) return;
                              final success = await _meetingAPI.endMeeting(
                                widget.meeting!.meetingId,
                                currentUser['userId'].toString(),
                                meetingType: widget.meeting!.meetingType,
                              );

                              if (success != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Meeting Ended'),
                                  ),
                                );
                                SessionManager.setActiveMeetingId(null);

                                if (mounted) {
                                  setState(() => _isSubmitting = false);
                                  // Use summary from endMeeting response directly
                                  final endData = success is Map ? success['data'] : null;
                                  final endSummary = endData is Map ? endData['summary'] : null;

                                  if (endSummary != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MeetingSummaryScreen(
                                          summaryData: endSummary,
                                          meetingId: widget.meeting!.meetingId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Fallback: fetch summary via separate API call
                                    final summaryResponse = await _meetingAPI
                                        .getMeetingSummary(
                                          widget.meeting!.meetingId,
                                          currentUser['userId'].toString(),
                                        );
                                    if (mounted) {
                                      if (summaryResponse != null &&
                                          summaryResponse['data'] != null &&
                                          summaryResponse['data']['summary'] !=
                                              null) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MeetingSummaryScreen(
                                              summaryData:
                                                  summaryResponse['data']['summary'],
                                              meetingId: widget.meeting!.meetingId,
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.pop(context, true);
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (mounted) {
                                  setState(() => _isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to end meeting. Ensure you are the original creator of this meeting.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'End Meeting',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      if (_meetingStatus == 'Ended' &&
                          widget.meeting!.summary != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MeetingSummaryScreen(
                                    summaryData: widget.meeting!.summary!,
                                    meetingId: widget.meeting!.meetingId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bar_chart),
                            label: const Text('View Full Scorecard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (_meetingStatus != 'Ended')
                        _buildMeetingActivities(context),
                    ],
                  ),

                const SizedBox(height: 32),

                // RSVP Buttons if not the creator and meeting exists
                if (!isManager && widget.meeting != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RSVP for this Meeting",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_isLoadingStatus)
                          const Center(child: CircularProgressIndicator())
                        else if (_rsvpStatus != null &&
                            (_rsvpStatus == 'Accepted' ||
                                _rsvpStatus == 'Rejected'))
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _rsvpStatus == 'Accepted'
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _rsvpStatus == 'Accepted'
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _rsvpStatus == 'Accepted'
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Meeting $_rsvpStatus",
                                  style: TextStyle(
                                    color: _rsvpStatus == 'Accepted'
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_rsvpStatus == 'Accepted') ...[
                          const SizedBox(height: 20),
                          if (_isCheckingLocation)
                            const Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text(
                                    "Checking location...",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          else if (_distanceInMeters != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _distanceInMeters! <= 200
                                    ? Colors.blue.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _distanceInMeters! <= 200
                                      ? Colors.blue.shade200
                                      : Colors.orange.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _distanceInMeters! <= 200
                                            ? Icons.location_on
                                            : Icons.location_off,
                                        color: _distanceInMeters! <= 200
                                            ? Colors.blue.shade700
                                            : Colors.orange.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _distanceInMeters! <= 200
                                              ? "You are at the venue (${_distanceInMeters!.toStringAsFixed(0)}m)"
                                              : "You are too far from the venue (${_distanceInMeters!.toStringAsFixed(0)}m)",
                                          style: TextStyle(
                                            color: _distanceInMeters! <= 200
                                                ? Colors.blue.shade900
                                                : Colors.orange.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _distanceInMeters! <= 200
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const ScanAttendanceQrScreen(),
                                                ),
                                              );
                                            }
                                          : null,
                                      icon: const Icon(Icons.qr_code_scanner),
                                      label: const Text("Scan Attendance QR"),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                          if (widget.meeting != null &&
                              _meetingStatus != 'Ended')
                            _buildMeetingActivities(context),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => _respondToMeeting('Accepted'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Accept",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => _respondToMeeting('Rejected'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Colors.red.shade200,
                                        width: 2,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Reject",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          if (_isSubmitting)
            Container(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildMeetingActivities(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Meeting Activities",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: [
            _activityButton(
              context,
              "Pass Lead",
              Icons.connect_without_contact,
              Colors.orange,
              PassLeadScreen(),
            ),
            _activityButton(
              context,
              "Gratitude",
              Icons.receipt_long,
              Colors.green,
              GratitudeScreen(),
            ),
            _activityButton(
              context,
              "Face to Face",
              Icons.handshake,
              Colors.blue,
              FaceToFaceInviteScreen(),
            ),
            _activityButton(
              context,
              "Add Guest",
              Icons.person_add,
              Colors.purple,
              GuestsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _activityButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        if (widget.meeting != null) {
          SessionManager.setActiveMeetingId(widget.meeting!.meetingId);
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildAgendaRow(String time, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              time,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryWidget(Map<String, dynamic> summary) {
    final totals = summary['totals'] ?? {};
    final attendance = summary['attendance'] ?? {};
    final leads = summary['leads'] ?? {};
    final faceToFace = summary['faceToFace'] ?? {};
    final guests = summary['guests'] ?? {};
    final gratitude = summary['gratitudeSlips'] ?? {};

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Widget _statRow(String label, String value, IconData icon, Color color) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                "Meeting Summary Scorecard",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 24),
          _statRow(
            "Attendance (Present/Total)",
            "${attendance['present'] ?? 0}/${attendance['total'] ?? 0}",
            Icons.people,
            Colors.teal,
          ),
          _statRow(
            "Total Leads Passed",
            "${totals['leads'] ?? 0}",
            Icons.connect_without_contact,
            Colors.orange,
          ),
          _statRow(
            "Total Face-to-Face",
            "${totals['faceToFace'] ?? 0}",
            Icons.handshake,
            Colors.blue,
          ),
          _statRow(
            "Total Guests",
            "${totals['guests'] ?? 0}",
            Icons.person_add,
            Colors.purple,
          ),
          _statRow(
            "Gratitude Slips",
            "${totals['gratitudeSlips'] ?? 0}",
            Icons.receipt_long,
            Colors.green,
          ),
          _statRow(
            "Business Value",
            "â‚¹${totals['businessValue'] ?? 0}",
            Icons.currency_rupee,
            Colors.green.shade700,
          ),
        ],
      ),
    );
  }
}
