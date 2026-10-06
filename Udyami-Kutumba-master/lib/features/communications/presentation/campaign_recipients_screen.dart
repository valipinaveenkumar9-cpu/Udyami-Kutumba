import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'contact_picker_screen.dart';
import 'campaign_step3_schedule_screen.dart';
import '../models/contact.dart';
import '../data/my_leads.dart';
import '../data/ward_members.dart';
import '../data/taluk_members.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CampaignRecipientsScreen extends StatelessWidget {
  final String campaignType;
  final CommunicationsViewModel viewModel;

  const CampaignRecipientsScreen({
    super.key,
    required this.campaignType,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
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
              "New Campaign",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "$campaignType · Step 2 of 4",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
              const ThemeToggleButton(),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                final balance = viewModel.wallet?.coins ?? 0;
                return Row(
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.orange.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$balance",
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
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
                      color: index < 2
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
              "Select Recipients",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 16),

            RecipientTile(
              icon: Icons.my_location_rounded,
              title: "My Leads",
              subtitle: "${myLeads.length} contacts · Tap to choose",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactPickerScreen(
                      title: "My Leads",
                      contacts: myLeads,
                      campaignType: campaignType,
                      viewModel: viewModel,
                    ),
                  ),
                );
              },
            ),

            RecipientTile(
              icon: Icons.location_on_rounded,
              title: "Ward Members",
              subtitle: "${wardMembers.length} contacts · Tap to choose",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactPickerScreen(
                      title: "Ward Members",
                      contacts: wardMembers,
                      campaignType: campaignType,
                      viewModel: viewModel,
                    ),
                  ),
                );
              },
            ),

            RecipientTile(
              icon: Icons.map_rounded,
              title: "Taluk Members",
              subtitle: "${talukMembers.length} contacts · Tap to choose",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactPickerScreen(
                      title: "Taluk Members",
                      contacts: talukMembers,
                      campaignType: campaignType,
                      viewModel: viewModel,
                    ),
                  ),
                );
              },
            ),

            ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                final isIvr = viewModel.newCampaignChannel == 'IVR';
                final hasFile = viewModel.selectedFile != null;
                
                return RecipientTile(
                  icon: isIvr ? Icons.audiotrack_rounded : Icons.table_chart_rounded,
                  title: isIvr ? "Import Audio (.mp3)" : "Import CSV",
                  subtitle: hasFile ? "Selected: ${viewModel.selectedFile!.name}" : "Upload your own list",
                  trailingIcon: Icons.upload_file_rounded,
                  onTap: () async {
                    fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
                      type: fp.FileType.custom,
                      allowedExtensions: isIvr ? ['mp3'] : ['csv'],
                    );

                    if (result != null && result.files.isNotEmpty) {
                      viewModel.selectedFile = result.files.first;
                      viewModel.notifyListeners();
                      print("DEV DEBUG - CampaignRecipients: Selected file ${viewModel.selectedFile!.name}");
                    }
                  },
                );
              }
            ),

            const Spacer(),

            ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                final hasMembers = viewModel.newCampaignMemberIds.isNotEmpty;
                final hasFile = viewModel.selectedFile != null;
                final canContinue = hasMembers || hasFile;
                
                String buttonText = "Continue · 0 Recipients";
                if (hasMembers) {
                  buttonText = "Continue · ${viewModel.newCampaignMemberIds.length} Recipients";
                } else if (hasFile) {
                  buttonText = "Continue · 1 File Attached";
                }

                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: canContinue ? () {
                      print("DEV DEBUG - CampaignRecipients: Proceeding to Step 3. Channel: ${viewModel.newCampaignChannel}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CampaignStep3ScheduleScreen(
                            campaignType: campaignType,
                            viewModel: viewModel,
                          ),
                        ),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      disabledBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200,
                      disabledForegroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class RecipientTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  const RecipientTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingIcon = Icons.chevron_right_rounded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Icon(
          trailingIcon,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }
}
