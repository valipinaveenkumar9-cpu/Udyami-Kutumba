import 'package:flutter/material.dart';
import '../../core/models/job_model.dart';
import '../../core/api/jobs/job_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class JobApplyScreen extends StatefulWidget {
  final JobModel? job;
  const JobApplyScreen({super.key, this.job});

  @override
  State<JobApplyScreen> createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends State<JobApplyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _currentSalaryCtrl = TextEditingController();
  final _expectedSalaryCtrl = TextEditingController();
  final _coverLetterCtrl = TextEditingController();

  String? _resumeUrl;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        _resumeUrl = result.files.single.name; // In a real app, upload this to a server and get URL
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_resumeUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload your resume')));
      return;
    }
    if (widget.job == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No job selected')));
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      "jobId": widget.job!.jobId,
      "fullName": _fullNameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "mobile": _mobileCtrl.text.trim(),
      "currentCity": _cityCtrl.text.trim(),
      "qualification": _qualificationCtrl.text.trim(),
      "experience": _experienceCtrl.text.trim(),
      "currentCompany": _companyCtrl.text.trim(),
      "currentSalary": _currentSalaryCtrl.text.trim(),
      "expectedSalary": _expectedSalaryCtrl.text.trim(),
      "resumeUrl": _resumeUrl, // Dummy URL logic
      "coverLetter": _coverLetterCtrl.text.trim(),
    };

    final success = await JobAPI.applyJob(payload);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application Submitted successfully!')));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit application')));
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _cityCtrl.dispose();
    _qualificationCtrl.dispose();
    _experienceCtrl.dispose();
    _companyCtrl.dispose();
    _currentSalaryCtrl.dispose();
    _expectedSalaryCtrl.dispose();
    _coverLetterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: const Text("Apply for Job", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.job != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Text("Applying for: ${widget.job!.title} at ${widget.job!.companyName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    const SizedBox(height: 24),
                    
                    _buildField(_fullNameCtrl, "Full Name", Icons.person),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildField(_emailCtrl, "Email", Icons.email)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField(_mobileCtrl, "Mobile", Icons.phone)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildField(_cityCtrl, "Current City", Icons.location_city)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField(_qualificationCtrl, "Qualification", Icons.school)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildField(_experienceCtrl, "Total Experience", Icons.work_history),
                    const SizedBox(height: 16),
                    _buildField(_companyCtrl, "Current Company", Icons.business),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildField(_currentSalaryCtrl, "Current Salary", Icons.attach_money)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField(_expectedSalaryCtrl, "Expected Salary", Icons.attach_money)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _coverLetterCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Cover Letter",
                        prefixIcon: const Icon(Icons.edit_document),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Resume Upload
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: _resumeUrl != null ? Colors.green : theme.colorScheme.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(_resumeUrl != null ? Icons.check_circle : Icons.upload_file, color: _resumeUrl != null ? Colors.green : theme.colorScheme.primary, size: 40),
                          const SizedBox(height: 8),
                          Text(_resumeUrl ?? "Upload Resume (PDF, DOCX)", style: TextStyle(fontWeight: FontWeight.bold, color: _resumeUrl != null ? Colors.green : null)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _pickFile,
                            child: const Text("Choose File"),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: Text("Submit Application", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
    );
  }
}
