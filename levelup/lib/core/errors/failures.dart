/// Base failure class
abstract class Failure {
  final String message;
  const Failure(this.message);
  
  @override
  String toString() => message;
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

