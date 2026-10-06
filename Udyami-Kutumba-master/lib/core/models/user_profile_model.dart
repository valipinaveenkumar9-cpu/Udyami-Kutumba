import 'dart:convert' as dart_convert;
import 'user_model.dart';

class BusinessDetailsModel {
  final String? gstNumber;
  final String? businessName;
  final String? businessType;
  final String? annualTurnover;
  final String? businessAddress;
  final List<String>? businessImages;
  final double? latitude;
  final double? longitude;
  final String? ward;
  final String? yearsInBusiness;
  final String? previousJobs;

  BusinessDetailsModel({
    this.gstNumber,
    this.businessName,
    this.businessType,
    this.annualTurnover,
    this.businessAddress,
    this.businessImages,
    this.latitude,
    this.longitude,
    this.ward,
    this.yearsInBusiness,
    this.previousJobs,
  });

  factory BusinessDetailsModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    print('DEV DEBUG - BusinessDetailsModel: json keys: ${json.keys.toList()}');
    if (json['businessImages'] != null && json['businessImages'] is List) {
      print('DEV DEBUG - BusinessDetailsModel: using businessImages array. count: ${(json['businessImages'] as List).length}');
      for (var img in json['businessImages']) {
        if (img != null && img.toString().isNotEmpty) {
          images.add(img.toString());
        }
      }
      // Also try parsing businessImage1-3 just in case the array is incomplete
      if (images.length < 3) {
        print('DEV DEBUG - BusinessDetailsModel: array has < 3 images, also checking businessImage1-3');
        for (int i = 1; i <= 3; i++) {
          var imgData = json['businessImage$i'];
          if (imgData != null) {
            String? imgStr;
            if (imgData is Map && imgData['image'] != null) {
              imgStr = imgData['image'].toString();
            } else if (imgData is String) {
              if (imgData.startsWith('{')) {
                try {
                  var decoded = dart_convert.jsonDecode(imgData);
                  if (decoded is Map && decoded['image'] != null) {
                    imgStr = decoded['image'].toString();
                  }
                } catch (e) {}
              } else {
                imgStr = imgData;
              }
            }
            if (imgStr != null && !images.contains(imgStr)) {
              print('DEV DEBUG - BusinessDetailsModel: adding missing image $i');
              images.add(imgStr);
            }
          }
        }
      }
    } else {
      print('DEV DEBUG - BusinessDetailsModel: processing businessImage1-3');
      for (int i = 1; i <= 3; i++) {
        var imgData = json['businessImage$i'];
        print('DEV DEBUG - BusinessDetailsModel: i=$i, type=${imgData.runtimeType}');
        if (imgData != null) {
          if (imgData is Map && imgData['image'] != null) {
            print('DEV DEBUG - BusinessDetailsModel: i=$i, adding from map');
            images.add(imgData['image'].toString());
          } else if (imgData is String) {
            print('DEV DEBUG - BusinessDetailsModel: i=$i, is string (length=${imgData.length})');
            // Check if it's JSON encoded
            if (imgData.startsWith('{')) {
              try {
                var decoded = dart_convert.jsonDecode(imgData);
                if (decoded is Map && decoded['image'] != null) {
                  images.add(decoded['image'].toString());
                }
              } catch (e) {
                print('DEV DEBUG - BusinessDetailsModel: failed to decode JSON string: $e');
              }
            } else {
              images.add(imgData);
            }
          } else if (imgData['image'] != null) {
             // fallback just in case
             images.add(imgData['image'].toString());
          }
        }
      }
    }


    return BusinessDetailsModel(
      gstNumber: json['gstNumber']?.toString(),
      businessName: json['businessName']?.toString(),
      businessType: json['businessType']?.toString(),
      annualTurnover: json['annualTurnover']?.toString(),
      businessAddress:
          json['address']?.toString() ?? json['businessAddress']?.toString(),
      businessImages: images.isNotEmpty ? images : null,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      ward: json['ward']?.toString(),
      yearsInBusiness: json['yearsInBusiness']?.toString(),
      previousJobs: json['previousJobs']?.toString(),
    );
  }
}

