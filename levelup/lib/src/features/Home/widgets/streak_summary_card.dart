import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/streak.dart';
import '../../../routing/app_routes.dart';
import '../../Streaks/bloc/streak_bloc.dart';
import '../../Streaks/bloc/streak_event.dart';
import '../../Streaks/bloc/streak_state.dart';

/// Widget displaying streak summary on home screen
class StreakSummaryCard extends StatelessWidget {
  const StreakSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = StreakBloc();
        bloc.add(const StreakLoadRequested());
        return bloc;
      },
      child: BlocBuilder<StreakBloc, StreakState>(
        builder: (context, state) {
          if (state is StreakLoading) {
            return Card(
              color: Colors.grey[900],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (state is StreakError) {
            return const SizedBox.shrink();
          }

          if (state is StreakLoaded) {
            final dailyQuestStreak =
                state.streaksByType[StreakType.dailyQuest];
            final questCompletionStreak =
                state.streaksByType[StreakType.questCompletion];

            // Show card if at least one streak exists
            if (dailyQuestStreak == null && questCompletionStreak == null) {
              return const SizedBox.shrink();
            }

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => context.go(AppRoutes.streaks),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Streaks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (dailyQuestStreak != null) ...[
                        _buildStreakRow(
                          context,
                          'Daily Quest',
                          dailyQuestStreak.currentStreak,
                          dailyQuestStreak.isActive(DateTime.now()),
                          dailyQuestStreak.isBroken(DateTime.now()),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (questCompletionStreak != null)
                        _buildStreakRow(
                          context,
                          'Quest Completion',
                          questCompletionStreak.currentStreak,
                          questCompletionStreak.isActive(DateTime.now()),
                          questCompletionStreak.isBroken(DateTime.now()),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStreakRow(
    BuildContext context,
    String label,
    int streak,
    bool isActive,
    bool isBroken,
  ) {
    Color streakColor;
    IconData streakIcon;
    String statusText;

    if (isBroken) {
      streakColor = Colors.grey;
      streakIcon = Icons.cancel_outlined;
      statusText = 'Broken';
    } else if (isActive) {
      streakColor = Colors.orange;
      streakIcon = Icons.local_fire_department;
      statusText = 'Active';
    } else {
      streakColor = Colors.amber;
      streakIcon = Icons.schedule;
      statusText = 'Continue today!';
    }

    return Row(
      children: [
        Icon(streakIcon, color: streakColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: streakColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: streakColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streak',
                style: TextStyle(
                  color: streakColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'days',
                style: TextStyle(
                  color: streakColor.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            color: streakColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

