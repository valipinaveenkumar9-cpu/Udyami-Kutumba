import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/api/ubn/face_to_face_api.dart';
import '../../../core/api/directory/directory_api.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/user_profile_model.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../auth/presentation/widgets/map_selection_modal.dart';
import '../../profile/presentation/profile_screen.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'face_to_face_screen.dart';

class FaceToFaceInviteScreen extends StatefulWidget {
  const FaceToFaceInviteScreen({super.key});

  @override
  State<FaceToFaceInviteScreen> createState() => _FaceToFaceInviteScreenState();
}

class _FaceToFaceInviteScreenState extends State<FaceToFaceInviteScreen> {
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedMemberId;
  bool _isLoading = false;
  bool _isProfileLoading = true;
  UserProfileModel? _profileData;
  UserProfileModel? _invitedMemberProfile;
  bool _isInvitedMemberLoading = false;

  double? _selectedLat;
  double? _selectedLng;
  bool _useBusinessLocation = false;

  @override
  void initState() {
    super.initState();
    print("DEV DEBUG - FaceToFaceInviteScreen: initState called, screen loaded.");
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    print("DEV DEBUG - FaceToFaceInviteScreen: _fetchProfile started.");
    final stopwatch = Stopwatch()..start();
    try {
      final user = SessionManager.user;
      if (user != null && user['userId'] != null) {
        final userId = user['userId'].toString();
        print("DEV DEBUG - FaceToFaceInviteScreen: calling ProfileAPI.getUserProfileById for $userId");
        final response = await ProfileAPI().getUserProfileById(userId);
        print("DEV DEBUG - FaceToFaceInviteScreen: ProfileAPI response received.");
        if (response != null && response['success'] == true) {
          setState(() {
            _profileData = UserProfileModel.fromJson(response['data']);
          });
        }
      }
    } catch (e) {
      print("DEV DEBUG - FaceToFaceInviteScreen: Error fetching profile: $e");
    } finally {
      stopwatch.stop();
      print("DEV DEBUG - FaceToFaceInviteScreen: ProfileAPI call took ${stopwatch.elapsedMilliseconds}ms");
      setState(() {
        _isProfileLoading = false;
      });
    }
  }

  Future<void> _fetchInvitedMemberProfile(String userId) async {
    setState(() {
      _isInvitedMemberLoading = true;
      _invitedMemberProfile = null;
    });
    try {
      final response = await ProfileAPI().getUserProfileById(userId);
      if (response != null && response['success'] == true) {
        setState(() {
          _invitedMemberProfile = UserProfileModel.fromJson(response['data']);
        });
      }
    } catch (e) {
      print("Error fetching invited member profile: $e");
    } finally {
      setState(() {
        _isInvitedMemberLoading = false;
      });
    }
  }

