import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../core/api/auth/auth_api.dart';
import '../../../core/api/area/ward_api.dart';
import '../../../core/models/ward_model.dart';
import 'widgets/design/top_left_blob.dart';
import 'widgets/design/water_flow.dart';
import 'widgets/design/india_skyline.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/api/profile/profile_api.dart';
import 'login_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'widgets/map_selection_modal.dart';
import '../../../core/api/ubn/sector_api.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert' as dart_convert;
import 'package:http/http.dart' as http;
import '../../../core/api/api.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessLocationController =
      TextEditingController();
  final TextEditingController _homeLocationController = TextEditingController();
  double _homeLat = 0.0;
  double _homeLng = 0.0;
  double _officeLat = 0.0;
  double _officeLng = 0.0;

  File? _selectedProfileImage;
  List<File> _selectedBusinessImageFiles = [];

  List<dynamic> _sectors = [];
  Map<String, dynamic>? _selectedSector;

  List<dynamic> _subSectors = [];
  Map<String, dynamic>? _selectedSubSector;

  List<dynamic> _subSubSectors = [];
  Map<String, dynamic>? _selectedSubSubSector;
  bool _isLoadingSubSubSectors = false;

  bool _isLoadingSectors = true;
  int _currentStep = 0;
  int _highestStep = 0;

  bool _hasBusiness = false;
  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _createdUserId;

  final WardAPI _wardAPI = WardAPI();
  List<WardModel> _allWards = [];
  List<String> _states = [];
  List<String> _districts = [];
  List<String> _talukas = [];
  List<WardModel> _wards = [];

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;
  String? _selectedWardId;

  bool _sameAsPersonalArea = false;
  String? _selectedBusinessState;
  String? _selectedBusinessDistrict;
  String? _selectedBusinessTaluka;
  String? _selectedBusinessWardId;
  
  List<String> _businessDistricts = [];
  List<String> _businessTalukas = [];
  List<WardModel> _businessWards = [];

  @override
  void initState() {
    super.initState();
    _fetchWards();
    _fetchSectors();
  }

  Future<void> _fetchWards() async {
    try {
      final response = await _wardAPI.getAllWards();
      if (response != null && response['success'] == true) {
        final List rawData = response['data'] ?? [];
        _allWards = rawData
            .map((w) => WardModel.fromJson(w as Map<String, dynamic>))
            .toList();

        _states = _allWards.map((w) => w.state).toSet().toList();
        _states.sort();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load wards. API may require login.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading wards: $e')));
      }
    } finally {
      if (mounted) setState(() {});
    }
  }

  void _onStateChanged(String? state) {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _selectedTaluka = null;
      _selectedWardId = null;

      _districts = _allWards
          .where((w) => w.state == state)
          .map((w) => w.district)
          .toSet()
          .toList();
      _districts.sort();

      _talukas = [];
      _wards = [];
    });
  }

  void _onDistrictChanged(String? district) {
    setState(() {
      _selectedDistrict = district;
      _selectedTaluka = null;
      _selectedWardId = null;

      _talukas = _allWards
          .where((w) => w.state == _selectedState && w.district == district)
          .map((w) => w.taluka)
          .toSet()
          .toList();
      _talukas.sort();

      _wards = [];
    });
  }

  void _onTalukaChanged(String? taluka) {
    setState(() {
      _selectedTaluka = taluka;
      _selectedWardId = null;

      _wards = _allWards
          .where(
            (w) =>
                w.state == _selectedState &&
                w.district == _selectedDistrict &&
                w.taluka == taluka,
          )
          .toList();
      _wards.sort((a, b) => a.wardName.compareTo(b.wardName));
    });
  }

  void _onBusinessStateChanged(String? state) {
    setState(() {
      _selectedBusinessState = state;
      _selectedBusinessDistrict = null;
      _selectedBusinessTaluka = null;
      _selectedBusinessWardId = null;

      _businessDistricts = _allWards
          .where((w) => w.state == state)
          .map((w) => w.district)
          .toSet()
          .toList();
      _businessDistricts.sort();

      _businessTalukas = [];
      _businessWards = [];
    });
  }

  void _onBusinessDistrictChanged(String? district) {
    setState(() {
      _selectedBusinessDistrict = district;
      _selectedBusinessTaluka = null;
      _selectedBusinessWardId = null;

      _businessTalukas = _allWards
          .where((w) => w.state == _selectedBusinessState && w.district == district)
          .map((w) => w.taluka)
          .toSet()
          .toList();
      _businessTalukas.sort();

      _businessWards = [];
    });
  }

  void _onBusinessTalukaChanged(String? taluka) {
    setState(() {
      _selectedBusinessTaluka = taluka;
      _selectedBusinessWardId = null;

      _businessWards = _allWards
          .where(
            (w) =>
                w.state == _selectedBusinessState &&
                w.district == _selectedBusinessDistrict &&
                w.taluka == taluka,
          )
          .toList();
      _businessWards.sort((a, b) => a.wardName.compareTo(b.wardName));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    _otpController.dispose();
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

  void _onSectorChanged(Map<String, dynamic>? newSector) {
    setState(() {
      _selectedSector = newSector;
      _subSectors = newSector?['subSectors'] ?? [];
      _selectedSubSector = null;
      _subSubSectors = [];
      _selectedSubSubSector = null;
    });
  }

  Future<void> _onSubSectorChanged(Map<String, dynamic>? newSubSector) async {
    setState(() {
      _selectedSubSector = newSubSector;
      _subSubSectors = [];
      _selectedSubSubSector = null;
    });

    if (newSubSector != null) {
      setState(() => _isLoadingSubSubSectors = true);
      try {
        final sectorApi = SectorAPI();
        final res = await sectorApi.getAllSubSubSectors(newSubSector['subSectorId']);
        if (res != null && res['success'] == true && res['data'] != null) {
          if (mounted) {
            setState(() {
              _subSubSectors = res['data'];
              _isLoadingSubSubSectors = false;
            });
          }
        } else {
          if (mounted) {
            setState(() => _isLoadingSubSubSectors = false);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingSubSubSectors = false);
        }
      }
    }
  }

  void _onSubSubSectorChanged(Map<String, dynamic>? newSubSubSector) {
    setState(() {
      _selectedSubSubSector = newSubSubSector;
    });
  }

  Future<void> _showCreateAllSectorsDialog() async {
    final sectorNameCtrl = TextEditingController();
    final sectorDescCtrl = TextEditingController();
    final subSectorNameCtrl = TextEditingController();
    final subSectorDescCtrl = TextEditingController();
    final subSubSectorNameCtrl = TextEditingController();
    final subSubSectorDescCtrl = TextEditingController();
    final prodDescCtrl = TextEditingController();
    final hasSector = _selectedSector != null;
    final hasSubSector = _selectedSubSector != null;

    if (hasSector) {
      sectorNameCtrl.text = _selectedSector!['sectorName'] ?? '';
    }
    if (hasSubSector) {
      subSectorNameCtrl.text = _selectedSubSector!['subSectorName'] ?? '';
    }

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
            Widget buildField(String label, TextEditingController ctrl, {bool required = true, bool readOnly = false}) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: ctrl,
                  readOnly: readOnly,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: required ? "$label *" : label,
                    labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
                    isDense: true,
                    filled: readOnly,
                    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: readOnly ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300) : Theme.of(context).colorScheme.primary),
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
                    Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              );
            }

            return AlertDialog(
              backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
              title: Row(
                children: [
                  Icon(Icons.add_business, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(child: Text("Add New Business Category", style: TextStyle(fontSize: 16))),
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
                      buildField("Sector Name", sectorNameCtrl, readOnly: hasSector),
                      if (!hasSector) buildField("Description (optional)", sectorDescCtrl, required: false),

                      const Divider(height: 16),

                      // --- Sub-Sector ---
                      buildSectionHeader("2. Sub-Sector", Icons.subdirectory_arrow_right),
                      buildField("Sub-Sector Name", subSectorNameCtrl, readOnly: hasSubSector),
                      if (!hasSubSector) buildField("Description (optional)", subSectorDescCtrl, required: false),

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
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              if (isSaving) SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                              if (isSaving) const SizedBox(width: 8),
                              Expanded(child: Text(statusMessage!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary))),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
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

                    String? finalSectorId;
                    String? finalSectorName;
                    
                    if (hasSector) {
                      finalSectorId = _selectedSector!['sectorId'];
                      finalSectorName = _selectedSector!['sectorName'];
                    } else {
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
                      finalSectorId = sectorRes['data']?['sectorId'];
                      finalSectorName = sectorRes['data']?['sectorName'] ?? sectorNameCtrl.text.trim();
                    }

                    String? finalSubSectorId;
                    String? finalSubSectorName;
                    
                    if (hasSubSector) {
                      finalSubSectorId = _selectedSubSector!['subSectorId'];
                      finalSubSectorName = _selectedSubSector!['subSectorName'];
                    } else {
                      // Step 2: Create Sub-Sector
                      setState(() => statusMessage = "✅ Sector ready! Creating Sub-Sector...");
                      final subSectorRes = await sectorApi.createOther({
                        "type": "subSector",
                        "name": subSectorNameCtrl.text.trim(),
                        "description": subSectorDescCtrl.text.trim().isNotEmpty ? subSectorDescCtrl.text.trim() : "User created sub-sector",
                        "sectorId": finalSectorId,
                      });

                      if (subSectorRes == null || subSectorRes['success'] != true) {
                        setState(() { isSaving = false; statusMessage = "❌ Failed to create Sub-Sector: ${subSectorRes?['message'] ?? 'Unknown error'}"; });
                        return;
                      }
                      finalSubSectorId = subSectorRes['data']?['subSectorId'];
                      finalSubSectorName = subSectorRes['data']?['subSectorName'] ?? subSectorNameCtrl.text.trim();
                    }

                    // Step 3: Create Sub-Sub-Sector
                    setState(() => statusMessage = "✅ Sub-Sector ready! Creating Sub-Sub-Sector...");
                    final subSubSectorRes = await sectorApi.createOther({
                      "type": "subSubSector",
                      "name": subSubSectorNameCtrl.text.trim(),
                      "description": subSubSectorDescCtrl.text.trim().isNotEmpty ? subSubSectorDescCtrl.text.trim() : "User created sub-sub-sector",
                      "productDescription": prodDescCtrl.text.trim().isNotEmpty ? prodDescCtrl.text.trim() : "Products/Services for ${subSubSectorNameCtrl.text.trim()}",
                      "subSectorId": finalSubSectorId,
                    });

                    if (subSubSectorRes == null || subSubSectorRes['success'] != true) {
                      setState(() { isSaving = false; statusMessage = "❌ Failed to create Sub-Sub-Sector: ${subSubSectorRes?['message'] ?? 'Unknown error'}"; });
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
                        // Update sub-lists for dropdown consistency
                        try {
                          final matchedSector = _sectors.firstWhere((s) => s['sectorId'] == finalSectorId);
                          _selectedSector = matchedSector;
                          _subSectors = matchedSector['subSectors'] ?? [];
                          
                          if (_subSectors.isNotEmpty) {
                            try {
                              final matchedSub = _subSectors.firstWhere((s) => s['subSectorId'] == finalSubSectorId);
                              _selectedSubSector = matchedSub;
                            } catch (_) {}
                          }
                        } catch (_) {}

                        _subSubSectors = [subSubSectorRes['data']];
                        _selectedSubSubSector = subSubSectorRes['data'];
                      });

                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text("✅ All 3 categories created and filled!")),
                      );
                    }
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _openMapToSelectLocation({required bool isHome}) async {
    LatLng? initial = isHome
        ? (_homeLat != 0.0 ? LatLng(_homeLat, _homeLng) : null)
        : (_officeLat != 0.0 ? LatLng(_officeLat, _officeLng) : null);

    WardModel? selectedWard;
    String? targetWardId = isHome ? _selectedWardId : _selectedBusinessWardId;
    
    if (targetWardId != null) {
      try {
        selectedWard = _allWards.firstWhere((w) => w.wardId == targetWardId);
        print(
          "DEV DEBUG - _openMapToSelectLocation: Found selected ward: ${selectedWard.wardName}, has GeoJson: ${selectedWard.geoJson != null}",
        );
      } catch (e) {
        print("DEV DEBUG - _openMapToSelectLocation: Error finding ward: $e");
      }
    } else {
      print("DEV DEBUG - _openMapToSelectLocation: No ward selected.");
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => MapSelectionModal(
        initialLocation: initial,
        selectedWard: selectedWard,
      ),
    );

    if (result != null && result['location'] != null) {
      final loc = result['location'] as LatLng;
      final address = result['address'] as String?;
      setState(() {
        if (isHome) {
          _homeLat = loc.latitude;
          _homeLng = loc.longitude;
          if (address != null && address.isNotEmpty) {
            _homeLocationController.text = address;
          } else {
            _homeLocationController.text =
                "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}";
          }
        } else {
          _officeLat = loc.latitude;
          _officeLng = loc.longitude;
          if (address != null && address.isNotEmpty) {
            _businessLocationController.text = address;
          } else {
            _businessLocationController.text =
                "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}";
          }
        }
      });
    }
  }

  void _openMapToSelectLocation_Old() {
    // TODO: Implement Google Map bottom sheet / modal for selection
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Map selection coming soon!')));
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedProfileImage = File(pickedFile.path);
      });
      print('DEV DEBUG - SignupScreen: Profile image selected');
    }
  }

  Future<void> _pickBusinessImages() async {
    if (_selectedBusinessImageFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only upload up to 3 business images'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var pickedFile in pickedFiles) {
          if (_selectedBusinessImageFiles.length < 3) {
            _selectedBusinessImageFiles.add(File(pickedFile.path));
          }
        }
      });
      print(
        'DEV DEBUG - SignupScreen: ${_selectedBusinessImageFiles.length} business images selected',
      );
    }
  }

  void _handleRegisterTap() async {
    if (_nameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedWardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and select a ward'),
        ),
      );
      return;
    }

    if (!_isOtpSent) {
      setState(() => _isLoading = true);
      try {
        final authApi = AuthAPI();
        final otpResponse = await authApi.sendOtp(
          _mobileController.text,
          'REGISTRATION',
        );

        if (otpResponse != null && otpResponse['success'] == true) {
          setState(() => _isOtpSent = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent to your mobile number')),
            );
          }
        } else {
          final errorMsg = otpResponse?['message'] ?? 'Failed to send OTP';
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMsg)));
          }
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (_otpController.text.length < 6) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter valid OTP')));
        return;
      }
      _verifyAndRegister();
    }
  }

  Future<void> _verifyAndRegister() async {
    setState(() => _isLoading = true);
    try {
      final authApi = AuthAPI();

      // Verify real-time OTP first
      final verifyResponse = await authApi.verifyOtp(
        _mobileController.text,
        _otpController.text,
        'REGISTRATION',
      );

      if (verifyResponse == null || verifyResponse['success'] != true) {
        final errorMsg = verifyResponse?['message'] ?? 'Invalid OTP';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
          setState(() => _isLoading = false);
        }
        return;
      }

      final verificationId = verifyResponse['verificationId']?.toString();

      // Step 1: Create the User
      final userResponse = await authApi.createUser({
        "name": _nameController.text,
        "email": _emailController.text,
        "password": "DefaultUser@123", // Dummy password required by backend
        "mobileNumber": _mobileController.text,
        "businessLocation": null,
        "officeLocation": _hasBusiness
            ? _businessLocationController.text
            : null,
        "latitude": _officeLat,
        "longitude": _officeLng,
        "hasBusiness": _hasBusiness,
        if (verificationId != null) "verificationId": verificationId,
      });

      if (userResponse == null || userResponse['success'] != true) {
        final errorMsg = userResponse?['message'] ?? 'Failed to create account';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
          setState(() => _isLoading = false);
        }
        return;
      }

      _createdUserId =
          userResponse['data']?['userId']?.toString() ?? 'dummy-uuid';

      // Step 2: Update User Profile (skipping login since Registration verificationId is single-use)
      final userId = _createdUserId ?? 'dummy-uuid';

      String selectedWardName = _selectedWardId ?? '';
      try {
        if (_selectedWardId != null) {
          selectedWardName = _wards
              .firstWhere((w) => w.wardId == _selectedWardId)
              .wardName;
        }
      } catch (_) {}

      final fields = <String, String>{
        "userId": userId,
        "alternateMobile": "",
        "gender": "Unknown",
        "state": _selectedState ?? "",
        "district": _selectedDistrict ?? "",
        "assembly": _selectedTaluka ?? "",
        "ward": selectedWardName,
        "pincode": _pincodeController.text,
        "homeAddress": _homeLocationController.text,
        "homeLatitude": _homeLat.toString(),
        "homeLongitude": _homeLng.toString(),
        "officeAddress": "",
        "hasBusiness": _hasBusiness.toString(),
      };

      if (_hasBusiness) {
        String businessWardName = _selectedBusinessWardId ?? '';
        try {
          if (_selectedBusinessWardId != null) {
            businessWardName = _allWards
                .firstWhere((w) => w.wardId == _selectedBusinessWardId)
                .wardName;
          }
        } catch (_) {}

        fields["businessDetails"] = dart_convert.jsonEncode({
          "businessType":
              "${_selectedSector?['sectorName'] ?? ''} | ${_selectedSubSector?['subSectorName'] ?? ''} | ${_selectedSubSubSector?['productDescription'] ?? _selectedSubSubSector?['subSubSectorName'] ?? ''}",
          "businessName": _businessNameController.text,
          "address": _businessLocationController.text,
          "latitude": _officeLat != 0.0 ? _officeLat : null,
          "longitude": _officeLng != 0.0 ? _officeLng : null,
          "ward": businessWardName.isNotEmpty ? businessWardName : selectedWardName,
        });
      }

      final pendingData = <String, dynamic>{
        'fields': fields,
        'profileImagePath': _selectedProfileImage?.path,
        'businessImagePaths': _selectedBusinessImageFiles
            .map((f) => f.path)
            .toList(),
      };
      await SessionManager.savePendingProfileData(pendingData);

      print(
        'DEV DEBUG - SignupScreen: Saved pending profile data to be uploaded on first login',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered Successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required ThemeData theme,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Container(
              width: 48,
              color: theme.colorScheme.secondary.withOpacity(0.1),
              child: Center(
                child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required ThemeData theme,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Container(
              width: 48,
              color: theme.colorScheme.secondary.withOpacity(0.1),
              child: Center(
                child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hintText,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealDropdown(
    String hint,
    IconData icon,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
    bool disabled,
  ) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: disabled
            ? Colors.grey.shade100
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Container(
              width: 48,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      items.isEmpty && !disabled ? 'Loading...' : hint,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.arrow_drop_down),
                  ),
                  items: items
                      .map(
                        (val) => DropdownMenuItem(
                          value: val,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              val,
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (disabled || items.isEmpty) ? null : onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(
    String label,
    TextEditingController controller,
    bool isHome,
  ) {
    final theme = Theme.of(context);
    final hasLocation = controller.text.isNotEmpty;
    return InkWell(
      onTap: () => _openMapToSelectLocation(isHome: isHome),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: hasLocation ? Colors.green.shade50 : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasLocation ? Colors.green.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              color: hasLocation
                  ? Colors.green.withOpacity(0.1)
                  : theme.colorScheme.secondary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  hasLocation
                      ? Icons.check_circle
                      : (isHome ? Icons.home : Icons.location_on),
                  color: hasLocation
                      ? Colors.green
                      : theme.colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  hasLocation ? 'Location Updated ($label)' : 'Select $label',
                  style: TextStyle(
                    color: hasLocation
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontWeight: hasLocation
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.map,
                color: hasLocation ? Colors.green : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardDropdown(String hint, IconData icon, bool disabled) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: disabled
            ? Colors.grey.shade100
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Container(
              width: 48,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedWardId,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _wards.isEmpty && !disabled ? 'Loading...' : hint,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.arrow_drop_down),
                  ),
                  items: _wards
                      .map(
                        (ward) => DropdownMenuItem(
                          value: ward.wardId,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${ward.wardName} (No. ${ward.wardNumber})',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (disabled || _wards.isEmpty)
                      ? null
                      : (val) {
                          setState(() => _selectedWardId = val);
                          _openMapToSelectLocation(isHome: true);
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessWardDropdown(String hint, IconData icon, bool disabled) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: disabled
            ? Colors.grey.shade100
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Container(
              width: 48,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBusinessWardId,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _businessWards.isEmpty && !disabled ? 'Loading...' : hint,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.arrow_drop_down),
                  ),
                  items: _businessWards
                      .map(
                        (ward) => DropdownMenuItem(
                          value: ward.wardId,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${ward.wardName} (No. ${ward.wardNumber})',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (disabled || _businessWards.isEmpty)
                      ? null
                      : (val) {
                          setState(() => _selectedBusinessWardId = val);
                          _openMapToSelectLocation(isHome: false);
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isUnlocked = step <= _highestStep;
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              setState(() {
                _currentStep = step;
              });
            }
          : null,
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive
                      ? Theme.of(context).colorScheme.surface
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade500,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey.shade300,
    );
  }

  Widget _buildOtpSection(ThemeData theme) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 48,
      textStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTP',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Pinput(
                  length: 6,
                  controller: _otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.send_outlined,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                label: Text(
                  'Send OTP',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
          return false; // Prevent pop
        }
        return true; // Allow pop
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Layers
            const TopLeftBlob(),
            const IndiaSkyline(opacity: 0.50),
            const WaterFlow(),

            SafeArea(
              child: Column(
                children: [
                  // Top Bar with Back Button
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep--);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // App Logo
                                SizedBox(
                                  height: size.height * 0.12,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/logo/uk_logo_1024x1024.jpeg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Header
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Create ',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Your Account',
                                            style: TextStyle(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 1,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 30,
                                          height: 1,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Step Indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStepIndicator(0, 'Personal'),
                                    _buildStepLine(),
                                    _buildStepIndicator(1, 'Area'),
                                    if (_hasBusiness || _currentStep == 2) ...[
                                      _buildStepLine(),
                                      _buildStepIndicator(2, 'Business'),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Form Fields
                                if (_currentStep == 0) ...[
                                  _buildInputField(
                                    theme: theme,
                                    hintText: 'Your Name',
                                    icon: Icons.person,
                                    controller: _nameController,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                    theme: theme,
                                    hintText: 'Mobile Number',
                                    icon: Icons.phone,
                                    controller: _mobileController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                    theme: theme,
                                    hintText: 'Email Address',
                                    icon: Icons.email,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: _pickProfileImage,
                                    icon: const Icon(
                                      Icons.add_photo_alternate_outlined,
                                    ),
                                    label: const Text('Upload Profile Image'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 20,
                                      ),
                                      side: BorderSide(
                                        color: theme.colorScheme.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  if (_selectedProfileImage != null) ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: FileImage(
                                              _selectedProfileImage!,
                                            ),
                                          ),
                                          Positioned(
                                            right: -8,
                                            top: -8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedProfileImage = null;
                                                });
                                              },
                                              child: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ] else if (_currentStep == 1) ...[
                                  Text(
                                    'YOUR AREA DETAILS',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildRealDropdown(
                                    'State',
                                    Icons.location_on,
                                    _states,
                                    _selectedState,
                                    _onStateChanged,
                                    false,
                                  ),
                                  _buildRealDropdown(
                                    'District',
                                    Icons.map,
                                    _districts,
                                    _selectedDistrict,
                                    _onDistrictChanged,
                                    _selectedState == null,
                                  ),
                                  _buildRealDropdown(
                                    'Taluk',
                                    Icons.terrain,
                                    _talukas,
                                    _selectedTaluka,
                                    _onTalukaChanged,
                                    _selectedDistrict == null,
                                  ),
                                  _buildWardDropdown(
                                    'Area / Village',
                                    Icons.map_outlined,
                                    _selectedTaluka == null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLocationButton(
                                    'Home Location',
                                    _homeLocationController,
                                    true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                    theme: theme,
                                    hintText: 'Pincode',
                                    icon: Icons.pin_drop,
                                    controller: _pincodeController,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Do you have a business?',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Radio<bool>(
                                        value: true,
                                        groupValue: _hasBusiness,
                                        activeColor: theme.colorScheme.primary,
                                        onChanged: (value) {
                                          setState(() {
                                            _hasBusiness = value!;
                                          });
                                        },
                                      ),
                                      Text('Yes'),
                                      const SizedBox(width: 16),
                                      Radio<bool>(
                                        value: false,
                                        groupValue: _hasBusiness,
                                        activeColor: theme.colorScheme.primary,
                                        onChanged: (value) {
                                          setState(() {
                                            _hasBusiness = value!;
                                          });
                                        },
                                      ),
                                      Text('No'),
                                    ],
                                  ),
                                ] else if (_currentStep == 2) ...[
                                  Text(
                                    'BUSINESS DETAILS',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInputField(
                                    theme: theme,
                                    hintText: 'Business Name',
                                    icon: Icons.store,
                                    controller: _businessNameController,
                                  ),
                                  const SizedBox(height: 16),
                                  _isLoadingSectors
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              child: DropdownButtonFormField<Map<String, dynamic>>(
                                                isExpanded: true,
                                                value: _selectedSector,
                                                decoration: InputDecoration(
                                                  labelText: "Business Category (Sector)",
                                                  filled: true,
                                                  fillColor: Colors.grey.shade50,
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                ),
                                                items: _sectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(value: s, child: Text(s['sectorName'], overflow: TextOverflow.ellipsis))).toList(),
                                                onChanged: _onSectorChanged,
                                                validator: (v) => v == null ? 'Required' : null,
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              child: DropdownButtonFormField<Map<String, dynamic>>(
                                                isExpanded: true,
                                                value: _selectedSubSector,
                                                decoration: InputDecoration(
                                                  labelText: "Business Sub-Category",
                                                  filled: true,
                                                  fillColor: Colors.grey.shade50,
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                ),
                                                items: _subSectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(value: s, child: Text(s['subSectorName'], overflow: TextOverflow.ellipsis))).toList(),
                                                onChanged: _onSubSectorChanged,
                                                validator: (v) => v == null ? 'Required' : null,
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: _isLoadingSubSubSectors ? const Center(child: CircularProgressIndicator()) : DropdownButtonFormField<Map<String, dynamic>>(
                                                      isExpanded: true,
                                                      value: _selectedSubSubSector,
                                                      decoration: InputDecoration(
                                                        labelText: "Business Sub-Sub-Category",
                                                        filled: true,
                                                        fillColor: Colors.grey.shade50,
                                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                                      ),
                                                      items: _subSubSectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(value: s, child: Text(s['productDescription'] ?? s['subSubSectorName'] ?? '', overflow: TextOverflow.ellipsis))).toList(),
                                                      onChanged: _onSubSubSectorChanged,
                                                      validator: (v) => v == null ? 'Required' : null,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
                                                    child: IconButton(
                                                      icon: const Icon(Icons.add, color: Colors.teal, size: 28),
                                                      onPressed: _showCreateAllSectorsDialog,
                                                      tooltip: 'Add new category',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _sameAsPersonalArea,
                                        activeColor: theme.colorScheme.primary,
                                        onChanged: (value) {
                                          setState(() {
                                            _sameAsPersonalArea = value ?? false;
                                            if (_sameAsPersonalArea) {
                                              _selectedBusinessState = _selectedState;
                                              _businessDistricts = List.from(_districts);
                                              _selectedBusinessDistrict = _selectedDistrict;
                                              _businessTalukas = List.from(_talukas);
                                              _selectedBusinessTaluka = _selectedTaluka;
                                              _businessWards = List.from(_wards);
                                              _selectedBusinessWardId = _selectedWardId;
                                            } else {
                                              _selectedBusinessState = null;
                                              _selectedBusinessDistrict = null;
                                              _selectedBusinessTaluka = null;
                                              _selectedBusinessWardId = null;
                                              _businessDistricts = [];
                                              _businessTalukas = [];
                                              _businessWards = [];
                                            }
                                          });
                                        },
                                      ),
                                      const Expanded(
                                        child: Text(
                                          'Same as personal area',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildRealDropdown(
                                    'State',
                                    Icons.location_on,
                                    _states,
                                    _selectedBusinessState,
                                    _onBusinessStateChanged,
                                    false,
                                  ),
                                  _buildRealDropdown(
                                    'District',
                                    Icons.map,
                                    _businessDistricts,
                                    _selectedBusinessDistrict,
                                    _onBusinessDistrictChanged,
                                    _selectedBusinessState == null,
                                  ),
                                  _buildRealDropdown(
                                    'Taluk',
                                    Icons.terrain,
                                    _businessTalukas,
                                    _selectedBusinessTaluka,
                                    _onBusinessTalukaChanged,
                                    _selectedBusinessDistrict == null,
                                  ),
                                  _buildBusinessWardDropdown(
                                    'Area / Village',
                                    Icons.map_outlined,
                                    _selectedBusinessTaluka == null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLocationButton(
                                    'Business Location',
                                    _businessLocationController,
                                    false,
                                  ),

                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                        side: BorderSide(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.5),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: _pickBusinessImages,
                                      icon: const Icon(
                                        Icons.add_photo_alternate_outlined,
                                      ),
                                      label: const Text(
                                        'Upload Business Images',
                                      ),
                                    ),
                                  ),
                                  if (_selectedBusinessImageFiles
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 80,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            _selectedBusinessImageFiles.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  right: 12,
                                                  top: 8,
                                                ),
                                                width: 72,
                                                height: 72,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image: FileImage(
                                                      _selectedBusinessImageFiles[index],
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 4,
                                                top: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedBusinessImageFiles
                                                          .removeAt(index);
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.remove_circle,
                                                      color: Colors.red,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                                const SizedBox(height: 24),
                                // Bottom Section with Gradient
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        theme.colorScheme.surface.withOpacity(
                                          0.0,
                                        ),
                                        theme.colorScheme.surface.withOpacity(
                                          0.85,
                                        ),
                                        theme.colorScheme.surface,
                                      ],
                                      stops: const [0.0, 0.25, 1.0],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 24),
                                      if (_isOtpSent) _buildOtpSection(theme),
                                      if (_isOtpSent)
                                        const SizedBox(height: 24),
                                      // Register Button
                                      InkWell(
                                        onTap: _isLoading
                                            ? null
                                            : () {
                                                if (_isOtpSent) {
                                                  _handleRegisterTap();
                                                } else {
                                                  if (_currentStep == 0) {
                                                    if (_nameController
                                                            .text
                                                            .isEmpty ||
                                                        _mobileController
                                                            .text
                                                            .isEmpty ||
                                                        _emailController
                                                            .text
                                                            .isEmpty) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Please fill all personal details',
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    setState(() {
                                                      _currentStep++;
                                                      if (_currentStep > _highestStep) {
                                                        _highestStep = _currentStep;
                                                      }
                                                    });
                                                    if (_states.isEmpty) {
                                                      _fetchWards();
                                                    }
                                                  } else if (_currentStep ==
                                                      1) {
                                                    if (_selectedWardId ==
                                                        null) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Please select an area',
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    if (_hasBusiness) {
                                                      setState(() {
                                                        _currentStep++;
                                                        if (_currentStep > _highestStep) {
                                                          _highestStep = _currentStep;
                                                        }
                                                      });
                                                    } else {
                                                      _handleRegisterTap();
                                                    }
                                                  } else if (_currentStep ==
                                                      2) {
                                                    _handleRegisterTap();
                                                  }
                                                }
                                              },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF001F3F),
                                                Color(0xFF00509E),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 16),
                                              Icon(
                                                Icons.person_add,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                size: 20,
                                              ),
                                              Container(
                                                width: 1,
                                                height: 24,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                    .withOpacity(0.3),
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                              ),
                                              Expanded(
                                                child: Center(
                                                  child: _isLoading
                                                      ? SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surface,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : Text(
                                                          _isOtpSent
                                                              ? 'VERIFY & REGISTER'
                                                              : ((_currentStep ==
                                                                            0 ||
                                                                        (_currentStep ==
                                                                                1 &&
                                                                            _hasBusiness))
                                                                    ? 'NEXT'
                                                                    : 'REGISTER'),
                                                          style: TextStyle(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surface,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            letterSpacing: 1.5,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 16),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: theme.colorScheme.secondary,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Your data is safe with us',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      // OR Divider
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    theme.colorScheme.onSurface
                                                        .withOpacity(0.0),
                                                    theme.colorScheme.onSurface
                                                        .withOpacity(0.5),
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(
                                              'OR',
                                              style: TextStyle(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    theme.colorScheme.onSurface
                                                        .withOpacity(0.5),
                                                    theme.colorScheme.onSurface
                                                        .withOpacity(0.0),
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Login Link
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Already have an account? ",
                                            style: TextStyle(
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Login',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 48),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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