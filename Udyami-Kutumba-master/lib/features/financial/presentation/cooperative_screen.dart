import 'package:flutter/material.dart';

class CooperativeScreen extends StatelessWidget {
  const CooperativeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D20);
    final subTextColor = isDark
        ? Colors.grey.shade400
        : const Color(0xFF5F6368);
    final borderColor = isDark ? Colors.grey.shade800 : const Color(0xFFE0E0E0);
    final searchBgColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF1F3F4);

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // phead
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  children: [
                    // phead-top
                    Row(
                      children: [
                        _buildIconButton(
                          Icons.arrow_back_rounded,
                          context,
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Co-operative',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '26 permissible services · Schedule A–J',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildIconButton(
                          Icons.open_in_new_rounded,
                          context,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // searchbar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: searchBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: subTextColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Search savings, loan, chit...',
                            style: TextStyle(color: subTextColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // scroller
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.only(bottom: 40),
                  children: [
                    _buildGroupLabel('A · Deposits & savings', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'A.1',
                      'Savings account',
                      'Open with ₹500, withdraw anytime',
                      Icons.savings_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'A.2',
                      'Recurring deposit',
                      'Fixed amount every month',
                      Icons.sync_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'A.3',
                      'Fixed deposit',
                      '6 to 60 months, interest on maturity',
                      Icons.account_balance_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'A.4',
                      'Pigmy daily collection',
                      'Agent collects at your shop',
                      Icons.store_outlined,
                    ),

                    _buildGroupLabel('B · Loans & advances', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'B.1',
                      'Business loan',
                      'Working capital for member enterprises',
                      Icons.monetization_on_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'B.2',
                      'Gold loan',
                      'Against jewellery, released same day',
                      Icons.diamond_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'B.3',
                      'Property mortgage loan',
                      'Against land or building',
                      Icons.key_outlined,
                    ),

                    _buildGroupLabel('D · Goal-based savings', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'D.1',
                      'Education fund',
                      'Save towards a child\'s fees',
                      Icons.school_outlined,
                    ),

                    _buildGroupLabel('F · Member ventures', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'F.1',
                      'Udyami Queens',
                      'Home-enterprise marketplace & mobility',
                      Icons.storefront_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'F.2',
                      'Udyami Yuva E3',
                      'Youth skilling and start-up funding',
                      Icons.groups_outlined,
                    ),

                    _buildGroupLabel('H · Build My Home', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'H.1',
                      'Cloud Patra',
                      'Property papers stored online',
                      Icons.description_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'H.2',
                      'Bhoomi Vault',
                      'Land record verification',
                      Icons.landscape_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'H.5',
                      'Logistics services',
                      'Material delivery to site',
                      Icons.local_shipping_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon, BuildContext context, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F3F4),
        shape: BoxShape.circle,
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

  Widget _buildGroupLabel(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildListItem(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    String code,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // dmark
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: subTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // lrow-icon
              Icon(icon, color: subTextColor, size: 20),
              const SizedBox(width: 12),
              // lrow-main
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: subTextColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
