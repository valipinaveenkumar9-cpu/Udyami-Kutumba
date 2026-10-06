import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/api/requirements/requirements_api.dart';
import 'package:udyamikutumba/core/models/requirement_model.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';

class RequirementsScreen extends StatefulWidget {
  final int initialIndex;
  const RequirementsScreen({super.key, this.initialIndex = 0});

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> with SingleTickerProviderStateMixin {
  bool _isLoadingB2C = true;
  bool _isLoadingB2B = true;
  List<RequirementModel> _b2cRequirements = [];
  List<RequirementModel> _b2bRequirements = [];
  String _b2cError = '';
  String _b2bError = '';

  late TabController _tabController;
  
  String _selectedCategory = 'IT Services'; 
  final List<String> _categories = ['IT Services', 'Finance', 'Health', 'Education', 'Business', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _fetchAll();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    _fetchB2C();
    _fetchB2B();
  }

  Future<void> _fetchB2C() async {
    setState(() { _isLoadingB2C = true; _b2cError = ''; });
    String wardId = SessionManager.user?['wardId'] ?? 'fb565c5c-fa8b-4b8c-9607-d4fd1a212bd1';
    final result = await RequirementsAPI.getB2CRequirements(wardId, _selectedCategory);
    if (mounted) {
      setState(() {
        _isLoadingB2C = false;
        if (result['success']) {
          _b2cRequirements = (result['data'] as List).map((e) => RequirementModel.fromJson(e)).toList();
        } else {
          _b2cError = result['message'];
        }
      });
    }
  }

  Future<void> _fetchB2B() async {
    setState(() { _isLoadingB2B = true; _b2bError = ''; });
    String talukaId = SessionManager.user?['talukaId'] ?? 'f9a6257c-7cbe-4c1c-a25a-8403ee801110';
    final result = await RequirementsAPI.getB2BRequirements(talukaId, _selectedCategory);
    if (mounted) {
      setState(() {
        _isLoadingB2B = false;
        if (result['success']) {
          _b2bRequirements = (result['data'] as List).map((e) => RequirementModel.fromJson(e)).toList();
        } else {
          _b2bError = result['message'];
        }
      });
    }
  }

  Widget _buildList(bool isLoading, String error, List<RequirementModel> list) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
    if (list.isEmpty) return const Center(child: Text("No requirements found."));
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: list.length,
      itemBuilder: (context, index) => _RequirementCard(requirement: list[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Requirements', 
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 0,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0, right: 65.0),
        child: FloatingActionButton.extended(
          heroTag: 'requirements_fab',
          backgroundColor: Colors.teal,
          onPressed: () {
            // Can be extended to open a post dialog if needed.
          },
          icon: const Icon(Icons.add),
          label: const Text("Post Requirement"),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.teal,
              labelColor: Colors.teal,
              unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              tabs: const [
                Tab(text: 'B2C (Ward)'),
                Tab(text: 'B2B (Taluka)'),
              ],
            ),
          ),
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                          _fetchAll();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_isLoadingB2C, _b2cError, _b2cRequirements),
                _buildList(_isLoadingB2B, _b2bError, _b2bRequirements),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementCard extends StatefulWidget {
  final RequirementModel requirement;
  const _RequirementCard({required this.requirement});

  @override
  State<_RequirementCard> createState() => _RequirementCardState();
}

class _RequirementCardState extends State<_RequirementCard> {
  @override
  Widget build(BuildContext context) {
    final req = widget.requirement;
    final user = req.user;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
                  child: user?.profileImage == null ? Text(user?.name.substring(0, 1).toUpperCase() ?? 'U') : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(req.createdAt.split('T').first, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(req.category, style: const TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              req.requirement,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.source, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(req.source, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: req.status == 'Pending' ? Colors.orange.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(req.status, style: TextStyle(color: req.status == 'Pending' ? Colors.orange.shade800 : Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
