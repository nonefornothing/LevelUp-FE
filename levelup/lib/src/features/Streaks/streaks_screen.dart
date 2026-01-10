import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/streak.dart';
import '../../../domain/repositories/streak_repository.dart';
import 'bloc/streak_bloc.dart';
import 'bloc/streak_event.dart';
import 'bloc/streak_state.dart';

/// Screen displaying all streaks and statistics
class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StreakBloc()..add(const StreakLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Streaks',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
        ),
        body: BlocBuilder<StreakBloc, StreakState>(
          builder: (context, state) {
            if (state is StreakLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StreakError) {
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
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StreakBloc>().add(const StreakRefreshRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is StreakLoaded) {
              if (state.streaks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Streaks Yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete quests to start building your streaks!',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StreakBloc>().add(const StreakRefreshRequested());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Summary
                      if (state.statistics != null)
                        _buildStatisticsCard(context, state.statistics!),
                      const SizedBox(height: 16),

                      // Streaks List
                      const Text(
                        'Your Streaks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.streaks.map((streak) => _buildStreakCard(
                            context,
                            streak,
                          )),
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

  Widget _buildStatisticsCard(
    BuildContext context,
    StreakStatistics statistics,
  ) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Active',
                    '${statistics.totalActiveStreaks}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Longest',
                    '${statistics.longestOverallStreak}',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Days',
                    '${statistics.totalDaysStreaked}',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, Streak streak) {
    final now = DateTime.now();
    final isActive = streak.isActive(now);
    final isBroken = streak.isBroken(now);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isBroken) {
      statusColor = Colors.grey;
      statusIcon = Icons.cancel_outlined;
      statusText = 'Streak Broken';
    } else if (isActive) {
      statusColor = Colors.orange;
      statusIcon = Icons.local_fire_department;
      statusText = 'Active Streak';
    } else {
      statusColor = Colors.amber;
      statusIcon = Icons.schedule;
      statusText = 'Continue Today!';
    }

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStreakTypeName(streak.type),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${streak.currentStreak}',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatRow(
                    'Current',
                    '${streak.currentStreak} days',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatRow(
                    'Longest',
                    '${streak.longestStreak} days',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatRow(
                    'Total',
                    '${streak.totalCompletions}',
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (streak.streakStartDate != null) ...[
              const SizedBox(height: 12),
              Text(
                'Started: ${_formatDate(streak.streakStartDate!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _getStreakTypeName(StreakType type) {
    switch (type) {
      case StreakType.dailyQuest:
        return 'Daily Quest Streak';
      case StreakType.questCompletion:
        return 'Quest Completion Streak';
      case StreakType.weeklyChallenge:
        return 'Weekly Challenge Streak';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


