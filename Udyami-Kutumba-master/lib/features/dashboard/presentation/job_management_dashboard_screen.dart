import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/session_manager.dart';
import 'post_job_screen.dart';

class JobManagementDashboardScreen extends StatefulWidget {
  const JobManagementDashboardScreen({super.key});

  @override
  State<JobManagementDashboardScreen> createState() => _JobManagementDashboardScreenState();
}

class _JobManagementDashboardScreenState extends State<JobManagementDashboardScreen> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
      _jobs.clear();
    }
    if (!_hasMore) return;
    
    setState(() => _isLoading = true);
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/jobs/getAllJobs?page=$_page&limit=20");
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      
      print('DEV DEBUG - Job API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('DEV DEBUG - Job API RAW JSON: ${response.body}');
        final data = json.decode(response.body);
        
        List<dynamic>? newJobs;
        if (data['data'] is List) {
          newJobs = data['data'];
        } else if (data['jobs'] is List) {
          newJobs = data['jobs'];
        } else if (data['data'] != null && data['data']['jobs'] is List) {
          newJobs = data['data']['jobs'];
        }

        if (newJobs != null) {
          setState(() {
            _jobs.addAll(newJobs!);
            if (newJobs.length < 20) _hasMore = false;
            _page++;
          });
          print('DEV DEBUG - Parsed Jobs Count: ${_jobs.length}');
        } else {
           print('DEV DEBUG - Could not parse jobs array from response!');
        }
      } else {
        print('DEV DEBUG - Job API Error: ${response.body}');
      }
    } catch (e) {
      print('DEV DEBUG - Job API Exception: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteJob(String id) async {
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/jobs/deleteJob/$id");
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchJobs(reset: true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job deleted')));
      }
    } catch (e) {
      print('Delete Job Error: $e');
    }
  }

  Future<void> _toggleActive(String id, bool currentActive) async {
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/jobs/updateJob/$id");
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'active': !currentActive}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchJobs(reset: true);
      }
    } catch (e) {
      print('Toggle Active Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = _jobs.length;
    int openCount = _jobs.where((j) => j['status'] == 'OPEN').length;
    int closedCount = _jobs.where((j) => j['status'] == 'CLOSED').length;
    int draftCount = _jobs.where((j) => j['status'] == 'DRAFT').length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Job Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchJobs(reset: true),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostJobScreen()),
                );
                if (result == true) {
                  _fetchJobs(reset: true);
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Post Job'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a1f3c),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Review, moderate and remove jobs posted across the platform.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatCard('Total Jobs', total.toString(), Colors.blue),
                const SizedBox(width: 8),
                _buildStatCard('Open', openCount.toString(), Colors.green),
                const SizedBox(width: 8),
                _buildStatCard('Closed', closedCount.toString(), Colors.red),
                const SizedBox(width: 8),
                _buildStatCard('Draft', draftCount.toString(), Colors.grey),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Table
          Expanded(
            child: _isLoading && _jobs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _jobs.isEmpty
                    ? const Center(child: Text("No jobs found."))
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                              columns: const [
                                DataColumn(label: Text('Title / Company', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                DataColumn(label: Text('Posted by', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                DataColumn(label: Text('Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                DataColumn(label: Text('Apps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                DataColumn(label: Text('Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                              ],
                              rows: _jobs.map((job) {
                                final jobId = job['jobId'] ?? job['id'] ?? job['_id'];
                                final isActive = job['active'] == true;
                                final apps = job['apps'] ?? job['applicationsCount'] ?? 0;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(job['title'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          Text(job['companyName'] ?? job['company'] ?? '—', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(job['postedBy'] ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepPurple)),
                                          Text(job['createdAt'] != null ? job['createdAt'].toString().substring(0,10) : '—', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(job['city'] ?? job['ward'] ?? job['location'] ?? '—', style: const TextStyle(fontSize: 13, color: Colors.black87))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: job['status'] == 'OPEN' ? Colors.green.shade50 : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          job['status'] ?? 'DRAFT',
                                          style: TextStyle(
                                            color: job['status'] == 'OPEN' ? Colors.green.shade700 : Colors.grey.shade700,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: apps > 0 ? Colors.deepPurple : const Color(0xFF1a1f3c),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(apps.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    DataCell(
                                      InkWell(
                                        onTap: () => _toggleActive(jobId.toString(), isActive),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isActive ? const Color(0xFF1a1f3c) : Colors.grey.shade100,
                                            border: Border.all(color: isActive ? const Color(0xFF1a1f3c) : Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(isActive ? Icons.check_circle_outline : Icons.circle_outlined, size: 14, color: isActive ? Colors.white : Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(isActive ? 'Active' : 'Hidden', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () => _deleteJob(jobId.toString()),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
