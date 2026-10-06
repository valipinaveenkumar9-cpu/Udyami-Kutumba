class WardLeaderboardResponse {
  final bool success;
  final String? message;
  final LeaderboardData? data;

  WardLeaderboardResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory WardLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    print('DEV DEBUG - WardLeaderboardResponse.fromJson - Parsing Data: $json');
    return WardLeaderboardResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? LeaderboardData.fromJson(json['data']) : null,
    );
  }
}

class LeaderboardData {
  final String ward;
  final num totalUsers;
  final num totalBusinessPassed;
  final String? formattedBusinessPassed;
  final List<LeaderboardUser> leaderboard;

  LeaderboardData({
    required this.ward,
    required this.totalUsers,
    required this.totalBusinessPassed,
    this.formattedBusinessPassed,
    required this.leaderboard,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      ward: json['ward'] ?? '',
      totalUsers: json['totalUsers'] ?? 0,
      totalBusinessPassed: json['totalBusinessPassed'] ?? 0,
      formattedBusinessPassed: json['formattedBusinessPassed'],
      leaderboard: json['leaderboard'] != null
          ? (json['leaderboard'] as List).map((i) => LeaderboardUser.fromJson(i)).toList()
          : [],
    );
  }
}

class LeaderboardUser {
  final num rank;
  final String userId;
  final String name;
  final String? profileImage;
  final String ward;
  final num leads;
  final num faceToFace;
  final num guests;
  final LeaderboardAttendance attendance;
  final num businessPassed;
  final num score;

  LeaderboardUser({
    required this.rank,
    required this.userId,
    required this.name,
    this.profileImage,
    required this.ward,
    required this.leads,
    required this.faceToFace,
    required this.guests,
    required this.attendance,
    required this.businessPassed,
    required this.score,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      rank: json['rank'] ?? 0,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'],
      ward: json['ward'] ?? '',
      leads: json['leads'] ?? 0,
      faceToFace: json['faceToFace'] ?? 0,
      guests: json['guests'] ?? 0,
      attendance: LeaderboardAttendance.fromJson(json['attendance'] ?? {}),
      businessPassed: json['businessPassed'] ?? 0,
      score: json['score'] ?? 0,
    );
  }
}

class LeaderboardAttendance {
  final num attended;
  final num total;
  final num percentage;

  LeaderboardAttendance({
    required this.attended,
    required this.total,
    required this.percentage,
  });

  factory LeaderboardAttendance.fromJson(Map<String, dynamic> json) {
    return LeaderboardAttendance(
      attended: json['attended'] ?? 0,
      total: json['total'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}
