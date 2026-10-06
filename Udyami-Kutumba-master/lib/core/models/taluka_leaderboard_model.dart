import 'ward_leaderboard_model.dart';

class TalukaLeaderboardResponse {
  final bool success;
  final String? message;
  final TalukaLeaderboardData? data;

  TalukaLeaderboardResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory TalukaLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return TalukaLeaderboardResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? TalukaLeaderboardData.fromJson(json['data']) : null,
    );
  }
}

class TalukaLeaderboardData {
  final String talukaId;
  final String talukaName;
  final TalukaSummary summary;
  final TalukaWardLeaderboard? topWard;
  final List<TalukaWardLeaderboard> wardLeaderboard;

  TalukaLeaderboardData({
    required this.talukaId,
    required this.talukaName,
    required this.summary,
    this.topWard,
    required this.wardLeaderboard,
  });

  factory TalukaLeaderboardData.fromJson(Map<String, dynamic> json) {
    return TalukaLeaderboardData(
      talukaId: json['talukaId'] ?? '',
      talukaName: json['talukaName'] ?? '',
      summary: TalukaSummary.fromJson(json['summary'] ?? {}),
      topWard: json['topWard'] != null ? TalukaWardLeaderboard.fromJson(json['topWard']) : null,
      wardLeaderboard: json['wardLeaderboard'] != null
          ? (json['wardLeaderboard'] as List).map((i) => TalukaWardLeaderboard.fromJson(i)).toList()
          : [],
    );
  }
}

class TalukaSummary {
  final num totalWards;
  final num totalUsers;
  final num totalBusinessPassed;
  final String? formattedBusinessPassed;

  TalukaSummary({
    required this.totalWards,
    required this.totalUsers,
    required this.totalBusinessPassed,
    this.formattedBusinessPassed,
  });

  factory TalukaSummary.fromJson(Map<String, dynamic> json) {
    return TalukaSummary(
      totalWards: json['totalWards'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalBusinessPassed: json['totalBusinessPassed'] ?? 0,
      formattedBusinessPassed: json['formattedBusinessPassed'],
    );
  }
}

class TalukaWardLeaderboard {
  final num rank;
  final String wardId;
  final String wardName;
  final String wardNumber;
  final num totalUsers;
  final num totalLeads;
  final num totalFaceToFace;
  final num totalGuests;
  final LeaderboardAttendance attendance;
  final num totalBusinessPassed;
  final String? formattedBusinessPassed;
  final num totalScore;
  final List<LeaderboardUser> memberLeaderboard;

  TalukaWardLeaderboard({
    required this.rank,
    required this.wardId,
    required this.wardName,
    required this.wardNumber,
    required this.totalUsers,
    required this.totalLeads,
    required this.totalFaceToFace,
    required this.totalGuests,
    required this.attendance,
    required this.totalBusinessPassed,
    this.formattedBusinessPassed,
    required this.totalScore,
    required this.memberLeaderboard,
  });

  factory TalukaWardLeaderboard.fromJson(Map<String, dynamic> json) {
    return TalukaWardLeaderboard(
      rank: json['rank'] ?? 0,
      wardId: json['wardId'] ?? '',
      wardName: json['wardName'] ?? '',
      wardNumber: json['wardNumber'] ?? '',
      totalUsers: json['totalUsers'] ?? 0,
      totalLeads: json['totalLeads'] ?? 0,
      totalFaceToFace: json['totalFaceToFace'] ?? 0,
      totalGuests: json['totalGuests'] ?? 0,
      attendance: LeaderboardAttendance.fromJson(json['attendance'] ?? {}),
      totalBusinessPassed: json['totalBusinessPassed'] ?? 0,
      formattedBusinessPassed: json['formattedBusinessPassed'],
      totalScore: json['totalScore'] ?? 0,
      memberLeaderboard: json['memberLeaderboard'] != null
          ? (json['memberLeaderboard'] as List).map((i) => LeaderboardUser.fromJson(i)).toList()
          : [],
    );
  }
}
