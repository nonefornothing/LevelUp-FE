/// Result class untuk handle success/error states
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Error wrapper for [Result].
///
/// Named `ResultError` (instead of `Failure`) to avoid name collision with
/// `core/errors/failures.dart`.
final class ResultError<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const ResultError(this.message, {this.exception});
  
  @override
  String toString() => 'ResultError: $message';
}

