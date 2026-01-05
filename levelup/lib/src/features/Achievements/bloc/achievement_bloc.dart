import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/repositories/achievement_repository.dart';
import 'achievement_event.dart';
import 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final AchievementRepository _achievementRepository;

  AchievementBloc({required AchievementRepository achievementRepository})
      : _achievementRepository = achievementRepository,
        super(AchievementState.initial()) {
    on<LoadAchievements>(_onLoadAchievements);
    on<RefreshAchievements>(_onRefreshAchievements);
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    
    final result = await _achievementRepository.getAchievements();
    if (result is Success<List<Achievement>>) {
      final achievements = result.data;
      final unlocked = achievements.where((a) => a.isUnlocked).toList();
      final locked = achievements.where((a) => !a.isUnlocked).toList();
      
      emit(state.copyWith(
        loading: false,
        achievements: achievements,
        unlockedAchievements: unlocked,
        lockedAchievements: locked,
        error: null,
      ));
    } else if (result is ResultError<List<Achievement>>) {
      emit(state.copyWith(
        loading: false,
        error: result.message,
      ));
    } else {
      emit(state.copyWith(
        loading: false,
        error: 'Unknown error',
      ));
    }
  }

  Future<void> _onRefreshAchievements(
    RefreshAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    final result = await _achievementRepository.getAchievements();
    if (result is Success<List<Achievement>>) {
      final achievements = result.data;
      final unlocked = achievements.where((a) => a.isUnlocked).toList();
      final locked = achievements.where((a) => !a.isUnlocked).toList();
      
      emit(state.copyWith(
        achievements: achievements,
        unlockedAchievements: unlocked,
        lockedAchievements: locked,
        error: null,
      ));
    }
  }
}





