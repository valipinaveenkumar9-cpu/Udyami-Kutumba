import 'dart:convert' as dart_convert;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:udyamikutumba/core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/media_display_widget.dart';
import 'package:udyamikutumba/core/widgets/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/models/post_model.dart';
import 'package:udyamikutumba/core/api/ubn/feed_api.dart';
import 'package:udyamikutumba/core/models/user_model.dart';
import 'package:udyamikutumba/features/posts/presentation/post_screen.dart';
import 'package:udyamikutumba/features/home/presentation/user_profile_screen.dart';

// ─────────────────────────────────────────────
// Comment Bottom Sheet
// ─────────────────────────────────────────────
class _CommentBottomSheet extends StatefulWidget {
  final String currentUserAvatar;
  final PostModel post;
  final void Function() onCommentAdded;

  const _CommentBottomSheet({
    required this.currentUserAvatar,
    required this.post,
    required this.onCommentAdded,
  });

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingComments = true;
  List<CommentModel> _localComments = [];

  static const List<String> _quickEmojis = [
    "❤️",
    "🙌",
    "🔥",
    "👏",
    "😢",
    "😍",
    "😮",
    "😂",
  ];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final fetched = await FeedAPI.getComments(widget.post.postId);
    if (mounted) {
      setState(() {
        _localComments = fetched.isEmpty
            ? List.from(widget.post.commentList)
            : fetched;
        _isLoadingComments = false;
      });
    }
  }

  void _appendEmoji(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;
    final insertPos = selection.isValid ? selection.baseOffset : text.length;
    final newText =
        text.substring(0, insertPos) + emoji + text.substring(insertPos);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: insertPos + emoji.length),
    );
    _focusNode.requestFocus();
  }

  void _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final newComment = await FeedAPI.addComment(widget.post.postId, text);

    if (newComment != null && mounted) {
      widget.onCommentAdded();
      _controller.clear();
      
      setState(() {
        _localComments.add(newComment);
      });
      
      // Scroll to bottom after updating list
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to post comment')));
    }
  }

  void _showCommentOptions(BuildContext context, CommentModel comment) {
    final currentUserId = SessionManager.user?['userId'];
    final isCommentOwner = currentUserId != null && comment.userId == currentUserId;
    final isPostOwner = currentUserId != null && widget.post.userId == currentUserId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Share logic (in-app or external)
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  // Report logic
                },
              ),
              if (isCommentOwner || isPostOwner)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await FeedAPI.deleteComment(comment.commentId);
                    if (success && mounted) {
                      setState(() {
                        _localComments.removeWhere((c) => c.commentId == comment.commentId);
                      });
                      widget.onCommentAdded(); // Using this to trigger UI update in parent
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete comment')),
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, sheetScrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // ── Drag handle ──
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // ── Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Comments",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_localComments.length}",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: Colors.grey.shade800, height: 16),

                // ── Comment list ──
                Expanded(
                  child: _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : _localComments.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.grey.shade700,
                                  size: 48,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No comments yet.\nBe the first to comment!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: sheetScrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _localComments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final c = _localComments[index];
                            return GestureDetector(
                              onLongPress: () {
                                _showCommentOptions(context, c);
                              },
                              child: Container(
                                color: Colors.transparent, // Ensure gesture detector works on entire row
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(c.profileImage),
                                    ),
                                    const SizedBox(width: 12),

                                    // Name, Text, Reply
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: c.name,
                                                  style: TextStyle(
                                                    color: Theme.of(context).brightness == Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const TextSpan(text: "  "),
                                                TextSpan(
                                                  text: c.time, // E.g., '1h' or '1s'
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            c.text,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {}, // Reply functionality stub
                                                child: Text(
                                                  "Reply",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              GestureDetector(
                                                onTap: () {}, // Translation stub
                                                child: Text(
                                                  "See translation",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Like icon and count on far right
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final wasLiked = c.isLiked;
                                            setState(() {
                                              c.isLiked = !wasLiked;
                                              c.reactionCount += wasLiked ? -1 : 1;
                                            });
                                            if (!wasLiked) {
                                              final success = await FeedAPI.addCommentReaction(c.commentId, "love");
                                              if (!success && mounted) {
                                                setState(() {
                                                  c.isLiked = wasLiked;
                                                  c.reactionCount -= 1;
                                                });
                                              }
                                            }
                                            // Handle unliking if there was an endpoint for it
                                          },
                                          child: Icon(
                                            c.isLiked ? Icons.favorite : Icons.favorite_border,
                                            size: 16,
                                            color: c.isLiked ? Colors.red : Colors.grey.shade600,
                                          ),
                                        ),
                                        if (c.reactionCount > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              "${c.reactionCount}",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ── Quick emoji row ──
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade800),
                      bottom: BorderSide(color: Colors.grey.shade800),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _quickEmojis
                        .map(
                          (emoji) => GestureDetector(
                            onTap: () => _appendEmoji(emoji),
                            child: Text(emoji, style: TextStyle(fontSize: 28)),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // ── Input row ──
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 10,
                    bottom: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.currentUserAvatar),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 46),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  autofocus: true,
                                  maxLines: null,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 15,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: "Write a comment…",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Use the emoji row above 👆",
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.sentiment_satisfied_alt_outlined,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: _sendComment,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Color(0xff1877F2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).colorScheme.surface,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Likes Bottom Sheet
// ─────────────────────────────────────────────
class _LikesBottomSheet extends StatefulWidget {
  final PostModel post;

  const _LikesBottomSheet({required this.post});

  @override
  State<_LikesBottomSheet> createState() => _LikesBottomSheetState();
}

class _LikesBottomSheetState extends State<_LikesBottomSheet> {
  bool _isLoading = true;
  List<UserModel> _likes = [];

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  Future<void> _fetchLikes() async {
    final fetched = await FeedAPI.getLikes(widget.post.postId);
    if (mounted) {
      setState(() {
        _likes = fetched;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, sheetScrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Likes",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey.shade800, height: 16),

              // ── Likes list ──
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _likes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up_off_alt,
                              color: Colors.grey.shade700,
                              size: 48,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No likes yet.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: sheetScrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _likes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final u = _likes[index];
                          final profileImage =
                              (u.profileImage != null &&
                                  u.profileImage!.isNotEmpty)
                              ? u.profileImage!
                              : 'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(u.name)}';
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(profileImage),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.name,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (u.companyName != null ||
                                        u.userType != null)
                                      Text(
                                        u.companyName ?? u.userType ?? '',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (SessionManager.user?['userId'] == widget.post.userId || SessionManager.user?['userId'] == u.userId)
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                  onPressed: () async {
                                    final success = await FeedAPI.removeUserLike(widget.post.postId, u.userId);
                                    if (success && mounted) {
                                      setState(() {
                                        _likes.removeAt(index);
                                        widget.post.likeCount = (widget.post.likeCount > 0) ? widget.post.likeCount - 1 : 0;
                                        // If it was our own like, also update isLiked
                                        if (SessionManager.user?['userId'] == u.userId) {
                                          widget.post.isLiked = false;
                                        }
                                      });
                                    } else if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to remove like')),
                                      );
                                    }
                                  },
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Home Screen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PostModel> posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    print("DEV DEBUG - HomeScreen _fetchPosts started");
    setState(() => _isLoading = true);
    final fetchedPosts = await FeedAPI.getAllPosts();
    
    final currentUserId = SessionManager.user?['userId'];
    if (currentUserId != null) {
      try {
        final followingData = await FeedAPI.getFollowing(currentUserId.toString());
        if (followingData != null) {
          final followingList = followingData['following'] as List?;
          if (followingList != null) {
            final followingIds = followingList.map((f) => f['userId']?.toString()).toSet();
            for (var post in fetchedPosts) {
              if (followingIds.contains(post.userId)) {
                post.isFollowing = true;
              }
            }
          }
        }
      } catch (e) {
        print("DEV DEBUG - Error mapping following status: $e");
      }
    }

    print(
      "DEV DEBUG - HomeScreen _fetchPosts fetched ${fetchedPosts.length} posts",
    );
    if (mounted) {
      setState(() {
        posts = fetchedPosts;
        _isLoading = false;
      });
      print(
        "DEV DEBUG - HomeScreen _fetchPosts UI updated. Total posts to display: ${posts.length}",
      );
    }
  }

  void _showCommentSheet(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentBottomSheet(
        currentUserAvatar:
            "https://api.dicebear.com/7.x/initials/png?seed=User",
        post: post,
        onCommentAdded: () {
          setState(() {
            post.commentCount++;
          });
        },
      ),
    );
  }

  void _showLikesSheet(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LikesBottomSheet(post: post),
    );
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

  Widget _buildCreatePostHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 1,
      color: isDark ? Colors.grey.shade900 : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.transparent),
      ),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCreatePostHeader(context, theme, isDark);
                      }
                      final post = posts[index - 1];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        elevation: 1,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.transparent),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Profile header ──
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfileScreen(
                                            userId: post.userId,
                                            userName: post.name,
                                            initialFollowing: post.isFollowing,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(
                                        post.profileImage,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserProfileScreen(
                                              userId: post.userId,
                                              userName: post.name,
                                              initialFollowing: post.isFollowing,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white
                                                  : const Color(0xff0D1B4C),
                                            ),
                                          ),
                                          Text(
                                            post.role,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            "${post.timeAgo} • 🌐",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (SessionManager.user?['userId'] != post.userId)
                                    TextButton.icon(
                                      onPressed: () async {
                                        final wasFollowing = post.isFollowing;
                                        final success =
                                            wasFollowing ? await FeedAPI.unfollowUser(post.userId) : await FeedAPI.followUser(post.userId);
                                        if (success && mounted) {
                                          setState(() {
                                            post.isFollowing = !wasFollowing;
                                          });
                                          SessionManager.profileUpdateNotifier.value++;
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to update follow status',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        post.isFollowing
                                            ? Icons.check
                                            : Icons.add,
                                        size: 16,
                                        color: post.isFollowing
                                            ? Colors.grey
                                            : Colors.teal,
                                      ),
                                      label: Text(
                                        post.isFollowing ? "Following" : "Follow",
                                        style: TextStyle(
                                          color: post.isFollowing
                                              ? Colors.grey
                                              : Colors.teal,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Edit feature coming soon.')),
                                        );
                                      } else if (value == 'delete') {
                                        final success = await FeedAPI.deletePost(post.postId);
                                        if (success && mounted) {
                                          setState(() {
                                            posts.removeWhere((p) => p.postId == post.postId);
                                          });
                                          SessionManager.profileUpdateNotifier.value++;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Post deleted successfully.')),
                                          );
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Failed to delete post')),
                                          );
                                        }
                                      } else if (value == 'report') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Post reported.')),
                                        );
                                      } else if (value == 'share') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Sharing not fully implemented yet.')),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) {
                                      final isOwner = SessionManager.user?['userId'].toString() == post.userId;
                                      return [
                                        if (isOwner)
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit Post'),
                                          ),
                                        if (isOwner)
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        if (!isOwner)
                                          const PopupMenuItem(
                                            value: 'report',
                                            child: Text('Report Post'),
                                          ),
                                      ];
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ── Post image ──
                              if (post.postImage != null &&
                                  post.postImage!.isNotEmpty)
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

                              // ── Caption ──
                              if (post.caption.isNotEmpty)
                                ExpandableText(
                                  text: post.caption,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    height: 1.4,
                                  ),
                                ),

                              const SizedBox(height: 12),

                              // ── Likes and Comments Summary ──
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showLikesSheet(context, post),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.teal,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.thumb_up,
                                            size: 10,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${post.likes}",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () =>
                                        _showCommentSheet(context, post),
                                    child: Text(
                                      "${post.comments} comments",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Divider(
                                  height: 1,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.black12,
                                ),
                              ),

                              // ── Action row ──
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildActionButton(
                                    icon: post.isLiked
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_alt_outlined,
                                    label: "Like",
                                    color: post.isLiked
                                        ? Colors.teal
                                        : isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                    onTap: () async {
                                      final wasLiked = post.isLiked;
                                      
                                      // Optimistic update
                                      setState(() {
                                        post.isLiked = !wasLiked;
                                        post.isLiked
                                            ? post.likeCount++
                                            : post.likeCount--;
                                      });

                                      final success = wasLiked
                                          ? await FeedAPI.unlikePost(
                                              post.postId,
                                            )
                                          : await FeedAPI.likePost(post.postId);

                                      if (!success && mounted) {
                                        // Revert on failure
                                        setState(() {
                                          post.isLiked = wasLiked;
                                          post.isLiked
                                              ? post.likeCount++
                                              : post.likeCount--;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to update like',
                                            ),
                                          ),
                                        );
                                      }

                                    },
                                  ),
                                  _buildActionButton(
                                    icon: Icons.chat_bubble_outline,
                                    label: "Comment",
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                    onTap: () =>
                                        _showCommentSheet(context, post),
                                  ),
                                  _buildActionButton(
                                    icon: Icons.share_outlined,
                                    label: "Share",
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                    onTap: () async {
                                      final userName = post.user?.name ?? 'A user';
                                      final String appUrl = "https://udyamicircle.com/post/${post.postId}";
                                      try {
                                        await FeedAPI.sharePost(post.postId, appUrl);
                                      } catch (e) {
                                        debugPrint("Share tracking failed: $e");
                                      }
                                      
                                      final shareText = "$userName posted on Udyami Kutumba:\n\n${post.content}\n\nRead more: $appUrl";
                                      
                                      if (post.postImage != null && post.postImage!.isNotEmpty) {
                                        try {
                                          Uint8List? bytes;
                                          if (post.postImage!.startsWith('http')) {
                                            final response = await http.get(Uri.parse(post.postImage!));
                                            if (response.statusCode == 200) bytes = response.bodyBytes;
                                          } else if (post.postImage!.startsWith('data:image')) {
                                            final base64Str = post.postImage!.split(',').last;
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

                              // ── Preview of latest comment ──
                              if (post.commentList.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...post.commentList
                                          .take(1)
                                          .map(
                                            (c) => RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                  fontSize: 13,
                                                  height: 1.3,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "${c.name}  ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(text: c.text),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ],
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





