import 'package:flutter/material.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'campaign_step2_setup_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CampaignStep1TypeScreen extends StatefulWidget {
  final CommunicationsViewModel viewModel;

  const CampaignStep1TypeScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<CampaignStep1TypeScreen> createState() => _CampaignStep1TypeScreenState();
}

class _CampaignStep1TypeScreenState extends State<CampaignStep1TypeScreen> {
  void _selectType(String type) {
    setState(() {
      widget.viewModel.campaignInputType = type;
    });
  }

  void _proceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignStep2SetupScreen(viewModel: widget.viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channel = widget.viewModel.newCampaignChannel ?? "Campaign";

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New $channel",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Step 1 of 3",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _proceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Continue to Setup",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Step Indicator
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              "Select Campaign Type",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "How would you like to set up the messages for this campaign?",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 32),

            // Option 1: Manual Message
            _buildTypeCard(
              theme,
              title: "Manual Message",
              subtitle: "Type your message once and we'll send it to all contacts in your CSV list.",
              icon: Icons.edit_note_rounded,
              typeValue: 'manual',
            ),

            const SizedBox(height: 16),

            // Option 2: Custom CSV Data
            _buildTypeCard(
              theme,
              title: "Custom CSV Data",
              subtitle: "Upload a CSV where each row contains personalized messages for every contact.",
              icon: Icons.table_chart_rounded,
              typeValue: 'csv',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(ThemeData theme, {required String title, required String subtitle, required IconData icon, required String typeValue}) {
    final isSelected = widget.viewModel.campaignInputType == typeValue;
    return GestureDetector(
      onTap: () => _selectType(typeValue),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? theme.colorScheme.onPrimary : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
