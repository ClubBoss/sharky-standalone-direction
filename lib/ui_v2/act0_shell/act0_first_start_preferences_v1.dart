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

  static const String _introductionSkippedKey = 'act0_introduction_skipped_v1';

  static Future<bool> hasSkippedIntroduction() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introductionSkippedKey) ?? false;
  }

  static Future<void> setIntroductionSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setBool(_introductionSkippedKey, true)) {
      throw StateError('Could not save introduction choice');
    }
  }

  static Future<void> resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeCompletedKey);
    await prefs.remove(_introductionSkippedKey);
  }
}
