import '../../core/utils/result.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/weekly_challenge.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/weekly_challenge_repository.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/repositories/player_repository.dart';

/// Service for managing weekly challenges
class WeeklyChallengeService {
  final WeeklyChallengeRepository _challengeRepository;
  final PlayerRepository _playerRepository;

  WeeklyChallengeService({
    required WeeklyChallengeRepository challengeRepository,
    required QuestRepository questRepository,
    required PlayerRepository playerRepository,
  })  : _challengeRepository = challengeRepository,
        _playerRepository = playerRepository;

  /// Get active weekly challenges, generating new ones if needed
  Future<List<WeeklyChallenge>> getActiveWeeklyChallenges() async {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = _getWeekEnd(now);

    // Check if we need to generate new challenges
    final existingResult = await _challengeRepository.getActiveWeeklyChallenges();
    List<WeeklyChallenge> existingChallenges = [];
    if (existingResult is Success<List<WeeklyChallenge>>) {
      existingChallenges = existingResult.data;
    }

    // If no challenges exist for this week, generate them
    if (existingChallenges.isEmpty || 
        existingChallenges.any((c) => c.weekStartDate.isBefore(weekStart))) {
      await _generateWeeklyChallenges(weekStart, weekEnd);
      // Get the newly generated challenges
      final newResult = await _challengeRepository.getActiveWeeklyChallenges();
      if (newResult is Success<List<WeeklyChallenge>>) {
        return newResult.data;
      }
    }

    return existingChallenges;
  }

  /// Generate weekly challenges for a given week
  Future<void> _generateWeeklyChallenges(DateTime weekStart, DateTime weekEnd) async {
    // Get player for level-based rewards
    final playerResult = await _playerRepository.getPlayer();
    final player = playerResult is Success<Player> ? playerResult.data : null;
    final playerLevel = player?.level ?? 1;

    // Generate 3-5 challenges
    final challenges = <WeeklyChallenge>[];
    
    // Challenge 1: Complete X quests
    challenges.add(_createChallenge(
      type: WeeklyChallengeType.completeQuests,
      title: 'Quest Master',
      description: 'Complete quests this week',
      targetValue: 5 + (playerLevel ~/ 2), // Scale with level
      weekStart: weekStart,
      weekEnd: weekEnd,
      playerLevel: playerLevel,
    ));

    // Challenge 2: Complete X daily quests
    challenges.add(_createChallenge(
      type: WeeklyChallengeType.completeDailyQuests,
      title: 'Daily Dedication',
      description: 'Complete daily quests this week',
      targetValue: 7, // One per day
      weekStart: weekStart,
      weekEnd: weekEnd,
      playerLevel: playerLevel,
    ));

    // Challenge 3: Earn X XP
    challenges.add(_createChallenge(
      type: WeeklyChallengeType.earnXP,
      title: 'Experience Seeker',
      description: 'Earn experience points this week',
      targetValue: 500 * playerLevel, // Scale with level
      weekStart: weekStart,
      weekEnd: weekEnd,
      playerLevel: playerLevel,
    ));

    // Challenge 4: Level up (optional, only if player is not max level)
    if (playerLevel < 50) {
      challenges.add(_createChallenge(
        type: WeeklyChallengeType.levelUp,
        title: 'Level Up',
        description: 'Level up this week',
        targetValue: 1,
        weekStart: weekStart,
        weekEnd: weekEnd,
        playerLevel: playerLevel,
      ));
    }

    // Create challenges
    for (final challenge in challenges) {
      await _challengeRepository.createWeeklyChallenge(challenge);
    }
  }

