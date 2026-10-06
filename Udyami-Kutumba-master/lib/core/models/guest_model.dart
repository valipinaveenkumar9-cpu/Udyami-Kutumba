import 'user_model.dart';

class GuestModel {
  final String id;
  final String guestName;
  final UserModel? createdUser;
  final String status;
  final DateTime? createdAt;

  GuestModel({
    required this.id,
    required this.guestName,
    this.createdUser,
    required this.status,
    this.createdAt,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? 'Unknown Guest',
      createdUser: json['createdUser'] != null ? UserModel.fromJson(json['createdUser']) : null,
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guestName': guestName,
      // 'createdUser' serialization is omitted as it's not strictly needed for requests
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
