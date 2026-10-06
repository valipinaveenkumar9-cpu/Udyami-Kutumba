import 'package:flutter/material.dart';
import 'package:udyamikutumba/features/jobs/job_apply_screen.dart';

import '../../core/models/job_model.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class JobPostScreen extends StatefulWidget {
  final JobModel job;
  const JobPostScreen({super.key, required this.job});

  @override
  State<JobPostScreen> createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: const Text("Job Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.business_center_rounded, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.job.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.job.companyName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_rounded, color: Colors.grey.shade500, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.job.location}, ${widget.job.city}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Grid
                  Row(
                    children: [
                      _buildQuickInfoCard(Icons.work_outline_rounded, "Experience", widget.job.experience),
                      const SizedBox(width: 16),
                      _buildQuickInfoCard(Icons.currency_rupee_rounded, "Salary", widget.job.salaryRange),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildQuickInfoCard(Icons.business_rounded, "Openings", widget.job.openings.toString()),
                      const SizedBox(width: 16),
                      _buildQuickInfoCard(Icons.schedule_rounded, "Job Type", widget.job.jobType),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  // Job Description
                  _buildSectionTitle("Job Description"),
                  const SizedBox(height: 12),
                  Text(
                    widget.job.requirements,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Required Skills (omitted since we just have requirements)
                  _buildSectionTitle("Category"),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: [
                      _buildSkillChip(widget.job.category),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  // Roles & Responsibilities
                  _buildSectionTitle("Roles & Responsibilities"),
                  const SizedBox(height: 12),
                  _buildBulletPoint("Develop Flutter mobile applications."),
                  _buildBulletPoint("Build responsive UI screens."),
                  _buildBulletPoint("Integrate REST APIs and Firebase."),
                  _buildBulletPoint("Debug and fix application issues."),
                  _buildBulletPoint("Improve app performance and write clean code."),

                  const SizedBox(height: 32),
                  
                  // Contact Details
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Contact Information",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        _buildContactRow(Icons.email_outlined, "careers@abctechnologies.com"),
                        const SizedBox(height: 12),
                        _buildContactRow(Icons.phone_outlined, "+91 9876543210"),
                        const SizedBox(height: 12),
                        _buildContactRow(Icons.language_rounded, "www.abctechnologies.com"),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JobApplyScreen(job: widget.job)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              "Apply Now",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade900.withValues(alpha: 0.2) : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade300 : Colors.orange.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade800,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue.shade700, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade800, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
