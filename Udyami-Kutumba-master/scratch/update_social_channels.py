import re

with open('lib/features/social_channels/presentation/social_channels_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

imports = """
import '../../../core/api/membership/membership_purchase_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../ucn/ucnsubscreens/ucn_subscription_screen.dart';
"""
content = content.replace("import 'widgets/marketos_theme.dart';", "import 'widgets/marketos_theme.dart';" + imports)

vars_to_add = """
  bool _isDigitalMarketingSubscribed = false;
  bool _isLoadingSubscription = true;
  final MembershipPurchaseAPI _membershipAPI = MembershipPurchaseAPI();
"""

content = content.replace("late PageController _pageController;", "late PageController _pageController;" + vars_to_add)


init_add = """
    _checkSubscriptionStatus();
    SessionManager.profileUpdateNotifier.addListener(_checkSubscriptionStatus);
"""

content = content.replace("_pageController = PageController(initialPage: _currentIndex);", "_pageController = PageController(initialPage: _currentIndex);" + init_add)

dispose_add = """
    SessionManager.profileUpdateNotifier.removeListener(_checkSubscriptionStatus);
"""

content = content.replace("super.dispose();", dispose_add + "    super.dispose();")

methods = """
  Future<void> _checkSubscriptionStatus() async {
    final user = SessionManager.user;
    if (user != null && user['userId'] != null) {
      try {
        final histRes = await _membershipAPI.getMembershipHistory(user['userId'].toString());
        if (histRes != null && histRes['success'] == true) {
          final List<dynamic> data = histRes['data'] ?? [];
          final now = DateTime.now();
          bool hasDigitalMarketing = false;
          for (var item in data) {
            if (item['membershipType'] == 'DIGITAL_MARKETING') {
              if (item['endDate'] != null) {
                final endDate = DateTime.tryParse(item['endDate'].toString());
                if (endDate != null && endDate.isAfter(now)) {
                  hasDigitalMarketing = true;
                  break;
                }
              }
            }
          }
          if (mounted) {
            setState(() {
              _isDigitalMarketingSubscribed = hasDigitalMarketing;
              _isLoadingSubscription = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingSubscription = false);
        }
      } catch (e) {
        if (mounted) setState(() => _isLoadingSubscription = false);
      }
    } else {
      if (mounted) setState(() => _isLoadingSubscription = false);
    }
  }

  Widget _buildJoinDigitalMarketingUI(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
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
              color: Colors.teal.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.1),
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
                  shadowColor: Colors.amberAccent.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  "Subscribe to Digital Marketing",
                  style: TextStyle(
                    fontSize: 16,
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
"""

content = content.replace("  @override\n  Widget build(BuildContext context) {", methods + "\n  @override\n  Widget build(BuildContext context) {")

build_inject = """
    if (_isLoadingSubscription) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }
    
    if (!_isDigitalMarketingSubscribed) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        appBar: showAppBar
            ? AppBar(
                title: const Text('Social Channels', style: TextStyle(fontWeight: FontWeight.w600)),
                centerTitle: true,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                elevation: 0,
              )
            : null,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildJoinDigitalMarketingUI(context),
        ),
      );
    }
"""

content = content.replace("final showAppBar = widget.showAppBar ?? true;\n", "final showAppBar = widget.showAppBar ?? true;\n" + build_inject)

with open('lib/features/social_channels/presentation/social_channels_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
