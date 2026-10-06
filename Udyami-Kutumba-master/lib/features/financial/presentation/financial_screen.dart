import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cooperative_screen.dart';
import 'ownify_screen.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define colors closer to HTML
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D20);
    final subTextColor = isDark
        ? Colors.grey.shade400
        : const Color(0xFF5F6368);
    final brassColor = const Color(0xFFC49A45); // var(--brass)
    final blueIconColor = const Color(0xFF1A73E8);
    final borderColor = isDark ? Colors.grey.shade800 : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Board
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TOP CARD
                    _buildColumnLeaf(
                      context: context,
                      isDark: isDark,
                      bgColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      markIcon: Icons.groups_rounded,
                      title: 'First Choice Co-operative',
                      tag: 'Deposits, loans, chits and member ventures',
                      onTapApp: () => _showCooperativePopup(context),
                      tiles: [
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'A.1', 'Savings', 'Open with ₹500', Icons.savings_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'A.3', 'Fixed deposit', '6 – 60 months', Icons.account_balance_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'B.1', 'Business loan', 'For members', Icons.monetization_on_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'B.2', 'Gold loan', 'Same-day release', Icons.diamond_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'J.1', 'Bharat Chits', 'Monthly group', Icons.receipt_long_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'E.2', 'Insurance', 'Life & crop', Icons.security_outlined),
                      ],
                      moreText: 'All 26 services',
                    ),
                    const SizedBox(height: 24),
                    // BOTTOM CARD
                    _buildColumnLeaf(
                      context: context,
                      isDark: isDark,
                      bgColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      markIcon: Icons.landscape_rounded,
                      title: 'Ownify',
                      tag: 'Own a share of property, held in your name',
                      onTapApp: () => _showOwnifyPopup(context),
                      tiles: [
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'C.1.1', 'Residential', 'Flats & sites', Icons.home_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'C.1.2', 'Commercial', 'Shops & offices', Icons.business_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'C.1.3', 'Agri land', 'Managed farms', Icons.landscape_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'C.2', 'Certificate', 'Your DIC', Icons.card_membership_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'C.3', 'Exchange', 'Society-run only', Icons.swap_horiz_outlined),
                        _buildTile(isDark, cardColor, borderColor, textColor, subTextColor, 'C.4', 'My holdings', '3 assets', Icons.pie_chart_outline),
                      ],
                      moreText: 'All 9 products',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Notecard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A233A)
                        : const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline, color: blueIconColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'These open in their own apps',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Kutumba member ID travels with you, so you won\'t sign in again. Nothing is transacted inside Kutumba.',
                              style: TextStyle(
                                fontSize: 13,
                                color: subTextColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Register Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(
                        'https://fcbizz.com/short-form',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, BuildContext context, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : const Color(0xFFE0E0E0),
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () {
          if (icon == Icons.arrow_back_rounded && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildColumnLeaf({
    required BuildContext context,
    required bool isDark,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
    required IconData markIcon,
    required String title,
    required String tag,
    required VoidCallback onTapApp,
    required List<Widget> tiles,
    required String moreText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // colhead
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(markIcon, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: onTapApp,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      foregroundColor: textColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Open app',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.open_in_new, size: 14, color: subTextColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // tiles
          for (int i = 0; i < tiles.length; i += 2)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  Container(width: 1, color: borderColor),
                  if (i + 1 < tiles.length)
                    Expanded(child: tiles[i + 1])
                  else
                    Expanded(child: const SizedBox()),
                ],
              ),
            ),

          // morebtn
          InkWell(
            onTap: onTapApp,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    moreText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    bool isDark,
    Color bgColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    String code,
    String name,
    String sub,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // tile-top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: subTextColor),
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 11,
                    color: subTextColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 11, color: subTextColor)),
          ],
        ),
      ),
    );
  }

  void _showCooperativePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CooperativeScreen(),
    );
  }

  void _showOwnifyPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OwnifyScreen(),
    );
  }
}
