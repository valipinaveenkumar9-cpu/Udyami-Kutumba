import 'package:flutter/material.dart';
import '../viewmodels/communications_viewmodel.dart';
import '../models/bulk_campaign_model.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CampaignStep3ReviewScreen extends StatefulWidget {
  final CommunicationsViewModel viewModel;

  const CampaignStep3ReviewScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<CampaignStep3ReviewScreen> createState() => _CampaignStep3ReviewScreenState();
}

class _CampaignStep3ReviewScreenState extends State<CampaignStep3ReviewScreen> {
  bool _isSubmitting = false;

  Future<void> _submitCampaign() async {
    final viewModel = widget.viewModel;
    
    // Calculate cost based on type (just an estimation for UI purposes)
    int _getCostPerRecipient(String channel) {
      // The backend is currently configured to charge a flat 2 coins per message
      // across all channels (Email, SMS, WhatsApp, IVR).
      return 2;
    }

    final channel = viewModel.newCampaignChannel ?? "";
    final int costPerRecipient = _getCostPerRecipient(channel);
    
    final int recipientsCount = viewModel.uploadedCsvData.length;
    final int totalCost = recipientsCount * costPerRecipient;
    final int currentBalance = viewModel.wallet?.coins ?? 0;
    
    print('DEV DEBUG - CampaignStep3Review: --- CAMPAIGN COST ESTIMATION ---');
    print('DEV DEBUG - CampaignStep3Review: Channel: $channel');
    print('DEV DEBUG - CampaignStep3Review: Recipients (Messages to send): $recipientsCount');
    print('DEV DEBUG - CampaignStep3Review: Cost per Message: $costPerRecipient');
    print('DEV DEBUG - CampaignStep3Review: Total Estimated Cost (Coins): $totalCost');
    print('DEV DEBUG - CampaignStep3Review: Current Wallet Balance: $currentBalance');

    if (currentBalance < totalCost) {
      print('DEV DEBUG - CampaignStep3Review: INSUFFICIENT BALANCE. Required: $totalCost, Available: $currentBalance');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient coin balance! Please recharge.')),
      );
      return;
    }
    
    print('DEV DEBUG - CampaignStep3Review: Balance is sufficient. Proceeding to submit...');

    setState(() => _isSubmitting = true);

    print('DEV DEBUG - CampaignStep3Review: Finalizing campaign...');

    final response = await viewModel.finalizeCampaignUpload();

    if (mounted) {
      if (response != null) {
        // Success
        _showSuccessDialog(response);
      } else {
        final errorMsg = viewModel.uploadErrorMessage ?? 'Failed to create campaign.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> response) {
    int totalRecipients = 0;
    int coinsDeducted = 0;
    int newWalletBalance = 0;

    try {
      if (response['campaign'] != null && response['campaign']['data'] != null) {
        final data = response['campaign']['data'];
        totalRecipients = data['totalRecipients'] ?? 0;
        coinsDeducted = data['totalCoins'] ?? 0;
        newWalletBalance = data['walletBalance'] ?? 0;
      }
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                "Campaign Created!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                response['message'] ?? "Your campaign has been successfully scheduled.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildStatRow("Messages Queued", "$totalRecipients", Icons.people_alt_rounded),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                    _buildStatRow("Coins Deducted", "-$coinsDeducted", Icons.monetization_on_rounded, color: Colors.red.shade700),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                    _buildStatRow("Remaining Balance", "$newWalletBalance", Icons.account_balance_wallet_rounded, color: Colors.green.shade700),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).popUntil((route) => route.isFirst); // Go back to start
                  },
                  child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black87, fontSize: 15)),
      ],
    );
  }

  String _getStringValue(dynamic record, List<String> possibleKeys) {
    if (record is! Map) return "";
    for (var key in possibleKeys) {
      if (record.containsKey(key) && record[key] != null) {
        return record[key].toString();
      }
      // Also try case-insensitive match
      for (var k in record.keys) {
        if (k.toString().toLowerCase() == key.toLowerCase() && record[k] != null) {
          return record[k].toString();
        }
      }
    }
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channel = widget.viewModel.newCampaignChannel ?? "Campaign";
    final dataList = widget.viewModel.uploadedCsvData;

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
              "Review Data",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Step 3 of 3",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCampaign,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting 
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2.5),
                    )
                  : Text(
                      "Submit Campaign",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface),
                    ),
            ),
          ),
        ),
      ),
      body: dataList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("No data found in the uploaded file.", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
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
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (widget.viewModel.campaignInputType == 'manual') ...[
                    const Text(
                      "Campaign Content",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.viewModel.newCampaignSubject != null && widget.viewModel.newCampaignSubject!.isNotEmpty) ...[
                            Text("Subject", style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              widget.viewModel.newCampaignSubject!,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text("Message", style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            widget.viewModel.newCampaignMessage ?? '',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Text(
                    "Data Preview (${dataList.length} records)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                        columns: const [
                          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Email ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('WhatsApp Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Message', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: dataList.take(20).map((record) {
                          return DataRow(
                            cells: [
                              DataCell(Text(_getStringValue(record, ['name', 'Name', 'first_name']))),
                              DataCell(Text(_getStringValue(record, ['mobile', 'mobile_number', 'Mobile Number', 'phone']))),
                              DataCell(Text(_getStringValue(record, ['email', 'Email ID', 'email_id']))),
                              DataCell(Text(_getStringValue(record, ['whatsapp', 'WhatsApp Number', 'whatsapp_number']))),
                              DataCell(Text(_getStringValue(record, ['subject', 'Subject']))),
                              DataCell(SizedBox(
                                width: 200,
                                child: Text(
                                  _getStringValue(record, ['message', 'Message', 'content']),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (dataList.length > 20)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "* Showing first 20 records",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
