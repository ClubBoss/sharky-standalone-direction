import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/entitlement_ssot_v1.dart';
import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SubscriptionServiceV1.debugResetTelemetryEmissionV1();
    await PremiumService().clear();
  });

  test(
    'status facade returns deterministic default payload and source',
    () async {
      await PremiumService().disablePremium();
      final statusA = await SubscriptionServiceV1.getStatusV1();
      final statusB = await SubscriptionServiceV1.getStatusV1();

      expect(statusA.schemaVersion, 1);
      expect(statusA.source, SubscriptionSourceV1.none);
      expect(statusA.isPremium, isFalse);
      expect(statusA.isEntitled, isFalse);
      expect(statusA.isTrialActive, isFalse);
      expect(statusA.accessState, SubscriptionAccessStateV1.free);
      expect(jsonEncode(statusA.toJson()), jsonEncode(statusB.toJson()));
    },
  );

  test('status checked telemetry is deterministic and emitted once', () async {
    final captured = <Map<String, dynamic>>[];
    Telemetry.overrideLogHandler((name, payload) async {
      if (name == 'subscription_status_checked_v1' && payload != null) {
        captured.add(Map<String, dynamic>.from(payload));
      }
    });
    try {
      await PremiumService().enablePremium();
      final first = await SubscriptionServiceV1.getStatusV1();
      final second = await SubscriptionServiceV1.getStatusV1();
      expect(first.isPremium, isTrue);
      expect(second.isPremium, isTrue);
      expect(first.isEntitled, isTrue);
      expect(first.accessState, SubscriptionAccessStateV1.premium);

      expect(captured, hasLength(1));
      final payload = captured.single;
      expect(payload['schemaVersion'], 1);
      expect(payload['isPremium'], true);
      expect(payload['source'], 'premiumService');
      expect(jsonEncode(payload), jsonEncode(captured.single));
    } finally {
      Telemetry.overrideLogHandler(null);
    }
  });

  test(
    'entitlement ssot resolves premium and trial states deterministically',
    () async {
      final nowEpochMs = DateTime.utc(2026, 3, 3, 12).millisecondsSinceEpoch;

      // premium=true, trial=false => entitled
      await PremiumService().enablePremium();
      var entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: nowEpochMs,
      );
      expect(entitled, isTrue);
      var status = await SubscriptionServiceV1.getStatusV1(
        nowEpochMs: nowEpochMs,
      );
      expect(status.isPremium, isTrue);
      expect(status.isEntitled, isTrue);
      expect(status.isTrialActive, isFalse);
      expect(status.source, SubscriptionSourceV1.premiumService);
      expect(status.accessState, SubscriptionAccessStateV1.premium);

      // premium=false, trial=true => entitled
      await PremiumService().disablePremium();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
      );
      entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: nowEpochMs,
      );
      expect(entitled, isTrue);
      status = await SubscriptionServiceV1.getStatusV1(nowEpochMs: nowEpochMs);
      expect(status.isPremium, isFalse);
      expect(status.isEntitled, isTrue);
      expect(status.isTrialActive, isTrue);
      expect(status.source, SubscriptionSourceV1.trial);
      expect(status.accessState, SubscriptionAccessStateV1.trial);

      // premium=false, trial=false => not entitled
      await prefs.remove('trial_entitlement_v1');
      entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: nowEpochMs,
      );
      expect(entitled, isFalse);
      status = await SubscriptionServiceV1.getStatusV1(nowEpochMs: nowEpochMs);
      expect(status.isPremium, isFalse);
      expect(status.isEntitled, isFalse);
      expect(status.isTrialActive, isFalse);
      expect(status.source, SubscriptionSourceV1.none);
      expect(status.accessState, SubscriptionAccessStateV1.free);

      // premium=true and trial=true => entitled with deterministic premium source
      await PremiumService().enablePremium();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
      );
      entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: nowEpochMs,
      );
      expect(entitled, isTrue);
      status = await SubscriptionServiceV1.getStatusV1(nowEpochMs: nowEpochMs);
      expect(status.isPremium, isTrue);
      expect(status.isEntitled, isTrue);
      expect(status.isTrialActive, isFalse);
      expect(status.source, SubscriptionSourceV1.premiumService);
      expect(status.accessState, SubscriptionAccessStateV1.premium);
    },
  );
}
