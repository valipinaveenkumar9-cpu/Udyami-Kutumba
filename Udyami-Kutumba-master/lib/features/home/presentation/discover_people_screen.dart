import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/api/auth/auth_api.dart';
import 'package:udyamikutumba/core/api/ubn/feed_api.dart';
import 'package:udyamikutumba/core/models/user_model.dart';
import 'package:udyamikutumba/features/home/presentation/user_profile_screen.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';

class DiscoverPeopleScreen extends StatefulWidget {
  final String title;
  final String? userId; // For Followers / Following
  final String emptyMessage;
  
  const DiscoverPeopleScreen({
    super.key, 
    this.title = "Discover People", 
    this.userId,
    this.emptyMessage = "No users found."
  });

  @override
  State<DiscoverPeopleScreen> createState() => _DiscoverPeopleScreenState();
}

class _DiscoverPeopleScreenState extends State<DiscoverPeopleScreen> {
  final AuthAPI _authApi = AuthAPI();
  List<Map<String, dynamic>> _usersMap = [];
  bool _isLoading = true;
  final currentUserId = SessionManager.user?['userId']?.toString();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      if (widget.title == "Followers" && widget.userId != null) {
        final res = await FeedAPI.getFollowers(widget.userId!);
        if (res != null) {
          final list = res['followers'] as List?;
          if (list != null) {
             _usersMap = list.map((e) => e as Map<String, dynamic>).toList();
          }
        }
      } else if (widget.title == "Following" && widget.userId != null) {
        final res = await FeedAPI.getFollowing(widget.userId!);
        if (res != null) {
          final list = res['following'] as List?;
          if (list != null) {
             _usersMap = list.map((e) => e as Map<String, dynamic>).toList();
          }
        }
      } else {
        // Discover People
        final res = await _authApi.getAllUsers();
        if (res != null && res['success'] == true) {
          final data = res['data'] ?? res['users'] ?? [];
          if (data is List) {
            _usersMap = data.map((e) => e as Map<String, dynamic>).toList();
            _usersMap.removeWhere((u) => u['userId'] == currentUserId);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching users list: $e");
    }
    
    // Fetch my following list so I can set _isFollowing correctly in the list
    List<String> myFollowingIds = [];
    if (currentUserId != null) {
       final myFollowing = await FeedAPI.getFollowing(currentUserId!);
       if (myFollowing != null && myFollowing['following'] != null) {
         final list = myFollowing['following'] as List;
         myFollowingIds = list.map((e) => e['userId'].toString()).toList();
       }
    }

    if (mounted) {
      setState(() {
        for (var u in _usersMap) {
           final targetId = u['userId']?.toString();
           u['_isFollowing'] = myFollowingIds.contains(targetId);
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _usersMap.isEmpty
              ? Center(child: Text(widget.emptyMessage))
              : ListView.builder(
                  itemCount: _usersMap.length,
                  itemBuilder: (context, index) {
                    final userMap = _usersMap[index];
                    return UserListTile(userMap: userMap);
                  },
                ),
    );
  }
}

class UserListTile extends StatefulWidget {
  final Map<String, dynamic> userMap;

  const UserListTile({super.key, required this.userMap});

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.userMap['_isFollowing'] == true;
  }

  Future<void> _toggleFollow() async {
    setState(() { _isLoading = true; });
    final targetId = widget.userMap['userId']?.toString();
    if (targetId == null) {
       setState(() { _isLoading = false; });
       return;
    }

    bool success;
    if (_isFollowing) {
      success = await FeedAPI.unfollowUser(targetId);
    } else {
      success = await FeedAPI.followUser(targetId);
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) {
          _isFollowing = !_isFollowing;
          SessionManager.profileUpdateNotifier.value++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userMap['name'] ?? 'User';
    final targetId = widget.userMap['userId']?.toString() ?? '';
    final isMe = SessionManager.user?['userId']?.toString() == targetId;
    final profileImage = widget.userMap['profileImage'];

    String initials = '';
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length > 1) {
        initials = parts[0].substring(0, 1) + parts[1].substring(0, 1);
      } else {
        initials = name.substring(0, name.length > 1 ? 2 : 1);
      }
      initials = initials.toUpperCase();
    }

    ImageProvider? avatarImage;
    if (profileImage != null && profileImage.isNotEmpty) {
      if (profileImage.startsWith('data:')) {
        try {
          final base64String = profileImage.split(',').last;
          avatarImage = MemoryImage(base64Decode(base64String));
        } catch (e) {
          avatarImage = null;
        }
      } else {
        avatarImage = NetworkImage(profileImage);
      }
    }

    return ListTile(
      onTap: () {
        if (targetId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                userId: targetId,
                userName: name,
              ),
            ),
          );
        }
      },
      leading: Builder(
        builder: (context) {
          if (avatarImage == null && (profileImage == null || !profileImage.startsWith('http'))) {
            return CircleAvatar(backgroundColor: Colors.grey.shade300, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.black54)));
          } else if (profileImage != null && profileImage.startsWith('http')) {
            return ClipOval(
              child: Image.network(
                profileImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(backgroundColor: Colors.grey.shade300, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.black54))),
              ),
            );
          } else {
            return CircleAvatar(backgroundColor: Colors.grey.shade300, backgroundImage: avatarImage);
          }
        },
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(widget.userMap['email'] ?? widget.userMap['companyName'] ?? ''),
      trailing: isMe ? null : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing ? Colors.grey.shade200 : Colors.blue,
          foregroundColor: _isFollowing ? Colors.black : Colors.white,
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _toggleFollow,
        child: _isLoading 
           ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
           : Text(_isFollowing ? "Following" : "Follow"),
      ),
    );
  }
}
