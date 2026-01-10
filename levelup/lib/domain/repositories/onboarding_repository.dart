import '../../core/utils/result.dart';

/// Onboarding repository interface (Domain layer)
abstract class OnboardingRepository {
  Future<Result<bool>> isCompleted();
  Future<Result<void>> setCompleted(bool completed);
}


