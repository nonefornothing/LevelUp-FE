import '../../core/utils/result.dart';
import '../entities/streak.dart';

/// Repository interface for streak operations
abstract class StreakRepository {
  /// Get streak by type
  Future<Result<Streak?>> getStreakByType(StreakType type);

  /// Get all streaks
  Future<Result<List<Streak>>> getAllStreaks();

  /// Save or update a streak
  Future<Result<Streak>> saveStreak(Streak streak);

  /// Delete a streak
  Future<Result<void>> deleteStreak(String id);

  /// Get streak statistics
  Future<Result<StreakStatistics>> getStreakStatistics();
}

/// Streak statistics summary
class StreakStatistics {
  final int totalActiveStreaks;
  final int totalBrokenStreaks;
  final int longestOverallStreak;
  final int totalDaysStreaked;
  final Map<StreakType, Streak> streaksByType;

  const StreakStatistics({
    required this.totalActiveStreaks,
    required this.totalBrokenStreaks,
    required this.longestOverallStreak,
    required this.totalDaysStreaked,
    required this.streaksByType,
  });
}



