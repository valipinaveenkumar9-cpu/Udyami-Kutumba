import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class ThankSlipScreen extends StatefulWidget {
  const ThankSlipScreen({super.key});

  @override
  State<ThankSlipScreen> createState() => _ThankSlipScreenState();
}

class _ThankSlipScreenState extends State<ThankSlipScreen> {
  final List<Map<String, dynamic>> thankSlips = [
    {
      "name": "Rahul Sharma",
      "company": "Tech Solutions Pvt Ltd",
      "chapter": "BNI Bangalore North",
      "reason": "Business Referral",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Priya Reddy",
      "company": "Creative Designs",
      "chapter": "BNI Bangalore Central",
      "reason": "Quality Presentation",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Arjun Kumar",
      "company": "AK Developers",
      "chapter": "BNI Whitefield",
      "reason": "Visitor Invitation",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Sneha Patel",
      "company": "Digital Marketing Hub",
      "chapter": "BNI Indiranagar",
      "reason": "Business Connection",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Rakesh Verma",
      "company": "VR Finance",
      "chapter": "BNI Electronic City",
      "reason": "Referral Passed",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Anjali Gupta",
      "company": "AG Interiors",
      "chapter": "BNI Koramangala",
      "reason": "One-to-One Meeting",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Suresh Naidu",
      "company": "SN Builders",
      "chapter": "BNI Marathahalli",
      "reason": "Business Support",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Deepika Rao",
      "company": "DR Events",
      "chapter": "BNI South Bangalore",
      "reason": "Reference Given",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Kiran Reddy",
      "company": "KR Travels",
      "chapter": "BNI Whitefield",
      "reason": "Client Introduction",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
    {
      "name": "Meghana Singh",
      "company": "MS Consultants",
      "chapter": "BNI Bangalore East",
      "reason": "Business Opportunity",
      "date": "22 Jul 2026",
      "status": "Sent",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: Text("Thank You Slips"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: thankSlips.length,
        itemBuilder: (context, index) {
          final member = thankSlips[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
              boxShadow: [
                BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    member["name"][0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              member["name"],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              member["status"],
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        member["company"],
                        style: TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 5),
                          Expanded(child: Text(member["chapter"])),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Expanded(child: Text(member["reason"])),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 5),
                          Text(member["date"]),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}