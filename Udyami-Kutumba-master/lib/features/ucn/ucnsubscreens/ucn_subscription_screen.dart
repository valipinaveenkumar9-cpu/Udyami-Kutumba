import 'package:flutter/material.dart';
import '../../../core/api/membership/membership_purchase_api.dart';
import '../../../core/ui/full_screen_pdf_viewer.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/network_utils.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'ucn_membership_history_screen.dart';
import '../../home/presentation/main_screen.dart';

class UcnSubscriptionScreen extends StatefulWidget {
  const UcnSubscriptionScreen({super.key});

  @override
  State<UcnSubscriptionScreen> createState() => _UcnSubscriptionScreenState();
}

class _UcnSubscriptionScreenState extends State<UcnSubscriptionScreen> {
  bool _isLoading = true;
  List<dynamic> _plans = [];
  bool _isPurchasing = false;
  final _api = MembershipPurchaseAPI();
  late Razorpay _razorpay;
  Map<String, dynamic>? _selectedPlan;
  String? _pendingPaymentId;
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('DEV DEBUG - Razorpay Event - PAYMENT_SUCCESS');
    debugPrint('DEV DEBUG - Payment ID: ${response.paymentId}');
    debugPrint('DEV DEBUG - Order ID: ${response.orderId}');
    debugPrint('DEV DEBUG - Signature: ${response.signature}');

