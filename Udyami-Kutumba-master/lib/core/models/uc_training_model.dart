class UcTrainingModel {
  final String id;
  final String ytLink;
  final String createdAt;
  final UcTrainingUser createdUser;

  UcTrainingModel({
    required this.id,
    required this.ytLink,
    required this.createdAt,
    required this.createdUser,
  });

  factory UcTrainingModel.fromJson(Map<String, dynamic> json) {
    return UcTrainingModel(
      id: json['id'] ?? '',
      ytLink: json['ytLink'] ?? '',
      createdAt: json['createdAt'] ?? '',
      createdUser: UcTrainingUser.fromJson(json['createdUser'] ?? {}),
    );
  }
}

class UcTrainingUser {
  final String userId;
  final String name;
  final String email;

  UcTrainingUser({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory UcTrainingUser.fromJson(Map<String, dynamic> json) {
    return UcTrainingUser(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
    );
  }
}
