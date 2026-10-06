import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/api/ubn/lead_api.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../core/api/directory/directory_api.dart';
import '../../../core/api/ubn/sector_api.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:udyamikutumba/core/widgets/selection_search_screen.dart';
import 'my_leads_screen.dart';

class PassLeadScreen extends StatefulWidget {
  const PassLeadScreen({super.key});

  @override
  State<PassLeadScreen> createState() => _PassLeadScreenState();
}

class _PassLeadScreenState extends State<PassLeadScreen> {
  String leadType = "Inside circle";
  String heatLevel = "Given name";

  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _subSectorController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _subSubSectorController = TextEditingController();

  // Category State
  List<dynamic> _sectors = [];
  Map<String, dynamic>? _selectedSector;
  List<dynamic> _subSectors = [];
  Map<String, dynamic>? _selectedSubSector;
  List<dynamic> _tags = [];
  Map<String, dynamic>? _selectedTag;
  
  // Sub-Sub-Sector State
  List<dynamic> _subSubSectors = [];
  Map<String, dynamic>? _selectedSubSubSector;
  bool _isLoadingSubSubSectors = false;
  
  List<dynamic> _allSubSectors = [];
  List<dynamic> _allTags = [];
  List<dynamic> _allSubSubSectors = [];
  
  bool _isLoadingSectors = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSectors();
  }

  Future<void> _fetchSectors() async {
    final sectorApi = SectorAPI();
    final res = await sectorApi.getAllSectors();
    if (res != null && res['success'] == true && res['data'] != null) {
      final List<dynamic> allSectors = res['data'];
      final List<dynamic> allSub = [];
      final List<dynamic> allT = [];
      
      for (var sec in allSectors) {
        final List<dynamic> subs = sec['subSectors'] ?? [];
        for (var sub in subs) {
          sub['parentSector'] = sec;
          allSub.add(sub);
          final List<dynamic> tags = sub['tags'] ?? [];
          for (var tag in tags) {
            tag['parentSubSector'] = sub;
            allT.add(tag);
          }
        }
      }

      if (mounted) {
        setState(() {
          _sectors = allSectors;
          _allSubSectors = allSub;
          _allTags = allT;
          _isLoadingSectors = false;
        });
      }
      
      // Fetch all sub-sub-sectors in parallel for all sub-sectors
      _fetchAllSubSubSectors(allSub, sectorApi);
    } else {
      if (mounted) {
        setState(() => _isLoadingSectors = false);
      }
    }
  }

  Future<void> _fetchAllSubSubSectors(List<dynamic> allSub, SectorAPI sectorApi) async {
    final List<dynamic> allSSS = [];
    
    final futures = allSub.map((sub) async {
      final subSectorId = sub['subSectorId'];
      if (subSectorId == null) return;
      final res = await sectorApi.getAllSubSubSectors(subSectorId);
      if (res != null && res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final List<dynamic> items = data['subSubSectors'] ?? [];
        for (var sss in items) {
          sss['parentSubSector'] = sub;
          sss['parentSector'] = sub['parentSector'];
          allSSS.add(sss);
        }
      }
    });
    
    await Future.wait(futures);
    
    if (mounted) {
      setState(() {
        _allSubSubSectors = allSSS;
      });
    }
  }

  void _onSectorChanged(Map<String, dynamic>? newSector) {
    setState(() {
      _selectedSector = newSector;
      _sectorController.text = newSector?['sectorName'] ?? '';
      _subSectors = newSector?['subSectors'] ?? [];
      _selectedSubSector = null;
      _subSectorController.text = '';
      _tags = [];
      _selectedTag = null;
      _tagController.text = '';
      _subSubSectors = [];
      _selectedSubSubSector = null;
      _subSubSectorController.text = '';
    });
  }

  void _onSubSectorChanged(Map<String, dynamic>? newSubSector) {
    setState(() {
      _selectedSubSector = newSubSector;
      _subSectorController.text = newSubSector?['subSectorName'] ?? '';
      _tags = newSubSector?['tags'] ?? [];
      _selectedTag = null;
      _tagController.text = '';
      _subSubSectors = [];
      _selectedSubSubSector = null;
      _subSubSectorController.text = '';
      
      if (newSubSector != null && newSubSector.containsKey('parentSector')) {
        final parentSec = newSubSector['parentSector'];
        _selectedSector = parentSec;
        _sectorController.text = parentSec?['sectorName'] ?? '';
        _subSectors = parentSec?['subSectors'] ?? [];
      }
    });
    
    // Fetch sub-sub-sectors for this sub-sector
    if (newSubSector != null) {
      final subSectorId = newSubSector['subSectorId'];
      if (subSectorId != null) {
        _fetchSubSubSectors(subSectorId);
      }
    }
  }

  Future<void> _fetchSubSubSectors(String subSectorId) async {
    setState(() => _isLoadingSubSubSectors = true);
    final sectorApi = SectorAPI();
    final res = await sectorApi.getAllSubSubSectors(subSectorId);
    if (mounted) {
      if (res != null && res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final List<dynamic> subSubSectors = data['subSubSectors'] ?? [];
        setState(() {
          _subSubSectors = subSubSectors;
          _isLoadingSubSubSectors = false;
        });
      } else {
        setState(() {
          _subSubSectors = [];
          _isLoadingSubSubSectors = false;
        });
      }
    }
  }

  void _onSubSubSectorChanged(Map<String, dynamic>? newSubSubSector) {
    setState(() {
      _selectedSubSubSector = newSubSubSector;
      _subSubSectorController.text = newSubSubSector?['productDescription'] ?? '';
      
      // Auto-fill Sub-Sector and Sector from parent references
      if (newSubSubSector != null && newSubSubSector.containsKey('parentSubSector')) {
        final parentSub = newSubSubSector['parentSubSector'];
        _selectedSubSector = parentSub;
        _subSectorController.text = parentSub?['subSectorName'] ?? '';
        _tags = parentSub?['tags'] ?? [];
        
        if (parentSub != null && parentSub.containsKey('parentSector')) {
          final parentSec = parentSub['parentSector'];
          _selectedSector = parentSec;
          _sectorController.text = parentSec?['sectorName'] ?? '';
          _subSectors = parentSec?['subSectors'] ?? [];
        }
      }
    });
  }

  void _onTagChanged(Map<String, dynamic>? newTag) {
    setState(() {
      _selectedTag = newTag;
      _tagController.text = newTag?['tagName'] ?? '';
      
      if (newTag != null && newTag.containsKey('parentSubSector')) {
        final parentSub = newTag['parentSubSector'];
        _selectedSubSector = parentSub;
        _subSectorController.text = parentSub?['subSectorName'] ?? '';
        _tags = parentSub?['tags'] ?? [];
        
        if (parentSub != null && parentSub.containsKey('parentSector')) {
          final parentSec = parentSub['parentSector'];
          _selectedSector = parentSec;
          _sectorController.text = parentSec?['sectorName'] ?? '';
          _subSectors = parentSec?['subSectors'] ?? [];
        }
      }
    });
  }

  Future<void> _submitLead() async {
    if (_memberController.text.trim().isEmpty ||
        _businessController.text.trim().isEmpty ||
        _selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member, Business, and Category Tag fields are required")),
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
      "memberName": _memberController.text.trim(),
      "category": _selectedTag?['tagName'] ?? '',
      "leadType": leadType,
      "business": _businessController.text.trim(),
      "phone": _phoneController.text.trim(),
      "heatLevel": heatLevel,
      "createdUserId": currentUserId ?? "",
      "status": "Pending",
      "feedback": "",
      "message": "",
      if (SessionManager.activeMeetingId != null) "meetingId": SessionManager.activeMeetingId,
    };

    final success = await LeadAPI.createLead(payload);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lead created successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create lead.")),
        );
      }
    }
  }

  void _openMemberSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _MemberSelectionSheet(
          onSelected: (name, memberData) {
            print("DEV DEBUG - Member Selected: $name");
            print("DEV DEBUG - Member Data: $memberData");
            setState(() {
              _memberController.text = name;
              if (memberData['businessCategory'] != null) {
                final categoryName = memberData['businessCategory'];
                print("DEV DEBUG - Extracted Category: $categoryName");
                try {
                  final matchedSector = _sectors.firstWhere((s) => s['sectorName'] == categoryName);
                  _onSectorChanged(matchedSector);
                  print("DEV DEBUG - Successfully matched and auto-filled Sector: $categoryName");

                  if (memberData['businessSubCategory'] != null && _subSectors.isNotEmpty) {
                    final subCategoryName = memberData['businessSubCategory'];
                    print("DEV DEBUG - Extracted Sub-Category: $subCategoryName");
                    try {
                      final matchedSubSector = _subSectors.firstWhere((s) => s['subSectorName'] == subCategoryName);
                      _onSubSectorChanged(matchedSubSector);
                      print("DEV DEBUG - Successfully matched and auto-filled Sub-Category: $subCategoryName");

                      if (memberData['businessTag'] != null && _tags.isNotEmpty) {
                        final tagName = memberData['businessTag'];
                        print("DEV DEBUG - Extracted Tag: $tagName");
                        try {
                          final matchedTag = _tags.firstWhere((t) => t['tagName'] == tagName);
                          _onTagChanged(matchedTag);
                          print("DEV DEBUG - Successfully matched and auto-filled Tag: $tagName");
                        } catch (_) {
                          print("DEV DEBUG - Failed to match Tag: $tagName");
                        }
                      }
                    } catch (_) {
                      print("DEV DEBUG - Failed to match Sub-Category: $subCategoryName");
                    }
                  }
                } catch (_) {
                  print("DEV DEBUG - Failed to match Sector: $categoryName");
                }
              } else {
                print("DEV DEBUG - No businessCategory found for member $name");
              }
            });
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _openLeadBusinessSelectionDialog() async {
    if (leadType == "Self") {
      return; // Do nothing, already autofilled
    }

    if (leadType == "Outside") {
      final FlutterNativeContactPicker contactPicker = FlutterNativeContactPicker();
      final contact = await contactPicker.selectContact();
      if (contact != null) {
        setState(() {
          _businessController.text = contact.fullName ?? '';
          if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {
            _phoneController.text = contact.phoneNumbers!.first;
          }
        });
      }
      return;
    }

    // Inside circle
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _LeadBusinessSelectionSheet(
          onSelected: (name, phone) {
            setState(() {
              _businessController.text = name;
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

  @override
  void dispose() {
    _memberController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    _sectorController.dispose();
    _subSectorController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Widget buildSegment(
      String text, String group, bool selected, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (group == "lead") {
              if (leadType != text) {
                _businessController.clear();
                _phoneController.clear();
                if (text == "Self") {
                  final userData = SessionManager.user;
                  if (userData != null) {
                    final userModel = UserModel.fromJson(userData);
                    _businessController.text = (userModel.companyName != null && userModel.companyName!.isNotEmpty) 
                        ? userModel.companyName! 
                        : userModel.name;
                    _phoneController.text = userModel.mobileNumber;
                  }
                }
              }
              leadType = text;
            } else {
              heatLevel = text;
            }
          });
        },
        child: Container(
          height: 42,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? color : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : (isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget textField(String label, String hint, TextEditingController controller, {bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType, Widget? labelTrailing, bool showDropdownIcon = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (labelTrailing != null) labelTrailing,
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              filled: true,
              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.teal),
              ),
              suffixIcon: (readOnly && showDropdownIcon) ? const Icon(Icons.arrow_drop_down, color: Colors.grey) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdowns(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Their Category",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingSectors)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          textField(
            "Sector",
            "Select Sector",
            _sectorController,
            readOnly: true,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectionSearchScreen(
                    title: "Select Sector",
                    items: _sectors,
                    displayKey: 'sectorName',
                    searchHint: "Search Sector...",
                    onAddPressed: () {
                      Navigator.pop(context);
                      _showCreateAllSectorsDialog();
                    },
                  ),
                ),
              );
              if (result != null) {
                _onSectorChanged(result as Map<String, dynamic>);
              }
            },
          ),
          textField(
            "Sub-Sector",
            "Select Sub-Sector",
            _subSectorController,
            readOnly: true,
            onTap: () async {
              final itemsToDisplay = _selectedSector != null && _subSectors.isNotEmpty ? _subSectors : _allSubSectors;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectionSearchScreen(
                    title: "Select Sub-Sector",
                    items: itemsToDisplay,
                    displayKey: 'subSectorName',
                    searchHint: "Search Sub-Sector...",
                    onAddPressed: () {
                      Navigator.pop(context);
                      _showCreateAllSectorsDialog();
                    },
                  ),
                ),
              );
              if (result != null) {
                _onSubSectorChanged(result as Map<String, dynamic>);
              }
            },
          ),
          // Sub-Sub-Sector field
          if (_isLoadingSubSubSectors)
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            textField(
              "Sub-Sub-Sector",
              "Select Sub-Sub-Sector",
              _subSubSectorController,
              readOnly: true,
              onTap: () async {
                final itemsToDisplay = _selectedSubSector != null && _subSubSectors.isNotEmpty ? _subSubSectors : _allSubSubSectors;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectionSearchScreen(
                      title: "Select Sub-Sub-Sector",
                      items: itemsToDisplay,
                      displayKey: 'productDescription',
                      searchHint: "Search Sub-Sub-Sector...",
                      onAddPressed: () {
                        Navigator.pop(context);
                        _showCreateAllSectorsDialog();
                      },
                    ),
                  ),
                );
                if (result != null) {
                  _onSubSubSectorChanged(result as Map<String, dynamic>);
                }
              },
            ),
          // Tag field hidden for now — kept for future use
          // textField(
          //   "Tag",
          //   "Select Tag",
          //   _tagController,
          //   readOnly: true,
          //   onTap: () async {
          //     final itemsToDisplay = _selectedSubSector != null && _tags.isNotEmpty ? _tags : _allTags;
          //     if (itemsToDisplay.isEmpty) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(content: Text("No Tags available")),
          //       );
          //       return;
          //     }
          //     final result = await Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => SelectionSearchScreen(
          //           title: "Select Tag",
          //           items: itemsToDisplay,
          //           displayKey: 'tagName',
          //           searchHint: "Search Tag...",
          //         ),
          //       ),
          //     );
          //     if (result != null) {
          //       _onTagChanged(result as Map<String, dynamic>);
          //     }
          //   },
          // ),
          const SizedBox(height: 18),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: Icon(Icons.history, color: theme.colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyLeadsScreen()),
              );
            },
          ),
        ],
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Pass a Lead",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textField(
                "To Member",
                "Select a member...",
                _memberController,
                readOnly: true,
                onTap: _openMemberSelectionDialog,
              ),
              _buildCategoryDropdowns(isDark),
              const Text(
                "Lead Type",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  buildSegment("Inside circle", "lead", leadType == "Inside circle", Colors.teal),
                  buildSegment("Outside", "lead", leadType == "Outside", Colors.teal),
                  buildSegment("Self", "lead", leadType == "Self", Colors.teal),
                ],
              ),
              const SizedBox(height: 20),
              textField(
                "Lead / Business",
                leadType == "Outside" 
                    ? "Pick from contacts..." 
                    : (leadType == "Self" ? "Your details" : "Select Business or Person..."),
                _businessController,
                readOnly: true,
                showDropdownIcon: leadType == "Inside circle",
                onTap: _openLeadBusinessSelectionDialog,
              ),
              textField(
                "Phone",
                "+91 XXXXX XXXXX",
                _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const Text(
                "Heat Level",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  buildSegment("Given name", "heat", heatLevel == "Given name", Colors.orange),
                  buildSegment("Told them", "heat", heatLevel == "Told them", Colors.orange),
                  buildSegment("Hot lead", "heat", heatLevel == "Hot lead", Colors.red),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submitLead,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                    "Pass Lead",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  "Adds to My Leads (Given) and notifies the member.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateAllSectorsDialog() async {
    final sectorNameCtrl = TextEditingController();
    final sectorDescCtrl = TextEditingController();
    final subSectorNameCtrl = TextEditingController();
    final subSectorDescCtrl = TextEditingController();
    final subSubSectorNameCtrl = TextEditingController();
    final subSubSectorDescCtrl = TextEditingController();
    final prodDescCtrl = TextEditingController();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool isSaving = false;
    String? statusMessage;

    final parentContext = context;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Widget buildField(String label, TextEditingController ctrl, {bool required = true}) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: ctrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: required ? "$label *" : label,
                    labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
              );
            }

            Widget buildSectionHeader(String title, IconData icon) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 6),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.teal.shade700)),
                  ],
                ),
              );
            }

            return AlertDialog(
              backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.add_business, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(child: Text("Add New Business Category", style: TextStyle(fontSize: 16))),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fill in all 3 levels to create a new business category.",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      const SizedBox(height: 12),

                      // --- Sector ---
                      buildSectionHeader("1. Sector", Icons.category),
                      buildField("Sector Name", sectorNameCtrl),
                      buildField("Description (optional)", sectorDescCtrl, required: false),

                      const Divider(height: 16),

                      // --- Sub-Sector ---
                      buildSectionHeader("2. Sub-Sector", Icons.subdirectory_arrow_right),
                      buildField("Sub-Sector Name", subSectorNameCtrl),
                      buildField("Description (optional)", subSectorDescCtrl, required: false),

                      const Divider(height: 16),

                      // --- Sub-Sub-Sector ---
                      buildSectionHeader("3. Sub-Sub-Sector", Icons.arrow_forward),
                      buildField("Sub-Sub-Sector Name", subSubSectorNameCtrl),
                      buildField("Description (optional)", subSubSectorDescCtrl, required: false),
                      buildField("Product Description (optional)", prodDescCtrl, required: false),

                      if (statusMessage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              if (isSaving) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal)),
                              if (isSaving) const SizedBox(width: 8),
                              Expanded(child: Text(statusMessage!, style: const TextStyle(fontSize: 12, color: Colors.teal))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: isSaving ? null : () async {
                    // Validate required fields
                    if (sectorNameCtrl.text.trim().isEmpty) {
                      setState(() => statusMessage = "❌ Sector Name is required");
                      return;
                    }
                    if (subSectorNameCtrl.text.trim().isEmpty) {
                      setState(() => statusMessage = "❌ Sub-Sector Name is required");
                      return;
                    }
                    if (subSubSectorNameCtrl.text.trim().isEmpty) {
                      setState(() => statusMessage = "❌ Sub-Sub-Sector Name is required");
                      return;
                    }

                    setState(() { isSaving = true; statusMessage = "Creating Sector..."; });
                    final sectorApi = SectorAPI();

                    // Step 1: Create Sector
                    final sectorRes = await sectorApi.createOther({
                      "type": "sector",
                      "name": sectorNameCtrl.text.trim(),
                      "description": sectorDescCtrl.text.trim().isNotEmpty ? sectorDescCtrl.text.trim() : "User created sector",
                      "productDescription": "Products/Services for ${sectorNameCtrl.text.trim()}",
                    });
                    
                    if (sectorRes == null || sectorRes['success'] != true) {
                      setState(() { isSaving = false; statusMessage = "❌ Failed to create Sector: ${sectorRes?['message'] ?? 'Unknown error'}"; });
                      return;
                    }
                    final sectorId = sectorRes['data']?['sectorId'];
                    final sectorName = sectorRes['data']?['sectorName'] ?? sectorNameCtrl.text.trim();

                    // Step 2: Create Sub-Sector
                    setState(() => statusMessage = "✅ Sector created! Creating Sub-Sector...");
                    final subSectorRes = await sectorApi.createOther({
                      "type": "subSector",
                      "name": subSectorNameCtrl.text.trim(),
                      "description": subSectorDescCtrl.text.trim().isNotEmpty ? subSectorDescCtrl.text.trim() : "User created sub-sector",
                      "sectorId": sectorId,
                    });

                    if (subSectorRes == null || subSectorRes['success'] != true) {
                      setState(() { isSaving = false; statusMessage = "❌ Sector created, but Sub-Sector failed: ${subSectorRes?['message'] ?? 'Unknown error'}"; });
                      return;
                    }
                    final subSectorId = subSectorRes['data']?['subSectorId'];
                    final subSectorName = subSectorRes['data']?['subSectorName'] ?? subSectorNameCtrl.text.trim();

                    // Step 3: Create Sub-Sub-Sector
                    setState(() => statusMessage = "✅ Sub-Sector created! Creating Sub-Sub-Sector...");
                    final subSubSectorRes = await sectorApi.createOther({
                      "type": "subSubSector",
                      "name": subSubSectorNameCtrl.text.trim(),
                      "description": subSubSectorDescCtrl.text.trim().isNotEmpty ? subSubSectorDescCtrl.text.trim() : "User created sub-sub-sector",
                      "productDescription": prodDescCtrl.text.trim().isNotEmpty ? prodDescCtrl.text.trim() : "Products/Services for ${subSubSectorNameCtrl.text.trim()}",
                      "subSectorId": subSectorId,
                    });

                    if (subSubSectorRes == null || subSubSectorRes['success'] != true) {
                      setState(() { isSaving = false; statusMessage = "❌ Sector & Sub-Sector created, but Sub-Sub-Sector failed: ${subSubSectorRes?['message'] ?? 'Unknown error'}"; });
                      return;
                    }
                    final subSubSectorProdDesc = subSubSectorRes['data']?['productDescription'] ?? prodDescCtrl.text.trim();

                    setState(() => statusMessage = "✅ All created! Auto-filling...");

                    // Close dialog first
                    Navigator.pop(dialogContext);

                    // Refresh data & auto-fill all 3 fields
                    await _fetchSectors();

                    if (mounted) {
                      this.setState(() {
                        // Auto-fill Sector
                        _sectorController.text = sectorName;
                        _selectedSector = {'sectorId': sectorId, 'sectorName': sectorName};

                        // Auto-fill Sub-Sector
                        _subSectorController.text = subSectorName;
                        _selectedSubSector = {'subSectorId': subSectorId, 'subSectorName': subSectorName, 'parentSector': _selectedSector};

                        // Auto-fill Sub-Sub-Sector
                        _subSubSectorController.text = subSubSectorProdDesc;
                        _selectedSubSubSector = subSubSectorRes['data'];

                        // Update sub-lists for dropdown consistency
                        try {
                          final matchedSector = _sectors.firstWhere((s) => s['sectorId'] == sectorId);
                          _selectedSector = matchedSector;
                          _subSectors = matchedSector['subSectors'] ?? [];
                          
                          if (_subSectors.isNotEmpty) {
                            try {
                              final matchedSub = _subSectors.firstWhere((s) => s['subSectorId'] == subSectorId);
                              _selectedSubSector = matchedSub;
                            } catch (_) {}
                          }
                        } catch (_) {}
                      });

                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text("✅ All 3 categories created and filled!")),
                      );
                    }
                  },
                  child: isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Text("Create All"),
                ),
              ],
            );
          }
        );
      }
    );
  }
}

