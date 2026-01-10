import 'package:equatable/equatable.dart';

import 'quest.dart';

/// Quest Template entity - Pre-built quests that users can add to their quest list
class QuestTemplate extends Equatable {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestCategory category;
  final int difficulty; // 1-5
  final QuestReward reward;
  final List<QuestTemplateTask> tasks;
  final List<QuestTemplateMilestone> milestones;
  final int? estimatedDurationDays; // Estimated days to complete
  final int requiredLevel; // Minimum level required
  final String? iconName; // Icon identifier
  final List<String> tags; // Tags for search and filtering
  final bool isFeatured; // Featured templates shown first
  final DateTime createdAt;

  const QuestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.reward,
    required this.tasks,
    required this.milestones,
    this.estimatedDurationDays,
    this.requiredLevel = 1,
    this.iconName,
    this.tags = const [],
    this.isFeatured = false,
    required this.createdAt,
  });

  /// Convert template to a Quest entity
  Quest toQuest({String? customId, DateTime? deadline}) {
    return Quest(
      id: customId ?? id,
      title: title,
      description: description,
      type: type,
      category: category,
      difficulty: difficulty,
      reward: reward,
      tasks: tasks.map((t) => t.toQuestTask(customId ?? id)).toList(),
      milestones: milestones.map((m) => m.toQuestMilestone(customId ?? id)).toList(),
      deadline: deadline,
      status: QuestStatus.notStarted,
      progressPercentage: 0.0,
      createdAt: DateTime.now(),
      requiredLevel: requiredLevel,
    );
  }

  /// Check if template is unlocked for a given player level
  bool isUnlocked(int playerLevel) {
    return playerLevel >= requiredLevel;
  }

  /// Get unlock status message
  String getUnlockMessage(int playerLevel) {
    if (isUnlocked(playerLevel)) {
      return 'Available';
    }
    return 'Unlock at Level $requiredLevel';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        category,
        difficulty,
        reward,
        tasks,
        milestones,
        estimatedDurationDays,
        requiredLevel,
        iconName,
        tags,
        isFeatured,
        createdAt,
      ];
}

/// Quest Template Task
class QuestTemplateTask extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int orderIndex;

  const QuestTemplateTask({
    required this.id,
    required this.title,
    this.description,
    required this.orderIndex,
  });

  QuestTask toQuestTask(String questId) {
    return QuestTask(
      id: id,
      questId: questId,
      title: title,
      description: description,
      isCompleted: false,
      orderIndex: orderIndex,
    );
  }

  @override
  List<Object?> get props => [id, title, description, orderIndex];
}

/// Quest Template Milestone
class QuestTemplateMilestone extends Equatable {
  final String id;
  final String title;
  final String? description;
  final QuestReward reward;
  final int orderIndex;

  const QuestTemplateMilestone({
    required this.id,
    required this.title,
    this.description,
    required this.reward,
    required this.orderIndex,
  });

  QuestMilestone toQuestMilestone(String questId) {
    return QuestMilestone(
      id: id,
      questId: questId,
      title: title,
      description: description,
      isCompleted: false,
      reward: reward,
      orderIndex: orderIndex,
    );
  }

  @override
  List<Object?> get props => [id, title, description, reward, orderIndex];
}


