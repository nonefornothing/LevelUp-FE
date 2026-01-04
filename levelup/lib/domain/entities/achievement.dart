import 'package:equatable/equatable.dart';

/// Achievement entity (Domain layer)
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final AchievementTier tier;
  final int targetValue; // Target value for this achievement (e.g., level 5, 10 quests)
  final int currentProgress; // Current progress towards target
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String iconName; // Icon identifier for UI

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.tier,
    required this.targetValue,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
    required this.iconName,
  });

  /// Get progress percentage (0.0 - 100.0)
  double get progressPercentage {
    if (targetValue == 0) return isUnlocked ? 100.0 : 0.0;
    return (currentProgress / targetValue * 100).clamp(0.0, 100.0);
  }

  /// Check if achievement is completed
  bool get isCompleted => isUnlocked;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    AchievementTier? tier,
    int? targetValue,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? iconName,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      tier: tier ?? this.tier,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        tier,
        targetValue,
        currentProgress,
        isUnlocked,
        unlockedAt,
        iconName,
      ];
}

/// Achievement types
enum AchievementType {
  firstQuest, // First quest completed
  questMilestone, // Quest completion milestones (10, 50, 100, etc.)
  levelMilestone, // Level milestones (5, 10, 20, etc.)
  dailyStreak, // Daily quest streaks (7, 30, 100 days)
  perfectWeek, // Complete all daily quests in a week
  totalXP, // Total XP milestones
}

/// Achievement tier (for UI display)
enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

