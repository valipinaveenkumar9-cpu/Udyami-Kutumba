import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/session_manager.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _salaryCtrl = TextEditingController();
  final TextEditingController _requirementsCtrl = TextEditingController();
  
  String _jobType = 'FULL_TIME';
  String _status = 'DRAFT';
  String _category = 'Sales';

  final List<String> _categories = [
    "Sales", "Accounting", "Marketing", "IT", "Operations", "HR", "Finance", "Design"
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _cityCtrl.dispose();
    _salaryCtrl.dispose();
    _requirementsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/jobs/createJob");
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "title": _titleCtrl.text.trim(),
          "companyName": _companyCtrl.text.trim(),
          "category": _category,
          "location": "",
          "city": _cityCtrl.text.trim(),
          "ward": "",
          "salaryRange": _salaryCtrl.text.trim(),
          "jobType": _jobType,
          "openings": 1,
          "experience": "",
          "requirements": _requirementsCtrl.text.trim(),
          "status": _status,
        }),
      );

      print('DEV DEBUG - Post Job Response Status: ${response.statusCode}');
      print('DEV DEBUG - Post Job Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Created successfully!')));
        Navigator.pop(context, true); // return true to refresh
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Job')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'Job Title', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _companyCtrl,
                      decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityCtrl,
                            decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _salaryCtrl,
                            decoration: const InputDecoration(labelText: 'Salary Range', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _jobType,
                      decoration: const InputDecoration(labelText: 'Job Type', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'FULL_TIME', child: Text('Full Time')),
                        DropdownMenuItem(value: 'PART_TIME', child: Text('Part Time')),
                        DropdownMenuItem(value: 'CONTRACT', child: Text('Contract')),
                        DropdownMenuItem(value: 'INTERNSHIP', child: Text('Internship')),
                      ],
                      onChanged: (v) => setState(() => _jobType = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                        DropdownMenuItem(value: 'OPEN', child: Text('Open')),
                        DropdownMenuItem(value: 'CLOSED', child: Text('Closed')),
                      ],
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _requirementsCtrl,
                      decoration: const InputDecoration(labelText: 'Requirements', border: OutlineInputBorder()),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF1a1f3c),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submitForm,
                      child: const Text('Post Job', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
