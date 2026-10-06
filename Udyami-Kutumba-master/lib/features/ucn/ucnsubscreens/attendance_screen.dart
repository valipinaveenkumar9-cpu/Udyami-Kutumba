import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../../core/api/ubn/attendance_api.dart';
import '../../../core/api/ubn/meeting_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../core/models/user_model.dart' as import_user_model;
import '../../../core/api/role/role_api.dart' as import_role_api;
import 'package:geolocator/geolocator.dart' as import_geolocator;

class AttendanceScreen extends StatefulWidget {
  final String? initialMeetingId;

  const AttendanceScreen({super.key, this.initialMeetingId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceAPI _attendanceAPI = AttendanceAPI();
  final MeetingAPI _meetingAPI = MeetingAPI();

  bool _isLoading = true;
  String? _selectedMeetingId;
  List<dynamic> _meetings = [];

  bool _isActiveSession = false;
  String? _attendanceSessionId;
  String? _qrCodeBase64;

  int _totalMembers = 0;
  int _presentCount = 0;
  int _absentCount = 0;
  List<dynamic> _attendanceList = [];

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _selectedMeetingId = widget.initialMeetingId;
    _fetchInitialData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  dynamic _extractData(dynamic res) {
    if (res == null) return null;
    if (res is Map) {
      if (res.containsKey('data')) return res['data'];
      return res;
    }
    return res;
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);

    try {
      if (_selectedMeetingId == null) {
        final userJson = SessionManager.user;
        dynamic response;

        if (userJson != null && userJson['userId'] != null) {
          final String userId = userJson['userId'].toString();
          bool isAssemblyPresident = false;
          String? talukaId;

          try {
            final currentUser = import_user_model.UserModel.fromJson(userJson);
            final roleWithTaluka = currentUser.roles.firstWhere(
              (r) =>
                  r.roleName.toLowerCase().contains('assembly_president') ||
                  r.roleName.toLowerCase().contains('assembly president'),
              orElse: () =>
                  import_user_model.RoleModel(roleId: 0, roleName: ''),
            );
            if (roleWithTaluka.roleName.isNotEmpty) {
              isAssemblyPresident = true;
              if (roleWithTaluka.talukaId != null &&
                  roleWithTaluka.talukaId!.isNotEmpty) {
                talukaId = roleWithTaluka.talukaId;
              } else {
                final rolesRes = await import_role_api.RoleAPI()
                    .getAllRoleUsers();
                if (rolesRes != null && rolesRes['success'] == true) {
                  final List rawRoleUsers = rolesRes['data'] ?? [];
                  final matchUser = rawRoleUsers
                      .cast<Map<String, dynamic>>()
                      .firstWhere(
                        (u) => u['userId'] == userId,
                        orElse: () => {},
                      );
                  if (matchUser.isNotEmpty &&
                      matchUser.containsKey('assignment')) {
                    final assignment = matchUser['assignment'] ?? {};
                    if (assignment['talukaId'] != null) {
                      talukaId = assignment['talukaId'].toString();
                    }
                  }
                }
              }
            } else {
              // Check if user is a Ward Leader
              final roleWithWard = currentUser.roles.firstWhere(
                (r) => r.wardId != null && r.wardId!.isNotEmpty,
                orElse: () =>
                    import_user_model.RoleModel(roleId: 0, roleName: ''),
              );
              String? wId;
              if (roleWithWard.wardId != null &&
                  roleWithWard.wardId!.isNotEmpty) {
                wId = roleWithWard.wardId;
                talukaId = roleWithWard.talukaId;
              } else {
                // Fallback to RoleAPI for wardId
                final rolesRes = await import_role_api.RoleAPI()
                    .getAllRoleUsers();
                if (rolesRes != null && rolesRes['success'] == true) {
                  final List rawRoleUsers = rolesRes['data'] ?? [];
                  final matchUser = rawRoleUsers
                      .cast<Map<String, dynamic>>()
                      .firstWhere(
                        (u) => u['userId'] == userId,
                        orElse: () => {},
                      );
                  if (matchUser.isNotEmpty &&
                      matchUser.containsKey('assignment')) {
                    final assignment = matchUser['assignment'] ?? {};
                    if (assignment['wardId'] != null) {
                      wId = assignment['wardId'].toString();
                    }
                    if (assignment['talukaId'] != null) {
                      talukaId = assignment['talukaId'].toString();
                    }
                  }
                }
              }

              if (wId != null) {
                print(
                  'DEV DEBUG - AttendanceScreen - Fetching Ward Meetings for wardId: $wId',
                );
                List combinedMeetings = [];
                final r = await _meetingAPI.getAllWardMeetings(wId);
                if (r != null && r['success'] == true) {
                  combinedMeetings.addAll(r['data'] ?? []);
                }
                if (talukaId != null && talukaId!.isNotEmpty) {
                  final rAssembly = await _meetingAPI.getAllAssemblyMeetings(
                    talukaId,
                  );
                  if (rAssembly != null && rAssembly['success'] == true) {
                    combinedMeetings.addAll(rAssembly['data'] ?? []);
                  }
                }
                if (combinedMeetings.isNotEmpty) {
                  response = combinedMeetings;
                }
              }
            }
          } catch (e) {
            print(
              "DEV DEBUG - Failed resolving roles for AttendanceScreen: $e",
            );
          }

          if (isAssemblyPresident && talukaId != null && talukaId!.isNotEmpty) {
            final r = await _meetingAPI.getAllAssemblyMeetings(talukaId);
            if (r != null && r['success'] == true) {
              response = r['data'];
            }
          } else if (response == null) {
            // Check if there are meetings created by this user
            final r = await _meetingAPI.getAllMeetingsByCreatedUserId(userId);
            if (r != null && r['success'] == true) {
              response = r['data'];
            } else {
              response = await _meetingAPI.getAllMeetings();
            }

            // Filter out Assembly Meetings for normal members
            if (response != null && response is List) {
              response = response.where((m) {
                if (m is Map &&
                    m['talukaId'] != null &&
                    m['talukaId'].toString().isNotEmpty &&
                    (m['wardId'] == null || m['wardId'].toString().isEmpty)) {
                  final createdUser = m['createdUser'];
                  if (createdUser is Map && createdUser['userId'] == userId) {
                    return true;
                  }
                  if (isAssemblyPresident) {
                    return true;
                  }
                  return false;
                }
                return true;
              }).toList();
            }
          }
        } else {
          response = await _meetingAPI.getAllMeetings();
        }

        if (response != null && response is List) {
          if (mounted) {
            setState(() {
              _meetings = response;
              if (_meetings.isNotEmpty) {
                _selectedMeetingId = _meetings.first['meetingId'];
              }
            });
          }
        }
      }

      if (_selectedMeetingId != null) {
        await _checkActiveSession();
        if (_isActiveSession) {
          _startPolling();
        }
      }
    } catch (e) {
      print("Error in _fetchInitialData: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _checkActiveSession() async {
    if (_selectedMeetingId == null) return;

    final res = await _attendanceAPI.getActiveSession(_selectedMeetingId!);
    final data = _extractData(res);
    print(
      'DEV DEBUG - AttendanceScreen - Checked active session for meeting: $_selectedMeetingId',
    );

    if (data is Map && data['isActive'] == true) {
      _attendanceSessionId = data['attendanceSessionId'];
      print(
        'DEV DEBUG - AttendanceScreen - Active Session ID found: $_attendanceSessionId',
      );
      _isActiveSession = true;
      await _fetchQR();
      await _fetchAttendanceList();
    } else {
      _isActiveSession = false;
      _attendanceSessionId = null;
      _qrCodeBase64 = null;
    }
    if (mounted) setState(() {});
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_selectedMeetingId != null && _isActiveSession) {
        _fetchAttendanceList();
      }
    });
  }

