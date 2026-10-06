import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert' as dart_convert;
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:udyamikutumba/core/models/post_model.dart';
import 'package:udyamikutumba/core/api/ubn/feed_api.dart';
import 'package:udyamikutumba/core/widgets/media_display_widget.dart';
import 'package:udyamikutumba/features/home/presentation/user_profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final post = await FeedAPI.getPost(widget.postId);
    
    if (mounted) {
      setState(() {
        _post = post;
        _isLoading = false;
        if (post == null) {
          _error = 'Could not load post details.';
        }
      });
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      elevation: 1,
                      color: isDark ? Colors.grey.shade900 : theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfileScreen(
                                          userId: _post!.userId,
                                          userName: _post!.name,
                                          initialFollowing: _post!.isFollowing,
                                        ),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(_post!.profileImage),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _post!.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark ? Colors.white : const Color(0xff0D1B4C),
                                        ),
                                      ),
                                      Text(
                                        _post!.role,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "${_post!.timeAgo} • 🌐",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Caption
                            Text(
                              _post!.caption,
                              style: TextStyle(
                                fontSize: 15,
                                color: theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Post image
                            if (_post!.postImage != null && _post!.postImage!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: MediaDisplayWidget(
                                  mediaUrl: _post!.postImage!,
                                  height: 250,
                                  width: double.infinity,
                                ),
                              ),
                            const SizedBox(height: 12),

                            // Likes and Comments count
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.teal,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.thumb_up,
                                    size: 10,
                                    color: theme.colorScheme.surface,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${_post!.likes}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${_post!.comments} comments",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                height: 1,
                                color: isDark ? Colors.grey.shade800 : Colors.black12,
                              ),
                            ),

                            // Action row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(
                                  icon: _post!.isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                  label: "Like",
                                  color: _post!.isLiked
                                      ? Colors.teal
                                      : isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade700,
                                  onTap: () async {
                                    final wasLiked = _post!.isLiked;
                                    
                                    // Optimistic update
                                    setState(() {
                                      _post!.isLiked = !wasLiked;
                                      _post!.isLiked ? _post!.likeCount++ : _post!.likeCount--;
                                    });

                                    final success = wasLiked
                                        ? await FeedAPI.unlikePost(_post!.postId)
                                        : await FeedAPI.likePost(_post!.postId);

                                    if (!success && mounted) {
                                      // Revert on failure
                                      setState(() {
                                        _post!.isLiked = wasLiked;
                                        _post!.isLiked ? _post!.likeCount++ : _post!.likeCount--;
                                      });
                                    }
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.chat_bubble_outline,
                                  label: "Comment",
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  onTap: () {
                                    // Just show a snackbar for now
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Open the app feed to comment.')),
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.share_outlined,
                                  label: "Share",
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  onTap: () async {
                                    final userName = _post!.name;
                                    final String appUrl = "https://udyamicircle.com/post/${_post!.postId}";
                                    await FeedAPI.sharePost(_post!.postId, appUrl);
                                    
                                    final shareText = "$userName posted on Udyami Kutumba:\n\n${_post!.content}\n\nRead more: $appUrl";
                                    
                                    if (_post!.postImage != null && _post!.postImage!.isNotEmpty) {
                                      try {
                                        List<int>? bytes;
                                        if (_post!.postImage!.startsWith('http')) {
                                          final response = await http.get(Uri.parse(_post!.postImage!));
                                          if (response.statusCode == 200) bytes = response.bodyBytes;
                                        } else if (_post!.postImage!.startsWith('data:image')) {
                                          final base64Str = _post!.postImage!.split(',').last;
                                          bytes = dart_convert.base64Decode(base64Str);
                                        }

                                        if (bytes != null && bytes.isNotEmpty) {
                                          final tempDir = await getTemporaryDirectory();
                                          final file = File('${tempDir.path}/shared_post_image.jpg');
                                          await file.writeAsBytes(bytes);

                                          final xfile = share_plus.XFile(file.path);
                                          await share_plus.Share.shareXFiles([xfile], text: shareText);
                                          return;
                                        }
                                      } catch (e) {
                                        debugPrint('Error preparing image for share: $e');
                                      }
                                    }
                                    share_plus.Share.share(shareText);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
