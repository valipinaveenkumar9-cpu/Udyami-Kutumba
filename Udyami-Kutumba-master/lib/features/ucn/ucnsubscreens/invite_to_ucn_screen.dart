import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import '../../../core/api/ubn/application/application_api.dart';
import '../../../core/api/ubn/guest_api.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../../core/utils/session_manager.dart';
import 'application_detail_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class InviteToUcnScreen extends StatefulWidget {
  const InviteToUcnScreen({super.key});

  @override
  State<InviteToUcnScreen> createState() => _InviteToUcnScreenState();
}

class _InviteToUcnScreenState extends State<InviteToUcnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _tagController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isSubmitting = false;
  
  List<dynamic> _sectors = [];
  Map<String, dynamic>? _selectedSector;
  
  List<dynamic> _subSectors = [];
  Map<String, dynamic>? _selectedSubSector;
  
  List<dynamic> _tags = [];
  Map<String, dynamic>? _selectedTag;
  
  bool _isLoadingSectors = true;
  bool _isLoadingHistory = true;
  List<dynamic> _historyApps = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _fetchSectors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _categoryController.dispose();
    _subCategoryController.dispose();
    _tagController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _fetchSectors() async {
    final sectorApi = SectorAPI();
    final res = await sectorApi.getAllSectors();
    if (res != null && res['success'] == true && res['data'] != null) {
      if (mounted) {
        setState(() {
          _sectors = res['data'];
          _isLoadingSectors = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingSectors = false);
      }
    }
  }

  void _openContactsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _DeviceContactsSheet(
          onSelected: (name, phone) {
            setState(() {
              _nameController.text = name;
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

  void _onSectorChanged(Map<String, dynamic>? newSector) {
    setState(() {
      _selectedSector = newSector;
      _subSectors = newSector?['subSectors'] ?? [];
      _selectedSubSector = null;
      _tags = [];
      _selectedTag = null;
      _categoryController.text = newSector?['sectorName'] ?? '';
      _subCategoryController.clear();
      _tagController.clear();
    });
  }

  void _onSubSectorChanged(Map<String, dynamic>? newSubSector) {
    setState(() {
      _selectedSubSector = newSubSector;
      _tags = newSubSector?['tags'] ?? [];
      _selectedTag = null;
      _subCategoryController.text = newSubSector?['subSectorName'] ?? '';
      _tagController.clear();
    });
  }

  void _onTagChanged(Map<String, dynamic>? newTag) {
    setState(() {
      _selectedTag = newTag;
      _tagController.text = newTag?['tagName'] ?? '';
    });
  }

  Future<void> _showCreateTagDialog() async {
    if (_selectedSubSector == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Sub-Category first')));
       return;
    }
    final textController = TextEditingController();
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Create New Tag'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'e.g. Flutter'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              Navigator.pop(c);
              final sectorApi = SectorAPI();
              final res = await sectorApi.createBusinessTags({
                 'tagName': textController.text.trim(),
                 'description': '${textController.text.trim()} tag',
                 'subSectorId': _selectedSubSector!['subSectorId'],
              });
              if (res != null && res['success'] == true) {
                 final newTag = {
                    'tagName': textController.text.trim(),
                    'tagId': res['data']?['tagId'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
                 };
                 setState(() {
                    _tags = List.from(_tags)..add(newTag);
                    _selectedTag = newTag;
                    _tagController.text = newTag['tagName'];
                 });
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tag created!')));
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create tag.')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchHistory() async {
    final currentUserId = SessionManager.user?['userId']?.toString();
    if (currentUserId == null) {
      if (mounted) setState(() => _isLoadingHistory = false);
      return;
    }

    try {
      // 1. Get all guests and filter by current user
      final guestRes = await GuestAPI.getAllGuests();
      Set<String> userGuestIds = {};

      if (guestRes != null && guestRes['success'] == true && guestRes['data'] != null) {
        final allGuests = guestRes['data'] as List;
        for (var g in allGuests) {
          final createdUser = g['createdUser'];
          if ((createdUser is Map && createdUser['userId'] == currentUserId) ||
              g['createdUserId'] == currentUserId) {
            final gid = g['id'] ?? g['guestId'];
            if (gid != null) userGuestIds.add(gid.toString());
          }
        }
      }

      // 2. Get all applications and filter by userGuestIds
      if (userGuestIds.isNotEmpty) {
        final appRes = await ApplicationAPI.getAllApplications();
        if (appRes != null && appRes['success'] == true && appRes['data'] != null) {
          final allApps = appRes['data'] as List;
          _historyApps = allApps.where((app) {
            final gid = app['guestId'] ?? app['guest']?['guestId'];
            return gid != null && userGuestIds.contains(gid.toString());
          }).toList();
        }
      } else {
        _historyApps = [];
      }
    } catch (e) {
      print('DEV DEBUG - error - invite_to_ucn_screen.dart - fetchHistory: $e');
    }

    if (mounted) {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _submitInvite() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = SessionManager.user?['userId']?.toString();
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Step 1: Create guest record to get guestId
      final guestRes = await GuestAPI.createGuest(
        guestName: _nameController.text.trim(),
        createdUserId: currentUserId,
        status: 'Invited',
        meetingId: SessionManager.activeMeetingId,
      );

      String? guestId;
      if (guestRes != null) {
        if (guestRes['data'] != null && guestRes['data']['guestId'] != null) {
          guestId = guestRes['data']['guestId'];
        } else if (guestRes['guestId'] != null) {
          guestId = guestRes['guestId'];
        } else if (guestRes['data'] != null && guestRes['data']['id'] != null) {
          guestId = guestRes['data']['id'];
        } else if (guestRes['id'] != null) {
          guestId = guestRes['id'];
        }
      }

      if (guestId == null) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to register invite. Please try again.')),
          );
        }
        return;
      }

      // Step 2: Submit membership application with guestId
      final appRes = await ApplicationAPI.applyForMembership(
        guestId: guestId,
        businessCategory: _categoryController.text.trim(),
        businessSubCategory: _subCategoryController.text.trim(),
        businessTag: _tagController.text.trim(),
        remarks: _remarksController.text.trim().isNotEmpty
            ? _remarksController.text.trim()
            : 'Invited by ${SessionManager.user?['name'] ?? 'a UCN member'}',
      );

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (appRes != null) {
          _nameController.clear();
          _categoryController.clear();
          _subCategoryController.clear();
          _tagController.clear();
          _remarksController.clear();

          // Refresh history
          setState(() => _isLoadingHistory = true);
          _fetchHistory();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => AlertDialog(
              icon: const Icon(Icons.check_circle, color: Colors.teal, size: 48),
              title: const Text('Invite Sent!'),
              content: const Text(
                'Membership invite has been successfully sent.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit application. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Hold':
        return Colors.amber.shade700;
      default:
        return Colors.orange;
    }
  }

  void _shareApproveLink(String name) {
    final userName = SessionManager.user?['name'] ?? 'A UCN member';
    final shareText =
        "Hi $name! Your UCN membership application has been approved! $userName has invited you to join Udyami Circle Network â€” a powerful business networking community. Download the app and login: https://play.google.com/store/apps/details?id=com.ub.kutumba";

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied! Share it via WhatsApp or SMS to the approved guest.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
          titleSpacing: 0,
          title: Text(
            "Invite to UCN",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: "Send Invite"),
              Tab(text: "History"),
            ],
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        body: TabBarView(
          children: [
            _buildFormTab(isDark),
            _buildHistoryTab(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.teal.withValues(alpha: 0.15) : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_add_alt_1, color: isDark ? Colors.teal.shade300 : Colors.teal.shade700, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Invite someone to join UCN. Enter their details to automatically send them an invitation.",
                      style: TextStyle(color: isDark ? Colors.teal.shade100 : Colors.teal.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Person Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 5),

            TextFormField(
              controller: _nameController,
              readOnly: true,
              onTap: _openContactsBottomSheet,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                hintText: "Enter the person's full name",
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                prefixIcon: Icon(Icons.person_outline, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                hintText: "Enter phone number",
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                prefixIcon: Icon(Icons.phone, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Business Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 12),

            _isLoadingSectors 
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedSector,
                  isExpanded: true,
                  dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Business Category (Sector)",
                    labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                    ),
                  ),
                  items: _sectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(
                    value: s,
                    child: Text(
                      s['sectorName'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: _onSectorChanged,
                  validator: (v) => v == null ? 'Required' : null,
                ),
            const SizedBox(height: 14),

            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedSubSector,
              dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Business Sub-Category",
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
              ),
              items: _subSectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(
                value: s,
                child: Text(s['subSectorName']),
              )).toList(),
              onChanged: _onSubSectorChanged,
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedTag,
                    dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: "Business Tag",
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      ),
                    ),
                    items: _tags.map((s) => DropdownMenuItem<Map<String, dynamic>>(
                      value: s,
                      child: Text(s['tagName'] ?? ''),
                    )).toList(),
                    onChanged: _onTagChanged,
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.teal.withValues(alpha: 0.15) : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add, color: isDark ? Colors.teal.shade300 : Colors.teal, size: 28),
                    onPressed: _showCreateTagDialog,
                    tooltip: 'Add new tag',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _remarksController,
              maxLines: 3,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Remarks (optional)",
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                hintText: "Why should they join UCN?",
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Submit Invite",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark) {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No invites sent yet",
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyApps.length,
        itemBuilder: (ctx, idx) {
          final app = _historyApps[idx];
          final name = app['guestName'] ?? app['guest']?['fullName'] ?? 'Unknown';
          final status = app['status'] ?? 'Pending';
          final statusColor = _getStatusColor(status);
          final tag = app['businessTag'] ?? '';

          return Card(
            elevation: 0,
            color: isDark ? Colors.grey.shade900 : Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplicationDetailScreen(
                      application: app,
                      isReadOnly: true, // They can view it, but not approve/reject it themselves
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isDark ? Colors.teal.withValues(alpha: 0.15) : Colors.teal.shade50,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(color: isDark ? Colors.teal.shade300 : Colors.teal.shade700, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                              if (tag.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(tag, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13)),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    if (status == 'Approved') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () => _shareApproveLink(name),
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text("Share App Link to Member"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.teal.shade300 : Colors.teal,
                            side: BorderSide(color: isDark ? Colors.teal.shade300 : Colors.teal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// Bottom Sheet for Device Contacts
// ==========================================

class _DeviceContactsSheet extends StatefulWidget {
  final Function(String name, String? phone) onSelected;
  const _DeviceContactsSheet({required this.onSelected});

  @override
  State<_DeviceContactsSheet> createState() => _DeviceContactsSheetState();
}

class _DeviceContactsSheetState extends State<_DeviceContactsSheet> {
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
                "Phone Contacts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
                        final contact = await _contactPicker.selectContact();
                        if (contact != null) {
                          final name = contact.fullName ?? '';
                          final phone = contact.phoneNumbers?.isNotEmpty == true ? contact.phoneNumbers!.first : '';
                          widget.onSelected(name, phone);
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
              ),
            ],
          ),
        );
      },
    );
  }
}

