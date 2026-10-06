import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/api/ubn/feed_api.dart';
import 'package:udyamikutumba/core/models/post_model.dart';
import 'package:udyamikutumba/core/widgets/media_display_widget.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';
import 'package:udyamikutumba/features/home/presentation/discover_people_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final bool initialFollowing;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.initialFollowing = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  List<PostModel> _userPosts = [];
  bool _isFollowing = false;

  int _followersCount = 0;
  int _followingCount = 0;
  String _bio = '';
  String? _profileImage;
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialFollowing;
    _fetchData();
  }

  Future<void> _fetchData() async {
    final profile = await FeedAPI.getUserProfile(widget.userId);
    final posts = await FeedAPI.getPostsByUser(widget.userId);
    final followersData = await FeedAPI.getFollowers(widget.userId);
    final followingData = await FeedAPI.getFollowing(widget.userId);
    final currentUserId = SessionManager.user?['userId'];
    
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _userPosts = posts;
        _isLoading = false;

        if (_userProfile != null) {
          final u = _userProfile!['user'];
          if (u != null && u is Map) {
             if (u.containsKey('profileImage')) _profileImage = u['profileImage'];
             if (u.containsKey('bio')) _bio = u['bio'] ?? '';
          }
        }

        if (followersData != null) {
          _followersCount = followersData['count'] ?? 0;
          final followersList = followersData['followers'] as List?;
          if (followersList != null && currentUserId != null) {
            _isFollowing = followersList.any((f) => f['userId'] == currentUserId.toString() || f['followId'] == currentUserId.toString());
          }
        }
        if (followingData != null) {
          _followingCount = followingData['count'] ?? 0;
        }

        if (widget.userName.isNotEmpty) {
          final parts = widget.userName.trim().split(' ');
          if (parts.length > 1) {
            _initials = parts[0].substring(0, 1) + parts[1].substring(0, 1);
          } else {
            _initials = widget.userName.substring(0, widget.userName.length > 1 ? 2 : 1);
          }
          _initials = _initials.toUpperCase();
        }
      });
    }
  }

  Future<void> _toggleFollow() async {
    final prevIsFollowing = _isFollowing;
    setState(() {
      _isFollowing = !_isFollowing;
      _followersCount += _isFollowing ? 1 : -1;
    });

    bool success;
    if (_isFollowing) {
      success = await FeedAPI.followUser(widget.userId);
    } else {
      success = await FeedAPI.unfollowUser(widget.userId);
    }
    
    if (success) {
      SessionManager.profileUpdateNotifier.value++;
    }

    if (!success) {
      if (mounted) {
        setState(() {
          _isFollowing = prevIsFollowing;
          _followersCount += _isFollowing ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update follow status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.userName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isMe = SessionManager.user?['userId'] == widget.userId;

    ImageProvider? avatarImage;
    if (_profileImage != null && _profileImage!.isNotEmpty) {
      if (_profileImage!.startsWith('data:image')) {
        try {
          final base64Str = _profileImage!.split(',').last;
          avatarImage = MemoryImage(base64Decode(base64Str.replaceAll(RegExp(r'\s+'), '')));
        } catch (_) {}
      } else {
        avatarImage = NetworkImage(_profileImage!);
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? Text(_initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)) 
                            : null,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn("posts", _userPosts.length),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => DiscoverPeopleScreen(title: "Followers", userId: widget.userId)
                                ));
                              },
                              child: _buildStatColumn("followers", _followersCount),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => DiscoverPeopleScreen(title: "Following", userId: widget.userId)
                                ));
                              },
                              child: _buildStatColumn("following", _followingCount),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (_bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_bio),
                  ],
                  const SizedBox(height: 16),
                  if (!isMe)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _isFollowing ? Colors.grey.shade200 : Colors.blue,
                              foregroundColor: _isFollowing ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _toggleFollow,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_isFollowing ? "Following" : "Follow"),
                                if (_isFollowing) const Icon(Icons.keyboard_arrow_down, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text("Message", style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(40, 40),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const DiscoverPeopleScreen(title: "Discover People")
                            ));
                          },
                          child: const Icon(Icons.person_add_outlined, color: Colors.black, size: 20),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          if (_userPosts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text("No posts yet"),
              ),
            )
          else
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = _userPosts[index];
                  if (post.media.isNotEmpty) {
                    final firstMedia = post.media.first;
                    return MediaDisplayWidget(
                      mediaUrl: firstMedia.mediaUrl,
                      height: double.infinity,
                      width: double.infinity,
                    );
                  }
                  return Container(
                    color: Colors.grey.shade200,
                    padding: const EdgeInsets.all(4),
                    child: Center(
                      child: Text(
                        post.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
                childCount: _userPosts.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
