import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api/ubn/gratitude_api.dart';
import '../../../core/models/gratitude_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/session_manager.dart';
import 'gratitude_details_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class GratitudeHistoryScreen extends StatefulWidget {
  final String? targetUserId;
  const GratitudeHistoryScreen({super.key, this.targetUserId});

  @override
  State<GratitudeHistoryScreen> createState() => _GratitudeHistoryScreenState();
}

class _GratitudeHistoryScreenState extends State<GratitudeHistoryScreen> {
  List<GratitudeModel> _givenSlips = [];
  List<GratitudeModel> _receivedSlips = [];
  int _selectedTab = 0; // 0 for Given, 1 for Received
  bool _isLoadingSlips = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initUserAndFetch();
  }

  Future<void> _initUserAndFetch() async {
    final userData = SessionManager.user;
    if (userData != null) {
      _currentUserId = widget.targetUserId ?? UserModel.fromJson(userData).userId;
    }
    await _fetchSlips();
  }

  Future<void> _fetchSlips() async {
    setState(() => _isLoadingSlips = true);
    final allSlips = await GratitudeAPI.getAllGratitudeSlips();
    
    if (mounted) {
      setState(() {
        if (_currentUserId != null) {
          _givenSlips = allSlips.where((s) => s.createdUser?.userId == _currentUserId).toList();
          _receivedSlips = allSlips.where((s) => s.thankYouMember?.userId == _currentUserId).toList();
        } else {
          _givenSlips = allSlips;
          _receivedSlips = [];
        }
        
        // Sort descending by date
        _givenSlips.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _receivedSlips.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _isLoadingSlips = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
          title: Text(
            "Gratitude History",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(text: "Given ${_givenSlips.length}"),
              Tab(text: "Received ${_receivedSlips.length}"),
            ],
          ),
        ),
        body: _isLoadingSlips
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildList(_givenSlips, true),
                  _buildList(_receivedSlips, false),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<GratitudeModel> slips, bool isGiven) {
    if (slips.isEmpty) {
      return Center(
        child: Text(
          isGiven ? "No gratitude slips given yet." : "No gratitude slips received yet.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: slips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final slip = slips[index];
        final formattedDate = slip.createdAt != null
            ? DateFormat('MMM dd, yyyy').format(slip.createdAt!)
            : '';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GratitudeDetailsScreen(
                  slip: slip,
                  isGiven: isGiven,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGiven 
                          ? (slip.thankYouMember?.name ?? "Unknown Member")
                          : (slip.createdUser?.name ?? "Unknown Member"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${slip.linkedLead?.business ?? 'Unknown Lead'} • ${slip.type}",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    if (formattedDate.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "₹${slip.businessValue.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}

