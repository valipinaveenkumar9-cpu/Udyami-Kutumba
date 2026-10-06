class AssemblyScorecardResponse {
  final bool? success;
  final String? message;
  final AssemblyScorecardData? data;

  AssemblyScorecardResponse({
    this.success,
    this.message,
    this.data,
  });

  factory AssemblyScorecardResponse.fromJson(Map<String, dynamic> json) {
    return AssemblyScorecardResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? AssemblyScorecardData.fromJson(json['data']) : null,
    );
  }
}

class AssemblyScorecardData {
  final String? assemblyId;
  final String? assemblyName;
  final AssemblyScoreInfo? score;
  final AssemblySummary? summary;
  final AssemblyWardInfo? topWard;
  final List<AssemblyWardInfo>? wards;

  AssemblyScorecardData({
    this.assemblyId,
    this.assemblyName,
    this.score,
    this.summary,
    this.topWard,
    this.wards,
  });

  factory AssemblyScorecardData.fromJson(Map<String, dynamic> json) {
    return AssemblyScorecardData(
      assemblyId: json['assemblyId'] as String?,
      assemblyName: json['assemblyName'] as String?,
      score: json['score'] != null ? AssemblyScoreInfo.fromJson(json['score']) : null,
      summary: json['summary'] != null ? AssemblySummary.fromJson(json['summary']) : null,
      topWard: json['topWard'] != null ? AssemblyWardInfo.fromJson(json['topWard']) : null,
      wards: (json['wards'] as List<dynamic>?)
          ?.map((e) => AssemblyWardInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AssemblyScoreInfo {
  final num? total;
  final num? max;
  final String? level;

  AssemblyScoreInfo({
    this.total,
    this.max,
    this.level,
  });

  factory AssemblyScoreInfo.fromJson(Map<String, dynamic> json) {
    return AssemblyScoreInfo(
      total: json['total'] as num?,
      max: json['max'] as num?,
      level: json['level'] as String?,
    );
  }
}

class AssemblySummary {
  final int? totalTalukas;
  final int? totalWards;
  final int? totalUsers;
  final num? totalBusinessPassed;
  final String? formattedBusinessPassed;

  AssemblySummary({
    this.totalTalukas,
    this.totalWards,
    this.totalUsers,
    this.totalBusinessPassed,
    this.formattedBusinessPassed,
  });

  factory AssemblySummary.fromJson(Map<String, dynamic> json) {
    return AssemblySummary(
      totalTalukas: json['totalTalukas'] as int?,
      totalWards: json['totalWards'] as int?,
      totalUsers: json['totalUsers'] as int?,
      totalBusinessPassed: json['totalBusinessPassed'] as num?,
      formattedBusinessPassed: json['formattedBusinessPassed'] as String?,
    );
  }
}

class AssemblyWardInfo {
  final int? rank;
  final String? wardId;
  final String? wardName;
  final String? wardNumber;
  final String? talukaId;
  final int? totalUsers;
  final AssemblyScoreInfo? score;
  final AssemblyWardStatistics? statistics;
  final List<AssemblyUserInfo>? users;

  AssemblyWardInfo({
    this.rank,
    this.wardId,
    this.wardName,
    this.wardNumber,
    this.talukaId,
    this.totalUsers,
    this.score,
    this.statistics,
    this.users,
  });

  factory AssemblyWardInfo.fromJson(Map<String, dynamic> json) {
    return AssemblyWardInfo(
      rank: json['rank'] as int?,
      wardId: json['wardId'] as String?,
      wardName: json['wardName'] as String?,
      wardNumber: json['wardNumber'] as String?,
      talukaId: json['talukaId'] as String?,
      totalUsers: json['totalUsers'] as int?,
      score: json['score'] != null ? AssemblyScoreInfo.fromJson(json['score']) : null,
      statistics: json['statistics'] != null ? AssemblyWardStatistics.fromJson(json['statistics']) : null,
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => AssemblyUserInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AssemblyWardStatistics {
  final int? totalLeads;
  final int? totalFaceToFace;
  final int? totalGuests;
  final AssemblyStatItem? attendance;
  final num? totalBusinessPassed;
  final String? formattedBusinessPassed;

  AssemblyWardStatistics({
    this.totalLeads,
    this.totalFaceToFace,
    this.totalGuests,
    this.attendance,
    this.totalBusinessPassed,
    this.formattedBusinessPassed,
  });

  factory AssemblyWardStatistics.fromJson(Map<String, dynamic> json) {
    return AssemblyWardStatistics(
      totalLeads: json['totalLeads'] as int?,
      totalFaceToFace: json['totalFaceToFace'] as int?,
      totalGuests: json['totalGuests'] as int?,
      attendance: json['attendance'] != null ? AssemblyStatItem.fromJson(json['attendance']) : null,
      totalBusinessPassed: json['totalBusinessPassed'] as num?,
      formattedBusinessPassed: json['formattedBusinessPassed'] as String?,
    );
  }
}

class AssemblyUserInfo {
  final int? rank;
  final String? userId;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? profileImage;
  final String? wardId;
  final String? wardName;
  final String? wardNumber;
  final String? talukaId;
  final String? talukaName;
  final AssemblyScoreInfo? score;
  final AssemblyStatItem? attendance;
  final AssemblyStatItem? leads;
  final AssemblyStatItem? faceToFace;
  final AssemblyStatItem? guests;
  final AssemblyGratitudeStat? gratitudeSlips;

  AssemblyUserInfo({
    this.rank,
    this.userId,
    this.name,
    this.email,
    this.mobileNumber,
    this.profileImage,
    this.wardId,
    this.wardName,
    this.wardNumber,
    this.talukaId,
    this.talukaName,
    this.score,
    this.attendance,
    this.leads,
    this.faceToFace,
    this.guests,
    this.gratitudeSlips,
  });

  factory AssemblyUserInfo.fromJson(Map<String, dynamic> json) {
    return AssemblyUserInfo(
      rank: json['rank'] as int?,
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      wardId: json['wardId'] as String?,
      wardName: json['wardName'] as String?,
      wardNumber: json['wardNumber'] as String?,
      talukaId: json['talukaId'] as String?,
      talukaName: json['talukaName'] as String?,
      score: json['score'] != null ? AssemblyScoreInfo.fromJson(json['score']) : null,
      attendance: json['attendance'] != null ? AssemblyStatItem.fromJson(json['attendance']) : null,
      leads: json['leads'] != null ? AssemblyStatItem.fromJson(json['leads']) : null,
      faceToFace: json['faceToFace'] != null ? AssemblyStatItem.fromJson(json['faceToFace']) : null,
      guests: json['guests'] != null ? AssemblyStatItem.fromJson(json['guests']) : null,
      gratitudeSlips: json['gratitudeSlips'] != null ? AssemblyGratitudeStat.fromJson(json['gratitudeSlips']) : null,
    );
  }
}

class AssemblyStatItem {
  final num? achieved;
  final num? target;
  final num? percentage;
  final num? score;
  final num? maxScore;
  final num? total;
  
  AssemblyStatItem({
    this.achieved,
    this.target,
    this.percentage,
    this.score,
    this.maxScore,
    this.total,
  });

  factory AssemblyStatItem.fromJson(Map<String, dynamic> json) {
    return AssemblyStatItem(
      achieved: json['achieved'] as num?,
      target: json['target'] as num?,
      percentage: json['percentage'] as num?,
      score: json['score'] as num?,
      maxScore: json['maxScore'] as num?,
      total: json['total'] as num?,
    );
  }
}

class AssemblyGratitudeStat {
  final num? totalValue;
  final String? formattedValue;
  final num? target;
  final num? percentage;
  final num? score;
  final num? maxScore;

  AssemblyGratitudeStat({
    this.totalValue,
    this.formattedValue,
    this.target,
    this.percentage,
    this.score,
    this.maxScore,
  });

  factory AssemblyGratitudeStat.fromJson(Map<String, dynamic> json) {
    return AssemblyGratitudeStat(
      totalValue: json['totalValue'] as num?,
      formattedValue: json['formattedValue'] as String?,
      target: json['target'] as num?,
      percentage: json['percentage'] as num?,
      score: json['score'] as num?,
      maxScore: json['maxScore'] as num?,
    );
  }
}
