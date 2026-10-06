import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/theme/app_colors.dart';
import '../../../core/api/directory/directory_api.dart';
import '../../jobs/directory_screen/member_directory_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _selectedSector = 'Construction';

  // API State
  String _searchQuery = "";
  String _selectedCategory = "All";
  List<String> _categories = [
    "All",
    "Automotive & Transportation",
    "Business Support",
    "Consulting & Corporate Services",
    "Agriculture, Dairy & Allied Sectors",
    "Construction, Building Materials & Real Estate",
    "Food, Beverage & Hospitality",
    "Media & Entertainment",
    "Pets & Animal Care",
    "Media",
    "Entertainment & Events",
    "Food & Beverage",
  ];
  final DirectoryAPI _directoryAPI = DirectoryAPI();
  List<MemberModel> _allMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  // --- API LOGIC ---
  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    try {
      final results = await _directoryAPI.getAllMembers();
      if (mounted) {
        setState(() {
          _allMembers = results.map((e) => MemberModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchMembers(String query) async {
    if (query.isEmpty) return _fetchMembers();
    setState(() => _isLoading = true);
    try {
      final results = await _directoryAPI.searchBusinessMembers(query);
      if (mounted) {
        setState(() {
          _allMembers = results.map((e) => MemberModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _searchMembers(query);
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case "All": return Icons.grid_view;
      case "Automotive & Transportation": return Icons.directions_car;
      case "Business Support": return Icons.business_center;
      case "Consulting & Corporate Services": return Icons.support_agent;
      case "Agriculture, Dairy & Allied Sectors": return Icons.agriculture;
      case "Construction, Building Materials & Real Estate": return Icons.construction;
      case "Food, Beverage & Hospitality": return Icons.restaurant;
      case "Media & Entertainment": return Icons.movie;
      case "Pets & Animal Care": return Icons.pets;
      case "Media": return Icons.perm_media;
      case "Entertainment & Events": return Icons.event;
      case "Food & Beverage": return Icons.local_cafe;
      default: return Icons.grid_view;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D12) : BackgroundColors.lightBackground;
    final textColor = isDark ? Colors.white : AppColorPalette.textBlack;
    final cardColor = isDark ? const Color(0xFF16161D) : Colors.white;

    final filteredMembers = _allMembers.where((m) {
      return _selectedCategory == "All" || m.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi Shahid 👋',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'I\'m here to help you with anything\nrelated to your sector.',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  ],
                ),
                const SizedBox(height: 24),
                
                
                
                // Ask Anything Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ask Anything',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Chat coming soon')));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF232330) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Type your question or request...',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6C47FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.send, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionBtn(
                              icon: Icons.phone_in_talk,
                              iconColor: Colors.green,
                              title: 'Call Enquiry',
                              subtitle: 'Talk to expert',
                              isDark: isDark,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Call Enquiry coming soon')));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionBtn(
                              icon: Icons.support_agent,
                              iconColor: const Color(0xFF6C47FF),
                              title: 'Request Callback',
                              subtitle: 'We will call you',
                              isDark: isDark,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Callback Request coming soon')));
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // ---- MEMBER DIRECTORY DOWNSIDE ----
                Text(
                  'Member Directory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 12),
                
                // Search
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Search members...",
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Category Chips
                SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF6C47FF) : cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: (!selected && !isDark) ? Border.all(color: Colors.grey.shade300) : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _categoryIcon(cat),
                                size: 15,
                                color: selected ? Colors.white : (isDark ? Colors.grey.shade400 : const Color(0xFF6C47FF)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat,
                                style: TextStyle(
                                  color: selected ? Colors.white : (isDark ? Colors.grey.shade400 : AppColorPalette.textBlack),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Members List
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(color: Color(0xFF6C47FF))))
                    : filteredMembers.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                "No members found.",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(), // Since it's inside SingleChildScrollView
                            shrinkWrap: true,
                            itemCount: filteredMembers.length,
                            itemBuilder: (context, index) {
                              final member = filteredMembers[index];
                              return MemberCard(
                                member: member,
                                categoryIcon: _categoryIcon(member.category),
                              );
                            },
                          ),
                          
                const SizedBox(height: 80), // Padding for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectorCard(String emoji, String title, bool isDark) {
    final isSelected = _selectedSector == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSector = title;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C47FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C47FF) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.black87),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232330) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColorPalette.textBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}