import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/lead_model.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class FilteredLeadsScreen extends StatelessWidget {
  final String source;
  final List<LeadModel> leads;

  const FilteredLeadsScreen({
    super.key,
    required this.source,
    required this.leads,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FC),
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: Text('$source Data'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: leads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 42, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text(
                    'No leads found',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leads.length,
              itemBuilder: (context, index) {
                return _buildLeadCard(context, leads[index], isDark);
              },
            ),
    );
  }

  Widget _buildLeadCard(BuildContext context, LeadModel lead, bool isDark) {
    int score = int.tryParse(lead.heatLevel) ?? 0;
    String dateStr = lead.createdAt != null && lead.createdAt!.length > 10 
        ? lead.createdAt!.substring(0, 10) 
        : lead.createdAt ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 21,
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
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        final cleanPhone = lead.phone.replaceAll(RegExp(r'[^\d+]'), '');
                        final Uri url = Uri.parse('tel:$cleanPhone');
                        launchUrl(url);
                      },
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lead.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _infoChip(Icons.source_outlined, lead.leadType.isEmpty ? 'Unknown' : lead.leadType, Colors.purple),
              _infoChip(Icons.category_outlined, lead.category, Colors.grey.shade700),
              _infoChip(Icons.business_center_outlined, lead.business.isEmpty ? 'Unknown' : lead.business, Colors.grey.shade700),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 5),
                  Text(dateStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.speed, size: 13, color: score >= 60 ? Colors.green : Colors.grey.shade500),
                  const SizedBox(width: 5),
                  Text('Score $score', style: TextStyle(fontSize: 11, color: score >= 60 ? Colors.green : Colors.grey.shade600)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
