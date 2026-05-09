import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding Preferences Service
///
/// Manages onboarding completion state using SharedPreferences.
/// Used to determine if onboarding should be shown on app launch.
class OnboardingPreferencesService {
  static const String _legacyKeyOnboardingComplete = 'onboarding_complete';
  static const String _canonicalKeyOnboardingComplete = 'onboardingCompleted';

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final canonical =
          prefs.getBool(_canonicalKeyOnboardingComplete) ?? false;
      if (canonical) {
        return true;
      }
      return prefs.getBool(_legacyKeyOnboardingComplete) ?? false;
    } catch (e) {
      // Default to false if we can't read preferences
      return false;
    }
  }

  /// Mark onboarding as complete
  static Future<void> setOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep both keys in sync to bridge legacy and canonical entry surfaces.
      await prefs.setBool(_canonicalKeyOnboardingComplete, true);
      await prefs.setBool(_legacyKeyOnboardingComplete, true);
    } catch (e) {
      // Silently fail - non-critical operation
    }
  }

  /// Reset onboarding state (useful for testing/debugging)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_canonicalKeyOnboardingComplete);
      await prefs.remove(_legacyKeyOnboardingComplete);
    } catch (e) {
      // Silently fail - non-critical operation
    }
  }
}
