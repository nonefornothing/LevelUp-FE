import 'package:equatable/equatable.dart';

import 'quest.dart';

/// Statistics entity (Domain layer)
class Statistics extends Equatable {
  // Overview
  final int totalQuestsCompleted;
  final int totalQuestsCreated;
  final double questCompletionRate; // Percentage
  final int totalXPEarned;
  final int totalCurrencyEarned;

  // Quest breakdown by type
  final Map<QuestType, int> questsByType;

  // Quest breakdown by category
  final Map<QuestCategory, int> questsByCategory;

  // Daily activity (last 7 days)
  final List<DailyActivity> dailyActivity;

  // Level stats
  final int currentLevel;
  final int totalLevelsGained;

  const Statistics({
    required this.totalQuestsCompleted,
    required this.totalQuestsCreated,
    required this.questCompletionRate,
    required this.totalXPEarned,
    required this.totalCurrencyEarned,
    required this.questsByType,
    required this.questsByCategory,
    required this.dailyActivity,
    required this.currentLevel,
    required this.totalLevelsGained,
  });

  @override
  List<Object?> get props => [
        totalQuestsCompleted,
        totalQuestsCreated,
        questCompletionRate,
        totalXPEarned,
        totalCurrencyEarned,
        questsByType,
        questsByCategory,
        dailyActivity,
        currentLevel,
        totalLevelsGained,
      ];
}

/// Daily activity data
class DailyActivity extends Equatable {
  final DateTime date;
  final int questsCompleted;
  final int xpEarned;
  final int currencyEarned;

  const DailyActivity({
    required this.date,
    required this.questsCompleted,
    required this.xpEarned,
    required this.currencyEarned,
  });

  @override
  List<Object?> get props => [date, questsCompleted, xpEarned, currencyEarned];
}

