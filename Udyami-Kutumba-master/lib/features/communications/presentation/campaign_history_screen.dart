import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/campaign.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'campaign_detail_screen.dart';
import 'communications_screen.dart'; import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
// for CampaignRow and FilterChipWidget

class CampaignHistoryScreen extends StatefulWidget {
  final CommunicationsViewModel viewModel;

  const CampaignHistoryScreen({super.key, required this.viewModel});

  @override
  State<CampaignHistoryScreen> createState() => _CampaignHistoryScreenState();
}

class _CampaignHistoryScreenState extends State<CampaignHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Refresh history when opening the screen
    widget.viewModel.fetchCampaignHistory();
  }

  List<Campaign> get _filteredCampaigns {
    final list = widget.viewModel.campaignHistory;
    if (_selectedFilter == 'All') return list;
    if (_selectedFilter == 'Sending') {
      return list.where((c) => c.statusText == 'Sending').toList();
    }
    if (_selectedFilter == 'Completed') {
      return list.where((c) => c.statusText == 'Completed').toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Campaign history",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoadingCampaigns) {
            return const Center(child: CircularProgressIndicator());
          }

          final campaigns = _filteredCampaigns;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        onTap: () => setState(() => _selectedFilter = 'Sending'),
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        title: "Completed",
                        selected: _selectedFilter == 'Completed',
                        onTap: () => setState(() => _selectedFilter = 'Completed'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: campaigns.isEmpty
                      ? const Center(child: Text("No campaigns found"))
                      : ListView.builder(
                          itemCount: campaigns.length,
                          itemBuilder: (context, index) {
                            final campaign = campaigns[index];
                            return CampaignRow(
                              icon: campaign.icon,
                              title: "${campaign.title} — ${campaign.channel}",
                              subtitle: campaign.subtitle,
                              badge: campaign.statusText,
                              badgeColor: campaign.statusColor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CampaignDetailScreen(campaign: campaign),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
