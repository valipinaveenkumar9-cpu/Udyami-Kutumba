class BulkCampaignModel {
  final String id;
  final String userId;
  final String channel;
  final String templateId;
  final List<String> memberIds;
  final List<String> uploadIds;
  final String scheduledAt;
  final String? voiceFileId;
  final String? status;
  final String? adminStatus;
  
  BulkCampaignModel({
    required this.id,
    required this.userId,
    required this.channel,
    required this.templateId,
    required this.memberIds,
    required this.uploadIds,
    required this.scheduledAt,
    this.voiceFileId,
    this.status,
    this.adminStatus,
  });

  factory BulkCampaignModel.fromJson(Map<String, dynamic> json) {
    return BulkCampaignModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      channel: json['channel'] ?? '',
      templateId: json['templateId'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      uploadIds: List<String>.from(json['uploadIds'] ?? []),
      scheduledAt: json['scheduledAt'] ?? '',
      voiceFileId: json['voiceFileId'],
      status: json['status'],
      adminStatus: json['adminStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'channel': channel,
      'templateId': templateId,
      'memberIds': memberIds,
      'uploadIds': uploadIds,
      'scheduledAt': scheduledAt,
      if (voiceFileId != null) 'voiceFileId': voiceFileId,
    };
  }
}
