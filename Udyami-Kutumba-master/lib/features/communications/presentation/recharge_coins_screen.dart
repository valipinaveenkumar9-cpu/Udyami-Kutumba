import 'package:flutter/material.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class RechargeCoinsScreen extends StatefulWidget {
  final CommunicationsViewModel viewModel;

  const RechargeCoinsScreen({super.key, required this.viewModel});

  @override
  State<RechargeCoinsScreen> createState() => _RechargeCoinsScreenState();
}

class _RechargeCoinsScreenState extends State<RechargeCoinsScreen> {
  bool _isRecharging = false;

  void _handleRecharge(String coinsString) async {
    if (_isRecharging) return;
    setState(() => _isRecharging = true);

    int coinsToAdd = int.tryParse(coinsString.replaceAll(',', '')) ?? 0;
    if (coinsToAdd > 0) {
      final success = await widget.viewModel.addWalletCoins(coinsToAdd);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coins recharged successfully!')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to recharge coins.')));
        }
      }
    }

    if (mounted) setState(() => _isRecharging = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recharge Coins",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final balance = widget.viewModel.wallet?.coins ?? 0;
                return Text(
                  "Balance $balance",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isRecharging)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            /// Coin Packages
            Column(
              children: [
                CoinPackCard(coins: "1,000", price: "₹499", onTap: () => _handleRecharge("1,000")),
                CoinPackCard(coins: "5,000", price: "₹1,999", popular: true, badge: "Most Popular", onTap: () => _handleRecharge("5,000")),
                CoinPackCard(coins: "10,000", price: "₹3,499", badge: "Best Value", onTap: () => _handleRecharge("10,000")),
                CoinPackCard(coins: "25,000", price: "₹7,999", badge: "Mega Pack", onTap: () => _handleRecharge("25,000")),
              ],
            ),

            const SizedBox(height: 24),

            /// Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Coins are shared across all channels and never expire. Unreached numbers are automatically refunded.",
                      style: TextStyle(height: 1.5, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              "Rate Card",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 16),

            const RateCardTile(icon: Icons.message_rounded, title: "Bulk SMS", rate: "1 coin / SMS", color: Colors.blue),
            const RateCardTile(icon: Icons.chat_bubble_rounded, title: "WhatsApp", rate: "2 coins / msg", color: Colors.green),
            const RateCardTile(icon: Icons.facebook_rounded, title: "Meta WhatsApp", rate: "2 coins / msg", color: Colors.indigo),
            const RateCardTile(icon: Icons.phone_in_talk_rounded, title: "Voice IVR", rate: "3 coins / call", color: Colors.deepPurple),
            const RateCardTile(icon: Icons.dialpad_rounded, title: "Interactive IVR", rate: "4 coins / call", color: Colors.orange),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class CoinPackCard extends StatelessWidget {
  final String coins;
  final String price;
  final bool popular;
  final String badge;
  final VoidCallback? onTap;

  const CoinPackCard({
    super.key,
    required this.coins,
    required this.price,
    this.popular = false,
    this.badge = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final List<Color> bgGradient = popular
        ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
        : [Colors.white, Colors.white];
    final Color textColor = popular ? Colors.white : const Color(0xFF1E293B);
    final Color highlightColor = popular ? Colors.amberAccent : Colors.teal.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (popular ? const Color(0xFF203A43) : Colors.grey.shade300).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: popular ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (popular || badge.isNotEmpty) const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: popular ? Colors.amber.withValues(alpha: 0.2) : Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.monetization_on_rounded, color: popular ? Colors.amberAccent : Colors.orange.shade700, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$coins COINS",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: highlightColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: popular ? Colors.amberAccent : const Color(0xFF1E293B),
                      foregroundColor: popular ? Colors.black : Colors.white,
                      elevation: popular ? 8 : 4,
                      shadowColor: (popular ? Colors.amberAccent : Colors.black).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Recharge Now",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (popular || badge.isNotEmpty)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

class RateCardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String rate;
  final MaterialColor color;

  const RateCardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.rate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark ? Colors.transparent : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color.shade700),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on_rounded, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Text(
                rate,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
