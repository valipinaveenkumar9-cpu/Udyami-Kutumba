import 'package:flutter/material.dart';

enum IncidentSeverity {
  low,
  medium,
  high,
  critical;

  static IncidentSeverity fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'LOW':
        return IncidentSeverity.low;
      case 'HIGH':
        return IncidentSeverity.high;
      case 'CRITICAL':
        return IncidentSeverity.critical;
      case 'MEDIUM':
      default:
        return IncidentSeverity.medium;
    }
  }

  String get label {
    switch (this) {
      case IncidentSeverity.low:
        return 'LOW';
      case IncidentSeverity.medium:
        return 'MEDIUM';
      case IncidentSeverity.high:
        return 'HIGH';
      case IncidentSeverity.critical:
        return 'CRITICAL';
    }
  }

  Color get color {
    switch (this) {
      case IncidentSeverity.low:
        return const Color(0xFF1F8F5F); // Green
      case IncidentSeverity.medium:
        return const Color(0xFFB87A1E); // Amber
      case IncidentSeverity.high:
      case IncidentSeverity.critical:
        return const Color(0xFFC23F2C); // Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case IncidentSeverity.low:
        return const Color(0x211F8F5F);
      case IncidentSeverity.medium:
        return const Color(0x24B87A1E);
      case IncidentSeverity.high:
      case IncidentSeverity.critical:
        return const Color(0x21C23F2C);
    }
  }
}

enum IncidentStatus {
  open,
  resolved;

  static IncidentStatus fromString(String? value) {
    if (value?.toUpperCase() == 'RESOLVED') {
      return IncidentStatus.resolved;
    }
    return IncidentStatus.open;
  }

  String get label => this == IncidentStatus.resolved ? 'RESOLVED' : 'OPEN';
}

class Incident {
  final String id;
  final String userId;
  final String? generatedContentId;
  final String? calendarId;
  final String? activityId;
  final String activityType;
  final String? provider;
  final String? model;
  final String incidentType;
  final IncidentSeverity severity;
  final String title;
  final String message;
  final String? errorMessage;
  final IncidentStatus status;
  final bool resolved;
  final String? resolvedAt;
  final String createdAt;
  final String? updatedAt;

  const Incident({
    required this.id,
    required this.userId,
    this.generatedContentId,
    this.calendarId,
    this.activityId,
    required this.activityType,
    this.provider,
    this.model,
    required this.incidentType,
    required this.severity,
    required this.title,
    required this.message,
    this.errorMessage,
    required this.status,
    this.resolved = false,
    this.resolvedAt,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isResolved => status == IncidentStatus.resolved || resolved;

  String get displayType => incidentType.replaceAll('_', ' ');

  String get displayActivity => activityType.replaceAll('_', ' ');

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      generatedContentId: json['generatedContentId']?.toString(),
      calendarId: json['calendarId']?.toString(),
      activityId: json['activityId']?.toString(),
      activityType: json['activityType']?.toString() ?? 'SOCIAL_POST',
      provider: json['provider']?.toString(),
      model: json['model']?.toString(),
      incidentType: json['incidentType']?.toString() ?? 'UNKNOWN',
      severity: IncidentSeverity.fromString(json['severity']?.toString()),
      title: json['title']?.toString() ?? 'Incident',
      message: json['message']?.toString() ?? '',
      errorMessage: json['errorMessage']?.toString(),
      status: IncidentStatus.fromString(json['status']?.toString()),
      resolved: json['resolved'] == true,
      resolvedAt: json['resolvedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'generatedContentId': generatedContentId,
      'calendarId': calendarId,
      'activityId': activityId,
      'activityType': activityType,
      'provider': provider,
      'model': model,
      'incidentType': incidentType,
      'severity': severity.label,
      'title': title,
      'message': message,
      'errorMessage': errorMessage,
      'status': status.label,
      'resolved': resolved,
      'resolvedAt': resolvedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CreateIncidentPayload {
  final String? userId;
  final String generatedContentId;
  final String calendarId;
  final String activityType;
  final String incidentType;
  final String severity;
  final String title;
  final String message;
  final String errorMessage;

  const CreateIncidentPayload({
    this.userId,
    required this.generatedContentId,
    required this.calendarId,
    required this.activityType,
    required this.incidentType,
    required this.severity,
    required this.title,
    required this.message,
    required this.errorMessage,
  });

  Map<String, dynamic> toJson([String? currentUserId]) {
    return {
      'userId': userId ?? currentUserId ?? '',
      'generatedContentId': generatedContentId,
      'calendarId': calendarId,
      'activityType': activityType,
      'incidentType': incidentType.trim().toUpperCase().replaceAll(' ', '_'),
      'severity': severity.toUpperCase(),
      'title': title.trim(),
      'message': message.trim(),
      'errorMessage': errorMessage.trim(),
    };
  }
}
