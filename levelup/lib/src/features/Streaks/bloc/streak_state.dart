import 'package:equatable/equatable.dart';

import '../../../../domain/entities/streak.dart';
import '../../../../domain/repositories/streak_repository.dart';

/// Base class for streak states
abstract class StreakState extends Equatable {
  const StreakState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class StreakInitial extends StreakState {
  const StreakInitial();
}

/// Loading state
class StreakLoading extends StreakState {
  const StreakLoading();
}

/// Loaded state with streaks
class StreakLoaded extends StreakState {
  final List<Streak> streaks;
  final Map<StreakType, Streak> streaksByType;
  final StreakStatistics? statistics;

  const StreakLoaded({
    required this.streaks,
    required this.streaksByType,
    this.statistics,
  });

  @override
  List<Object?> get props => [streaks, streaksByType, statistics];
}

/// Error state
class StreakError extends StreakState {
  final String message;

  const StreakError(this.message);

  @override
  List<Object?> get props => [message];
}


