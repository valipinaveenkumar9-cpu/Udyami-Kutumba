import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = "All";

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Explore",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.teal.shade800),
            ),
            Text(
              "Discover opportunities & connections",
              style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search businesses, jobs, members...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.teal.shade400),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ── Categories ──
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _CategoryChip(
                  title: "All",
                  isSelected: _selectedCategory == "All",
                  onTap: () => _onCategorySelected("All"),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  title: "Trending",
                  isSelected: _selectedCategory == "Trending",
                  onTap: () => _onCategorySelected("Trending"),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  title: "Jobs",
                  isSelected: _selectedCategory == "Jobs",
                  onTap: () => _onCategorySelected("Jobs"),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  title: "Business",
                  isSelected: _selectedCategory == "Business",
                  onTap: () => _onCategorySelected("Business"),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  title: "Events",
                  isSelected: _selectedCategory == "Events",
                  onTap: () => _onCategorySelected("Events"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Scrollable Content ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  if (_selectedCategory == "All" || _selectedCategory == "Trending") ...[
                    const _SectionTitle(title: "✨ Featured Opportunity"),
                    const SizedBox(height: 12),
                    const _FeaturedCard(),
                    const SizedBox(height: 24),
                  ],

                  if (_selectedCategory == "All" || _selectedCategory == "Trending" || _selectedCategory == "Business") ...[
                    const _SectionTitle(title: "🔥 Trending Businesses"),
                    const SizedBox(height: 12),
                    const _TrendingBusinessCard(),
                    const SizedBox(height: 24),
                  ],

                  if (_selectedCategory == "All" || _selectedCategory == "Jobs") ...[
                    const _SectionTitle(title: "📢 Latest Opportunities"),
                    const SizedBox(height: 12),
                    const _OpportunityCard(),
                    const SizedBox(height: 24),
                  ],

                  if (_selectedCategory == "All" || _selectedCategory == "Events") ...[
                    const _SectionTitle(title: "📅 Upcoming Events"),
                    const SizedBox(height: 12),
                    const _EventCard(),
                    const SizedBox(height: 24),
                  ],

                  if (_selectedCategory == "All" || _selectedCategory == "Business") ...[
                    const _SectionTitle(title: "💡 Business Tips"),
                    const SizedBox(height: 12),
                    const _TipCard(),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard();

  void _showFeaturedDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.rocket_launch, color: Colors.orange, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text("Tech Innovators Inc.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("About the Opportunity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(
              "We are an AI-driven logistics startup based in Bengaluru. We are raising ₹50L to scale our operations across South India. Offering 10% equity.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(context, Icons.monetization_on, "Funding Required", "₹50 Lakhs"),
            const SizedBox(height: 12),
            _buildDetailRow(context, Icons.pie_chart, "Equity Offered", "10%"),
            const SizedBox(height: 12),
            _buildDetailRow(context, Icons.timeline, "Current Stage", "Seed Round"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Contact Founder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                child: Icon(Icons.rocket_launch, color: Colors.orange, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Startup Looking for Investors",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text("Bengaluru", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(width: 12),
              Icon(Icons.monetization_on, color: Colors.green.shade600, size: 16),
              const SizedBox(width: 4),
              Text("₹50L Funding Required", style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () => _showFeaturedDetails(context),
              child: Text("Explore Now", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingBusinessCard extends StatelessWidget {
  const _TrendingBusinessCard();

  void _showBusinessDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.business, color: Colors.blue, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ABC Technologies", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      Text("Software Development", style: TextStyle(color: Colors.teal, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text("About the Business", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(
              "ABC Technologies specializes in building high-quality mobile and web applications for enterprises. We have over 10 years of experience delivering robust solutions.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text("4.8 Rating", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(width: 8),
                Text("(120 Reviews)", style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("View Full Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBusinessDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.business, color: Colors.blue, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ABC Technologies",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Software Development",
                    style: TextStyle(color: Colors.teal, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text("4.8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 4),
                      Text("(120 reviews)", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
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

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard();

  void _showJobDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.work, color: Colors.indigo, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Flutter Developer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      Text("ABC Technologies", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text("Bangalore (Hybrid)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text("₹6-8 LPA", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 20),
            Text("Job Requirements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(
              "• 2+ years of experience with Flutter & Dart.\n• Experience with REST APIs and state management (Provider/Riverpod).\n• Strong understanding of UI/UX principles.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.5),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Application submitted successfully!")),
                  );
                },
                child: Text("Apply Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.work, color: Colors.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Flutter Developer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    Text("ABC Technologies", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text("Bangalore", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(width: 16),
              Icon(Icons.account_balance_wallet, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text("₹6-8 LPA", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _showJobDetails(context),
              child: Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard();

  void _showEventDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Flutter Meetup 2026", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.teal, size: 20),
                const SizedBox(width: 8),
                Text("July 28, 2026 • 10:00 AM", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.teal, size: 20),
                const SizedBox(width: 8),
                Text("Tech Park Auditorium, Bengaluru", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 24),
            Text("About the Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(
              "Join us for the biggest Flutter developer meetup in Bengaluru! Learn about the latest updates, network with industry experts, and participate in hands-on workshops.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.5),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Successfully registered for the event!")),
                  );
                },
                child: Text("Confirm Registration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEventDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 8, offset: Offset(0, 4))],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              color: Colors.teal.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("JUL", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("28", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 24)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Flutter Meetup 2026", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text("Bengaluru", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Register →",
                      style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
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

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.teal.shade900.withValues(alpha: 0.2) : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
            child: Icon(Icons.lightbulb, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "5 Ways to Grow Your Business",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.teal.shade900),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text("Read More", style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.teal.shade300 : Colors.teal.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Theme.of(context).brightness == Brightness.dark ? Colors.teal.shade300 : Colors.teal.shade700, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
