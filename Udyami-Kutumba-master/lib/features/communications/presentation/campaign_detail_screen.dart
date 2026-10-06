import 'package:flutter/material.dart';
import '../models/campaign.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CampaignDetailScreen extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    MaterialColor badgeColor = campaign.statusColor;
    String badgeText = campaign.statusText;
    final List<dynamic> _contacts = campaign.recipients ?? [];

    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
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
              campaign.title,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "${campaign.id} · ${campaign.channel}",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
              const ThemeToggleButton(),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildKvRow("Channel", campaign.channel, context),
                  _buildKvRow("Recipients", campaign.recipientsText, context),
                  _buildKvRow("Coins spent", "${campaign.coinsSpent}", context, isCoin: true),
                  _buildKvRow("Submitted", campaign.submittedDate, context, isLast: true),
                ],
              ),
            ),

            Text(
              "Status",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Timeline
            _buildTimelineStep(
              context: context,
              title: "Submitted",
              subtitle: campaign.submittedDate,
              isDone: true,
              isLast: false,
            ),
            _buildTimelineStep(
              context: context,
              title: campaign.statusText == "Failed" ? "Verification" : "Verified",
              subtitle: campaign.verifiedText,
              isDone: campaign.statusText != "Failed",
              isError: campaign.statusText == "Failed",
              isLast: campaign.statusText == "Failed",
            ),
            if (campaign.statusText != "Failed") ...[
              _buildTimelineStep(
                context: context,
                title: "Sending",
                subtitle: campaign.sendingText,
                isDone: campaign.statusText == "Completed",
                isActive: campaign.statusText == "Sending",
                isLast: false,
              ),
              _buildTimelineStep(
                context: context,
                title: "Report",
                subtitle: campaign.reportText,
                isDone: campaign.statusText == "Completed",
                isFuture: campaign.statusText == "Sending",
                isLast: true,
              ),
            ],

            const SizedBox(height: 24),

            if (campaign.statusText == "Completed" && campaign.primaryStats != null) ...[
              Text(
                "Results — ${campaign.channel}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: campaign.primaryStats!.map((s) => Expanded(child: _buildStatCard(s, context))).toList(),
              ),
              const SizedBox(height: 8),
              if (campaign.secondaryStats != null)
                Row(
                  children: campaign.secondaryStats!.map((s) => Expanded(child: _buildStatCard(s, context))).toList(),
                ),
              const SizedBox(height: 24),
            ],

            if (campaign.errorText != null) ...[
              _buildNoteBanner(campaign.errorText!, Colors.red, context),
            ],
            if (campaign.refundNote != null) ...[
              _buildNoteBanner(campaign.refundNote!, Colors.orange, context, icon: Icons.monetization_on_rounded),
            ],
            if (campaign.infoNote != null) ...[
              _buildNoteBanner(campaign.infoNote!, Colors.grey, context, icon: Icons.info_outline_rounded),
            ],

            if (campaign.reports != null && campaign.reports!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                "Delivery reports",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...campaign.reports!.map((r) => _buildReportTile(r, context)),
            ],

            if (campaign.statusText == "Failed") ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.upload_rounded),
                  label: Text(
                    "Re-upload file",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text(
              "Contacts / Leads",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _contacts.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No contacts uploaded for this campaign.", style: TextStyle(color: Colors.grey)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _contacts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                       final contact = _contacts[index];
                       return _buildContactTile(contact, context);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildKvRow(String key, String value, BuildContext context, {bool isLast = false, bool isCoin = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Row(
            children: [
              if (isCoin)
                Icon(Icons.monetization_on_rounded, size: 16, color: Colors.orange.shade700),
              if (isCoin) const SizedBox(width: 4),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required BuildContext context,
    required String title,
    required String subtitle,
    bool isDone = false,
    bool isError = false,
    bool isActive = false,
    bool isFuture = false,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.deepPurple
                      : isError
                          ? Colors.red
                          : isActive
                              ? Colors.blue
                              : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : isError
                        ? Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14)
                        : isActive
                            ? Padding(
                                padding: EdgeInsets.all(4),
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? Colors.deepPurple : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isFuture ? Colors.grey.shade400 : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(CampaignStats stat, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(stat.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
              if (stat.percentage != null) ...[
                const SizedBox(width: 6),
                Text(
                  stat.percentage!,
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBanner(String text, MaterialColor color, BuildContext context, {IconData icon = Icons.warning_amber_rounded}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.shade900.withOpacity(0.2) : color.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile(CampaignReport report, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            report.name.endsWith(".csv") ? Icons.table_chart_rounded : Icons.picture_as_pdf_rounded,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 2),
                Text(report.size, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.download_rounded, color: Colors.deepPurple.shade400),
        ],
      ),
    );
  }

  Widget _buildContactTile(dynamic contact, BuildContext context) {
    final theme = Theme.of(context);
    String name = 'Unknown';
    String mobile = '';
    
    // The recipient might have nested upload object or flat fields
    if (contact['upload'] != null) {
      name = contact['upload']['name'] ?? 'Unknown';
    } else {
      name = contact['name'] ?? 'Unknown';
    }
    
    mobile = contact['mobileNumber'] ?? contact['contactValue'] ?? '';
    
    final status = contact['upload']?['status'] ?? contact['status'] ?? 'PENDING';
    
    Color statusColor = Colors.orange;
    if (status == 'COMPLETED' || status == 'DELIVERED' || status == 'APPROVED') statusColor = Colors.green;
    if (status == 'FAILED' || status == 'REJECTED') statusColor = Colors.red;
    if (status == 'IN_PROGRESS') statusColor = Colors.blue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (mobile.isNotEmpty)
                   Text(mobile, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
