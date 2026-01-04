import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../domain/entities/player.dart';
import '../../../../domain/repositories/player_repository.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final PlayerRepository _playerRepository;

  PlayerBloc({required PlayerRepository playerRepository})
      : _playerRepository = playerRepository,
        super(const PlayerInitial()) {
    on<PlayerLoadRequested>(_onLoadRequested);
    on<PlayerRefreshRequested>(_onRefreshRequested);
    on<PlayerLevelUpDetected>(_onLevelUpDetected);
  }

  Future<void> _onLoadRequested(
    PlayerLoadRequested event,
    Emitter<PlayerState> emit,
  ) async {
    emit(const PlayerLoading());
    final result = await _playerRepository.getPlayer();
    
    if (result is Success<Player>) {
      emit(PlayerLoaded(result.data));
    } else if (result is ResultError<Player>) {
      emit(PlayerError(result.message));
    } else {
      emit(const PlayerError('Unknown error'));
    }
  }

  Future<void> _onRefreshRequested(
    PlayerRefreshRequested event,
    Emitter<PlayerState> emit,
  ) async {
    final result = await _playerRepository.getPlayer();
    
    if (result is Success<Player>) {
      emit(PlayerLoaded(result.data));
    } else if (result is ResultError<Player>) {
      emit(PlayerError(result.message));
    }
  }

  Future<void> _onLevelUpDetected(
    PlayerLevelUpDetected event,
    Emitter<PlayerState> emit,
  ) async {
    // Reload player after level up
    final result = await _playerRepository.getPlayer();
    if (result is Success<Player>) {
      emit(PlayerLoaded(result.data));
    }
  }
}
