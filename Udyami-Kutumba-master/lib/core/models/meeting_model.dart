class MeetingModel {
  final String meetingId;
  final String date;
  final String venue;
  final String agenda;
  final String status;
  final String createdAt;
  final Map<String, dynamic>? createdUser;
  final double? latitude;
  final double? longitude;
  final String? talukaId;
  final String? wardId;
  
  final String? meetingType;
  final String? startedAt;
  final String? endedAt;
  final Map<String, dynamic>? summary;

  MeetingModel({
    required this.meetingId,
    required this.date,
    required this.venue,
    required this.agenda,
    required this.status,
    required this.createdAt,
    this.createdUser,
    this.latitude,
    this.longitude,
    this.talukaId,
    this.wardId,
    this.meetingType,
    this.startedAt,
    this.endedAt,
    this.summary,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      meetingId: json['meetingId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      agenda: json['agenda']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Scheduled',
      createdAt: json['createdAt']?.toString() ?? '',
      createdUser: (json['createdUser'] ?? json['createdBy']) is Map ? Map<String, dynamic>.from(json['createdUser'] ?? json['createdBy']) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      talukaId: json['talukaId']?.toString(),
      wardId: json['wardId']?.toString(),
      meetingType: json['meetingType']?.toString(),
      startedAt: json['startedAt']?.toString(),
      endedAt: json['endedAt']?.toString(),
      summary: json['summary'] is Map ? Map<String, dynamic>.from(json['summary']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingId': meetingId,
      'date': date,
      'venue': venue,
      'agenda': agenda,
      'status': status,
      'createdAt': createdAt,
      'createdUser': createdUser,
      'latitude': latitude,
      'longitude': longitude,
      'talukaId': talukaId,
      'wardId': wardId,
      'meetingType': meetingType,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'summary': summary,
    };
  }
}
