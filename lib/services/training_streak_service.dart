import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedantic/pedantic.dart'; // Added for unawaited

class TrainingStreakService {
  static final TrainingStreakService _instance =
      TrainingStreakService._internal();

  factory TrainingStreakService() => _instance;

  TrainingStreakService._internal();

  static const String _lastTrainingDateKey = 'last_training_date';
  static const String _currentStreakKey = 'current_streak';

  Future<void> recordSession(DateTime timestamp) async {
    unawaited(
      SharedPreferences.getInstance().then((prefs) {
        final lastTrainingDateString = prefs.getString(_lastTrainingDateKey);
        final lastTrainingDate = lastTrainingDateString != null
            ? DateTime.parse(lastTrainingDateString)
            : null;

        if (lastTrainingDate != null) {
          final difference = timestamp.difference(lastTrainingDate).inDays;
          if (difference == 1) {
            // Increment streak if the session is on the next day
            final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
            prefs.setInt(_currentStreakKey, currentStreak + 1);
          } else if (difference > 1) {
            // Reset streak if a day is missed
            prefs.setInt(_currentStreakKey, 1);
          }
        } else {
          // First session ever
          prefs.setInt(_currentStreakKey, 1);
        }

        // Update the last training date
        prefs.setString(_lastTrainingDateKey, timestamp.toIso8601String());
      }),
    );
  }

  Future<int> getCurrentStreak() async => SharedPreferences.getInstance().then(
    (prefs) => prefs.getInt(_currentStreakKey) ?? 0,
  );

  Future<DateTime?> getLastTrainingDate() async =>
      SharedPreferences.getInstance().then((prefs) {
        final lastTrainingDateString = prefs.getString(_lastTrainingDateKey);
        return lastTrainingDateString != null
            ? DateTime.parse(lastTrainingDateString)
            : null;
      });

  Future<void> resetStreak() async {
    unawaited(
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove(_lastTrainingDateKey);
        prefs.remove(_currentStreakKey);
      }),
    );
  }
}
