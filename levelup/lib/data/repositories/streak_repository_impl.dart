import '../../core/utils/result.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/streak_repository.dart';
import '../datasources/streak_local_datasource.dart';

/// Implementation of StreakRepository using local data source
class StreakRepositoryImpl implements StreakRepository {
  final StreakLocalDataSource _localDataSource;

  StreakRepositoryImpl({
    required StreakLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Result<Streak?>> getStreakByType(StreakType type) async {
    try {
      final streak = _localDataSource.getStreakByType(type);
      return Success(streak);
    } catch (e) {
      return ResultError('Failed to get streak: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Streak>>> getAllStreaks() async {
    try {
      final streaks = _localDataSource.getAllStreaks();
      return Success(streaks);
    } catch (e) {
      return ResultError('Failed to get streaks: ${e.toString()}');
    }
  }

  @override
  Future<Result<Streak>> saveStreak(Streak streak) async {
    try {
      await _localDataSource.saveStreak(streak);
      return Success(streak);
    } catch (e) {
      return ResultError('Failed to save streak: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteStreak(String id) async {
    try {
      await _localDataSource.deleteStreak(id);
      return Success(null);
    } catch (e) {
      return ResultError('Failed to delete streak: ${e.toString()}');
    }
  }

  @override
  Future<Result<StreakStatistics>> getStreakStatistics() async {
    try {
      final allStreaks = _localDataSource.getAllStreaks();
      final now = DateTime.now();

      int activeCount = 0;
      int brokenCount = 0;
      int longestOverall = 0;
      int totalDays = 0;
      final streaksByType = <StreakType, Streak>{};

      for (final streak in allStreaks) {
        streaksByType[streak.type] = streak;

        if (streak.isActive(now)) {
          activeCount++;
        } else if (streak.isBroken(now)) {
          brokenCount++;
        }

        if (streak.longestStreak > longestOverall) {
          longestOverall = streak.longestStreak;
        }

        totalDays += streak.totalCompletions;
      }

      return Success(StreakStatistics(
        totalActiveStreaks: activeCount,
        totalBrokenStreaks: brokenCount,
        longestOverallStreak: longestOverall,
        totalDaysStreaked: totalDays,
        streaksByType: streaksByType,
      ));
    } catch (e) {
      return ResultError('Failed to get streak statistics: ${e.toString()}');
    }
  }
}



