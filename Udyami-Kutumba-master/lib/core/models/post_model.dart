import 'user_model.dart';

class PostMedia {
  final String mediaId;
  final String postId;
  final String mediaUrl;
  final String mediaType;

  PostMedia({
    required this.mediaId,
    required this.postId,
    required this.mediaUrl,
    required this.mediaType,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      mediaId: json['mediaId']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      mediaType: json['mediaType']?.toString() ?? 'IMAGE', // Defaulting to IMAGE if not provided
    );
  }
}

class PostModel {
  final String postId;
  final String userId;
  final UserModel? user;
  final String content;
  int likeCount;
  int commentCount;
  final int shareCount;
  final bool isActive;
  final List<PostMedia> media;
  final List<CommentModel> commentList;
  final String? createdAt;
  
  // Extra fields that were in the dummy model
  bool isFollowing;
  bool isLiked;

  PostModel({
    required this.postId,
    required this.userId,
    this.user,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isActive,
    required this.media,
    List<CommentModel>? commentList,
    this.createdAt,
    this.isFollowing = false,
    this.isLiked = false,
  }) : commentList = commentList ?? [];

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      var rawMedia = json['media'] as List? ?? json['images'] as List? ?? [];
      List<PostMedia> parsedMedia = [];
      if (rawMedia.isNotEmpty) {
        for (var m in rawMedia) {
          if (m == null) continue;
          if (m is String) {
            parsedMedia.add(PostMedia(
              mediaId: '', 
              postId: json['postId']?.toString() ?? '', 
              mediaUrl: m, 
              mediaType: 'IMAGE'
            ));
          } else if (m is Map<String, dynamic>) {
            parsedMedia.add(PostMedia.fromJson(m));
          }
        }
      }

      List<CommentModel> parsedComments = [];
      var rawComments = json['comments'] as List? ?? json['commentList'] as List? ?? [];
      for (var c in rawComments) {
        if (c is Map<String, dynamic>) {
          parsedComments.add(CommentModel.fromJson(c));
        }
      }

      return PostModel(
        postId: json['postId']?.toString() ?? json['_id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        user: json['user'] is Map<String, dynamic> ? UserModel.fromJson(json['user']) : null,
        content: json['content']?.toString() ?? json['text']?.toString() ?? '',
        likeCount: json['likeCount'] is int ? json['likeCount'] : int.tryParse(json['likeCount']?.toString() ?? '0') ?? 0,
        commentCount: json['commentCount'] is int ? json['commentCount'] : int.tryParse(json['commentCount']?.toString() ?? '0') ?? 0,
        shareCount: json['shareCount'] is int ? json['shareCount'] : int.tryParse(json['shareCount']?.toString() ?? '0') ?? 0,
        isActive: json['isActive'] == true || json['isActive'] == 'true',
        media: parsedMedia,
        commentList: parsedComments,
        isLiked: json['isLiked'] == true || json['isLiked'] == 'true',
        createdAt: json['createdAt']?.toString(),
      );
    } catch (e, stacktrace) {
      print("DEV DEBUG - PostModel.fromJson failed for json: $json\nError: $e\n$stacktrace");
      // Return a dummy error post so it doesn't crash the whole list, but we can see it failed
      return PostModel(
        postId: 'error',
        userId: 'error',
        content: 'Error parsing post: $e',
        likeCount: 0,
        commentCount: 0,
        shareCount: 0,
        isActive: false,
        media: [],
      );
    }
  }

  // Helpers for UI
  String get name => user?.name ?? 'Unknown User';
  String get role => user?.companyName ?? user?.userType ?? 'User';
  String get profileImage {
    if (user != null && user!.profileImage != null && user!.profileImage!.isNotEmpty) {
      return user!.profileImage!;
    }
    return 'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(name)}';
  }
  String? get postImage => media.isNotEmpty ? media.first.mediaUrl : null;
  String get caption => content;
  int get likes => likeCount;
  int get comments => commentCount;

  String get timeAgo {
    if (createdAt == null) return "Just now";
    final dt = DateTime.tryParse(createdAt!);
    if (dt == null) return "Just now";
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return "${diff.inDays} days ago";
    if (diff.inHours > 0) return "${diff.inHours} hrs ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} mins ago";
    return "Just now";
  }
}

class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final UserModel? user;
  final String text;
  final String time;
  int reactionCount;
  bool isLiked;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    this.user,
    required this.text,
    required this.time,
    this.reactionCount = 0,
    this.isLiked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      text: json['text']?.toString() ?? json['content']?.toString() ?? '',
      time: json['createdAt']?.toString() ?? 'Just now',
      reactionCount: json['reactions'] is List ? (json['reactions'] as List).length : 0,
      // Default to false for now unless we can parse from json
      isLiked: false, 
    );
  }

  // Helpers for UI
  String get name => user?.name ?? 'Unknown User';
  String get profileImage {
    if (user != null && user!.profileImage != null && user!.profileImage!.isNotEmpty) {
      return user!.profileImage!;
    }
    return 'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(name)}';
  }
}
