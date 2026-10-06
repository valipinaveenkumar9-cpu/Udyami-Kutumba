const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

text = text.replace(
  "_allDistrictsCount = _districtsList.length; \n           } catch (_) {}",
  "_allDistrictsCount = _districtsList.length; \n           } catch (_) {}\n           print('DEBUG: [Super Admin] Data Fetched -> Users: ${_totalUsers}, Districts: ${_allDistrictsCount}, Heads: ${_allHeadsCount}, CPs: ${_channelPartners}');"
);

text = text.replace(
  "_appointedChairmen = _chairmenList.length;\n             } catch (_) {}\n           }\n           \n        } else if (_highestRole == 'taluka_head')",
  "_appointedChairmen = _chairmenList.length;\n             } catch (_) {}\n           }\n           print('DEBUG: [District Head] Data Fetched -> Users: ${_totalUsers}, Talukas: ${_activeTalukas}, Chairmen: ${_appointedChairmen}, CPs: ${_channelPartners}');\n        } else if (_highestRole == 'taluka_head')"
);

text = text.replace(
  "_appointedChairmen = _chairmenList.length;\n             } catch (_) {}\n           }\n           \n        } else if (_highestRole == 'ward_chairman')",
  "_appointedChairmen = _chairmenList.length;\n             } catch (_) {}\n           }\n           print('DEBUG: [Taluka Head] Data Fetched -> Users: ${_totalUsers}, Wards: ${_wardsCount}, Chairmen: ${_appointedChairmen}, CPs: ${_channelPartners}');\n        } else if (_highestRole == 'ward_chairman')"
);

text = text.replace(
  "try { _cpSubmissions = _countData(await _api.fetchCpSubmissions(userId), key: 'submissions'); } catch (_) {}\n        }\n      }\n    } catch (_) {}",
  "try { _cpSubmissions = _countData(await _api.fetchCpSubmissions(userId), key: 'submissions'); } catch (_) {}\n           print('DEBUG: [Ward Chairman] Data Fetched -> Users: ${_totalUsers}, Cloud Patra: ${_cloudPatra}, Submissions: ${_cpSubmissions}, CPs: ${_channelPartners}');\n        }\n      }\n    } catch (_) {}"
);


fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
