import 'user_model.dart';
import 'lead_model.dart';

class GratitudeModel {
  final String id;
  final UserModel? thankYouMember;
  final LeadModel? linkedLead;
  final double businessValue;
  final String type;
  final UserModel? createdUser;
  final String feedback;
  final String? utrNo;
  final List<String>? proofImages;
  final DateTime? createdAt;

  GratitudeModel({
    required this.id,
    this.thankYouMember,
    this.linkedLead,
    required this.businessValue,
    required this.type,
    this.createdUser,
    required this.feedback,
    this.utrNo,
    this.proofImages,
    this.createdAt,
  });

  factory GratitudeModel.fromJson(Map<String, dynamic> json) {
    return GratitudeModel(
      id: json['id']?.toString() ?? '',
      thankYouMember: json['thankYouMember'] != null ? UserModel.fromJson(json['thankYouMember']) : null,
      linkedLead: json['linkedLead'] != null ? LeadModel.fromJson(json['linkedLead']) : null,
      businessValue: double.tryParse(json['businessValue']?.toString() ?? '0') ?? 0.0,
      type: json['type']?.toString() ?? 'Inside',
      createdUser: json['createdUser'] != null ? UserModel.fromJson(json['createdUser']) : null,
      feedback: json['feedback']?.toString() ?? '',
      utrNo: json['utrNo']?.toString(),
      proofImages: json['proofImages'] != null ? List<String>.from(json['proofImages']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
