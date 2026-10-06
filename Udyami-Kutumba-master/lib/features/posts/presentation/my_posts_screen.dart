import 'dart:convert' as dart_convert;
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:udyamikutumba/core/widgets/media_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/expandable_text.dart';
import 'package:udyamikutumba/core/models/post_model.dart';
import 'package:udyamikutumba/core/api/ubn/feed_api.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class MyPostsScreen extends StatefulWidget {
  final String emptyMessage;
  const MyPostsScreen({super.key, this.emptyMessage = 'No posts found'});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  List<PostModel> posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyPosts();
  }

  Future<void> _fetchMyPosts() async {
    setState(() => _isLoading = true);
    
    final userId = SessionManager.user?['userId'];
    print("DEV DEBUG - Fetching My Posts for userId: $userId");

    final fetchedPosts = await FeedAPI.getAllPosts();
    print("DEV DEBUG - Total Posts Fetched: ${fetchedPosts.length}");

    if (mounted) {
      setState(() {
        if (userId != null) {
          posts = fetchedPosts.where((p) => p.userId == userId || p.userId == userId.toString()).toList();
        } else {
          posts = fetchedPosts;
        }
        print("DEV DEBUG - Filtered My Posts: ${posts.length}");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        actions: const [ThemeToggleButton()],
      ),
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _fetchMyPosts,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : posts.isEmpty 
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                      Center(child: Text(widget.emptyMessage)),
                    ],
                  )
                : Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 1,
                  color: isDark ? Colors.grey.shade900 : theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.transparent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(post.profileImage),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : const Color(0xff0D1B4C),
                                    ),
                                  ),

                                  Text(
                                    post.role,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  Text(
                                    "${post.timeAgo} • 🌐",
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (post.postImage != null && post.postImage!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: MediaDisplayWidget(
                                mediaUrl: post.postImage!,
                                height: 250,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        if (post.caption.isNotEmpty)
                          ExpandableText(
                            text: post.caption,
                            style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface, height: 1.4),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                              child: Icon(Icons.thumb_up, size: 10, color: theme.colorScheme.surface),
                            ),
                            const SizedBox(width: 6),
                            Text("${post.likes}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const Spacer(),
                            Text("${post.comments} comments", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
