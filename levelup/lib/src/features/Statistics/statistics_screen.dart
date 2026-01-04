import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/statistics_service.dart';
import '../../../domain/entities/quest.dart';
import '../../../domain/entities/statistics.dart';
import '../../../core/utils/result.dart';
import '../../../domain/repositories/player_repository.dart';
import '../../../domain/repositories/quest_repository.dart';
import '../Player/bloc/player_bloc.dart';
import '../Player/bloc/player_event.dart';
import '../Player/bloc/player_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PlayerBloc(
            playerRepository: sl<PlayerRepository>(),
          )..add(const PlayerLoadRequested()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Statistics',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
        ),
        body: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, playerState) {
            if (playerState is PlayerLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightBlueAccent,
                ),
              );
            }

            if (playerState is PlayerError) {
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
                      playerState.message,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PlayerBloc>().add(const PlayerLoadRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (playerState is PlayerLoaded) {
              return FutureBuilder<List<Quest>>(
                future: _loadAllQuests(),
                builder: (context, questSnapshot) {
                  if (questSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.lightBlueAccent,
                      ),
                    );
                  }

                  if (questSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading quests: ${questSnapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final allQuests = questSnapshot.data ?? [];
                  final statistics = StatisticsService.calculateStatistics(
                    player: playerState.player,
                    allQuests: allQuests,
                  );

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PlayerBloc>().add(const PlayerRefreshRequested());
                    },
                    color: Colors.lightBlueAccent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview Statistics
                          _buildOverviewCard(statistics),
                          const SizedBox(height: 16),

                          // Quest Breakdown by Type
                          _buildQuestsByTypeCard(statistics),
                          const SizedBox(height: 16),

                          // Quest Breakdown by Category
                          _buildQuestsByCategoryCard(statistics),
                          const SizedBox(height: 16),

                          // Daily Activity
                          _buildDailyActivityCard(statistics),
                          const SizedBox(height: 16),

                          // Level & Progression
                          _buildLevelCard(statistics),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<List<Quest>> _loadAllQuests() async {
    final questRepository = sl<QuestRepository>();
    final result = await questRepository.getQuests();
    return result is Success<List<Quest>> ? result.data : [];
  }

  Widget _buildOverviewCard(Statistics stats) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _StatRow(
              icon: Icons.flag,
              label: 'Quests Completed',
              value: '${stats.totalQuestsCompleted} / ${stats.totalQuestsCreated}',
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.trending_up,
              label: 'Completion Rate',
              value: '${stats.questCompletionRate.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.stars,
              label: 'Total XP Earned',
              value: '${stats.totalXPEarned}',
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.currency_bitcoin,
              label: 'Total Currency Earned',
              value: '${stats.totalCurrencyEarned}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsByTypeCard(Statistics stats) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quests by Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...QuestType.values.map((type) {
              final count = stats.questsByType[type] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StatRow(
                  icon: _getTypeIcon(type),
                  label: _formatTypeName(type),
                  value: '$count',
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsByCategoryCard(Statistics stats) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quests by Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...QuestCategory.values.map((category) {
              final count = stats.questsByCategory[category] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StatRow(
                  icon: _getCategoryIcon(category),
                  label: _formatCategoryName(category),
                  value: '$count',
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyActivityCard(Statistics stats) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Activity (Last 7 Days)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (stats.dailyActivity.isEmpty)
              const Text(
                'No activity recorded',
                style: TextStyle(color: Colors.white70),
              )
            else
              ...stats.dailyActivity.map((activity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(activity.date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${activity.questsCompleted} quest${activity.questsCompleted != 1 ? 's' : ''}',
                            style: const TextStyle(color: Colors.lightBlueAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '+${activity.xpEarned} XP',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '+${activity.currencyEarned} coins',
                            style: const TextStyle(color: Colors.yellow, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(Statistics stats) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Level & Progression',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _StatRow(
              icon: Icons.trending_up,
              label: 'Current Level',
              value: '${stats.currentLevel}',
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.trending_up,
              label: 'Levels Gained',
              value: '${stats.totalLevelsGained}',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(QuestType type) {
    switch (type) {
      case QuestType.mainStory:
        return Icons.book;
      case QuestType.side:
        return Icons.explore;
      case QuestType.daily:
        return Icons.calendar_today;
      case QuestType.weekly:
        return Icons.calendar_view_week;
    }
  }

  IconData _getCategoryIcon(QuestCategory category) {
    switch (category) {
      case QuestCategory.combat:
        return Icons.sports_mma;
      case QuestCategory.crafting:
        return Icons.build;
      case QuestCategory.exploration:
        return Icons.explore;
      case QuestCategory.social:
        return Icons.people;
      case QuestCategory.health:
        return Icons.favorite;
      case QuestCategory.learning:
        return Icons.school;
      case QuestCategory.work:
        return Icons.work;
      case QuestCategory.personal:
        return Icons.person;
    }
  }

  String _formatTypeName(QuestType type) {
    switch (type) {
      case QuestType.mainStory:
        return 'Main Story';
      case QuestType.side:
        return 'Side';
      case QuestType.daily:
        return 'Daily';
      case QuestType.weekly:
        return 'Weekly';
    }
  }

  String _formatCategoryName(QuestCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.lightBlueAccent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

