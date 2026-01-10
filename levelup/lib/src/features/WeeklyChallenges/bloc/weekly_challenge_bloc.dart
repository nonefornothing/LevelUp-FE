import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/weekly_challenge_service.dart';
import '../../../../domain/entities/weekly_challenge.dart';
import 'weekly_challenge_event.dart';
import 'weekly_challenge_state.dart';

/// BLoC for managing weekly challenge state
class WeeklyChallengeBloc extends Bloc<WeeklyChallengeEvent, WeeklyChallengeState> {
  final WeeklyChallengeService _challengeService;

  WeeklyChallengeBloc({
    WeeklyChallengeService? challengeService,
  })  : _challengeService = challengeService ?? sl<WeeklyChallengeService>(),
        super(const WeeklyChallengeInitial()) {
    on<WeeklyChallengeLoadRequested>(_onLoadRequested);
    on<WeeklyChallengeRefreshRequested>(_onRefreshRequested);
    on<WeeklyChallengeClaimRewardRequested>(_onClaimRewardRequested);
  }

  Future<void> _onLoadRequested(
    WeeklyChallengeLoadRequested event,
    Emitter<WeeklyChallengeState> emit,
  ) async {
    emit(const WeeklyChallengeLoading());

    try {
      final challenges = await _challengeService.getActiveWeeklyChallenges();
      
      final activeChallenges = challenges
          .where((c) => c.status == WeeklyChallengeStatus.active)
          .toList();
      final completedChallenges = challenges
          .where((c) => c.status == WeeklyChallengeStatus.completed)
          .toList();

      emit(WeeklyChallengeLoaded(
        challenges: challenges,
        activeChallenges: activeChallenges,
        completedChallenges: completedChallenges,
      ));
    } catch (e) {
      emit(WeeklyChallengeError('Failed to load weekly challenges: $e'));
    }
  }

  Future<void> _onRefreshRequested(
    WeeklyChallengeRefreshRequested event,
    Emitter<WeeklyChallengeState> emit,
  ) async {
    try {
      final challenges = await _challengeService.getActiveWeeklyChallenges();
      
      final activeChallenges = challenges
          .where((c) => c.status == WeeklyChallengeStatus.active)
          .toList();
      final completedChallenges = challenges
          .where((c) => c.status == WeeklyChallengeStatus.completed)
          .toList();

      emit(WeeklyChallengeLoaded(
        challenges: challenges,
        activeChallenges: activeChallenges,
        completedChallenges: completedChallenges,
      ));
    } catch (e) {
      emit(WeeklyChallengeError('Failed to refresh weekly challenges: $e'));
    }
  }

  Future<void> _onClaimRewardRequested(
    WeeklyChallengeClaimRewardRequested event,
    Emitter<WeeklyChallengeState> emit,
  ) async {
    // Reward claiming is handled by the reward claim screen
    // This event can be used to trigger a refresh
    add(const WeeklyChallengeRefreshRequested());
  }
}

