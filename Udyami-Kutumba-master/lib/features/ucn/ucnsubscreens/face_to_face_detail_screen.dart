import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../../core/api/ubn/face_to_face_api.dart';
import '../../../../core/models/face_to_face_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../core/api/directory/directory_api.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../../core/models/user_profile_model.dart';
import '../../profile/presentation/profile_screen.dart';

class ContactFormModel {
  String? sector;
  String name = '';
  String phone = '';
  String email = '';
  String profession = '';
  String remarks = '';
  bool useSameSectorAsAbove = false;
}

class FaceToFaceDetailScreen extends StatefulWidget {
  final FaceToFaceModel meeting;

  const FaceToFaceDetailScreen({super.key, required this.meeting});

  @override
  State<FaceToFaceDetailScreen> createState() => _FaceToFaceDetailScreenState();
}

class _FaceToFaceDetailScreenState extends State<FaceToFaceDetailScreen> {
  final List<ContactFormModel> _forms = [ContactFormModel()];
  final TextEditingController _contactSphereNameController = TextEditingController();
  final TextEditingController _commitmentController = TextEditingController();

  List<dynamic> _sectors = [];
  bool _isLoadingSectors = true;
  bool _isSubmitting = false;

  bool _isMyContactSphereSubmitted = false;
  String? _myContactSphereId;

  Map<String, dynamic>? _theirContactSphere;

  UserProfileModel? _creatorProfile;
  UserProfileModel? _invitedProfile;
  bool _isLoadingProfiles = true;

  String? currentUserId;
  String? currentUserName;
  late String _currentStatus;

  int _selectedTab = 0; // 0 = My Sphere, 1 = Their Sphere

  @override
  void dispose() {
    _contactSphereNameController.dispose();
    _commitmentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.meeting.status;
    final userData = SessionManager.user;
    if (userData != null) {
      final u = UserModel.fromJson(userData);
      currentUserId = u.userId;
      currentUserName = u.name.toLowerCase().trim();
    }
    _fetchSectors();
    _fetchProfiles();
    _fetchContactSphere();
  }

