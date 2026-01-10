import '../../core/utils/result.dart';
import '../entities/weekly_challenge.dart';

/// Weekly Challenge Repository Interface (Domain layer)
abstract class WeeklyChallengeRepository {
  /// Get all weekly challenges
  Future<Result<List<WeeklyChallenge>>> getWeeklyChallenges();

  /// Get active weekly challenges (for current week)
  Future<Result<List<WeeklyChallenge>>> getActiveWeeklyChallenges();

  /// Get weekly challenge by ID
  Future<Result<WeeklyChallenge>> getWeeklyChallengeById(String id);

  /// Create new weekly challenge
  Future<Result<WeeklyChallenge>> createWeeklyChallenge(WeeklyChallenge challenge);

  /// Update weekly challenge
  Future<Result<WeeklyChallenge>> updateWeeklyChallenge(WeeklyChallenge challenge);

  /// Delete weekly challenge
  Future<Result<void>> deleteWeeklyChallenge(String id);

  /// Update challenge progress
  Future<Result<WeeklyChallenge>> updateProgress(String challengeId, int progress);

  /// Complete challenge
  Future<Result<WeeklyChallenge>> completeChallenge(String challengeId);
}




