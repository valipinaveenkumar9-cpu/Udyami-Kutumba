class ScoringWeightsResponse {
  final bool success;
  final String? message;
  final ScoringWeightsData? data;

  ScoringWeightsResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ScoringWeightsResponse.fromJson(Map<String, dynamic> json) {
    print('DEV DEBUG - ScoringWeightsResponse.fromJson - Parsing Data: $json');
    return ScoringWeightsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? ScoringWeightsData.fromJson(json['data']) : null,
    );
  }
}

class ScoringWeightsData {
  final List<ScoringWeight> weights;
  final List<ScoreBand> bands;

  ScoringWeightsData({
    required this.weights,
    required this.bands,
  });

  factory ScoringWeightsData.fromJson(Map<String, dynamic> json) {
    return ScoringWeightsData(
      weights: json['weights'] != null
          ? (json['weights'] as List).map((i) => ScoringWeight.fromJson(i)).toList()
          : [],
      bands: json['bands'] != null
          ? (json['bands'] as List).map((i) => ScoreBand.fromJson(i)).toList()
          : [],
    );
  }
}

class ScoringWeight {
  final String scoringWeightId;
  final String action;
  final num points;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  ScoringWeight({
    required this.scoringWeightId,
    required this.action,
    required this.points,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ScoringWeight.fromJson(Map<String, dynamic> json) {
    return ScoringWeight(
      scoringWeightId: json['scoringWeightId'] ?? '',
      action: json['action'] ?? '',
      points: json['points'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'points': points,
    };
  }
}

class ScoreBand {
  final String scoreBandId;
  final String bandName;
  final num minScore;
  final num maxScore;
  final String colorCode;
  final String? createdAt;
  final String? updatedAt;

  ScoreBand({
    required this.scoreBandId,
    required this.bandName,
    required this.minScore,
    required this.maxScore,
    required this.colorCode,
    this.createdAt,
    this.updatedAt,
  });

  factory ScoreBand.fromJson(Map<String, dynamic> json) {
    return ScoreBand(
      scoreBandId: json['scoreBandId'] ?? '',
      bandName: json['bandName'] ?? '',
      minScore: json['minScore'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      colorCode: json['colorCode'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'bandName': bandName,
      'minScore': minScore,
      'maxScore': maxScore,
      'colorCode': colorCode,
    };
  }
}
