import '../../core/utils/result.dart';
import '../../domain/entities/weekly_challenge.dart';
import '../../domain/repositories/weekly_challenge_repository.dart';
import '../datasources/weekly_challenge_local_datasource.dart';

/// Implementation of WeeklyChallengeRepository
class WeeklyChallengeRepositoryImpl implements WeeklyChallengeRepository {
  final WeeklyChallengeLocalDataSource _dataSource;

  WeeklyChallengeRepositoryImpl({
    required WeeklyChallengeLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<WeeklyChallenge>>> getWeeklyChallenges() async {
    try {
      final challenges = _dataSource.getAllWeeklyChallenges();
      return Success(challenges);
    } catch (e) {
      return ResultError('Failed to get weekly challenges: $e');
    }
  }

  @override
  Future<Result<List<WeeklyChallenge>>> getActiveWeeklyChallenges() async {
    try {
      final challenges = _dataSource.getActiveWeeklyChallenges();
      return Success(challenges);
    } catch (e) {
      return ResultError('Failed to get active weekly challenges: $e');
    }
  }

  @override
  Future<Result<WeeklyChallenge>> getWeeklyChallengeById(String id) async {
    try {
      final challenge = _dataSource.getWeeklyChallengeById(id);
      if (challenge == null) {
        return ResultError('Weekly challenge not found: $id');
      }
      return Success(challenge);
    } catch (e) {
      return ResultError('Failed to get weekly challenge: $e');
    }
  }

  @override
  Future<Result<WeeklyChallenge>> createWeeklyChallenge(WeeklyChallenge challenge) async {
    try {
      await _dataSource.createWeeklyChallenge(challenge);
      return Success(challenge);
    } catch (e) {
      return ResultError('Failed to create weekly challenge: $e');
    }
  }

  @override
  Future<Result<WeeklyChallenge>> updateWeeklyChallenge(WeeklyChallenge challenge) async {
    try {
      await _dataSource.updateWeeklyChallenge(challenge);
      return Success(challenge);
    } catch (e) {
      return ResultError('Failed to update weekly challenge: $e');
    }
  }

  @override
  Future<Result<void>> deleteWeeklyChallenge(String id) async {
    try {
      await _dataSource.deleteWeeklyChallenge(id);
      return Success(null);
    } catch (e) {
      return ResultError('Failed to delete weekly challenge: $e');
    }
  }

  @override
  Future<Result<WeeklyChallenge>> updateProgress(String challengeId, int progress) async {
    try {
      final challengeResult = await getWeeklyChallengeById(challengeId);
      if (challengeResult is ResultError) {
        return challengeResult;
      }

      final challenge = (challengeResult as Success<WeeklyChallenge>).data;
      final updatedChallenge = challenge.copyWith(
        currentProgress: progress.clamp(0, challenge.targetValue),
        status: progress >= challenge.targetValue
            ? WeeklyChallengeStatus.completed
            : WeeklyChallengeStatus.active,
        completedAt: progress >= challenge.targetValue ? DateTime.now() : challenge.completedAt,
      );

      await _dataSource.updateWeeklyChallenge(updatedChallenge);
      return Success(updatedChallenge);
    } catch (e) {
      return ResultError('Failed to update progress: $e');
    }
  }

  @override
  Future<Result<WeeklyChallenge>> completeChallenge(String challengeId) async {
    try {
      final challengeResult = await getWeeklyChallengeById(challengeId);
      if (challengeResult is ResultError) {
        return challengeResult;
      }

      final challenge = (challengeResult as Success<WeeklyChallenge>).data;
      final completedChallenge = challenge.copyWith(
        currentProgress: challenge.targetValue,
        status: WeeklyChallengeStatus.completed,
        completedAt: DateTime.now(),
      );

      await _dataSource.updateWeeklyChallenge(completedChallenge);
      return Success(completedChallenge);
    } catch (e) {
      return ResultError('Failed to complete challenge: $e');
    }
  }
}

