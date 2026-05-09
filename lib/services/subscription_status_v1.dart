import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/infra/telemetry.dart';

import 'entitlement_ssot_v1.dart';

// Append-only enum for deterministic source tagging.
enum SubscriptionSourceV1 { none, premiumService, trial }

// Append-only enum for deterministic access-state labeling.
enum SubscriptionAccessStateV1 { free, trial, premium }

@immutable
class SubscriptionStatusV1 {
  const SubscriptionStatusV1({
    this.schemaVersion = 1,
    required this.isPremium,
    required this.isEntitled,
    required this.isTrialActive,
    required this.trialRemainingDays,
    required this.source,
    required this.accessState,
  });

  final int schemaVersion;
  final bool isPremium;
  final bool isEntitled;
  final bool isTrialActive;
  final int trialRemainingDays;
  final SubscriptionSourceV1 source;
  final SubscriptionAccessStateV1 accessState;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': schemaVersion,
    'isPremium': isPremium,
    'isEntitled': isEntitled,
    'isTrialActive': isTrialActive,
    'trialRemainingDays': trialRemainingDays,
    'source': source.name,
    'accessState': accessState.name,
  };
}

class SubscriptionServiceV1 {
  static const String _statusCheckedEventV1 = 'subscription_status_checked_v1';
  static bool _didEmitCheckedEventV1 = false;

  static Future<SubscriptionStatusV1> getStatusV1({int? nowEpochMs}) async {
    final state = await EntitlementSSOTV1.instance.readPremiumStateV1(
      nowEpochMs: nowEpochMs,
    );
    final source = state.premiumActiveFlag
        ? SubscriptionSourceV1.premiumService
        : (state.trialActive
              ? SubscriptionSourceV1.trial
              : SubscriptionSourceV1.none);
    final accessState = state.premiumActiveFlag
        ? SubscriptionAccessStateV1.premium
        : (state.trialActive
              ? SubscriptionAccessStateV1.trial
              : SubscriptionAccessStateV1.free);
    final status = SubscriptionStatusV1(
      isPremium: state.premiumActiveFlag,
      isEntitled: state.isEntitledToPremium,
      isTrialActive: state.trialActive,
      trialRemainingDays: state.trialRemainingDays,
      source: source,
      accessState: accessState,
    );
    if (!_didEmitCheckedEventV1) {
      _didEmitCheckedEventV1 = true;
      await Telemetry.logEvent(_statusCheckedEventV1, status.toJson());
    }
    return status;
  }

  static Stream<SubscriptionStatusV1> watchStatusV1() async* {
    yield await getStatusV1();
  }

  @visibleForTesting
  static void debugResetTelemetryEmissionV1() {
    _didEmitCheckedEventV1 = false;
  }
}
