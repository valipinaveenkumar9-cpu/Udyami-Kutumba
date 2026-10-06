const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', 'utf-8');

const replacement = `
  Future<void> _initDashboard() async {
    try {
      final user = SessionManager.user;
      if (user == null || user['userId'] == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final userModel = UserModel.fromJson(user);
      if (userModel.roles.isNotEmpty) {
        _highestRole = userModel.roles.first.roleName.toLowerCase();
        for (final r in userModel.roles) {
          final rl = r.roleName.toLowerCase();
          if (rl == 'super_admin') { _highestRole = rl; break; }
          if (rl.contains('district')) { _highestRole = rl; }
          if (rl.contains('taluka') && !_highestRole.contains('district')) { _highestRole = rl; }
          if ((rl.contains('ward_chairman') || rl.contains('ward_head')) && !_highestRole.contains('taluka') && !_highestRole.contains('district')) { _highestRole = rl; }
        }
      }

      // 1. Get user profile
      final profileRes = await _profileApi.getUserProfileById(user['userId'].toString());
      Map<String, dynamic>? profile;
      if (profileRes != null && profileRes['success'] == true) {
        if (profileRes['data'] is Map && profileRes['data']['profile'] is Map) {
          profile = profileRes['data']['profile'];
        }
      }

      // 2. Identify entityId and type
      if (_highestRole == 'super_admin') {
        _entityId = 'karnataka';
        _entityType = 'state';
      } else if (_highestRole.contains('district')) {
        _entityType = 'district';
        if (profile != null && profile['district'] != null) {
          _entityId = profile['district'] is Map ? (profile['district']['_id']?.toString() ?? '') : profile['district'].toString();
        }
        if (_entityId.isEmpty && user['district'] != null) {
          _entityId = user['district'] is Map ? (user['district']['_id']?.toString() ?? '') : user['district'].toString();
        }
      } else if (_highestRole.contains('taluka')) {
        _entityType = 'taluka';
        if (profile != null && profile['taluka'] != null) {
          _entityId = profile['taluka'] is Map ? (profile['taluka']['_id']?.toString() ?? '') : profile['taluka'].toString();
        }
        if (_entityId.isEmpty) {
          try {
            final locRes = await _dashboardApi.getLocationByWardHeadId(user['userId'].toString());
            final locData = locRes != null ? (locRes['data'] ?? locRes) : null;
            List wardsArray = [];
            if (locData is Map && locData['wards'] is List) wardsArray = locData['wards'];
            else if (locData is List) wardsArray = locData;
            else if (locData is Map && locData['areaChart'] != null && locData['areaChart']['wards'] is List) wardsArray = locData['areaChart']['wards'];
            if (wardsArray.isNotEmpty) {
              final source = wardsArray.first as Map;
              if (source['taluka'] is Map) {
                _entityId = source['taluka']['_id']?.toString() ?? source['taluka']['talukaId']?.toString() ?? '';
              }
            }
          } catch (_) {}
        }
      } else if (_highestRole.contains('ward')) {
        _entityType = 'ward';
        if (profile != null && profile['ward'] != null) {
          _entityId = profile['ward'] is Map ? (profile['ward']['_id']?.toString() ?? '') : profile['ward'].toString();
        }
      }

      // 3. Fetch Dashboard Data
      if (_entityId.isNotEmpty && _entityType.isNotEmpty) {
        final res = await _dashboardApi.getBusinessCircleDashboard(_entityId, _entityType);
        if (res != null && (res['success'] == true || res['summary'] != null)) {
          final dataObj = res['data'] ?? res;
          setState(() {
            _summary = dataObj['summary'] ?? {};
            if (dataObj['assemblies'] != null && (dataObj['assemblies'] as List).isNotEmpty) {
               _circlesList = dataObj['assemblies'];
            } else if (dataObj['wards'] != null && (dataObj['wards'] as List).isNotEmpty) {
               _circlesList = dataObj['wards'];
            } else {
               _circlesList = [];
            }
          });
        }
      }

    } catch (e) {
      debugPrint("Error loading UCN dashboard: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
`;

const start = text.indexOf('Future<void> _initDashboard() async {');
const end = text.indexOf('Widget _buildStatCard');
text = text.substring(0, start) + replacement + '\n  ' + text.substring(end);

fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', text, 'utf-8');
