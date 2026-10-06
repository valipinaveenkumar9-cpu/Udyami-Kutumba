import 'package:flutter/material.dart';
import '../../../core/api/ubn/application/application_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;
  final bool isReadOnly;

  const ApplicationDetailScreen({super.key, required this.application, this.isReadOnly = false});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  bool _isSubmitting = false;
  late Map<String, dynamic> _app;

  @override
  void initState() {
    super.initState();
    _app = Map<String, dynamic>.from(widget.application);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Hold':
        return Colors.amber.shade700;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Hold':
        return Icons.pause_circle;
      default:
        return Icons.hourglass_top;
    }
  }

  Future<void> _reviewApplication(String status) async {
    String remarks = '';

    if (status != 'Approved') {
      final result = await showDialog<String>(
        context: context,
        builder: (c) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text('${status == 'Hold' ? 'Hold' : 'Reject'} Application'),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Remarks',
                hintText: status == 'Hold'
                    ? 'e.g. Need additional documents'
                    : 'e.g. Business category already occupied',
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(c, controller.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == 'Hold' ? Colors.amber.shade700 : Colors.red,
                ),
                child: Text(status, style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );

      if (result == null) return;
      remarks = result;
    } else {
      remarks = 'Application approved successfully.';
    }

    final userId = SessionManager.user?['userId']?.toString();
    if (userId == null) return;

    setState(() => _isSubmitting = true);

    final res = await ApplicationAPI.reviewApplication(
      applicationId: _app['applicationId'],
      status: status,
      remarks: remarks,
      reviewedBy: userId,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (res != null) {
        setState(() {
          _app['status'] = status;
          _app['remarks'] = remarks;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'Approved'
                  ? 'Approved — now a member'
                  : status == 'Hold'
                      ? 'Application put on hold'
                      : 'Application rejected',
            ),
            backgroundColor: _getStatusColor(status),
          ),
        );

        // Pop back with result to refresh the list
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _app['status'] ?? 'Pending';
    final statusColor = _getStatusColor(status);
    final isPending = status == 'Pending';

    final guestName = _app['guestName'] ?? _app['guest']?['fullName'] ?? 'Unknown';
    final initials = guestName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Application",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Applicant Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: Colors.deepPurple.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guestName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _app['businessCategory'] ?? '',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getStatusIcon(status), size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Business Details
                const Text(
                  "Business Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildDetailCard(Icons.category, "Category", _app['businessCategory'] ?? '-'),
                _buildDetailCard(Icons.subdirectory_arrow_right, "Sub-Category", _app['businessSubCategory'] ?? '-'),
                _buildDetailCard(Icons.label, "Tag", _app['businessTag'] ?? '-'),

                const SizedBox(height: 20),

                // Visit & KYC Info
                const Text(
                  "Verification",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Visits",
                        "${_app['visitCount'] ?? 0}",
                        Icons.event,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        "KYC",
                        _app['kycVerified'] == true ? "Verified" : "Pending",
                        _app['kycVerified'] == true ? Icons.verified : Icons.pending,
                        _app['kycVerified'] == true ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Remarks
                if (_app['remarks'] != null && _app['remarks'].toString().isNotEmpty) ...[
                  const Text(
                    "Remarks",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Text(
                      _app['remarks'].toString(),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Applied Date
                if (_app['createdAt'] != null)
                  _buildDetailCard(
                    Icons.calendar_today,
                    "Applied On",
                    _app['createdAt'].toString().split('T').first,
                  ),

                if (_app['reviewedBy'] != null) ...[
                  _buildDetailCard(Icons.person, "Reviewed By", _app['reviewedBy'].toString()),
                  if (_app['reviewedAt'] != null)
                    _buildDetailCard(
                      Icons.schedule,
                      "Reviewed At",
                      _app['reviewedAt'].toString().split('T').first,
                    ),
                ],

                // Action Buttons (only for Pending and if not read-only)
                if (isPending && !widget.isReadOnly) ...[
                  const SizedBox(height: 32),

                  // Warning Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Review this application carefully. Approved members will get full UCN access.",
                            style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Reject
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : () => _reviewApplication('Rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Hold
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : () => _reviewApplication('Hold'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber.shade700,
                            side: BorderSide(color: Colors.amber.shade700),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Hold", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Approve
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () => _reviewApplication('Approved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text("Approve", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),

          // Loading overlay
          if (_isSubmitting)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