  /// Create a weekly challenge
  WeeklyChallenge _createChallenge({
    required WeeklyChallengeType type,
    required String title,
    required String description,
    required int targetValue,
    required DateTime weekStart,
    required DateTime weekEnd,
    required int playerLevel,
  }) {
    // Calculate reward based on challenge type and player level
    int baseXP = 100;
    int baseCurrency = 50;

    switch (type) {
      case WeeklyChallengeType.completeQuests:
        baseXP = 200;
        baseCurrency = 100;
        break;
      case WeeklyChallengeType.completeDailyQuests:
        baseXP = 300;
        baseCurrency = 150;
        break;
      case WeeklyChallengeType.earnXP:
        baseXP = 150;
        baseCurrency = 75;
        break;
      case WeeklyChallengeType.levelUp:
        baseXP = 500;
        baseCurrency = 250;
        break;
    }

    return WeeklyChallenge(
      id: IdGenerator.newId(),
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      currentProgress: 0,
      reward: QuestReward(
        experience: baseXP * playerLevel,
        currency: baseCurrency * playerLevel,
      ),
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      status: WeeklyChallengeStatus.active,
      createdAt: DateTime.now(),
    );
  }

  /// Update challenge progress based on quest completion
  Future<void> onQuestCompleted(Quest quest) async {
    final challengesResult = await _challengeRepository.getActiveWeeklyChallenges();
    if (challengesResult is ResultError) return;

    final challenges = (challengesResult as Success<List<WeeklyChallenge>>).data;

    for (final challenge in challenges) {
      if (challenge.status != WeeklyChallengeStatus.active) continue;

      switch (challenge.type) {
        case WeeklyChallengeType.completeQuests:
          // Increment for any quest completion
          await _updateChallengeProgress(challenge.id, challenge.currentProgress + 1);
          break;
        case WeeklyChallengeType.completeDailyQuests:
          // Only increment for daily quests
          if (quest.type == QuestType.daily) {
            await _updateChallengeProgress(challenge.id, challenge.currentProgress + 1);
          }
          break;
        case WeeklyChallengeType.earnXP:
        case WeeklyChallengeType.levelUp:
          // These are handled separately
          break;
      }
    }
  }

  /// Update challenge progress based on XP earned
  Future<void> onXPEarned(int xpAmount) async {
    final challengesResult = await _challengeRepository.getActiveWeeklyChallenges();
    if (challengesResult is ResultError) return;

    final challenges = (challengesResult as Success<List<WeeklyChallenge>>).data;

    for (final challenge in challenges) {
      if (challenge.status != WeeklyChallengeStatus.active) continue;
      if (challenge.type == WeeklyChallengeType.earnXP) {
        await _updateChallengeProgress(
          challenge.id,
          challenge.currentProgress + xpAmount,
        );
      }
    }
  }

  /// Update challenge progress based on level up
  Future<void> onLevelUp() async {
    final challengesResult = await _challengeRepository.getActiveWeeklyChallenges();
    if (challengesResult is ResultError) return;

    final challenges = (challengesResult as Success<List<WeeklyChallenge>>).data;

    for (final challenge in challenges) {
      if (challenge.status != WeeklyChallengeStatus.active) continue;
      if (challenge.type == WeeklyChallengeType.levelUp) {
        await _updateChallengeProgress(challenge.id, challenge.currentProgress + 1);
      }
    }
  }

  /// Update challenge progress
  Future<void> _updateChallengeProgress(String challengeId, int newProgress) async {
    final result = await _challengeRepository.updateProgress(challengeId, newProgress);
    if (result is Success<WeeklyChallenge>) {
      final challenge = result.data;
      // If challenge is completed, we could trigger a notification here
      if (challenge.isCompleted) {
        // Challenge completed - could show notification
      }
    }
  }

  /// Get week start (Monday)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysFromMonday = weekday == 7 ? 6 : weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }

  /// Get week end (Sunday)
  DateTime _getWeekEnd(DateTime date) {
    final weekday = date.weekday;
    final daysToSunday = weekday == 7 ? 0 : 7 - weekday;
    return DateTime(date.year, date.month, date.day, 23, 59, 59).add(Duration(days: daysToSunday));
  }
}

