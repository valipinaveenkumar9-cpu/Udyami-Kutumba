class WardMemberModel {
  final String memberId;
  final String? memberNumber;
  final String name;
  final String? mobileNumber;
  final String? email;
  final String? companyName;
  final String? profileImage;
  final String role;
  final String? wardName;
  final String? wardNumber;
  final bool isBasic;
  final bool isPrime;
  final bool isPatron;

  WardMemberModel({
    required this.memberId,
    this.memberNumber,
    required this.name,
    this.mobileNumber,
    this.email,
    this.companyName,
    this.profileImage,
    required this.role,
    this.wardName,
    this.wardNumber,
    this.isBasic = false,
    this.isPrime = false,
    this.isPatron = false,
  });

  factory WardMemberModel.fromJson(Map<String, dynamic> json, String roleKey, {String? wardName, String? wardNumber}) {
    return WardMemberModel(
      memberId: json['memberId'] ?? json['userId'] ?? '',
      memberNumber: json['memberNumber'],
      name: json['name'] ?? 'Unknown',
      mobileNumber: json['mobileNumber'],
      email: json['email'],
      companyName: json['companyName'],
      profileImage: json['profileImage'],
      role: roleKey,
      wardName: wardName,
      wardNumber: wardNumber,
      isBasic: json['isBasic'] ?? false,
      isPrime: json['isPrime'] ?? false,
      isPatron: json['isPatron'] ?? false,
    );
  }
}
