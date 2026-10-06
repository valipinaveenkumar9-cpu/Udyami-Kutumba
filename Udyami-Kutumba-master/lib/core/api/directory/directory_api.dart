import 'dart:convert';
import '../api.dart';

class DirectoryAPI {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> searchMembers(String name, String sector) async {
    try {
      final response = await _api.get('/auth/getAllUsers');
      
      if (response != null && response['success'] != false) {
        final data = response;
        
        List<dynamic> members = [];
        if (data is Map && data.containsKey('membershipUsers')) {
           members = data['membershipUsers'] as List<dynamic>? ?? [];
        } else if (data is Map && data.containsKey('data')) {
           members = data['data'] as List<dynamic>? ?? [];
        }

        // Fetch profile for each user
        final profileFutures = members.map((user) async {
          final userId = user['userId'];
          if (userId == null) return null;
          try {
            final profileResponse = await _api.get('/userprofile/getUserProfileById/$userId');
            if (profileResponse != null && profileResponse['success'] != false) {
              final profileData = profileResponse;
              if (profileData is Map && profileData['data'] != null && profileData['data']['profile'] != null) {
                final profile = profileData['data']['profile'];
                // Decode businessDetails if it's a string
                if (profile['businessDetails'] is String) {
                  try {
                    profile['businessDetails'] = jsonDecode(profile['businessDetails']);
                  } catch (_) {}
                }
                user['profile'] = profile;
                
                // Add businessCategory to the root user object for easy access
                if (profile['businessCategory'] != null && profile['businessCategory'].toString().isNotEmpty) {
                  user['businessCategory'] = profile['businessCategory'];
                  user['businessSubCategory'] = profile['businessSubCategory'];
                  user['businessTag'] = profile['businessTag'];
                } else if (profile['businessDetails'] is Map) {
                  final bType = profile['businessDetails']['businessType'];
                  if (bType != null && bType is String) {
                    final parts = bType.split(RegExp(r'[|-]')).map((e) => e.trim()).toList();
                    if (parts.isNotEmpty) user['businessCategory'] = parts[0];
                    if (parts.length > 1) user['businessSubCategory'] = parts[1];
                    if (parts.length > 2) user['businessTag'] = parts[2];
                  }
                }
                return user;
              }
            }
          } catch (e) {
            // ignore
          }
          return user; // Return user even without profile
        });

        final results = await Future.wait(profileFutures);
        members = results.where((u) => u != null).toList();

        // Apply local filtering for name and sector
        if (name.isNotEmpty || (sector.isNotEmpty && sector.toLowerCase() != 'all')) {
          members = members.where((e) {
            bool matchesName = true;
            bool matchesSector = true;
            
            if (name.isNotEmpty) {
              final String memberName = (e['name']?.toString() ?? '').toLowerCase();
              matchesName = memberName.contains(name.toLowerCase());
            }
            
            if (sector.isNotEmpty && sector.toLowerCase() != 'all') {
              String memberSector = '';
              if (e['businessCategory'] != null) {
                memberSector = e['businessCategory']?.toString().toLowerCase() ?? '';
              }
              matchesSector = memberSector == sector.toLowerCase();
            }
            
            return matchesName && matchesSector;
          }).toList();
        }

        return members;
      }
      return [];
    } catch (e) {
      print('DEV DEBUG - get - directory_api.dart - Exception: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllMembers() async {
    try {
      final response = await _api.get('/auth/getAllUsers');
      
      if (response != null && response['success'] != false) {
        final data = response;
        
        List<dynamic> baseUsers = [];
        if (data is Map && data.containsKey('membershipUsers')) {
           baseUsers = data['membershipUsers'] as List<dynamic>? ?? [];
        } else if (data is Map && data.containsKey('data')) {
           baseUsers = data['data'] as List<dynamic>? ?? [];
        }

        List<dynamic> members = [];
        
        // Combine both APIs: fetch profile for each user to get hasBusiness
        final profileFutures = baseUsers.map((user) async {
          final userId = user['userId'];
          if (userId == null) return null;
          
          try {
            final profileResponse = await _api.get('/userprofile/getUserProfileById/$userId');
            if (profileResponse != null && profileResponse['success'] != false) {
              final profileData = profileResponse;
              if (profileData is Map && profileData['data'] != null && profileData['data']['profile'] != null) {
                user['profile'] = profileData['data']['profile'];
                return user;
              }
            }
          } catch (e) {
            // ignore
          }
          return null;
        });

        final results = await Future.wait(profileFutures);
        for (var user in results) {
          if (user != null) {
            final profile = user['profile'];
            if (profile != null) {
              final hasBiz = profile['hasBusiness'];
              if (hasBiz == true || hasBiz == 'true' || hasBiz == 1) {
                members.add(user);
              }
            }
          }
        }

        return members;
      }
      return [];
    } catch (e) {
      print('DEV DEBUG - get - directory_api.dart - Exception: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchBusinessMembers(String name) async {
    try {
      final response = await _api.post('/directory/searchMembers', {"name": name});
      
      if (response != null && response['success'] != false) {
        final data = response;
        
        List<dynamic> members = [];
        if (data is Map && data.containsKey('data')) {
           members = data['data'] as List<dynamic>? ?? [];
        } else if (data is List) {
           members = data;
        } else if (data is Map && data.containsKey('members')) {
           members = data['members'] as List<dynamic>? ?? [];
        }

        // Apply fallback filter for hasBusiness just in case
        members = members.where((e) {
          if (e['profile'] != null) {
            final hasBiz = e['profile']['hasBusiness'];
            return hasBiz == true || hasBiz == 'true' || hasBiz == 1;
          }
          return false;
        }).toList();

        return members;
      }
      return [];
    } catch (e) {
      print('DEV DEBUG - post - directory_api.dart - Exception: $e');
      return [];
    }
  }
}