  void _openMemberSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _F2FMemberSelectionSheet(
          onSelected: (userId, name, phone) {
            setState(() {
              if (userId != null) {
                _selectedMemberId = userId;
                _fetchInvitedMemberProfile(userId);
              } else {
                _selectedMemberId = "external_contact_${DateTime.now().millisecondsSinceEpoch}";
              }
              _memberController.text = name;
              if (phone != null && phone.isNotEmpty) {
                _phoneController.text = phone;
              }
            });
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _openMapToSelectLocation() async {
    LatLng? initial = (_selectedLat != null && _selectedLng != null)
        ? LatLng(_selectedLat!, _selectedLng!) : null;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => MapSelectionModal(
        initialLocation: initial,
      ),
    );

    if (result != null && result['location'] != null) {
      final loc = result['location'] as LatLng;
      setState(() {
        _selectedLat = loc.latitude;
        _selectedLng = loc.longitude;
        _locationController.text = "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}";
        _useBusinessLocation = false;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedMemberId == null || _dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member and Date fields are required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userData = SessionManager.user;
    String? currentUserId;
    if (userData != null) {
      currentUserId = UserModel.fromJson(userData).userId;
    }

    final payload = {
      "createdUserId": currentUserId ?? "",
      "invitedMemberUserId": _selectedMemberId!,
      "date": _dateController.text.trim(),
      "purpose": _purposeController.text.trim(),
      "status": "Pending",
      "feedback": "",
      "message": "",
      if (SessionManager.activeMeetingId != null) "meetingId": SessionManager.activeMeetingId,
      "location": _locationController.text.trim(),
      "latitude": _selectedLat?.toString(),
      "longitude": _selectedLng?.toString(),
      "businessName": _profileData?.profile.businessDetails?.businessName ?? "",
      "profession": _profileData?.profile.businessCategory ?? _profileData?.profile.businessDetails?.businessType ?? "",
      "yearsInBusiness": _profileData?.profile.businessDetails?.yearsInBusiness,
      "previousJobs": _profileData?.profile.businessDetails?.previousJobs ?? "",
      "spouse": _profileData?.profile.spouse ?? "",
      "children": _profileData?.profile.children ?? "",
      "pets": _profileData?.profile.pets ?? "",
      "hobbies": _profileData?.profile.hobbies ?? "",
      "activitiesOrInterests": _profileData?.profile.interests ?? "",
      "cityOfResidence": _profileData?.profile.cityOfResidence ?? "",
      "yearsInCity": _profileData?.profile.yearsInCity,
      "familyInformation": "",
    };

    final success = await FaceToFaceAPI.createFaceToFace(payload);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Face to Face requested successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create request.")),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedProfileCard(String title, UserProfileModel profile, IconData titleIcon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(titleIcon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoText("Name:", profile.user.name)),
                Expanded(child: _buildInfoText("Date:", _dateController.text.isNotEmpty ? _dateController.text : "Not Selected")),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Business Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _buildInfoRow("Business Name:", profile.profile.businessDetails?.businessName),
            _buildInfoRow("Profession:", profile.profile.businessCategory),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoText("Location:", profile.profile.businessDetails?.businessAddress)),
                Expanded(child: _buildInfoText("Years in Business:", profile.profile.businessDetails?.yearsInBusiness)),
              ],
            ),
            _buildInfoRow("Previous types of jobs:", profile.profile.businessDetails?.previousJobs),

            const SizedBox(height: 16),

            const Text("Personal Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            const Text("Family Information", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("A. Spouse / Significant Other:", profile.profile.spouse),
                  _buildInfoRow("B. Children:", profile.profile.children),
                  _buildInfoRow("C. Animals:", profile.profile.pets),
                ],
              ),
            ),

