import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/api/ubn/gratitude_api.dart';
import '../../../core/api/directory/directory_api.dart';
import '../../../core/api/ubn/lead_api.dart';
import '../../../core/models/gratitude_model.dart';
import '../../../core/models/lead_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/session_manager.dart';
import 'gratitude_details_screen.dart';
import 'gratitude_history_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _leadController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _utrController = TextEditingController();

  List<String> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedType = "Inside";
  String? _selectedMemberId;
  String? _selectedLeadId;
  
  List<GratitudeModel> _givenSlips = [];
  List<GratitudeModel> _receivedSlips = [];
  int _selectedTab = 0; // 0 for Given, 1 for Received
  bool _isLoadingSlips = true;
  bool _isSubmitting = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initUserAndFetch();
  }

  Future<void> _initUserAndFetch() async {
    final userData = SessionManager.user;
    if (userData != null) {
      _currentUserId = UserModel.fromJson(userData).userId;
    }
    await _fetchSlips();
  }

  Future<void> _fetchSlips() async {
    setState(() => _isLoadingSlips = true);
    print("DEV DEBUG - method - gratitude_screen.dart - _fetchSlips called");
    final allSlips = await GratitudeAPI.getAllGratitudeSlips();
    
    if (mounted) {
      setState(() {
        if (_currentUserId != null) {
          _givenSlips = allSlips.where((s) => s.createdUser?.userId == _currentUserId).toList();
          _receivedSlips = allSlips.where((s) => s.thankYouMember?.userId == _currentUserId).toList();
        } else {
          _givenSlips = allSlips;
          _receivedSlips = [];
        }
        // Sort descending by date
        _givenSlips.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _receivedSlips.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _isLoadingSlips = false;
      });
      double totalGivenVal = _givenSlips.fold(0, (sum, s) => sum + (s.businessValue ?? 0));
      double totalReceivedVal = _receivedSlips.fold(0, (sum, s) => sum + (s.businessValue ?? 0));
      print('DEV DEBUG - UCN Action Screen (GRATITUDE_SLIP) - Data fetched successfully.');
      print('DEV DEBUG - UCN Action Screen (GRATITUDE_SLIP) - Given: ${_givenSlips.length} slips, Total Value: ₹$totalGivenVal');
      print('DEV DEBUG - UCN Action Screen (GRATITUDE_SLIP) - Received: ${_receivedSlips.length} slips, Total Value: ₹$totalReceivedVal');
    }
  }

  @override
  void dispose() {
    _memberController.dispose();
    _leadController.dispose();
    _valueController.dispose();
    _feedbackController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((e) => e.path));
      });
    }
  }

  void _openMemberSelectionDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final theme = Theme.of(ctx);
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
                        "Thank You To",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
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
                          onChanged: (val) {
                            setModalState(() {
                              searchQuery = val.toLowerCase();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<dynamic>>(
                          future: DirectoryAPI().searchMembers('', ''),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text("No members found"));
                            }
                            
                            final members = snapshot.data!.where((m) {
                              final name = (m['name'] ?? '').toString().toLowerCase();
                              final email = (m['email'] ?? '').toString().toLowerCase();
                              
                              if (searchQuery.isNotEmpty && !name.contains(searchQuery) && !email.contains(searchQuery)) {
                                return false;
                              }

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
                            
                            if (members.isEmpty) {
                              return const Center(child: Text("No normal members found matching your search"));
                            }

                            return ListView.separated(
                              controller: controller,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: members.length,
                              separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              itemBuilder: (ctx, idx) {
                                final m = members[idx];
                                return ListTile(
                                  title: Text(m['name'] ?? 'Unknown'),
                                  subtitle: Text(m['email'] ?? ''),
                                  onTap: () {
                                    setState(() {
                                      _selectedMemberId = m['userId'];
                                      _memberController.text = m['name'] ?? '';
                                    });
                                    if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _openLeadSelectionDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final theme = Theme.of(ctx);
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
                        "Select Linked Lead",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: "Search lead...",
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
                          onChanged: (val) {
                            setModalState(() {
                              searchQuery = val.toLowerCase();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<LeadModel>>(
                          future: LeadAPI.getAllLeads(),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text("No leads found"));
                            }
                            
                            final leads = snapshot.data!.where((l) {
                              // Filter by search query
                              if (searchQuery.isNotEmpty) {
                                final name = l.memberName.toLowerCase();
                                final business = l.business.toLowerCase();
                                if (!name.contains(searchQuery) && !business.contains(searchQuery)) {
                                  return false;
                                }
                              }

                              // Filter by status (only Accepted or Completed)
                              final status = l.status.toLowerCase();
                              if (status != 'accepted' && status != 'completed') {
                                return false;
                              }

                              // Filter to ensure it's between the two users
                              if (_selectedMemberId != null && _currentUserId != null) {
                                final creatorId = l.createdUser?['userId'];
                                if (creatorId != _selectedMemberId && creatorId != _currentUserId) {
                                  return false;
                                }
                              }

                              return true;
                            }).toList();
                            
                            if (leads.isEmpty) {
                              return const Center(child: Text("No leads match your search"));
                            }

                            return ListView.separated(
                              controller: controller,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: leads.length,
                              separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              itemBuilder: (ctx, idx) {
                                final l = leads[idx];
                                return ListTile(
                                  title: Text(l.business),
                                  subtitle: Text("${l.memberName} • ${l.status}"),
                                  onTap: () {
                                    setState(() {
                                      _selectedLeadId = l.leadId;
                                      _leadController.text = l.business;
                                      
                                      // Auto-fill the Thank You To member
                                      if (l.createdUser != null) {
                                        final creatorId = l.createdUser!['userId'];
                                        final creatorName = l.createdUser!['name'] ?? l.createdUser!['memberName'] ?? l.memberName;
                                        if (creatorId != null && creatorId != _currentUserId) {
                                          _selectedMemberId = creatorId.toString();
                                          _memberController.text = creatorName.toString();
                                        } else {
                                          // If the current user created the lead, we might be thanking the recipient?
                                          // Usually you thank the person who GAVE you the lead.
                                          // If current user is the creator, then the other party is the receiver (toMemberId maybe?)
                                          // But if it's not clear, we just fill `memberName` if it's the other person.
                                          _memberController.text = l.memberName;
                                          // We don't have toMemberId directly in LeadModel here, but memberName is usually the other person.
                                        }
                                      }
                                    });
                                    if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _submitGratitude() async {
    if (_selectedMemberId == null || _selectedLeadId == null || _valueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a member, lead, and enter a value.")),
      );
      return;
    }

    final val = double.tryParse(_valueController.text.trim());
    if (val == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number for business value.")),
      );
      return;
    }

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User session not found.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    print("DEV DEBUG - method - gratitude_screen.dart - _submitGratitude called");

    final payload = {
      "thankYouMemberUserId": _selectedMemberId!,
      "leadId": _selectedLeadId!,
      "businessValue": val,
      "type": _selectedType,
      "createdUserId": _currentUserId!,
      "feedback": _feedbackController.text.trim(),
      if (SessionManager.activeMeetingId != null) "meetingId": SessionManager.activeMeetingId,
    };

    final success = await GratitudeAPI.createGratitudeSlip(
      payload: payload,
      utrNo: _utrController.text.trim(),
      imagePaths: _selectedImages,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        print("DEV DEBUG - success - gratitude_screen.dart - Gratitude created successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gratitude slip recorded successfully!")),
        );
        _memberController.clear();
        _leadController.clear();
        _valueController.clear();
        _feedbackController.clear();
        _utrController.clear();
        _selectedImages.clear();
        _selectedMemberId = null;
        _selectedLeadId = null;
        _fetchSlips();
      } else {
        print("DEV DEBUG - error - gratitude_screen.dart - Failed to create gratitude");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to record gratitude.")),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Gratitude Slip",
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
                MaterialPageRoute(builder: (_) => const GratitudeHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thank the member whose lead turned into business. Amount stays private.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Linked Lead
            Text(
              "Linked lead",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(controller: _leadController, readOnly: true, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              onTap: _openLeadSelectionDialog,
              decoration: InputDecoration(
                hintText: "Select Linked Lead",
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                suffixIcon: Icon(Icons.arrow_drop_down),
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

            const SizedBox(height: 16),
            
            // Thank you to
            Text(
              "Thank you to",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(controller: _memberController, readOnly: true, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              onTap: _openMemberSelectionDialog,
              decoration: InputDecoration(
                hintText: "Select Member",
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                suffixIcon: Icon(Icons.arrow_drop_down),
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

            const SizedBox(height: 16),

            // Business Value
            Text(
              "Business value (₹)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter value e.g. 85000",
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
            ),

            const SizedBox(height: 16),

            // UTR Number
            Text(
              "FC Bank's UTR number",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _utrController,
              decoration: InputDecoration(
                hintText: "Enter transaction UTR number",
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
            ),

            const SizedBox(height: 16),

            // Proof Images
            Text(
              "Proof Images",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.teal),
                    const SizedBox(height: 8),
                    Text(
                      "Tap to select images",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(_selectedImages[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 2,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Feedback/Notes
            Text(
              "Notes / Feedback",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "e.g. Great referral, closed within a week.",
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
            ),

            const SizedBox(height: 20),

            // Type
            Text(
              "Type",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                ChoiceChip(
                  label: Text("Inside"),
                  selected: _selectedType == "Inside",
                  onSelected: (value) {
                    setState(() => _selectedType = "Inside");
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Text("Outside"),
                  selected: _selectedType == "Outside",
                  onSelected: (value) {
                    setState(() => _selectedType = "Outside");
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Only the circle total is public — currently ₹85,000",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitGratitude,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface, strokeWidth: 2),
                      )
                    : Text(
                        "Record Gratitude Slip",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // Tabs for Given and Received
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
                        color: _selectedTab == 0 ? Colors.teal : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "Given ${_givenSlips.length}",
                          style: TextStyle(
                            color: _selectedTab == 0 ? Theme.of(context).colorScheme.surface : Colors.teal,
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
                        color: _selectedTab == 1 ? Colors.teal : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "Received ${_receivedSlips.length}",
                          style: TextStyle(
                            color: _selectedTab == 1 ? Theme.of(context).colorScheme.surface : Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _isLoadingSlips
                ? const Center(child: CircularProgressIndicator())
                : (_selectedTab == 0 ? _givenSlips : _receivedSlips).isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _selectedTab == 0 ? "No gratitude slips given yet." : "No gratitude slips received yet.", 
                            style: TextStyle(color: Colors.grey)
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedTab == 0 
                            ? (_givenSlips.length > 5 ? 5 : _givenSlips.length) 
                            : (_receivedSlips.length > 5 ? 5 : _receivedSlips.length),
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final slip = _selectedTab == 0 ? _givenSlips[index] : _receivedSlips[index];
                          final formattedDate = slip.createdAt != null
                              ? DateFormat('MMM dd, yyyy').format(slip.createdAt!)
                              : '';
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GratitudeDetailsScreen(
                                    slip: slip,
                                    isGiven: _selectedTab == 0,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                        _selectedTab == 0 
                                            ? (slip.thankYouMember?.name ?? "Unknown Member")
                                            : (slip.createdUser?.name ?? "Unknown Member"),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${slip.linkedLead?.business ?? 'Unknown Lead'} • ${slip.type}",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (formattedDate.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            formattedDate,
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "₹${slip.businessValue.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
