import 'package:equatable/equatable.dart';

import 'quest.dart';

/// Enhanced analytics data for quest completion patterns
class QuestAnalytics extends Equatable {
  final ProductivityInsights productivityInsights;
  final CategoryPerformance categoryPerformance;
  final TimeBasedAnalytics timeBasedAnalytics;
  final CompletionPatterns completionPatterns;
  final DifficultyAnalysis difficultyAnalysis;
  final DateTime generatedAt;

  const QuestAnalytics({
    required this.productivityInsights,
    required this.categoryPerformance,
    required this.timeBasedAnalytics,
    required this.completionPatterns,
    required this.difficultyAnalysis,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        productivityInsights,
        categoryPerformance,
        timeBasedAnalytics,
        completionPatterns,
        difficultyAnalysis,
        generatedAt,
      ];
}

/// Productivity insights about when user is most productive
class ProductivityInsights extends Equatable {
  final String bestDayOfWeek; // e.g., "Monday"
  final int bestHourOfDay; // 0-23
  final double averageQuestsPerDay;
  final int mostProductiveDayCount;
  final String mostProductiveMonth;
  final double completionRate;
  final double averageCompletionTimeHours; // Average hours to complete a quest

  const ProductivityInsights({
    required this.bestDayOfWeek,
    required this.bestHourOfDay,
    required this.averageQuestsPerDay,
    required this.mostProductiveDayCount,
    required this.mostProductiveMonth,
    required this.completionRate,
    required this.averageCompletionTimeHours,
  });

  @override
  List<Object?> get props => [
        bestDayOfWeek,
        bestHourOfDay,
        averageQuestsPerDay,
        mostProductiveDayCount,
        mostProductiveMonth,
        completionRate,
        averageCompletionTimeHours,
      ];
}

/// Performance breakdown by category
class CategoryPerformance extends Equatable {
  final Map<QuestCategory, CategoryStats> statsByCategory;
  final QuestCategory? bestCategory;
  final QuestCategory? needsImprovement;

  const CategoryPerformance({
    required this.statsByCategory,
    this.bestCategory,
    this.needsImprovement,
  });

  @override
  List<Object?> get props => [statsByCategory, bestCategory, needsImprovement];
}

/// Statistics for a specific category
class CategoryStats extends Equatable {
  final QuestCategory category;
  final int totalQuests;
  final int completedQuests;
  final double completionRate;
  final int totalXP;
  final int averageDifficulty;
  final double averageCompletionTimeHours;

  const CategoryStats({
    required this.category,
    required this.totalQuests,
    required this.completedQuests,
    required this.completionRate,
    required this.totalXP,
    required this.averageDifficulty,
    required this.averageCompletionTimeHours,
  });

  @override
  List<Object?> get props => [
        category,
        totalQuests,
        completedQuests,
        completionRate,
        totalXP,
        averageDifficulty,
        averageCompletionTimeHours,
      ];
}

/// Time-based analytics (weekly, monthly trends)
class TimeBasedAnalytics extends Equatable {
  final List<WeeklyTrend> weeklyTrends; // Last 12 weeks
  final List<MonthlyTrend> monthlyTrends; // Last 12 months
  final TrendDirection overallTrend; // Improving, declining, stable

  const TimeBasedAnalytics({
    required this.weeklyTrends,
    required this.monthlyTrends,
    required this.overallTrend,
  });

  @override
  List<Object?> get props => [weeklyTrends, monthlyTrends, overallTrend];
}

/// Weekly trend data
class WeeklyTrend extends Equatable {
  final DateTime weekStart;
  final int questsCompleted;
  final int xpEarned;
  final double completionRate;

  const WeeklyTrend({
    required this.weekStart,
    required this.questsCompleted,
    required this.xpEarned,
    required this.completionRate,
  });

  @override
  List<Object?> get props => [weekStart, questsCompleted, xpEarned, completionRate];
}

/// Monthly trend data
class MonthlyTrend extends Equatable {
  final int year;
  final int month;
  final int questsCompleted;
  final int xpEarned;
  final double completionRate;

  const MonthlyTrend({
    required this.year,
    required this.month,
    required this.questsCompleted,
    required this.xpEarned,
    required this.completionRate,
  });

  @override
  List<Object?> get props => [year, month, questsCompleted, xpEarned, completionRate];
}

/// Trend direction indicator
enum TrendDirection {
  improving,
  declining,
  stable,
}

/// Completion patterns analysis
class CompletionPatterns extends Equatable {
  final Map<QuestType, TypePattern> patternsByType;
  final double averageTasksPerQuest;
  final double averageMilestonesPerQuest;
  final int fastestCompletionHours; // Fastest quest completion time
  final int slowestCompletionHours; // Slowest quest completion time
  final double averageProgressAtCompletion; // Average progress % when completed

  const CompletionPatterns({
    required this.patternsByType,
    required this.averageTasksPerQuest,
    required this.averageMilestonesPerQuest,
    required this.fastestCompletionHours,
    required this.slowestCompletionHours,
    required this.averageProgressAtCompletion,
  });

  @override
  List<Object?> get props => [
        patternsByType,
        averageTasksPerQuest,
        averageMilestonesPerQuest,
        fastestCompletionHours,
        slowestCompletionHours,
        averageProgressAtCompletion,
      ];
}

/// Pattern for a specific quest type
class TypePattern extends Equatable {
  final QuestType type;
  final int totalQuests;
  final double averageCompletionTimeHours;
  final double completionRate;
  final int averageXP;

  const TypePattern({
    required this.type,
    required this.totalQuests,
    required this.averageCompletionTimeHours,
    required this.completionRate,
    required this.averageXP,
  });

  @override
  List<Object?> get props => [
        type,
        totalQuests,
        averageCompletionTimeHours,
        completionRate,
        averageXP,
      ];
}

/// Difficulty analysis
class DifficultyAnalysis extends Equatable {
  final Map<int, DifficultyStats> statsByDifficulty; // 1-5
  final int preferredDifficulty; // Most completed difficulty
  final double averageDifficultyCompleted;
  final int hardestQuestCompleted; // Highest difficulty completed
  final double successRateByDifficulty; // Overall success rate

  const DifficultyAnalysis({
    required this.statsByDifficulty,
    required this.preferredDifficulty,
    required this.averageDifficultyCompleted,
    required this.hardestQuestCompleted,
    required this.successRateByDifficulty,
  });

  @override
  List<Object?> get props => [
        statsByDifficulty,
        preferredDifficulty,
        averageDifficultyCompleted,
        hardestQuestCompleted,
        successRateByDifficulty,
      ];
}

/// Statistics for a specific difficulty level
class DifficultyStats extends Equatable {
  final int difficulty;
  final int totalQuests;
  final int completedQuests;
  final double completionRate;
  final double averageCompletionTimeHours;

  const DifficultyStats({
    required this.difficulty,
    required this.totalQuests,
    required this.completedQuests,
    required this.completionRate,
    required this.averageCompletionTimeHours,
  });

  @override
  List<Object?> get props => [
        difficulty,
        totalQuests,
        completedQuests,
        completionRate,
        averageCompletionTimeHours,
      ];
}