            _buildInfoRow("Hobbies:", profile.profile.hobbies),
            _buildInfoRow("Activities of interest:", profile.profile.interests),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoText("City of residence:", profile.profile.cityOfResidence)),
                Expanded(child: _buildInfoText("How long?:", profile.profile.yearsInCity)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    if (_isProfileLoading) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading Profile Data..."),
              ],
            ),
          ),
        ),
      );
    }

    if (_profileData == null || !_profileData!.profile.hasBusiness) {
      return Card(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.amber.shade900 : Colors.amber.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: const Icon(Icons.warning, color: Colors.amber, size: 40),
          title: const Text("Business Profile Not Updated", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text("Please update your profile to share your business and personal details with the invitee."),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              _fetchProfile();
            },
            child: const Text("Update Profile"),
          ),
        ),
      );
    }

    return _buildUnifiedProfileCard("My Profile", _profileData!, Icons.account_circle);
  }

  Widget _buildInvitedMemberCard() {
    if (_isInvitedMemberLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_invitedMemberProfile == null || !_invitedMemberProfile!.profile.hasBusiness) {
      return Card(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade900.withOpacity(0.5) : Colors.orange.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "This member has not fully updated their profile yet. You may not see all their details.",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildUnifiedProfileCard("Invited Member Profile", _invitedMemberProfile!, Icons.person_pin_circle);
  }

  @override
  void dispose() {
    _memberController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _purposeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: Icon(Icons.history, color: theme.colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaceToFaceScreen()),
              );
            },
          ),
        ],
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Schedule Face to Face",
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: isDark ? Colors.transparent : Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Meeting Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                  TextField(
                    controller: _memberController,
                    readOnly: true,
                    onTap: _openMemberSelectionDialog,
                    decoration: InputDecoration(
                      hintText: "With which member?",
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.person_search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  if (_selectedMemberId != null && !_selectedMemberId!.startsWith('external')) ...[
                    const SizedBox(height: 12),
                    _buildInvitedMemberCard(),
                  ],
                  const SizedBox(height: 12),

                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      hintText: "Date (yyyy-mm-dd)",
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meeting Location
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: "Meeting Location",
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed: _openMapToSelectLocation,
                        tooltip: "Select on Map",
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),

                  if (_profileData?.profile.businessDetails?.businessAddress != null)
                    CheckboxListTile(
                      title: const Text("Use my business location", style: TextStyle(fontSize: 14)),
                      value: _useBusinessLocation,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setState(() {
                          _useBusinessLocation = val ?? false;
                          if (_useBusinessLocation) {
                            _locationController.text = _profileData!.profile.businessDetails!.businessAddress!;
                            _selectedLat = _profileData!.profile.businessDetails!.latitude;
                            _selectedLng = _profileData!.profile.businessDetails!.longitude;
                          } else {
                            _locationController.clear();
                            _selectedLat = null;
                            _selectedLng = null;
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _purposeController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Purpose (Optional)",
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _submitRequest,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Send Invite", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Bottom Sheet for F2F Member Selection (with Contacts Tab)
// ==========================================

class _F2FMemberSelectionSheet extends StatefulWidget {
  final Function(String? userId, String name, String? phone) onSelected;
  const _F2FMemberSelectionSheet({required this.onSelected});

  @override
  State<_F2FMemberSelectionSheet> createState() => _F2FMemberSelectionSheetState();
}

class _F2FMemberSelectionSheetState extends State<_F2FMemberSelectionSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late TabController _tabController;
  List<dynamic> _members = [];
  bool _isLoadingMembers = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchMembers();
      }
    });
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    if (_tabController.index == 0) {
      setState(() => _isLoadingMembers = true);
      final results = await DirectoryAPI().searchMembers(_searchQuery, '');

      // Filter out Sector Heads and Circle Leaders
      final filteredMembers = results.where((m) {
        final name = (m['name'] ?? '').toString().toLowerCase();
        final roles = m['roles'] as List<dynamic>? ?? [];
        final userRoles = m['userRoles'] as List<dynamic>? ?? [];

        bool isLeader = roles.contains('circle_leader') || roles.contains('sector_head') ||
            userRoles.any((ur) {
              if (ur is Map && ur['role'] is Map) {
                final roleName = ur['role']['roleName']?.toString();
                return roleName == 'circle_leader' || roleName == 'sector_head';
              }
              return false;
            });

        bool hasLeaderName = name.contains('circle leader') || name.contains('sector head');
        return !isLeader && !hasLeaderName;
      }).toList();

      if (mounted) {
        setState(() {
          _members = filteredMembers;
          _isLoadingMembers = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "Select Member",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.teal,
                tabs: const [
                  Tab(text: "UCN Members"),
                  Tab(text: "Contacts"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? Colors.black : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    _searchQuery = v;
                    _fetchMembers();
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // UCN Members List
                    _isLoadingMembers
                        ? const Center(child: CircularProgressIndicator())
                        : _members.isEmpty
                        ? const Center(child: Text("No normal members found"))
                        : ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _members.length,
                      separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      itemBuilder: (ctx, idx) {
                        final m = _members[idx];
                        final name = m['name'] ?? 'Unknown';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.withValues(alpha: 0.15),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          subtitle: Text(m['email'] ?? '', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                          onTap: () => widget.onSelected(m['userId'], name, null),
                        );
                      },
                    ),
                    // Device Contacts Tab
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
                            final contact = await _contactPicker.selectContact();
                            if (contact != null) {
                              final name = contact.fullName ?? '';
                              final phone = contact.phoneNumbers?.isNotEmpty == true ? contact.phoneNumbers!.first : '';
                              widget.onSelected(null, name, phone);
                            }
                          },
                          icon: const Icon(Icons.perm_contact_calendar),
                          label: const Text("Open Phone Contact Picker"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(250, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}