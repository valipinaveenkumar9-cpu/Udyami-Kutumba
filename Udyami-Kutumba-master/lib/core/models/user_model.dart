class RoleModel {
  final int roleId;
  final String roleName;
  final String? role;
  final String? description;
  final String? wardId;
  final String? talukaId;
  final String? districtId;
  final String? districtName;
  final String? talukaName;
  final String? wardName;

  RoleModel({
    required this.roleId,
    required this.roleName,
    this.role,
    this.description,
    this.wardId,
    this.talukaId,
    this.districtId,
    this.districtName,
    this.talukaName,
    this.wardName,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    final assignment = json['assignment'] is Map ? json['assignment'] : json;
    return RoleModel(
      roleId: json['roleId'] is int
          ? json['roleId']
          : int.tryParse(json['roleId']?.toString() ?? '0') ?? 0,
      roleName: json['roleName']?.toString() ?? '',
      role: json['role']?.toString(),
      description: json['description']?.toString(),
      wardId: json['wardId']?.toString() ?? assignment['wardId']?.toString(),
      talukaId:
          json['talukaId']?.toString() ?? assignment['talukaId']?.toString(),
      districtId:
          json['districtId']?.toString() ??
          assignment['districtId']?.toString(),
      districtName:
          json['districtName']?.toString() ??
          assignment['districtName']?.toString(),
      talukaName:
          json['talukaName']?.toString() ??
          assignment['talukaName']?.toString(),
      wardName:
          json['wardName']?.toString() ?? assignment['wardName']?.toString(),
    );
  }
}

class UserModel {
  final String userId;
  final String? username;
  final String name;
  final String email;
  final String mobileNumber;
  final String? businessLocation;
  final String? officeLocation;
  final String? latitude;
  final String? longitude;
  final String? createdAt;
  final String? updatedAt;
  final bool? isActive;
  final bool? isBasic;
  final bool? isPrime;
  final bool? hasBusiness;
  final String? otp;
  final List<RoleModel> roles;

  // Fields for ward-chart API
  final String? userType;
  final String? companyName;

  // Extra fields for UI fallbacks
  final String? profileImage;
  final String? image;
  final String? gender;
  final String? memberId;

  UserModel({
    required this.userId,
    this.username,
    required this.name,
    required this.email,
    required this.mobileNumber,
    this.businessLocation,
    this.officeLocation,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.isBasic,
    this.isPrime,
    this.hasBusiness,
    this.otp,
    required this.roles,
    this.userType,
    this.companyName,
    this.profileImage,
    this.image,
    this.gender,
    this.memberId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var rawRolesList = (json['userRoles'] ?? json['roles']) as List? ?? [];
    List<RoleModel> parsedRoles = [];

    for (var r in rawRolesList) {
      if (r is Map<String, dynamic>) {
        if (r.containsKey('role') && r['role'] is Map<String, dynamic>) {
          // Structure from /auth/getAllUsers -> userRoles[].role
          final roleData = Map<String, dynamic>.from(
            r['role'] as Map<String, dynamic>,
          );
          if (r.containsKey('assignment')) {
            roleData['assignment'] = r['assignment'];
          }
          if (r.containsKey('talukaId')) {
            roleData['talukaId'] = r['talukaId'];
          }
          if (r.containsKey('wardId')) {
            roleData['wardId'] = r['wardId'];
          }
          parsedRoles.add(RoleModel.fromJson(roleData));
        } else {
          // Structure from /roles/getAllRoleUsers -> roles[]
          final roleData = Map<String, dynamic>.from(r);
          Map<String, dynamic>? assignmentObj;
          if (json.containsKey('assignment') && json['assignment'] != null) {
            assignmentObj = json['assignment'];
          } else if (json.containsKey('positionHolder') &&
              json['positionHolder'] != null) {
            final ph = json['positionHolder'];
            if (ph is Map &&
                ph.containsKey('assignment') &&
                ph['assignment'] != null) {
              assignmentObj = ph['assignment'];
            }
          }

          if (assignmentObj != null) {
            roleData['assignment'] = assignmentObj;
            if (assignmentObj['talukaId'] != null) {
              roleData['talukaId'] = assignmentObj['talukaId'];
            }
            if (assignmentObj['wardId'] != null) {
              roleData['wardId'] = assignmentObj['wardId'];
            }
          }
          parsedRoles.add(RoleModel.fromJson(roleData));
        }
      } else if (r is String) {
        // Flat string array fallback
        parsedRoles.add(RoleModel(roleId: 0, roleName: r, role: r));
      }
    }

    // Fallback for /auth/ucn-members which returns role info in the root JSON
    if (parsedRoles.isEmpty &&
        (json['positionName'] != null || json['assignmentType'] != null)) {
      parsedRoles.add(
        RoleModel(
          roleId: json['roleId'] is int
              ? json['roleId']
              : int.tryParse(json['roleId']?.toString() ?? '0') ?? 0,
          roleName:
              json['assignmentType']?.toString() ??
              json['positionName']?.toString() ??
              '',
          role: json['positionName']?.toString(),
        ),
      );
    }

    return UserModel(
      userId:
          json['userId']?.toString() ??
          json['memberId']?.toString() ??
          json['createdByUserId']?.toString() ??
          '',
      username: json['username']?.toString(),
      name:
          json['name']?.toString() ??
          json['fullName']?.toString() ??
          json['firstName']?.toString() ??
          '',
      email: json['email']?.toString() ?? '',
      mobileNumber:
          json['mobileNumber']?.toString() ??
          json['primaryMobile']?.toString() ??
          '',
      businessLocation: json['businessLocation']?.toString(),
      officeLocation: json['officeLocation']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      isActive: json['isActive'] as bool?,
      isBasic: json['isBasic'] as bool?,
      isPrime: json['isPrime'] as bool?,
      hasBusiness: json['hasBusiness'] == true || json['hasBusiness'] == 'true',
      otp: json['otp']?.toString(),
      roles: parsedRoles,
      userType: json['userType']?.toString(),
      companyName: json['companyName']?.toString(),
      profileImage: json['profileImage']?.toString(),
      image: json['image']?.toString(),
      gender: json['gender']?.toString(),
      memberId: json['memberId']?.toString(),
    );
  }
}
