import 'package:flutter/material.dart';
import '../viewmodels/communications_viewmodel.dart';
import '../models/bulk_campaign_model.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CampaignStep4ReviewScreen extends StatefulWidget {
  final String campaignType;
  final CommunicationsViewModel viewModel;

  const CampaignStep4ReviewScreen({
    super.key,
    required this.campaignType,
    required this.viewModel,
  });

  @override
  State<CampaignStep4ReviewScreen> createState() => _CampaignStep4ReviewScreenState();
}

class _CampaignStep4ReviewScreenState extends State<CampaignStep4ReviewScreen> {
  bool _isSubmitting = false;

  void _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    String channel = "SMS";
    if (widget.campaignType.contains("Email")) channel = "EMAIL";
    if (widget.campaignType.contains("WhatsApp")) channel = "WHATSAPP";
    if (widget.campaignType.contains("IVR")) channel = "IVR";

    final userId = SessionManager.user?['userId']?.toString() ?? "user-id-placeholder";

    final newCampaign = BulkCampaignModel(
      id: '',
      userId: userId,
      channel: channel,
      templateId: widget.viewModel.newCampaignTemplateId ?? "template-placeholder",
      memberIds: widget.viewModel.newCampaignMemberIds,
      uploadIds: widget.viewModel.newCampaignUploadIds,
      scheduledAt: widget.viewModel.newCampaignScheduledAt ?? DateTime.now().toUtc().toIso8601String(),
      voiceFileId: widget.viewModel.newCampaignVoiceFileId,
    );

    print('DEV DEBUG - CampaignStep4: Submitting campaign...');

    bool isSuccess = true;
    if (widget.viewModel.selectedFile != null) {
      print('DEV DEBUG - CampaignStep4: Found selected file, attempting to upload...');
      final uploadSuccess = await widget.viewModel.uploadSelectedFile();
      if (!uploadSuccess) {
        isSuccess = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload file.')));
        }
      }
    }

    if (isSuccess) {
      print('DEV DEBUG - Payload: ${newCampaign.toJson()}');
      final createSuccess = await widget.viewModel.createCampaign(newCampaign);
      isSuccess = createSuccess;
    }

    if (mounted) {
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign created successfully!')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (widget.viewModel.selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create campaign.')));
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int recipientsCount = widget.viewModel.newCampaignMemberIds.length;
    
    // Calculate cost based on type
    int costPerRecipient = 1;
    if (widget.campaignType.contains("WhatsApp")) costPerRecipient = 2;
    if (widget.campaignType.contains("Voice IVR")) costPerRecipient = 3;
    if (widget.campaignType.contains("Interactive IVR")) costPerRecipient = 4;
    
    final int totalCost = recipientsCount * costPerRecipient;
    final int currentBalance = widget.viewModel.wallet?.coins ?? 0;
    
    // If they have a file attached, we don't know the exact cost yet, so we allow them to proceed
    final bool hasFile = widget.viewModel.selectedFile != null;
    final bool hasEnoughCoins = hasFile || (currentBalance >= totalCost);

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
              "Review",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "${widget.campaignType} · Step 4 of 4",
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
              onPressed: (_isSubmitting || !hasEnoughCoins) ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.surface),
                    )
                  : Text(
                      "Submit Campaign",
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
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Review Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(context, Icons.campaign_rounded, "Channel", widget.campaignType),
                  const Divider(height: 32),
                  _buildSummaryRow(context, Icons.people_rounded, "Recipients", widget.viewModel.selectedFile != null ? "1 Attached File (${widget.viewModel.selectedFile!.name})" : "$recipientsCount members"),
                  const Divider(height: 32),
                  _buildSummaryRow(
                    context, 
                    Icons.schedule_rounded, 
                    "Scheduled", 
                    (widget.viewModel.newCampaignScheduledAt != null && widget.viewModel.newCampaignScheduledAt!.contains("Z"))
                        ? "Specific Date/Time" // Ideally format this date properly
                        : "Send Now",
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Icon(Icons.monetization_on_rounded, color: Colors.orange.shade700, size: 24),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Total Cost",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Text(
                        hasFile ? "Pending Calculation" : "$totalCost coins",
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: hasFile ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (!hasEnoughCoins) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You don't have enough coins. You need $totalCost coins but only have $currentBalance.",
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
