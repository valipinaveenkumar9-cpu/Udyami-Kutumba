import 'package:flutter/material.dart';
import '../../../core/api/ubn/guest_api.dart';
import '../../../core/models/guest_model.dart';
import '../../../core/utils/session_manager.dart';
import 'package:intl/intl.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class GuestsHistoryScreen extends StatefulWidget {
  final String? targetUserId;
  const GuestsHistoryScreen({super.key, this.targetUserId});

  @override
  State<GuestsHistoryScreen> createState() => _GuestsHistoryScreenState();
}

class _GuestsHistoryScreenState extends State<GuestsHistoryScreen> {
  bool _isLoading = true;
  List<GuestModel> _guests = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = widget.targetUserId ?? SessionManager.user?['userId']?.toString();
    _fetchGuests();
  }

  Future<void> _fetchGuests() async {
    setState(() {
      _isLoading = true;
    });

    final res = await GuestAPI.getAllGuests();
    if (res != null && res['success'] == true) {
      final data = res['data'] as List? ?? [];
      final allGuests = data.map((g) => GuestModel.fromJson(g)).toList();
      
      // Filter guests to only show those created by current user
      if (_currentUserId != null) {
        _guests = allGuests.where((g) => g.createdUser?.userId == _currentUserId).toList();
      } else {
        _guests = allGuests;
      }
      
      // Sort by newest first
      _guests.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUpdateStatusDialog(GuestModel guest) {
    String selectedStatus = guest.status;
    final List<String> statuses = ["Pending", "Invited", "Visited", "Applied", "Joined", "Cancelled"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Update Guest Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.map((status) {
                  return RadioListTile<String>(
                    title: Text(status),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedStatus = val;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _updateGuest(guest, selectedStatus);
                  },
                  child: Text('Update'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _updateGuest(GuestModel guest, String newStatus) async {
    if (_currentUserId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final res = await GuestAPI.updateGuestData(
      guestId: guest.id,
      userId: _currentUserId!,
      guestName: guest.guestName,
      status: newStatus,
    );

    if (mounted) Navigator.pop(context);

    if (res != null && res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest status updated!')),
      );
      _fetchGuests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update guest status')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'joined': return Colors.teal;
      case 'applied': return Colors.orange;
      case 'visited': return Colors.purple;
      case 'invited': return Colors.blue;
      case 'cancelled': return Colors.red;
      case 'pending': 
      default: return Colors.grey;
    }
  }

  Widget _guestTile({
    required GuestModel guest,
    required Color color,
    required VoidCallback onTap,
  }) {
    final formattedDate = guest.createdAt != null 
        ? DateFormat('MMM dd, yyyy').format(guest.createdAt!) 
        : 'Unknown Date';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  guest.guestName.isNotEmpty ? guest.guestName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest.guestName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                guest.status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        title: Text(
          "My Guests History",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "All Guests (${_guests.length})",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_guests.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("No guests registered yet.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _guests.length,
                  itemBuilder: (context, index) {
                    final guest = _guests[index];
                    return _guestTile(
                      guest: guest,
                      color: _getStatusColor(guest.status),
                      onTap: () => _showUpdateStatusDialog(guest),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
