import 'package:flutter/material.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'campaign_step4_review_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CampaignStep3ScheduleScreen extends StatefulWidget {
  final String campaignType;
  final CommunicationsViewModel viewModel;

  const CampaignStep3ScheduleScreen({
    super.key,
    required this.campaignType,
    required this.viewModel,
  });

  @override
  State<CampaignStep3ScheduleScreen> createState() => _CampaignStep3ScheduleScreenState();
}

class _CampaignStep3ScheduleScreenState extends State<CampaignStep3ScheduleScreen> {
  bool _sendNow = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              "Schedule",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "${widget.campaignType} · Step 3 of 4",
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
              onPressed: () {
                if (_sendNow) {
                  widget.viewModel.newCampaignScheduledAt = DateTime.now().toUtc().toIso8601String();
                } else if (_selectedDate != null && _selectedTime != null) {
                  final dt = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );
                  widget.viewModel.newCampaignScheduledAt = dt.toUtc().toIso8601String();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select date and time.")),
                  );
                  return;
                }

                print('DEV DEBUG - CampaignStep3: Scheduled at ${widget.viewModel.newCampaignScheduledAt}');
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampaignStep4ReviewScreen(
                      campaignType: widget.campaignType,
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
                "Review Campaign",
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
                      color: index < 3
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
              "When to send?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Send Now Option
            GestureDetector(
              onTap: () => setState(() => _sendNow = true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _sendNow ? theme.colorScheme.primary.withOpacity(0.05) : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100,
                    width: _sendNow ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.send_rounded,
                      color: _sendNow ? theme.colorScheme.primary : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Send Now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _sendNow ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Campaign starts immediately.",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (_sendNow)
                      Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Schedule Later Option
            GestureDetector(
              onTap: () => setState(() => _sendNow = false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: !_sendNow ? theme.colorScheme.primary.withOpacity(0.05) : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100,
                    width: !_sendNow ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: !_sendNow ? theme.colorScheme.primary : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Schedule for later",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: !_sendNow ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Pick a specific date and time.",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (!_sendNow)
                          Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                      ],
                    ),
                    if (!_sendNow) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (d != null) setState(() => _selectedDate = d);
                              },
                              icon: const Icon(Icons.calendar_today_rounded, size: 18),
                              label: Text(_selectedDate == null ? "Date" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (t != null) setState(() => _selectedTime = t);
                              },
                              icon: const Icon(Icons.access_time_rounded, size: 18),
                              label: Text(_selectedTime == null ? "Time" : _selectedTime!.format(context)),
                            ),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