// ==========================================
// Bottom Sheets
// ==========================================

class _MemberSelectionSheet extends StatefulWidget {
  final Function(String, Map<String, dynamic>) onSelected;
  const _MemberSelectionSheet({required this.onSelected});

  @override
  State<_MemberSelectionSheet> createState() => _MemberSelectionSheetState();
}

class _MemberSelectionSheetState extends State<_MemberSelectionSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _members = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    final results = await DirectoryAPI().searchMembers(_searchQuery, '');
    if (mounted) {
      setState(() {
        _members = results;
        _isLoading = false;
      });
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _members.isEmpty
                    ? const Center(child: Text("No members found"))
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
                      onTap: () => widget.onSelected(name, m as Map<String, dynamic>),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeadBusinessSelectionSheet extends StatefulWidget {
  final Function(String name, String? phone) onSelected;
  const _LeadBusinessSelectionSheet({required this.onSelected});

  @override
  State<_LeadBusinessSelectionSheet> createState() => _LeadBusinessSelectionSheetState();
}

class _LeadBusinessSelectionSheetState extends State<_LeadBusinessSelectionSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<dynamic> _businesses = [];
  List<dynamic> _members = [];
  bool _isLoadingBusinesses = false;
  bool _isLoadingMembers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchData();
      }
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_tabController.index == 0) {
      // Businesses tab
      setState(() => _isLoadingBusinesses = true);
      final results = await DirectoryAPI().searchBusinessMembers(_searchQuery);
      if (mounted) {
        setState(() {
          _businesses = results;
          _isLoadingBusinesses = false;
        });
      }
    } else if (_tabController.index == 1) {
      // UCN Members tab
      setState(() => _isLoadingMembers = true);
      final results = await DirectoryAPI().searchMembers(_searchQuery, '');
      if (mounted) {
        setState(() {
          _members = results;
          _isLoadingMembers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, scrollController) {
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
              TabBar(
                controller: _tabController,
                labelColor: Colors.teal,
                unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                indicatorColor: Colors.teal,
                tabs: const [
                  Tab(text: "Businesses"),
                  Tab(text: "UCN Members"),
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
                    _fetchData();
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Businesses List
                    _isLoadingBusinesses
                        ? const Center(child: CircularProgressIndicator())
                        : _businesses.isEmpty
                        ? const Center(child: Text("No businesses found"))
                        : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _businesses.length,
                      separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      itemBuilder: (ctx, idx) {
                        final m = _businesses[idx];
                        final bizName = m['profile']?['businessDetails']?['businessName'] ?? m['name'] ?? 'Unknown Business';
                        final phone = m['mobileNumber']?.toString() ?? m['primaryMobile']?.toString() ?? '';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withValues(alpha: 0.15),
                            child: const Icon(Icons.store, color: Colors.orange),
                          ),
                          title: Text(bizName, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          subtitle: Text(m['name'] ?? '', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                          onTap: () => widget.onSelected(bizName, phone),
                        );
                      },
                    ),
                    // UCN Members List
                    _isLoadingMembers
                        ? const Center(child: CircularProgressIndicator())
                        : _members.isEmpty
                        ? const Center(child: Text("No members found"))
                        : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _members.length,
                      separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      itemBuilder: (ctx, idx) {
                        final m = _members[idx];
                        final name = m['name'] ?? 'Unknown';
                        final phone = m['mobileNumber']?.toString() ?? m['primaryMobile']?.toString() ?? '';
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
                          onTap: () => widget.onSelected(name, phone),
                        );
                      },
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
