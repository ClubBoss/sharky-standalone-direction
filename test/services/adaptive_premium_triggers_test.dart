import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/adaptive_premium_triggers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'energy_current': 3,
      'wallet_chips': 10,
    });
  });

  test(
    'legacy triggers are hard-disabled and side-effect free in v1',
    () async {
      final triggers = AdaptivePremiumTriggers();
      final prefs = await SharedPreferences.getInstance();

      final result = await triggers.evaluateTriggers(
        momentum: 1.0,
        fatigue: 100,
        streakDays: 7,
      );

      expect(result.trialActivated, isFalse);
      expect(result.energyBonus, 0);
      expect(result.chipsBonus, 0);
      expect(result.message, 'legacy_triggers_disabled_v1');
      expect(prefs.getInt('energy_current'), 3);
      expect(prefs.getInt('wallet_chips'), 10);
      expect(prefs.getInt('premium_trial_expiry'), isNull);
      expect(prefs.getInt('triggers_last_eval'), isNull);
    },
  );
}
