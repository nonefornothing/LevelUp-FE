import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/streak_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/streak.dart';
import '../../../../domain/repositories/streak_repository.dart';
import 'streak_event.dart';
import 'streak_state.dart';

/// BLoC for managing streak state
class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final StreakService _streakService;

  StreakBloc({
    StreakService? streakService,
  })  : _streakService = streakService ?? sl<StreakService>(),
        super(const StreakInitial()) {
    on<StreakLoadRequested>(_onLoadRequested);
    on<StreakRefreshRequested>(_onRefreshRequested);
    on<StreakLoadByTypeRequested>(_onLoadByTypeRequested);
    on<StreakStatisticsRequested>(_onStatisticsRequested);
  }

  Future<void> _onLoadRequested(
    StreakLoadRequested event,
    Emitter<StreakState> emit,
  ) async {
    emit(const StreakLoading());

    try {
      final result = await _streakService.getAllStreaks();
      if (result is ResultError<List<Streak>>) {
        emit(StreakError((result as ResultError<dynamic>).message));
        return;
      }

      final streaks = (result as Success<List<Streak>>).data;
      final streaksByType = <StreakType, Streak>{};
      for (final streak in streaks) {
        streaksByType[streak.type] = streak;
      }

      // Also load statistics
      final statsResult = await _streakService.getStreakStatistics();
      StreakStatistics? statistics;
      if (statsResult is Success<StreakStatistics>) {
        statistics = statsResult.data;
      }

      emit(StreakLoaded(
        streaks: streaks,
        streaksByType: streaksByType,
        statistics: statistics,
      ));
    } catch (e) {
      emit(StreakError('Failed to load streaks: $e'));
    }
  }

  Future<void> _onRefreshRequested(
    StreakRefreshRequested event,
    Emitter<StreakState> emit,
  ) async {
    // Reload streaks
    add(const StreakLoadRequested());
  }

  Future<void> _onLoadByTypeRequested(
    StreakLoadByTypeRequested event,
    Emitter<StreakState> emit,
  ) async {
    try {
      final result = await _streakService.getStreakByType(event.type);
      if (result is ResultError<Streak?>) {
        emit(StreakError((result as ResultError<dynamic>).message));
        return;
      }

      final streak = (result as Success<Streak?>).data;
      final streaksByType = <StreakType, Streak>{};
      if (streak != null) {
        streaksByType[event.type] = streak;
      }

      emit(StreakLoaded(
        streaks: streak != null ? [streak] : [],
        streaksByType: streaksByType,
      ));
    } catch (e) {
      emit(StreakError('Failed to load streak: $e'));
    }
  }

  Future<void> _onStatisticsRequested(
    StreakStatisticsRequested event,
    Emitter<StreakState> emit,
  ) async {
    try {
      final result = await _streakService.getStreakStatistics();
      if (result is ResultError<StreakStatistics>) {
        emit(StreakError((result as ResultError<dynamic>).message));
        return;
      }

      final statistics = (result as Success<StreakStatistics>).data;
      final currentState = state;
      if (currentState is StreakLoaded) {
        emit(currentState.copyWith(statistics: statistics));
      } else {
        // Load all streaks first
        final streaksResult = await _streakService.getAllStreaks();
        final streaks = streaksResult is Success<List<Streak>>
            ? streaksResult.data
            : <Streak>[];
        final streaksByType = <StreakType, Streak>{};
        for (final streak in streaks) {
          streaksByType[streak.type] = streak;
        }

        emit(StreakLoaded(
          streaks: streaks,
          streaksByType: streaksByType,
          statistics: statistics,
        ));
      }
    } catch (e) {
      emit(StreakError('Failed to load statistics: $e'));
    }
  }
}

/// Extension to add copyWith to StreakLoaded
extension StreakLoadedExtension on StreakLoaded {
  StreakLoaded copyWith({
    List<Streak>? streaks,
    Map<StreakType, Streak>? streaksByType,
    StreakStatistics? statistics,
  }) {
    return StreakLoaded(
      streaks: streaks ?? this.streaks,
      streaksByType: streaksByType ?? this.streaksByType,
      statistics: statistics ?? this.statistics,
    );
  }
}


