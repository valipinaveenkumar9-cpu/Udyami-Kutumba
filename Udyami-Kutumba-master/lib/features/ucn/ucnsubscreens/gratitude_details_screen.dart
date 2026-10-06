import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/gratitude_model.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class GratitudeDetailsScreen extends StatelessWidget {
  final GratitudeModel slip;
  final bool isGiven;

  const GratitudeDetailsScreen({
    super.key,
    required this.slip,
    required this.isGiven,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = slip.createdAt != null
        ? DateFormat('MMM dd, yyyy').format(slip.createdAt!)
        : 'Unknown Date';

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Gratitude Details",
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
            // Amount and Type Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "₹${slip.businessValue.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      slip.type.toUpperCase(),
                      style: TextStyle(
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.teal.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Members Details
            Text(
              "Members Involved",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              "Given By",
              slip.createdUser?.name ?? "Unknown",
              Icons.arrow_upward,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              "Received By",
              slip.thankYouMember?.name ?? "Unknown",
              Icons.arrow_downward,
              Colors.green,
            ),
            const SizedBox(height: 24),

            // Linked Lead
            Text(
              "Linked Lead",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slip.linkedLead?.business ?? 'Unknown Lead',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (slip.linkedLead?.memberName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Member: ${slip.linkedLead?.memberName}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                  if (slip.linkedLead?.status != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slip.linkedLead!.status!,
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // UTR Number
            if (slip.utrNo != null && slip.utrNo!.isNotEmpty) ...[
              Text(
                "UTR Number",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                slip.utrNo!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],

            // Feedback/Notes
            if (slip.feedback.isNotEmpty) ...[
              Text(
                "Notes / Feedback",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  slip.feedback,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Proof Images
            if (slip.proofImages != null && slip.proofImages!.isNotEmpty) ...[
              Text(
                "Proof Images",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: slip.proofImages!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imageUrl = slip.proofImages![index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
