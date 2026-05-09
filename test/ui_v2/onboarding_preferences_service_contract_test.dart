import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('legacy key alone is treated as completed onboarding', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_complete': true,
    });

    final first = await OnboardingPreferencesService.hasCompletedOnboarding();
    final second = await OnboardingPreferencesService.hasCompletedOnboarding();

    expect(first, isTrue);
    expect(second, isTrue);
  });

  test('setOnboardingComplete writes canonical and legacy keys', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await OnboardingPreferencesService.setOnboardingComplete();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboardingCompleted'), isTrue);
    expect(prefs.getBool('onboarding_complete'), isTrue);
    expect(await OnboardingPreferencesService.hasCompletedOnboarding(), isTrue);
  });
}
