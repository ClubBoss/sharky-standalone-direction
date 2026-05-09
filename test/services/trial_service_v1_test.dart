import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';
import 'package:poker_analyzer/services/trial_service_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PremiumService().clear();
    SubscriptionServiceV1.debugResetTelemetryEmissionV1();
  });

  test(
    'trial starts only once after placement and stays deterministic',
    () async {
      const nowEpochMs = 1700000000000;

      final beforePlacement = await TrialServiceV1.getTrialStatusV1(
        nowEpochMs: nowEpochMs,
      );
      expect(beforePlacement.isEligible, isFalse);
      expect(beforePlacement.reason, 'placement_incomplete');

      await TrialServiceV1.markPlacementCompletedV1();
      final eligible = await TrialServiceV1.getTrialStatusV1(
        nowEpochMs: nowEpochMs,
      );
      expect(eligible.isEligible, isTrue);
      expect(eligible.reason, 'eligible');

      final started = await TrialServiceV1.startTrialIfEligibleV1(
        nowEpochMs: nowEpochMs,
      );
      expect(started.isTrialActive, isTrue);
      expect(started.remainingDays, 7);
      expect(started.isEligible, isFalse);

      final prefs = await SharedPreferences.getInstance();
      final firstEntitlementJson = prefs.getString('trial_entitlement_v1');
      expect(firstEntitlementJson, isNotNull);

      final secondStart = await TrialServiceV1.startTrialIfEligibleV1(
        nowEpochMs: nowEpochMs + 5000,
      );
      final secondEntitlementJson = prefs.getString('trial_entitlement_v1');
      expect(secondEntitlementJson, firstEntitlementJson);
      expect(secondStart.isTrialActive, isTrue);

      final sixDaysLater = await TrialServiceV1.getTrialStatusV1(
        nowEpochMs: nowEpochMs + (6 * 24 * 60 * 60 * 1000),
      );
      expect(sixDaysLater.isTrialActive, isTrue);
      expect(sixDaysLater.remainingDays, greaterThanOrEqualTo(1));

      final eightDaysLater = await TrialServiceV1.getTrialStatusV1(
        nowEpochMs: nowEpochMs + (8 * 24 * 60 * 60 * 1000),
      );
      expect(eightDaysLater.isTrialActive, isFalse);
      expect(eightDaysLater.reason, 'trial_already_used');
    },
  );

  test('subscription facade reflects active trial deterministically', () async {
    const nowEpochMs = 1700000000000;
    await PremiumService().disablePremium();
    await TrialServiceV1.markPlacementCompletedV1();
    await TrialServiceV1.startTrialIfEligibleV1(nowEpochMs: nowEpochMs);

    final statusA = await SubscriptionServiceV1.getStatusV1(
      nowEpochMs: nowEpochMs + 1000,
    );
    final statusB = await SubscriptionServiceV1.getStatusV1(
      nowEpochMs: nowEpochMs + 1000,
    );
    expect(statusA.isPremium, isFalse);
    expect(statusA.isEntitled, isTrue);
    expect(statusA.isTrialActive, isTrue);
    expect(statusA.source, SubscriptionSourceV1.trial);
    expect(statusA.accessState, SubscriptionAccessStateV1.trial);
    expect(jsonEncode(statusA.toJson()), jsonEncode(statusB.toJson()));
  });

  test(
    'clock rollback is detected deterministically and trial stays blocked',
    () async {
      const nowEpochMs = 1700000000000;
      const rollbackEpochMs = nowEpochMs - (10 * 60 * 1000);

      await PremiumService().disablePremium();
      await TrialServiceV1.markPlacementCompletedV1();
      await TrialServiceV1.startTrialIfEligibleV1(nowEpochMs: nowEpochMs);

      final rollbackStatus = await TrialServiceV1.getTrialStatusV1(
        nowEpochMs: rollbackEpochMs,
      );
      expect(rollbackStatus.isTrialActive, isFalse);
      expect(rollbackStatus.isEligible, isFalse);
      expect(rollbackStatus.reason, 'clock_rollback');

      final afterRollback = await TrialServiceV1.getTrialStatusV1(
        nowEpochMs: nowEpochMs + 1000,
      );
      expect(afterRollback.isTrialActive, isFalse);
      expect(afterRollback.isEligible, isFalse);
      expect(afterRollback.reason, 'clock_rollback');
    },
  );

  test(
    'clock rollback telemetry emits exactly once on first detection',
    () async {
      const nowEpochMs = 1700000000000;
      const rollbackEpochMs = nowEpochMs - (10 * 60 * 1000);
      final events = <Map<String, dynamic>>[];

      Telemetry.overrideLogHandler((name, payload) async {
        events.add(<String, dynamic>{
          'name': name,
          'payload': Map<String, dynamic>.from(
            payload ?? const <String, dynamic>{},
          ),
        });
      });
      addTearDown(() => Telemetry.overrideLogHandler(null));

      await PremiumService().disablePremium();
      await TrialServiceV1.markPlacementCompletedV1();
      await TrialServiceV1.startTrialIfEligibleV1(nowEpochMs: nowEpochMs);

      await TrialServiceV1.getTrialStatusV1(nowEpochMs: rollbackEpochMs);
      await TrialServiceV1.getTrialStatusV1(nowEpochMs: rollbackEpochMs - 1000);
      await TrialServiceV1.getTrialStatusV1(nowEpochMs: nowEpochMs + 2000);

      final rollbackEvents = events
          .where((event) => event['name'] == 'trial_clock_rollback_detected_v1')
          .toList(growable: false);
      expect(rollbackEvents, hasLength(1));
      expect(rollbackEvents.single['payload']['schemaVersion'], 1);
      expect(rollbackEvents.single['payload']['skewMs'], greaterThan(0));
      expect(rollbackEvents.single['payload']['lastSeenEpochMs'], nowEpochMs);
      expect(rollbackEvents.single['payload']['nowEpochMs'], rollbackEpochMs);
    },
  );
}
