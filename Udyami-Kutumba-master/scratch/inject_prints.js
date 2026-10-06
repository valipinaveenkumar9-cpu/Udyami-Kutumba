const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

text = text.replace(
  /if \(userModel\.roles\.isNotEmpty\) \{/,
  "print('DEBUG: User Roles found: \\${userModel.roles.map((r) => r.roleName).toList()}');\n        if (userModel.roles.isNotEmpty) {"
);

text = text.replace(
  /String\? districtId;\s*final profileRes = await _profileApi\.getUserProfileById\(userId\);/,
  "String? districtId;\n        print('DEBUG: Determined Highest Role: \\$_highestRole');\n        \n        final profileRes = await _profileApi.getUserProfileById(userId);"
);

text = text.replace(
  /if \(talukaId == null \|\| _talukaName\.isEmpty\) \{/,
  "print('DEBUG: Resolved Location -> Ward: \\$_wardName (\\$wardId), Taluka: \\$_talukaName (\\$talukaId), District: \\$_districtName (\\$districtId)');\n\n        if (talukaId == null || _talukaName.isEmpty) {"
);

text = text.replace(
  /if \(_highestRole == 'super_admin' \|\| _highestRole\.contains\('state'\)\) \{/,
  "if (_highestRole == 'super_admin' || _highestRole.contains('state')) {\n           print('DEBUG: [Super Admin / State] Triggering APIs...');"
);

text = text.replace(
  /\_allDistrictsCount = \_districtsList\.length; \n\s*\} catch \(\_\) \{\}/,
  "_allDistrictsCount = _districtsList.length; \n           } catch (_) {}\n           print('DEBUG: [Super Admin] Data -> Users: \\$_totalUsers, Districts: \\$_allDistrictsCount, Heads: \\$_allHeadsCount, CPs: \\$_channelPartners');"
);

text = text.replace(
  /else if \(_highestRole\.contains\('district'\)\) \{/,
  "else if (_highestRole.contains('district')) {\n           print('DEBUG: [District Head] Triggering APIs for District: \\$_districtName (ID: \\$districtId)...');"
);

text = text.replace(
  /\_appointedChairmen = \_chairmenList\.length;\n\s*\} catch \(\_\) \{\}\n\s*\}/,
  "_appointedChairmen = _chairmenList.length;\n             } catch (_) {}\n           }\n           print('DEBUG: [District Head] Data -> Users: \\$_totalUsers, Talukas: \\$_activeTalukas, Chairmen: \\$_appointedChairmen, CPs: \\$_channelPartners');"
);

text = text.replace(
  /else if \(_highestRole == 'taluka_head'\) \{/,
  "else if (_highestRole == 'taluka_head') {\n           print('DEBUG: [Taluka Head] Triggering APIs for Taluka: \\$_talukaName (ID: \\$talukaId)...');"
);

text = text.replace(
  /\_appointedChairmen = \_chairmenList\.length;\n\s*\} catch \(\_\) \{\}\n\s*\}/g,
  "_appointedChairmen = _chairmenList.length;\n             } catch (_) {}\n           }\n           print('DEBUG: [Taluka Head] Data -> Users: \\$_totalUsers, Wards: \\$_wardsCount, Chairmen: \\$_appointedChairmen, CPs: \\$_channelPartners');"
);

text = text.replace(
  /else if \(_highestRole == 'ward_chairman'\) \{/,
  "else if (_highestRole == 'ward_chairman') {\n           print('DEBUG: [Ward Chairman] Triggering APIs for Ward: \\$_wardName (ID: \\$wardId)...');"
);

text = text.replace(
  /try \{ \_cpSubmissions = \_countData\(await \_api\.fetchCpSubmissions\(userId\), key: 'submissions'\); \} catch \(\_\) \{\}/,
  "try { _cpSubmissions = _countData(await _api.fetchCpSubmissions(userId), key: 'submissions'); } catch (_) {}\n           print('DEBUG: [Ward Chairman] Data -> Users: \\$_totalUsers, CPs: \\$_channelPartners, Cloud Patra: \\$_cloudPatra, Submissions: \\$_cpSubmissions');"
);


fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
