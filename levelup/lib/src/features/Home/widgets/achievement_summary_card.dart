import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/repositories/achievement_repository.dart';
import '../../../routing/app_routes.dart';
import '../../Achievements/bloc/achievement_bloc.dart';
import '../../Achievements/bloc/achievement_event.dart';
import '../../Achievements/bloc/achievement_state.dart';

/// Achievement summary card widget for home screen
class AchievementSummaryCard extends StatelessWidget {
  const AchievementSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AchievementBloc(
        achievementRepository: sl<AchievementRepository>(),
      )..add(const LoadAchievements()),
      child: BlocBuilder<AchievementBloc, AchievementState>(
        builder: (context, state) {
          if (state.loading && state.achievements.isEmpty) {
            return const SizedBox.shrink();
          }

          final total = state.achievements.length;
          final unlocked = state.unlockedAchievements.length;
          final progress = total > 0 ? (unlocked / total * 100) : 0.0;
          final recentUnlocked = state.unlockedAchievements
            ..sort((a, b) => (b.unlockedAt ?? DateTime(2000)).compareTo(a.unlockedAt ?? DateTime(2000)));
          final recent = recentUnlocked.take(3).toList();

          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () => context.go(AppRoutes.achievements),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Achievements',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$unlocked / $total',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unlocked',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${progress.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Complete',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.lightBlueAccent,
                        ),
                      ),
                    ),
                    if (recent.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Recent Unlocks',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...recent.map((achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _getTierColor(achievement.tier).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getTierColor(achievement.tier),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    _getAchievementIcon(achievement.type),
                                    color: _getTierColor(achievement.tier),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        achievement.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (achievement.unlockedAt != null)
                                        Text(
                                          _formatDate(achievement.unlockedAt!),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white54,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: _getTierColor(achievement.tier),
                                  size: 20,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getTierColor(dynamic tier) {
    if (tier is AchievementTier) {
      switch (tier) {
        case AchievementTier.bronze:
          return const Color(0xFFCD7F32);
        case AchievementTier.silver:
          return const Color(0xFFC0C0C0);
        case AchievementTier.gold:
          return const Color(0xFFFFD700);
        case AchievementTier.platinum:
          return const Color(0xFFE5E4E2);
      }
    }
    return Colors.grey;
  }

  IconData _getAchievementIcon(dynamic type) {
    if (type is AchievementType) {
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
    return Icons.star;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

