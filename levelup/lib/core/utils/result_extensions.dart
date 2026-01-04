import 'result.dart';

/// Extension untuk Result untuk handle success/error
extension ResultExtension<T> on Result<T> {
  /// Execute function based on result type
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Exception? exception) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      final errorResult = this as ResultError<T>;
      return failure(errorResult.message, errorResult.exception);
    }
  }
  
  /// Get data if success, null if error
  T? get dataOrNull {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }
  
  /// Get error message if error, null if success
  String? get errorOrNull {
    if (this is ResultError<T>) {
      return (this as ResultError<T>).message;
    }
    return null;
  }
}