  Uint8List? _qrBytes;

  Future<void> _fetchQR() async {
    if (_attendanceSessionId == null) return;
    print(
      'DEV DEBUG - AttendanceScreen - Fetching QR for session: $_attendanceSessionId',
    );
    final res = await _attendanceAPI.generateQR(_attendanceSessionId!);
    final data = _extractData(res);

    if (data is Map && mounted) {
      setState(() {
        _qrCodeBase64 = data['qrCode'] ?? data['qrImage'];
        if (_qrCodeBase64 != null) {
          try {
            _qrBytes = base64Decode(_qrCodeBase64!.split(',').last);
            print(
              'DEV DEBUG - AttendanceScreen - QR Code decoded successfully. Bytes length: ${_qrBytes!.length}',
            );
          } catch (e) {
            _qrBytes = null;
            print(
              'DEV DEBUG - AttendanceScreen - Failed to decode QR Code: $e',
            );
          }
        } else {
          print(
            'DEV DEBUG - AttendanceScreen - QR Code base64 string is null from API response.',
          );
        }
      });
    } else {
      print(
        'DEV DEBUG - AttendanceScreen - Failed to fetch QR or data is not a Map.',
      );
    }
  }

  Future<void> _fetchAttendanceList() async {
    if (_selectedMeetingId == null) return;
    final res = await _attendanceAPI.getMeetingAttendance(_selectedMeetingId!);
    final data = _extractData(res);

    if (data != null && mounted) {
      setState(() {
        if (data is Map) {
          _totalMembers = data['totalMembers'] != null
              ? int.tryParse(data['totalMembers'].toString()) ?? 0
              : 0;
          _presentCount = data['present'] != null
              ? int.tryParse(data['present'].toString()) ?? 0
              : 0;
          _absentCount = data['absent'] != null
              ? int.tryParse(data['absent'].toString()) ?? 0
              : 0;
          _attendanceList = data['attendance'] is List
              ? data['attendance']
              : [];
        } else if (data is List) {
          _totalMembers = data.length;
          _presentCount = data
              .where((e) => e is Map && e['status'] == 'Present')
              .length;
          _absentCount = data
              .where((e) => e is Map && e['status'] == 'Absent')
              .length;
          _attendanceList = data;
        }

        print(
          'DEV DEBUG - UCN Action Screen (MEETING_PRESENT & MEETING_ABSENT) - Data fetched successfully.',
        );
        print(
          'DEV DEBUG - UCN Action Screen (MEETING_PRESENT & MEETING_ABSENT) - Total: $_totalMembers (Present: $_presentCount, Absent: $_absentCount)',
        );
      });
    }
  }

