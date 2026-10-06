import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../core/api/ubn/scorecard_api.dart';
import '../../../../core/models/scorecard_model.dart';
import '../../../../core/models/ward_leaderboard_model.dart';
import '../view_model/scorecard_bloc/scorecard_bloc.dart';
import '../view_model/scorecard_bloc/scorecard_event.dart';
import '../view_model/scorecard_bloc/scorecard_state.dart';

class ScoreCardScreen extends StatelessWidget {
  const ScoreCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        print('DEV DEBUG - ScoreCardScreen - Initializing ScorecardBloc');
        return ScorecardBloc(ScorecardApi())..add(const FetchScorecardData());
      },
      child: const ScoreCardView(),
    );
  }
}

class ScoreCardView extends StatelessWidget {
  const ScoreCardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Theme.of(context).colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Scorecard",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<ScorecardBloc, ScorecardState>(
        builder: (context, state) {
          print('DEV DEBUG - ScoreCardView - Current State: $state');
          if (state is ScorecardLoading || state is ScorecardInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScorecardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ScorecardBloc>().add(const FetchScorecardData());
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          } else if (state is ScorecardLoaded) {
            final scorecard = state.scorecard;
            final rankText = _getRankText(state.leaderboardResponse, scorecard.userId);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Score Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Contribution Score",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${scorecard.score.total}",
                                style: TextStyle(
                                  color: _getColorForLevel(scorecard.score.level),
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: " / ${scorecard.score.max}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "${scorecard.score.level} · $rankText",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Reward Wallet / Breakdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Reward Wallet (Scores)",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${scorecard.score.total} Points",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _walletBreakdownRow(context, "Lead Management", "+${scorecard.leads.score} pts"),
                        _walletBreakdownRow(context, "Face to Face", "+${scorecard.faceToFace.score} pts"),
                        _walletBreakdownRow(context, "Attendance", "+${scorecard.attendance.score} pts"),
                        _walletBreakdownRow(context, "Invites (Guests)", "+${scorecard.guests.score} pts"),
                        _walletBreakdownRow(context, "Gratitude Slips", "+${scorecard.gratitudeSlips.score} pts"),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                               print('DEV DEBUG - Claim Rewards clicked');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "Claim Rewards",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  _progressTile(context,
                    title: "Attendance",
                    value: "${scorecard.attendance.achieved}/${scorecard.attendance.total} · ${scorecard.attendance.percentage}%",
                    progress: scorecard.attendance.percentage / 100,
                    color: Colors.teal,
                  ),

                  const SizedBox(height: 18),

                  _progressTile(context,
                    title: "Leads Given",
                    value: "${scorecard.leads.achieved} · ${scorecard.leads.target}",
                    progress: scorecard.leads.percentage / 100,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 18),

                  _progressTile(context,
                    title: "Face to Face Done",
                    value: "${scorecard.faceToFace.achieved} · ${scorecard.faceToFace.target}",
                    progress: scorecard.faceToFace.percentage / 100,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 18),

                  _progressTile(context,
                    title: "Guests Joined",
                    value: "${scorecard.guests.achieved} · ${scorecard.guests.target}",
                    progress: scorecard.guests.percentage / 100,
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 18),

                  _progressTile(context,
                    title: "Gratitude Slips Given",
                    value: scorecard.gratitudeSlips.formattedValue.isNotEmpty 
                        ? scorecard.gratitudeSlips.formattedValue 
                        : "₹${scorecard.gratitudeSlips.totalValue}",
                    progress: scorecard.gratitudeSlips.percentage / 100,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.track_changes,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pass more leads & book Face to Face meetings to improve your score.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Color _getColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'amber':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRankText(WardLeaderboardResponse? leaderboardResponse, String userId) {
    if (leaderboardResponse != null && leaderboardResponse.success && leaderboardResponse.data != null) {
      final totalUsers = leaderboardResponse.data!.totalUsers;
      final users = leaderboardResponse.data!.leaderboard;
      final currentUserRank = users.firstWhere(
        (element) => element.userId == userId,
        orElse: () => LeaderboardUser(rank: 0, userId: '', name: '', ward: '', leads: 0, faceToFace: 0, guests: 0, attendance: LeaderboardAttendance(attended: 0, total: 0, percentage: 0), businessPassed: 0, score: 0),
      );

      if (currentUserRank.rank > 0) {
        return "Rank ${currentUserRank.rank} of $totalUsers";
      }
    }
    return "Rank N/A";
  }

  Widget _progressTile(BuildContext context, {
    required String title,
    required String value,
    required double progress,
    required Color color,
  }) {
    // Ensure progress is between 0 and 1
    double safeProgress = progress.isNaN || progress.isInfinite ? 0.0 : progress;
    if (safeProgress > 1.0) safeProgress = 1.0;
    if (safeProgress < 0.0) safeProgress = 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: safeProgress,
            minHeight: 10,
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _walletBreakdownRow(BuildContext context, String title, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            points,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}