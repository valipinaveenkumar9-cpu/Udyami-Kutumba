import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class AppreciationScreen extends StatefulWidget {
  const AppreciationScreen({super.key});

  @override
  State<AppreciationScreen> createState() => _AppreciationScreenState();
}

class _AppreciationScreenState extends State<AppreciationScreen> {
  int selectedTab = 0;

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Appreciations",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
              const ThemeToggleButton(),
          IconButton(
            onPressed: () {
              // Navigate to Give Appreciation Screen
            },
            icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Tabs
            Row(
              children: [
                _tabButton("Wall", 0),
                const SizedBox(width: 10),
                _tabButton("Received 1", 1),
                const SizedBox(width: 10),
                _tabButton("Given 1", 2),
              ],
            ),

            const SizedBox(height: 20),

            /// Appreciation Cards
            _appreciationCard(
              initials: "AK",
              fromTo: "Anita Kumar → Priya Shetty",
              message:
                  "Priya delivered our office interiors ahead of schedule.",
            ),

            const SizedBox(height: 15),

            _appreciationCard(
              initials: "SR",
              fromTo: "Suresh Rao → Nikhil K",
              message:
                  "Great leads from Nikhil, closed two deals this quarter.",
            ),

            const SizedBox(height: 15),

            _appreciationCard(
              initials: "MG",
              fromTo: "Manoj Gowda → Anita Kumar",
              message:
                  "Sorted my GST mess in a week. Highly recommend.",
            ),

            const SizedBox(height: 25),

            /// Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Give Appreciation
                    },
                    icon: Icon(Icons.star),
                    label: Text("Give"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.teal,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Request Appreciation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Request Appreciation"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    bool selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: selected ? Colors.teal : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Theme.of(context).colorScheme.surface : Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appreciationCard({
    required String initials,
    required String fromTo,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.teal,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  fromTo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "\"$message\"",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}