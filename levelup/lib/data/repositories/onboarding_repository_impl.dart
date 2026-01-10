import '../../core/utils/result.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _local;

  OnboardingRepositoryImpl({required OnboardingLocalDataSource localDataSource})
      : _local = localDataSource;

  @override
  Future<Result<bool>> isCompleted() async {
    try {
      final completed = await _local.isCompleted();
      return Success(completed);
    } catch (e) {
      return ResultError(
        'Failed to read onboarding status: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> setCompleted(bool completed) async {
    try {
      await _local.setCompleted(completed);
      return const Success(null);
    } catch (e) {
      return ResultError(
        'Failed to write onboarding status: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}


