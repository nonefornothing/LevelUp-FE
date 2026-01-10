import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/id_generator.dart';
import '../../../core/utils/quest_progress_calculator.dart';
import '../../../domain/entities/quest.dart';
import 'bloc/quest_bloc.dart';
import 'bloc/quest_event.dart';

class QuestCreateScreen extends StatefulWidget {
  const QuestCreateScreen({super.key});

  @override
  State<QuestCreateScreen> createState() => _QuestCreateScreenState();
}

class _QuestCreateScreenState extends State<QuestCreateScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tasksCtrl = TextEditingController();

  QuestType _type = QuestType.side;
  QuestCategory _category = QuestCategory.personal;
  int _difficulty = 1;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tasksCtrl.dispose();
    super.dispose();
  }

  void _create() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final questId = IdGenerator.newId();

    final taskLines = _tasksCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final tasks = <QuestTask>[];
    for (var i = 0; i < taskLines.length; i++) {
      tasks.add(
        QuestTask(
          id: IdGenerator.newId(),
          questId: questId,
          title: taskLines[i],
          description: null,
          isCompleted: false,
          completedAt: null,
          orderIndex: i,
        ),
      );
    }

    final reward = QuestReward(
      experience: _difficulty * 10,
      currency: _difficulty * 5,
    );

    // Calculate required level based on difficulty (1-5 maps to levels 1, 2, 3, 5, 8)
    final requiredLevel = _calculateRequiredLevel(_difficulty);
    
    final quest = Quest(
      id: questId,
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      type: _type,
      category: _category,
      difficulty: _difficulty,
      reward: reward,
      tasks: tasks,
      milestones: const [],
      deadline: null,
      status: QuestStatus.notStarted,
      progressPercentage: 0.0,
      createdAt: DateTime.now(),
      completedAt: null,
      requiredLevel: requiredLevel,
    );

    final progress = QuestProgressCalculator.calculateProgress(quest);
    final questWithProgress = Quest(
      id: quest.id,
      title: quest.title,
      description: quest.description,
      type: quest.type,
      category: quest.category,
      difficulty: quest.difficulty,
      reward: quest.reward,
      tasks: quest.tasks,
      milestones: quest.milestones,
      deadline: quest.deadline,
      status: quest.status,
      progressPercentage: progress,
      createdAt: quest.createdAt,
      completedAt: quest.completedAt,
    );

    context.read<QuestBloc>().add(CreateQuestRequested(questWithProgress));
    context.pop();
  }

  /// Calculate required level based on difficulty
  /// Difficulty 1 = Level 1, 2 = Level 2, 3 = Level 3, 4 = Level 5, 5 = Level 8
  int _calculateRequiredLevel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      case 4:
        return 5;
      case 5:
        return 8;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Create Quest',
          style: TextStyle(color: Colors.lightBlueAccent),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<QuestType>(
              value: _type,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Type',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              items: QuestType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<QuestCategory>(
              value: _category,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              items: QuestCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _difficulty,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Difficulty (1-5)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              items: [1, 2, 3, 4, 5]
                  .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                  .toList(),
              onChanged: (v) => setState(() => _difficulty = v ?? _difficulty),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tasksCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Tasks (one per line)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _create,
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


