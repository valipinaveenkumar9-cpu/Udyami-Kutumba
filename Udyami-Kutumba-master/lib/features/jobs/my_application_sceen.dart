import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/api/jobs/job_api.dart';
import '../../core/models/applications/application_model.dart';

class MyApplicationsTab extends StatefulWidget {
  const MyApplicationsTab({super.key});

  @override
  State<MyApplicationsTab> createState() => _MyApplicationsTabState();
}

class _MyApplicationsTabState extends State<MyApplicationsTab> {
  List<ApplicationModel> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
    final apps = await JobAPI.getAllApplications();
    if (mounted) {
      setState(() {
        _applications = apps;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_applications.isEmpty) {
      return const Center(child: Text("No applications found."));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: _applications.map((app) {
          final job = app.job;
          MaterialColor statusColor = Colors.grey;
          IconData statusIcon = Icons.info_outline;

          if (app.status == 'APPLIED') {
            statusColor = Colors.blue;
            statusIcon = Icons.send_rounded;
          } else if (app.status == 'UNDER_REVIEW') {
            statusColor = Colors.orange;
            statusIcon = Icons.access_time_rounded;
          } else if (app.status == 'SHORTLISTED') {
            statusColor = Colors.green;
            statusIcon = Icons.check_circle_rounded;
          } else if (app.status == 'REJECTED') {
            statusColor = Colors.red;
            statusIcon = Icons.cancel_rounded;
          } else if (app.status == 'HIRED') {
            statusColor = Colors.purple;
            statusIcon = Icons.workspace_premium;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildApplicationCard(
              context: context,
              role: job?.title ?? 'Unknown Job',
              company: job?.companyName ?? 'Unknown Company',
              location: job?.location ?? '',
              salary: job?.salaryRange ?? '',
              date: app.createdAt != null ? timeago.format(DateTime.parse(app.createdAt!)) : 'Just now',
              status: app.status,
              statusColor: statusColor,
              statusIcon: statusIcon,
            ),
          );
        }).toList(),
      ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard({
    required BuildContext context,
    required String role,
    required String company,
    required String location,
    required String salary,
    required String date,
    required String status,
    required MaterialColor statusColor,
    required IconData statusIcon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .brightness == Brightness.dark ? Colors.grey.shade900 : Theme
            .of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Theme
              .of(context)
              .brightness == Brightness.dark ? Colors.transparent : Colors.grey
              .shade100,
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme
                            .of(context)
                            .brightness == Brightness.dark ? Colors.grey
                            .shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .brightness == Brightness.dark ? statusColor.shade900
                      .withValues(alpha: 0.3) : statusColor.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: Theme
                        .of(context)
                        .brightness == Brightness.dark
                        ? statusColor.shade300
                        : statusColor.shade700, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: Theme
                            .of(context)
                            .brightness == Brightness.dark ? statusColor
                            .shade300 : statusColor.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: Theme
                  .of(context)
                  .brightness == Brightness.dark ? Colors.grey.shade500 : Colors
                  .grey.shade400, size: 16),
              const SizedBox(width: 6),
              Text(
                location,
                style: TextStyle(fontSize: 14, color: Theme
                    .of(context)
                    .brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.currency_rupee_rounded, color: Theme
                  .of(context)
                  .brightness == Brightness.dark ? Colors.grey.shade500 : Colors
                  .grey.shade400, size: 16),
              const SizedBox(width: 6),
              Text(
                salary,
                style: TextStyle(fontSize: 14, color: Theme
                    .of(context)
                    .brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Theme
                  .of(context)
                  .brightness == Brightness.dark ? Colors.grey.shade500 : Colors
                  .grey.shade400, size: 14),
              const SizedBox(width: 6),
              Text(
                "Applied on: $date",
                style: TextStyle(fontSize: 13, color: Theme
                    .of(context)
                    .brightness == Brightness.dark
                    ? Colors.grey.shade500
                    : Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
