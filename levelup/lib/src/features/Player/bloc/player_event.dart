import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Load player data
class PlayerLoadRequested extends PlayerEvent {
  const PlayerLoadRequested();
}

/// Refresh player data
class PlayerRefreshRequested extends PlayerEvent {
  const PlayerRefreshRequested();
}

/// Player leveled up
class PlayerLevelUpDetected extends PlayerEvent {
  final int newLevel;
  
  const PlayerLevelUpDetected(this.newLevel);
  
  @override
  List<Object?> get props => [newLevel];
}
