import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:udyamikutumba/features/jobs/job_post_screen.dart';
import 'package:udyamikutumba/features/jobs/my_application_sceen.dart';
import 'package:udyamikutumba/features/jobs/job_create_screen.dart';
import '../../core/models/job_model.dart';
import '../../core/api/jobs/job_api.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
        appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            dividerColor: Colors.transparent, // Remove the white line
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: "Search Jobs"),
              Tab(text: "My Applications"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SearchJobsTab(),
            MyApplicationsTab(),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 90.0, right: 65.0),
          child: FloatingActionButton.extended(
            heroTag: 'jobs_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobCreateScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Post Job"),
          ),
        ),
      ),
    );
  }
}

class SearchJobsTab extends StatefulWidget {
  const SearchJobsTab({super.key});

  @override
  State<SearchJobsTab> createState() => _SearchJobsTabState();
}

class _SearchJobsTabState extends State<SearchJobsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<JobModel> _allJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    final jobs = await JobAPI.getAllJobs();
    if (mounted) {
      setState(() {
        _allJobs = jobs;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search Jobs by title or keyword...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Domain", Icons.keyboard_arrow_down_rounded, theme, ["IT & Software", "Finance", "Healthcare", "Education"]),
                const SizedBox(width: 8),
                _buildFilterChip("Location", Icons.keyboard_arrow_down_rounded, theme, ["Bangalore", "Mumbai", "Remote", "Delhi"]),
                const SizedBox(width: 8),
                _buildFilterChip("Experience", Icons.keyboard_arrow_down_rounded, theme, ["Fresher", "1-3 Years", "3-5 Years", "5+ Years"]),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text(
            "Recommended for you",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Job Listings
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ))
          else if (_allJobs.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text("No jobs found"),
            ))
          else
            ..._allJobs.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildJobCard(context: context, job: job),
            )),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, ThemeData theme, List<String> options) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        // Update label or filter in future
      },
      itemBuilder: (BuildContext context) {
        return options.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 18, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required JobModel job,
  }) {
    final theme = Theme.of(context);
    final isHot = job.jobType == 'FULL_TIME';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobPostScreen(job: job),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
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
                        job.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: Colors.red, size: 14),
                        SizedBox(width: 4),
                        Text("HOT", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade400, size: 16),
                const SizedBox(width: 4),
                Text(job.location, style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.jobType,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade700),
                  ),
                ),
                const Spacer(),
                Text(
                  job.createdAt != null ? timeago.format(DateTime.parse(job.createdAt!)) : "Just now",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
