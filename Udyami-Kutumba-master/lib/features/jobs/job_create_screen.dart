import 'package:flutter/material.dart';
import '../../core/api/jobs/job_api.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class JobCreateScreen extends StatefulWidget {
  const JobCreateScreen({super.key});

  @override
  State<JobCreateScreen> createState() => _JobCreateScreenState();
}

class _JobCreateScreenState extends State<JobCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _wardController = TextEditingController();
  final _salaryController = TextEditingController();
  final _experienceController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _openingsController = TextEditingController(text: '1');
  
  String _jobType = 'FULL_TIME';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _wardController.dispose();
    _salaryController.dispose();
    _experienceController.dispose();
    _requirementsController.dispose();
    _openingsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      "title": _titleController.text.trim(),
      "companyName": _companyController.text.trim(),
      "category": _categoryController.text.trim(),
      "location": _locationController.text.trim(),
      "city": _cityController.text.trim(),
      "ward": _wardController.text.trim(),
      "salaryRange": _salaryController.text.trim(),
      "jobType": _jobType,
      "openings": int.tryParse(_openingsController.text) ?? 1,
      "experience": _experienceController.text.trim(),
      "requirements": _requirementsController.text.trim(),
    };

    final success = await JobAPI.createJob(payload);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted successfully!')));
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to post job. It may already exist.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: const Text("Post a Job", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildField(_titleController, "Job Title", Icons.title),
                    const SizedBox(height: 16),
                    _buildField(_companyController, "Company Name", Icons.business),
                    const SizedBox(height: 16),
                    _buildField(_categoryController, "Category (e.g. Sales, IT)", Icons.category),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildField(_locationController, "Location", Icons.location_on)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField(_cityController, "City", Icons.location_city)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildField(_wardController, "Ward", Icons.map),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildField(_salaryController, "Salary Range", Icons.attach_money)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField(_experienceController, "Experience", Icons.work_history)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildField(_openingsController, "Openings", Icons.numbers, isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _jobType,
                            decoration: InputDecoration(
                              labelText: "Job Type",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'FULL_TIME', child: Text('Full Time')),
                              DropdownMenuItem(value: 'PART_TIME', child: Text('Part Time')),
                              DropdownMenuItem(value: 'CONTRACT', child: Text('Contract')),
                              DropdownMenuItem(value: 'INTERNSHIP', child: Text('Internship')),
                              DropdownMenuItem(value: 'FREELANCE', child: Text('Freelance')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _jobType = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _requirementsController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Requirements",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: const Icon(Icons.list),
                      ),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _submit,
                      child: const Text("Post Job", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
    );
  }
}
