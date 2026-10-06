import 'package:flutter/material.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../../core/api/ubn/face_to_face_api.dart';
import '../../../../core/models/face_to_face_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class ContactFormModel {
  String? sector;
  String name = '';
  String phone = '';
  String email = '';
  String profession = '';
  String remarks = '';
  bool useSameSectorAsAbove = false;
}

class FaceToFaceStartScreen extends StatefulWidget {
  final FaceToFaceModel meeting;

  const FaceToFaceStartScreen({super.key, required this.meeting});

  @override
  State<FaceToFaceStartScreen> createState() => _FaceToFaceStartScreenState();
}

class _FaceToFaceStartScreenState extends State<FaceToFaceStartScreen> {
  final List<ContactFormModel> _forms = [ContactFormModel()];
  final TextEditingController _contactSphereNameController = TextEditingController();
  final TextEditingController _commitmentController = TextEditingController();
  List<dynamic> _sectors = [];
  bool _isLoadingSectors = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contactSphereNameController.dispose();
    _commitmentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchSectors();
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
    setState(() {
      _isSubmitting = true;
    });

    final userData = SessionManager.user;
    final currentUserId = userData != null ? UserModel.fromJson(userData).userId : "";

    final members = _forms.map((f) => {
      "name": f.name,
      "profession": f.profession,
    }).toList();

    final payload = {
      "meetingId": widget.meeting.id,
      "createdUserId": currentUserId,
      "invitedMemberUserId": widget.meeting.invitedMember?['userId'] ?? currentUserId,
      "contactSphereName": _contactSphereNameController.text.trim(),
      "contactSphereMembers": members,
      "profession1": _forms.isNotEmpty ? _forms[0].profession : "",
      "profession2": _forms.length > 1 ? _forms[1].profession : "",
      "profession3": _forms.length > 2 ? _forms[2].profession : "",
      "commitment": _commitmentController.text.trim(),
    };
    
    final success = await FaceToFaceAPI.createContactSphere(payload);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact Sphere created successfully!")),
        );
        Navigator.pop(context);
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
                if (index > 0)
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
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) {
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
                onChanged: form.useSameSectorAsAbove
                    ? null // Disabled if using same as above
                    : (val) {
                        setState(() {
                          form.sector = val;
                        });
                      },
              ),
            const SizedBox(height: 12),
            
            TextField(
              decoration: InputDecoration(
                labelText: "Name",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onChanged: (val) => form.name = val,
            ),
            const SizedBox(height: 12),
            
            TextField(
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
        title: Text(
          "Start Meeting",
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
            Text(
              "My Contact Sphere Members to Invite",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              "You can add up to 5 contact sphere members.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactSphereNameController,
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
            
            if (_forms.length < 5)
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
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmitting ? null : _submitForms,
              child: _isSubmitting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("Submit & Start Meeting", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
