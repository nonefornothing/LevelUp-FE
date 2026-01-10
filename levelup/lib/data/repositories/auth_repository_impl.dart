import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// NOTE:
/// This is an offline/local stub to unblock MVP development.
/// Later we will replace these flows with real Google OAuth / backend auth.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({required AuthLocalDataSource localDataSource})
      : _local = localDataSource;

  @override
  Future<Result<String>> loginWithGoogle() async {
    // TODO: Implement Google Sign-In + backend token exchange.
    return const ResultError('Google login not implemented yet');
  }

  @override
  Future<Result<String>> loginWithEmail(String email, String password) async {
    // Offline stub: generate deterministic token from email+password
    try {
      final token = _hash('$email:$password');
      final userId = _hash(email).substring(0, 16);
      await _local.setAuthToken(token);
      await _local.setUserId(userId);
      return Success(token);
    } catch (e) {
      return ResultError(
        'Failed to login: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<String>> registerWithEmail(
    String email,
    String password,
    String username,
  ) async {
    // Offline stub: treat as login and store session
    return loginWithEmail(email, password);
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _local.clearSession();
      return const Success(null);
    } catch (e) {
      return ResultError(
        'Failed to logout: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> isLoggedIn() async {
    try {
      final token = await _local.getAuthToken();
      return Success(token != null && token.isNotEmpty);
    } catch (e) {
      return ResultError(
        'Failed to check login state: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<String?>> getCurrentUserId() async {
    try {
      final userId = await _local.getUserId();
      return Success(userId);
    } catch (e) {
      return ResultError(
        'Failed to get current user id: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}