    final missing = <String>[];
    if (_pendingPaymentId == null) missing.add('pendingPaymentId');
    if (response.paymentId == null) missing.add('paymentId');
    if (response.signature == null) missing.add('signature (backend likely did not return an order_id)');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment verification details missing: ${missing.join(', ')}'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      final verifyResponse = await _api.verifyPayment(
        paymentId: _pendingPaymentId!,
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );

      setState(() => _isPurchasing = false);

      if (verifyResponse != null && (verifyResponse['success'] == true || verifyResponse['message']?.toString().toLowerCase().contains('success') == true)) {
        if (mounted && _selectedPlan != null) {
          final membershipType = _selectedPlan!['membershipType']?.toString().toUpperCase() ?? '';
          // Default to PRIME if membershipType is empty or not BASIC
          final isPrime = membershipType == 'PRIME' || membershipType.isEmpty || membershipType != 'BASIC';
          final isBasic = membershipType == 'BASIC';

          final currentUser = SessionManager.user;
          if (currentUser != null) {
            final updatedUser = Map<String, dynamic>.from(currentUser);
            updatedUser['isPrime'] = isPrime;
            updatedUser['isBasic'] = isBasic;
            await SessionManager.saveSession(
              SessionManager.token ?? '',
              updatedUser,
            );
          }

          SessionManager.profileUpdateNotifier.value++;

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
                    const SizedBox(width: 8),
                    const Text('Payment Successful'),
                  ],
                ),
                content: Text(
                  'You have successfully subscribed to ${_selectedPlan!['planName']}!\n\nWould you like to download your payment receipt?',
                  style: const TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Fetching receipt from server...')),
                        );

                        final paymentId = _pendingPaymentId;
                        if (paymentId == null || paymentId.isEmpty) {
                          throw Exception("Payment ID not found.");
                        }

                        final pdfBytes = await _api.downloadReceipt(paymentId);

                        if (pdfBytes != null) {
                          if (ctx.mounted) {
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (context) => FullScreenPdfViewer(
                                  pdfBytes: pdfBytes,
                                  title: 'Receipt_$paymentId',
                                ),
                              ),
                            );
                          }
                        } else {
                          throw Exception("Failed to download receipt from server.");
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed to load receipt: $e')));
                        }
                      }
                    },
                    child: const Text('Download Receipt'),
                  ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx); // Close dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(initialIndex: 3),
                          ),
                          (route) => false,
                        );
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verifyResponse?['message'] ?? 'Payment verification failed.'),
              backgroundColor: Colors.red.shade800,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isPurchasing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying payment: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('DEV DEBUG - Razorpay Event - PAYMENT_ERROR');
    debugPrint('DEV DEBUG - Error Code: ${response.code}');
    debugPrint('DEV DEBUG - Error Message: ${response.message}');
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      debugPrint(
        'DEV DEBUG - Reason: User cancelled the payment / closed the checkout form.',
      );
    } else if (response.code == Razorpay.NETWORK_ERROR) {
      debugPrint('DEV DEBUG - Reason: Network error occurred.');
    } else {
      debugPrint('DEV DEBUG - Reason: Other payment issue.');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed: ${response.message ?? "Unknown error"}',
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('DEV DEBUG - Razorpay Event - EXTERNAL_WALLET');
    debugPrint('DEV DEBUG - Selected Wallet: ${response.walletName}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
        ),
      );
    }
  }

  Future<void> _startPayment(Map<String, dynamic> plan) async {
    debugPrint(
      'DEV DEBUG - _startPayment - Tapped purchase for plan: ${plan['planName']}',
    );
    final userId = SessionManager.user?['userId']?.toString();
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    _selectedPlan = plan;
    final planId = plan['id']?.toString() ?? plan['planId']?.toString() ?? plan['_id']?.toString();
    if (planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid plan ID.')));
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      final orderResponse = await _api.createOrder(userId: userId, planId: planId);

      if (orderResponse == null || (orderResponse['success'] == false)) {
        setState(() => _isPurchasing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderResponse?['message'] ?? 'Failed to create order.')),
        );
        return;
      }

      final orderData = orderResponse['data'] ?? orderResponse;
      final razorpayOrderId = orderData['razorpayOrderId'] ?? orderData['orderId'] ?? orderData['id'];
      _pendingPaymentId = orderData['paymentId'] ?? orderData['id'] ?? razorpayOrderId;

      if (razorpayOrderId == null) {
        debugPrint('DEV WARNING: Backend did not return a razorpayOrderId. Razorpay will not generate a signature.');
      }

      final user = SessionManager.user;
      final userPhone = user?['phone'] ?? '';
      final userEmail = user?['email'] ?? '';
      final userName = user?['fullName'] ?? user?['name'] ?? 'User';

      int amountInPaise = 0;
      if (orderData['amount'] != null) {
        amountInPaise = int.tryParse(orderData['amount'].toString()) ?? 0;
      } else {
        final priceStr = plan['price']?.toString() ?? '0';
        final price = double.tryParse(priceStr) ?? 0;
        amountInPaise = (price * 100).toInt();
      }

      var options = {
        'key': orderData['key'] ?? NetworkUtils.razorpayKey,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'Udyami Kutumba',
        'description': 'Subscription to ${plan['planName']}',
        if (razorpayOrderId != null) 'order_id': razorpayOrderId,
        'prefill': {'contact': userPhone, 'email': userEmail, 'name': userName},
      };

      debugPrint(
        'DEV DEBUG - _startPayment - Starting Razorpay checkout for ${plan['planName']}',
      );
      debugPrint('DEV DEBUG - _startPayment - Options: $options');

      setState(() => _isPurchasing = false);
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isPurchasing = false);
      debugPrint('DEV DEBUG - _startPayment - Error starting Razorpay: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting payment: $e')),
        );
      }
    }
  }

  List<dynamic> _history = [];
  Map<String, dynamic>? _activePlan;

  Future<void> _fetchPlans() async {
    debugPrint('DEV DEBUG - _fetchPlans - Fetching plans from API: /membership-purchase/membershipAllPlans');
    final response = await _api.getAllPlans();

    if (response != null && response['success'] == true) {
      debugPrint('DEV DEBUG - _fetchPlans - Plans Fetched Successfully: ${response['data']}');

      // Fetch user's history to determine active plans
      final userId = SessionManager.user?['userId']?.toString();
      if (userId != null) {
        debugPrint('DEV DEBUG - _fetchPlans - Fetching history from API for user: $userId');
        try {
          final histRes = await _api.getMembershipHistory(userId);
          if (histRes != null && histRes['success'] == true) {
            final List<dynamic> data = histRes['data'] ?? [];
            _history = data;
            debugPrint('DEV DEBUG - _fetchPlans - History Fetched: $data');

            final now = DateTime.now();
            for (var item in data) {
              if (item['endDate'] != null) {
                final endDate = DateTime.tryParse(item['endDate'].toString());
                if (endDate != null && endDate.isAfter(now)) {
                  if (_activePlan == null || endDate.isAfter(DateTime.parse(_activePlan!['endDate'].toString()))) {
                    _activePlan = item;
                  }
                }
              }
            }
            debugPrint('DEV DEBUG - _fetchPlans - Active Plan Identified: $_activePlan');
          }
        } catch (e) {
          debugPrint('DEV DEBUG - _fetchPlans - Error fetching history: $e');
        }
      }

      if (mounted) {
        setState(() {
          _plans = response['data'] ?? [];
          _isLoading = false;
        });
        
        debugPrint('DEV DEBUG - _fetchPlans - Total plans loaded: ${_plans.length}');
        for (var i = 0; i < _plans.length; i++) {
          final p = _plans[i];
          debugPrint('DEV DEBUG - Plan $i: ID=${p['id'] ?? p['_id'] ?? p['planId']} | Name=${p['planName']} | Price=${p['price']} | Type=${p['membershipType']} | Status=${p['isActive']}');
        }
      }
    } else {
      debugPrint('DEV DEBUG - _fetchPlans - Failed to fetch plans: $response');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load membership plans.')),
        );
      }
    }
  }

  Future<void> _purchasePlan(Map<String, dynamic> plan) async {
    final userId = SessionManager.user?['userId']?.toString();
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    setState(() => _isPurchasing = true);

    final membershipType =
        plan['membershipType']?.toString().toUpperCase() ?? '';
    final isPrime = membershipType == 'PRIME';
    final isBasic = membershipType == 'BASIC';

    final response = await _api.updateMembership(
      userId: userId,
      isBasic: isBasic,
      isPrime: isPrime,
    );

    setState(() => _isPurchasing = false);

    if (response != null &&
        (response['success'] == true ||
            response['message']?.toString().toLowerCase().contains('success') ==
                true)) {
      if (mounted) {
        // Update the cached user in SessionManager with new membership status
        final currentUser = SessionManager.user;
        if (currentUser != null) {
          final updatedUser = Map<String, dynamic>.from(currentUser);
          updatedUser['isPrime'] = isPrime;
          updatedUser['isBasic'] = isBasic;
          await SessionManager.saveSession(
            SessionManager.token ?? '',
            updatedUser,
          );
        }

        // Notify all listeners (UCN screen, profile screen, etc.) to refresh
        SessionManager.profileUpdateNotifier.value++;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully subscribed to ${plan['planName']}!'),
            backgroundColor: Colors.green.shade800,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?['message'] ?? 'Failed to update membership.',
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UcnMembershipHistoryScreen(),
                ),
              );
            },
            tooltip: 'Membership History',
          ),
          const ThemeToggleButton(),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          "UCN Memberships",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
          ? _buildEmptyState()
          : Stack(
        children: [
          _buildPlansList(),
          if (_isPurchasing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_rounded, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No plans available right now.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Choose Your Plan",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            "Unlock premium features and supercharge your networking experience.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: PageView.builder(
            clipBehavior: Clip.none,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              final isCurrent = index == _currentPage;

              // Scale down slightly if not focused
              final scale = isCurrent ? 1.0 : 0.9;
              return TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: scale, end: scale),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: _buildPlanCard(plan),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildPillIndicator(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPillIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_plans.length, (index) {
        final isCurrent = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isCurrent ? 24 : 8,
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFF1E293B) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isPopular = plan['isPopular'] == true;
    final planName = plan['planName'] ?? 'Unknown Plan';
    final priceStr = plan['price']?.toString() ?? '0';
    final price = double.tryParse(priceStr)?.toInt() ?? 0;
    final badge = plan['badge']?.toString() ?? '';
    final duration = plan['durationDays']?.toString() ?? '365';
    final features = (plan['features'] as List?) ?? [];

    // Distinct styles for different plans
    final bool isPrime =
        plan['membershipType']?.toString().toUpperCase() == 'PRIME';

    final planId = plan['id']?.toString() ?? plan['planId']?.toString() ?? plan['_id']?.toString();
    final isActiveSub = _activePlan != null && (_activePlan!['planId']?.toString() == planId || _activePlan!['plan']?['planId']?.toString() == planId);

    final List<Color> bgGradient = isPrime
        ? [
      const Color(0xFF0F2027),
      const Color(0xFF203A43),
      const Color(0xFF2C5364),
    ]
        : [Colors.white, Colors.white];
    final Color textColor = isPrime ? Colors.white : const Color(0xFF1E293B);
    final Color featureIconColor = isPrime
        ? Colors.amberAccent
        : Colors.teal.shade600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPrime ? const Color(0xFF203A43) : Colors.grey.shade300)
                .withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isPrime ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPopular || badge.isNotEmpty)
                  const SizedBox(height: 12), // space for badge
                Text(
                  planName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isPrime ? Colors.amberAccent : Colors.teal.shade700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "₹$price",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "/ $duration Days",
                      style: TextStyle(
                        fontSize: 15,
                        color: isPrime ? Colors.white70 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 24),

                // Features
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: features.map((f) {
                      final featureName = f['featureName']?.toString() ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: featureIconColor,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                featureName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isPrime ? Colors.white : Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isActiveSub ? null : () => _startPayment(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActiveSub
                          ? Colors.grey.shade400
                          : (isPrime ? Colors.amberAccent : const Color(0xFF1E293B)),
                      foregroundColor: isActiveSub
                          ? Colors.white
                          : (isPrime ? Colors.black : Colors.white),
                      elevation: isActiveSub ? 0 : (isPrime ? 8 : 4),
                      shadowColor: isActiveSub
                          ? Colors.transparent
                          : ((isPrime ? Colors.amberAccent : Colors.black).withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: Text(
                      isActiveSub ? "Purchased" : "Purchase Now",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isPopular || badge.isNotEmpty)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  badge.isNotEmpty ? badge : "POPULAR",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}