import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/quest_progress_calculator.dart';
import '../../../domain/entities/quest.dart';
import '../../routing/app_routes.dart';
import '../Rewards/reward_claim_screen.dart';
import 'bloc/quest_bloc.dart';
import 'bloc/quest_event.dart';
import 'bloc/quest_state.dart';

class QuestDetailScreen extends StatefulWidget {
  final String questId;

  const QuestDetailScreen({super.key, required this.questId});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  bool _rewardShown = false;

  @override
  void initState() {
    super.initState();
    context.read<QuestBloc>().add(LoadQuestById(widget.questId));
  }

  void _toggleTask(Quest quest, QuestTask task, bool checked) {
    final updatedTasks = quest.tasks.map((t) {
      if (t.id != task.id) return t;
      return QuestTask(
        id: t.id,
        questId: t.questId,
        title: t.title,
        description: t.description,
        isCompleted: checked,
        completedAt: checked ? DateTime.now() : null,
        orderIndex: t.orderIndex,
      );
    }).toList();

    final newStatus = updatedTasks.any((t) => t.isCompleted)
        ? QuestStatus.inProgress
        : QuestStatus.notStarted;

    final updated = Quest(
      id: quest.id,
      title: quest.title,
      description: quest.description,
      type: quest.type,
      category: quest.category,
      difficulty: quest.difficulty,
      reward: quest.reward,
      tasks: updatedTasks,
      milestones: quest.milestones,
      deadline: quest.deadline,
      status: quest.status == QuestStatus.completed ? quest.status : newStatus,
      progressPercentage: quest.progressPercentage,
      createdAt: quest.createdAt,
      completedAt: quest.completedAt,
    );

    final progress = QuestProgressCalculator.calculateProgress(updated);
    final updatedWithProgress = Quest(
      id: updated.id,
      title: updated.title,
      description: updated.description,
      type: updated.type,
      category: updated.category,
      difficulty: updated.difficulty,
      reward: updated.reward,
      tasks: updated.tasks,
      milestones: updated.milestones,
      deadline: updated.deadline,
      status: updated.status,
      progressPercentage: progress,
      createdAt: updated.createdAt,
      completedAt: updated.completedAt,
    );

    context.read<QuestBloc>().add(UpdateQuestRequested(updatedWithProgress));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Quest Detail',
          style: TextStyle(color: Colors.lightBlueAccent),
        ),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              context.read<QuestBloc>().add(DeleteQuestRequested(widget.questId));
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: BlocListener<QuestBloc, QuestState>(
        listener: (context, state) {
          final q = state.selectedQuest;
          if (!_rewardShown &&
              q != null &&
              q.id == widget.questId &&
              q.status == QuestStatus.completed) {
            _rewardShown = true;
            context.push(
              AppRoutes.rewardClaim,
              extra: RewardArgs(
                questId: q.id,
                questTitle: q.title,
                experience: q.reward.experience,
                currency: q.reward.currency,
              ),
            );
          }
        },
        child: BlocBuilder<QuestBloc, QuestState>(
          builder: (context, state) {
          final quest = state.selectedQuest;
          if (state.loading && quest == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.lightBlueAccent),
            );
          }
          if (quest == null) {
            return Center(
              child: Text(
                state.error ?? 'Quest not found',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                quest.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${quest.type.name} • ${quest.category.name} • Difficulty ${quest.difficulty}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (quest.progressPercentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.white12,
                color: Colors.lightBlueAccent,
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${quest.progressPercentage.toStringAsFixed(0)}% • ${quest.status.name}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if (quest.description != null)
                Text(
                  quest.description!,
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 16),
              const Text(
                'Tasks',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (quest.tasks.isEmpty)
                const Text(
                  'No tasks for this quest.',
                  style: TextStyle(color: Colors.white70),
                )
              else
                ...quest.tasks.map((t) {
                  return CheckboxListTile(
                    value: t.isCompleted,
                    onChanged: quest.status == QuestStatus.completed
                        ? null
                        : (v) => _toggleTask(quest, t, v ?? false),
                    activeColor: Colors.lightBlueAccent,
                    checkColor: Colors.black,
                    title: Text(
                      t.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: t.completedAt != null
                        ? Text(
                            'Completed',
                            style: const TextStyle(color: Colors.white54),
                          )
                        : null,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
              const SizedBox(height: 16),
              if (quest.status != QuestStatus.completed)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      context.read<QuestBloc>().add(CompleteQuestRequested(quest.id));
                    },
                    child: Text(
                      'Complete Quest (+${quest.reward.experience} XP, +${quest.reward.currency} Gold)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          );
        },
      ),
      ),
    );
  }
}


