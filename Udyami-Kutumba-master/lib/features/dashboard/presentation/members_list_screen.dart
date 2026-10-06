import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/session_manager.dart';

class MembersListScreen extends StatefulWidget {
  final String role;
  final String title;
  final String subtitle;
  final String type; // 'district', 'taluk', 'ward'

  const MembersListScreen({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  List<dynamic> _members = [];
  List<dynamic> _filteredMembers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/ward/usersByRole?role=${widget.role}");
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final users = data['data'] as List<dynamic>? ?? [];
        setState(() {
          _members = users;
          _filteredMembers = users;
        });
      }
    } catch (e) {
      print('Fetch Members Error: $e');
    }
    setState(() => _isLoading = false);
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMembers = _members;
      } else {
        _filteredMembers = _members.where((m) {
          final name = (m['name'] ?? '').toString().toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(widget.subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 16),
                TextField(
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMembers.isEmpty
                    ? const Center(child: Text("No records found."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredMembers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredMembers[index];
                          final name = user['name'] ?? 'Unknown';
                          final email = user['email'] ?? '';
                          final mobile = user['mobileNumber'] ?? '';
                          final status = user['status'] ?? 'active';
                          final stateStr = user['state'] ?? '';
                          final dist = user['districtName'] ?? '';
                          final taluk = user['talukaName'] ?? '';
                          final ward = user['wardName'] ?? '';

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Avatar
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.blue.shade100),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                                          style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            const SizedBox(height: 4),
                                            if (mobile.isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
                                                  const SizedBox(width: 4),
                                                  Text(mobile, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                                ],
                                              ),
                                            const SizedBox(height: 2),
                                            if (email.isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(Icons.email, size: 12, color: Colors.grey.shade500),
                                                  const SizedBox(width: 4),
                                                  Expanded(child: Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Status Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: status == 'active' ? Colors.green.shade50 : Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: status == 'active' ? Colors.green.shade100 : Colors.amber.shade100),
                                        ),
                                        child: Text(
                                          status == 'active' ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            color: status == 'active' ? Colors.green.shade700 : Colors.amber.shade700,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  
                                  // Location details based on type
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 12,
                                    children: [
                                      if (stateStr.isNotEmpty) _buildLocItem('State', stateStr, Icons.map),
                                      if (widget.type == 'district' || widget.type == 'taluk' || widget.type == 'ward') 
                                        if (dist.isNotEmpty) _buildLocItem('District', dist, Icons.location_city),
                                      if (widget.type == 'taluk' || widget.type == 'ward') 
                                        if (taluk.isNotEmpty) _buildLocItem('Taluk', taluk, Icons.holiday_village),
                                      if (widget.type == 'ward') 
                                        if (ward.isNotEmpty) _buildLocItem('Ward/Hobli', ward, Icons.home_work),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ],
    );
  }
}
