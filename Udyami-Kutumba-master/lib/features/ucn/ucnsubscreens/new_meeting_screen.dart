import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api/ubn/meeting_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../core/models/user_model.dart' as import_user_model;
import '../../../core/api/role/role_api.dart' as import_role_api;
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/location/location_api.dart';
import 'map_picker_screen.dart';

class NewMeetingScreen extends StatefulWidget {
  const NewMeetingScreen({super.key});

  @override
  State<NewMeetingScreen> createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Circle';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _agendaController = TextEditingController();
  bool _isLoading = false;

  final MeetingAPI _meetingAPI = MeetingAPI();

  @override
  void dispose() {
    _venueController.dispose();
    _agendaController.dispose();
    super.dispose();
  }

  Future<String?> _resolveTalukaId(String userId) async {
    try {
      final profileRes = await ProfileAPI().getUserProfileById(userId);
      if (profileRes != null && profileRes['success'] == true) {
        final profile = profileRes['data']?['profile'] ?? {};
        final districtName = profile['district']?.toString();
        final assemblyName =
            profile['assembly']?.toString() ?? profile['taluka']?.toString();

        if (districtName != null &&
            districtName.isNotEmpty &&
            assemblyName != null &&
            assemblyName.isNotEmpty) {
          final distApiRes = await LocationAPI().getAllDistricts();
          if (distApiRes != null && distApiRes['success'] == true) {
            final List rawDistricts = distApiRes['data'] ?? [];
            final matchDist = rawDistricts
                .cast<Map<String, dynamic>>()
                .firstWhere(
                  (d) =>
                      d['districtName']?.toString().toLowerCase() ==
                      districtName.toLowerCase(),
                  orElse: () => <String, dynamic>{},
                );

            if (matchDist.isNotEmpty) {
              final distId = matchDist['districtId']?.toString();
              if (distId != null) {
                final talukaApiRes = await LocationAPI().getAllDistricts(
                  districtId: distId,
                );
                if (talukaApiRes != null && talukaApiRes['success'] == true) {
                  final List rawTalukas = talukaApiRes['data'] ?? [];
                  final matchTaluka = rawTalukas
                      .cast<Map<String, dynamic>>()
                      .firstWhere(
                        (t) =>
                            t['talukaName']?.toString().toLowerCase() ==
                            assemblyName.toLowerCase(),
                        orElse: () => <String, dynamic>{},
                      );
                  if (matchTaluka.isNotEmpty) {
                    return matchTaluka['talukaId']?.toString();
                  }
                }
              }
            }

            // Search all districts
            for (var dist in rawDistricts) {
              final dId = dist['districtId']?.toString();
              if (dId != null) {
                final talukasRes = await LocationAPI().getAllDistricts(
                  districtId: dId,
                );
                if (talukasRes != null && talukasRes['success'] == true) {
                  final List tList = talukasRes['data'] ?? [];
                  final tMatch = tList.cast<Map<String, dynamic>>().firstWhere(
                    (t) =>
                        t['talukaName']?.toString().toLowerCase() ==
                        assemblyName.toLowerCase(),
                    orElse: () => <String, dynamic>{},
                  );
                  if (tMatch.isNotEmpty) {
                    return tMatch['talukaId']?.toString();
                  }
                }
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 30),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _createMeeting() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    final user = SessionManager.user;
    if (user == null || user['userId'] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User session not found')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final payload = {
      "date": dateTime.toUtc().toIso8601String(),
      "venue": _venueController.text.trim(),
      "agenda": _agendaController.text.trim(),
      "status": "Scheduled",
    };

    // Determine if we are creating an assembly meeting or ward meeting based on user role
    bool isAssemblyPresident = false;
    bool isWardLeader = false;
    String? talukaId;
    String? wardId;

    try {
      final currentUser = import_user_model.UserModel.fromJson(user);
      final roleWithTaluka = currentUser.roles.firstWhere(
        (r) =>
            r.roleName.toLowerCase() == 'assembly_president' ||
            r.roleName.toLowerCase() == 'assembly president',
        orElse: () => import_user_model.RoleModel(roleId: 0, roleName: ''),
      );

      if (roleWithTaluka.roleName.isNotEmpty) {
        isAssemblyPresident = true;
        talukaId = roleWithTaluka.talukaId;
      } else {
        final roleWithWard = currentUser.roles.firstWhere(
          (r) => r.wardId != null && r.wardId!.isNotEmpty,
          orElse: () => import_user_model.RoleModel(roleId: 0, roleName: ''),
        );
        if (roleWithWard.wardId != null && roleWithWard.wardId!.isNotEmpty) {
          isWardLeader = true;
          wardId = roleWithWard.wardId;
          talukaId = roleWithWard.talukaId;
        }
      }

      // Fallback if missing ids
      if ((isAssemblyPresident && (talukaId == null || talukaId!.isEmpty)) ||
          (!isAssemblyPresident && (wardId == null || wardId!.isEmpty))) {
        final rolesRes = await import_role_api.RoleAPI().getAllRoleUsers();
        if (rolesRes != null && rolesRes['success'] == true) {
          final List rawRoleUsers = rolesRes['data'] ?? [];
          final matchUser = rawRoleUsers
              .cast<Map<String, dynamic>>()
              .firstWhere(
                (u) => u['userId'] == user['userId'].toString(),
                orElse: () => {},
              );
          if (matchUser.isNotEmpty) {
            Map<String, dynamic>? assignment;
            if (matchUser.containsKey('assignment') &&
                matchUser['assignment'] != null) {
              assignment = matchUser['assignment'];
            } else if (matchUser.containsKey('positionHolder') &&
                matchUser['positionHolder'] != null) {
              final ph = matchUser['positionHolder'];
              if (ph is Map &&
                  ph.containsKey('assignment') &&
                  ph['assignment'] != null) {
                assignment = ph['assignment'] as Map<String, dynamic>;
              }
            }
            if (assignment != null) {
              if (isAssemblyPresident) {
                talukaId ??= assignment['talukaId']?.toString();
              } else {
                wardId ??= assignment['wardId']?.toString();
                talukaId ??= assignment['talukaId']?.toString();
                if (wardId != null && wardId!.isNotEmpty) {
                  isWardLeader = true;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("DEV DEBUG - Failed to resolve assembly/ward status: $e");
    }

    // ULTIMATE FALLBACK
    if (talukaId == null && (isAssemblyPresident || isWardLeader)) {
      talukaId = await _resolveTalukaId(user['userId'].toString());
    }

    dynamic response;
    if (isAssemblyPresident && talukaId != null && talukaId!.isNotEmpty) {
      payload['talukaId'] = talukaId;
      payload['meetingType'] = 'Assembly';
      print('DEV DEBUG - Creating Assembly Meeting with talukaId: $talukaId');
      response = await _meetingAPI.createAsemblyBasedMeetings(
        user['userId'].toString(),
        payload,
      );
    } else if (isWardLeader && wardId != null && wardId!.isNotEmpty) {
      payload['wardId'] = wardId;
      payload['meetingType'] = 'Ward';
      if (talukaId != null && talukaId!.isNotEmpty) {
        payload['talukaId'] = talukaId;
      }
      print('DEV DEBUG - Creating Ward Meeting with wardId: $wardId');
      response = await _meetingAPI.createWardBasedMeetings(
        user['userId'].toString(),
        payload,
      );
    } else {
      print('DEV DEBUG - Creating normal Circle Meeting');
      response = await _meetingAPI.createMeeting(
        user['userId'].toString(),
        payload,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (response != null &&
          (response['meetingId'] != null || response['success'] == true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting created successfully!')),
        );
        Navigator.pop(context, true); // Return true to refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to create meeting'),
          ),
        );
      }
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
          "New meeting",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Type",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    _buildSegmentedButton("Circle"),
                    _buildSegmentedButton("Special"),
                    _buildSegmentedButton("Training"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade900
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                          ),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? "Select Date"
                              : DateFormat('EEE d MMM').format(_selectedDate!),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _selectedDate == null
                                ? Colors.grey
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade900
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                          ),
                        ),
                        child: Text(
                          _selectedTime == null
                              ? "Select Time"
                              : _selectedTime!.format(context),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _selectedTime == null
                                ? Colors.grey
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                "Venue",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(
                  hintText: "Enter venue (e.g. Taluka community hall)",
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    tooltip: "Select on Map",
                    onPressed: () async {
                      final selectedAddress = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MapPickerScreen(),
                        ),
                      );
                      if (selectedAddress != null &&
                          selectedAddress is String) {
                        setState(() {
                          _venueController.text = selectedAddress;
                        });
                      }
                    },
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Venue is required'
                    : null,
              ),

              const SizedBox(height: 24),

              Text(
                "Agenda",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _agendaController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter meeting agenda items here...",
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Agenda is required'
                    : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createMeeting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade900
                                : Theme.of(context).colorScheme.surface,
                          ),
                        )
                      : Text(
                          "CREATE MEETING",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedButton(String text) {
    bool isSelected = _selectedType == text;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = text;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.transparent
                          : Colors.grey.shade100,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
