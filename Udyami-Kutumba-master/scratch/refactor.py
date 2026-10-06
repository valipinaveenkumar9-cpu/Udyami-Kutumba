import sys, re

path = 'd:\\DigiNik\\Apps\\udyamikutumba\\lib\\features\\profile\\presentation\\profile_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

replacement = '''
  Map<String, dynamic> _buildUpdateData() {
    final Map<String, dynamic> updateData = {};

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
      updateData["yearsInCity"] = _yearsInCityController.text;
    }
    if (_selectedBusinessVerticalController.text != (_profileData!.profile.selectedBusinessVertical ?? '')) {
      updateData["selectedBusinessVertical"] = _selectedBusinessVerticalController.text;
    }
    if (_familyInformationController.text != (_profileData!.profile.familyInformation ?? '')) {
      updateData["familyInformation"] = _familyInformationController.text;
    }
    if (_spouseController.text != (_profileData!.profile.spouse ?? '')) {
      updateData["spouse"] = _spouseController.text;
    }
    if (_childrenController.text != (_profileData!.profile.children ?? '')) {
      updateData["children"] = _childrenController.text;
    }
    if (_petsController.text != (_profileData!.profile.pets ?? '')) {
      updateData["pets"] = _petsController.text;
    }
    if (_hobbiesController.text != (_profileData!.profile.hobbies ?? '')) {
      updateData["hobbies"] = _hobbiesController.text;
    }
    if (_activitiesOrInterestsController.text != (_profileData!.profile.activitiesOrInterests ?? '')) {
      updateData["activitiesOrInterests"] = _activitiesOrInterestsController.text;
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
        if (existing.businessImages != null) bDetails["businessImages"] = existing.businessImages;
        if (existing.latitude != null) bDetails["latitude"] = existing.latitude;
        if (existing.longitude != null) bDetails["longitude"] = existing.longitude;
        if (existing.ward != null) bDetails["ward"] = existing.ward;
        if (existing.yearsInBusiness != null) bDetails["yearsInBusiness"] = existing.yearsInBusiness;
        if (existing.previousJobs != null) bDetails["previousJobs"] = existing.previousJobs;
      }

      if (selectedWardName.isNotEmpty) {
        bDetails["ward"] = selectedWardName;
      }
      if (_businessNameController.text.isNotEmpty) {
        bDetails["businessName"] = _businessNameController.text;
      }

      final newBusinessType = "${_selectedSector?['sectorName'] ?? ''} | ${_selectedSubSector?['subSectorName'] ?? ''} | ${_selectedTag?['tagName'] ?? ''}";
      if (newBusinessType.trim() != '|  |') {
        bDetails["businessType"] = newBusinessType;
        updateData["businessCategory"] = _selectedSector?['sectorName'] ?? '';
        updateData["businessSubCategory"] = _selectedSubSector?['subSectorName'] ?? '';
        updateData["businessTag"] = _selectedTag?['tagName'] ?? '';
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

    try {
      final authApi = AuthAPI();
      final mobile = _profileData?.user.mobileNumber ?? '';
      if (mobile.isNotEmpty) {
        final response = await authApi.sendOtp(mobile, 'PROFILE');
        if (response == null || response['success'] != true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response?['message'] ?? 'Failed to send OTP')));
          }
          setState(() => _isLoading = false);
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
      }
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = false);
    _showOtpBottomSheet();
  }

  Future<void> _executeProfileSave() async {
    setState(() => _isLoading = true);
    List<File> tempFiles = [];
    try {
      final userId = _profileData!.user.userId;
      final updateData = _buildUpdateData();
      updateData["userId"] = userId;

      List<File> allImageFiles = [];
      if (_selectedBusinessImageFiles.isNotEmpty) {
        final existingImages = _profileData?.profile.businessDetails?.businessImages ?? [];
        if (existingImages.isNotEmpty) {
          final tempDir = await Directory.systemTemp.createTemp('biz_img_');
          for (int i = 0; i < existingImages.length; i++) {
            final imgStr = existingImages[i];
            final base64Data = imgStr.contains(',') ? imgStr.split(',').last : imgStr;
            final bytes = dart_convert.base64Decode(base64Data);
            final tempFile = File('${tempDir.path}/existing_$i.jpg');
            await tempFile.writeAsBytes(bytes);
            tempFiles.add(tempFile);
            allImageFiles.add(tempFile);
          }
        }
        allImageFiles.addAll(_selectedBusinessImageFiles);
      }

      print('DEV DEBUG - Profile Save Payload: $updateData');

      final response = await _profileAPI.createUserProfile(
        updateData,
        businessImageFiles: allImageFiles.isNotEmpty ? allImageFiles : null,
      );

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
      for (var f in tempFiles) {
        if (await f.exists()) await f.delete();
      }
    }
  }
'''

def remove_function(code, name):
    idx = code.find(f'Future<void> {name}() async {{')
    if idx == -1: return code
    depth = 0
    started = False
    for i in range(idx, len(code)):
        if code[i] == '{':
            depth += 1
            started = True
        elif code[i] == '}':
            depth -= 1
            if started and depth == 0:
                return code[:idx] + code[i+1:]
    return code

code = remove_function(code, '_executeProfileSave')
idx = code.find('Future<void> _saveProfile() async {')
if idx != -1:
    code = remove_function(code, '_saveProfile')
    code = code[:idx] + replacement + code[idx:]
else:
    print("Could not find _saveProfile!")
    sys.exit(1)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
print('Done!')
