class WardModel {
  final String wardId;
  final String wardName;
  final String district;
  final String taluka;
  final String state;
  final String wardNumber;
  final String? talukaId;
  final String constituency;
  final int boothsBuilt;
  final int boothsTotal;
  final Map<String, dynamic>? geoJson;
  final String? createdAt;

  WardModel({
    required this.wardId,
    required this.wardName,
    required this.district,
    required this.taluka,
    required this.state,
    required this.wardNumber,
    this.talukaId,
    this.constituency = '',
    this.boothsBuilt = 0,
    this.boothsTotal = 0,
    this.geoJson,
    this.createdAt,
  });

  factory WardModel.fromJson(Map<String, dynamic> json) {
    return WardModel(
      wardId: json['wardId']?.toString() ?? '',
      wardName: json['wardName']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      taluka: json['taluka']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      wardNumber: json['wardNumber']?.toString() ?? '',
      talukaId: json['talukaId']?.toString(),
      constituency: json['constituency']?.toString() ?? json['taluka']?.toString() ?? '',
      boothsBuilt: json['booths_built'] != null ? int.tryParse(json['booths_built'].toString()) ?? 0 : 0,
      boothsTotal: json['booths_total'] != null ? int.tryParse(json['booths_total'].toString()) ?? 0 : 0,
      geoJson: json['geoJson'] as Map<String, dynamic>?,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
