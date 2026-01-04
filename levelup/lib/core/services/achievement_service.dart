import '../../core/utils/result.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';

/// Service for managing predefined achievements and checking unlock conditions
class AchievementService {
  final AchievementRepository _achievementRepository;

  AchievementService({required AchievementRepository achievementRepository})
      : _achievementRepository = achievementRepository;

  /// Initialize all predefined achievements (call once on app startup)
  Future<Result<void>> initializeAchievements() async {
    try {
      final existingResult = await _achievementRepository.getAchievements();
      if (existingResult is Success<List<Achievement>>) {
        final existing = existingResult.data;
        // If achievements already exist, don't recreate them
        if (existing.isNotEmpty) {
          return const Success(null);
        }
      }

      // Create all predefined achievements
      final predefined = _getPredefinedAchievements();
      
      // Save all achievements
      for (final achievement in predefined) {
        await _achievementRepository.updateAchievement(achievement);
      }

      return const Success(null);
    } catch (e) {
      return ResultError(
        'Failed to initialize achievements: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Check and unlock achievements based on player stats
  Future<Result<List<Achievement>>> checkAndUnlockAchievements({
    required int questsCompleted,
    required int level,
    required int currentStreak,
    required int totalXP,
  }) async {
    try {
      final allResult = await _achievementRepository.getAchievements();
      if (allResult is! Success<List<Achievement>>) {
        return ResultError('Failed to get achievements');
      }

      final allAchievements = allResult.data;
      final newlyUnlocked = <Achievement>[];

      for (final achievement in allAchievements) {
        if (achievement.isUnlocked) continue;

        bool shouldUnlock = false;
        int newProgress = achievement.currentProgress;

        switch (achievement.type) {
          case AchievementType.firstQuest:
            if (questsCompleted >= 1) {
              shouldUnlock = true;
              newProgress = 1;
            }
            break;

          case AchievementType.questMilestone:
            if (questsCompleted >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = questsCompleted;
            } else {
              newProgress = questsCompleted;
            }
            break;

          case AchievementType.levelMilestone:
            if (level >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = level;
            } else {
              newProgress = level;
            }
            break;

          case AchievementType.dailyStreak:
            if (currentStreak >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = currentStreak;
            } else {
              newProgress = currentStreak;
            }
            break;

          case AchievementType.totalXP:
            if (totalXP >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = totalXP;
            } else {
              newProgress = totalXP;
            }
            break;

          case AchievementType.perfectWeek:
            // This will need special handling based on weekly quest completion
            // For now, skip
            break;
        }

        if (shouldUnlock && !achievement.isUnlocked) {
          // Unlock the achievement with updated progress
          final unlocked = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            currentProgress: newProgress,
          );
          await _achievementRepository.updateAchievement(unlocked);
          newlyUnlocked.add(unlocked);
        } else if (newProgress != achievement.currentProgress) {
          // Update progress even if not unlocked
          final updated = achievement.copyWith(currentProgress: newProgress);
          await _achievementRepository.updateAchievement(updated);
        }
      }

      return Success(newlyUnlocked);
    } catch (e) {
      return ResultError(
        'Failed to check achievements: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get all predefined achievements
  List<Achievement> _getPredefinedAchievements() {
    return [
      // First Quest
      Achievement(
        id: 'first_quest',
        title: 'First Steps',
        description: 'Complete your first quest',
        type: AchievementType.firstQuest,
        tier: AchievementTier.bronze,
        targetValue: 1,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'first_quest',
      ),

      // Quest Milestones
      Achievement(
        id: 'quest_10',
        title: 'Quest Novice',
        description: 'Complete 10 quests',
        type: AchievementType.questMilestone,
        tier: AchievementTier.bronze,
        targetValue: 10,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'quest_10',
      ),
      Achievement(
        id: 'quest_50',
        title: 'Quest Master',
        description: 'Complete 50 quests',
        type: AchievementType.questMilestone,
        tier: AchievementTier.silver,
        targetValue: 50,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'quest_50',
      ),
      Achievement(
        id: 'quest_100',
        title: 'Quest Legend',
        description: 'Complete 100 quests',
        type: AchievementType.questMilestone,
        tier: AchievementTier.gold,
        targetValue: 100,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'quest_100',
      ),

      // Level Milestones
      Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reach level 5',
        type: AchievementType.levelMilestone,
        tier: AchievementTier.bronze,
        targetValue: 5,
        currentProgress: 1,
        isUnlocked: false,
        iconName: 'level_5',
      ),
      Achievement(
        id: 'level_10',
        title: 'Level Up',
        description: 'Reach level 10',
        type: AchievementType.levelMilestone,
        tier: AchievementTier.silver,
        targetValue: 10,
        currentProgress: 1,
        isUnlocked: false,
        iconName: 'level_10',
      ),
      Achievement(
        id: 'level_20',
        title: 'Master',
        description: 'Reach level 20',
        type: AchievementType.levelMilestone,
        tier: AchievementTier.gold,
        targetValue: 20,
        currentProgress: 1,
        isUnlocked: false,
        iconName: 'level_20',
      ),
      Achievement(
        id: 'level_50',
        title: 'Grand Master',
        description: 'Reach level 50',
        type: AchievementType.levelMilestone,
        tier: AchievementTier.platinum,
        targetValue: 50,
        currentProgress: 1,
        isUnlocked: false,
        iconName: 'level_50',
      ),

      // Daily Streak
      Achievement(
        id: 'streak_7',
        title: 'Hot Streak',
        description: 'Complete daily quests for 7 days',
        type: AchievementType.dailyStreak,
        tier: AchievementTier.bronze,
        targetValue: 7,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'streak_7',
      ),
      Achievement(
        id: 'streak_30',
        title: 'Dedicated',
        description: 'Complete daily quests for 30 days',
        type: AchievementType.dailyStreak,
        tier: AchievementTier.silver,
        targetValue: 30,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'streak_30',
      ),
      Achievement(
        id: 'streak_100',
        title: 'Unstoppable',
        description: 'Complete daily quests for 100 days',
        type: AchievementType.dailyStreak,
        tier: AchievementTier.gold,
        targetValue: 100,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'streak_100',
      ),

      // Total XP
      Achievement(
        id: 'xp_1000',
        title: 'XP Collector',
        description: 'Earn 1,000 XP',
        type: AchievementType.totalXP,
        tier: AchievementTier.bronze,
        targetValue: 1000,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'xp_1000',
      ),
      Achievement(
        id: 'xp_10000',
        title: 'XP Expert',
        description: 'Earn 10,000 XP',
        type: AchievementType.totalXP,
        tier: AchievementTier.silver,
        targetValue: 10000,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'xp_10000',
      ),
      Achievement(
        id: 'xp_50000',
        title: 'XP Legend',
        description: 'Earn 50,000 XP',
        type: AchievementType.totalXP,
        tier: AchievementTier.gold,
        targetValue: 50000,
        currentProgress: 0,
        isUnlocked: false,
        iconName: 'xp_50000',
      ),
    ];
  }
}

