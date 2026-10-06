import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class LeadAppealsScreen extends StatefulWidget {
  const LeadAppealsScreen({super.key});

  @override
  State<LeadAppealsScreen> createState() => _LeadAppealsScreenState();
}

class _LeadAppealsScreenState extends State<LeadAppealsScreen> {
  String _selectedRuling = 'Uphold decline';

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
          "Lead appeals",
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
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vani Silks lead",
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Nikhil (giver) vs Priya (declined)",
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Members Dispute Rows
            _buildMemberRow(
              "NK",
              "Nikhil",
              "“Lead was in her ward, valid.”",
              Colors.blue.shade100,
              Colors.blue.shade900,
            ),
            const SizedBox(height: 12),
            _buildMemberRow(
              "PS",
              "Priya",
              "“Out of my service area.”",
              Colors.purple.shade100,
              Colors.purple.shade900,
            ),

            const SizedBox(height: 24),

            // Ruling segmented control
            Text(
              "Ruling",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _buildSegmentedButton("Uphold decline"),
                  _buildSegmentedButton("Reinstate"),
                  _buildSegmentedButton("Reassign"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Apply Button
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
                child: Text(
                  "Record ruling",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Footer
            Center(
              child: Text(
                "Unresolved 7+ days → auto-escalates to you",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedButton(String title) {
    bool isSelected = _selectedRuling == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRuling = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberRow(String initials, String name, String quote, Color avatarBg, Color avatarText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarBg,
            child: Text(
              initials,
              style: TextStyle(
                color: avatarText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  quote,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
