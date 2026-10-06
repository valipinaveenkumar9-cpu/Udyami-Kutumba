import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/ubn/lead_api.dart';
import '../../../core/models/lead_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/api/communications/communications_api.dart';
import '../../../core/api/ubn/gratitude_api.dart';
import '../../ucn/ucnsubscreens/ucn_subscription_screen.dart';
import 'communication_stats_screen.dart';
import 'ucn_stats_screen.dart';
import 'filtered_leads_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../requirements/presentation/requirements_screen.dart';
import 'package:udyamikutumba/core/api/requirements/requirements_api.dart';
import '../../social_channels/presentation/social_channels_screen.dart';
import '../../../core/api/membership/membership_purchase_api.dart';

void main() {
  runApp(const LeadManagementApp());
}

class LeadManagementApp extends StatelessWidget {
  const LeadManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lead Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF635BFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        fontFamily: 'Roboto',
      ),
      home: const LeadManagementScreen(),
    );
  }
}

class LeadManagementScreen extends StatefulWidget {
  const LeadManagementScreen({super.key});

  @override
  State<LeadManagementScreen> createState() =>
      _LeadManagementScreenState();
}

class _LeadManagementScreenState extends State<LeadManagementScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedSource = 'All sources';
  String selectedCategory = 'All categories';
  String selectedStage = 'All stages';
  String selectedPeriod = 'All';

  bool _isLoading = true;
  List<LeadModel> _leads = [];
  List<LeadModel> _freeLeads = [];
  List<LeadModel> _paidLeads = [];
  String? _currentUserId;
  int _totalCampaigns = 0;
  int _totalUcn = 0;
  int _b2cReqCount = 0;
  int _b2bReqCount = 0;
  bool aiMiningExpanded = false;
  bool _isPrime = false;
  bool _isDigitalMarketingSubscribed = false;
  final MembershipPurchaseAPI _membershipAPI = MembershipPurchaseAPI();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userData = SessionManager.user;
      if (userData != null) {
        _currentUserId = userData['userId'];
        _isPrime = userData['isPrime'] == true;
      }

      if (_currentUserId != null) {
        final fetchedLeads = await LeadAPI.getLeadsById(_currentUserId!);
        final allFree = await LeadAPI.getFreeMemberLeads();
        final free = allFree.where((l) => l.createdUser?['userId'] == _currentUserId).toList();
        final allPaid = await LeadAPI.getPaidMemberLeads();
        final paid = allPaid.where((l) => l.createdUser?['userId'] == _currentUserId).toList();
        
        // Fetch Comms count
        int comms = 0;
        final commsResponse = await CommunicationsAPI().getAllCampaigns(userId: _currentUserId, limit: 1);
        if (commsResponse != null && commsResponse is Map && commsResponse['success'] == true) {
          comms = commsResponse['totalRecords'] ?? 0;
        }

        // Fetch UCN count
        int ucn = 0;
        final slips = await GratitudeAPI.getAllGratitudeSlips();
        for (var slip in slips) {
          if (slip.createdUser?.userId == _currentUserId || slip.thankYouMember?.userId == _currentUserId) {
            ucn++;
          }
        }
        
        // Fetch Requirements counts
        int b2cReq = 0;
        int b2bReq = 0;
        String wardId = userData?['wardId'] ?? 'fb565c5c-fa8b-4b8c-9607-d4fd1a212bd1';
        String talukaId = userData?['talukaId'] ?? 'f9a6257c-7cbe-4c1c-a25a-8403ee801110';
        
        final b2cRes = await RequirementsAPI.getB2CRequirements(wardId, 'IT Services'); // Or could just call for all without category if API supported, defaulting to first for count
        if (b2cRes['success']) {
          b2cReq = (b2cRes['data'] as List).length;
        }
        
        final b2bRes = await RequirementsAPI.getB2BRequirements(talukaId, 'IT Services');
        if (b2bRes['success']) {
          b2bReq = (b2bRes['data'] as List).length;
        }

        // Fetch Subscription Status
        bool hasDigitalMarketing = false;
        try {
          final histRes = await _membershipAPI.getMembershipHistory(_currentUserId!);
          if (histRes != null && histRes['success'] == true) {
            final List<dynamic> data = histRes['data'] ?? [];
            final now = DateTime.now();
            for (var item in data) {
              final plan = item['plan'] ?? {};
              if (plan['membershipType'] == 'DIGITAL_MARKETING') {
                if (item['endDate'] != null) {
                  final endDate = DateTime.tryParse(item['endDate'].toString());
                  if (endDate != null && endDate.isAfter(now)) {
                    hasDigitalMarketing = true;
                    break;
                  }
                }
              }
            }
          }
        } catch (_) {}
        
        if (userData?['isDigital'] == true) {
          hasDigitalMarketing = true;
        }

        if (mounted) {
          setState(() {
            _leads = fetchedLeads;
            _freeLeads = free;
            _paidLeads = paid;
            _totalCampaigns = comms;
            _totalUcn = ucn;
            _b2cReqCount = b2cReq;
            _b2bReqCount = b2bReq;
            _isDigitalMarketingSubscribed = hasDigitalMarketing;
          });
        }
      }
    } catch (e) {
      print('DEV DEBUG - error fetching leads: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<LeadModel> get filteredLeads {
    final query = searchController.text.toLowerCase();

    // Combine all relevant leads for the main list if needed
    // But currently, the UI just shows counts on top, and maybe a list at the bottom?
    // Let's combine them for the full list view.
    final allCombined = [..._leads, ..._freeLeads, ..._paidLeads];

    return allCombined.where((lead) {
      final matchesSearch =
          lead.memberName.toLowerCase().contains(query) ||
          lead.business.toLowerCase().contains(query) ||
          lead.phone.toLowerCase().contains(query) ||
          lead.category.toLowerCase().contains(query);

      final matchesSource =
          selectedSource == 'All sources' ||
              lead.leadType == selectedSource;

      final matchesCategory =
          selectedCategory == 'All categories' ||
              lead.category == selectedCategory;

      final matchesStage =
          selectedStage == 'All stages' ||
              lead.status == selectedStage;

      return matchesSearch &&
          matchesSource &&
          matchesCategory &&
          matchesStage;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF635BFF).withOpacity(0.2) : const Color(0xFFEDEBFF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF635BFF),
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Text(
              'Lead Management',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF171923),
              ),
            ),
          ],
        ),
        actions: [
              const ThemeToggleButton(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 700));
                },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildSummaryCards(),

              const SizedBox(height: 18),

              _buildSourceSection(),

              const SizedBox(height: 18),

              _buildAiMiningCard(),

              const SizedBox(height: 18),

              _buildCategoryCard(),

              const SizedBox(height: 20),

              _buildFilterSection(),

              const SizedBox(height: 15),

              _buildLeadHeader(),

              const SizedBox(height: 10),

              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...filteredLeads.map(
                              (lead) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildLeadCard(lead),
                          ),
                        ),
                        if (filteredLeads.isEmpty)
                          _buildEmptyState(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDataSheet(String title, String data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditSheet(LeadModel lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20, left: 160),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                'Edit Lead',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: lead.memberName,
                      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: lead.phone,
                      decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: lead.category,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: lead.business,
                      decoration: const InputDecoration(labelText: 'Business', border: OutlineInputBorder()),
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
                      const SnackBar(content: Text('Lead updated manually')),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Widget _buildJoinPrimeUI(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade900,
              Colors.teal.shade700,
              Colors.teal.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.amberAccent,
                size: 80,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Unlock Lead Management",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Join UBN to access the exclusive Lead Management dashboard, track your leads, and grow your business network.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UcnSubscriptionScreen()),
                  );
                },
                icon: const Icon(Icons.workspace_premium_rounded),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.teal.shade900,
                  elevation: 10,
                  shadowColor: Colors.amberAccent.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  "Subscribe for UBN Membership",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Upgrade your membership to unlock premium features",
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinDigitalMarketingUI(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade900,
              Colors.teal.shade700,
              Colors.teal.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.amberAccent,
                size: 80,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Unlock AI Marketing",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Join the Digital Marketing Plan to let our AI automatically generate, schedule, and publish posts to all your social channels.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UcnSubscriptionScreen()),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.teal.shade900,
                  elevation: 10,
                  shadowColor: Colors.amberAccent.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  "Subscribe to Digital Marketing",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionBottomSheet(BuildContext context, String feature) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              if (feature == 'Digital Marketing')
                _buildJoinDigitalMarketingUI(context)
              else
                _buildJoinPrimeUI(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lead Management',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF161722),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Unified command center for all 6 lead sources — requirements, B2B, social ads, bulk/IVR, manual, and AI generation.',
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    int totalLeads = _leads.length;
    int completedLeads = _leads.where((l) => l.status == 'Completed').length;
    double conversionRate = totalLeads == 0 ? 0 : (completedLeads / totalLeads) * 100;
    
    // For now we don't have business value per lead locally stored in LeadModel (except via Gratitude/Completed endpoints)
    // We will show a placeholder or basic metric for value for now.
    String formattedValue = "₹0";

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        _summaryCard(
          'Total leads',
          totalLeads.toString(),
          Icons.track_changes_rounded,
        ),
        _summaryCard(
          'Acceptance rate',
          'N/A', // Update logic if acceptance is tracked differently
          Icons.trending_up_rounded,
        ),
        _summaryCard(
          'Conversion rate',
          '${conversionRate.toStringAsFixed(1)}%',
          Icons.trending_up_rounded,
        ),
        _summaryCard(
          '₹ closed',
          formattedValue,
          Icons.currency_rupee_rounded,
        ),
      ],
    );
  }

  Widget _summaryCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection() {
    int b2cCount = _b2cReqCount;
    int b2bCount = _b2bReqCount;
    int socialCount = _leads.where((l) => l.leadType == 'Social Channels' || l.leadType == 'Social Ad').length;
    int aiCount = _leads.where((l) => l.leadType == 'AI Generated').length;
    
    // Everything else from _leads falls into Manual
    int manualCount = _leads.where((l) {
      return l.leadType != 'Social Channels' && l.leadType != 'Social Ad' && 
             l.leadType != 'AI Generated';
    }).length;
    
    int ucnCount = _totalUcn;
    int commsCount = _totalCampaigns;
    
    final sources = [
      (
      'B2C Requirement',
      b2cCount.toString(),
      Icons.chat_bubble_outline_rounded,
      const Color(0xFF6366F1),
      ),
      (
      'B2B Requirement',
      b2bCount.toString(),
      Icons.business_center_outlined,
      const Color(0xFF8B5CF6),
      ),
      (
      'Social Channels',
      socialCount.toString(),
      Icons.campaign_outlined,
      const Color(0xFF3B82F6),
      ),
      (
      'Communication',
      commsCount.toString(),
      Icons.radio_rounded,
      const Color(0xFF10B981),
      ),
      (
      'Own',
      manualCount.toString(),
      Icons.person_add_alt_1_rounded,
      const Color(0xFF64748B),
      ),
      (
      'AI Generated',
      aiCount.toString(),
      Icons.smart_toy_outlined,
      const Color(0xFFF59E0B),
      ),
      (
      'UBN',
      ucnCount.toString(),
      Icons.event_available_outlined,
      const Color(0xFFEC4899),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lead Sources',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
          ),
          itemCount: sources.length,
          itemBuilder: (context, index) {
            final source = sources[index];

            return GestureDetector(
              onTap: () {
                final sourceName = source.$1;

                if (sourceName == 'Communication') {
                  if (!_isPrime) {
                    _showSubscriptionBottomSheet(context, 'UBN');
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunicationStatsScreen()));
                } else if (sourceName == 'UBN') {
                  if (!_isPrime) {
                    _showSubscriptionBottomSheet(context, 'UBN');
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UcnStatsScreen()));
                } else if (sourceName == 'Social Channels') {
                  if (!_isDigitalMarketingSubscribed) {
                    _showSubscriptionBottomSheet(context, 'Digital Marketing');
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialChannelsScreen(showAppBar: true)));
                } else if (sourceName == 'B2C Requirement') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RequirementsScreen(initialIndex: 0)));
                } else if (sourceName == 'B2B Requirement') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RequirementsScreen(initialIndex: 1)));
                } else if (sourceName == 'Own' || sourceName == 'AI Generated') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This feature will be implemented later.')));
                } else {
                  // Fallback for any other source
                  final filtered = _leads.where((l) => l.leadType == sourceName).toList();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FilteredLeadsScreen(source: sourceName, leads: filtered)));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: source.$4.withOpacity(.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        source.$3,
                        size: 16,
                        color: source.$4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      source.$2,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      source.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAiMiningCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                aiMiningExpanded = !aiMiningExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEBFF),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF635BFF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI lead mining',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Generate fresh leads from network signals',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          if (aiMiningExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 15),
                  Text(
                    'Use AI signals to discover new potential customers based on business activity and network data.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_awesome, size: 17),
                      label: const Text('Generate Leads'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leads by business category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 18),

          _categoryBar(
            'Uncategorized',
            14,
            1.0,
            const Color(0xFF64748B),
          ),
          _categoryBar(
            'Advertising',
            2,
            .30,
            const Color(0xFF64748B),
          ),
          _categoryBar(
            'Marketing',
            1,
            .14,
            const Color(0xFF6366F1),
          ),
          _categoryBar(
            'Architecture',
            1,
            .14,
            const Color(0xFF64748B),
          ),
          _categoryBar(
            'Reality',
            1,
            .14,
            const Color(0xFF64748B),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _legend('B2C Requirement', const Color(0xFF6366F1)),
              _legend('B2B Requirement', const Color(0xFF8B5CF6)),
              _legend('Social Ad', const Color(0xFF3B82F6)),
              _legend('Bulk / IVR', const Color(0xFF10B981)),
              _legend('Manual', const Color(0xFF64748B)),
              _legend('AI Generated', const Color(0xFFF59E0B)),
              _legend('Circle Meeting', const Color(0xFFEC4899)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryBar(
      String title,
      int count,
      double percentage,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFFE9EAF0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 22,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.filter_alt_outlined,
              size: 18,
              color: Colors.grey,
            ),
            SizedBox(width: 7),
            Text(
              'Filter leads',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),

        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search name, category, ward, phone…',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              onPressed: () {
                searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close_rounded),
            )
                : null,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _dropdown(
                value: selectedSource,
                items: const [
                  'All sources',
                  'B2C Requirement',
                  'B2B Requirement',
                  'Social Ad',
                  'Bulk / IVR',
                  'Manual',
                  'AI Generated',
                  'Circle Meeting',
                ],
                onChanged: (value) {
                  setState(() {
                    selectedSource = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dropdown(
                value: selectedCategory,
                items: const [
                  'All categories',
                  'Marketing',
                  'Advertising',
                  'Architecture',
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _dropdown(
                value: selectedStage,
                items: const [
                  'All stages',
                  'Closed',
                  'Prospect',
                  'Enrolled',
                ],
                onChanged: (value) {
                  setState(() {
                    selectedStage = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dropdown(
                value: selectedPeriod,
                items: const [
                  'All',
                  'Today',
                  '7 days',
                  '30 days',
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.grey.shade400 : null),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white : const Color(0xFF292B35),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLeadHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Leads',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
          ),
          child: Text(
            '${filteredLeads.length} leads',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadCard(LeadModel lead) {
    int score = int.tryParse(lead.heatLevel) ?? 0;
    String dateStr = lead.createdAt != null && lead.createdAt!.length > 10 
        ? lead.createdAt!.substring(0, 10) 
        : lead.createdAt ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showDataSheet('User Details', 'Name: ${lead.memberName}\nSource: ${lead.leadType}'),
                child: Container(
                  height: 43,
                  width: 43,
                  decoration: BoxDecoration(
                    color: _sourceColor(lead.leadType).withOpacity(.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _sourceIcon(lead.leadType),
                    color: _sourceColor(lead.leadType),
                    size: 21,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.memberName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _launchPhone(lead.phone),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lead.phone,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _stageBadge(lead.status),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _infoChip(
                Icons.source_outlined,
                lead.leadType.isEmpty ? 'Unknown' : lead.leadType,
                _sourceColor(lead.leadType),
                onTap: null,
              ),
              _infoChip(
                Icons.category_outlined,
                lead.category,
                Colors.grey.shade700,
                onTap: () => _showDataSheet('Category Data', 'Category: ${lead.category}\nDetails related to ${lead.category} architecture will be shown here.'),
              ),
              _infoChip(
                Icons.location_on_outlined,
                lead.business.isEmpty ? 'Unknown' : lead.business,
                Colors.grey.shade700,
                onTap: () => _showDataSheet('Business Data', 'Business: ${lead.business}\nDetails related to business will be shown here.'),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _scoreWidget(score, onTap: () => _showDataSheet('Score Details', 'Score: $score\nScore breakdown and suggestions will be shown here.')),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showDataSheet('Calendar Data', 'Date: $dateStr\nScheduled follow-ups and events will be shown here.'),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      final cleanPhone = lead.phone.replaceAll(RegExp(r'[^\d+]'), '');
                      final Uri url = Uri.parse('https://wa.me/$cleanPhone');
                      launchUrl(url);
                    },
                    child: Image.asset(
                      'assets/whatsapp_logo_green.svg.webp',
                      width: 22,
                      height: 22,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.chat, color: Colors.green.shade600, size: 20);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton(
                    Icons.edit_outlined,
                    'Edit',
                    Colors.grey.shade700,
                        () => _showEditSheet(lead),
                  ),
                  _actionButton(
                    Icons.warning_amber_rounded,
                    'Mark bad',
                    Colors.amber.shade700,
                        () => _showMessage('Lead marked as bad'),
                  ),
                  _actionButton(
                    Icons.delete_outline_rounded,
                    'Delete',
                    Colors.red.shade500,
                        () => _showDeleteDialog(lead),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
      IconData icon,
      String text,
      Color color, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(.07),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: color.withOpacity(.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreWidget(int score, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: score >= 60
                ? (isDark ? const Color(0xFF14532d).withOpacity(0.3) : const Color(0xFFEFFDF5))
                : (isDark ? Colors.grey.shade800 : const Color(0xFFF8F9FB)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: score >= 60
                  ? (isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0))
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: 13,
                color: score >= 60
                    ? const Color(0xFF16A34A)
                    : Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                'Score $score',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: score >= 60
                      ? const Color(0xFF15803D)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _stageBadge(String stage) {
    Color color;

    switch (stage) {
      case 'Closed':
        color = const Color(0xFF635BFF);
        break;
      case 'Prospect':
        color = const Color(0xFF2563EB);
        break;
      case 'Enrolled':
        color = const Color(0xFF059669);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stage,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _actionButton(
      IconData icon,
      String tooltip,
      Color color,
      VoidCallback onTap,
      ) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      padding: EdgeInsets.zero,
      icon: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 42,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          Text(
            'No leads found',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try changing your search or filters.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _sourceColor(String source) {
    switch (source) {
      case 'B2C Requirement':
        return const Color(0xFF6366F1);
      case 'B2B Requirement':
        return const Color(0xFF8B5CF6);
      case 'Social Ad':
        return const Color(0xFF3B82F6);
      case 'Bulk / IVR':
        return const Color(0xFF10B981);
      case 'AI Generated':
        return const Color(0xFFF59E0B);
      case 'Circle Meeting':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _sourceIcon(String source) {
    switch (source) {
      case 'B2C Requirement':
        return Icons.chat_bubble_outline_rounded;
      case 'B2B Requirement':
        return Icons.business_center_outlined;
      case 'Social Ad':
        return Icons.campaign_outlined;
      case 'Bulk / IVR':
        return Icons.radio_rounded;
      case 'AI Generated':
        return Icons.smart_toy_outlined;
      case 'Circle Meeting':
        return Icons.event_available_outlined;
      default:
        return Icons.person_add_alt_1_rounded;
    }
  }

  BoxDecoration _cardDecoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isDark ? Colors.grey.shade800 : const Color(0xFFE5E7EB),
      ),
      boxShadow: [
        if (!isDark)
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteDialog(LeadModel lead) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete lead?'),
          content: Text(
            'Are you sure you want to delete ${lead.memberName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _leads.remove(lead);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
