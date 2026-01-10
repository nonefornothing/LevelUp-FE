import '../../core/utils/result.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/streak_repository.dart';

/// Service for managing streaks
class StreakService {
  final StreakRepository _streakRepository;

  StreakService({
    required StreakRepository streakRepository,
  }) : _streakRepository = streakRepository;

  /// Update streak when a quest is completed
  /// Returns the updated streak and whether it was a new record
  Future<Result<StreakUpdateResult>> updateStreakOnQuestCompletion({
    required QuestType questType,
    required DateTime completionDate,
  }) async {
    try {
      final now = DateTime.now();
      final completionDay = DateTime(
        completionDate.year,
        completionDate.month,
        completionDate.day,
      );

      // Determine which streaks to update
      final streaksToUpdate = <StreakType>[];

      // Always update quest completion streak
      streaksToUpdate.add(StreakType.questCompletion);

      // Update daily quest streak if it's a daily quest
      if (questType == QuestType.daily) {
        streaksToUpdate.add(StreakType.dailyQuest);
      }

      final updatedStreaks = <Streak>[];
      bool newRecord = false;

      for (final streakType in streaksToUpdate) {
        final streakResult = await _streakRepository.getStreakByType(streakType);
        Streak? streak;

        if (streakResult is Success<Streak?>) {
          streak = streakResult.data;
        }

        if (streak == null) {
          // Create new streak
          streak = Streak(
            id: IdGenerator.newId(),
            type: streakType,
            currentStreak: 1,
            longestStreak: 1,
            lastCompletedDate: completionDay,
            streakStartDate: completionDay,
            totalCompletions: 1,
            createdAt: now,
            updatedAt: now,
          );
        } else {
          // Update existing streak
          final lastDate = DateTime(
            streak.lastCompletedDate.year,
            streak.lastCompletedDate.month,
            streak.lastCompletedDate.day,
          );

          final daysDifference = completionDay.difference(lastDate).inDays;

          if (daysDifference == 0) {
            // Already completed today, just increment total
            streak = streak.copyWith(
              totalCompletions: streak.totalCompletions + 1,
              updatedAt: now,
            );
          } else if (daysDifference == 1) {
            // Consecutive day - continue streak
            final newStreak = streak.currentStreak + 1;
            final newLongest = newStreak > streak.longestStreak
                ? newStreak
                : streak.longestStreak;

            if (newStreak > streak.longestStreak) {
              newRecord = true;
            }

            streak = streak.copyWith(
              currentStreak: newStreak,
              longestStreak: newLongest,
              lastCompletedDate: completionDay,
              streakStartDate: streak.streakStartDate ?? completionDay,
              totalCompletions: streak.totalCompletions + 1,
              updatedAt: now,
            );
          } else {
            // Streak broken - start new streak
            streak = streak.copyWith(
              currentStreak: 1,
              lastCompletedDate: completionDay,
              streakStartDate: completionDay,
              totalCompletions: streak.totalCompletions + 1,
              updatedAt: now,
            );
          }
        }

        // Save streak
        final saveResult = await _streakRepository.saveStreak(streak);
        if (saveResult is Success<Streak>) {
          updatedStreaks.add(saveResult.data);
        }
      }

      return Success(StreakUpdateResult(
        streaks: updatedStreaks,
        newRecord: newRecord,
      ));
    } catch (e) {
      return ResultError('Failed to update streak: ${e.toString()}');
    }
  }

  /// Get streak by type
  Future<Result<Streak?>> getStreakByType(StreakType type) async {
    return await _streakRepository.getStreakByType(type);
  }

  /// Get all streaks
  Future<Result<List<Streak>>> getAllStreaks() async {
    return await _streakRepository.getAllStreaks();
  }

  /// Get streak statistics
  Future<Result<StreakStatistics>> getStreakStatistics() async {
    return await _streakRepository.getStreakStatistics();
  }

  /// Get current streak status message
  Future<Result<String>> getStreakStatusMessage(StreakType type) async {
    final streakResult = await _streakRepository.getStreakByType(type);
    if (streakResult is Success<Streak?>) {
      final streak = streakResult.data;
      if (streak == null) {
        return const Success('No streak yet. Complete a quest to start!');
      }
      return Success(streak.getStatusMessage(DateTime.now()));
    }
    return const Success('Unable to load streak status');
  }
}

/// Result of streak update operation
class StreakUpdateResult {
  final List<Streak> streaks;
  final bool newRecord;

  StreakUpdateResult({
    required this.streaks,
    required this.newRecord,
  });
}

