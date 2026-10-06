import 'package:flutter/material.dart';
import '../../../core/api/ubn/guest_api.dart';
import '../../../core/api/directory/directory_api.dart';
import '../../../core/api/ubn/meeting_api.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../../core/models/guest_model.dart';
import '../../../core/models/meeting_model.dart';
import '../../../core/utils/session_manager.dart';
import 'package:intl/intl.dart';
import 'guests_history_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;
  List<GuestModel> _guests = [];
  String? _currentUserId;

  List<MeetingModel> _meetings = [];
  String? _selectedMeetingId;
  bool _isLoadingMeetings = true;

  List<dynamic> _sectors = [];
  Map<String, dynamic>? _selectedSector;
  List<dynamic> _subSectors = [];
  Map<String, dynamic>? _selectedSubSector;
  List<dynamic> _tags = [];
  Map<String, dynamic>? _selectedTag;
  bool _isLoadingSectors = true;

  @override
  void initState() {
    super.initState();
    _currentUserId = SessionManager.user?['userId']?.toString();
    _fetchGuests();
    _fetchMeetings();
    _fetchSectors();
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

  void _onSectorChanged(Map<String, dynamic>? newSector) {
    setState(() {
      _selectedSector = newSector;
      _subSectors = newSector?['subSectors'] ?? [];
      _selectedSubSector = null;
      _tags = [];
      _selectedTag = null;
    });
  }

  void _onSubSectorChanged(Map<String, dynamic>? newSubSector) {
    setState(() {
      _selectedSubSector = newSubSector;
      _tags = newSubSector?['tags'] ?? [];
      _selectedTag = null;
    });
  }

  void _onTagChanged(Map<String, dynamic>? newTag) {
    setState(() {
      _selectedTag = newTag;
    });
  }

  Future<void> _fetchMeetings() async {
    try {
      final meetingAPI = MeetingAPI();
      final res = await meetingAPI.getAllMeetings();
      if (res is List) {
        final parsed = res.map((m) => MeetingModel.fromJson(m)).toList();
        if (mounted) {
          setState(() {
            _meetings = parsed;
            _isLoadingMeetings = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingMeetings = false);
        }
      }
    } catch (e) {
      print("DEV DEBUG - _fetchMeetings exception: $e");
      if (mounted) {
        setState(() => _isLoadingMeetings = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickContactForGuest() async {
    final picker = FlutterNativeContactPicker();
    final contact = await picker.selectContact();
    if (contact != null && mounted) {
      setState(() {
        _nameController.text = contact.fullName ?? '';
        if (contact.phoneNumbers?.isNotEmpty == true) {
          _phoneController.text = contact.phoneNumbers!.first;
        }
      });
    }
  }

  void _openMemberSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _GuestMemberSelectionSheet(
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

  Future<void> _fetchGuests() async {
    print("DEV DEBUG - method - guests_screen.dart - _fetchGuests called");
    setState(() {
      _isLoading = true;
    });

    final res = await GuestAPI.getAllGuests();
    if (res != null && res['success'] == true) {
      final data = res['data'] as List? ?? [];
      final allGuests = data.map((g) => GuestModel.fromJson(g)).toList();

      // Filter guests to only show those created by current user
      if (_currentUserId != null) {
        _guests = allGuests.where((g) => g.createdUser?.userId == _currentUserId).toList();
      } else {
        _guests = allGuests;
      }

      // Sort by newest first
      _guests.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

      print("DEV DEBUG - get - guests_screen.dart - Fetched ${_guests.length} guests for current user");
    } else {
      print("DEV DEBUG - error - guests_screen.dart - Failed to fetch guests");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerGuest() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a guest name')),
      );
      return;
    }

    if (_selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a business tag')),
      );
      return;
    }

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User session expired. Please log in again.')),
      );
      return;
    }

    print("DEV DEBUG - method - guests_screen.dart - _registerGuest called with name: ${_nameController.text.trim()}");

    // Show loading indicator in a dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final res = await GuestAPI.createGuest(
      guestName: _nameController.text.trim(),
      createdUserId: _currentUserId!,
      meetingId: _selectedMeetingId,
      businessCategory: _selectedSector?['sectorName'],
      businessSubCategory: _selectedSubSector?['subSectorName'],
      businessTag: _selectedTag?['tagName'],
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (res != null && (res['success'] == true || res['statusCode'] == 201)) {
      print("DEV DEBUG - success - guests_screen.dart - Guest registered successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest registered successfully!')),
      );
      _nameController.clear();
      setState(() {
        _selectedMeetingId = null;
      });
      _fetchGuests();
    } else {
      print("DEV DEBUG - error - guests_screen.dart - Failed to register guest");
      final errorMsg = res?['message'] ?? res?['error'] ?? 'Failed to register guest';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  void _showUpdateStatusDialog(GuestModel guest) {
    print("DEV DEBUG - method - guests_screen.dart - _showUpdateStatusDialog called for guest: ${guest.id}");
    String selectedStatus = guest.status;
    final List<String> statuses = ["Pending", "Invited", "Visited", "Applied", "Joined", "Cancelled"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Update Guest Status'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: statuses.map((status) {
                    return RadioListTile<String>(
                      title: Text(status),
                      value: status,
                      groupValue: selectedStatus,
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedStatus = val;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _updateGuest(guest, selectedStatus);
                    },
                    child: Text('Update'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Future<void> _updateGuest(GuestModel guest, String newStatus) async {
    print("DEV DEBUG - method - guests_screen.dart - _updateGuest called for guest: ${guest.id} to status: $newStatus");
    if (_currentUserId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final res = await GuestAPI.updateGuestData(
      guestId: guest.id,
      userId: _currentUserId!,
      guestName: guest.guestName,
      status: newStatus,
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (res != null) {
      if (res['success'] == true || res['statusCode'] == 200) {
        print("DEV DEBUG - success - guests_screen.dart - Guest status updated");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully!')),
        );
        _fetchGuests();
      } else {
        print("DEV DEBUG - error - guests_screen.dart - Failed to update guest status: ${res['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to update status. Only Prime/Basic users may update.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status. Please try again.')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'joined':
        return Colors.green;
      case 'visited':
        return Colors.blue;
      case 'applied':
        return Colors.orange;
      case 'invited':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCategoryDropdowns(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoadingSectors)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedSector,
            isExpanded: true,
            dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Select Sector",
              hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: _sectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(
              value: s,
              child: Text(s['sectorName'], overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: _onSectorChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedSubSector,
            isExpanded: true,
            dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Select Sub-Category",
              hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: _subSectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(
              value: s,
              child: Text(s['subSectorName'], overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: _onSubSectorChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedTag,
            isExpanded: true,
            dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Select Tag",
              hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: _tags.map((s) => DropdownMenuItem<Map<String, dynamic>>(
              value: s,
              child: Text(s['tagName'] ?? '', overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: _onTagChanged,
          ),
          const SizedBox(height: 12),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Invite Guest",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: Icon(Icons.history, color: theme.colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuestsHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Invite Guest Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Invite a Guest",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _nameController,
                    readOnly: true,
                    onTap: _pickContactForGuest,
                    decoration: InputDecoration(
                      hintText: "Select Guest",
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                      suffixIcon: const Icon(Icons.contacts),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryDropdowns(theme.brightness == Brightness.dark),
                  if (_isLoadingMeetings)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedMeetingId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: "Select Meeting",
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _meetings.map((m) {
                        String formattedDate = m.date;
                        try {
                          final dt = DateTime.parse(m.date);
                          formattedDate = DateFormat('MMM dd, yyyy').format(dt);
                        } catch (_) {}

                        return DropdownMenuItem(
                          value: m.meetingId,
                          child: Text(
                            "${m.agenda} - $formattedDate",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMeetingId = val;
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.teal,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Category checked at invite — open seats only",
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share Pass coming soon...')),
                            );
                          },
                          icon: Icon(Icons.share),
                          label: Text("Share Pass"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          onPressed: _registerGuest,
                          child: Text(
                            "Register Guest",
                            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Guests (${_guests.length})",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_guests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No guests registered yet.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _guests.length > 6 ? 6 : _guests.length,
                itemBuilder: (context, index) {
                  final guest = _guests[index];
                  return _guestTile(
                    guest: guest,
                    color: _getStatusColor(guest.status),
                    onTap: () => _showUpdateStatusDialog(guest),
                  );
                },
              ),

            const SizedBox(height: 15),

            Text(
              "Pending → Invited → Visited → Applied → Joined",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _guestTile({
    required GuestModel guest,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formattedDate = guest.createdAt != null
        ? DateFormat('MMM dd, yyyy').format(guest.createdAt!)
        : 'Unknown Date';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(Icons.person, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.guestName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Registered: $formattedDate",
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    guest.status,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Bottom Sheets
// ==========================================

class _GuestMemberSelectionSheet extends StatefulWidget {
  final Function(String name, String? phone) onSelected;
  const _GuestMemberSelectionSheet({required this.onSelected});

  @override
  State<_GuestMemberSelectionSheet> createState() => _GuestMemberSelectionSheetState();
}

class _GuestMemberSelectionSheetState extends State<_GuestMemberSelectionSheet> with SingleTickerProviderStateMixin {
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
                "Select Member as Guest",
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
                    hintText: "Search member...",
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
                          onTap: () => widget.onSelected(name, null),
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
