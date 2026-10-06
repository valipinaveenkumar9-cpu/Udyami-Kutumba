import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyToken = 'access_token';
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static late SharedPreferences _prefs;
  static final ValueNotifier<int> profileUpdateNotifier = ValueNotifier(0);

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveSession(
    String token,
    Map<String, dynamic> user,
  ) async {
    await _prefs.setString(_keyToken, token);
    await _prefs.setString(_keyUser, jsonEncode(user));
    await _prefs.setBool(_keyIsLoggedIn, true);
  }

  static Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
    await _prefs.setBool(_keyIsLoggedIn, false);
  }

  static bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  static String? get token => _prefs.getString(_keyToken);

  static Map<String, dynamic>? get user {
    final userStr = _prefs.getString(_keyUser);
    if (userStr != null) {
      try {
        return jsonDecode(userStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static const String _keyActiveMeeting = 'active_meeting_id';

  static Future<void> setActiveMeetingId(String? meetingId) async {
    if (meetingId == null) {
      await _prefs.remove(_keyActiveMeeting);
    } else {
      await _prefs.setString(_keyActiveMeeting, meetingId);
    }
  }

  static String? get activeMeetingId => _prefs.getString(_keyActiveMeeting);

  static const String _keyPendingProfile = 'pending_profile_data';

  static Future<void> savePendingProfileData(Map<String, dynamic> data) async {
    await _prefs.setString(_keyPendingProfile, jsonEncode(data));
  }

  static Map<String, dynamic>? get pendingProfileData {
    final str = _prefs.getString(_keyPendingProfile);
    if (str != null) {
      try {
        return jsonDecode(str);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearPendingProfileData() async {
    await _prefs.remove(_keyPendingProfile);
  }
}
