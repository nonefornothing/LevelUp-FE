import 'package:equatable/equatable.dart';

/// Streak entity representing a consecutive completion streak
class Streak extends Equatable {
  final String id;
  final StreakType type;
  final int currentStreak; // Current consecutive days/weeks
  final int longestStreak; // Longest streak ever achieved
  final DateTime lastCompletedDate; // Last date when streak was maintained
  final DateTime? streakStartDate; // When current streak started
  final int totalCompletions; // Total number of completions (not necessarily consecutive)
  final DateTime createdAt;
  final DateTime updatedAt;

  const Streak({
    required this.id,
    required this.type,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCompletedDate,
    this.streakStartDate,
    required this.totalCompletions,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if streak is active (completed today)
  bool isActive(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastCompletedDate.year,
      lastCompletedDate.month,
      lastCompletedDate.day,
    );
    return today.isAtSameMomentAs(lastDate);
  }

  /// Check if streak is broken (last completion was more than 1 day ago)
  bool isBroken(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastCompletedDate.year,
      lastCompletedDate.month,
      lastCompletedDate.day,
    );
    final daysDifference = today.difference(lastDate).inDays;
    return daysDifference > 1;
  }

  /// Get days until streak breaks (0 if already broken, 1 if today, >1 if future)
  int getDaysUntilBreak(DateTime now) {
    if (isBroken(now)) return 0;
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastCompletedDate.year,
      lastCompletedDate.month,
      lastCompletedDate.day,
    );
    final daysDifference = today.difference(lastDate).inDays;
    return 1 - daysDifference; // 1 if today, 0 if tomorrow
  }

  /// Get streak status message
  String getStatusMessage(DateTime now) {
    if (isActive(now)) {
      return 'Active • $currentStreak day${currentStreak != 1 ? 's' : ''}';
    } else if (isBroken(now)) {
      return 'Broken • Start a new streak!';
    } else {
      return 'Continue your streak today!';
    }
  }

  Streak copyWith({
    String? id,
    StreakType? type,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    DateTime? streakStartDate,
    int? totalCompletions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Streak(
      id: id ?? this.id,
      type: type ?? this.type,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        currentStreak,
        longestStreak,
        lastCompletedDate,
        streakStartDate,
        totalCompletions,
        createdAt,
        updatedAt,
      ];
}

/// Types of streaks that can be tracked
enum StreakType {
  dailyQuest, // Consecutive days completing at least one daily quest
  questCompletion, // Consecutive days completing any quest
  weeklyChallenge, // Consecutive weeks completing weekly challenges
}



