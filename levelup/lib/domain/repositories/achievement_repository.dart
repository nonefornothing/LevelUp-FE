import '../../core/utils/result.dart';
import '../entities/achievement.dart';

/// Achievement Repository Interface (Domain layer)
abstract class AchievementRepository {
  /// Get all achievements
  Future<Result<List<Achievement>>> getAchievements();

  /// Get achievement by ID
  Future<Result<Achievement>> getAchievementById(String id);

  /// Get unlocked achievements
  Future<Result<List<Achievement>>> getUnlockedAchievements();

  /// Get locked achievements
  Future<Result<List<Achievement>>> getLockedAchievements();

  /// Update achievement progress
  Future<Result<Achievement>> updateAchievement(Achievement achievement);

  /// Unlock achievement
  Future<Result<Achievement>> unlockAchievement(String id);

  /// Check and unlock achievements based on player stats
  Future<Result<List<Achievement>>> checkAndUnlockAchievements({
    required int questsCompleted,
    required int level,
    required int currentStreak,
    required int totalXP,
  });
}

