import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/weekly_challenge.dart';
import 'bloc/weekly_challenge_bloc.dart';
import 'bloc/weekly_challenge_event.dart';
import 'bloc/weekly_challenge_state.dart';

class WeeklyChallengesScreen extends StatelessWidget {
  const WeeklyChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeeklyChallengeBloc()
        ..add(const WeeklyChallengeLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Weekly Challenges',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
        ),
        body: BlocBuilder<WeeklyChallengeBloc, WeeklyChallengeState>(
          builder: (context, state) {
            if (state is WeeklyChallengeLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightBlueAccent,
                ),
              );
            }

            if (state is WeeklyChallengeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<WeeklyChallengeBloc>().add(
                              const WeeklyChallengeLoadRequested(),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is WeeklyChallengeLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WeeklyChallengeBloc>().add(
                        const WeeklyChallengeRefreshRequested(),
                      );
                },
                color: Colors.lightBlueAccent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Week Info Card
                      _buildWeekInfoCard(state),
                      const SizedBox(height: 24),

                      // Active Challenges
                      if (state.activeChallenges.isNotEmpty) ...[
                        const Text(
                          'Active Challenges',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...state.activeChallenges.map((challenge) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ChallengeCard(challenge: challenge),
                            )),
                        const SizedBox(height: 24),
                      ],

                      // Completed Challenges
                      if (state.completedChallenges.isNotEmpty) ...[
                        const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...state.completedChallenges.map((challenge) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ChallengeCard(challenge: challenge, isCompleted: true),
                            )),
                      ],

                      // Empty State
                      if (state.activeChallenges.isEmpty &&
                          state.completedChallenges.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No challenges this week',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildWeekInfoCard(WeeklyChallengeLoaded state) {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = _getWeekEnd(now);
    final daysRemaining = weekEnd.difference(now).inDays + 1;

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.lightBlueAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: daysRemaining <= 2 ? Colors.orange : Colors.lightBlueAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} remaining',
                  style: TextStyle(
                    color: daysRemaining <= 2 ? Colors.orange : Colors.lightBlueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${state.completedChallenges.length} of ${state.challenges.length} completed',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    final daysFromMonday = weekday == 7 ? 6 : weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  DateTime _getWeekEnd(DateTime date) {
    final weekday = date.weekday;
    final daysToSunday = weekday == 7 ? 0 : 7 - weekday;
    return DateTime(date.year, date.month, date.day, 23, 59, 59)
        .add(Duration(days: daysToSunday));
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

class _ChallengeCard extends StatelessWidget {
  final WeeklyChallenge challenge;
  final bool isCompleted;

  const _ChallengeCard({
    required this.challenge,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCompleted ? Colors.grey[800] : Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getChallengeIcon(challenge.type),
                  color: isCompleted
                      ? Colors.green
                      : Colors.lightBlueAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.green : Colors.white,
                        ),
                      ),
                      if (challenge.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          challenge.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getProgressText(challenge),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${challenge.progressPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.lightBlueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: challenge.progressPercentage / 100,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Colors.lightBlueAccent,
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Reward Info
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${challenge.reward.experience} XP',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.monetization_on,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${challenge.reward.currency} coins',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getChallengeIcon(WeeklyChallengeType type) {
    switch (type) {
      case WeeklyChallengeType.completeQuests:
        return Icons.assignment;
      case WeeklyChallengeType.completeDailyQuests:
        return Icons.today;
      case WeeklyChallengeType.earnXP:
        return Icons.trending_up;
      case WeeklyChallengeType.levelUp:
        return Icons.arrow_upward;
    }
  }

  String _getProgressText(WeeklyChallenge challenge) {
    switch (challenge.type) {
      case WeeklyChallengeType.completeQuests:
        return '${challenge.currentProgress}/${challenge.targetValue} quests';
      case WeeklyChallengeType.completeDailyQuests:
        return '${challenge.currentProgress}/${challenge.targetValue} daily quests';
      case WeeklyChallengeType.earnXP:
        return '${challenge.currentProgress}/${challenge.targetValue} XP';
      case WeeklyChallengeType.levelUp:
        return '${challenge.currentProgress}/${challenge.targetValue} level${challenge.targetValue > 1 ? 's' : ''}';
    }
  }
}

