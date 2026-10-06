import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/face_to_face_model.dart';
import '../api.dart';

class FaceToFaceAPI {
  static final ApiClient _api = ApiClient();

  static Future<bool> startFaceToFaceMeeting(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/facetoface/startFaceToFaceMeeting', payload);
      if (response != null && response['success'] != false) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("DEV DEBUG - error - face_to_face_api.dart - Exception starting face to face meeting: $e");
      }
      return false;
    }
  }

  static Future<bool> createFaceToFace(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/facetoface/createFaceToFace', payload);
      if (response != null && response['success'] != false) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("DEV DEBUG - error - face_to_face_api.dart - Exception creating face to face: $e");
      }
      return false;
    }
  }

  static Future<List<FaceToFaceModel>> getFaceToFaceMeetingsByUserId(String userId) async {
    try {
      final response = await _api.get('/facetoface/getFaceToFaceMeetingsByUserId/$userId');
      if (response != null && response['success'] != false) {
        if (response['data'] != null) {
          return (response['data'] as List).map((x) => FaceToFaceModel.fromJson(x)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("DEV DEBUG - error - face_to_face_api.dart - Exception fetching face to face meetings: $e");
      }
      return [];
    }
  }

  static Future<bool> updateFaceToFaceMeeting(String meetingId, Map<String, dynamic> payload) async {
    try {
      final response = await _api.patch('/facetoface/updateFaceToFaceMeeting/$meetingId', payload);
      if (response != null && response['success'] != false) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("DEV DEBUG - error - face_to_face_api.dart - Exception updating face to face meeting: $e");
      }
      return false;
    }
  }

  static Future<List<FaceToFaceModel>> getAllFaceToFaceMeetings() async {
    try {
      final response = await _api.get('/facetoface/getAllFaceToFaceMeetings');
      if (response != null && response['success'] != false) {
        if (response['data'] != null) {
          return (response['data'] as List).map((x) => FaceToFaceModel.fromJson(x)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("DEV DEBUG - error - face_to_face_api.dart - Exception fetching all face to face meetings: $e");
      }
      return [];
    }
  }

  static Future<bool> updateFaceToFaceStatus(String meetingId, String status, String userId) async {
    try {
      final payload = {
        "invitedMemberUserId": userId,
        "status": status,
        "feedback": "",
        "message": "",
      };
      final response = await _api.patch('/facetoface/updateFaceToFace/$meetingId/status', payload);
      if (response != null && response['success'] != false) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("DEV DEBUG - error - face_to_face_api.dart - Exception updating face to face status: $e");
      }
      return false;
    }
  }

  static Future<List<FaceToFaceModel>> getMeetingsByInvitedMember(String invitedMemberUserId) async {
    try {
      final response = await _api.get('/facetoface/invited-member/$invitedMemberUserId');
      if (response != null && response['success'] != false) {
        if (response['data'] != null) {
          return (response['data'] as List).map((x) => FaceToFaceModel.fromJson(x)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - face_to_face_api.dart - Exception fetching invited member meetings: $e");
      return [];
    }
  }

  static Future<bool> createContactSphere(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/facetoface/createContactSphere', payload);
      if (response != null && response['success'] != false) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - face_to_face_api.dart - Exception creating contact sphere: $e");
      return false;
    }
  }

  static Future<bool> updateContactSphere(String contactSphereId, Map<String, dynamic> payload) async {
    try {
      final response = await _api.patch('/facetoface/updateContactSphere/$contactSphereId', payload);
      if (response != null && response['success'] != false) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - face_to_face_api.dart - Exception updating contact sphere: $e");
      return false;
    }
  }

  static Future<dynamic> getContactSphere({String? createdUserId, String? invitedMemberUserId}) async {
    try {
      final queryParams = <String>[];
      if (createdUserId != null) queryParams.add('createdUserId=$createdUserId');
      if (invitedMemberUserId != null) queryParams.add('invitedMemberUserId=$invitedMemberUserId');
      
      final q = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _api.get('/facetoface/contactSphere$q');
      
      if (response != null && response['success'] != false) {
        return response;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - face_to_face_api.dart - Exception fetching contact sphere: $e");
      return null;
    }
  }
}
