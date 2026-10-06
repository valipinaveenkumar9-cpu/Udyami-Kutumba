import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CoordinatorCommunicationsScreen extends StatefulWidget {
  const CoordinatorCommunicationsScreen({super.key});

  @override
  State<CoordinatorCommunicationsScreen> createState() => _CoordinatorCommunicationsScreenState();
}

class _CoordinatorCommunicationsScreenState extends State<CoordinatorCommunicationsScreen> {
  String _selectedChannel = 'App + WhatsApp';
  String _selectedAudience = 'All 44';

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
        title: Text(
          "Communications",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Channel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  _buildChannelButton("App + WhatsApp"),
                  _buildChannelButton("App"),
                  _buildChannelButton("WhatsApp"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text("Audience", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  _buildAudienceButton("All 44"),
                  _buildAudienceButton("By sector"),
                  _buildAudienceButton("By ward"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text("Message", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Announcement…",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Send announcement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),

            Text("Sent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildSentRow("Announcement", "Just now · 44 reached"),
            _buildSentRow("Bring a guest this Thursday", "Sent 2d ago · 44 reached"),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelButton(String title) {
    bool isSelected = _selectedChannel == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedChannel = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildAudienceButton(String title) {
    bool isSelected = _selectedAudience == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedAudience = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSentRow(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.cyan.shade50,
            child: Icon(Icons.chat_bubble_rounded, color: Colors.cyan.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
