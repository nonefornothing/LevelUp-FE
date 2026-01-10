import '../../core/utils/result.dart';
import '../../core/utils/result_extensions.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/achievement_local_datasource.dart';

/// Achievement Repository Implementation (Data layer)
class AchievementRepositoryImpl implements AchievementRepository {
  final AchievementLocalDataSource _localDataSource;

  AchievementRepositoryImpl({required AchievementLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Result<List<Achievement>>> getAchievements() async {
    try {
      final achievements = await _localDataSource.getAllAchievements();
      return Success(achievements);
    } catch (e) {
      return ResultError(
        'Failed to get achievements: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Achievement>> getAchievementById(String id) async {
    try {
      final achievement = await _localDataSource.getAchievementById(id);
      if (achievement == null) return const ResultError('Achievement not found');
      return Success(achievement);
    } catch (e) {
      return ResultError(
        'Failed to get achievement: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<List<Achievement>>> getUnlockedAchievements() async {
    try {
      final all = await _localDataSource.getAllAchievements();
      final unlocked = all.where((a) => a.isUnlocked).toList();
      return Success(unlocked);
    } catch (e) {
      return ResultError(
        'Failed to get unlocked achievements: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<List<Achievement>>> getLockedAchievements() async {
    try {
      final all = await _localDataSource.getAllAchievements();
      final locked = all.where((a) => !a.isUnlocked).toList();
      return Success(locked);
    } catch (e) {
      return ResultError(
        'Failed to get locked achievements: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Achievement>> updateAchievement(Achievement achievement) async {
    try {
      await _localDataSource.upsertAchievement(achievement);
      return Success(achievement);
    } catch (e) {
      return ResultError(
        'Failed to update achievement: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Achievement>> unlockAchievement(String id) async {
    try {
      final achievementResult = await getAchievementById(id);
      return achievementResult.when(
        success: (achievement) async {
          final unlocked = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          await _localDataSource.upsertAchievement(unlocked);
          return Success(unlocked);
        },
        failure: (message, exception) async =>
            ResultError(message, exception: exception),
      );
    } catch (e) {
      return ResultError(
        'Failed to unlock achievement: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<List<Achievement>>> checkAndUnlockAchievements({
    required int questsCompleted,
    required int level,
    required int currentStreak,
    required int totalXP,
  }) async {
    // This method is handled by AchievementService
    // Repository just provides basic CRUD operations
    return const ResultError('Use AchievementService.checkAndUnlockAchievements instead');
  }
}





