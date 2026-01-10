import '../../domain/entities/analytics.dart';
import '../../domain/entities/quest.dart';

/// Service for calculating advanced quest analytics and insights
class AnalyticsService {
  /// Calculate comprehensive analytics from quest data
  static QuestAnalytics calculateAnalytics({
    required List<Quest> allQuests,
  }) {
    final completedQuests = allQuests
        .where((q) => q.status == QuestStatus.completed && q.completedAt != null)
        .toList();

    return QuestAnalytics(
      productivityInsights: _calculateProductivityInsights(completedQuests),
      categoryPerformance: _calculateCategoryPerformance(allQuests, completedQuests),
      timeBasedAnalytics: _calculateTimeBasedAnalytics(completedQuests),
      completionPatterns: _calculateCompletionPatterns(allQuests, completedQuests),
      difficultyAnalysis: _calculateDifficultyAnalysis(allQuests, completedQuests),
      generatedAt: DateTime.now(),
    );
  }

  /// Calculate productivity insights
  static ProductivityInsights _calculateProductivityInsights(List<Quest> completedQuests) {
    if (completedQuests.isEmpty) {
      return ProductivityInsights(
        bestDayOfWeek: 'N/A',
        bestHourOfDay: 12,
        averageQuestsPerDay: 0.0,
        mostProductiveDayCount: 0,
        mostProductiveMonth: 'N/A',
        completionRate: 0.0,
        averageCompletionTimeHours: 0.0,
      );
    }

    // Analyze by day of week
    final dayCounts = <String, int>{};
    final hourCounts = <int, int>{};
    final monthCounts = <String, int>{};
    final completionTimes = <int>[];

    for (final quest in completedQuests) {
      if (quest.completedAt != null) {
        final date = quest.completedAt!;
        final dayName = _getDayName(date.weekday);
        dayCounts[dayName] = (dayCounts[dayName] ?? 0) + 1;
        hourCounts[date.hour] = (hourCounts[date.hour] ?? 0) + 1;

        final monthName = _getMonthName(date.month);
        monthCounts[monthName] = (monthCounts[monthName] ?? 0) + 1;

        // Calculate completion time
        final duration = quest.completedAt!.difference(quest.createdAt);
        completionTimes.add(duration.inHours);
      }
    }

    final bestDay = dayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final bestHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final bestMonth = monthCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Group by date to calculate average per day
    final questsByDate = <DateTime, int>{};
    for (final quest in completedQuests) {
      if (quest.completedAt != null) {
        final date = DateTime(
          quest.completedAt!.year,
          quest.completedAt!.month,
          quest.completedAt!.day,
        );
        questsByDate[date] = (questsByDate[date] ?? 0) + 1;
      }
    }

    final averageQuestsPerDay = questsByDate.isNotEmpty
        ? completedQuests.length / questsByDate.length
        : 0.0;

    final averageCompletionTime = completionTimes.isNotEmpty
        ? completionTimes.reduce((a, b) => a + b) / completionTimes.length
        : 0.0;

    return ProductivityInsights(
      bestDayOfWeek: bestDay,
      bestHourOfDay: bestHour,
      averageQuestsPerDay: averageQuestsPerDay,
      mostProductiveDayCount: dayCounts.values.reduce((a, b) => a > b ? a : b),
      mostProductiveMonth: bestMonth,
      completionRate: 100.0, // All are completed
      averageCompletionTimeHours: averageCompletionTime,
    );
  }

  /// Calculate category performance
  static CategoryPerformance _calculateCategoryPerformance(
    List<Quest> allQuests,
    List<Quest> completedQuests,
  ) {
    final statsByCategory = <QuestCategory, CategoryStats>{};
    final categoryCompletions = <QuestCategory, int>{};
    final categoryTotal = <QuestCategory, int>{};
    final categoryXP = <QuestCategory, int>{};
    final categoryDifficulties = <QuestCategory, List<int>>{};
    final categoryTimes = <QuestCategory, List<int>>{};

    // Initialize
    for (final category in QuestCategory.values) {
      categoryCompletions[category] = 0;
      categoryTotal[category] = 0;
      categoryXP[category] = 0;
      categoryDifficulties[category] = [];
      categoryTimes[category] = [];
    }

    // Process all quests
    for (final quest in allQuests) {
      categoryTotal[quest.category] = (categoryTotal[quest.category] ?? 0) + 1;
    }

    // Process completed quests
    for (final quest in completedQuests) {
      categoryCompletions[quest.category] =
          (categoryCompletions[quest.category] ?? 0) + 1;
      categoryXP[quest.category] =
          (categoryXP[quest.category] ?? 0) + quest.reward.experience;
      categoryDifficulties[quest.category]?.add(quest.difficulty);

      final duration = quest.completedAt!.difference(quest.createdAt);
      categoryTimes[quest.category]?.add(duration.inHours);
    }

    // Build stats
    for (final category in QuestCategory.values) {
      final total = categoryTotal[category] ?? 0;
      final completed = categoryCompletions[category] ?? 0;
      final completionRate = total > 0 ? (completed / total * 100) : 0.0;
      final avgDifficulty = categoryDifficulties[category]?.isNotEmpty == true
          ? ((categoryDifficulties[category]!.reduce((a, b) => a + b) /
              categoryDifficulties[category]!.length)
              .round())
          : 0;
      final avgTime = categoryTimes[category]?.isNotEmpty == true
          ? (categoryTimes[category]!.reduce((a, b) => a + b) /
              categoryTimes[category]!.length)
          : 0.0;

      statsByCategory[category] = CategoryStats(
        category: category,
        totalQuests: total,
        completedQuests: completed,
        completionRate: completionRate,
        totalXP: categoryXP[category] ?? 0,
        averageDifficulty: avgDifficulty,
        averageCompletionTimeHours: avgTime,
      );
    }

    // Find best and worst categories
    QuestCategory? bestCategory;
    QuestCategory? needsImprovement;
    double bestRate = 0.0;
    double worstRate = 100.0;

    for (final entry in statsByCategory.entries) {
      if (entry.value.totalQuests > 0) {
        if (entry.value.completionRate > bestRate) {
          bestRate = entry.value.completionRate;
          bestCategory = entry.key;
        }
        if (entry.value.completionRate < worstRate && entry.value.totalQuests >= 3) {
          worstRate = entry.value.completionRate;
          needsImprovement = entry.key;
        }
      }
    }

    return CategoryPerformance(
      statsByCategory: statsByCategory,
      bestCategory: bestCategory,
      needsImprovement: needsImprovement,
    );
  }

