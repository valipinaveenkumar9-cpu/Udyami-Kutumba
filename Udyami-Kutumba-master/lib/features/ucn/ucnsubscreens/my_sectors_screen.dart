import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'sector_team_screen.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/models/user_profile_model.dart';

class MySectorsScreen extends StatefulWidget {
  const MySectorsScreen({super.key});

  @override
  State<MySectorsScreen> createState() => _MySectorsScreenState();
}

class _MySectorsScreenState extends State<MySectorsScreen> {
  List<String> _mySectors = [];

  @override
  void initState() {
    super.initState();
    _loadSectors();
  }

  void _loadSectors() {
    // In a real app, you might fetch this from an API like /sector/getMySectors.
    // Here we'll derive it from the user's business profile for now.
    try {
      final user = SessionManager.user;
      if (user != null && user['profile'] != null) {
        final profileData = ProfileDataModel.fromJson(user['profile']);
        if (profileData.hasBusiness && profileData.businessDetails != null) {
          final bType = profileData.businessDetails!.businessType;
          if (bType != null && bType.isNotEmpty) {
            // Extract the main Category from "Category | SubCategory | Tag"
            final parts = bType.split(RegExp(r'[|-]')).map((e) => e.trim()).toList();
            if (parts.isNotEmpty && parts[0].isNotEmpty) {
              _mySectors.add(parts[0]);
            }
          }
        }
      }
    } catch (e) {
      print("Error loading sectors: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "My Sectors",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _mySectors.isEmpty
          ? Center(
              child: Text(
                "You haven't joined any sectors yet.\nAdd a business in your profile to join one.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mySectors.length,
              itemBuilder: (context, index) {
                final sectorName = _mySectors[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SectorTeamScreen(sectorName: sectorName),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.teal.shade900 : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isDark ? Colors.teal.shade800 : Colors.teal.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.2),
                          radius: 24,
                          child: const Icon(Icons.work, color: Colors.teal),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sectorName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Tap to view team and leads",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.teal),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
