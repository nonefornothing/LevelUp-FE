/// Simple logger utility for the app
/// In production, this can be replaced with a proper logging package
class Logger {
  static const bool _debugMode = true; // Set to false in production

  static void info(String message) {
    if (_debugMode) {
      // ignore: avoid_print
      print('[INFO] $message');
    }
  }

  static void warning(String message) {
    if (_debugMode) {
      // ignore: avoid_print
      print('[WARNING] $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_debugMode) {
      // ignore: avoid_print
      print('[ERROR] $message');
      if (error != null) {
        // ignore: avoid_print
        print('Error: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('Stack trace: $stackTrace');
      }
    }
  }

  static void debug(String message) {
    if (_debugMode) {
      // ignore: avoid_print
      print('[DEBUG] $message');
    }
  }
}

