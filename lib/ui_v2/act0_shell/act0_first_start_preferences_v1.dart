import 'package:shared_preferences/shared_preferences.dart';

class Act0FirstStartPreferencesV1 {
  static const String _welcomeCompletedKey = 'act0_welcome_completed_v1';

  static Future<bool> hasCompletedWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeCompletedKey) ?? false;
  }

  static Future<void> setWelcomeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeCompletedKey, true);
  }

  static Future<void> resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeCompletedKey);
  }
}
