import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

// --- Data Classes ---
class ChildData {
  final String name;
  final int age;
  final String parentName;
  final String parentId;
  final String school;
  final String ward;
  final bool hasBenefits;
  final int discounts;
  final int scholarships;

  ChildData({
    required this.name,
    required this.age,
    required this.parentName,
    required this.parentId,
    required this.school,
    required this.ward,
    required this.hasBenefits,
    required this.discounts,
    required this.scholarships,
  });
}

class PartnerInstitution {
  final String name;
  final String type;
  final String discount;
  final String ward;
  final int activeStudents;
  final String validUntil;

  PartnerInstitution({
    required this.name,
    required this.type,
    required this.discount,
    required this.ward,
    required this.activeStudents,
    required this.validUntil,
  });
}

class DiscountUsage {
  final String child;
  final String institution;
  final int original;
  final int discount;
  final int paid;
  final String status;
  final String date;

  DiscountUsage({
    required this.child,
    required this.institution,
    required this.original,
    required this.discount,
    required this.paid,
    required this.status,
    required this.date,
  });
}

class WorkshopData {
  final String title;
  final String category;
  final String ageGroup;
  final String dateTime;
  final String location;
  final int enrolled;
  final int maxCapacity;
  final String price;

  WorkshopData({
    required this.title,
    required this.category,
    required this.ageGroup,
    required this.dateTime,
    required this.location,
    required this.enrolled,
    required this.maxCapacity,
    required this.price,
  });
}

class WorkshopHistory {
  final String workshop;
  final String date;
  final String attendance;
  final String feedback;

  WorkshopHistory({
    required this.workshop,
    required this.date,
    required this.attendance,
    required this.feedback,
  });
}

class ScholarshipData {
  final String title;
  final String type;
  final String amount;
  final String eligibility;
  final String deadline;
  final int applied;

  ScholarshipData({
    required this.title,
    required this.type,
    required this.amount,
    required this.eligibility,
    required this.deadline,
    required this.applied,
  });
}

class ScholarshipApplication {
  final String child;
  final String scholarship;
  final String appliedDate;
  final String status;
  final String amount;
  final String disbursed;

  ScholarshipApplication({
    required this.child,
    required this.scholarship,
    required this.appliedDate,
    required this.status,
    required this.amount,
    required this.disbursed,
  });
}

class BusinessVisit {
  final String company;
  final String industry;
  final String date;
  final int spotsRemaining;

  BusinessVisit({
    required this.company,
    required this.industry,
    required this.date,
    required this.spotsRemaining,
  });
}

class PastVisit {
  final String company;
  final String date;
  final String feedback;

  PastVisit({
    required this.company,
    required this.date,
    required this.feedback,
  });
}

class TalkSession {
  final String speaker;
  final String expertise;
  final String school;
  final String date;
  final String grade;
  final String topic;
  final String feedback;

  TalkSession({
    required this.speaker,
    required this.expertise,
    required this.school,
    required this.date,
    required this.grade,
    required this.topic,
    required this.feedback,
  });
}

class CareerPath {
  final String title;
  final int membersInField;
  final IconData icon;

  CareerPath({
    required this.title,
    required this.membersInField,
    required this.icon,
  });
}

class RoleModel {
  final String name;
  final String experience;

  RoleModel({
    required this.name,
    required this.experience,
  });
}

// --- Screen ---
class ChildrenProgrammeScreen extends StatefulWidget {
  const ChildrenProgrammeScreen({Key? key}) : super(key: key);

  @override
  State<ChildrenProgrammeScreen> createState() =>
      _ChildrenProgrammeScreenState();
}

