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
      // Check onboarding and auth status in parallel for faster startup
      final results = await Future.wait([
        _onboardingRepository.isCompleted(),
        _authRepository.isLoggedIn(),
      ]);

      final onboardingResult = results[0];
      final loggedInResult = results[1];
      
      final onboardingDone = onboardingResult is Success<bool> && onboardingResult.data;
      final loggedIn = loggedInResult is Success<bool> && loggedInResult.data;

      // Only add minimal delay if we need to show splash screen
      // Otherwise navigate immediately
      if (!onboardingDone || !loggedIn) {
        // Minimal delay for UX (reduced from 2 seconds to 500ms)
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (!onboardingDone) {
        emit(SplashRouteDecision(AppRoutes.onboarding));
        return;
      }

      emit(SplashRouteDecision(loggedIn ? AppRoutes.home : AppRoutes.login));
    });
  }
}
