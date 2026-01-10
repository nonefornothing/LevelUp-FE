import 'package:equatable/equatable.dart';

/// Quest entity (Domain layer)
class Quest extends Equatable {
  final String id;
  final String title;
  final String? description;
  final QuestType type;
  final QuestCategory category;
  final int difficulty; // 1-5
  final QuestReward reward;
  final List<QuestTask> tasks;
  final List<QuestMilestone> milestones;
  final DateTime? deadline;
  final QuestStatus status;
  final double progressPercentage; // 0.0 - 100.0
  final DateTime createdAt;
  final DateTime? completedAt;
  final int requiredLevel; // Minimum level required to unlock this quest

  const Quest({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.reward,
    required this.tasks,
    required this.milestones,
    this.deadline,
    required this.status,
    required this.progressPercentage,
    required this.createdAt,
    this.completedAt,
    this.requiredLevel = 1, // Default: available from start
  });

  /// Check if quest is unlocked for a given player level
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
        deadline,
        status,
        progressPercentage,
        createdAt,
        completedAt,
        requiredLevel,
      ];
}

enum QuestType {
  mainStory,
  side,
  daily,
  weekly,
}

enum QuestCategory {
  combat,
  crafting,
  exploration,
  social,
  health,
  learning,
  work,
  personal,
}

enum QuestStatus {
  notStarted,
  inProgress,
  completed,
  failed,
  paused,
}

/// Quest Task entity
class QuestTask extends Equatable {
  final String id;
  final String questId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final int orderIndex;

  const QuestTask({
    required this.id,
    required this.questId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.completedAt,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [
        id,
        questId,
        title,
        description,
        isCompleted,
        completedAt,
        orderIndex,
      ];
}

/// Quest Milestone entity
class QuestMilestone extends Equatable {
  final String id;
  final String questId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final QuestReward reward;
  final int orderIndex;

  const QuestMilestone({
    required this.id,
    required this.questId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.completedAt,
    required this.reward,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [
        id,
        questId,
        title,
        description,
        isCompleted,
        completedAt,
        reward,
        orderIndex,
      ];
}

/// Quest Reward entity
class QuestReward extends Equatable {
  final int experience;
  final int currency;
  // Items will be added in Phase 2 (Inventory system)

  const QuestReward({
    required this.experience,
    required this.currency,
  });

  @override
  List<Object?> get props => [experience, currency];
}

