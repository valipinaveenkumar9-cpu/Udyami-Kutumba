const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(_highestRole == 'super_admin'[\s\S]*?if \(mounted\) setState\(\(\) => _isLoading = false\);/;

const replacement = `if (_highestRole == 'super_admin' || _highestRole.contains('state')) {
           print('DEBUG: [Super Admin / State] Triggering APIs...');
           try {
             final usersRes = await _api.fetchUsersSuperAdmin();
             _totalUsers = _countUsersSafe(usersRes);
             _usersList = _extractList(usersRes, 'users');
             if (usersRes != null && usersRes['users'] != null) {
               _allHeadsCount = (usersRes['users'] as List).where((u) {
                 final roles = u['roles'] as List?;
                 return roles != null && roles.any((r) => r.toString().toLowerCase().contains('head') || r.toString().toLowerCase().contains('chairman'));
               }).length;
             }
           } catch (_) {}
           _calculatePlans(_usersList);
           try { _channelPartners = _countData(await _api.fetchChannelPartners()); } catch (_) {}
           try { 
             final distRes = await _api.fetchAllDistricts();
             _districtsList = _extractList(distRes, 'data');
             _allDistrictsCount = _districtsList.length; 
           } catch (_) {}
           print('DEBUG: [Super Admin] Data Fetched -> Users: ${_totalUsers}, Districts: ${_allDistrictsCount}, Heads: ${_allHeadsCount}, CPs: ${_channelPartners}');
           
        } else if (_highestRole.contains('district')) {
           print('DEBUG: [District Head] Triggering APIs for District: ${_districtName} (ID: ${districtId})...');
           if (_districtName.isNotEmpty) {
             try {
               final usersRes = await _api.fetchUsersByDistrict(_districtName);
               _usersList = _extractList(usersRes, 'users');
               _totalUsers = _countUsersSafe(usersRes);
             } catch (_) {}
           }
           if (districtId != null && _totalUsers == 0) {
             try {
               final searchRes = await _api.searchMembers({'districtId': districtId, 'limit': 5000});
               final sList = _extractList(searchRes, 'data');
               if (sList.isNotEmpty) {
                 _usersList = sList;
                 _totalUsers = _usersList.length;
               }
             } catch (_) {}
           }
           _calculatePlans(_usersList);
           try { _channelPartners = _countData(await _api.fetchChannelPartners()); } catch (_) {}
           if (districtId != null && districtId.isNotEmpty) {
             try { 
               final talukaRes = await _api.fetchTalukasByDistrict(districtId);
               _talukasList = _extractList(talukaRes, 'data');
               _activeTalukas = _talukasList.length; 
             } catch (_) {}
             try {
               final chRes = await _api.fetchWardChairmenBy(districtId);
               _chairmenList = _extractList(chRes, 'data');
               _appointedChairmen = _chairmenList.length;
             } catch (_) {}
           }
           print('DEBUG: [District Head] Data Fetched -> Users: ${_totalUsers}, Talukas: ${_activeTalukas}, Chairmen: ${_appointedChairmen}, CPs: ${_channelPartners}');
           
        } else if (_highestRole == 'taluka_head') {
           print('DEBUG: [Taluka Head] Triggering APIs for Taluka: ${_talukaName} (ID: ${talukaId})...');
           if (_talukaName.isNotEmpty) {
             try {
               final usersRes = await _api.fetchUsersByTaluka(_talukaName);
               _usersList = _extractList(usersRes, 'users');
               _totalUsers = _countUsersSafe(usersRes);
             } catch (_) {}
           }
           if (talukaId != null && (_totalUsers == 0 || _usersList.isEmpty)) {
             try {
               final searchRes = await _api.searchMembers({'talukaId': talukaId, 'limit': 5000});
               final sList = _extractList(searchRes, 'data');
               if (sList.isNotEmpty) {
                 _usersList = sList;
                 _totalUsers = _usersList.length;
               }
             } catch (_) {}
           }
           _calculatePlans(_usersList);
           try { _channelPartners = _countData(await _api.fetchChannelPartners()); } catch (_) {}
           if (talukaId != null && talukaId.isNotEmpty) {
             try {
               final wardRes = await _api.fetchWardsByTaluka(talukaId);
               _wardsList = _extractList(wardRes, 'data');
               _wardsCount = _wardsList.length;
             } catch (_) {}
             try {
               final chRes = await _api.fetchWardChairmenBy(talukaId);
               _chairmenList = _extractList(chRes, 'data');
               _appointedChairmen = _chairmenList.length;
             } catch (_) {}
           }
           print('DEBUG: [Taluka Head] Data Fetched -> Users: ${_totalUsers}, Wards: ${_wardsCount}, Chairmen: ${_appointedChairmen}, CPs: ${_channelPartners}');
           
        } else if (_highestRole == 'ward_chairman') {
           print('DEBUG: [Ward Chairman] Triggering APIs for Ward: ${_wardName} (ID: ${wardId})...');
           if (_wardName.isNotEmpty) {
             try {
               final usersRes = await _api.fetchUsersByWard(_wardName);
               _usersList = _extractList(usersRes, 'users');
               _totalUsers = _countUsersSafe(usersRes);
             } catch (_) {}
           }
           if (wardId != null && _totalUsers == 0) {
             try {
               final searchRes = await _api.searchMembers({'wardId': wardId, 'limit': 5000});
               final sList = _extractList(searchRes, 'data');
               if (sList.isNotEmpty) {
                 _usersList = sList;
                 _totalUsers = _usersList.length;
               }
             } catch (_) {}
           }
           _calculatePlans(_usersList);
           
           if (wardId != null && wardId.isNotEmpty) {
             try { _channelPartners = _countData(await _api.fetchChannelPartners(wardId: wardId)); } catch (_) {}
             try { _cloudPatra = _countData(await _api.fetchCloudPatraApplicationsByWard(wardId), key: 'applications'); } catch (_) {}
           }
           try { _cpSubmissions = _countData(await _api.fetchCpSubmissions(userId), key: 'submissions'); } catch (_) {}
           print('DEBUG: [Ward Chairman] Data Fetched -> Users: ${_totalUsers}, Cloud Patra: ${_cloudPatra}, Submissions: ${_cpSubmissions}, CPs: ${_channelPartners}');
        }
      }
    } catch (e) { print('DEBUG: Dashboard Fetch Error: $e'); }

    if (mounted) setState(() => _isLoading = false);`;

text = text.replace(regex, replacement.replace(/\$/g, '\\$'));

// Wait, the variables inside print are $_totalUsers etc. I should escape the $ in regex replacement but keep them as variables in Dart.
let dartText = text.replace(/\\\$_/g, '$_').replace(/\\\$\{/g, '${');
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', dartText, 'utf-8');