  Future<void> _startAttendance() async {
    if (_selectedMeetingId == null) return;
    setState(() => _isLoading = true);

    try {
      import_geolocator.Position? position;
      try {
        bool serviceEnabled =
            await import_geolocator.Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception('Location services disabled');

        import_geolocator.LocationPermission permission =
            await import_geolocator.Geolocator.checkPermission();
        if (permission == import_geolocator.LocationPermission.denied) {
          permission = await import_geolocator.Geolocator.requestPermission();
          if (permission == import_geolocator.LocationPermission.denied) {
            throw Exception('Location permissions denied');
          }
        }

        if (permission == import_geolocator.LocationPermission.deniedForever) {
          throw Exception('Location permissions permanently denied');
        }

        position = await import_geolocator.Geolocator.getCurrentPosition();
      } catch (e) {
        print(
          'DEV DEBUG - AttendanceScreen - Could not get GPS for session: $e',
        );
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
        "meetingId": _selectedMeetingId,
        "latitude": position?.latitude ?? 15.3647,
        "longitude": position?.longitude ?? 75.1240,
        "allowedRadius": 100,
      };

      print(
        'DEV DEBUG - AttendanceScreen - Creating new session for meeting: $_selectedMeetingId',
      );
      final res = await _attendanceAPI.createAttendanceSession(payload);
      final data = _extractData(res);

      if (data is Map && data['attendanceSessionId'] != null) {
        _attendanceSessionId = data['attendanceSessionId'];
        _isActiveSession = true;
        await _fetchQR();
        await _fetchAttendanceList();
        _startPolling();
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start session.')),
          );
      }
    } catch (e) {
      print("Error in _startAttendance: $e");
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _closeAttendance() async {
    if (_attendanceSessionId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Close Attendance?'),
        content: const Text(
          'Once closed, members can no longer scan the QR code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final res = await _attendanceAPI.closeSession(_attendanceSessionId!);
    if (res != null && res['success'] == true) {
      _isActiveSession = false;
      _pollingTimer?.cancel();
      
      // Also end the meeting since the user expects closing attendance to finish the meeting
      if (_selectedMeetingId != null) {
          final currentUserId = SessionManager.user?['userId'];
          if (currentUserId != null) {
            String? mType;
            if (_selectedMeetingId != null) {
              try {
                final mtg = _meetings.firstWhere((m) => m['meetingId'] == _selectedMeetingId);
                mType = mtg['meetingType'];
              } catch (_) {}
            }
            await _meetingAPI.endMeeting(_selectedMeetingId!, currentUserId.toString(), meetingType: mType);
            SessionManager.setActiveMeetingId(null);
          }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session closed and Meeting Ended.')));
        // Navigate back to previous screen
        Navigator.pop(context, true);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _markManual(String userId, String status, String remarks) async {
    if (_selectedMeetingId == null) return;

    // The user marking the attendance is the currently logged-in user (meeting creator / area leader)
    final currentUserId = SessionManager.user?['userId'];
    if (currentUserId == null) return;

    final payload = {
      "meetingId": _selectedMeetingId,
      "userId": userId,
      "status": status,
      "attendanceType": "Manual",
      "remarks": remarks,
      "markedBy": currentUserId,
    };

    final res = await _attendanceAPI.addManualAttendance(payload);
    if (res != null && res['success'] == true) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Updated successfully.')));
      _fetchAttendanceList();
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res?['message'] ?? 'Failed update')),
        );
    }
  }

  void _showManualOverrideDialog(Map<String, dynamic> userAtt) {
    String selectedStatus = userAtt['status'] ?? 'Present';
    String remarks = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) {
        return StatefulBuilder(
          builder: (c, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Manual Override: ${userAtt['userName']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'Present',
                        child: Text('Present'),
                      ),
                      DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                      DropdownMenuItem(value: 'Late', child: Text('Late')),
                    ],
                    onChanged: (v) => setModalState(() => selectedStatus = v!),
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Remarks',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => remarks = v,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(c);
                        _markManual(userAtt['userId'], selectedStatus, remarks);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
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
          "Attendance",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.initialMeetingId == null) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedMeetingId,
                      hint: const Text("Select Meeting"),
                      items: _meetings
                          .map(
                            (m) => DropdownMenuItem<String>(
                              value: m['meetingId'],
                              child: Text(m['agenda'] ?? m['meetingId']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedMeetingId = v);
                        _checkActiveSession();
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_selectedMeetingId != null && !_isActiveSession)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _startAttendance,
                        icon: const Icon(Icons.qr_code_2_rounded),
                        label: const Text(
                          "Display venue QR (Start Session)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: BorderSide(color: Colors.teal.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                  if (_isActiveSession) ...[
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                                color: Colors.teal.shade900,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "QR check-in · Active",
                                  style: TextStyle(
                                    color: Colors.teal.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Members scan the venue QR on-site · off-site scans rejected · geofence 100 m",
                            style: TextStyle(
                              color: Colors.teal.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Present",
                            _presentCount.toString(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            "Total",
                            _totalMembers.toString(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            "Absent",
                            _absentCount.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Display QR Button or QR Image directly
                    if (_qrBytes != null)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Image.memory(
                            _qrBytes!,
                            width: 200,
                            height: 200,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    const Text(
                      "Roster · tap to set a manual override",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Roster List
                    if (_attendanceList.isEmpty)
                      const Text(
                        "No members found.",
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ..._attendanceList.map((att) {
                        final status = att['status'] ?? 'Absent';
                        final type = att['attendanceType'] ?? '';
                        final isPresent = status == 'Present';
                        final isQr = type == 'QR';

                        return _buildRosterRow(
                          att['userName'] ?? 'Unknown',
                          type,
                          status,
                          isPresent
                              ? Colors.teal
                              : (status == 'Late' ? Colors.orange : Colors.red),
                          icon: isQr ? Icons.location_on : null,
                          onTap: () => _showManualOverrideDialog(att),
                        );
                      }),

                    const SizedBox(height: 24),

                    // Warning Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Manual override is logged and needs Chairman sign-off",
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Publish Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _closeAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Close attendance & publish",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterRow(
    String name,
    String subtitle,
    String badgeText,
    MaterialColor badgeColor, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
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
                color: badgeColor.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 12, color: badgeColor.shade700),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