  /// Calculate time-based analytics
  static TimeBasedAnalytics _calculateTimeBasedAnalytics(List<Quest> completedQuests) {
    final now = DateTime.now();
    final weeklyTrends = <WeeklyTrend>[];
    final monthlyTrends = <MonthlyTrend>[];

    // Calculate weekly trends (last 12 weeks)
    for (int i = 11; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weekQuests = completedQuests.where((q) {
        if (q.completedAt == null) return false;
        return q.completedAt!.isAfter(weekStart) && q.completedAt!.isBefore(weekEnd);
      }).toList();

      final weekXP = weekQuests.fold(0, (sum, q) => sum + q.reward.experience);
      final completionRate = weekQuests.isNotEmpty ? 100.0 : 0.0;

      weeklyTrends.add(WeeklyTrend(
        weekStart: weekStart,
        questsCompleted: weekQuests.length,
        xpEarned: weekXP,
        completionRate: completionRate,
      ));
    }

    // Calculate monthly trends (last 12 months)
    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(monthDate.year, monthDate.month + 1, 1);

      final monthQuests = completedQuests.where((q) {
        if (q.completedAt == null) return false;
        return q.completedAt!.isAfter(monthDate) && q.completedAt!.isBefore(nextMonth);
      }).toList();

      final monthXP = monthQuests.fold(0, (sum, q) => sum + q.reward.experience);
      final completionRate = monthQuests.isNotEmpty ? 100.0 : 0.0;

      monthlyTrends.add(MonthlyTrend(
        year: monthDate.year,
        month: monthDate.month,
        questsCompleted: monthQuests.length,
        xpEarned: monthXP,
        completionRate: completionRate,
      ));
    }

    // Determine overall trend
    final trend = _calculateTrend(weeklyTrends);

