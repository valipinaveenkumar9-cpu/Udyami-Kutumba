import 'package:flutter/material.dart';

class OwnifyScreen extends StatelessWidget {
  const OwnifyScreen({super.key});

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
                                'Ownify',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Property co-ownership ecosystem',
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
                            'Search projects, exchanges...',
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
                    _buildGroupLabel('C.1 · Primary Assets', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'C.1.1',
                      'Residential',
                      'Flats & sites in upcoming areas',
                      Icons.home_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'C.1.2',
                      'Commercial',
                      'Shops & offices for rent yield',
                      Icons.business_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'C.1.3',
                      'Agri land',
                      'Managed farms and plantations',
                      Icons.landscape_outlined,
                    ),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'C.1.4',
                      'Industrial',
                      'Warehouses and manufacturing plots',
                      Icons.factory_outlined,
                    ),

                    _buildGroupLabel('C.2 · Ownership Proof', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'C.2',
                      'Certificate',
                      'Digital ID Certificate (DIC) for your share',
                      Icons.card_membership_outlined,
                    ),

                    _buildGroupLabel('C.3 · Trading', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'C.3',
                      'Exchange',
                      'Trade shares with other members',
                      Icons.swap_horiz_outlined,
                    ),

                    _buildGroupLabel('C.4 · Portfolio', textColor),
                    _buildListItem(
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                      'C.4',
                      'My holdings',
                      'View your 3 active assets',
                      Icons.pie_chart_outline,
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
