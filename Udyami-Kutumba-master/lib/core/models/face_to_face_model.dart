class FaceToFaceModel {
  final String id;
  final String memberName;
  final String date;
  final String purpose;
  final String status;
  final String? feedback;
  final String? message;
  final String? createdAt;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? businessName;
  final String? profession;
  final int? yearsInBusiness;
  final String? previousJobs;
  final String? familyInformation;
  final String? spouse;
  final String? children;
  final String? pets;
  final String? hobbies;
  final String? activitiesOrInterests;
  final String? cityOfResidence;
  final String? yearsInCity;
  final Map<String, dynamic>? createdUser;
  final Map<String, dynamic>? invitedMember;
  final String? createdUserId;
  final String? invitedMemberUserId;

  FaceToFaceModel({
    required this.id,
    required this.memberName,
    required this.date,
    required this.purpose,
    required this.status,
    this.feedback,
    this.message,
    this.createdAt,
    this.location,
    this.latitude,
    this.longitude,
    this.businessName,
    this.profession,
    this.yearsInBusiness,
    this.previousJobs,
    this.familyInformation,
    this.spouse,
    this.children,
    this.pets,
    this.hobbies,
    this.activitiesOrInterests,
    this.cityOfResidence,
    this.yearsInCity,
    this.createdUser,
    this.invitedMember,
    this.createdUserId,
    this.invitedMemberUserId,
  });

  factory FaceToFaceModel.fromJson(Map<String, dynamic> json) {
    String mName = json['memberName']?.toString() ?? '';
    if (mName.trim().isEmpty && json['invitedMember'] != null) {
      mName = json['invitedMember']['name']?.toString() ?? '';
    }

    return FaceToFaceModel(
      id: json['id']?.toString() ?? '',
      memberName: mName,
      date: json['date']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      feedback: json['feedback']?.toString(),
      message: json['message']?.toString(),
      createdAt: json['createdAt']?.toString(),
      location: json['location']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      businessName: json['businessName']?.toString(),
      profession: json['profession']?.toString(),
      yearsInBusiness: json['yearsInBusiness'] != null ? int.tryParse(json['yearsInBusiness'].toString()) : null,
      previousJobs: json['previousJobs']?.toString(),
      familyInformation: json['familyInformation']?.toString(),
      spouse: json['spouse']?.toString(),
      children: json['children']?.toString(),
      pets: json['pets']?.toString(),
      hobbies: json['hobbies']?.toString(),
      activitiesOrInterests: json['activitiesOrInterests']?.toString(),
      cityOfResidence: json['cityOfResidence']?.toString(),
      yearsInCity: json['yearsInCity']?.toString(),
      createdUser: json['createdUser'],
      invitedMember: json['invitedMember'],
      createdUserId: json['createdUserId']?.toString(),
      invitedMemberUserId: json['invitedMemberUserId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberName': memberName,
      'date': date,
      'purpose': purpose,
      'status': status,
      'feedback': feedback,
      'message': message,
      'createdAt': createdAt,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'businessName': businessName,
      'profession': profession,
      'yearsInBusiness': yearsInBusiness,
      'previousJobs': previousJobs,
      'familyInformation': familyInformation,
      'spouse': spouse,
      'children': children,
      'pets': pets,
      'hobbies': hobbies,
      'activitiesOrInterests': activitiesOrInterests,
      'cityOfResidence': cityOfResidence,
      'yearsInCity': yearsInCity,
      'createdUser': createdUser,
      'invitedMember': invitedMember,
      'createdUserId': createdUserId,
      'invitedMemberUserId': invitedMemberUserId,
    };
  }
}
