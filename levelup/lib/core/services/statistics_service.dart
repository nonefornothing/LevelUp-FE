import '../../domain/entities/player.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/statistics.dart';

/// Service for calculating statistics
class StatisticsService {
  /// Calculate statistics from player and quest data
  static Statistics calculateStatistics({
    required Player player,
    required List<Quest> allQuests,
  }) {
    final completedQuests = allQuests.where((q) => q.status == QuestStatus.completed).toList();
    final totalQuestsCreated = allQuests.length;
    final totalQuestsCompleted = completedQuests.length;
    final questCompletionRate = totalQuestsCreated > 0
        ? (totalQuestsCompleted / totalQuestsCreated * 100).clamp(0.0, 100.0)
        : 0.0;

    // Calculate total XP and Currency earned
    int totalXP = 0;
    int totalCurrency = 0;
    for (final quest in completedQuests) {
      totalXP += quest.reward.experience;
      totalCurrency += quest.reward.currency;
    }

    // Quest breakdown by type
    final questsByType = <QuestType, int>{};
    for (final questType in QuestType.values) {
      questsByType[questType] = completedQuests.where((q) => q.type == questType).length;
    }

    // Quest breakdown by category
    final questsByCategory = <QuestCategory, int>{};
    for (final category in QuestCategory.values) {
      questsByCategory[category] = completedQuests.where((q) => q.category == category).length;
    }

    // Daily activity (last 7 days)
    final dailyActivity = _calculateDailyActivity(completedQuests);

    return Statistics(
      totalQuestsCompleted: totalQuestsCompleted,
      totalQuestsCreated: totalQuestsCreated,
      questCompletionRate: questCompletionRate,
      totalXPEarned: totalXP,
      totalCurrencyEarned: totalCurrency,
      questsByType: questsByType,
      questsByCategory: questsByCategory,
      dailyActivity: dailyActivity,
      currentLevel: player.level,
      totalLevelsGained: player.level - 1, // Assuming starting level is 1
    );
  }

  /// Calculate daily activity for the last 7 days
  static List<DailyActivity> _calculateDailyActivity(List<Quest> completedQuests) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: index));
      return date;
    }).reversed.toList();

    final dailyMap = <DateTime, DailyActivity>{};

    // Initialize all days with zero activity
    for (final date in last7Days) {
      dailyMap[date] = DailyActivity(
        date: date,
        questsCompleted: 0,
        xpEarned: 0,
        currencyEarned: 0,
      );
    }

    // Group completed quests by date
    for (final quest in completedQuests) {
      if (quest.completedAt != null) {
        final completedDate = DateTime(
          quest.completedAt!.year,
          quest.completedAt!.month,
          quest.completedAt!.day,
        );

        // Only include if within last 7 days
        if (completedDate.isAfter(last7Days.first.subtract(const Duration(days: 1))) &&
            completedDate.isBefore(now.add(const Duration(days: 1)))) {
          final existing = dailyMap[completedDate];
          if (existing != null) {
            dailyMap[completedDate] = DailyActivity(
              date: completedDate,
              questsCompleted: existing.questsCompleted + 1,
              xpEarned: existing.xpEarned + quest.reward.experience,
              currencyEarned: existing.currencyEarned + quest.reward.currency,
            );
          }
        }
      }
    }

    return dailyMap.values.toList();
  }
}
