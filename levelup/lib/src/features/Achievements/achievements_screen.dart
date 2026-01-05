import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/achievement.dart';
import '../../../domain/repositories/achievement_repository.dart';
import 'bloc/achievement_bloc.dart';
import 'bloc/achievement_event.dart';
import 'bloc/achievement_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AchievementBloc(
        achievementRepository: sl<AchievementRepository>(),
      )..add(const LoadAchievements()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Achievements',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
        ),
        body: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state.loading && state.achievements.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightBlueAccent,
                ),
              );
            }

            if (state.error != null && state.achievements.isEmpty) {
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
                      state.error!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AchievementBloc>().add(const LoadAchievements());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AchievementBloc>().add(const RefreshAchievements());
              },
              color: Colors.lightBlueAccent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    _buildSummaryCard(state),
                    const SizedBox(height: 16),

                    // Unlocked Achievements
                    if (state.unlockedAchievements.isNotEmpty) ...[
                      const Text(
                        'Unlocked',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.unlockedAchievements.map((achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AchievementCard(achievement: achievement, isUnlocked: true),
                          )),
                      const SizedBox(height: 24),
                    ],

                    // Locked Achievements
                    const Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.lockedAchievements.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No locked achievements',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    else
                      ...state.lockedAchievements.map((achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AchievementCard(achievement: achievement, isUnlocked: false),
                          )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AchievementState state) {
    final total = state.achievements.length;
    final unlocked = state.unlockedAchievements.length;
    final progress = total > 0 ? (unlocked / total * 100) : 0.0;

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$unlocked / $total',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.lightBlueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getTierColor(achievement.tier).withOpacity(0.2)
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnlocked
                      ? _getTierColor(achievement.tier)
                      : Colors.grey[700]!,
                  width: 2,
                ),
              ),
              child: Icon(
                _getAchievementIcon(achievement.type),
                color: isUnlocked
                    ? _getTierColor(achievement.tier)
                    : Colors.grey[600],
                size: 30,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        Icon(
                          Icons.check_circle,
                          color: _getTierColor(achievement.tier),
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnlocked ? Colors.white70 : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isUnlocked) ...[
                    Text(
                      'Progress: ${achievement.currentProgress} / ${achievement.targetValue}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: achievement.progressPercentage / 100,
                        minHeight: 4,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.lightBlueAccent,
                        ),
                      ),
                    ),
                  ] else if (achievement.unlockedAt != null) ...[
                    Text(
                      'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32); // Bronze
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0); // Silver
      case AchievementTier.gold:
        return const Color(0xFFFFD700); // Gold
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2); // Platinum
    }
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstQuest:
        return Icons.flag;
      case AchievementType.questMilestone:
        return Icons.emoji_events;
      case AchievementType.levelMilestone:
        return Icons.trending_up;
      case AchievementType.dailyStreak:
        return Icons.local_fire_department;
      case AchievementType.perfectWeek:
        return Icons.calendar_today;
      case AchievementType.totalXP:
        return Icons.stars;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}





