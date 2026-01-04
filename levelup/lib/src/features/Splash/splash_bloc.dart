import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../../routing/app_routes.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository _authRepository;
  final OnboardingRepository _onboardingRepository;

  SplashBloc({
    required AuthRepository authRepository,
    required OnboardingRepository onboardingRepository,
  })  : _authRepository = authRepository,
        _onboardingRepository = onboardingRepository,
        super(SplashInitial()) {
    on<SplashStarted>((event, emit) async {
      // Keep a short splash delay for UX
      await Future.delayed(const Duration(seconds: 2));

      final onboardingResult = await _onboardingRepository.isCompleted();
      final onboardingDone = onboardingResult is Success<bool> && onboardingResult.data;

      if (!onboardingDone) {
        emit(SplashRouteDecision(AppRoutes.onboarding));
        return;
      }

      final loggedInResult = await _authRepository.isLoggedIn();
      final loggedIn = loggedInResult is Success<bool> && loggedInResult.data;

      emit(SplashRouteDecision(loggedIn ? AppRoutes.home : AppRoutes.login));
    });
  }
}
