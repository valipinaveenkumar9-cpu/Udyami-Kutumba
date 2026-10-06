import 'package:flutter/material.dart';
import '../../../core/api/ubn/attendance_api.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class AttendanceSummaryListScreen extends StatefulWidget {
  final String meetingId;
  final List<dynamic>? attendanceData;

  const AttendanceSummaryListScreen({super.key, required this.meetingId, this.attendanceData});

  @override
  State<AttendanceSummaryListScreen> createState() =>
      _AttendanceSummaryListScreenState();
}

class _AttendanceSummaryListScreenState
    extends State<AttendanceSummaryListScreen> {
  final AttendanceAPI _attendanceAPI = AttendanceAPI();
  bool _isLoading = true;
  List<dynamic> _allMembers = [];
  int _selectedFilterIndex = 0; // 0: All, 1: Attended, 2: Absent

  @override
  void initState() {
    super.initState();
    if (widget.attendanceData != null && widget.attendanceData!.isNotEmpty) {
      _allMembers = widget.attendanceData!;
      _isLoading = false;
    } else {
      _fetchAttendanceList();
    }
  }

  Future<void> _fetchAttendanceList() async {
    setState(() => _isLoading = true);
    try {
      final res = await _attendanceAPI.getMeetingAttendance(widget.meetingId);
      dynamic extractData(dynamic r) {
        if (r == null) return null;
        if (r is Map) return r.containsKey('data') ? r['data'] : r;
        return r;
      }

      final data = extractData(res);
      if (data != null && mounted) {
        setState(() {
          if (data is Map && data['attendance'] is List) {
            _allMembers = data['attendance'];
          } else if (data is List) {
            _allMembers = data;
          } else {
            _allMembers = [];
          }
        });
      }
    } catch (e) {
      print("Error fetching attendance list: $e");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<dynamic> get _filteredMembers {
    if (_selectedFilterIndex == 1) {
      // Attended
      return _allMembers
          .where((m) => m['status'] == 'Present' || m['status'] == 'Late')
          .toList();
    } else if (_selectedFilterIndex == 2) {
      // Absent
      return _allMembers.where((m) => m['status'] == 'Absent').toList();
    }
    // All Accepted
    return _allMembers;
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
          "Attendance List",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip("All Accepted", 0),
                      const SizedBox(width: 8),
                      _buildFilterChip("Attended", 1),
                      const SizedBox(width: 8),
                      _buildFilterChip("Absent", 2),
                    ],
                  ),
                ),
                const Divider(),
                // List
                Expanded(
                  child: _filteredMembers.isEmpty
                      ? const Center(
                          child: Text(
                            "No members found.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = _filteredMembers[index];
                            final status = member['status'] ?? 'Absent';
                            final isPresent =
                                status == 'Present' || status == 'Late';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.transparent
                                        : Colors.grey.shade100,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isPresent
                                        ? Colors.teal.shade100
                                        : Colors.red.shade100,
                                    child: Icon(
                                      isPresent ? Icons.check : Icons.close,
                                      color: isPresent
                                          ? Colors.teal
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member['userName'] ??
                                              'Unknown Member',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          status,
                                          style: TextStyle(
                                            color: isPresent
                                                ? Colors.teal
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilterIndex = index;
          });
        }
      },
      selectedColor: Colors.teal.shade100,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.teal.shade900
            : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.teal : Colors.grey.shade300,
        ),
      ),
    );
  }
}
