import 'package:flutter/material.dart';
import '../../../core/api/ubn/application/application_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class ApplyMembershipScreen extends StatefulWidget {
  const ApplyMembershipScreen({super.key});

  @override
  State<ApplyMembershipScreen> createState() => _ApplyMembershipScreenState();
}

class _ApplyMembershipScreenState extends State<ApplyMembershipScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _existingApplication;

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
  }

  Future<void> _checkExistingApplication() async {
    final userId = SessionManager.user?['userId']?.toString();
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await ApplicationAPI.getApplicationByGuestId(userId);
      if (res != null && res['success'] == true && res['data'] != null) {
        if (mounted) {
          setState(() {
            _existingApplication = res['data'];
          });
        }
      }
    } catch (e) {
      print('DEV DEBUG - error - apply_membership_screen.dart - Check existing: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Hold':
        return Colors.amber;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          "UCN Membership",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _existingApplication != null
              ? _buildExistingApplicationView()
              : _buildNoApplicationView(),
    );
  }

  Widget _buildNoApplicationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // How to join
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Icon(Icons.groups_rounded, color: Colors.teal.shade700, size: 48),
                const SizedBox(height: 16),
                Text(
                  "How to join UCN",
                  style: TextStyle(
                    color: Colors.teal.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "To join Udyami Circle Network, an existing UCN member needs to invite you. Once invited, a Circle Leader will review and approve your membership.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.teal.shade800, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Steps
          _buildStep("1", "Get invited", "Ask an existing UCN member to invite you from their Guests → Invite to UCN screen.", Icons.person_add),
          _buildStep("2", "Application reviewed", "A Circle Leader will review your business details and category fit.", Icons.rate_review),
          _buildStep("3", "Approved & join", "Once approved, you'll get full access to the UCN dashboard, leads, meetings, and more.", Icons.verified),

          const SizedBox(height: 24),

          // Contact info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Know a UCN member? Ask them to register you as a guest and submit your membership invite.",
                    style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingApplicationView() {
    final status = _existingApplication!['status'] ?? 'Pending';
    final statusColor = _getStatusColor(status);
    final remarks = _existingApplication!['remarks'] ?? '';
    final createdAt = _existingApplication!['createdAt'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  status == 'Approved'
                      ? Icons.check_circle
                      : status == 'Rejected'
                          ? Icons.cancel
                          : status == 'Hold'
                              ? Icons.pause_circle
                              : Icons.hourglass_top,
                  color: statusColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  "Application $status",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (status == 'Pending') ...[
                  const SizedBox(height: 8),
                  Text(
                    "Your application is being reviewed by a Circle Leader.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
                if (status == 'Approved') ...[
                  const SizedBox(height: 8),
                  Text(
                    "Welcome to Udyami Circle Network! You're now a member.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
                if (status == 'Rejected') ...[
                  const SizedBox(height: 8),
                  Text(
                    "Your application was not approved at this time.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details
          _buildInfoRow("Business Category", _existingApplication!['businessCategory'] ?? '-'),
          _buildInfoRow("Sub-Category", _existingApplication!['businessSubCategory'] ?? '-'),
          _buildInfoRow("Business Tag", _existingApplication!['businessTag'] ?? '-'),
          if (remarks.toString().isNotEmpty) _buildInfoRow("Remarks", remarks.toString()),
          if (createdAt.toString().isNotEmpty) _buildInfoRow("Applied On", createdAt.toString().split('T').first),
          if (_existingApplication!['reviewedBy'] != null)
            _buildInfoRow("Reviewed By", _existingApplication!['reviewedBy'].toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}
