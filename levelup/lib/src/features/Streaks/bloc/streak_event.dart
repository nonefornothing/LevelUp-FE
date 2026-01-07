import 'package:equatable/equatable.dart';

import '../../../../domain/entities/streak.dart';

/// Base class for streak events
abstract class StreakEvent extends Equatable {
  const StreakEvent();

  @override
  List<Object?> get props => [];
}

/// Load all streaks
class StreakLoadRequested extends StreakEvent {
  const StreakLoadRequested();
}

/// Refresh streaks
class StreakRefreshRequested extends StreakEvent {
  const StreakRefreshRequested();
}

/// Load streak by type
class StreakLoadByTypeRequested extends StreakEvent {
  final StreakType type;

  const StreakLoadByTypeRequested(this.type);

  @override
  List<Object?> get props => [type];
}

/// Load streak statistics
class StreakStatisticsRequested extends StreakEvent {
  const StreakStatisticsRequested();
}



