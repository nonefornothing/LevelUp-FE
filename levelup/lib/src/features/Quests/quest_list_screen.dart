import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/quest_recommendation_service.dart';
import '../../routing/app_routes.dart';
import '../Player/bloc/player_bloc.dart';
import '../Player/bloc/player_event.dart';
import '../Player/bloc/player_state.dart';
import 'bloc/quest_bloc.dart';
import 'bloc/quest_event.dart';
import 'bloc/quest_state.dart';

class QuestListScreen extends StatefulWidget {
  const QuestListScreen({super.key});

  @override
  State<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends State<QuestListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuestBloc>().add(LoadQuests());
    context.read<PlayerBloc>().add(const PlayerLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Quests',
          style: TextStyle(color: Colors.lightBlueAccent),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.questTemplates),
            icon: const Icon(Icons.library_books, color: Colors.white70),
            tooltip: 'Quest Templates',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => context.go(AppRoutes.questCreate),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<QuestBloc, QuestState>(
        builder: (context, state) {
          if (state.loading && state.quests.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.lightBlueAccent),
            );
          }

          if (state.error != null && state.quests.isEmpty) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (state.quests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No quests yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () => context.go(AppRoutes.questCreate),
                    child: const Text('Create your first quest'),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<QuestBloc>().add(LoadQuests());
            },
            child: FutureBuilder<List<RecommendedQuest>>(
              future: sl<QuestRecommendationService>().getRecommendedQuests(limit: 5),
              builder: (context, recSnapshot) {
                return CustomScrollView(
                  slivers: [
                    // Recommended Quests Section
                    if (recSnapshot.hasData && recSnapshot.data!.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Recommended for You',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    if (recSnapshot.hasData && recSnapshot.data!.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final rec = recSnapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: InkWell(
                                onTap: () => context.go('${AppRoutes.quests}/${rec.quest.id}'),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.amber.withOpacity(0.5),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.2),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              rec.quest.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${(rec.score * 100).toStringAsFixed(0)}% match',
                                              style: const TextStyle(
                                                color: Colors.amber,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        rec.explanation,
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${rec.quest.type.name} • ${rec.quest.category.name} • Difficulty ${rec.quest.difficulty}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 10),
                                      LinearProgressIndicator(
                                        value: (rec.quest.progressPercentage / 100).clamp(0.0, 1.0),
                                        backgroundColor: Colors.white12,
                                        color: Colors.amber,
                                        minHeight: 6,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${rec.quest.progressPercentage.toStringAsFixed(0)}% • ${rec.quest.status.name}',
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 14,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${rec.quest.reward.experience} XP',
                                                style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: recSnapshot.data!.length,
                        ),
                      ),
                    if (recSnapshot.hasData && recSnapshot.data!.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Divider(color: Colors.white24),
                        ),
                      ),
                    // All Quests Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: const Text(
                          'All Quests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    BlocBuilder<PlayerBloc, PlayerState>(
                      builder: (context, playerState) {
                        final playerLevel = playerState is PlayerLoaded 
                            ? playerState.player.level 
                            : 1;
                        
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final q = state.quests[index];
                              final isUnlocked = q.isUnlocked(playerLevel);
                              
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: InkWell(
                                  onTap: isUnlocked 
                                      ? () => context.go('${AppRoutes.quests}/${q.id}')
                                      : () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Unlock at Level ${q.requiredLevel}'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        },
                                  child: Opacity(
                                    opacity: isUnlocked ? 1.0 : 0.6,
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isUnlocked 
                                              ? Colors.blueAccent 
                                              : Colors.grey,
                                          width: 1,
                                        ),
                                        boxShadow: isUnlocked ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.25),
                                            blurRadius: 16,
                                            spreadRadius: 2,
                                          ),
                                        ] : null,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  q.title,
                                                  style: TextStyle(
                                                    color: isUnlocked 
                                                        ? Colors.white 
                                                        : Colors.white60,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (!isUnlocked)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.lock,
                                                        size: 12,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Lv.${q.requiredLevel}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${q.type.name} • ${q.category.name} • Difficulty ${q.difficulty}',
                                            style: TextStyle(
                                              color: isUnlocked 
                                                  ? Colors.white70 
                                                  : Colors.white38,
                                            ),
                                          ),
                                          if (isUnlocked) ...[
                                            const SizedBox(height: 10),
                                            LinearProgressIndicator(
                                              value: (q.progressPercentage / 100).clamp(0.0, 1.0),
                                              backgroundColor: Colors.white12,
                                              color: Colors.lightBlueAccent,
                                              minHeight: 6,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${q.progressPercentage.toStringAsFixed(0)}% • ${q.status.name}',
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ] else
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                'Unlock at Level ${q.requiredLevel}',
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: state.quests.length,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}


