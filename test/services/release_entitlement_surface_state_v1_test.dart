import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/services/release_entitlement_surface_state_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';
import 'package:poker_analyzer/services/trial_service_v1.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PremiumService().clear();
    SubscriptionServiceV1.debugResetTelemetryEmissionV1();
  });

  test(
    'release entitlement surface keeps premium precedence over trial',
    () async {
      const nowEpochMs = 1700000000000;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
      );
      await PremiumService().enablePremium();

      final surface = await ReleaseEntitlementSurfaceStateServiceV1.readV1(
        nowEpochMs: nowEpochMs,
      );

      expect(surface.isPremium, isTrue);
      expect(surface.isTrialActive, isFalse);
      expect(surface.isTrialEligible, isFalse);
      expect(surface.showMonetizationRow, isTrue);
      expect(
        surface.subscriptionStatus.accessState,
        SubscriptionAccessStateV1.premium,
      );
    },
  );

  test(
    'release entitlement surface keeps expired trial visible as free state',
    () async {
      const nowEpochMs = 1700000000000;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - (9 * 24 * 60 * 60 * 1000),
          'durationDays': 7,
        }),
      );
      await TrialServiceV1.markPlacementCompletedV1();

      final surface = await ReleaseEntitlementSurfaceStateServiceV1.readV1(
        nowEpochMs: nowEpochMs,
      );

      expect(surface.isPremium, isFalse);
      expect(surface.isTrialActive, isFalse);
      expect(surface.isTrialEligible, isFalse);
      expect(surface.showMonetizationRow, isTrue);
      expect(
        surface.subscriptionStatus.accessState,
        SubscriptionAccessStateV1.free,
      );
      expect(surface.trialStatus.reason, 'trial_already_used');
    },
  );
}
