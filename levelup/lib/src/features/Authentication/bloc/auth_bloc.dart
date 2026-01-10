import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/repositories/player_repository.dart';
import '../../../../domain/entities/player.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final PlayerRepository _playerRepository;

  AuthBloc({
    required AuthRepository authRepository,
    required PlayerRepository playerRepository,
  })  : _authRepository = authRepository,
        _playerRepository = playerRepository,
        super(AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginWithEmail>(_onLoginWithEmail);
    on<AuthRegisterWithEmail>(_onRegisterWithEmail);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onAppStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
    final loggedInResult = await _authRepository.isLoggedIn();
    if (loggedInResult is Success<bool> && loggedInResult.data) {
      await _ensurePlayer(username: null);
      // token not exposed by repository; treat as authenticated
      emit(AuthAuthenticated('local-session'));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginWithEmail(
    AuthLoginWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.loginWithEmail(event.email, event.password);
    if (result is Success<String>) {
      await _ensurePlayer(username: event.email.split('@').first);
      emit(AuthAuthenticated(result.data));
    } else if (result is ResultError<String>) {
      emit(AuthError(result.message));
      emit(AuthUnauthenticated());
    } else {
      emit(AuthError('Unknown error'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterWithEmail(
    AuthRegisterWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.registerWithEmail(
      event.email,
      event.password,
      event.username,
    );
    if (result is Success<String>) {
      await _ensurePlayer(username: event.username);
      emit(AuthAuthenticated(result.data));
    } else if (result is ResultError<String>) {
      emit(AuthError(result.message));
      emit(AuthUnauthenticated());
    } else {
      emit(AuthError('Unknown error'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    // optional: keep player cached; for now we don't clear it
    emit(AuthUnauthenticated());
  }

  Future<void> _ensurePlayer({required String? username}) async {
    final existing = await _playerRepository.getPlayer();
    if (existing is Success<Player>) return;

    final userIdRes = await _authRepository.getCurrentUserId();
    final userId = (userIdRes is Success<String?>) ? (userIdRes.data ?? '') : '';
    if (userId.isEmpty) return;

    final player = Player(
      id: userId,
      username: (username == null || username.isEmpty) ? userId : username,
      email: null,
      level: 1,
      experience: 0,
      currency: 0,
      stats: const PlayerStats(
        totalQuestsCompleted: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: null,
      ),
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    await _playerRepository.createPlayer(player);
  }
}


