import 'package:flutter/material.dart';
import '../../../core/api/ubn/sector_api.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class SectorJoinReviewScreen extends StatefulWidget {
  final String? sectorJoinRequestId;

  const SectorJoinReviewScreen({super.key, this.sectorJoinRequestId});

  @override
  State<SectorJoinReviewScreen> createState() => _SectorJoinReviewScreenState();
}

class _SectorJoinReviewScreenState extends State<SectorJoinReviewScreen> {
  final SectorAPI _sectorApi = SectorAPI();
  bool _isLoading = true;
  Map<String, dynamic>? _request;

  @override
  void initState() {
    super.initState();
    _fetchRequest();
  }

  Future<void> _fetchRequest() async {
    if (widget.sectorJoinRequestId == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _sectorApi.getSectorRequestById(widget.sectorJoinRequestId!);
      if (mounted && response != null && response['success'] == true) {
        setState(() {
          _request = response['data'];
        });
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAction(String action) async {
    if (widget.sectorJoinRequestId == null) return;
    
    // For reject, prompt for remarks
    if (action == 'reject') {
      String remarks = '';
      final bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Reject Request"),
          content: TextField(
            onChanged: (v) => remarks = v,
            decoration: const InputDecoration(hintText: "Enter rejection remarks"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              child: const Text("Reject", style: TextStyle(color: Colors.red))
            ),
          ],
        ),
      );
      if (confirm != true) return;
      
      setState(() => _isLoading = true);
      final res = await _sectorApi.rejectRequest(widget.sectorJoinRequestId!, remarks);
      _finishAction(res);
      return;
    }

    setState(() => _isLoading = true);
    dynamic res;
    if (action == 'endorse') {
      res = await _sectorApi.endorseRequest(widget.sectorJoinRequestId!);
    } else if (action == 'approve') {
      res = await _sectorApi.approveRequest(widget.sectorJoinRequestId!);
    }
    _finishAction(res);
  }

  void _finishAction(dynamic res) {
    if (mounted) {
      setState(() => _isLoading = false);
      if (res != null && res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Action successful')));
        Navigator.pop(context); // Go back to dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action failed. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sector join review",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
              ? Center(child: Text("No request data found.", style: TextStyle(color: isDark ? Colors.white : Colors.black)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // User Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.shade200,
                              child: Text(
                                _request!['createdUser']?['name']?.substring(0, 1).toUpperCase() ?? "U",
                                style: TextStyle(color: isDark ? Colors.blue.shade300 : Colors.blue.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _request!['createdUser']?['name'] ?? 'Unknown Member',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _request!['createdUser']?['email'] ?? '',
                                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

            // Requested Tag Field
            _buildField(
              "Requested sector",
              Row(
                children: [
                  Expanded(child: Text(_request!['sector']?['sectorName'] ?? 'Unknown Sector', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.teal.withValues(alpha: 0.15) : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _request!['status'] ?? 'Open',
                      style: TextStyle(
                        color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              isDark,
            ),

            const SizedBox(height: 12),

            // Conflict Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.teal.withValues(alpha: 0.15) : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: isDark ? Colors.teal.shade300 : Colors.teal.shade700, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "No conflict — seat available",
                    style: TextStyle(
                      color: isDark ? Colors.teal.shade100 : Colors.teal.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (_request!['status'] == 'Open' || _request!['status'] == 'Endorsed')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAction('reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.red.withValues(alpha: 0.15) : Colors.red.shade50,
                        foregroundColor: isDark ? Colors.red.shade300 : Colors.red.shade700,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_request!['status'] == 'Open')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAction('endorse'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Endorse", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  if (_request!['status'] == 'Endorsed')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAction('approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Approve", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 16),

            // Footer
            Text(
              "Endorsement moves it to the Chairman's approval",
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, Widget child, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
