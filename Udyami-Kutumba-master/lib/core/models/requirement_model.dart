class RequirementUserModel {
  final String userId;
  final String name;
  final String mobileNumber;
  final String? email;
  final String? profileImage; // Assuming this might be available

  RequirementUserModel({
    required this.userId,
    required this.name,
    required this.mobileNumber,
    this.email,
    this.profileImage,
  });

  factory RequirementUserModel.fromJson(Map<String, dynamic> json) {
    return RequirementUserModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Unknown User',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'],
      profileImage: json['profileImage'],
    );
  }
}

class RequirementModel {
  final String requirementId;
  final String requirement;
  final String category;
  final String source;
  final String status;
  final String createdAt;
  final String updatedAt;
  final RequirementUserModel? user;
  final int interestedCount;

  RequirementModel({
    required this.requirementId,
    required this.requirement,
    required this.category,
    required this.source,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.interestedCount = 0,
  });

  factory RequirementModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'user' (from getB2C/B2B) and 'createdBy' (from getMyRequirements)
    Map<String, dynamic>? userJson = json['user'] ?? json['createdBy'];

    return RequirementModel(
      requirementId: json['requirementId'] ?? '',
      requirement: json['requirement'] ?? '',
      category: json['category'] ?? '',
      source: json['source'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      user: userJson != null ? RequirementUserModel.fromJson(userJson) : null,
      interestedCount: json['interestedCount'] ?? 0,
    );
  }
}
