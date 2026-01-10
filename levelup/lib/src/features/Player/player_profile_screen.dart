import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/repositories/player_repository.dart';
import '../../routing/app_routes.dart';
import 'bloc/player_bloc.dart';
import 'bloc/player_event.dart';
import 'bloc/player_state.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerBloc(
        playerRepository: sl<PlayerRepository>(),
      )..add(const PlayerLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
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
                      // Player Info Card
                      Card(
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.lightBlueAccent,
                                child: Text(
                                  player.username[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                player.username,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (player.email != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  player.email!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Level & XP Card
                      Card(
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Level ${player.level}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlueAccent,
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
                              
                              // XP Progress Bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${player.experience} XP',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Next: ${player.xpForNextLevel} XP',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
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
                                  const SizedBox(height: 4),
                                  Text(
                                    '${player.xpProgressPercentage.toStringAsFixed(1)}% to Level ${player.level + 1}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Card
                      Card(
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Statistics',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => context.go(AppRoutes.statistics),
                                    icon: const Icon(
                                      Icons.analytics,
                                      size: 16,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    label: const Text(
                                      'View Details',
                                      style: TextStyle(color: Colors.lightBlueAccent),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _StatRow(
                                icon: Icons.flag,
                                label: 'Quests Completed',
                                value: '${player.stats.totalQuestsCompleted}',
                              ),
                              const SizedBox(height: 12),
                              _StatRow(
                                icon: Icons.local_fire_department,
                                label: 'Current Streak',
                                value: '${player.stats.currentStreak} days',
                              ),
                              const SizedBox(height: 12),
                              _StatRow(
                                icon: Icons.emoji_events,
                                label: 'Longest Streak',
                                value: '${player.stats.longestStreak} days',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Inventory Card
                      Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.purple,
                            ),
                          ),
                          title: const Text(
                            'Inventory',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'View your items and collectibles',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () => context.go(AppRoutes.inventory),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Achievements Card
                      Card(
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Achievements',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => context.go(AppRoutes.achievements),
                                    icon: const Icon(
                                      Icons.emoji_events,
                                      size: 16,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    label: const Text(
                                      'View All',
                                      style: TextStyle(color: Colors.lightBlueAccent),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'View your achievements and progress',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Account Info
                      Card(
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Info',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(
                                label: 'Member Since',
                                value: _formatDate(player.createdAt),
                              ),
                              if (player.lastActiveAt != null) ...[
                                const SizedBox(height: 12),
                                _InfoRow(
                                  label: 'Last Active',
                                  value: _formatDate(player.lastActiveAt!),
                                ),
                              ],
                            ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
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

