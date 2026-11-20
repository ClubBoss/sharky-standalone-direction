import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Act0FirstStartPreferencesV1 {
  static const String _welcomeCompletedKey = 'act0_welcome_completed_v1';
  static Future<void>? _operations;
  static Future<void> flush() => _operations ?? Future<void>.value();

  // Legacy preferences update their cache before the backend acknowledges a
  // write. Serialize this owner's reads/writes and refresh from
  // backend storage before each operation; failed writes cannot become cached truth.
  static Future<T> _withPreferences<T>(
    Future<T> Function(SharedPreferences prefs) operation,
  ) {
    final predecessor = _operations;
    final released = Completer<void>();
    final tail = released.future;
    _operations = tail;
    Future<T> run() async {
      try {
        if (predecessor != null) await predecessor;
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        return await operation(prefs);
      } finally {
        // Drop an idle tail before completing the caller. Retaining a settled
        // Future can retain its scheduler zone across widget-test boundaries.
        // A newer queued operation still owns its own release barrier.
        if (identical(_operations, tail)) _operations = null;
        released.complete();
      }
    }

    return run();
  }

  static Future<void> _setAcknowledged(String key) =>
      _withPreferences((prefs) async {
        if (!await prefs.setBool(key, true)) {
          throw StateError('Could not save introduction choice');
        }
      });

  static Future<({bool welcomeCompleted, bool introductionSkipped})>
  readWelcomeDisposition() => _withPreferences(
    (prefs) async => (
      welcomeCompleted: prefs.getBool(_welcomeCompletedKey) ?? false,
      introductionSkipped: prefs.getBool(_introductionSkippedKey) ?? false,
    ),
  );

  static Future<bool> hasCompletedWelcome() => _withPreferences(
    (prefs) async => prefs.getBool(_welcomeCompletedKey) ?? false,
  );

  static Future<void> setWelcomeCompleted() =>
      _setAcknowledged(_welcomeCompletedKey);

  static const String _introductionSkippedKey = 'act0_introduction_skipped_v1';

  static Future<bool> hasSkippedIntroduction() => _withPreferences(
    (prefs) async => prefs.getBool(_introductionSkippedKey) ?? false,
  );

  static Future<void> setIntroductionSkipped() =>
      _setAcknowledged(_introductionSkippedKey);

  static Future<void> resetWelcome() => _withPreferences((prefs) async {
    // Use the same queue so an older pending save cannot revive reset flags.
    await prefs.remove(_welcomeCompletedKey);
    await prefs.remove(_introductionSkippedKey);
  });
}
