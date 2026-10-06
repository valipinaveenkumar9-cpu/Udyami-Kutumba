import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../core/api/ubn/scorecard_api.dart';
import '../../../../core/models/ward_leaderboard_model.dart';
import '../../../../core/utils/session_manager.dart';
import '../view_model/scorecard_bloc/scorecard_bloc.dart';
import '../view_model/scorecard_bloc/scorecard_event.dart';
import '../view_model/scorecard_bloc/scorecard_state.dart';

class LeaderBoardScreen extends StatelessWidget {
  const LeaderBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScorecardBloc(ScorecardApi())..add(const FetchScorecardData()),
      child: const LeaderBoardView(),
    );
  }
}

class LeaderBoardView extends StatelessWidget {
  const LeaderBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = SessionManager.user?['userId']?.toString();

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Leaderboard",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<ScorecardBloc, ScorecardState>(
        builder: (context, state) {
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
            final lbResponse = state.leaderboardResponse;
            if (lbResponse == null || !lbResponse.success || lbResponse.data == null) {
              return const Center(
                child: Text("Leaderboard data not available."),
              );
            }

            final data = lbResponse.data!;
            final leaderboardList = data.leaderboard;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Quarter / Year Buttons
                  Row(
                    children: [
                      _filterChip(context, "All Time", true),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Total Business Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Business Passed in Ward (${data.ward})",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data.formattedBusinessPassed ?? "₹${data.totalBusinessPassed}",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (leaderboardList.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No users found in leaderboard."),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leaderboardList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = leaderboardList[index];
                        final isYou = user.userId == currentUserId;
                        final avatarText = _getInitials(user.name);

                        // Colors based on rank
                        Color avatarColor = Colors.grey;
                        if (user.rank == 1) avatarColor = Colors.orange;
                        else if (user.rank == 2) avatarColor = Colors.purple;
                        else if (user.rank == 3) avatarColor = Colors.blue;
                        else avatarColor = Colors.green;

                        final formattedBusiness = "₹${user.businessPassed}"; // No formatted specific to user returned by API natively, fallback to this
                        final subtitle = "${user.leads} Leads · $formattedBusiness Closed · ${user.score} Pts";

                        return _leaderTile(
                          context,
                          rank: "${user.rank}",
                          avatar: avatarText,
                          avatarColor: avatarColor,
                          name: user.name.isEmpty ? "Unknown User" : user.name,
                          subtitle: subtitle,
                          trophy: user.rank == 1,
                          isYou: isYou,
                          highlight: isYou,
                        );
                      },
                    ),

                  const SizedBox(height: 25),

                  const Center(
                    child: Text(
                      "Points: Leads • Face to Face • Guests • Attendance",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
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

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Widget _filterChip(BuildContext context, String title, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.teal : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _leaderTile(BuildContext context, {
    required String rank,
    required String avatar,
    required Color avatarColor,
    required String name,
    required String subtitle,
    bool trophy = false,
    bool isYou = false,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: highlight 
            ? Border.all(color: Colors.teal.withOpacity(0.5), width: 1.5) 
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              rank,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: rank == "1"
                    ? Colors.orange
                    : Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(width: 10),

          CircleAvatar(
            radius: 22,
            backgroundColor: avatarColor.withOpacity(.15),
            child: Text(
              avatar,
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "You",
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          if (trophy)
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 30,
            ),
        ],
      ),
    );
  }
}