import 'package:flutter/material.dart';

class CampaignStats {
  final String label;
  final String value;
  final String? percentage;

  const CampaignStats({
    required this.label,
    required this.value,
    this.percentage,
  });
}

class CampaignReport {
  final String name;
  final String size;

  const CampaignReport({
    required this.name,
    required this.size,
  });
}

class Campaign {
  final String id;
  final String title;
  final String channel;
  final IconData icon;
  final String subtitle;
  final String statusText;
  final MaterialColor statusColor;
  final String recipientsText;
  final int coinsSpent;
  final String submittedDate;
  final String verifiedText;
  final String sendingText;
  final String reportText;
  final String? errorText;
  final String? refundNote;
  final String? infoNote;
  final List<CampaignStats>? primaryStats;
  final List<CampaignStats>? secondaryStats;
  final List<CampaignReport>? reports;
  final List<String>? uploadIds;
  final List<dynamic>? recipients;

  const Campaign({
    required this.id,
    required this.title,
    required this.channel,
    required this.icon,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.recipientsText,
    required this.coinsSpent,
    required this.submittedDate,
    required this.verifiedText,
    required this.sendingText,
    required this.reportText,
    this.errorText,
    this.refundNote,
    this.infoNote,
    this.primaryStats,
    this.secondaryStats,
    this.reports,
    this.uploadIds,
    this.recipients,
  });
}
