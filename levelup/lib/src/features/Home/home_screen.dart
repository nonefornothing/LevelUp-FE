import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/daily_quest_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/entities/quest.dart';
import '../../routing/app_routes.dart';
import '../Player/bloc/player_bloc.dart';
import '../Player/bloc/player_event.dart';
import '../Player/bloc/player_state.dart';
import 'widgets/achievement_summary_card.dart';
import 'widgets/weekly_challenge_summary_card.dart';
import 'widgets/recommended_quests_card.dart';
import 'widgets/friends_summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PlayerBloc>()..add(const PlayerLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'LevelUp',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
          actions: [
            FutureBuilder<int>(
              future: sl<NotificationService>().getUnreadCount(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => context.go(AppRoutes.notifications),
                      icon: const Icon(Icons.notifications, color: Colors.white70),
                      tooltip: 'Notifications',
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              onPressed: () => context.go(AppRoutes.profile),
              icon: const Icon(Icons.person, color: Colors.white70),
              tooltip: 'Profile',
            ),
            IconButton(
              onPressed: () => context.go(AppRoutes.settings),
              icon: const Icon(Icons.settings, color: Colors.white70),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            if (state is PlayerLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightBlueAccent,
                ),
              );
            }

            if (state is PlayerError) {
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
                        context.read<PlayerBloc>().add(const PlayerLoadRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PlayerLoaded) {
              final player = state.player;
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
                      // Player Stats Card
                      Card(
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.lightBlueAccent,
                                    child: Text(
                                      player.username[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.username,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Level ${player.level}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.lightBlueAccent,
                                            fontWeight: FontWeight.bold,
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
                                      color: Colors.blueAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.currency_bitcoin,
                                          size: 16,
                                          color: Colors.yellow,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${player.currency}',
                                          style: const TextStyle(
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // XP Progress
                              Text(
                                '${player.experience} / ${player.xpForNextLevel} XP',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: player.xpProgressPercentage / 100,
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
                      ),
                      const SizedBox(height: 24),

                      // Achievement Summary Card
                      const AchievementSummaryCard(),
                      const SizedBox(height: 16),

                      // Weekly Challenges Summary Card
                      const WeeklyChallengeSummaryCard(),
                      const SizedBox(height: 16),

                      // Recommended Quests Card
                      const RecommendedQuestsCard(),
                      const SizedBox(height: 16),

                      // Friends Summary Card
                      const FriendsSummaryCard(),
                      const SizedBox(height: 16),

                      // Daily Quests Section
                      FutureBuilder<List<Quest>>(
                        future: sl<DailyQuestService>().getDailyQuests(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            final dailyQuests = snapshot.data!;
                            final activeQuests = dailyQuests.where(
                              (q) => q.status != QuestStatus.completed,
                            ).take(3).toList();
                            
                            if (activeQuests.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Quests',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...activeQuests.map((quest) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                    onTap: () => context.go('${AppRoutes.quests}/${quest.id}'),
                                    child: Card(
                                      color: Colors.grey[900],
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    quest.title,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  LinearProgressIndicator(
                                                    value: quest.progressPercentage / 100,
                                                    backgroundColor: Colors.grey[800],
                                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                                      Colors.lightBlueAccent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${quest.progressPercentage.toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => context.go(AppRoutes.quests),
                                  child: const Text(
                                    'View All Daily Quests',
                                    style: TextStyle(color: Colors.lightBlueAccent),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Quick Stats
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.flag,
                              label: 'Quests',
                              value: '${player.stats.totalQuestsCompleted}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department,
                              label: 'Streak',
                              value: '${player.stats.currentStreak}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => context.go(AppRoutes.quests),
                          icon: const Icon(Icons.list_alt, color: Colors.white),
                          label: const Text(
                            'View All Quests',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.lightBlueAccent,
                            side: const BorderSide(color: Colors.lightBlueAccent),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => context.go(AppRoutes.profile),
                          icon: const Icon(Icons.person),
                          label: const Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.lightBlueAccent, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


