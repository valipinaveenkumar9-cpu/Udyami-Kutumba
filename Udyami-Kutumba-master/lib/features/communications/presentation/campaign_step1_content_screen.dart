import 'package:flutter/material.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'campaign_recipients_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CampaignStep1ContentScreen extends StatefulWidget {
  final CommunicationsViewModel viewModel;

  const CampaignStep1ContentScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<CampaignStep1ContentScreen> createState() => _CampaignStep1ContentScreenState();
}

class _CampaignStep1ContentScreenState extends State<CampaignStep1ContentScreen> {
  String? _selectedTemplateId;
  
  // Dummy templates
  final List<Map<String, String>> _templates = [
    {"id": "tpl_001", "name": "Welcome Greeting", "content": "Welcome to our platform!"},
    {"id": "tpl_002", "name": "Meeting Reminder", "content": "Just a reminder about our upcoming meeting."},
    {"id": "tpl_003", "name": "Event Invitation", "content": "You are invited to our special event this Friday."},
  ];

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New Campaign",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "$channel · Step 1 of 4",
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
              onPressed: _selectedTemplateId == null
                  ? null
                  : () {
                      print('DEV DEBUG - CampaignStep1: Selected template $_selectedTemplateId');
                      widget.viewModel.newCampaignTemplateId = _selectedTemplateId;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CampaignRecipientsScreen(
                            campaignType: channel,
                            viewModel: widget.viewModel,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Step Indicator
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index < 1
                          ? theme.colorScheme.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Select Template",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  final isSelected = _selectedTemplateId == template["id"];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTemplateId = template["id"];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary.withOpacity(0.05) : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  template["name"]!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            template["content"]!,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
