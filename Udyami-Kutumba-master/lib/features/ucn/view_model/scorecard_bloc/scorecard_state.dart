import 'package:equatable/equatable.dart';
import '../../../../core/models/scorecard_model.dart';
import '../../../../core/models/scoring_weights_model.dart';
import '../../../../core/models/ward_leaderboard_model.dart';

abstract class ScorecardState extends Equatable {
  const ScorecardState();

  @override
  List<Object?> get props => [];
}

class ScorecardInitial extends ScorecardState {}

class ScorecardLoading extends ScorecardState {}

class ScorecardLoaded extends ScorecardState {
  final ScorecardModel scorecard;
  final WardLeaderboardResponse? leaderboardResponse;
  final ScoringWeightsResponse? scoringWeightsResponse;

  const ScorecardLoaded({
    required this.scorecard,
    this.leaderboardResponse,
    this.scoringWeightsResponse,
  });

  @override
  List<Object?> get props => [scorecard, leaderboardResponse, scoringWeightsResponse];
}

class ScorecardError extends ScorecardState {
  final String message;

  const ScorecardError(this.message);

  @override
  List<Object?> get props => [message];
}
