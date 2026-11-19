import 'dart:async';
import 'package:flutter/foundation.dart';

import '../infra/telemetry.dart';

/// A simple logging utility that centralizes log output.
///
/// Prints debug logs and allows local observation in contract tests.
class AppLogger {
  AppLogger._();

  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    } else {
      unawaited(Telemetry.logEvent('log', {'message': message}));
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ $message');
    } else {
      unawaited(Telemetry.logEvent('warn', {'message': message}));
    }
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('❌ $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stack != null) {
        debugPrint(stack.toString());
      }
    } else {
      unawaited(
        Telemetry.logEvent('error', {
          'message': message,
          if (error != null) 'error': error.toString(),
          if (stack != null) 'stack': stack.toString(),
        }),
      );
    }
  }
}
