import 'package:flutter/material.dart';
import 'recharge_coins_screen.dart';
import 'coin_history_screen.dart';
import 'campaign_step1_type_screen.dart';
import 'campaign_detail_screen.dart';
import '../models/campaign.dart';
import 'package:provider/provider.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'campaign_history_screen.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/models/user_model.dart';
import '../../ucn/ucnsubscreens/ucn_subscription_screen.dart';

class CommunicationsScreen extends StatefulWidget {
  const CommunicationsScreen({super.key});

  @override
  State<CommunicationsScreen> createState() => _CommunicationsScreenState();
}

class _CommunicationsScreenState extends State<CommunicationsScreen> {
  String _selectedFilter = 'All';
  bool _isPrime = false;

  @override
  void initState() {
    super.initState();
    _checkPrimeStatus();
    SessionManager.profileUpdateNotifier.addListener(_checkPrimeStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunicationsViewModel>().fetchWalletData();
      context.read<CommunicationsViewModel>().fetchCampaignHistory();
    });
  }

  void _checkPrimeStatus() {
    final user = SessionManager.user;
    if (user != null) {
      final userModel = UserModel.fromJson(user);
      setState(() {
        _isPrime = userModel.isPrime == true;
      });
    }
  }

  @override
  void dispose() {
    SessionManager.profileUpdateNotifier.removeListener(_checkPrimeStatus);
    super.dispose();
  }

  List<Campaign> _getFilteredCampaigns(List<Campaign> allCampaigns) {
    if (_selectedFilter == 'All') return allCampaigns;
    if (_selectedFilter == 'Sending') {
      return allCampaigns
          .where(
            (c) =>
                c.statusText.toLowerCase() == 'sending' ||
                c.statusText.toLowerCase() == 'pending' ||
                c.statusText.toLowerCase() == 'in progress',
          )
          .toList();
    }
    if (_selectedFilter == 'Completed') {
      return allCampaigns
          .where(
            (c) =>
                c.statusText.toLowerCase() == 'completed' ||
                c.statusText.toLowerCase() == 'approved',
          )
          .toList();
    }
    return allCampaigns;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_isPrime) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJoinPrimeUI(context),
            ],
          ),
        ),
      );
    }

    return Consumer<CommunicationsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
          body: RefreshIndicator(
            onRefresh: () async {
              viewModel.fetchWalletData();
              viewModel.fetchCampaignHistory();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Balance Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.orange.shade900.withValues(alpha: 0.2)
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.monetization_on_rounded,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Coin balance",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: viewModel.isLoadingWallet
                                ? null
                                : () {
                                    viewModel.fetchWalletData();
                                    viewModel.fetchCampaignHistory();
                                  },
                            icon: viewModel.isLoadingWallet
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.orange.shade700,
                                    ),
                                  )
                                : Icon(Icons.refresh_rounded, color: Colors.orange.shade700, size: 22),
                            tooltip: 'Refresh',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (viewModel.wallet?.coins ?? 0).toString(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Prime plan · refills 2,000 on 1 Aug",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RechargeCoinsScreen(
                                      viewModel: viewModel,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: const Text(
                                "Recharge",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                  builder: (context) => CoinHistoryScreen(viewModel: viewModel),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal,
                                side: const BorderSide(color: Colors.teal),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.history_rounded, size: 20),
                              label: const Text(
                                "History",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  "Start a campaign",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    CampaignTile(
                      icon: Icons.message_rounded,
                      title: "Bulk SMS",
                      subtitle: "1 coin /msg",
                      onTap: () {
                        viewModel.startNewCampaign("Bulk SMS");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampaignStep1TypeScreen(viewModel: viewModel),
                          ),
                        );
                      },
                    ),
                    CampaignTile(
                      icon: Icons.chat_bubble_rounded,
                      title: "WhatsApp",
                      subtitle: "2 coins /msg",
                      onTap: () {
                        viewModel.startNewCampaign("WhatsApp");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampaignStep1TypeScreen(viewModel: viewModel),
                          ),
                        );
                      },
                    ),
                    // CampaignTile(
                    //   icon: Icons.facebook_rounded,
                    //   title: "Meta WhatsApp",
                    //   subtitle: "2 coins /msg",
                    //   onTap: () {
                    //     viewModel.startNewCampaign("Meta WhatsApp");
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => CampaignStep1TypeScreen(viewModel: viewModel),
                    //       ),
                    //     );
                    //   },
                    // ),
                    CampaignTile(
                      icon: Icons.phone_in_talk_rounded,
                      title: "Voice IVR",
                      subtitle: "3 coins /call",
                      onTap: () {
                        viewModel.startNewCampaign("Voice IVR");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampaignStep1TypeScreen(viewModel: viewModel),
                          ),
                        );
                      },
                    ),
                    // CampaignTile(
                    //   icon: Icons.dialpad_rounded,
                    //   title: "Interactive IVR",
                    //   subtitle: "4 coins /call",
                    //   onTap: () {
                    //     viewModel.startNewCampaign("Interactive IVR");
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => CampaignStep1TypeScreen(viewModel: viewModel),
                    //       ),
                    //     );
                    //   },
                    // ),
                    CampaignTile(
                      icon: Icons.email_rounded,
                      title: "Bulk Email",
                      subtitle: "1 coin /email",
                      onTap: () {
                        viewModel.startNewCampaign("Bulk Email");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampaignStep1TypeScreen(viewModel: viewModel),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My campaigns",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CampaignHistoryScreen(viewModel: viewModel),
                          ),
                        );
                      },
                      child: Text(
                        "History",
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipWidget(
                        title: "All",
                        selected: _selectedFilter == 'All',
                        onTap: () => setState(() => _selectedFilter = 'All'),
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        title: "Sending",
                        selected: _selectedFilter == 'Sending',
                        onTap: () =>
                            setState(() => _selectedFilter = 'Sending'),
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        title: "Completed",
                        selected: _selectedFilter == 'Completed',
                        onTap: () =>
                            setState(() => _selectedFilter = 'Completed'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (viewModel.isLoadingCampaigns)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (viewModel.campaignHistory.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No campaigns yet",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...() {
                    final filtered = _getFilteredCampaigns(
                      viewModel.campaignHistory,
                    );
                    final top5 = filtered.take(5).toList();

                    return top5.map((campaign) {
                      return CampaignRow(
                        icon: campaign.icon,
                        title: "${campaign.title}",
                        subtitle: campaign.subtitle,
                        badge: campaign.statusText,
                        badgeColor: campaign.statusColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CampaignDetailScreen(campaign: campaign),
                            ),
                          );
                        },
                      );
                    }).toList();
                  }(),

                const SizedBox(height: 80), // Padding for bottom nav
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildJoinPrimeUI(BuildContext context) {
    final theme = Theme.of(context);
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
            "Unlock Communications",
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
            "Join UCN Prime to run communication campaigns, send targeted SMS, manage contacts, and grow your business network seamlessly.",
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
                shadowColor: Colors.amberAccent.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              label: const Text(
                "Subscribe for Prime Membership",
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
}

class CampaignTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const CampaignTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.teal),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class CampaignRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final MaterialColor badgeColor;
  final VoidCallback? onTap;

  const CampaignRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? badgeColor.withOpacity(0.2)
                : badgeColor.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: badgeColor.shade700),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? badgeColor.withOpacity(0.2)
                : badgeColor.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: badgeColor.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const FilterChipWidget({
    super.key,
    required this.title,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(title),
        backgroundColor: selected
            ? Colors.teal.withOpacity(0.1)
            : isDark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
        labelStyle: TextStyle(
          color: selected
              ? Colors.teal
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected
                ? Colors.teal.withOpacity(0.2)
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
