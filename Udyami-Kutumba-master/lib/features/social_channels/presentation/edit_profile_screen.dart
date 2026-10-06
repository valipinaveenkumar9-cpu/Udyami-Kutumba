import 'package:flutter/material.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/utils/session_manager.dart';
import '../data/social_channel_api.dart';
import 'widgets/marketos_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentWorkspace;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentWorkspace,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _workspaceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _workspaceController = TextEditingController(text: widget.currentWorkspace);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workspaceController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final socialApi = SocialChannelApi();
      final userId = socialApi.currentUserId;
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      final newName = _nameController.text.trim();
      final newWorkspace = _workspaceController.text.trim();

      // Send to Profile API
      final payload = {
        'name': newName,
        'businessDetails': {
          'businessName': newWorkspace,
        }
      };

      final api = ProfileAPI();
      final response = await api.updateUserProfile(userId, payload);

      if (response != null) {
        // Update SessionManager
        final user = SessionManager.user;
        if (user != null && SessionManager.token != null) {
          user['name'] = newName;
          user['businessName'] = newWorkspace;
          await SessionManager.saveSession(SessionManager.token!, user);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'), 
              backgroundColor: Color(0xFF1F8F5F), // MarketOS green
            ),
          );
          Navigator.pop(context, true); // true indicates success/refresh needed
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'), 
            backgroundColor: const Color(0xFFC23F2C), // MarketOS red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = MarketOSTheme.bg(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final surf = MarketOSTheme.surf(context);
    final line = MarketOSTheme.line(context);
    final gold = MarketOSTheme.gold(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surf,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: text),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: text,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: line, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your name',
                surf: surf,
                line: line,
                text: text,
                muted: muted,
                gold: gold,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Workspace Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _workspaceController,
                label: 'Workspace Name',
                hint: 'Enter your business/workspace name',
                surf: surf,
                line: line,
                text: text,
                muted: muted,
                gold: gold,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Workspace name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color surf,
    required Color line,
    required Color text,
    required Color muted,
    required Color gold,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: TextStyle(color: text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: muted.withValues(alpha: 0.5)),
            filled: true,
            fillColor: surf,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: gold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC23F2C)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC23F2C), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