class ProfileDataModel {
  final String profileId;
  final String userId;
  final String? alternateMobile;
  final String? gender;
  final String? state;
  final String? district;
  final String? assembly;
  final String? ward;
  final String? pincode;
  final String? homeAddress;
  final String? officeAddress;
  final double? homeLatitude;
  final double? homeLongitude;
  final String? businessCategory;
  final String? businessSubCategory;
  final String? businessTag;
  final bool hasBusiness;
  final BusinessDetailsModel? businessDetails;
  final String? profileImage;
  final String? createdAt;
  final String? updatedAt;

  // New Personal Information Fields
  final String? spouse;
  final String? children;
  final String? pets;
  final String? hobbies;
  final String? interests;
  final String? cityOfResidence;
  final String? yearsInCity;
  final num? familyCount;
  final String? selectedBusinessVertical;

  ProfileDataModel({
    required this.profileId,
    required this.userId,
    this.alternateMobile,
    this.gender,
    this.state,
    this.district,
    this.assembly,
    this.ward,
    this.pincode,
    this.homeAddress,
    this.officeAddress,
    this.homeLatitude,
    this.homeLongitude,
    this.businessCategory,
    this.businessSubCategory,
    this.businessTag,
    required this.hasBusiness,
    this.businessDetails,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
    this.spouse,
    this.children,
    this.pets,
    this.hobbies,
    this.interests,
    this.cityOfResidence,
    this.yearsInCity,
    this.familyCount,
    this.selectedBusinessVertical,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      profileId: json['profileId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      alternateMobile: json['alternateMobile']?.toString(),
      gender: json['gender']?.toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      assembly: json['assembly']?.toString(),
      ward: json['ward']?.toString(),
      pincode: json['pincode']?.toString(),
      homeAddress: json['homeAddress']?.toString(),
      officeAddress: json['officeAddress']?.toString(),
      homeLatitude: json['homeLatitude'] != null
          ? double.tryParse(json['homeLatitude'].toString())
          : null,
      homeLongitude: json['homeLongitude'] != null
          ? double.tryParse(json['homeLongitude'].toString())
          : null,
      businessCategory: json['businessCategory']?.toString(),
      businessSubCategory: json['businessSubCategory']?.toString(),
      businessTag: json['businessTag']?.toString(),
      hasBusiness: json['hasBusiness'] == true || json['hasBusiness'] == 'true',
      businessDetails: _parseBusinessDetails(json['businessDetails']),
      profileImage: json['profileImage']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      spouse: json['spouse']?.toString(),
      children: json['children'] is List ? dart_convert.jsonEncode(json['children']) : json['children']?.toString(),
      pets: json['pets']?.toString(),
      hobbies: json['hobbies'] is List ? dart_convert.jsonEncode(json['hobbies']) : json['hobbies']?.toString(),
      interests: json['interests'] is List ? dart_convert.jsonEncode(json['interests']) : json['interests']?.toString(),
      cityOfResidence: json['cityOfResidence']?.toString(),
      yearsInCity: json['yearsInCity']?.toString(),
      familyCount: json['familyCount'] as num?,
      selectedBusinessVertical: json['selectedBusinessVertical']?.toString(),
    );
  }

  static BusinessDetailsModel? _parseBusinessDetails(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      return BusinessDetailsModel.fromJson(data);
    }
    if (data is String) {
      try {
        final decoded = dart_convert.jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return BusinessDetailsModel.fromJson(decoded);
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class UserProfileModel {
  final UserModel user;
  final ProfileDataModel profile;

  UserProfileModel({required this.user, required this.profile});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      profile: ProfileDataModel.fromJson(json['profile'] ?? {}),
    );
  }
}