    return TimeBasedAnalytics(
      weeklyTrends: weeklyTrends,
      monthlyTrends: monthlyTrends,
      overallTrend: trend,
    );
  }

  /// Calculate completion patterns
  static CompletionPatterns _calculateCompletionPatterns(
    List<Quest> allQuests,
    List<Quest> completedQuests,
  ) {
    final patternsByType = <QuestType, TypePattern>{};
    final typeCompletions = <QuestType, List<Quest>>{};
    final typeTimes = <QuestType, List<int>>{};

    // Group by type
    for (final quest in completedQuests) {
      typeCompletions.putIfAbsent(quest.type, () => []).add(quest);
      final duration = quest.completedAt!.difference(quest.createdAt);
      typeTimes.putIfAbsent(quest.type, () => []).add(duration.inHours);
    }

    // Build patterns
    for (final type in QuestType.values) {
      final typeQuests = allQuests.where((q) => q.type == type).toList();
      final completed = typeCompletions[type] ?? [];
      final avgTime = typeTimes[type]?.isNotEmpty == true
          ? (typeTimes[type]!.reduce((a, b) => a + b) / typeTimes[type]!.length)
          : 0.0;
      final completionRate = typeQuests.isNotEmpty
          ? (completed.length / typeQuests.length * 100)
          : 0.0;
      final avgXP = completed.isNotEmpty
          ? (completed.fold(0, (sum, q) => sum + q.reward.experience) / completed.length)
              .round()
          : 0;

      patternsByType[type] = TypePattern(
        type: type,
        totalQuests: typeQuests.length,
        averageCompletionTimeHours: avgTime,
        completionRate: completionRate,
        averageXP: avgXP,
      );
    }

    // Calculate averages
    final totalTasks = allQuests.fold(0, (sum, q) => sum + q.tasks.length);
    final totalMilestones = allQuests.fold(0, (sum, q) => sum + q.milestones.length);
    final avgTasks = allQuests.isNotEmpty ? totalTasks / allQuests.length : 0.0;
    final avgMilestones = allQuests.isNotEmpty ? totalMilestones / allQuests.length : 0.0;

    final completionTimes = completedQuests
        .where((q) => q.createdAt != null && q.completedAt != null)
        .map((q) => q.completedAt!.difference(q.createdAt).inHours)
        .toList();

    final fastest = completionTimes.isNotEmpty ? completionTimes.reduce((a, b) => a < b ? a : b) : 0;
    final slowest = completionTimes.isNotEmpty ? completionTimes.reduce((a, b) => a > b ? a : b) : 0;

    return CompletionPatterns(
      patternsByType: patternsByType,
      averageTasksPerQuest: avgTasks,
      averageMilestonesPerQuest: avgMilestones,
      fastestCompletionHours: fastest,
      slowestCompletionHours: slowest,
      averageProgressAtCompletion: 100.0, // Completed quests are 100%
    );
  }

  /// Calculate difficulty analysis
  static DifficultyAnalysis _calculateDifficultyAnalysis(
    List<Quest> allQuests,
    List<Quest> completedQuests,
  ) {
    final statsByDifficulty = <int, DifficultyStats>{};
    final difficultyCompletions = <int, int>{};
    final difficultyTotal = <int, int>{};
    final difficultyTimes = <int, List<int>>{};

    // Initialize
    for (int i = 1; i <= 5; i++) {
      difficultyCompletions[i] = 0;
      difficultyTotal[i] = 0;
      difficultyTimes[i] = [];
    }

    // Process all quests
    for (final quest in allQuests) {
      difficultyTotal[quest.difficulty] = (difficultyTotal[quest.difficulty] ?? 0) + 1;
    }

    // Process completed quests
    for (final quest in completedQuests) {
      difficultyCompletions[quest.difficulty] =
          (difficultyCompletions[quest.difficulty] ?? 0) + 1;
      final duration = quest.completedAt!.difference(quest.createdAt);
      difficultyTimes[quest.difficulty]?.add(duration.inHours);
    }

    // Build stats
    for (int i = 1; i <= 5; i++) {
      final total = difficultyTotal[i] ?? 0;
      final completed = difficultyCompletions[i] ?? 0;
      final completionRate = total > 0 ? (completed / total * 100) : 0.0;
      final avgTime = difficultyTimes[i]?.isNotEmpty == true
          ? (difficultyTimes[i]!.reduce((a, b) => a + b) / difficultyTimes[i]!.length)
          : 0.0;

      statsByDifficulty[i] = DifficultyStats(
        difficulty: i,
        totalQuests: total,
        completedQuests: completed,
        completionRate: completionRate,
        averageCompletionTimeHours: avgTime,
      );
    }

    // Find preferred difficulty (most completed)
    int preferredDifficulty = 1;
    int maxCompleted = 0;
    for (int i = 1; i <= 5; i++) {
      final completed = difficultyCompletions[i] ?? 0;
      if (completed > maxCompleted) {
        maxCompleted = completed;
        preferredDifficulty = i;
      }
    }

    // Calculate average difficulty completed
    final totalCompleted = completedQuests.length;
    final avgDifficulty = totalCompleted > 0
        ? (completedQuests.fold(0, (sum, q) => sum + q.difficulty) / totalCompleted)
        : 0.0;

    // Find hardest quest completed
    final hardest = completedQuests.isNotEmpty
        ? completedQuests.map((q) => q.difficulty).reduce((a, b) => a > b ? a : b)
        : 0;

    // Overall success rate
    final totalQuests = allQuests.length;
    final successRate = totalQuests > 0 ? (totalCompleted / totalQuests * 100) : 0.0;

    return DifficultyAnalysis(
      statsByDifficulty: statsByDifficulty,
      preferredDifficulty: preferredDifficulty,
      averageDifficultyCompleted: avgDifficulty,
      hardestQuestCompleted: hardest,
      successRateByDifficulty: successRate,
    );
  }

  /// Calculate trend direction
  static TrendDirection _calculateTrend(List<WeeklyTrend> trends) {
    if (trends.length < 2) return TrendDirection.stable;

    final recent = trends.sublist(trends.length - 4);
    final older = trends.sublist(0, trends.length - 4);

    if (recent.isEmpty || older.isEmpty) return TrendDirection.stable;

    final recentAvg = recent.fold(0, (sum, t) => sum + t.questsCompleted) / recent.length;
    final olderAvg = older.fold(0, (sum, t) => sum + t.questsCompleted) / older.length;

    if (recentAvg > olderAvg * 1.1) return TrendDirection.improving;
    if (recentAvg < olderAvg * 0.9) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  /// Helper: Get day name
  static String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  /// Helper: Get month name
  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