  Future<void> _refreshData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Refreshing..."), duration: Duration(seconds: 1)),
    );
    final meetings = await FaceToFaceAPI.getAllFaceToFaceMeetings();
    try {
      final updatedMeeting = meetings.firstWhere((m) => m.id == widget.meeting.id);
      if (mounted) {
        setState(() {
          _currentStatus = updatedMeeting.status;
        });
      }
    } catch (_) {}
    await _fetchProfiles();
    await _fetchContactSphere();
  }

  Future<void> _fetchContactSphere() async {
    final status = _currentStatus.toLowerCase();
    if (status != 'accepted' &&
        status != 'start' &&
        status != 'completed' &&
        status != 'close') {
      return;
    }

    try {
      if (currentUserId == null) return;

      final meetingCreatorId = widget.meeting.createdUserId ?? widget.meeting.createdUser?['userId'] ?? widget.meeting.createdUser?['id'];
      final meetingInvitedId = widget.meeting.invitedMemberUserId ?? widget.meeting.invitedMember?['userId'] ?? widget.meeting.invitedMember?['id'];

      final otherPersonId = currentUserId == meetingCreatorId ? meetingInvitedId : meetingCreatorId;

      if (otherPersonId == null) return;

      // Fetch My Sphere (Created by me, shared to them)
      final myRes = await FaceToFaceAPI.getContactSphere(createdUserId: currentUserId!, invitedMemberUserId: otherPersonId);
      if (myRes != null && myRes['success'] == true && myRes['data'] != null) {
        final List dataList = myRes['data'];
        final mySphere = dataList.firstWhere(
                (item) {
              final meetingMatch = item['meeting']?['id'] == widget.meeting.id;
              final creatorId = item['createdUser']?['userId'] ?? item['createdUser']?['id'];
              return meetingMatch && (creatorId == currentUserId);
            },
            orElse: () => null
        );

        if (mySphere != null) {
          setState(() {
            _myContactSphereId = mySphere['contactSphereId'];
            _isMyContactSphereSubmitted = true;
            _contactSphereNameController.text = mySphere['contactSphereName'] ?? '';
            _commitmentController.text = mySphere['commitment'] ?? '';

            final membersList = mySphere['contactSphereMembers'] as List?;
            if (membersList != null && membersList.isNotEmpty) {
              _forms.clear();
              for (var i = 0; i < membersList.length; i++) {
                final mem = membersList[i];
                final model = ContactFormModel();
                model.name = mem['name'] ?? '';
                model.phone = mem['phone'] ?? '';
                model.email = mem['email'] ?? '';
                model.profession = mem['profession'] ?? '';
                model.remarks = mem['remarks'] ?? '';
                model.sector = mem['sector'] == "" ? null : mem['sector'];
                model.useSameSectorAsAbove = mem['useSameSectorAsAbove'] ?? false;
                _forms.add(model);
              }
            }
          });
        }
      }

      // Fetch Their Sphere (Created by them, shared to me)
      final theirRes = await FaceToFaceAPI.getContactSphere(createdUserId: otherPersonId, invitedMemberUserId: currentUserId!);
      if (theirRes != null && theirRes['success'] == true && theirRes['data'] != null) {
        final List dataList = theirRes['data'];
        final theirSphere = dataList.firstWhere(
                (item) {
              final meetingMatch = item['meeting']?['id'] == widget.meeting.id;
              final creatorId = item['createdUser']?['userId'] ?? item['createdUser']?['id'];
              return meetingMatch && (creatorId == otherPersonId);
            },
            orElse: () => null
        );

        if (theirSphere != null) {
          setState(() {
            _theirContactSphere = theirSphere;
          });
        }
      }
    } catch (e) {
      print("Error fetching contact spheres: $e");
    }
  }

  Future<void> _fetchProfiles() async {
    setState(() {
      _isLoadingProfiles = true;
    });

    try {
      final creatorId = widget.meeting.createdUserId ?? widget.meeting.createdUser?['userId'] ?? widget.meeting.createdUser?['id'];
      final invitedId = widget.meeting.invitedMemberUserId ?? widget.meeting.invitedMember?['userId'] ?? widget.meeting.invitedMember?['id'];

      final futures = <Future>[];

      if (creatorId != null) {
        futures.add(ProfileAPI().getUserProfileById(creatorId).then((res) {
          if (res != null && res['success'] == true) {
            _creatorProfile = UserProfileModel.fromJson(res['data']);
          }
        }));
      }

      if (invitedId != null) {
        futures.add(ProfileAPI().getUserProfileById(invitedId).then((res) {
          if (res != null && res['success'] == true) {
            _invitedProfile = UserProfileModel.fromJson(res['data']);
          }
        }));
      }

      await Future.wait(futures);
    } catch (e) {
      print("Error fetching profiles in detail screen: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfiles = false;
        });
      }
    }
  }

  Future<void> _fetchSectors() async {
    try {
      final res = await SectorAPI().getAllSectors();
      if (res != null && res['success'] == true && res['data'] != null) {
        setState(() {
          _sectors = res['data'];
        });
      }
    } catch (e) {
      print("Error fetching sectors: $e");
    } finally {
      setState(() {
        _isLoadingSectors = false;
      });
    }
  }

  Future<void> _submitForms() async {
    if (currentUserId == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final members = _forms.map((f) => {
      "name": f.name,
      "phone": f.phone,
      "email": f.email,
      "profession": f.profession,
      "remarks": f.remarks,
      "sector": f.sector ?? "",
      "useSameSectorAsAbove": f.useSameSectorAsAbove,
    }).toList();

    final meetingCreatorId = widget.meeting.createdUserId ?? widget.meeting.createdUser?['userId'] ?? widget.meeting.createdUser?['id'];
    final meetingInvitedId = widget.meeting.invitedMemberUserId ?? widget.meeting.invitedMember?['userId'] ?? widget.meeting.invitedMember?['id'];

    final otherPersonId = currentUserId == meetingCreatorId ? meetingInvitedId : meetingCreatorId;

    final payload = {
      "meetingId": widget.meeting.id,
      "createdUserId": currentUserId!,
      "invitedMemberUserId": otherPersonId,
      "contactSphereName": _contactSphereNameController.text.trim(),
      "contactSphereMembers": members,
      "profession1": _forms.isNotEmpty ? _forms[0].profession : "",
      "profession2": _forms.length > 1 ? _forms[1].profession : "",
      "profession3": _forms.length > 2 ? _forms[2].profession : "",
      "commitment": _commitmentController.text.trim(),
    };

    bool success = false;
    if (_myContactSphereId != null && _myContactSphereId!.isNotEmpty) {
      success = await FaceToFaceAPI.updateContactSphere(_myContactSphereId!, payload);
    } else {
      success = await FaceToFaceAPI.createContactSphere(payload);
    }

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_myContactSphereId != null ? "Contact Sphere updated successfully!" : "Contact Sphere created successfully!")),
        );
        _fetchContactSphere(); // refresh local data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create Contact Sphere")),
        );
      }
    }
  }

  Widget _buildFormCard(int index) {
    final form = _forms[index];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey.shade900 : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Contact ${index + 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (index > 0 && !_isMyContactSphereSubmitted)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _forms.removeAt(index);
                      });
                    },
                  )
              ],
            ),
            const Divider(),

            if (index > 0)
              CheckboxListTile(
                title: const Text("Same as above sector selection", style: TextStyle(fontSize: 14)),
                value: form.useSameSectorAsAbove,
                dense: true,
                enabled: !_isMyContactSphereSubmitted,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: _isMyContactSphereSubmitted ? null : (val) {
                  setState(() {
                    form.useSameSectorAsAbove = val ?? false;
                    if (form.useSameSectorAsAbove) {
                      form.sector = _forms[index - 1].sector;
                    }
                  });
                },
              ),

            const SizedBox(height: 12),
            if (_isLoadingSectors)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                value: form.sector,
                hint: const Text("Select Sector"),
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                items: _sectors.map((s) {
                  final sectorName = s['sectorName']?.toString() ?? 'Unknown';
                  final sectorId = s['sectorId']?.toString() ?? sectorName;
                  return DropdownMenuItem(value: sectorId, child: Text(sectorName));
                }).toList(),
                onChanged: form.useSameSectorAsAbove || _isMyContactSphereSubmitted
                    ? null
                    : (val) {
                  setState(() {
                    form.sector = val;
                  });
                },
              ),
            const SizedBox(height: 12),

            TextField(
              readOnly: _isMyContactSphereSubmitted,
              controller: TextEditingController(text: form.name)..selection = TextSelection.fromPosition(TextPosition(offset: form.name.length)),
              decoration: InputDecoration(
                labelText: "Name",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onTap: _isMyContactSphereSubmitted
                  ? null
                  : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _F2FContactSelectionSheet(
                    onSelected: (name, phone, email, profession) {
                      setState(() {
                        _forms[index].name = name;
                        _forms[index].phone = phone;
                        if (email.isNotEmpty) _forms[index].email = email;
                        if (profession.isNotEmpty) _forms[index].profession = profession;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              onChanged: (val) => form.name = val,
            ),
            const SizedBox(height: 12),

            TextField(
              readOnly: _isMyContactSphereSubmitted,
              controller: TextEditingController(text: form.phone)..selection = TextSelection.fromPosition(TextPosition(offset: form.phone.length)),
              decoration: InputDecoration(
                labelText: "Phone",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (val) => form.phone = val,
            ),
            const SizedBox(height: 12),

            TextField(
              readOnly: _isMyContactSphereSubmitted,
              controller: TextEditingController(text: form.email)..selection = TextSelection.fromPosition(TextPosition(offset: form.email.length)),
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) => form.email = val,
            ),
            const SizedBox(height: 12),

            TextField(
              readOnly: _isMyContactSphereSubmitted,
              controller: TextEditingController(text: form.profession)..selection = TextSelection.fromPosition(TextPosition(offset: form.profession.length)),
              decoration: InputDecoration(
                labelText: "Profession",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onChanged: (val) => form.profession = val,
            ),
            const SizedBox(height: 12),

            TextField(
              readOnly: _isMyContactSphereSubmitted,
              controller: TextEditingController(text: form.remarks)..selection = TextSelection.fromPosition(TextPosition(offset: form.remarks.length)),
              decoration: InputDecoration(
                labelText: "Remarks (Optional)",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              maxLines: 2,
              onChanged: (val) => form.remarks = val,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    if (currentUserId == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Updating status...")),
    );

    final success = await FaceToFaceAPI.updateFaceToFaceStatus(widget.meeting.id, newStatus, currentUserId!);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        setState(() {
          _currentStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status updated!")),
        );
        // Only pop if completed to return to list, otherwise stay to fill form
        if (newStatus.toLowerCase() == 'completed' || newStatus.toLowerCase() == 'close') {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update status.")),
        );
      }
    }
  }

  Widget _buildProfileCard(String title, UserProfileModel? profile, bool isCreator) {
    if (_isLoadingProfiles) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (profile == null || !profile.profile.hasBusiness) {
      return Card(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade900.withOpacity(0.5) : Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Profile is incomplete. Please ask them to update their profile to view business and personal details.",
                style: const TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 8),
              if (currentUserId != null &&
                  currentUserId ==
                      (isCreator
                          ? (widget.meeting.createdUserId ?? (widget.meeting.createdUser != null ? widget.meeting.createdUser!['userId'] : null))
                          : (widget.meeting.invitedMemberUserId ?? (widget.meeting.invitedMember != null ? widget.meeting.invitedMember!['userId'] : null))))
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  },
                  child: const Text("Update My Profile"),
                ),
            ],
          ),
        ),
      );
    }

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
                Icon(isCreator ? Icons.account_circle : Icons.person_pin_circle, color: Theme.of(context).colorScheme.primary),
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
                Expanded(child: _buildInfoText("Date:", widget.meeting.date)),
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

  Widget _buildIconInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySphereTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "My Contact Sphere to Share",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
            ),
            if (_isMyContactSphereSubmitted)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  setState(() {
                    _isMyContactSphereSubmitted = false;
                  });
                },
                tooltip: "Edit Contact Sphere",
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "You can add up to 5 contact sphere members.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _contactSphereNameController,
          readOnly: _isMyContactSphereSubmitted,
          decoration: InputDecoration(
            labelText: "Contact Sphere Name",
            filled: true,
            fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commitmentController,
          readOnly: _isMyContactSphereSubmitted,
          decoration: InputDecoration(
            labelText: "Commitment",
            filled: true,
            fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 24),

        ...List.generate(_forms.length, (index) => _buildFormCard(index)),

        if (_forms.length < 5 && !_isMyContactSphereSubmitted)
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Another Contact"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.primary),
            ),
            onPressed: () {
              setState(() {
                _forms.add(ContactFormModel());
              });
            },
          ),

        const SizedBox(height: 32),

        if (_currentStatus.toLowerCase() == 'start')
          Row(
            children: [
              if (!_isMyContactSphereSubmitted)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : _submitForms,
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Save & Share Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (!_isMyContactSphereSubmitted)
                const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _updateStatus("Completed"),
                  child: const Text("Complete Meeting", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTheirSphereTab(ThemeData theme) {
    if (_theirContactSphere == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.hourglass_empty, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Waiting for them to share their contacts.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final sphereName = _theirContactSphere!['contactSphereName'] ?? '';
    final commitment = _theirContactSphere!['commitment'] ?? '';
    final membersList = _theirContactSphere!['contactSphereMembers'] as List?;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sphereName.isNotEmpty) ...[
          Text("Contact Sphere Name", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(sphereName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
        ],
        if (commitment.isNotEmpty) ...[
          Text("Commitment", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(commitment, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
        ],

        Text(
          "Shared Contacts",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),

        if (membersList == null || membersList.isEmpty)
          const Text("No contacts shared in this sphere.", style: TextStyle(color: Colors.grey))
        else
          ...membersList.map((mem) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: isDark ? Colors.grey.shade900 : theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.person, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mem['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (mem['profession'] != null && mem['profession'].toString().isNotEmpty)
                                Text(mem['profession'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    if (mem['phone'] != null && mem['phone'].toString().isNotEmpty)
                      _buildIconInfoRow(Icons.phone, "Phone", mem['phone']),
                    if (mem['email'] != null && mem['email'].toString().isNotEmpty)
                      _buildIconInfoRow(Icons.email, "Email", mem['email']),
                    if (mem['remarks'] != null && mem['remarks'].toString().isNotEmpty)
                      _buildIconInfoRow(Icons.note, "Remarks", mem['remarks']),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isInvitedMember = false;
    if (currentUserId != null) {
      isInvitedMember = (currentUserId == widget.meeting.invitedMemberUserId ||
          currentUserId == widget.meeting.invitedMember?['userId'] ||
          currentUserId == widget.meeting.invitedMember?['id']);
    }
    if (!isInvitedMember && currentUserName != null && widget.meeting.memberName.isNotEmpty) {
      isInvitedMember = (currentUserName == widget.meeting.memberName.toLowerCase().trim());
    }

    // Determine the name of the other person
    final meetingCreatorName = widget.meeting.createdUser?['name'] ?? 'Creator';
    final meetingInvitedName = widget.meeting.invitedMember?['name'] ?? widget.meeting.memberName;
    final otherPersonName = isInvitedMember ? meetingCreatorName : meetingInvitedName;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: "Refresh Data",
          ),
          const ThemeToggleButton(),
        ],
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Meeting Details",
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
            Card(
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Meeting Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(height: 8),
                    _buildIconInfoRow(Icons.calendar_today, "Date", widget.meeting.date),
                    _buildIconInfoRow(Icons.location_on, "Location", widget.meeting.location),
                    _buildIconInfoRow(Icons.info, "Purpose", widget.meeting.purpose),
                    _buildIconInfoRow(Icons.pending, "Status", _currentStatus),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildProfileCard("Creator Profile", _creatorProfile, true),
            const SizedBox(height: 16),
            _buildProfileCard("Invited Member Profile", _invitedProfile, false),
            const SizedBox(height: 24),

            if (isInvitedMember &&
                _currentStatus.toLowerCase() != 'accepted' &&
                _currentStatus.toLowerCase() != 'start' &&
                _currentStatus.toLowerCase() != 'completed' &&
                _currentStatus.toLowerCase() != 'cancelled' &&
                _currentStatus.toLowerCase() != 'rejected') ...[
              const Text("Update Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      onPressed: () => _updateStatus("Accepted"),
                      child: const Text("Accept"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () => _updateStatus("Rejected"),
                      child: const Text("Reject"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            if (_currentStatus.toLowerCase() == 'start' || _currentStatus.toLowerCase() == 'completed' || _currentStatus.toLowerCase() == 'close') ...[
              // The Tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? theme.colorScheme.primary : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            "My Sphere",
                            style: TextStyle(
                              color: _selectedTab == 0 ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
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
                          _selectedTab = 1;
                        });
                      },
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? theme.colorScheme.primary : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            "${otherPersonName.split(' ').first}'s Sphere",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedTab == 1 ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_selectedTab == 0)
                _buildMySphereTab(theme)
              else
                _buildTheirSphereTab(theme),

              const SizedBox(height: 32),
            ],

            if (_currentStatus.toLowerCase() == 'accepted')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _updateStatus("Start"),
                      child: const Text("Start Meeting", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            if (_currentStatus.toLowerCase() == 'accepted')
              const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Bottom Sheet for F2F Contact Sphere Selection
// ==========================================

class _F2FContactSelectionSheet extends StatefulWidget {
  final Function(String name, String phone, String email, String profession) onSelected;
  const _F2FContactSelectionSheet({required this.onSelected});

  @override
  State<_F2FContactSelectionSheet> createState() => _F2FContactSelectionSheetState();
}

class _F2FContactSelectionSheetState extends State<_F2FContactSelectionSheet> with SingleTickerProviderStateMixin {
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
                "Select Member / Contact",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.teal,
                tabs: const [
                  Tab(text: "UCN Members"),
                  Tab(text: "Phone Contacts"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search members...",
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
                        final email = m['email'] ?? '';
                        final phone = m['mobileNumber'] ?? m['phone'] ?? '';
                        final prof = m['profile']?['businessCategory'] ?? '';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.withValues(alpha: 0.15),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          subtitle: Text(email, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                          onTap: () => widget.onSelected(name, phone, email, prof),
                        );
                      },
                    ),
                    // Device Contacts Tab
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final picker = FlutterNativeContactPicker();
                            final contact = await picker.selectContact();
                            if (contact != null) {
                              final name = contact.fullName ?? '';
                              final phone = contact.phoneNumbers?.isNotEmpty == true ? contact.phoneNumbers!.first : '';
                              widget.onSelected(name, phone, '', '');
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