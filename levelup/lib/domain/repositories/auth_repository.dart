import '../../core/utils/result.dart';

/// Authentication Repository Interface (Domain layer)
abstract class AuthRepository {
  /// Login with Google
  Future<Result<String>> loginWithGoogle();

  /// Login with email and password
  Future<Result<String>> loginWithEmail(String email, String password);

  /// Register with email and password
  Future<Result<String>> registerWithEmail(
    String email,
    String password,
    String username,
  );

  /// Logout
  Future<Result<void>> logout();

  /// Check if user is logged in
  Future<Result<bool>> isLoggedIn();

  /// Get current user ID
  Future<Result<String?>> getCurrentUserId();
}

