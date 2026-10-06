import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/session_manager.dart';

class PostNewsScreen extends StatefulWidget {
  const PostNewsScreen({super.key});

  @override
  State<PostNewsScreen> createState() => _PostNewsScreenState();
}

class _PostNewsScreenState extends State<PostNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _summaryCtrl = TextEditingController();
  final TextEditingController _sourceCtrl = TextEditingController();
  final TextEditingController _imageUrlCtrl = TextEditingController();
  final TextEditingController _sourceUrlCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();
  
  String _category = 'Business';
  bool _isFeatured = false;

  final List<String> _categories = [
    "Business", "Technology", "Policy", "Agriculture",
    "Finance", "Health", "Education", "Infrastructure",
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    _sourceCtrl.dispose();
    _imageUrlCtrl.dispose();
    _sourceUrlCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/news/createNews");
      
      final payload = {
        "title": _titleCtrl.text.trim(),
        "summary": _summaryCtrl.text.trim(),
        "body": _bodyCtrl.text.trim(),
        "category": _category,
        "source": _sourceCtrl.text.trim(),
        "imageUrl": _imageUrlCtrl.text.trim(),
        "sourceUrl": _sourceUrlCtrl.text.trim(),
        "publishedAt": DateTime.now().toIso8601String(),
        "isFeatured": _isFeatured,
      };

      print('DEV DEBUG - Post News Payload: $payload');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      print('DEV DEBUG - Post News Status: ${response.statusCode}');
      print('DEV DEBUG - Post News Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article created successfully!')));
        Navigator.pop(context, true); 
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
      appBar: AppBar(title: const Text('New Article')),
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
                      decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _summaryCtrl,
                      decoration: const InputDecoration(labelText: 'Summary *', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _sourceCtrl,
                            decoration: const InputDecoration(labelText: 'Source Name', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sourceUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Source URL', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bodyCtrl,
                      decoration: const InputDecoration(labelText: 'Body Content', border: OutlineInputBorder()),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Feature this article'),
                      subtitle: const Text('Will be pinned to the top of the feed'),
                      value: _isFeatured,
                      onChanged: (val) => setState(() => _isFeatured = val),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF1a1f3c),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submitForm,
                      child: const Text('Publish Article', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
