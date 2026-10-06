import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../utils/session_manager.dart';
import '../api.dart';
import 'package:http/http.dart' as http;

class FeedAPI {
  static final ApiClient _api = ApiClient();

  static Future<bool> createPost(String content, {List<File>? images}) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) {
        if (kDebugMode) print("DEV DEBUG - FeedAPI createPost failed: userId is null");
        return false;
      }

      final fields = {
        'userId': userId.toString(),
        'content': content,
      };

      List<http.MultipartFile> files = [];
      if (images != null) {
        for (var image in images) {
          final ext = image.path.split('.').last.toLowerCase();
          String topType = 'image';
          String subType = 'jpeg';
          
          if (ext == 'png') subType = 'png';
          else if (ext == 'webp') subType = 'webp';
          else if (ext == 'mp4') { topType = 'video'; subType = 'mp4'; }
          else if (ext == 'mov') { topType = 'video'; subType = 'quicktime'; }

          files.add(await http.MultipartFile.fromPath(
            'images', 
            image.path,
            contentType: MediaType(topType, subType),
          ));
        }
      }

      final response = await _api.postMultipart(
        '/feed/createPost',
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      return response != null && (response['success'] == true || response['statusCode'] == null);
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception creating post: $e");
      return false;
    }
  }

  static Future<bool> likePost(String postId) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) return false;
      
      final response = await _api.post('/feed/$postId/like', {'userId': userId.toString()});
      
      if (response == null || response is String) return true;
      if (response is Map) {
        if (response['success'] == false) return false;
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception liking post: $e");
      return false;
    }
  }

  static Future<bool> unlikePost(String postId) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) return false;
      
      final response = await _api.delete('/feed/$postId/like', data: {'userId': userId.toString()});
      
      if (response == null || response is String) return true;
      if (response is Map) {
        if (response['success'] == false) return false;
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception unliking post: $e");
      return false;
    }
  }

  static Future<bool> removeUserLike(String postId, String targetUserId) async {
    try {
      final response = await _api.delete('/feed/$postId/like', data: {'userId': targetUserId});
      
      if (response == null || response is String) return true;
      if (response is Map) {
        if (response['success'] == false) return false;
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception removing user like: $e");
      return false;
    }
  }

  static Future<CommentModel?> addComment(String postId, String commentText) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) {
        if (kDebugMode) print("DEV DEBUG - FeedAPI addComment failed: userId is null");
        return null;
      }

      final body = {
        'userId': userId.toString(),
        'content': commentText,
        'imageUrl': null,
      };

      final response = await _api.post('/feed/addComments/$postId', body);
      
      if (response != null && (response['statusCode'] == 201 || response['statusCode'] == null || response['success'] == true)) {
        if (response is Map<String, dynamic> && response.containsKey('commentId')) {
          return CommentModel.fromJson(response as Map<String, dynamic>);
        } else if (response is Map<String, dynamic> && response.containsKey('data')) {
          return CommentModel.fromJson(response['data'] as Map<String, dynamic>);
        }
        return CommentModel(
          commentId: DateTime.now().millisecondsSinceEpoch.toString(),
          postId: postId,
          userId: userId.toString(),
          text: commentText,
          time: DateTime.now().toIso8601String(),
          user: UserModel(
            userId: userId.toString(),
            name: SessionManager.user?['name'] ?? 'You',
            email: '',
            mobileNumber: '',
            roles: [],
          )
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception adding comment: $e");
      return null;
    }
  }

  static Future<bool> deletePost(String postId) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) return false;

      final response = await _api.delete('/feed/deletePost/$postId', data: {'userId': userId.toString()});
      
      return response != null && (response['statusCode'] == 200 || response['statusCode'] == null || response['message'] != null);
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception deleting post: $e");
      return false;
    }
  }

  static Future<bool> deleteComment(String commentId) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) return false;

      final response = await _api.delete('/feed/deleteComment/$commentId', data: {'userId': userId.toString()});
      
      return response != null && (response['statusCode'] == 200 || response['statusCode'] == null || response['message'] != null);
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception deleting comment: $e");
      return false;
    }
  }

  static Future<bool> addCommentReaction(String commentId, String reactionType) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) return false;

      final body = {
        'userId': userId.toString(),
        'reactionType': reactionType,
      };

      final response = await _api.post('/feed/addReactionBy/$commentId', body);
      
      return response != null && (response['statusCode'] == 201 || response['statusCode'] == null || response['message'] != null);
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception adding comment reaction: $e");
      return false;
    }
  }

  static Future<PostModel?> getPost(String postId) async {
    try {
      final response = await _api.get('/feed/getPostById/$postId');
      
      if (response != null && (response is Map ? response['statusCode'] == null : true)) {
        dynamic targetData = response;
        if (targetData is Map && targetData.containsKey('data')) {
          targetData = targetData['data'];
        }
        if (targetData is Map) {
          return PostModel.fromJson(targetData as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching post: $e");
      return null;
    }
  }

  static Future<List<CommentModel>> getComments(String postId) async {
    try {
      final response = await _api.get('/feed/getPostById/$postId');
      
      if (response != null && (response is Map ? response['statusCode'] == null : true)) {
        dynamic targetData = response;
        if (targetData is Map && targetData.containsKey('data')) {
          targetData = targetData['data'];
        }
        if (targetData is Map && targetData.containsKey('comments')) {
           final commentsList = targetData['comments'];
           if (commentsList is List) {
             return commentsList.map((x) => CommentModel.fromJson(x)).toList();
           }
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching comments: $e");
      return [];
    }
  }

  static Future<List<UserModel>> getLikes(String postId) async {
    try {
      final response = await _api.get('/feed/getPostById/$postId');
      
      if (response != null && (response is Map ? response['statusCode'] == null : true)) {
        dynamic targetData = response;
        if (targetData is Map && targetData.containsKey('data')) {
          targetData = targetData['data'];
        }
        if (targetData is Map && targetData.containsKey('likes')) {
          final likesList = targetData['likes'];
          if (likesList is List) {
            return likesList.map((x) {
              if (x is Map<String, dynamic>) {
                if (x.containsKey('user')) {
                  return UserModel.fromJson(x['user'] as Map<String, dynamic>);
                }
                return UserModel.fromJson(x);
              }
              return UserModel(userId: '', name: 'Unknown', email: '', mobileNumber: '', roles: []);
            }).where((u) => u.userId.isNotEmpty).toList();
          }
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching likes: $e");
      return [];
    }
  }

  static Future<bool> followUser(String targetUserId) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) return false;

      final body = {
        'followerId': userId.toString(),
      };
      
      final response = await _api.post('/feed/followUserBy/$targetUserId', body);
      
      return response != null && (response['statusCode'] == 201 || response['statusCode'] == 200 || response['message'] != null);
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception following user: $e");
      return false;
    }
  }

  static Future<bool> unfollowUser(String targetUserId) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) return false;

      final body = {
        'followerId': userId.toString(), 
      };
      
      final response = await _api.delete('/feed/$targetUserId/unfollow', data: body);
      
      return response != null && (response['statusCode'] == 200 || response['statusCode'] == null || response['message'] != null);
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception unfollowing user: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getFollowers(String userId) async {
    try {
      final response = await _api.get('/feed/$userId/followers');
      
      if (response != null && response is Map<String, dynamic> && response['data'] != null) {
        return response['data'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching followers: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getFollowing(String userId) async {
    try {
      final response = await _api.get('/feed/$userId/following');
      
      if (response != null && response is Map<String, dynamic> && response['data'] != null) {
        return response['data'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching following: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _api.get('/userprofile/getUserProfileById/$userId');
      
      if (response != null && response is Map<String, dynamic> && response['success'] == true) {
        if (response.containsKey('data')) {
           return response['data'] as Map<String, dynamic>;
        }
        return response;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching user profile: $e");
      return null;
    }
  }

  static Future<List<PostModel>> getPostsByUser(String userId) async {
    try {
      final response = await _api.get('/feed/getPostBy/$userId');
      
      if (response != null) {
        dynamic targetData = response;
        if (targetData is Map && targetData.containsKey('data')) {
          targetData = targetData['data'];
        }
        
        if (targetData is List) {
          final posts = targetData.map((x) => PostModel.fromJson(x)).toList();
          return posts;
        }
      }
      return [];
    } catch (e, st) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching user posts: $e\n$st");
      return [];
    }
  }

  static Future<List<PostModel>> getAllPosts({String? cursor, int limit = 50}) async {
    try {
      final endpoint = cursor != null ? '/feed/getAllPosts?cursor=$cursor&limit=$limit' : '/feed/getAllPosts?limit=$limit';
      final response = await _api.get(endpoint);
      
      if (response == null) return [];

      if (response is Map) {
        if (response['success'] == false && response['statusCode'] != null) {
           return [];
        }

        dynamic targetData = response;

        if (targetData is Map) {
          if (targetData.containsKey('data') && targetData['data'] != null) targetData = targetData['data'];
          else if (targetData.containsKey('posts') && targetData['posts'] != null) targetData = targetData['posts'];
          else if (targetData.containsKey('docs') && targetData['docs'] != null) targetData = targetData['docs'];
          else if (targetData.containsKey('feed') && targetData['feed'] != null) targetData = targetData['feed'];
        }

        if (targetData is Map) {
          if (targetData.containsKey('docs')) targetData = targetData['docs'];
          else if (targetData.containsKey('posts')) targetData = targetData['posts'];
          else if (targetData.containsKey('data')) targetData = targetData['data'];
        }

        if (targetData is List) {
          return targetData.map((x) => PostModel.fromJson(x)).toList();
        }
      } else if (response is List) {
         return response.map((x) => PostModel.fromJson(x)).toList();
      }
      
      return [];
    } catch (e, stacktrace) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching posts: $e\n$stacktrace");
      return [];
    }
  }

  static Future<Map<String, dynamic>?> sharePost(String postId, String appUrl) async {
    try {
      final userId = SessionManager.user?['userId'];
      if (userId == null) return null;

      final body = {
        'userId': userId.toString(),
        'appUrl': appUrl,
      };

      final response = await _api.post('/feed/sharePost/$postId', body);
      
      if (response != null && (response['statusCode'] == 201 || response['statusCode'] == null || response['message'] != null)) {
        return response as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception sharing post: $e");
      return null;
    }
  }
}
