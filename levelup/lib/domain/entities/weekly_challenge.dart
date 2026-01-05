import 'package:equatable/equatable.dart';

import 'quest.dart';

/// Weekly Challenge entity (Domain layer)
class WeeklyChallenge extends Equatable {
  final String id;
  final String title;
  final String? description;
  final WeeklyChallengeType type;
  final int targetValue; // Target value for the challenge (e.g., complete 10 quests)
  final int currentProgress; // Current progress towards target
  final QuestReward reward;
  final DateTime weekStartDate; // Monday of the week
  final DateTime weekEndDate; // Sunday of the week
  final WeeklyChallengeStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const WeeklyChallenge({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.targetValue,
    required this.currentProgress,
    required this.reward,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  /// Calculate progress percentage (0.0 - 100.0)
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentProgress / targetValue * 100).clamp(0.0, 100.0);
  }

  /// Check if challenge is completed
  bool get isCompleted => status == WeeklyChallengeStatus.completed;

  /// Check if challenge is expired (past week end date)
  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(weekEndDate);
  }

  /// Get days remaining until challenge expires
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(weekEndDate)) return 0;
    return weekEndDate.difference(now).inDays + 1;
  }

  /// Create a copy with updated progress
  WeeklyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    WeeklyChallengeType? type,
    int? targetValue,
    int? currentProgress,
    QuestReward? reward,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    WeeklyChallengeStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return WeeklyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      reward: reward ?? this.reward,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        targetValue,
        currentProgress,
        reward,
        weekStartDate,
        weekEndDate,
        status,
        createdAt,
        completedAt,
      ];
}

/// Weekly Challenge Type
enum WeeklyChallengeType {
  completeQuests, // Complete X quests
  completeDailyQuests, // Complete X daily quests
  earnXP, // Earn X XP
  levelUp, // Level up X times
}

/// Weekly Challenge Status
enum WeeklyChallengeStatus {
  active, // Challenge is active and in progress
  completed, // Challenge has been completed
  expired, // Challenge expired without completion
}