class _ChildrenProgrammeScreenState extends State<ChildrenProgrammeScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Directory',
    'Discounts',
    'Workshops',
    'Scholarships',
    'Careers',
  ];

  final List<IconData> _tabIcons = [
    Icons.people_outline,
    Icons.domain,
    Icons.auto_awesome,
    Icons.emoji_events_outlined,
    Icons.explore_outlined,
  ];

  // Dummy Data
  final List<ChildData> _children = [
    ChildData(
      name: 'Aarav Sharma',
      age: 6,
      parentName: 'Sharma Sr.',
      parentId: 'UDY-4000',
      school: 'DPS Bangalore',
      ward: 'Indiranagar',
      hasBenefits: false,
      discounts: 0,
      scholarships: 0,
    ),
    ChildData(
      name: 'Diya Patel',
      age: 7,
      parentName: 'Patel Sr.',
      parentId: 'UDY-4001',
      school: 'Bishop Cotton',
      ward: 'Jayanagar',
      hasBenefits: true,
      discounts: 1,
      scholarships: 1,
    ),
    ChildData(
      name: 'Vihaan Reddy',
      age: 8,
      parentName: 'Reddy Sr.',
      parentId: 'UDY-4002',
      school: 'Vidya Niketan',
      ward: 'Whitefield',
      hasBenefits: true,
      discounts: 2,
      scholarships: 2,
    ),
    ChildData(
      name: 'Anaya Iyer',
      age: 9,
      parentName: 'Iyer Sr.',
      parentId: 'UDY-4003',
      school: 'NPS Indiranagar',
      ward: 'HSR Layout',
      hasBenefits: true,
      discounts: 3,
      scholarships: 0,
    ),
    ChildData(
      name: 'Aditya Kumar',
      age: 10,
      parentName: 'Kumar Sr.',
      parentId: 'UDY-4004',
      school: 'Sri Kumaran',
      ward: 'Koramangala',
      hasBenefits: true,
      discounts: 4,
      scholarships: 1,
    ),
    ChildData(
      name: 'Saanvi Rao',
      age: 11,
      parentName: 'Rao Sr.',
      parentId: 'UDY-4005',
      school: 'VIBGYOR High',
      ward: 'Malleshwaram',
      hasBenefits: false,
      discounts: 5,
      scholarships: 2,
    ),
    ChildData(
      name: 'Arjun Mehta',
      age: 12,
      parentName: 'Mehta Sr.',
      parentId: 'UDY-4006',
      school: 'DPS Bangalore',
      ward: 'Indiranagar',
      hasBenefits: true,
      discounts: 0,
      scholarships: 0,
    ),

    ChildData(
      name: 'Ishani Nair',
      age: 13,
      parentName: 'Nair Sr.',
      parentId: 'UDY-4007',
      school: 'Bishop Cotton',
      ward: 'Jayanagar',
      hasBenefits: true,
      discounts: 1,
      scholarships: 1,
    ),
    ChildData(
      name: 'Krishna Gowda',
      age: 14,
      parentName: 'Gowda Sr.',
      parentId: 'UDY-4008',
      school: 'Vidya Niketan',
      ward: 'Whitefield',
      hasBenefits: true,
      discounts: 2,
      scholarships: 2,
    ),
    ChildData(
      name: 'Myra Kapoor',
      age: 15,
      parentName: 'Kapoor Sr.',
      parentId: 'UDY-4009',
      school: 'NPS Indiranagar',
      ward: 'HSR Layout',
      hasBenefits: true,
      discounts: 3,
      scholarships: 0,
    ),
  ];

  final List<PartnerInstitution> _institutions = [
    PartnerInstitution(
      name: 'Aakash Coaching',
      type: 'Coaching',
      discount: '15%',
      ward: 'Indiranagar',
      activeStudents: 34,
      validUntil: '2026-12-31',
    ),
    PartnerInstitution(
      name: 'BYJU\'S Tuition Centre',
      type: 'Coaching',
      discount: '20%',
      ward: 'Jayanagar',
      activeStudents: 56,
      validUntil: '2026-08-30',
    ),
    PartnerInstitution(
      name: 'Whitefield Public School',
      type: 'School',
      discount: '10%',
      ward: 'Whitefield',
      activeStudents: 22,
      validUntil: '2027-03-31',
    ),
    PartnerInstitution(
      name: 'Code Wizards Academy',
      type: 'Skill Centre',
      discount: '25%',
      ward: 'HSR Layout',
      activeStudents: 41,
      validUntil: '2026-11-30',
    ),
    PartnerInstitution(
      name: 'PES University',
      type: 'College',
      discount: '8%',
      ward: 'Koramangala',
      activeStudents: 12,
      validUntil: '2027-06-30',
    ),
    PartnerInstitution(
      name: 'Music Bridge School',
      type: 'Skill Centre',
      discount: '18%',
      ward: 'Malleshwaram',
      activeStudents: 19,
      validUntil: '2026-09-30',
    ),
  ];

  final List<DiscountUsage> _discountUsages = [
    DiscountUsage(
      child: 'Aarav Sharma',
      institution: 'Aakash Coaching',
      original: 5000,
      discount: -500,
      paid: 4500,
      status: 'Pending',
      date: '2026-04-05',
    ),
    DiscountUsage(
      child: 'Diya Patel',
      institution: 'BYJU\'S Tuition Centre',
      original: 6500,
      discount: -975,
      paid: 5525,
      status: 'Paid',
      date: '2026-04-06',
    ),
    DiscountUsage(
      child: 'Vihaan Reddy',
      institution: 'Whitefield Public School',
      original: 8000,
      discount: -1600,
      paid: 6400,
      status: 'Paid',
      date: '2026-04-07',
    ),
    DiscountUsage(
      child: 'Anaya Iyer',
      institution: 'Code Wizards Academy',
      original: 9500,
      discount: -950,
      paid: 8550,
      status: 'Paid',
      date: '2026-04-08',
    ),
    DiscountUsage(
      child: 'Aditya Kumar',
      institution: 'PES University',
      original: 11000,
      discount: -1650,
      paid: 9350,
      status: 'Pending',
      date: '2026-04-09',
    ),
    DiscountUsage(
      child: 'Saanvi Rao',
      institution: 'Music Bridge School',
      original: 12500,
      discount: -2500,
      paid: 10000,
      status: 'Paid',
      date: '2026-04-10',
    ),
    DiscountUsage(
      child: 'Arjun Mehta',
      institution: 'Aakash Coaching',
      original: 14000,
      discount: -1400,
      paid: 12600,
      status: 'Paid',
      date: '2026-04-11',
    ),
    DiscountUsage(
      child: 'Ishani Nair',
      institution: 'BYJU\'S Tuition Centre',
      original: 15500,
      discount: -2325,
      paid: 13175,
      status: 'Paid',
      date: '2026-04-12',
    ),
  ];

  final List<WorkshopData> _workshops = [
    WorkshopData(
      title: 'Scratch Coding for Kids',
      category: 'Coding',
      ageGroup: '8-12',
      dateTime: '2026-05-09 10:00',
      location: 'Indiranagar Centre',
      enrolled: 14,
      maxCapacity: 20,
      price: 'Free',
    ),
    WorkshopData(
      title: 'Origami & Mandala Art',
      category: 'Art & Craft',
      ageGroup: '6-10',
      dateTime: '2026-05-10 11:00',
      location: 'Jayanagar Centre',
      enrolled: 12,
      maxCapacity: 15,
      price: '₹200',
    ),
    WorkshopData(
      title: 'TEDx Speaking Bootcamp',
      category: 'Public Speaking',
      ageGroup: '13-17',
      dateTime: '2026-05-16 16:00',
      location: 'Online',
      enrolled: 9,
      maxCapacity: 25,
      price: 'Free',
    ),
    WorkshopData(
      title: 'Junior Business Pitch',
      category: 'Business Basics',
      ageGroup: '14-18',
      dateTime: '2026-05-17 14:00',
      location: 'HSR Layout Centre',
      enrolled: 11,
      maxCapacity: 18,
      price: '₹300',
    ),
    WorkshopData(
      title: 'Cricket Coaching Camp',
      category: 'Sports Coaching',
      ageGroup: '9-14',
      dateTime: '2026-05-18 07:00',
      location: 'Whitefield Ground',
      enrolled: 22,
      maxCapacity: 30,
      price: '₹500',
    ),
    WorkshopData(
      title: 'Magnet & Static Lab',
      category: 'Science Experiments',
      ageGroup: '8-12',
      dateTime: '2026-05-23 10:30',
      location: 'Koramangala Centre',
      enrolled: 17,
      maxCapacity: 20,
      price: '₹250',
    ),
  ];

  final List<WorkshopHistory> _workshopHistory = [
    WorkshopHistory(
      workshop: 'Easy Cooking Basics',
      date: '2026-04-12',
      attendance: '18 / 20',
      feedback: '4.6 ★',
    ),
    WorkshopHistory(
      workshop: 'Robotics Intro',
      date: '2026-04-05',
      attendance: '22 / 25',
      feedback: '4.8 ★',
    ),
    WorkshopHistory(
      workshop: 'Storytelling for Kids',
      date: '2026-03-29',
      attendance: '14 / 15',
      feedback: '4.5 ★',
    ),
    WorkshopHistory(
      workshop: 'Music & Rhythm',
      date: '2026-03-22',
      attendance: '16 / 20',
      feedback: '4.4 ★',
    ),
  ];

  final List<ScholarshipData> _scholarships = [
    ScholarshipData(
      title: 'PM Scholarship Scheme',
      type: 'Govt',
      amount: '₹36,000',
      eligibility: 'Wards of ex-servicemen',
      deadline: '2026-06-30',
      applied: 18,
    ),
    ScholarshipData(
      title: 'National Talent Search',
      type: 'Govt',
      amount: '₹12,500',
      eligibility: 'Class 10 students',
      deadline: '2026-05-15',
      applied: 24,
    ),
    ScholarshipData(
      title: 'Tata Trust Education Grant',
      type: 'Private',
      amount: '₹50,000',
      eligibility: 'Family income < 6L',
      deadline: '2026-07-20',
      applied: 11,
    ),
    ScholarshipData(
      title: 'Reliance Foundation UG',
      type: 'Private',
      amount: '₹2,00,000',
      eligibility: 'Undergraduate aspirants',
      deadline: '2026-09-15',
      applied: 7,
    ),
  ];

  final List<ScholarshipApplication> _scholarshipApplications = [
    ScholarshipApplication(
      child: 'Aarav Sharma',
      scholarship: 'Udyami Merit Scholarship',
      appliedDate: '2026-03-12',
      status: 'Approved',
      amount: '₹25,000',
      disbursed: '2026-04-01',
    ),
    ScholarshipApplication(
      child: 'Diya Patel',
      scholarship: 'National Talent Search',
      appliedDate: '2026-04-02',
      status: 'Reviewing',
      amount: '₹12,500',
      disbursed: '—',
    ),
    ScholarshipApplication(
      child: 'Vihaan Reddy',
      scholarship: 'Tata Trust Education Grant',
      appliedDate: '2026-04-10',
      status: 'Applied',
      amount: '₹50,000',
      disbursed: '—',
    ),
    ScholarshipApplication(
      child: 'Anaya Iyer',
      scholarship: 'Udyami Merit Scholarship',
      appliedDate: '2026-02-20',
      status: 'Approved',
      amount: '₹25,000',
      disbursed: '2026-03-15',
    ),
    ScholarshipApplication(
      child: 'Aditya Kumar',
      scholarship: 'PM Scholarship Scheme',
      appliedDate: '2026-04-18',
      status: 'Rejected',
      amount: '₹36,000',
      disbursed: '—',
    ),
  ];

  final List<BusinessVisit> _upcomingVisits = [
    BusinessVisit(company: 'Sharma Textiles', industry: 'Manufacturing', date: '2026-05-12', spotsRemaining: 8),
    BusinessVisit(company: 'Reddy Foods', industry: 'Food & Bev', date: '2026-05-19', spotsRemaining: 12),
    BusinessVisit(company: 'Iyer Electronics', industry: 'Retail/Tech', date: '2026-05-26', spotsRemaining: 6),
  ];

  final List<PastVisit> _pastVisits = [
    PastVisit(company: 'Patel Pharma', date: '2026-04-14', feedback: '12 children attended; very engaged with R&D demo.'),
    PastVisit(company: 'Rao Constructions', date: '2026-03-30', feedback: 'Site safety walkthrough; sparked interest in civil engg.'),
  ];

  final List<TalkSession> _talkSessions = [
    TalkSession(speaker: 'Dr. Anjali Patel', expertise: 'Cardiology', school: 'DPS Bangalore', date: '2026-05-08', grade: 'Class 9', topic: 'Careers in Medicine', feedback: '4.8 ★'),
    TalkSession(speaker: 'Eng. Rajesh K.', expertise: 'Civil Engineering', school: 'NPS Indiranagar', date: '2026-05-14', grade: 'Class 10', topic: 'Building India\'s Future', feedback: '4.6 ★'),
    TalkSession(speaker: 'CA Meena S.', expertise: 'Finance', school: 'Bishop Cotton', date: '2026-05-20', grade: 'Class 11', topic: 'Money Management 101', feedback: '4.7 ★'),
  ];

  final List<CareerPath> _careerPaths = [
    CareerPath(title: 'Business Owner', membersInField: 234, icon: Icons.storefront),
    CareerPath(title: 'Doctor', membersInField: 56, icon: Icons.local_hospital),
    CareerPath(title: 'Engineer', membersInField: 189, icon: Icons.engineering),
    CareerPath(title: 'Teacher', membersInField: 78, icon: Icons.school),
    CareerPath(title: 'Farmer', membersInField: 42, icon: Icons.agriculture),
    CareerPath(title: 'Artist', membersInField: 31, icon: Icons.palette),
    CareerPath(title: 'Chef', membersInField: 28, icon: Icons.restaurant),
    CareerPath(title: 'Sportsperson', membersInField: 19, icon: Icons.sports_basketball),
    CareerPath(title: 'Scientist', membersInField: 24, icon: Icons.science),
    CareerPath(title: 'Journalist', membersInField: 16, icon: Icons.campaign),
    CareerPath(title: 'Lawyer', membersInField: 33, icon: Icons.gavel),
    CareerPath(title: 'Government Officer', membersInField: 21, icon: Icons.account_balance),
  ];

  final List<RoleModel> _dummyRoleModels = [
    RoleModel(name: 'Mr. Anil K.', experience: '22 yrs experience'),
    RoleModel(name: 'Ms. Priya R.', experience: '15 yrs experience'),
    RoleModel(name: 'Dr. Suresh M.', experience: '30 yrs experience'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: const Text('Children\'s Programme'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildMetricsGrid(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 16),
            if (_selectedTabIndex == 0) _buildDirectoryTab(),
            if (_selectedTabIndex == 1) _buildDiscountsTab(),
            if (_selectedTabIndex == 2) _buildWorkshopsTab(),
            if (_selectedTabIndex == 3) _buildScholarshipsTab(),
            if (_selectedTabIndex == 4) _buildCareersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0F766E), Color(0xFFFF9933)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: Icon(
              Icons.school,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.school, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Children\'s Programme',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Planting the seeds of tomorrow\'s entrepreneurs 🌱',
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

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Children Enrolled',
                '634',
                Icons.people_alt_outlined,
                const Color(0xFF0D9488),
                const Color(0xFF0D9488).withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Partner Institutions',
                '23',
                Icons.domain,
                Colors.amber.shade700,
                Colors.amber.shade100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Active Scholarships',
                '47',
                Icons.emoji_events_outlined,
                Colors.purple.shade700,
                Colors.purple.shade100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Workshops This Month',
                '8',
                Icons.auto_awesome,
                Colors.blue.shade700,
                Colors.blue.shade100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isActive = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0D9488) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF0D9488)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _tabIcons[index],
                      size: 16,
                      color: isActive ? Colors.white : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
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

  Widget _buildDirectoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF0D9488),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All children of Udyami members automatically get access to this programme. Benefits activate when their parent\'s membership is active.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterDropdown('All Ages', [
                  '5-8 Years',
                  '9-12 Years',
                  '13-16 Years',
                  '17+ Years',
                ]),
                _buildFilterDropdown('All Membership', [
                  'Active',
                  'Pending',
                  'Expired',
                  'Cancelled',
                ]),
                _buildFilterDropdown('All Wards', [
                  'Indiranagar',
                  'Jayanagar',
                  'Whitefield',
                  'HSR Layout',
                  'Koramangala',
                ]),
                _buildFilterDropdown('All Schools', [
                  'DPS Bangalore',
                  'Bishop Cotton',
                  'Vidya Niketan',
                  'NPS Indiranagar',
                  'Sri Kumaran',
                ]),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showRegisterChildSheet,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Register Child'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Age')),
                DataColumn(label: Text('Parent')),
                DataColumn(label: Text('School')),
                DataColumn(label: Text('Area')),
                DataColumn(label: Text('Benefits')),
                DataColumn(label: Text('Discounts')),
                DataColumn(label: Text('Scholarships')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _children.map((child) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        child.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(child.age.toString())),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(child.parentName),
                          Text(
                            child.parentId,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(child.school)),
                    DataCell(Text(child.ward)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: child.hasBenefits
                              ? const Color(0xFF0D9488)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          child.hasBenefits ? 'Yes' : 'No',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: child.hasBenefits
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(child.discounts.toString())),
                    DataCell(Text(child.scholarships.toString())),
                    DataCell(
                      TextButton(
                        onPressed: () => _showChildDetails(child),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade800,
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String hint, List<String> options) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Selected: $value from $hint')));
      },
      itemBuilder: (context) => options.map((option) {
        return PopupMenuItem(value: option, child: Text(option));
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hint,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  void _showRegisterChildSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Register a Child',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Child\'s name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date of birth (mm/dd/yyyy)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'DPS Bangalore',
                      decoration: const InputDecoration(
                        labelText: 'School/College',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'Class 8',
                      decoration: const InputDecoration(
                        labelText: 'Class/Grade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'UDY-XXXX',
                      decoration: const InputDecoration(
                        labelText: 'Parent\'s Udyami ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'Indiranagar',
                      decoration: const InputDecoration(
                        labelText: 'Area',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Interests',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                                'Coding',
                                'Art',
                                'Sports',
                                'Science',
                                'Business',
                                'Music',
                              ]
                              .map(
                                (interest) => Chip(
                                  label: Text(interest),
                                  backgroundColor: const Color(
                                    0xFF0D9488,
                                  ).withOpacity(0.1),
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Child Registered Successfully!'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChildDetails(ChildData child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
                    radius: 24,
                    child: const Icon(Icons.person, color: Color(0xFF0D9488)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Age ${child.age} • ${child.school}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                'Parent',
                '${child.parentName} (${child.parentId})',
              ),
              _buildDetailRow('Area', child.ward),
              _buildDetailRow(
                'Benefits Active',
                child.hasBenefits ? 'Yes' : 'No',
              ),
              _buildDetailRow('Discounts Used', child.discounts.toString()),
              _buildDetailRow('Scholarships', child.scholarships.toString()),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDiscountsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Savings This Year',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '₹11,900',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddInstitutionSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Partner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Partner Institutions list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _institutions.length,
          itemBuilder: (context, index) {
            final inst = _institutions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          inst.type,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${inst.discount} OFF',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    inst.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${inst.ward} • ${inst.ward}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active students: ${inst.activeStudents}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'Valid until ${inst.validUntil}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showInstitutionDetails(inst),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('View Details'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _showReferInstitution(inst),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Refer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Tracker table
        const Text(
          'Discount Usage Tracker',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              columns: const [
                DataColumn(label: Text('Child')),
                DataColumn(label: Text('Institution')),
                DataColumn(label: Text('Original (₹)')),
                DataColumn(label: Text('Discount (₹)')),
                DataColumn(label: Text('Paid (₹)')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Date')),
              ],
              rows: _discountUsages.map((usage) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        usage.child,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(usage.institution)),
                    DataCell(Text(usage.original.toString())),
                    DataCell(
                      Text(
                        usage.discount.toString(),
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    DataCell(
                      Text(
                        usage.paid.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: usage.status == 'Paid'
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          usage.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: usage.status == 'Paid'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(usage.date)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddInstitutionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Add Partner Institution',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Institution name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'School',
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'Indiranagar',
                      decoration: const InputDecoration(
                        labelText: 'Area',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: '10',
                      decoration: const InputDecoration(
                        labelText: 'Discount %',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Valid until (mm/dd/yyyy)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Contact person',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Institution Added Successfully!'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add Institution'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInstitutionDetails(PartnerInstitution inst) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                inst.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Type', inst.type),
              _buildDetailRow('Area', inst.ward),
              _buildDetailRow('Discount', inst.discount),
              _buildDetailRow(
                'Active Students',
                inst.activeStudents.toString(),
              ),
              _buildDetailRow('Valid Until', inst.validUntil),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReferInstitution(PartnerInstitution inst) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Refer Institution'),
          content: Text(
            'Would you like to refer ${inst.name} to another parent?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Referral link for ${inst.name} copied!'),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
              ),
              child: const Text('Copy Link'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkshopsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Weekend workshops designed for children — coding, art, sports & more.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showScheduleWorkshopSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Workshops list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _workshops.length,
          itemBuilder: (context, index) {
            final workshop = _workshops[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          workshop.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: workshop.price == 'Free'
                              ? Colors.green.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          workshop.price,
                          style: TextStyle(
                            fontSize: 11,
                            color: workshop.price == 'Free'
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workshop.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        workshop.dateTime,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.child_care,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Age: ${workshop.ageGroup}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          workshop.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enrolled: ${workshop.enrolled} / ${workshop.maxCapacity}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      FilledButton(
                        onPressed: () => _showEnrollChildDialog(workshop),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Enroll Child',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Workshop History
        const Text(
          'Workshop History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              columns: const [
                DataColumn(label: Text('Workshop')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Attendance')),
                DataColumn(label: Text('Feedback')),
              ],
              rows: _workshopHistory.map((history) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        history.workshop,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(history.date)),
                    DataCell(Text(history.attendance)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            history.feedback.split(' ')[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showScheduleWorkshopSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Schedule Workshop',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Workshop name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'Coding',
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: '8-12',
                      decoration: const InputDecoration(
                        labelText: 'Target age group',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Date (mm/dd/yyyy)',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Time (--:-- --)',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: '2h',
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'Indiranagar Centre',
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Facilitator',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: '20',
                            decoration: const InputDecoration(
                              labelText: 'Max Capacity',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: '0',
                            decoration: const InputDecoration(
                              labelText: 'Fee (₹)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workshop Scheduled Successfully!'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Schedule'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEnrollChildDialog(WorkshopData workshop) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enroll Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a child to enroll for ${workshop.title}:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Child',
                ),
                items: _children
                    .map(
                      (child) => DropdownMenuItem(
                        value: child.name,
                        child: Text('${child.name} (Age: ${child.age})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully enrolled in ${workshop.title}!',
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
              ),
              child: const Text('Confirm Enrollment'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScholarshipsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Access various government, private, and internal scholarships for your children.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showPostScholarshipSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Post Scholarship'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Scholarships list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _scholarships.length,
          itemBuilder: (context, index) {
            final scholarship = _scholarships[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          scholarship.type,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        scholarship.amount,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0D9488),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    scholarship.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scholarship.eligibility,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deadline: ${scholarship.deadline}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'Applied: ${scholarship.applied}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showApplyScholarshipSheet(scholarship.title),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D9488)),
                        foregroundColor: const Color(0xFF0D9488),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Internal Scholarship Section
        const Text(
          'Udyami Kutumba Internal Scholarship',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Merit-based selection from member families. Reviewed by selection committee.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.shade100.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Udyami Merit Scholarship',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    '₹25,000',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Applied: 32 • Deadline 2026-08-01',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _showApplyScholarshipSheet('Udyami Merit Scholarship'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Tracker table
        const Text(
          'Applications Tracker',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              columns: const [
                DataColumn(label: Text('Child')),
                DataColumn(label: Text('Scholarship')),
                DataColumn(label: Text('Applied')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Disbursed')),
              ],
              rows: _scholarshipApplications.map((app) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        app.child,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(app.scholarship)),
                    DataCell(Text(app.appliedDate)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: app.status == 'Approved'
                              ? Colors.green.shade50
                              : app.status == 'Rejected'
                                  ? Colors.red.shade50
                                  : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          app.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: app.status == 'Approved'
                                ? Colors.green.shade700
                                : app.status == 'Rejected'
                                    ? Colors.red.shade700
                                    : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        app.amount,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text(app.disbursed)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showPostScholarshipSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Post Scholarship',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Scholarship Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Type (Govt / Private / NGO)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Eligibility Criteria',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Deadline (yyyy-mm-dd)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Application Link (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description / Remarks',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Scholarship Posted Successfully!'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Post Scholarship'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApplyScholarshipSheet(String scholarshipTitle) {
    String? selectedChild;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'Apply: $scholarshipTitle',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select child',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Pick a child',
                    ),
                    value: selectedChild,
                    items: _children.map((child) {
                      return DropdownMenuItem<String>(
                        value: child.name,
                        child: Text(child.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedChild = newValue;
                      });
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (selectedChild != null) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Application for $selectedChild submitted successfully!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a child to proceed.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit Application'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCareersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Explore various career paths with guidance from senior Udyami members.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showScheduleVisitSheet,
                icon: const Icon(Icons.calendar_month, size: 16),
                label: const Text('Schedule Visit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Business Visit Programme
        const Text(
          'Business Visit Programme',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _upcomingVisits.length,
          itemBuilder: (context, index) {
            final visit = _upcomingVisits[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.business, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.company,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${visit.industry} • ${visit.date}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Spots remaining: ${visit.spotsRemaining}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Registered for ${visit.company} visit!')),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Book', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),
        const Text(
          'Past Visits',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pastVisits.length,
          itemBuilder: (context, index) {
            final visit = _pastVisits[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        visit.company,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        visit.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    visit.feedback,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Professional Talk Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            OutlinedButton.icon(
              onPressed: _showBookSpeakerSheet,
              icon: const Icon(Icons.mic, size: 16),
              label: const Text('Book a Speaker'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D9488),
                side: const BorderSide(color: Color(0xFF0D9488)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              columns: const [
                DataColumn(label: Text('Speaker')),
                DataColumn(label: Text('Expertise')),
                DataColumn(label: Text('School')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Class')),
                DataColumn(label: Text('Topic')),
                DataColumn(label: Text('Feedback')),
              ],
              rows: _talkSessions.map((session) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        session.speaker,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(session.expertise)),
                    DataCell(Text(session.school)),
                    DataCell(Text(session.date)),
                    DataCell(Text(session.grade)),
                    DataCell(Text(session.topic)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            session.feedback.split(' ')[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 32),
        const Text(
          'Career Exploration Map',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _careerPaths.length,
          itemBuilder: (context, index) {
            final career = _careerPaths[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      career.icon,
                      color: const Color(0xFF0D9488),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    career.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Members in field: ${career.membersInField}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: FilledButton(
                      onPressed: () => _showRoleModelsSheet(career.title),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Meet a Role Model', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showScheduleVisitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Schedule a Business Visit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Industry',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date (yyyy-mm-dd)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Capacity (No. of children)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Additional Details',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Business Visit Scheduled Successfully!'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Schedule'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookSpeakerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Book a Speaker',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Speaker Name (Member ID)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Target School/Institution',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Target Class/Grade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Preferred Date (yyyy-mm-dd)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Speaker Booking Request Submitted!'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Request'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoleModelsSheet(String careerTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                '$careerTitle — Role Models',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Senior Udyami members willing to speak about a career as a $careerTitle:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _dummyRoleModels.length,
                  itemBuilder: (context, index) {
                    final roleModel = _dummyRoleModels[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
                            child: const Icon(Icons.person, color: Color(0xFF0D9488)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  roleModel.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  roleModel.experience,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Talk requested with ${roleModel.name}'),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                            ),
                            child: const Text('Request Talk'),
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
      },
    );
  }
}
