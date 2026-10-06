class LeadModel {
  final String leadId;
  final String memberName;
  final String category;
  final String leadType;
  final String business;
  final String phone;
  final String heatLevel;
  final String status;
  final String? feedback;
  final String? message;
  final String? createdAt;
  final Map<String, dynamic>? createdUser;

  LeadModel({
    required this.leadId,
    required this.memberName,
    required this.category,
    required this.leadType,
    required this.business,
    required this.phone,
    required this.heatLevel,
    required this.status,
    this.feedback,
    this.message,
    this.createdAt,
    this.createdUser,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      leadId: json['leadId'] ?? '',
      memberName: json['memberName'] ?? '',
      category: json['category'] ?? '',
      leadType: json['leadType'] ?? '',
      business: json['business'] ?? '',
      phone: json['phone'] ?? '',
      heatLevel: json['heatLevel'] ?? '',
      status: json['status'] ?? 'Pending',
      feedback: json['feedback'],
      message: json['message'],
      createdAt: json['createdAt'],
      createdUser: json['createdUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leadId': leadId,
      'memberName': memberName,
      'category': category,
      'leadType': leadType,
      'business': business,
      'phone': phone,
      'heatLevel': heatLevel,
      'status': status,
      'feedback': feedback,
      'message': message,
      'createdAt': createdAt,
      'createdUser': createdUser,
    };
  }
}
