import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class Member {
  final String name;
  final String initials;
  final int age;
  final String location;
  final String institution;
  final String course;
  final int gradYear;
  final String memberType;
  final String objective;
  final String? idea;
  final String? stage;
  final String? mentor;

  const Member({
    required this.name,
    required this.initials,
    required this.age,
    required this.location,
    required this.institution,
    required this.course,
    required this.gradYear,
    required this.memberType,
    required this.objective,
    this.idea,
    this.stage,
    this.mentor,
  });
}

class PrincePrincessProgrammeScreen extends StatefulWidget {
  const PrincePrincessProgrammeScreen({Key? key}) : super(key: key);

  @override
  State<PrincePrincessProgrammeScreen> createState() => _PrincePrincessProgrammeScreenState();
}

class _PrincePrincessProgrammeScreenState extends State<PrincePrincessProgrammeScreen> {
  int _selectedTabIndex = 0;
  bool _isSearching = false;

  final List<String> _tabs = [
    "Directory",
    "MVP Tracker",
    "Exposure",
    "Mentorship & Seed",
    "Employment"
  ];

  final List<Member> _members = const [
    Member(
      name: "Naveen",
      initials: "N",
      age: 20,
      location: "matikere",
      institution: "BGS",
      course: "BE",
      gradYear: 2026,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      idea: "water tank cleaning robot: water tank cleaning robot",
    ),
    Member(
      name: "Aarav Sharma",
      initials: "AS",
      age: 18,
      location: "Kothrud",
      institution: "Pune University",
      course: "B.Tech Computer Science",
      gradYear: 2026,
      memberType: "Recent Graduate",
      objective: "Aspiring Entrepreneur",
      idea: "StudyBuddy AI: AI-powered study planner for engineering students",
      stage: "Idea",
      mentor: "Rajesh Patil",
    ),
    Member(
      name: "Diya Patel",
      initials: "DP",
      age: 19,
      location: "Aundh",
      institution: "COEP Pune",
      course: "B.Com",
      gradYear: 2027,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      idea: "FarmConnect: Direct marketplace between farmers and urban consumers",
      stage: "MVP",
    ),
    Member(
      name: "Vivaan Reddy",
      initials: "VR",
      age: 20,
      location: "Hadapsar",
      institution: "Symbiosis",
      course: "BBA",
      gradYear: 2028,
      memberType: "Student",
      objective: "Job Seeker",
    ),
    Member(
      name: "Ananya Iyer",
      initials: "AI",
      age: 21,
      location: "Whitefield",
      institution: "BITS Pilani Goa",
      course: "B.Tech Mechanical",
      gradYear: 2029,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      mentor: "Rajesh Patil",
    ),
    Member(
      name: "Arjun Singh",
      initials: "AS",
      age: 22,
      location: "Indiranagar",
      institution: "IIT Bombay",
      course: "B.A. Economics",
      gradYear: 2026,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      idea: "LocalBiz Cards: Digital business cards for kirana stores",
      stage: "Idea",
    ),
    Member(
      name: "Saanvi Joshi",
      initials: "SJ",
      age: 23,
      location: "Koramangala",
      institution: "NMIMS",
      course: "B.Sc IT",
      gradYear: 2027,
      memberType: "Recent Graduate",
      objective: "Exploring",
    ),
    Member(
      name: "Reyansh Nair",
      initials: "RN",
      age: 24,
      location: "Baner",
      institution: "Christ University Bengaluru",
      course: "MBA",
      gradYear: 2028,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      idea: "MediTrack: Medication reminder app for elderly",
      stage: "Launch",
      mentor: "Rajesh Patil",
    ),
    Member(
      name: "Myra Kulkarni",
      initials: "MK",
      age: 25,
      location: "Viman Nagar",
      institution: "Jain University",
      course: "B.Des",
      gradYear: 2029,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
    ),
    Member(
      name: "Kabir Mehta",
      initials: "KM",
      age: 18,
      location: "Kothrud",
      institution: "Mount Carmel",
      course: "B.Tech Computer Science",
      gradYear: 2026,
      memberType: "Student",
      objective: "Job Seeker",
    ),
    Member(
      name: "Aaradhya Rao",
      initials: "AR",
      age: 19,
      location: "Aundh",
      institution: "Pune University",
      course: "B.Com",
      gradYear: 2027,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      idea: "FarmConnect: Direct marketplace between farmers and urban consumers",
      stage: "MVP",
      mentor: "Rajesh Patil",
    ),
    Member(
      name: "Aditya Kapoor",
      initials: "AK",
      age: 20,
      location: "Hadapsar",
      institution: "COEP Pune",
      course: "BBA",
      gradYear: 2028,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      idea: "FitTribe: Hyperlocal fitness community app",
      stage: "Launch",
    ),
    Member(
      name: "Ishaan Verma",
      initials: "IV",
      age: 21,
      location: "Whitefield",
      institution: "Symbiosis",
      course: "B.Tech Mechanical",
      gradYear: 2029,
      memberType: "Student",
      objective: "Job Seeker",
    ),
    Member(
      name: "Anika Bhat",
      initials: "AB",
      age: 22,
      location: "Indiranagar",
      institution: "BITS Pilani Goa",
      course: "B.A. Economics",
      gradYear: 2026,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      idea: "LocalBiz Cards: Digital business cards for kirana stores",
      stage: "Idea",
      mentor: "Rajesh Patil",
    ),
    Member(
      name: "Krish Pillai",
      initials: "KP",
      age: 23,
      location: "Koramangala",
      institution: "IIT Bombay",
      course: "B.Sc IT",
      gradYear: 2027,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      idea: "TutorMatch: Verified peer tutors for school students",
      stage: "MVP",
    ),
    Member(
      name: "Navya Shetty",
      initials: "NS",
      age: 24,
      location: "Baner",
      institution: "NMIMS",
      course: "MBA",
      gradYear: 2028,
      memberType: "Student",
      objective: "Job Seeker",
    ),
    Member(
      name: "Vihaan Gupta",
      initials: "VG",
      age: 25,
      location: "Viman Nagar",
      institution: "Christ University Bengaluru",
      course: "B.Des",
      gradYear: 2029,
      memberType: "Student",
      objective: "Aspiring Entrepreneur",
      mentor: "Rajesh Patil",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(isDark),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBanner(),
              const SizedBox(height: 20),
              _buildStatsGrid(isDark),
              const SizedBox(height: 20),
              _buildTabs(isDark),
              const SizedBox(height: 16),
              if (_selectedTabIndex == 0) _buildDirectoryContent(isDark),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      actionsIconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      // Drawer/Menu icon removed entirely per request
      automaticallyImplyLeading: false, 
      title: _isSearching
          ? Container(
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey.shade100, // Explicit light gray for search
                border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.black54),
                  prefixIcon: Icon(Icons.search, size: 18, color: isDark ? Colors.grey[400] : Colors.black),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            )
          : null,
      actions: [
              const ThemeToggleButton(),
        if (MediaQuery.of(context).size.width <= 600 && !_isSearching)
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        if (_isSearching)
          IconButton(
            icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = false;
              });
            },
          ),
        if (MediaQuery.of(context).size.width > 600)
          Container(
            width: 200,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey.shade100,
              border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.black54),
                prefixIcon: Icon(Icons.search, size: 18, color: isDark ? Colors.grey[400] : Colors.black),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        if (!_isSearching)
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF3B82F6), size: 14),
                const SizedBox(width: 6),
                Text(
                  "Profile 50%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        if (!_isSearching) const SizedBox(width: 8),
        if (!_isSearching)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: isDark ? Colors.white : Colors.black),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '9+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        if (!_isSearching)
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: GestureDetector(
              onTap: () {
                // Show profile data
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("My Profile"),
                    content: const Text("Profile completion is at 50%. Fill missing details to reach 100%."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                    ],
                  )
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFFFF9933)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "A",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1A2744), Color(0xFFFF9933)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(Icons.flash_on, size: 100, color: Colors.white.withOpacity(0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2.0),
                    child: Icon(Icons.flash_on, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: const Text(
                      "Udyami Prince & Princess Programme",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Your future starts today. Build it here. ⚡",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    final stats = [
      {'title': 'Youth Members', 'value': '298', 'icon': Icons.people, 'color': const Color(0xFF3B82F6), 'bgColor': const Color(0xFF3B82F6).withOpacity(0.1)},
      {'title': 'Active MVPs', 'value': '47', 'icon': Icons.rocket_launch, 'color': const Color(0xFF3B82F6), 'bgColor': const Color(0xFF3B82F6).withOpacity(0.1)},
      {'title': 'Mentors Assigned', 'value': '89', 'icon': Icons.school, 'color': Colors.green[600]!, 'bgColor': Colors.green[100]!},
      {'title': 'Pitch Sessions Done', 'value': '34', 'icon': Icons.workspace_premium, 'color': Colors.purple[600]!, 'bgColor': Colors.purple[100]!},
      {'title': 'Seed Connections', 'value': '12', 'icon': Icons.flash_on, 'color': Colors.amber[600]!, 'bgColor': Colors.amber[100]!},
    ];

    List<Map<String, dynamic>> adjustedStats = stats.map((s) {
      if (isDark) {
        if (s['color'] == Colors.green[600]) s['bgColor'] = Colors.green.withOpacity(0.15);
        if (s['color'] == Colors.purple[600]) s['bgColor'] = Colors.purple.withOpacity(0.15);
        if (s['color'] == Colors.amber[600]) s['bgColor'] = Colors.amber.withOpacity(0.15);
      }
      return s;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: adjustedStats.map((stat) {
            return GestureDetector(
              onTap: () {
                // Navigate to the "big screen" when tapping a stat block
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatDetailScreen(title: stat['title'] as String),
                  ),
                );
              },
              child: Container(
                width: itemWidth,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: stat['bgColor'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['title'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            stat['value'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTabs(bool isDark) {
    final icons = [Icons.people, Icons.rocket_launch, Icons.work, Icons.school, Icons.workspace_premium];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Icon(
                      icons[index],
                      size: 16,
                      color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDirectoryContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDropdownFilter("All Status", ["Active", "Inactive", "Pending"], isDark),
              _buildDropdownFilter("Idea: Any", ["Has Idea", "No Idea", "Any"], isDark),
              _buildDropdownFilter("All Tracks", ["Tech", "Agriculture", "Health", "Any"], isDark),
              _buildDropdownFilter("All Wards", ["Kothrud", "Aundh", "Hadapsar", "Any"], isDark),
              _buildDropdownFilter("All Colleges", ["Pune University", "COEP", "Symbiosis", "Any"], isDark),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showEnrollBottomSheet(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Enroll Youth Member"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 20),
        // Grid/List of members
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _members.length,
          separatorBuilder: (c, i) => const SizedBox(height: 16),
          itemBuilder: (c, i) => _buildMemberCard(_members[i], isDark),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(String text, List<String> options, bool isDark) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Handle filter selection here if needed
      },
      itemBuilder: (context) {
        return options.map((option) {
          return PopupMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(text, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  void _showEnrollBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Enroll Youth — Step 1 of 4",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Age",
                          hintText: "20",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Phone",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "Ward",
                    hintText: "Kothrud",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "College",
                    hintText: "Pune University",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Course",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Graduation Year",
                          hintText: "2027",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Next"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMemberDetails(BuildContext context, Member member, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF3B82F6),
                child: Text(member.initials, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${member.memberType} • Age ${member.age}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Location", member.location, isDark),
                _detailRow("Institution", member.institution, isDark),
                _detailRow("Course", "${member.course} (Class of ${member.gradYear})", isDark),
                _detailRow("Objective", member.objective, isDark),
                if (member.idea != null) _detailRow("Idea", member.idea!, isDark),
                if (member.stage != null) _detailRow("Stage", member.stage!, isDark),
                if (member.mentor != null) _detailRow("Mentor", member.mentor!, isDark),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[200] : Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1A2744)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text("YOUTH MEMBER", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Text(
                    member.memberType,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showMemberDetails(context, member, isDark),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFFFF9933)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          member.initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text("Age ${member.age} • ${member.location}", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                    children: [
                      TextSpan(text: "Institution: ", style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600])),
                      TextSpan(text: member.institution),
                    ]
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                    children: [
                      TextSpan(text: "Course: ", style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600])),
                      TextSpan(text: "${member.course} "),
                      TextSpan(text: "• Grad ${member.gradYear}", style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600])),
                    ]
                  ),
                ),
                const SizedBox(height: 12),
                
                // Objective Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getObjectiveBgColor(member.objective, isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    member.objective,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getObjectiveTextColor(member.objective, isDark),
                    ),
                  ),
                ),
                
                if (member.idea != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Color(0xFF3B82F6), width: 2)),
                    ),
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "💡 ${member.idea}",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
                
                if (member.stage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStageColor(member.stage!, isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Stage: ${member.stage}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStageTextColor(member.stage!, isDark),
                      ),
                    ),
                  ),
                ],
                
                if (member.mentor != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.school, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text("Mentor: ", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                      Text(member.mentor!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[200] : Colors.grey[800])),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showMemberDetails(context, member, isDark),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          minimumSize: const Size(0, 36),
                          side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                          foregroundColor: isDark ? Colors.white : Colors.black,
                        ),
                        child: const Text("View", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _showMemberDetails(context, member, isDark),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(36, 36),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                        foregroundColor: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Icon(Icons.school, size: 16),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _showMemberDetails(context, member, isDark),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(36, 36),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                        foregroundColor: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Icon(Icons.calendar_today, size: 16),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getObjectiveBgColor(String objective, bool isDark) {
    if (objective == 'Aspiring Entrepreneur' || objective == 'Job Seeker') {
      return const Color(0xFF3B82F6);
    }
    return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
  }

  Color _getObjectiveTextColor(String objective, bool isDark) {
    if (objective == 'Aspiring Entrepreneur' || objective == 'Job Seeker') {
      return Colors.white;
    }
    return isDark ? Colors.grey.shade300 : Colors.grey.shade800;
  }

  Color _getStageColor(String stage, bool isDark) {
    if (stage == 'Idea') return isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    if (stage == 'MVP') return isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50;
    if (stage == 'Launch') return isDark ? Colors.amber.withOpacity(0.2) : Colors.amber.shade50;
    return isDark ? Colors.grey.shade800 : Colors.grey.shade100;
  }

  Color _getStageTextColor(String stage, bool isDark) {
    if (stage == 'Idea') return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    if (stage == 'MVP') return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    if (stage == 'Launch') return isDark ? Colors.amber.shade300 : Colors.amber.shade700;
    return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
  }
}

// New big screen for displaying detailed statistics data
class StatDetailScreen extends StatelessWidget {
  final String title;

  const StatDetailScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 15,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF3B82F6),
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              "Sample Entry ${index + 1} for $title",
              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              "Here is some detailed information regarding $title to review.",
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey[500] : Colors.grey[400]),
            onTap: () {
              // Specific detailed action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Tapped on entry ${index + 1}")),
              );
            },
          );
        },
      ),
    );
  }
}
