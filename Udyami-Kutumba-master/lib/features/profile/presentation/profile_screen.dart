import 'dart:io';
import 'dart:convert' as dart_convert;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/auth/auth_api.dart';
import '../../../core/api/ubn/udyami_member_api.dart';
import '../../../core/models/udyami_member_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../../core/api/area/ward_api.dart';
import '../../../core/api/location/location_api.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/models/ward_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../auth/presentation/widgets/map_selection_modal.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'udyami_member_form_screen.dart';

import 'udyami_member_form_screen.dart';
import '../../ucn/ucnsubscreens/my_sectors_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileAPI _profileAPI = ProfileAPI();
  final WardAPI _wardAPI = WardAPI();
  final LocationAPI _locationAPI = LocationAPI();
  bool _isLoading = false;
  UserProfileModel? _profileData;
  Map<String, dynamic>? _udyamiMemberData;
  bool _isEditing = false;
  File? _selectedImageFile;
  bool _isUploadingImage = false;
  List<File> _selectedBusinessImageFiles = [];
  bool _isUploadingBusinessImages = false;
  bool _isAddingBusiness = false;

  // Ward cascading state
  List<WardModel> _allWards = [];
  List<Map<String, dynamic>> _apiDistricts = [];
  List<Map<String, dynamic>> _apiTalukas = [];
  List<String> _states = [
    'Karnataka',
  ]; // Pre-populate since the API only returns Karnataka
  List<String> _districts = [];
  List<String> _talukas = [];
  List<WardModel> _wards = [];
  // Business dropdown state
  List<dynamic> _sectors = [];
  List<dynamic> _subSectors = [];
  List<dynamic> _subSubSectors = [];
  Map<String, dynamic>? _selectedSector;
  Map<String, dynamic>? _selectedSubSector;
  Map<String, dynamic>? _selectedSubSubSector;
  bool _isLoadingSectors = true;

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

  // Location state
  double _homeLat = 0.0;
  double _homeLng = 0.0;
  double _officeLat = 0.0;
  double _officeLng = 0.0;

  // Controllers for editing
  final TextEditingController _alternateMobileController =
      TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _officeAddressController =
      TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _homeLocationController = TextEditingController();
  final TextEditingController _businessLocationController =
      TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _yearsInCityController = TextEditingController();
  final TextEditingController _selectedBusinessVerticalController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _familyCountController = TextEditingController();
  final TextEditingController _spouseController = TextEditingController();
  final TextEditingController _petsController = TextEditingController();
  
  // Dynamic lists for multiple items
  List<String> _childrenList = [];
  List<String> _hobbiesList = [];
  List<String> _interestsList = [];
  
  final TextEditingController _newChildController = TextEditingController();
  final TextEditingController _newHobbyController = TextEditingController();
  final TextEditingController _newInterestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await Future.wait([_fetchDistricts(), _fetchWards(), _fetchSectors()]);
    await _fetchProfile();

    // Trigger population of dependent dropdowns after both districts and profile are loaded
    if (_selectedDistrict != null) {
      await _onDistrictChanged(_selectedDistrict, preserveSelections: true);
    }
  }

  // Parse JSON array strings for multiple values
  List<String> _parseList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = dart_convert.jsonDecode(jsonString);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (e) {}
    
    // Fallback for comma-separated strings (legacy or malformed)
    if (jsonString.contains(',')) {
      return jsonString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    
    return [jsonString];
  }

  Future<void> _fetchDistricts() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _locationAPI.getAllDistricts();
      if (response != null && response['success'] == true) {
        final List rawData = response['data'] ?? [];
        _apiDistricts = rawData.cast<Map<String, dynamic>>();
        setState(() {
          _districts =
              _apiDistricts
                  .map((d) => d['districtName']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
        });
      }
    } catch (e) {
      print("DEV DEBUG - Failed to fetch districts: $e");
    } finally {
      stopwatch.stop();
      print(
        "DEV DEBUG - ProfileScreen: _fetchDistricts finished. Loading took ${stopwatch.elapsed.inSeconds} seconds (${stopwatch.elapsedMilliseconds} ms).",
      );
    }
  }

  Future<void> _fetchWards() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _wardAPI.getAllWards();
      if (response != null && response['success'] == true) {
        final List rawData = response['data'] ?? [];
        _allWards = rawData
            .map((w) => WardModel.fromJson(w as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print("DEV DEBUG - Failed to fetch wards: $e");
    } finally {
      stopwatch.stop();
      print(
        "DEV DEBUG - ProfileScreen: _fetchWards finished. Loading took ${stopwatch.elapsed.inSeconds} seconds (${stopwatch.elapsedMilliseconds} ms).",
      );
      if (mounted && _isEditing && _selectedTaluka != null) {
        // Now that _allWards is loaded, refresh the wards dropdown
        _onTalukaChanged(_selectedTaluka, preserveSelections: true);
      }
    }
  }

  @override
  void dispose() {
    _alternateMobileController.dispose();
    _homeAddressController.dispose();
    _officeAddressController.dispose();
    _pincodeController.dispose();
    _homeLocationController.dispose();
    _businessLocationController.dispose();
    _businessNameController.dispose();
    _yearsInCityController.dispose();
    _selectedBusinessVerticalController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _familyCountController.dispose();
    _spouseController.dispose();
    _petsController.dispose();
    _newChildController.dispose();
    _newHobbyController.dispose();
    _newInterestController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    final stopwatch = Stopwatch()..start();
    setState(() => _isLoading = true);
    try {
      final user = SessionManager.user;
      if (user == null || user['userId'] == null) {
        throw Exception("User not logged in");
      }

      final userId = user['userId'].toString();
      final response = await _profileAPI.getUserProfileById(userId);

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data']['user'] != null) {
          final sessionRoles = user['userRoles'] ?? user['roles'];
          if (sessionRoles != null) {
            response['data']['user']['userRoles'] = sessionRoles;
          }
        }

        // Fetch Udyami Member data to calculate completeness
        final membersList = await UdyamiMemberAPI.getAllUdyamiMembers();
        Map<String, dynamic>? memberData;
        try {
          memberData =
              membersList.firstWhere(
                    (m) =>
                        m['createdByUserId'] == userId ||
                        m['primaryMobile'] ==
                            response['data']['user']['mobileNumber'],
                  )
                  as Map<String, dynamic>?;
        } catch (_) {}

        setState(() {
          _profileData = UserProfileModel.fromJson(response['data']);
          print("DEV DEBUG - ProfileScreen: parsed _profileData");
          print("DEV DEBUG - ProfileScreen: _profileData.profile.hasBusiness = ${_profileData!.profile.hasBusiness}",);
          print("DEV DEBUG - ProfileScreen: _profileData.profile.businessDetails = ${_profileData!.profile.businessDetails}",);
          _udyamiMemberData = memberData;
          _populateControllers();
          _isLoading = false;
        });
      } else {
        throw Exception(response?['message'] ?? "Failed to load profile");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    } finally {
      stopwatch.stop();
      print("DEV DEBUG - ProfileScreen: _fetchProfile finished. Loading took ${stopwatch.elapsed.inSeconds} seconds (${stopwatch.elapsedMilliseconds} ms).");
    }
  }

  Future<void> _openMapToSelectLocation({required bool isHome}) async {
    LatLng? initial = isHome
        ? (_homeLat != 0.0 ? LatLng(_homeLat, _homeLng) : null)
        : (_officeLat != 0.0 ? LatLng(_officeLat, _officeLng) : null);

    WardModel? selectedWard;
    if (_selectedWardId != null) {
      try {
        selectedWard = _wards.firstWhere((w) => w.wardId == _selectedWardId);
      } catch (e) {
        print("DEV DEBUG - _openMapToSelectLocation: Error finding ward: $e");
      }
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
          _homeLocationController.text =
              "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}";
          if (address != null && address.isNotEmpty) {
            _homeAddressController.text = address;
          }
        } else {
          _officeLat = loc.latitude;
          _officeLng = loc.longitude;
          _businessLocationController.text =
              "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}";
          if (address != null && address.isNotEmpty) {
            _officeAddressController.text = address;
          }
        }
      });
    }
  }

  Widget _buildLocationButton(
    String label,
    TextEditingController addressController,
    bool isHome,
  ) {
    final theme = Theme.of(context);
    final hasLocation = addressController.text.isNotEmpty;
    return InkWell(
      onTap: () => _openMapToSelectLocation(isHome: isHome),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: hasLocation ? Colors.green.shade50 : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasLocation ? Colors.green.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasLocation
                    ? Colors.green.withOpacity(0.1)
                    : theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                ),
              ),
              child: Center(
                child: Icon(
                  hasLocation
                      ? Icons.location_on
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  hasLocation ? addressController.text : label,
                  style: TextStyle(
                    color: hasLocation ? Colors.black87 : Colors.grey.shade600,
                    fontWeight: hasLocation
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _populateControllers() {
    if (_profileData != null) {
      _usernameController.text = _profileData!.user.username ?? '';
      _emailController.text = _profileData!.user.email;
      _mobileController.text = _profileData!.user.mobileNumber;
      _alternateMobileController.text =
          _profileData!.profile.alternateMobile ?? '';
      _homeAddressController.text = _profileData!.profile.homeAddress ?? '';
      _pincodeController.text = _profileData!.profile.pincode ?? '';
      _yearsInCityController.text = _profileData!.profile.yearsInCity ?? '';
      _selectedBusinessVerticalController.text =
          _profileData!.profile.selectedBusinessVertical ?? '';
      _familyCountController.text =
          _profileData!.profile.familyCount?.toString() ?? '';
      _spouseController.text = _profileData!.profile.spouse ?? '';
      
      _childrenList = _parseList(_profileData!.profile.children);
      _petsController.text = _profileData!.profile.pets ?? '';
      _hobbiesList = _parseList(_profileData!.profile.hobbies);
      _interestsList = _parseList(_profileData!.profile.interests);

      _homeLat = _profileData!.profile.homeLatitude ?? 0.0;
      _homeLng = _profileData!.profile.homeLongitude ?? 0.0;

      if (_homeLat == 0.0 && _homeLng == 0.0) {
        final ha = _profileData!.profile.homeAddress ?? '';
        if (ha.contains(',')) {
          final parts = ha.split(',');
          if (parts.length == 2) {
            _homeLat = double.tryParse(parts[0].trim()) ?? 0.0;
            _homeLng = double.tryParse(parts[1].trim()) ?? 0.0;
          }
        }
      }

      if (_homeLat != 0.0 && _homeLng != 0.0) {
        _homeLocationController.text =
            '${_homeLat.toStringAsFixed(4)}, ${_homeLng.toStringAsFixed(4)}';
      }

      if (_profileData!.profile.businessDetails != null) {
        _businessNameController.text =
            _profileData!.profile.businessDetails!.businessName ?? '';
        _officeLat = _profileData!.profile.businessDetails!.latitude ?? 0.0;
        _officeLng = _profileData!.profile.businessDetails!.longitude ?? 0.0;

        if (_officeLat == 0.0 && _officeLng == 0.0) {
          final ba =
              _profileData!.profile.businessDetails!.businessAddress ?? '';
          if (ba.contains(',')) {
            final parts = ba.split(',');
            if (parts.length == 2) {
              _officeLat = double.tryParse(parts[0].trim()) ?? 0.0;
              _officeLng = double.tryParse(parts[1].trim()) ?? 0.0;
            }
          }
        }

        if (_officeLat != 0.0 && _officeLng != 0.0) {
          _businessLocationController.text =
              '${_officeLat.toStringAsFixed(4)}, ${_officeLng.toStringAsFixed(4)}';
          final ba =
              _profileData!.profile.businessDetails!.businessAddress ?? '';

          bool isJustCoords = false;
          final parts = ba.split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            if (lat != null && lng != null) {
              isJustCoords = true;
            }
          }

          if (ba.isNotEmpty && !isJustCoords) {
            _officeAddressController.text = ba;
          }
        }
      }

      print('DEV DEBUG - _populateControllers: START');
      print('DEV DEBUG - _populateControllers: profile.state = ${_profileData!.profile.state}');
      print('DEV DEBUG - _populateControllers: profile.district = ${_profileData!.profile.district}');
      print('DEV DEBUG - _populateControllers: profile.assembly (taluka) = ${_profileData!.profile.assembly}');
      print('DEV DEBUG - _populateControllers: profile.ward = ${_profileData!.profile.ward}');

      if (_profileData!.profile.state != null) {
        _selectedState = _profileData!.profile.state;
      }
      if (_profileData!.profile.district != null) {
        _selectedDistrict = _profileData!.profile.district;
      }
      if (_profileData!.profile.assembly != null) {
        _selectedTaluka = _profileData!.profile.assembly;
      }
      
      if (_profileData!.profile.ward != null) {
        String savedWard = _profileData!.profile.ward!;
        WardModel? matchedWard;
        // If it's not a UUID, try to find the ID from _allWards
        if (!savedWard.contains('-')) {
          try {
            matchedWard = _allWards.firstWhere(
              (w) => w.wardName.toLowerCase() == savedWard.toLowerCase(),
            );
            _selectedWardId = matchedWard.wardId;
            print('DEV DEBUG - _populateControllers: mapped ward "$savedWard" to ID "${matchedWard.wardId}"');
          } catch (e) {
            _selectedWardId = savedWard;
            print('DEV DEBUG - _populateControllers: failed to map ward "$savedWard" to an ID');
          }
        } else {
          _selectedWardId = savedWard;
          try {
            matchedWard = _allWards.firstWhere((w) => w.wardId == savedWard);
          } catch (e) {}
          print('DEV DEBUG - _populateControllers: ward is already UUID "$savedWard"');
        }

        // Back-fill taluka, district, and state if they are missing or likely wrong (legacy short names)
        if (matchedWard != null) {
          if (_selectedTaluka == null || _selectedTaluka!.isEmpty || !_apiTalukas.any((t) => t['talukaName'] == _selectedTaluka)) {
            print('DEV DEBUG - _populateControllers: backfilling Taluka to "${matchedWard.taluka}"');
            _selectedTaluka = matchedWard.taluka;
          }
          if (_selectedDistrict == null || _selectedDistrict!.isEmpty || !_apiDistricts.any((d) => d['districtName'] == _selectedDistrict)) {
            print('DEV DEBUG - _populateControllers: backfilling District to "${matchedWard.district}"');
            _selectedDistrict = matchedWard.district;
          }
          if (_selectedState == null || _selectedState!.isEmpty) {
            print('DEV DEBUG - _populateControllers: backfilling State to "${matchedWard.state}"');
            _selectedState = matchedWard.state;
          }
        }
      }

      if (_profileData!.profile.businessDetails != null && _profileData!.profile.businessDetails!.ward != null) {
        String savedWard = _profileData!.profile.businessDetails!.ward!;
        WardModel? matchedWard;
        if (!savedWard.contains('-')) {
          try {
            matchedWard = _allWards.firstWhere(
              (w) => w.wardName.toLowerCase() == savedWard.toLowerCase(),
            );
            _selectedBusinessWardId = matchedWard.wardId;
          } catch (e) {
            _selectedBusinessWardId = savedWard;
          }
        } else {
          _selectedBusinessWardId = savedWard;
          try {
            matchedWard = _allWards.firstWhere((w) => w.wardId == savedWard);
          } catch (e) {}
        }

        if (matchedWard != null) {
          _selectedBusinessTaluka = matchedWard.taluka;
          _selectedBusinessDistrict = matchedWard.district;
          _selectedBusinessState = matchedWard.state;

          if (_selectedBusinessState == _selectedState &&
              _selectedBusinessDistrict == _selectedDistrict &&
              _selectedBusinessTaluka == _selectedTaluka &&
              _selectedBusinessWardId == _selectedWardId) {
            _sameAsPersonalArea = true;
          }
        }
      }

      print('DEV DEBUG - _populateControllers: Selected Variables -> State: $_selectedState, District: $_selectedDistrict, Taluka: $_selectedTaluka, WardID: $_selectedWardId');

      // Pre-populate lists so dropdowns have items when editing
      if (_selectedState != null) {
        _onStateChanged(_selectedState, preserveSelections: true);
      }
      if (_selectedDistrict != null) {
        _onDistrictChanged(_selectedDistrict, preserveSelections: true);
      } else if (_selectedTaluka != null) {
        _onTalukaChanged(_selectedTaluka, preserveSelections: true);
      }
      
      print('DEV DEBUG - _populateControllers: Dropdown lists lengths -> states: ${_states.length}, districts: ${_districts.length}, talukas: ${_talukas.length}, wards: ${_wards.length}');
      print('DEV DEBUG - _populateControllers: END');
      
      // Initialize business dropdowns
      if (_sameAsPersonalArea) {
        _businessDistricts = List.from(_districts);
        _businessTalukas = List.from(_talukas);
        _businessWards = List.from(_wards);
      } else {
        if (_selectedBusinessState != null) {
          _businessDistricts = List.from(_districts);
        }
        if (_selectedBusinessTaluka != null) {
          final query = _selectedBusinessTaluka!.toLowerCase().trim();
          _businessWards = _allWards.where((w) => w.taluka.toLowerCase().trim() == query).toList();
          _businessWards.sort((a, b) => a.wardName.compareTo(b.wardName));
        }
      }
    }
  }

  void _onStateChanged(String? state, {bool preserveSelections = false}) {
    setState(() {
      if (!preserveSelections) {
        _selectedState = state;
        _selectedDistrict = null;
        _selectedTaluka = null;
        _selectedWardId = null;
      }
      _districts =
          _apiDistricts
              .map((d) => d['districtName']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
            
      if (preserveSelections && _selectedDistrict != null && !_districts.contains(_selectedDistrict)) {
        print('DEV DEBUG - _selectedDistrict "$_selectedDistrict" not found in API list! Adding it manually.');
        _districts.add(_selectedDistrict!);
        _districts.sort();
      }
            
      if (!preserveSelections) {
        _talukas = [];
        _wards = [];
      }
    });
  }

  Future<void> _onDistrictChanged(
    String? district, {
    bool preserveSelections = false,
  }) async {
    setState(() {
      if (!preserveSelections) {
        _selectedDistrict = district;
        _selectedTaluka = null;
        _selectedWardId = null;
      }
      if (!preserveSelections) {
        _talukas = [];
        _wards = [];
      }
    });

    if (district != null) {
      final districtMap = _apiDistricts.firstWhere(
        (d) => d['districtName'] == district,
        orElse: () => {},
      );
      final districtId = districtMap['districtId']?.toString();
      if (districtId != null && districtId.isNotEmpty) {
        try {
          final response = await _locationAPI.getAllDistricts(
            districtId: districtId,
          );
          if (response != null && response['success'] == true) {
            final List rawData = response['data'] ?? [];
            _apiTalukas = rawData.cast<Map<String, dynamic>>();
            if (mounted) {
              setState(() {
                _talukas =
                    _apiTalukas
                        .map((t) => t['talukaName']?.toString() ?? '')
                        .where((s) => s.isNotEmpty)
                        .toSet()
                        .toList()
                      ..sort();
                      
                if (preserveSelections && _selectedTaluka != null && !_talukas.contains(_selectedTaluka)) {
                  print('DEV DEBUG - _selectedTaluka "$_selectedTaluka" not found in API list! Adding it manually.');
                  _talukas.add(_selectedTaluka!);
                  _talukas.sort();
                }
              });

              // If we are preserving selections, we might need to trigger taluka changed to populate wards
              if (preserveSelections && _selectedTaluka != null) {
                _onTalukaChanged(_selectedTaluka, preserveSelections: true);
              }
            }
          }
        } catch (e) {
          print("DEV DEBUG - Failed to fetch talukas: $e");
        }
      }
    }
  }

  void _onTalukaChanged(String? taluka, {bool preserveSelections = false}) {
    setState(() {
      if (!preserveSelections) {
        _selectedTaluka = taluka;
        _selectedWardId = null;
      }
      if (taluka != null) {
        final query = taluka.toLowerCase().trim();
        // Fallback to try finding wards from _apiTalukas if _allWards is empty
        final talukaData = _apiTalukas.firstWhere(
          (t) =>
              (t['talukaName']?.toString().toLowerCase().trim() ?? '') == query,
          orElse: () => {},
        );

        if (talukaData.containsKey('wards') && talukaData['wards'] is List) {
          final List<dynamic> wardsList = talukaData['wards'];
          _wards = wardsList.map((w) {
            return WardModel(
              wardId: w['wardId']?.toString() ?? w['id']?.toString() ?? '',
              wardName:
                  w['wardName']?.toString() ?? w['name']?.toString() ?? '',
              wardNumber: w['wardNumber']?.toString() ?? '',
              taluka: taluka,
              district: _selectedDistrict ?? '',
              state: _selectedState ?? '',
            );
          }).toList();
        } else {
          _wards = _allWards
              .where((w) => w.taluka.toLowerCase().trim() == query)
              .toList();
        }
        _wards.sort((a, b) => a.wardName.compareTo(b.wardName));
        
        if (preserveSelections && _selectedWardId != null && !_wards.any((w) => w.wardId == _selectedWardId)) {
          print('DEV DEBUG - _selectedWardId "$_selectedWardId" not found in wards list! Adding dummy model.');
          // Try to find the real name if it exists in _allWards
          String wardName = _selectedWardId!;
          try {
             wardName = _allWards.firstWhere((w) => w.wardId == _selectedWardId).wardName;
          } catch (_) {}
          
          _wards.add(WardModel(
            wardId: _selectedWardId!,
            wardName: wardName,
            wardNumber: '',
            taluka: taluka,
            district: _selectedDistrict ?? '',
            state: _selectedState ?? '',
          ));
        }
      } else {
      }
    });
  }

  void _onBusinessStateChanged(String? state) {
    setState(() {
      _selectedBusinessState = state;
      _selectedBusinessDistrict = null;
      _selectedBusinessTaluka = null;
      _selectedBusinessWardId = null;
      _businessDistricts = _districts;
      _businessTalukas = [];
      _businessWards = [];
    });
  }

  Future<void> _onBusinessDistrictChanged(String? district) async {
    setState(() {
      _selectedBusinessDistrict = district;
      _selectedBusinessTaluka = null;
      _selectedBusinessWardId = null;
      _businessTalukas = [];
      _businessWards = [];
    });

    if (district != null) {
      final districtMap = _apiDistricts.firstWhere(
        (d) => d['districtName'] == district,
        orElse: () => {},
      );
      final districtId = districtMap['districtId']?.toString();
      if (districtId != null && districtId.isNotEmpty) {
        try {
          final response = await _locationAPI.getAllDistricts(
            districtId: districtId,
          );
          if (response != null && response['success'] == true) {
            final List rawData = response['data'] ?? [];
            if (mounted) {
              setState(() {
                _businessTalukas = rawData
                    .map((t) => t['talukaName']?.toString() ?? '')
                    .where((s) => s.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();
              });
            }
          }
        } catch (e) {
          print("DEV DEBUG - Failed to fetch business talukas: $e");
        }
      }
    }
  }

  void _onBusinessTalukaChanged(String? taluka) {
    setState(() {
      _selectedBusinessTaluka = taluka;
      _selectedBusinessWardId = null;
      if (taluka != null) {
        final query = taluka.toLowerCase().trim();
        _businessWards = _allWards
            .where((w) => w.taluka.toLowerCase().trim() == query)
            .toList();
        _businessWards.sort((a, b) => a.wardName.compareTo(b.wardName));
      } else {
        _businessWards = [];
      }
    });
  }

  void _onBusinessWardChanged(String? wardId) {
    setState(() {
      _selectedBusinessWardId = wardId;
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
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                    
                    if (hasSector) {
                      finalSectorId = _selectedSector!['sectorId'];
                    } else {
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
                    }

                    String? finalSubSectorId;
                    
                    if (hasSubSector) {
                      finalSubSectorId = _selectedSubSector!['subSectorId'];
                    } else {
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
                    }

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

                    setState(() => statusMessage = "✅ All created! Auto-filling...");

                    Navigator.pop(dialogContext);

                    await _fetchSectors();

                    if (mounted) {
                      this.setState(() {
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

  void _onSectorChanged(Map<String, dynamic>? newSector) {
    setState(() {
      _selectedSector = newSector;
      _subSectors = newSector?['subSectors'] ?? [];
      _selectedSubSector = null;
      _subSubSectors = [];
      _selectedSubSubSector = null;
    });
  }

  void _onSubSectorChanged(Map<String, dynamic>? newSubSector) {
    setState(() {
      _selectedSubSector = newSubSector;
      _subSubSectors = [];
      _selectedSubSubSector = null;
    });
    if (newSubSector != null) {
      _fetchTags(newSubSector['subSectorId']);
    }
  }

  void _onSubSubSectorChanged(Map<String, dynamic>? newTag) {
    setState(() {
      _selectedSubSubSector = newTag;
    });
  }

  Future<void> _fetchTags(String subSectorId, {String? tagNameToSelect}) async {
    final sectorApi = SectorAPI();
    final res = await sectorApi.getAllSubSubSectors(subSectorId);
    if (res != null && res['success'] == true && res['data'] != null) {
      if (mounted) {
        setState(() {
          _subSubSectors = res['data']['subSubSectors'] ?? [];
          if (tagNameToSelect != null) {
            try {
              _selectedSubSubSector = _subSubSectors.firstWhere(
                (t) =>
                    (t['subSubSectorName']?.toString().toLowerCase().trim() ??
                        '') ==
                    tagNameToSelect,
              );
            } catch (e) {
              _selectedSubSubSector = null;
            }
          }
        });
      }
    }
  }

  Future<void> _fetchSectors() async {
    final sectorApi = SectorAPI();
    final res = await sectorApi.getAllSectors();
    if (res != null && res['success'] == true && res['data'] != null) {
      if (mounted) {
        setState(() {
          _sectors = res['data'];
          _isLoadingSectors = false;

          if (_profileData?.profile.hasBusiness == true) {
            String? catNameFromProfile;
            String? subCatNameFromProfile;
            String? tagNameFromProfile;

            if (_profileData?.profile.businessDetails?.businessType != null) {
              final bType =
                  _profileData!.profile.businessDetails!.businessType!;
              final parts = bType
                  .split(RegExp(r'[|-]'))
                  .map((e) => e.trim())
                  .toList();
              if (parts.isNotEmpty)
                catNameFromProfile = parts[0].toLowerCase().trim();
              if (parts.length > 1)
                subCatNameFromProfile = parts[1].toLowerCase().trim();
              if (parts.length > 2)
                tagNameFromProfile = parts[2].toLowerCase().trim();
            } else {
              catNameFromProfile = _profileData?.profile.businessCategory
                  ?.toLowerCase()
                  .trim();
              subCatNameFromProfile = _profileData?.profile.businessSubCategory
                  ?.toLowerCase()
                  .trim();
              tagNameFromProfile = _profileData?.profile.businessTag
                  ?.toLowerCase()
                  .trim();
            }

            if (catNameFromProfile != null && catNameFromProfile.isNotEmpty) {
              final catName = catNameFromProfile;
              try {
                _selectedSector = _sectors.firstWhere(
                  (s) =>
                      (s['sectorName']?.toString().toLowerCase().trim() ??
                          '') ==
                      catName,
                );
                if (_selectedSector != null) {
                  _subSectors = _selectedSector!['subSectors'] ?? [];
                  if (subCatNameFromProfile != null &&
                      subCatNameFromProfile.isNotEmpty) {
                    final subCatName = subCatNameFromProfile;
                    try {
                      _selectedSubSector = _subSectors.firstWhere(
                        (s) =>
                            (s['subSectorName']
                                    ?.toString()
                                    .toLowerCase()
                                    .trim() ??
                                '') ==
                            subCatName,
                      );
                      if (_selectedSubSector != null) {
                        if (tagNameFromProfile != null &&
                            tagNameFromProfile.isNotEmpty) {
                          _fetchTags(_selectedSubSector!['subSectorId'],
                              tagNameToSelect: tagNameFromProfile);
                        }
                      }
                    } catch (_) {}
                  }
                }
              } catch (_) {}
            }
          }
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingSectors = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.teal.shade700),
                ),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.blue.shade700),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    setState(() {
      _selectedImageFile = imageFile;
      _isUploadingImage = true;
    });

    try {
      final userId = _profileData!.user.userId;
      final hasProfile = _profileData?.profile.profileId.isNotEmpty == true;
      final response = hasProfile
          ? await _profileAPI.uploadProfileImage(userId, imageFile)
          : await _profileAPI.createProfileWithImage(userId, imageFile);
      if (response != null && response['success'] != false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
            ),
          );
          SessionManager.profileUpdateNotifier.value++;
          _fetchProfile();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload image: ${response?['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _pickAndUploadBusinessImages() async {
    final existingImages =
        _profileData?.profile.businessDetails?.businessImages ?? [];
    final remainingSlots = 3 - existingImages.length - _selectedBusinessImageFiles.length;

    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 business images allowed.')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFiles.isEmpty) return;

    final limitedPicks = pickedFiles.take(remainingSlots).toList();
    final newImageFiles = limitedPicks.map((x) => File(x.path)).toList();

    setState(() {
      _selectedBusinessImageFiles.addAll(newImageFiles);
    });
  }


  void _showOtpBottomSheet() {
    final TextEditingController otpController = TextEditingController();
    bool isVerifying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify Updates',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'To secure your profile updates, please enter the OTP sent to your registered mobile number.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      prefixIcon: const Icon(
                        Icons.security,
                        color: Colors.teal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: isVerifying
                          ? null
                          : () async {
                              if (otpController.text.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a valid 6-digit OTP',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setModalState(() => isVerifying = true);
                              try {
                                final authApi = AuthAPI();
                                final mobile =
                                    _profileData?.user.mobileNumber ?? '';
                                final verifyResponse = await authApi.verifyOtp(
                                  mobile,
                                  otpController.text,
                                  'PROFILE',
                                );

                                if (verifyResponse == null ||
                                    verifyResponse['success'] != true) {
                                  if (mounted) {
                                    final errorMsg =
                                        verifyResponse?['message'] ??
                                        'Invalid OTP';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMsg)),
                                    );
                                  }
                                  setModalState(() => isVerifying = false);
                                  return;
                                }

                                if (mounted) {
                                  Navigator.pop(ctx);
                                  _executeProfileSave();
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error verifying OTP: $e'),
                                    ),
                                  );
                                }
                                setModalState(() => isVerifying = false);
                              }
                            },
                      child: isVerifying
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.surface,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Verify & Save',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _buildUpdateData() {
    final Map<String, dynamic> updateData = {};

    if (_usernameController.text.isNotEmpty && _usernameController.text != (_profileData!.user.username ?? '')) {
      updateData["username"] = _usernameController.text;
    }
    if (_emailController.text.isNotEmpty && _emailController.text != _profileData!.user.email) {
      updateData["email"] = _emailController.text;
    }
    if (_mobileController.text.isNotEmpty && _mobileController.text != _profileData!.user.mobileNumber) {
      updateData["mobileNumber"] = _mobileController.text;
    }

    if (_alternateMobileController.text != (_profileData!.profile.alternateMobile ?? '')) {
      updateData["alternateMobile"] = _alternateMobileController.text;
    }
    if (_homeLat != 0.0 && _homeLng != 0.0) {
      updateData["homeAddress"] = _homeAddressController.text.isNotEmpty
          ? _homeAddressController.text
          : '${_homeLat.toStringAsFixed(4)}, ${_homeLng.toStringAsFixed(4)}';
      updateData["homeLatitude"] = _homeLat;
      updateData["homeLongitude"] = _homeLng;
    }
    if (_officeAddressController.text != (_profileData!.profile.officeAddress ?? '')) {
      updateData["officeAddress"] = _officeAddressController.text;
    }
    if (_pincodeController.text != (_profileData!.profile.pincode ?? '')) {
      updateData["pincode"] = _pincodeController.text;
    }

    if (_yearsInCityController.text != (_profileData!.profile.yearsInCity ?? '')) {
      updateData["yearsInCity"] = int.tryParse(_yearsInCityController.text) ?? 0;
    }
    if (_selectedBusinessVerticalController.text != (_profileData!.profile.selectedBusinessVertical ?? '')) {
      updateData["selectedBusinessVertical"] = _selectedBusinessVerticalController.text;
    }
    if (_familyCountController.text != (_profileData!.profile.familyCount?.toString() ?? '')) {
      updateData["familyCount"] = int.tryParse(_familyCountController.text) ?? 0;
    }
    if (_spouseController.text != (_profileData!.profile.spouse ?? '')) {
      updateData["spouse"] = _spouseController.text;
    }
    
    if (_childrenList.isNotEmpty || (_profileData!.profile.children?.isNotEmpty ?? false)) {
      updateData["children"] = _childrenList;
    }
    if (_petsController.text != (_profileData!.profile.pets ?? '')) {
      updateData["pets"] = _petsController.text;
    }
    if (_hobbiesList.isNotEmpty || (_profileData!.profile.hobbies?.isNotEmpty ?? false)) {
      updateData["hobbies"] = _hobbiesList;
    }
    if (_interestsList.isNotEmpty || (_profileData!.profile.interests?.isNotEmpty ?? false)) {
      updateData["interests"] = _interestsList;
    }

    if (_selectedState != null && _selectedState != _profileData!.profile.state) {
      updateData["state"] = _selectedState!;
    }
    if (_selectedDistrict != null && _selectedDistrict != _profileData!.profile.district) {
      updateData["district"] = _selectedDistrict!;
    }
    if (_selectedTaluka != null && _selectedTaluka != _profileData!.profile.assembly) {
      updateData["assembly"] = _selectedTaluka!;
    }

    String selectedWardName = _selectedWardId ?? '';
    try {
      if (_selectedWardId != null) {
        selectedWardName = _allWards.firstWhere((w) => w.wardId == _selectedWardId).wardName;
      }
    } catch (_) {}

    if (_selectedWardId != null && selectedWardName.isNotEmpty && selectedWardName != _profileData!.profile.ward) {
      updateData["ward"] = selectedWardName;
    }

    if (_profileData!.profile.hasBusiness || _isAddingBusiness) {
      if (_isAddingBusiness) {
        updateData["hasBusiness"] = true;
      }
      final Map<String, dynamic> bDetails = {};

      if (_profileData!.profile.businessDetails != null) {
        final existing = _profileData!.profile.businessDetails!;
        if (existing.gstNumber != null) bDetails["gstNumber"] = existing.gstNumber;
        if (existing.businessName != null) bDetails["businessName"] = existing.businessName;
        if (existing.businessType != null) bDetails["businessType"] = existing.businessType;
        if (existing.annualTurnover != null) bDetails["annualTurnover"] = existing.annualTurnover;
        if (existing.businessAddress != null) bDetails["address"] = existing.businessAddress;
        
        // Re-send existing images in JSON so they aren't deleted by the backend's PATCH
        if (existing.businessImages != null && existing.businessImages!.isNotEmpty) {
          for (int i = 0; i < existing.businessImages!.length; i++) {
            bDetails["businessImage${i + 1}"] = {"image": existing.businessImages![i]};
          }
        }

        if (existing.latitude != null) bDetails["latitude"] = existing.latitude;
        if (existing.longitude != null) bDetails["longitude"] = existing.longitude;
        if (existing.ward != null) bDetails["ward"] = existing.ward;
        if (existing.yearsInBusiness != null) bDetails["yearsInBusiness"] = existing.yearsInBusiness;
        if (existing.previousJobs != null) bDetails["previousJobs"] = existing.previousJobs;
      }

      String businessWardName = _selectedBusinessWardId ?? '';
      try {
        if (_selectedBusinessWardId != null) {
          businessWardName = _allWards.firstWhere((w) => w.wardId == _selectedBusinessWardId).wardName;
        }
      } catch (_) {}

      if (businessWardName.isNotEmpty) {
        bDetails["ward"] = businessWardName;
      } else if (selectedWardName.isNotEmpty && _sameAsPersonalArea) {
        bDetails["ward"] = selectedWardName;
      }
      if (_businessNameController.text.isNotEmpty) {
        bDetails["businessName"] = _businessNameController.text;
      }

      final subSubName = _selectedSubSubSector?['sourceService'] ?? _selectedSubSubSector?['subSubSectorName'] ?? _selectedSubSubSector?['productDescription'] ?? '';
      final newBusinessType = "${_selectedSector?['sectorName'] ?? ''} | ${_selectedSubSector?['subSectorName'] ?? ''} | $subSubName";
      if (newBusinessType.trim() != '|  |') {
        bDetails["businessType"] = newBusinessType;
        updateData["businessCategory"] = _selectedSector?['sectorName'] ?? '';
        updateData["businessSubCategory"] = _selectedSubSector?['subSectorName'] ?? '';
        updateData["businessTag"] = subSubName;
      }

      if (_officeLat != 0.0 && _officeLng != 0.0) {
        final newAddress = _officeAddressController.text.isNotEmpty
            ? _officeAddressController.text
            : '${_officeLat.toStringAsFixed(4)}, ${_officeLng.toStringAsFixed(4)}';
        bDetails["address"] = newAddress;
        bDetails["latitude"] = _officeLat;
        bDetails["longitude"] = _officeLng;
      }

      if (bDetails.isNotEmpty) {
        updateData["businessDetails"] = bDetails;
      }
    }

    return updateData;
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final updateData = _buildUpdateData();
    if (updateData.isEmpty && _selectedBusinessImageFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes detected.')));
        setState(() {
          _isEditing = false;
          _isLoading = false;
          _isAddingBusiness = false;
        });
      }
      return;
    }

    // Commented out OTP logic
    // try {
    //   final authApi = AuthAPI();
    //   final mobile = _profileData?.user.mobileNumber ?? '';
    //   if (mobile.isNotEmpty) {
    //     final response = await authApi.sendOtp(mobile, 'PROFILE');
    //     if (response == null || response['success'] != true) {
    //       if (mounted) {
    //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response?['message'] ?? 'Failed to send OTP')));
    //       }
    //       setState(() => _isLoading = false);
    //       return;
    //     }
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    //   }
    //   setState(() => _isLoading = false);
    //   return;
    // }
    // setState(() => _isLoading = false);
    // _showOtpBottomSheet();
    
    // Save directly without OTP
    await _executeProfileSave();
  }

  Future<void> _executeProfileSave() async {
    setState(() => _isLoading = true);
    try {
      final userId = _profileData!.user.userId;
      final updateData = _buildUpdateData();
      updateData["userId"] = userId;

      // Count existing images (for logging only)
      final existingImages = _profileData?.profile.businessDetails?.businessImages ?? [];

      print('DEV DEBUG - Profile Save Payload: $updateData');
      print('DEV DEBUG - New images count: ${_selectedBusinessImageFiles.length}, existing in DB: ${existingImages.length}');

      dynamic response;
      
      if (_selectedBusinessImageFiles.isEmpty) {
        response = await _profileAPI.updateUserProfile(userId, updateData);
      } else {
        response = await _profileAPI.createUserProfile(
          updateData,
          businessImageFiles: _selectedBusinessImageFiles,
        );
      }

      if (response != null && response['success'] == true) {
        await _fetchProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
          setState(() {
            _isEditing = false;
            _isAddingBusiness = false;
            _selectedBusinessImageFiles.clear();
          });
        }
      } else {
        throw Exception(response?['message'] ?? 'Unknown error');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Future<void> _saveProfile() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final authApi = AuthAPI();
  //     final mobile = _profileData?.user.mobileNumber ?? '';
  //     if (mobile.isNotEmpty) {
  //       final response = await authApi.sendOtp(mobile, 'PROFILE');
  //       if (response == null || response['success'] != true) {
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(response?['message'] ?? 'Failed to send OTP'),
  //             ),
  //           );
  //         }
  //         setState(() => _isLoading = false);
  //         return;
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
  //     }
  //     setState(() => _isLoading = false);
  //     return;
  //   }
  //   setState(() => _isLoading = false);
  //   _showOtpBottomSheet();
  // }
  //
  // Future<void> _executeProfileSave() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final userId = _profileData!.user.userId;
  //     final Map<String, dynamic> updateData = {};
  //
  //     if (_alternateMobileController.text !=
  //         (_profileData!.profile.alternateMobile ?? '')) {
  //       updateData["alternateMobile"] = _alternateMobileController.text;
  //     }
  //     if (_homeLat != 0.0 && _homeLng != 0.0) {
  //       updateData["homeAddress"] = _homeAddressController.text.isNotEmpty
  //           ? _homeAddressController.text
  //           : '${_homeLat.toStringAsFixed(4)}, ${_homeLng.toStringAsFixed(4)}';
  //       updateData["homeLatitude"] = _homeLat;
  //       updateData["homeLongitude"] = _homeLng;
  //     }
  //     if (_officeAddressController.text !=
  //         (_profileData!.profile.officeAddress ?? '')) {
  //       updateData["officeAddress"] = _officeAddressController.text;
  //     }
  //     if (_pincodeController.text != (_profileData!.profile.pincode ?? '')) {
  //       updateData["pincode"] = _pincodeController.text;
  //     }
  //
  //     if (_yearsInCityController.text !=
  //         (_profileData!.profile.yearsInCity ?? '')) {
  //       updateData["yearsInCity"] = _yearsInCityController.text;
  //     }
  //     if (_selectedBusinessVerticalController.text !=
  //         (_profileData!.profile.selectedBusinessVertical ?? '')) {
  //       updateData["selectedBusinessVertical"] =
  //           _selectedBusinessVerticalController.text;
  //     }
  //     if (_familyInformationController.text !=
  //         (_profileData!.profile.familyInformation ?? '')) {
  //       updateData["familyInformation"] = _familyInformationController.text;
  //     }
  //     if (_spouseController.text != (_profileData!.profile.spouse ?? '')) {
  //       updateData["spouse"] = _spouseController.text;
  //     }
  //     if (_childrenController.text != (_profileData!.profile.children ?? '')) {
  //       updateData["children"] = _childrenController.text;
  //     }
  //     if (_petsController.text != (_profileData!.profile.pets ?? '')) {
  //       updateData["pets"] = _petsController.text;
  //     }
  //     if (_hobbiesController.text != (_profileData!.profile.hobbies ?? '')) {
  //       updateData["hobbies"] = _hobbiesController.text;
  //     }
  //     if (_activitiesOrInterestsController.text !=
  //         (_profileData!.profile.activitiesOrInterests ?? '')) {
  //       updateData["activitiesOrInterests"] =
  //           _activitiesOrInterestsController.text;
  //     }
  //
  //     if (_selectedState != null &&
  //         _selectedState != _profileData!.profile.state) {
  //       updateData["state"] = _selectedState!;
  //     }
  //     if (_selectedDistrict != null &&
  //         _selectedDistrict != _profileData!.profile.district) {
  //       updateData["district"] = _selectedDistrict!;
  //     }
  //     if (_selectedTaluka != null &&
  //         _selectedTaluka != _profileData!.profile.assembly) {
  //       updateData["assembly"] = _selectedTaluka!;
  //     }
  //
  //     String selectedWardName = _selectedWardId ?? '';
  //     try {
  //       if (_selectedWardId != null) {
  //         selectedWardName = _allWards
  //             .firstWhere((w) => w.wardId == _selectedWardId)
  //             .wardName;
  //       }
  //     } catch (_) {}
  //
  //     if (_selectedWardId != null &&
  //         selectedWardName.isNotEmpty &&
  //         selectedWardName != _profileData!.profile.ward) {
  //       updateData["ward"] = selectedWardName;
  //     }
  //
  //     if (_profileData!.profile.hasBusiness || _isAddingBusiness) {
  //       if (_isAddingBusiness) {
  //         updateData["hasBusiness"] = true;
  //       }
  //       final Map<String, dynamic> bDetails = {};
  //
  //       // 1. Copy all existing business details first so they aren't wiped out
  //       if (_profileData!.profile.businessDetails != null) {
  //         final existing = _profileData!.profile.businessDetails!;
  //         if (existing.gstNumber != null)
  //           bDetails["gstNumber"] = existing.gstNumber;
  //         if (existing.businessName != null)
  //           bDetails["businessName"] = existing.businessName;
  //         if (existing.businessType != null)
  //           bDetails["businessType"] = existing.businessType;
  //         if (existing.annualTurnover != null)
  //           bDetails["annualTurnover"] = existing.annualTurnover;
  //         if (existing.businessAddress != null)
  //           bDetails["address"] = existing.businessAddress;
  //         if (existing.businessImages != null)
  //           bDetails["businessImages"] = existing.businessImages;
  //         if (existing.latitude != null)
  //           bDetails["latitude"] = existing.latitude;
  //         if (existing.longitude != null)
  //           bDetails["longitude"] = existing.longitude;
  //         if (existing.ward != null) bDetails["ward"] = existing.ward;
  //         if (existing.yearsInBusiness != null)
  //           bDetails["yearsInBusiness"] = existing.yearsInBusiness;
  //         if (existing.previousJobs != null)
  //           bDetails["previousJobs"] = existing.previousJobs;
  //       }
  //
  //       // 2. Override with new values if changed
  //       if (selectedWardName.isNotEmpty) {
  //         bDetails["ward"] = selectedWardName;
  //       }
  //
  //       if (_businessNameController.text.isNotEmpty) {
  //         bDetails["businessName"] = _businessNameController.text;
  //       }
  //
  //       final newBusinessType =
  //           "${_selectedSector?['sectorName'] ?? ''} | ${_selectedSubSector?['subSectorName'] ?? ''} | ${_selectedTag?['tagName'] ?? ''}";
  //       if (newBusinessType.trim() != '|  |') {
  //         bDetails["businessType"] = newBusinessType;
  //         updateData["businessCategory"] = _selectedSector?['sectorName'] ?? '';
  //         updateData["businessSubCategory"] =
  //             _selectedSubSector?['subSectorName'] ?? '';
  //         updateData["businessTag"] = _selectedTag?['tagName'] ?? '';
  //       }
  //
  //       if (_officeLat != 0.0 && _officeLng != 0.0) {
  //         final newAddress = _officeAddressController.text.isNotEmpty
  //             ? _officeAddressController.text
  //             : '${_officeLat.toStringAsFixed(4)}, ${_officeLng.toStringAsFixed(4)}';
  //         bDetails["address"] = newAddress;
  //         bDetails["latitude"] = _officeLat;
  //         bDetails["longitude"] = _officeLng;
  //       }
  //
  //       if (_selectedBusinessImageFiles.isNotEmpty) {
  //         for (int i = 0; i < _selectedBusinessImageFiles.length; i++) {
  //           final file = _selectedBusinessImageFiles[i];
  //           final bytes = file.readAsBytesSync();
  //           final base64Image = dart_convert.base64Encode(bytes);
  //           bDetails["businessImage${i + 1}"] = {
  //             "fileName": file.path.split('/').last,
  //             "mimeType": "image/${file.path.split('.').last}",
  //             "image":
  //                 "data:image/${file.path.split('.').last};base64,$base64Image",
  //           };
  //         }
  //       }
  //
  //       if (bDetails.isNotEmpty) {
  //         updateData["businessDetails"] = bDetails;
  //       }
  //     }
  //
  //     if (updateData.isEmpty) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
  //         setState(() {
  //           _isEditing = false;
  //           _isLoading = false;
  //           _isAddingBusiness = false;
  //         });
  //       }
  //       return;
  //     }
  //
  //     dynamic response;
  //
  //     print('DEV DEBUG - Profile Save Payload: $updateData');
  //
  //     updateData["userId"] = userId;
  //     // Always use createUserProfile (which uses postMultipart) for upserting
  //     // because it handles large payloads better than patch (application/json)
  //     response = await _profileAPI.createUserProfile(updateData);
  //
  //     if (response != null && response['success'] == true) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Profile updated successfully')),
  //         );
  //         setState(() {
  //           _isEditing = false;
  //           _isAddingBusiness = false;
  //         });
  //         SessionManager.profileUpdateNotifier.value++;
  //         _fetchProfile();
  //       }
  //     } else {
  //       throw Exception(response?['message'] ?? "Failed to update profile");
  //     }
  //   } catch (e) {
  //     print('DEV DEBUG - Profile Save Exception: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Error: $e')));
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  Future<void> _deleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final userId = _profileData!.user.userId;
        final response = await _profileAPI.deleteUserProfile(userId);

        if (response != null && response['success'] == true) {
          await SessionManager.clearSession();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } else {
          throw Exception(response?['message'] ?? "Failed to delete profile");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : Colors.grey.shade200.withValues(alpha: 0.5),
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
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayValue = (value == null || value.isEmpty || value == "null")
        ? "Not Updated"
        : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.teal),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: displayValue == "Not Updated"
                        ? Colors.grey.shade400
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditRow(
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Icon(icon, size: 20, color: Colors.teal),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                helperText: helperText,
                helperMaxLines: 2,
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicListEditor(
    String label,
    List<String> items,
    TextEditingController textController, {
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Icon(icon, size: 20, color: Colors.teal),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                if (items.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: items.map((item) {
                      return Chip(
                        label: Text(item, style: const TextStyle(fontSize: 12)),
                        onDeleted: _isEditing
                            ? () {
                                setState(() {
                                  items.remove(item);
                                });
                              }
                            : null,
                        deleteIconColor: Colors.red.shade400,
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.teal.shade50,
                      );
                    }).toList(),
                  )
                else if (!_isEditing)
                  Text(
                    "Not Updated",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                if (items.isNotEmpty && _isEditing) const SizedBox(height: 8),
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'Add new...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                          ),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              setState(() {
                                items.add(val.trim());
                                textController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.teal, size: 32),
                        onPressed: () {
                          if (textController.text.trim().isNotEmpty) {
                            setState(() {
                              items.add(textController.text.trim());
                              textController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Icon(icon, size: 20, color: Colors.teal),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: DropdownButtonFormField<T>(
              isExpanded: true,
              value: items.contains(value) ? value : null,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUdyamiMemberCompletenessCard(ThemeData theme, bool isDark) {
    int percentage = 0;
    if (_udyamiMemberData != null) {
      percentage = UdyamiMemberModel(
        _udyamiMemberData!,
      ).calculateCompletionPercentage();
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UdyamiMemberFormScreen(
              existingData: _udyamiMemberData ?? {},
              currentUser: _profileData?.user,
              fullProfile: _profileData,
            ),
          ),
        );
        if (result == true) {
          _fetchProfile(); // Refresh on successful update
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: percentage == 100
                ? [Colors.teal, Colors.tealAccent.shade700]
                : [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Udyami Member Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Icon(
                  percentage == 100
                      ? Icons.check_circle
                      : Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              percentage == 100
                  ? "Your Udyami Profile is complete!"
                  : "Complete your Udyami Profile to unlock exclusive features.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "$percentage%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Adapts seamlessly to light/dark mode
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          const ThemeToggleButton(),
          if (_profileData != null)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit_outlined,
                color: Colors.teal,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    _isAddingBusiness = false;
                    _populateControllers();
                  }
                });
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initData,
        child: _isLoading
            ? const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  ),
                ),
              )
            : _profileData == null
            ? const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 400,
                  child: Center(child: Text("Could not load profile")),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Udyami Member Completeness Card
                        _buildUdyamiMemberCompletenessCard(theme, isDark),
                        const SizedBox(height: 16),

                        // Profile Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade900
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.transparent
                                    : Colors.grey.shade200.withValues(
                                        alpha: 0.5,
                                      ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _isEditing ? _pickAndUploadImage : null,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 48,
                                      backgroundColor: Colors.teal.withValues(
                                        alpha: 0.1,
                                      ),
                                      backgroundImage:
                                          _selectedImageFile != null
                                          ? FileImage(_selectedImageFile!)
                                          : (() {
                                              final img = _profileData
                                                  ?.profile
                                                  .profileImage;
                                              if (img == null || img.isEmpty)
                                                return null;
                                              if (img.startsWith('data:')) {
                                                final base64Str = img
                                                    .split(',')
                                                    .last;
                                                return MemoryImage(
                                                      dart_convert.base64Decode(
                                                        base64Str,
                                                      ),
                                                    )
                                                    as ImageProvider;
                                              }
                                              return NetworkImage(img)
                                                  as ImageProvider;
                                            })(),
                                      child:
                                          (_selectedImageFile == null &&
                                              _profileData
                                                      ?.profile
                                                      .profileImage ==
                                                  null)
                                          ? const Icon(
                                              Icons.person,
                                              size: 48,
                                              color: Colors.teal,
                                            )
                                          : null,
                                    ),
                                    if (_isEditing)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.teal,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.grey.shade900
                                                  : Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    if (_isUploadingImage)
                                      Positioned.fill(
                                        child: CircleAvatar(
                                          radius: 48,
                                          backgroundColor: Colors.black
                                              .withValues(alpha: 0.4),
                                          child: const SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                (_profileData!.user.username != null && _profileData!.user.username!.isNotEmpty)
                                    ? _profileData!.user.username!
                                    : _profileData!.user.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _profileData!.user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                children: [
                                  ..._buildRoleChips(
                                    _profileData!.user,
                                    isDark,
                                  ),
                                  // if (_profileData!.user.isActive != null)
                                  //   Container(
                                  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  //     decoration: BoxDecoration(
                                  //         color: _profileData!.user.isActive == true ? Colors.green.shade50 : Colors.red.shade50,
                                  //         borderRadius: BorderRadius.circular(20),
                                  //         border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200)
                                  //     ),
                                  //     child: Text(
                                  //       _profileData!.user.isActive == true ? 'Active' : 'Inactive',
                                  //       style: TextStyle(
                                  //         color: _profileData!.user.isActive == true ? Colors.green.shade800 : Colors.red.shade800,
                                  //         fontWeight: FontWeight.bold,
                                  //         fontSize: 12,
                                  //       ),
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Personal Details Section
                        _buildSectionCard(
                          title: 'Personal Information',
                          children: [
                            _isEditing
                                ? _buildEditRow(
                                    'Username',
                                    _usernameController,
                                    icon: Icons.person_outline,
                                  )
                                : _buildDetailRow(
                                    'Username',
                                    _profileData!.user.username,
                                    icon: Icons.person_outline,
                                  ),
                            _isEditing
                                ? _buildEditRow(
                                    'Email Address',
                                    _emailController,
                                    icon: Icons.email_outlined,
                                  )
                                : _buildDetailRow(
                                    'Email Address',
                                    _profileData!.user.email,
                                    icon: Icons.email_outlined,
                                  ),
                            _isEditing
                                ? _buildEditRow(
                                    'Primary Mobile',
                                    _mobileController,
                                    icon: Icons.phone_outlined,
                                  )
                                : _buildDetailRow(
                                    'Primary Mobile',
                                    _profileData!.user.mobileNumber,
                                    icon: Icons.phone_outlined,
                                  ),
                            _isEditing
                                ? _buildEditRow(
                                    'Alternate Mobile',
                                    _alternateMobileController,
                                    icon: Icons.phone_android_outlined,
                                  )
                                : _buildDetailRow(
                                    'Alternate Mobile',
                                    _profileData!.profile.alternateMobile,
                                    icon: Icons.phone_android_outlined,
                                  ),
                          ],
                        ),

                        // Location Details Section
                        _buildSectionCard(
                          title: 'Ward Location',
                          children: [
                            if (!_isEditing) ...[
                              _buildDetailRow(
                                'State',
                                _profileData!.profile.state,
                                icon: Icons.map_outlined,
                              ),
                              _buildDetailRow(
                                'District',
                                _profileData!.profile.district,
                                icon: Icons.location_city_outlined,
                              ),
                              _buildDetailRow(
                                'Assembly',
                                _profileData!.profile.assembly,
                                icon: Icons.account_balance_outlined,
                              ),
                              _buildDetailRow(
                                'Area',
                                _profileData!.profile.ward != null
                                    ? (_allWards
                                              .where(
                                                (w) =>
                                                    w.wardId ==
                                                    _profileData!.profile.ward,
                                              )
                                              .isNotEmpty
                                          ? _allWards
                                                .firstWhere(
                                                  (w) =>
                                                      w.wardId ==
                                                      _profileData!
                                                          .profile
                                                          .ward,
                                                )
                                                .wardName
                                          : _profileData!.profile.ward)
                                    : null,
                                icon: Icons.home_work_outlined,
                              ),
                            ] else ...[
                              _buildDropdownRow<String>(
                                label: 'State',
                                value: _selectedState,
                                items: _states,
                                itemLabel: (s) => s,
                                onChanged: _onStateChanged,
                                icon: Icons.map_outlined,
                              ),
                              _buildDropdownRow<String>(
                                label: 'District',
                                value: _selectedDistrict,
                                items: _districts,
                                itemLabel: (d) => d,
                                onChanged: _onDistrictChanged,
                                icon: Icons.location_city_outlined,
                              ),
                              _buildDropdownRow<String>(
                                label: 'Taluka',
                                value: _selectedTaluka,
                                items: _talukas,
                                itemLabel: (t) => t,
                                onChanged: _onTalukaChanged,
                                icon: Icons.account_balance_outlined,
                              ),
                              _buildDropdownRow<String>(
                                label: 'Area',
                                value: _selectedWardId,
                                items: _wards.map((w) => w.wardId).toList(),
                                itemLabel: (id) => _wards
                                    .firstWhere((w) => w.wardId == id)
                                    .wardName,
                                onChanged: (val) {
                                  setState(() => _selectedWardId = val);
                                },
                                icon: Icons.home_work_outlined,
                              ),
                            ],
                            _isEditing
                                ? _buildEditRow(
                                    'Pincode',
                                    _pincodeController,
                                    icon: Icons.pin_drop_outlined,
                                  )
                                : _buildDetailRow(
                                    'Pincode',
                                    _profileData!.profile.pincode,
                                    icon: Icons.pin_drop_outlined,
                                  ),

                            const SizedBox(height: 8),
                            _isEditing
                                ? _buildLocationButton(
                                    'Select Home Location',
                                    _homeAddressController,
                                    true,
                                  )
                                : _buildDetailRow(
                                    'Home Address',
                                    _homeAddressController.text.isNotEmpty
                                        ? _homeAddressController.text
                                        : 'Not Updated',
                                    icon: Icons.home,
                                  ),
                          ],
                        ),

                        // Family & Additional Details Section
                        _buildSectionCard(
                          title: 'Family & Additional Details',
                          children: [
                            _isEditing
                                ? _buildEditRow(
                                    'Years in City',
                                    _yearsInCityController,
                                    icon: Icons.access_time,
                                  )
                                : _buildDetailRow(
                                    'Years in City',
                                    _profileData!.profile.yearsInCity,
                                    icon: Icons.access_time,
                                  ),
                            _isEditing
                                ? _buildEditRow(
                                    'Family Count',
                                    _familyCountController,
                                    icon: Icons.family_restroom,
                                    keyboardType: TextInputType.number,
                                  )
                                : _buildDetailRow(
                                    'Family Count',
                                    _profileData!.profile.familyCount?.toString(),
                                    icon: Icons.family_restroom,
                                  ),
                            _isEditing
                                ? _buildEditRow(
                                    'Spouse',
                                    _spouseController,
                                    icon: Icons.favorite,
                                  )
                                : _buildDetailRow(
                                    'Spouse',
                                    _profileData!.profile.spouse,
                                    icon: Icons.favorite,
                                  ),
                            _buildDynamicListEditor(
                              'Children',
                              _childrenList,
                              _newChildController,
                              icon: Icons.child_care,
                            ),
                            _isEditing
                                ? _buildEditRow(
                                    'Pets',
                                    _petsController,
                                    icon: Icons.pets,
                                  )
                                : _buildDetailRow(
                                    'Pets',
                                    _profileData!.profile.pets,
                                    icon: Icons.pets,
                                  ),
                            _buildDynamicListEditor(
                              'Hobbies',
                              _hobbiesList,
                              _newHobbyController,
                              icon: Icons.sports_esports,
                            ),
                            _buildDynamicListEditor(
                              'Activities/Interests',
                              _interestsList,
                              _newInterestController,
                              icon: Icons.interests,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Business Details Section
                        if (_profileData!.profile.hasBusiness ||
                            _isAddingBusiness) ...[
                          Builder(
                            builder: (context) {
                              print(
                                "DEV DEBUG - UI BUILD: Rendering Business Information section",
                              );
                              print(
                                "DEV DEBUG - UI BUILD: hasBusiness = ${_profileData!.profile.hasBusiness}",
                              );
                              print(
                                "DEV DEBUG - UI BUILD: businessDetails = ${_profileData!.profile.businessDetails}",
                              );
                              print(
                                "DEV DEBUG - UI BUILD: businessName = ${_profileData!.profile.businessDetails?.businessName}",
                              );
                              print(
                                "DEV DEBUG - UI BUILD: businessAddress = ${_profileData!.profile.businessDetails?.businessAddress}",
                              );
                              print(
                                "DEV DEBUG - UI BUILD: businessCategory = ${_profileData!.profile.businessCategory}",
                              );
                              print(
                                "DEV DEBUG - UI BUILD: businessType = ${_profileData!.profile.businessDetails?.businessType}",
                              );
                              print(
                                "DEV DEBUG - UI BUILD: businessImages = ${_profileData!.profile.businessDetails?.businessImages}",
                              );
                              return const SizedBox.shrink();
                            },
                          ),
                          _buildSectionCard(
                            title: 'Business Information',
                            children: [
                              if (!_isEditing) ...[
                                _buildDetailRow(
                                  'Business Name',
                                  _profileData
                                      ?.profile
                                      .businessDetails
                                      ?.businessName,
                                  icon: Icons.store_outlined,
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (context) {
                                    String category =
                                        _profileData!
                                            .profile
                                            .businessCategory ??
                                        "Not Updated";
                                    String subCategory =
                                        _profileData!
                                            .profile
                                            .businessSubCategory ??
                                        "Not Updated";
                                    String tag =
                                        _profileData!.profile.businessTag ??
                                        "Not Updated";
                                    final bType = _profileData!
                                        .profile
                                        .businessDetails
                                        ?.businessType;
                                    if (bType != null && bType.isNotEmpty) {
                                      final parts = bType
                                          .split(RegExp(r'[|-]'))
                                          .map((e) => e.trim())
                                          .toList();
                                      if (parts.isNotEmpty) category = parts[0];
                                      if (parts.length > 1)
                                        subCategory = parts[1];
                                      if (parts.length > 2) tag = parts[2];
                                    }
                                    return Column(
                                      children: [
                                        _buildDetailRow(
                                          'Business Category',
                                          category,
                                          icon: Icons.category_outlined,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildDetailRow(
                                          'Business Sub-Category',
                                          subCategory,
                                          icon: Icons.account_tree_outlined,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildDetailRow(
                                          'Business Sub-Sub-Category',
                                          tag,
                                          icon: Icons.local_offer_outlined,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'State',
                                  _selectedBusinessState ?? 'Not Updated',
                                  icon: Icons.map_outlined,
                                ),
                                _buildDetailRow(
                                  'District',
                                  _selectedBusinessDistrict ?? 'Not Updated',
                                  icon: Icons.location_city_outlined,
                                ),
                                _buildDetailRow(
                                  'Taluk',
                                  _selectedBusinessTaluka ?? 'Not Updated',
                                  icon: Icons.terrain_outlined,
                                ),
                                _buildDetailRow(
                                  'Area / Village',
                                  _businessWards.any((w) => w.wardId == _selectedBusinessWardId)
                                      ? _businessWards.firstWhere((w) => w.wardId == _selectedBusinessWardId).wardName
                                      : 'Not Updated',
                                  icon: Icons.map_outlined,
                                ),
                                _buildDetailRow(
                                  'Business Address',
                                  _officeAddressController.text.isNotEmpty
                                      ? _officeAddressController.text
                                      : 'Not Updated',
                                  icon: Icons.map_outlined,
                                ),
                              ] else ...[
                                _buildEditRow(
                                  'Business Name',
                                  _businessNameController,
                                  icon: Icons.store_outlined,
                                ),
                                if (_isLoadingSectors)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else ...[
                                  _buildDropdownRow<Map<String, dynamic>>(
                                    label: 'Business Category',
                                    value: _selectedSector,
                                    items: _sectors
                                        .cast<Map<String, dynamic>>(),
                                    itemLabel: (s) => s['sectorName'] ?? '',
                                    onChanged: _onSectorChanged,
                                    icon: Icons.category_outlined,
                                  ),
                                  _buildDropdownRow<Map<String, dynamic>>(
                                    label: 'Business Sub-Category',
                                    value: _selectedSubSector,
                                    items: _subSectors
                                        .cast<Map<String, dynamic>>(),
                                    itemLabel: (s) => s['subSectorName'] ?? '',
                                    onChanged: _onSubSectorChanged,
                                    icon: Icons.account_tree_outlined,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildDropdownRow<Map<String, dynamic>>(
                                          label: 'Business Sub-Sub-Category',
                                          value: _selectedSubSubSector,
                                          items: _subSubSectors.cast<Map<String, dynamic>>(),
                                          itemLabel: (s) => s['sourceService'] ?? s['subSubSectorName'] ?? s['productDescription'] ?? '',
                                          onChanged: _onSubSubSectorChanged,
                                          icon: Icons.local_offer_outlined,
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
                                ],
                                const SizedBox(height: 12),
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Same as personal area', style: TextStyle(fontSize: 14)),
                                  value: _sameAsPersonalArea,
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  controlAffinity: ListTileControlAffinity.leading,
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
                                _buildDropdownRow<String>(
                                  label: 'State',
                                  value: _selectedBusinessState,
                                  items: _states,
                                  itemLabel: (s) => s,
                                  onChanged: _sameAsPersonalArea ? (s) {} : _onBusinessStateChanged,
                                  icon: Icons.map_outlined,
                                ),
                                _buildDropdownRow<String>(
                                  label: 'District',
                                  value: _selectedBusinessDistrict,
                                  items: _businessDistricts,
                                  itemLabel: (s) => s,
                                  onChanged: _sameAsPersonalArea || _selectedBusinessState == null ? (s) {} : _onBusinessDistrictChanged,
                                  icon: Icons.location_city_outlined,
                                ),
                                _buildDropdownRow<String>(
                                  label: 'Taluk',
                                  value: _selectedBusinessTaluka,
                                  items: _businessTalukas,
                                  itemLabel: (s) => s,
                                  onChanged: _sameAsPersonalArea || _selectedBusinessDistrict == null ? (s) {} : _onBusinessTalukaChanged,
                                  icon: Icons.terrain_outlined,
                                ),
                                _buildDropdownRow<WardModel>(
                                  label: 'Area / Village',
                                  value: _businessWards.any((w) => w.wardId == _selectedBusinessWardId)
                                      ? _businessWards.firstWhere((w) => w.wardId == _selectedBusinessWardId)
                                      : null,
                                  items: _businessWards,
                                  itemLabel: (w) => w.wardName,
                                  onChanged: _sameAsPersonalArea || _selectedBusinessTaluka == null ? (w) {} : (WardModel? w) => _onBusinessWardChanged(w?.wardId),
                                  icon: Icons.map_outlined,
                                ),
                                const SizedBox(height: 12),
                                _buildLocationButton(
                                  'Select Business Location',
                                  _officeAddressController,
                                  false,
                                ),
                              ],

                              Builder(
                                builder: (context) {
                                  final hasRemoteImages =
                                      _profileData!
                                          .profile
                                          .businessDetails
                                          ?.businessImages
                                          ?.isNotEmpty ==
                                      true;
                                  final hasLocalImages =
                                      _selectedBusinessImageFiles.isNotEmpty;

                                  final remoteCount = _profileData!.profile.businessDetails?.businessImages?.length ?? 0;
                                  final localCount = _selectedBusinessImageFiles.length;
                                  print(
                                    'DEV DEBUG - UI IMAGES BLOCK: hasRemote=$hasRemoteImages(count=$remoteCount) hasLocal=$hasLocalImages(count=$localCount)',
                                  );

                                  if (hasRemoteImages || hasLocalImages) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.image_outlined,
                                              size: 20,
                                              color: Colors.teal,
                                            ),
                                            const SizedBox(width: 14),
                                            Text(
                                              'Business Images',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: hasLocalImages
                                                ? _selectedBusinessImageFiles
                                                      .length
                                                : _profileData!
                                                      .profile
                                                      .businessDetails!
                                                      .businessImages!
                                                      .length,
                                            itemBuilder: (context, index) {
                                              ImageProvider? provider;
                                              if (hasLocalImages) {
                                                print(
                                                  'DEV DEBUG - UI IMAGE[$index]: source=LOCAL_FILE path=${_selectedBusinessImageFiles[index].path}',
                                                );
                                                provider = FileImage(
                                                  _selectedBusinessImageFiles[index],
                                                );
                                              } else {
                                                final imgStr = _profileData!
                                                    .profile
                                                    .businessDetails!
                                                    .businessImages![index];
                                                final preview = imgStr.length > 80
                                                    ? '${imgStr.substring(0, 80)}...'
                                                    : imgStr;
                                                if (imgStr.startsWith('data:')) {
                                                  print(
                                                    'DEV DEBUG - UI IMAGE[$index]: source=BASE64 length=${imgStr.length} preview=$preview',
                                                  );
                                                  provider = MemoryImage(
                                                    dart_convert.base64Decode(
                                                      imgStr.split(',').last,
                                                    ),
                                                  );
                                                } else if (imgStr.isNotEmpty) {
                                                  print(
                                                    'DEV DEBUG - UI IMAGE[$index]: source=NETWORK url=$imgStr',
                                                  );
                                                  provider = NetworkImage(imgStr);
                                                } else {
                                                  print(
                                                    'DEV DEBUG - UI IMAGE[$index]: source=EMPTY — no provider',
                                                  );
                                                }
                                              }

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: isDark
                                                      ? Colors.grey.shade800
                                                      : Colors.grey.shade200,
                                                  image: provider != null
                                                      ? DecorationImage(
                                                          image: provider,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                                ),
                                                child: provider == null
                                                    ? const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                      )
                                                    : null,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),

                              if (_isEditing) ...[
                                const SizedBox(height: 16),
                                Builder(
                                  builder: (context) {
                                    final existingCount =
                                        _profileData
                                            ?.profile
                                            .businessDetails
                                            ?.businessImages
                                            ?.length ??
                                        0;
                                    final isFull = existingCount >= 3;
                                    return SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isFull
                                              ? Colors.grey
                                              : Colors.teal,
                                          side: BorderSide(
                                            color: isFull
                                                ? Colors.grey.shade400
                                                : Colors.teal.shade300,
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
                                        onPressed:
                                            (_isUploadingBusinessImages ||
                                                isFull)
                                            ? null
                                            : _pickAndUploadBusinessImages,
                                        icon: _isUploadingBusinessImages
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Icon(
                                                isFull
                                                    ? Icons.check_circle_outline
                                                    : Icons
                                                          .add_photo_alternate_outlined,
                                              ),
                                        label: Text(
                                          _isUploadingBusinessImages
                                              ? 'Uploading...'
                                              : isFull
                                              ? 'Max 3 images uploaded'
                                              : 'Add Business Image ($existingCount/3)',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ] else ...[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditing = true;
                                _isAddingBusiness = true;
                                _populateControllers();
                              });
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 2,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context).colorScheme.surface
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add_business_rounded,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Add Business Details',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Set up your business profile to connect with others.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Sector Network Card
                        if (_profileData!.profile.hasBusiness && !_isEditing)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MySectorsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal.shade700,
                                    Colors.teal.shade500,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.groups,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'My Sector Teams',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Connect with members in your business sector',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        if (_isEditing)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: theme.colorScheme.surface,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: _saveProfile,
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: _deleteProfile,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildRoleChips(UserModel user, bool isDark) {
    List<Widget> chips = [];

    // 1. Membership tier fallback (if they don't have ward roles, or in addition to)
    if (user.isPrime == true) {
      chips.add(
        _buildRoleChip(
          'Prime Member',
          Icons.workspace_premium_rounded,
          Colors.orange,
          isDark,
        ),
      );
    } else if (user.isBasic == true) {
      chips.add(
        _buildRoleChip(
          'Basic Member',
          Icons.verified_rounded,
          Colors.teal,
          isDark,
        ),
      );
    } else if (user.roles.isEmpty ||
        user.roles.every((r) => r.roleName == 'member')) {
      chips.add(
        _buildRoleChip('Member', Icons.person_rounded, Colors.grey, isDark),
      );
    }

    // 2. Map through specific ward roles
    for (var r in user.roles) {
      if (r.roleName == 'district_head' || r.roleName == 'DistrictHead') {
        chips.add(
          _buildRoleChip(
            'District Head',
            Icons.admin_panel_settings_rounded,
            Colors.blue,
            isDark,
          ),
        );
      } else if (r.roleName == 'taluka_head' || r.roleName == 'TalukHead') {
        chips.add(
          _buildRoleChip(
            'Taluka Head',
            Icons.admin_panel_settings_rounded,
            Colors.indigo,
            isDark,
          ),
        );
      } else if (r.roleName == 'ward_chairman' ||
          r.roleName == 'WardChairman') {
        chips.add(
          _buildRoleChip(
            'Ward Chairman',
            Icons.admin_panel_settings_rounded,
            Colors.purple,
            isDark,
          ),
        );
      } else if (r.roleName == 'circle_leader' ||
          r.roleName == 'CircleLeader') {
        chips.add(
          _buildRoleChip(
            'Circle Leader',
            Icons.group_work_rounded,
            Colors.deepOrange,
            isDark,
          ),
        );
      } else if (r.roleName == 'sector_head' || r.roleName == 'SectorHead') {
        chips.add(
          _buildRoleChip(
            'Sector Head',
            Icons.account_tree_rounded,
            Colors.teal,
            isDark,
          ),
        );
      } else if (r.roleName == 'ucn_member' || r.roleName == 'UcnMember') {
        chips.add(
          _buildRoleChip(
            'UCN Member',
            Icons.business_center_rounded,
            Colors.brown,
            isDark,
          ),
        );
      } else if (r.roleName != 'member' && r.roleName != 'user') {
        // Any other special role
        String roleText = r.role ?? r.roleName;
        String assemblyName = _profileData?.profile.assembly ?? '';
        assemblyName = assemblyName.replaceAll(RegExp(r'\s*Assembly\s*', caseSensitive: false), '').trim();
        
        if (assemblyName.isNotEmpty) {
          roleText = roleText.replaceAll(RegExp(r'Assembly', caseSensitive: false), assemblyName);
        }
        
        // Ensure "Assembly" word is removed even if we don't have a specific name
        if (roleText.toLowerCase().contains('assembly')) {
           roleText = roleText.replaceAll(RegExp(r'\s*Assembly\s*', caseSensitive: false), '').trim();
        }

        chips.add(
          _buildRoleChip(
            roleText,
            Icons.badge_rounded,
            Colors.blueGrey,
            isDark,
          ),
        );
      }
    }

    return chips;
  }

  Widget _buildRoleChip(
    String label,
    IconData icon,
    MaterialColor color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color.shade700),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
