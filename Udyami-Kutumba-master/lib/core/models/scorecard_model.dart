class ScorecardModel {
  final String userId;
  final ScorecardUser user;
  final ScoreDetails score;
  final AttendanceDetails attendance;
  final ActivityDetails leads;
  final ActivityDetails faceToFace;
  final ActivityDetails guests;
  final GratitudeDetails gratitudeSlips;

  ScorecardModel({
    required this.userId,
    required this.user,
    required this.score,
    required this.attendance,
    required this.leads,
    required this.faceToFace,
    required this.guests,
    required this.gratitudeSlips,
  });

  factory ScorecardModel.fromJson(Map<String, dynamic> json) {
    print('DEV DEBUG - ScorecardModel.fromJson - Parsing Data: $json');
    return ScorecardModel(
      userId: json['userId'] ?? '',
      user: ScorecardUser.fromJson(json['user'] ?? {}),
      score: ScoreDetails.fromJson(json['score'] ?? {}),
      attendance: AttendanceDetails.fromJson(json['attendance'] ?? {}),
      leads: ActivityDetails.fromJson(json['leads'] ?? {}),
      faceToFace: ActivityDetails.fromJson(json['faceToFace'] ?? {}),
      guests: ActivityDetails.fromJson(json['guests'] ?? {}),
      gratitudeSlips: GratitudeDetails.fromJson(json['gratitudeSlips'] ?? {}),
    );
  }
}

class ScorecardUser {
  final String name;
  final String email;

  ScorecardUser({required this.name, required this.email});

  factory ScorecardUser.fromJson(Map<String, dynamic> json) {
    return ScorecardUser(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class ScoreDetails {
  final num total;
  final num max;
  final String level;

  ScoreDetails({required this.total, required this.max, required this.level});

  factory ScoreDetails.fromJson(Map<String, dynamic> json) {
    return ScoreDetails(
      total: json['total'] ?? 0,
      max: json['max'] ?? 0,
      level: json['level'] ?? '',
    );
  }
}

class AttendanceDetails {
  final num achieved;
  final num total;
  final num percentage;
  final num score;
  final num maxScore;

  AttendanceDetails({
    required this.achieved,
    required this.total,
    required this.percentage,
    required this.score,
    required this.maxScore,
  });

  factory AttendanceDetails.fromJson(Map<String, dynamic> json) {
    return AttendanceDetails(
      achieved: json['achieved'] ?? 0,
      total: json['total'] ?? 0,
      percentage: json['percentage'] ?? 0,
      score: json['score'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
    );
  }
}

class ActivityDetails {
  final num achieved;
  final num target;
  final num percentage;
  final num score;
  final num maxScore;

  ActivityDetails({
    required this.achieved,
    required this.target,
    required this.percentage,
    required this.score,
    required this.maxScore,
  });

  factory ActivityDetails.fromJson(Map<String, dynamic> json) {
    return ActivityDetails(
      achieved: json['achieved'] ?? 0,
      target: json['target'] ?? 0,
      percentage: json['percentage'] ?? 0,
      score: json['score'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
    );
  }
}

class GratitudeDetails {
  final num totalValue;
  final String formattedValue;
  final num target;
  final num percentage;
  final num score;
  final num maxScore;

  GratitudeDetails({
    required this.totalValue,
    required this.formattedValue,
    required this.target,
    required this.percentage,
    required this.score,
    required this.maxScore,
  });

  factory GratitudeDetails.fromJson(Map<String, dynamic> json) {
    return GratitudeDetails(
      totalValue: json['totalValue'] ?? 0,
      formattedValue: json['formattedValue'] ?? '',
      target: json['target'] ?? 0,
      percentage: json['percentage'] ?? 0,
      score: json['score'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
    );
  }
}
