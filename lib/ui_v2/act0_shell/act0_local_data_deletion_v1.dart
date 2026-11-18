import 'package:shared_preferences/shared_preferences.dart';

import 'act0_local_data_files_v1.dart';
import 'act0_practice_reminder_v1.dart';

/// A durable erase intent survives process death between individual removals.
/// No learner route may open until a pending erase has finished and reloaded.
class Act0LocalDataDeletionV1 {
  static const pendingKey = 'act0_local_data_deletion_pending_v1';
  static int generation = 0;
  static bool blocked = false;
  static Future<void>? _operation;

  static void blockOldWriters() {
    blocked = true;
    generation++;
  }

  static Future<void> resumePending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (blocked || prefs.containsKey(pendingKey)) {
      blockOldWriters();
      await erase();
    }
  }

  static Future<void> erase() => _operation ??= _erase().whenComplete(() {
    _operation = null;
  });

  static Future<void> _erase() async {
    blockOldWriters();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!await prefs.setBool(pendingKey, true)) {
      throw StateError('Deletion could not be started');
    }
    await prefs.reload();
    if (prefs.getBool(pendingKey) != true) {
      throw StateError('Deletion intent could not be verified');
    }
    await Act0PracticeReminderV1.setEnabled(false);
    // Includes the compatibility mirror, twins, damaged archive, recovery
    // intent, onboarding, preferences and old learning projections.
    for (final key in prefs.getKeys().where((key) => key != pendingKey)) {
      if (!await prefs.remove(key)) {
        throw StateError('Some local data could not be deleted');
      }
    }
    await eraseAct0LocalDiagnosticFileV1();
    await prefs.reload();
    if (prefs.getKeys().any((key) => key != pendingKey)) {
      throw StateError('Local data deletion could not be verified');
    }
    if (!await prefs.remove(pendingKey)) {
      throw StateError('Deletion completion could not be saved');
    }
    await prefs.reload();
    if (prefs.getKeys().isNotEmpty) {
      throw StateError('Deletion completion could not be verified');
    }
    blocked = false;
  }
}
