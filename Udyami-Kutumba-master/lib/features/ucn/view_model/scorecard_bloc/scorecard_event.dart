import 'package:equatable/equatable.dart';

abstract class ScorecardEvent extends Equatable {
  const ScorecardEvent();

  @override
  List<Object> get props => [];
}

class FetchScorecardData extends ScorecardEvent {
  const FetchScorecardData();
}
