import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:provider/provider.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'campaign_step3_review_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CampaignStep2SetupScreen extends StatefulWidget {
  final CommunicationsViewModel viewModel;

  const CampaignStep2SetupScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<CampaignStep2SetupScreen> createState() => _CampaignStep2SetupScreenState();
}

class _CampaignStep2SetupScreenState extends State<CampaignStep2SetupScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _subjectController.text = widget.viewModel.newCampaignSubject ?? '';
    _messageController.text = widget.viewModel.newCampaignMessage ?? '';
    // Default schedule
    _updateViewModelSchedule();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _updateViewModelSchedule() {
    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    widget.viewModel.newCampaignScheduledAt = dt.toUtc().toIso8601String();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateViewModelSchedule();
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      _updateViewModelSchedule();
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}";
  }

  Future<void> _uploadAndReview() async {
    final viewModel = widget.viewModel;
    final isIvr = viewModel.newCampaignChannel == 'Voice IVR' || viewModel.newCampaignChannel == 'Interactive IVR';

    if (viewModel.selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a CSV file with contacts.')),
      );
      return;
    }

    if (isIvr && viewModel.selectedVoiceFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Voice (MP3) file.')),
      );
      return;
    }

    if (viewModel.campaignInputType == 'manual') {
      if (_messageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a campaign message.')),
        );
        return;
      }
      viewModel.newCampaignSubject = _subjectController.text.trim();
      viewModel.newCampaignMessage = _messageController.text.trim();
    }

    setState(() => _isUploading = true);
    
    final uploadSuccess = await viewModel.uploadSelectedFile();
    
    if (uploadSuccess) {
      if (mounted) {
        setState(() => _isUploading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampaignStep3ReviewScreen(viewModel: viewModel),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.uploadErrorMessage ?? 'Failed to upload file. Please try again.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channel = widget.viewModel.newCampaignChannel ?? "Campaign";
    final isIvr = channel.contains("IVR");

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
              "Configure $channel",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Step 2 of 3",
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
              onPressed: _isUploading ? null : _uploadAndReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200,
                disabledForegroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isUploading 
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(
                      "Upload & Review",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
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

                if (widget.viewModel.campaignInputType == 'manual') ...[
                  const Text(
                    "Compose Message",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      hintText: "Enter the subject line",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Message",
                      hintText: "Type your campaign message here...",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // File Upload Section
                Text(
                  "Upload Contacts Data",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
                      type: fp.FileType.custom,
                      allowedExtensions: ['csv'],
                    );

                    if (result != null) {
                      widget.viewModel.selectedFile = result.files.first;
                      setState(() {});
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: widget.viewModel.selectedFile != null ? (Theme.of(context).brightness == Brightness.dark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
                        width: widget.viewModel.selectedFile != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.viewModel.selectedFile != null ? Colors.teal.shade100 : Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.table_chart_rounded,
                            color: widget.viewModel.selectedFile != null ? Colors.teal.shade700 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.viewModel.selectedFile != null
                                    ? widget.viewModel.selectedFile!.name
                                    : "Select CSV File",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.viewModel.selectedFile != null
                                    ? "Tap to change file"
                                    : "Must include Mobile Number & Email ID",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (isIvr) ...[
                  const SizedBox(height: 32),
                  Text(
                    "Upload Voice Recording",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
                        type: fp.FileType.custom,
                        allowedExtensions: ['mp3'],
                      );

                      if (result != null) {
                        widget.viewModel.selectedVoiceFile = result.files.first;
                        setState(() {});
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.viewModel.selectedVoiceFile != null ? (Theme.of(context).brightness == Brightness.dark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
                          width: widget.viewModel.selectedVoiceFile != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: widget.viewModel.selectedVoiceFile != null ? Colors.teal.shade100 : Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.audiotrack_rounded,
                              color: widget.viewModel.selectedVoiceFile != null ? Colors.teal.shade700 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.viewModel.selectedVoiceFile != null
                                      ? widget.viewModel.selectedVoiceFile!.name
                                      : "Select MP3 File",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.viewModel.selectedVoiceFile != null
                                      ? "Tap to change file"
                                      : "Max size 10MB",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Schedule Section
                Text(
                  "Schedule Campaign",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 20, color: Colors.teal),
                              const SizedBox(width: 12),
                              Text(
                                _formatDate(_selectedDate),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 20, color: Colors.teal),
                              const SizedBox(width: 12),
                              Text(
                                _selectedTime.format(context),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Removed Template Section
              ],
            ),
          );
        },
      ),
    );
  }
}
