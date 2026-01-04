import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../routing/app_routes.dart';
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.quests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final q = state.quests[index];
                return InkWell(
                  onTap: () => context.go('${AppRoutes.quests}/${q.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.25),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${q.type.name} • ${q.category.name} • Difficulty ${q.difficulty}',
                          style: const TextStyle(color: Colors.white70),
                        ),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


