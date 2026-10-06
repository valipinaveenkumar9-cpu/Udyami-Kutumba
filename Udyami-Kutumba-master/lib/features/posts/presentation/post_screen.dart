import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:udyamikutumba/core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'package:udyamikutumba/core/api/ubn/feed_api.dart';
import '../../home/presentation/main_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _postController = TextEditingController();

  String selectedVisibility = 'Public';
  String selectedCategory = 'General';
  String? selectedLocation;
  String? selectedFeeling;
  List<String> taggedPeople = [];
  File? _selectedMedia;
  String? _mediaName;
  bool _isLoading = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? media = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return;

      if (media != null) {
        setState(() {
          _selectedMedia = File(media.path);
          _mediaName = media.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  Widget _optionButton(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty && _selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something or add media before posting.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    List<File>? images = _selectedMedia != null ? [_selectedMedia!] : null;

    // Combine tagged people, location etc into content if needed. For now just passing text.
    String fullContent = _postController.text.trim();
    if (selectedLocation != null) fullContent += '\nLocation: $selectedLocation';
    if (selectedFeeling != null) fullContent += '\nFeeling: $selectedFeeling';
    if (taggedPeople.isNotEmpty) fullContent += '\nTagged: ${taggedPeople.join(', ')}';

    print("DEV DEBUG - PostScreen _createPost initiated. Content: $fullContent");
    if (images != null) print("DEV DEBUG - PostScreen _createPost has ${images.length} images.");

    bool success = await FeedAPI.createPost(fullContent, images: images);
    print("DEV DEBUG - PostScreen _createPost success status: $success");

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
        ),
      );
      
      // Navigate to Home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,

      // ─────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Create Post',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,

        actions: [
              const ThemeToggleButton(),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isLoading ? null : _createPost,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Post',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),

      // ─────────────────────────────────────
      // BODY
      // ─────────────────────────────────────
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PROFILE
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              colorScheme.primary.withOpacity(.12),
                          backgroundImage: SessionManager.user?['profileImage'] != null
                              ? NetworkImage(SessionManager.user!['profileImage'])
                              : null,
                          child: SessionManager.user?['profileImage'] == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 28,
                                  color: colorScheme.primary,
                                )
                              : null,
                        ),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              SessionManager.user?['name'] ?? 'User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    selectedVisibility,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // TEXT FIELD
                    Container(
                      child: TextField(
                        controller: _postController,
                        maxLines: 7,
                        maxLength: 500,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: "What's on your mind?",
                          hintStyle: TextStyle(
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                          counterText: '',
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // MEDIA CARD
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        _pickMedia();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 145,
                        decoration: BoxDecoration(
                          color: _selectedMedia != null
                              ? colorScheme.primary.withOpacity(.15)
                              : colorScheme.primary.withOpacity(.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(.25),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withOpacity(.10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _selectedMedia != null ? Icons.check_circle_outline : Icons.add_photo_alternate_outlined,
                                color: colorScheme.primary,
                                size: 27,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              _selectedMedia != null ? 'Photo Selected' : 'Add Photo',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              _mediaName ?? 'Share a photo with your post',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM POST BUTTON
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 15),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Create Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : colorScheme.surfaceContainerHighest.withOpacity(.45),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomAction(IconData icon, String title, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(
                icon,
                size: 21,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}