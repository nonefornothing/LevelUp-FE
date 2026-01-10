import 'package:equatable/equatable.dart';

import '../../../../domain/entities/player.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {
  const PlayerInitial();
}

class PlayerLoading extends PlayerState {
  const PlayerLoading();
}

class PlayerLoaded extends PlayerState {
  final Player player;
  
  const PlayerLoaded(this.player);
  
  @override
  List<Object?> get props => [player];
}

class PlayerError extends PlayerState {
  final String message;
  
  const PlayerError(this.message);
  
  @override
  List<Object?> get props => [message];
}
