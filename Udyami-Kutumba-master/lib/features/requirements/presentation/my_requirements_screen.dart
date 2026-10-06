import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/api/requirements/requirements_api.dart';
import 'package:udyamikutumba/core/models/requirement_model.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';

class MyRequirementsScreen extends StatefulWidget {
  const MyRequirementsScreen({super.key});

  @override
  State<MyRequirementsScreen> createState() => _MyRequirementsScreenState();
}

class _MyRequirementsScreenState extends State<MyRequirementsScreen> {
  bool _isLoading = true;
  List<RequirementModel> _requirements = [];
  String _error = '';
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = SessionManager.user?['userId'] ?? '';
    _fetchMyRequirements();
  }

  Future<void> _fetchMyRequirements() async {
    if (_userId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'User not logged in';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await RequirementsAPI.getMyRequirements(_userId);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          final data = result['data'] as List;
          _requirements = data.map((e) => RequirementModel.fromJson(e)).toList();
        } else {
          _error = result['message'];
        }
      });
    }
  }

  Future<void> _deleteRequirement(String reqId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Requirement'),
        content: const Text('Are you sure you want to delete this requirement?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await RequirementsAPI.deleteRequirement(reqId, _userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      if (res['success']) {
        _fetchMyRequirements();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requirements'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : _requirements.isEmpty
                  ? const Center(child: Text("You haven't posted any requirements yet."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _requirements.length,
                      itemBuilder: (context, index) {
                        final req = _requirements[index];
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(req.category, style: const TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                                    if (req.status == 'Pending')
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _deleteRequirement(req.requirementId),
                                      )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  req.requirement,
                                  style: const TextStyle(fontSize: 15, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Source: ${req.source}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: req.status == 'Pending' ? Colors.orange.shade100 : Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(req.status, style: TextStyle(color: req.status == 'Pending' ? Colors.orange.shade800 : Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                if (req.interestedCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('${req.interestedCount} people interested', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
