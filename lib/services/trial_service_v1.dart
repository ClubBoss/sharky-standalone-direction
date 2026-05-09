import 'dart:convert';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entitlement_sync_v1.dart';
import 'premium_service.dart';

class TrialEntitlementV1 {
  const TrialEntitlementV1({
    this.schemaVersion = 1,
    required this.startEpochMs,
    this.durationDays = 7,
  });

  final int schemaVersion;
  final int startEpochMs;
  final int durationDays;

  int get endEpochMs => startEpochMs + (durationDays * _kMsPerDay);

  bool isActive(int nowEpochMs) => nowEpochMs < endEpochMs;

  int remainingDays(int nowEpochMs) {
    if (!isActive(nowEpochMs)) return 0;
    final remainingMs = endEpochMs - nowEpochMs;
    final fullDays = remainingMs ~/ _kMsPerDay;
    return fullDays <= 0 ? 1 : fullDays;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'startEpochMs': startEpochMs,
    'durationDays': durationDays,
  };

  static TrialEntitlementV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final schemaVersion = _safeInt(raw['schemaVersion']);
    final startEpochMs = _safeInt(raw['startEpochMs']);
    final durationDays = _safeInt(raw['durationDays']);
    if (schemaVersion != 1 || startEpochMs <= 0 || durationDays <= 0) {
      return null;
    }
    return TrialEntitlementV1(
      schemaVersion: schemaVersion,
      startEpochMs: startEpochMs,
      durationDays: durationDays,
    );
  }
}

class TrialStatusV1 {
  const TrialStatusV1({
    this.schemaVersion = 1,
    required this.isPremium,
    required this.isTrialActive,
    required this.remainingDays,
    required this.isEligible,
    required this.reason,
  });

  final int schemaVersion;
  final bool isPremium;
  final bool isTrialActive;
  final int remainingDays;
  final bool isEligible;
  final String reason;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'isPremium': isPremium,
    'isTrialActive': isTrialActive,
    'remainingDays': remainingDays,
    'isEligible': isEligible,
    'reason': reason,
  };
}

class TrialServiceV1 {
  static const String _entitlementKey = 'trial_entitlement_v1';
  static const String _placementCompletedKey = 'trial_placement_completed_v1';
  static const String _offerShownLoggedKey = 'trial_offer_shown_logged_v1';
  static const String _statusTelemetryDayKey = 'trial_status_day_key_v1';
  static const String _lastSeenEpochMsKey = 'trial_last_seen_epoch_ms_v1';
  static const String _clockRollbackDetectedKey =
      'trial_clock_rollback_detected_v1';
  static const String _clockRollbackTelemetryEventV1 =
      'trial_clock_rollback_detected_v1';
  static const int _rollbackSkewMs = 5 * 60 * 1000;

  static Future<void> markPlacementCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_placementCompletedKey, true);
  }

  static Future<TrialStatusV1> getTrialStatusV1({
    required int nowEpochMs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = await PremiumService().isPremiumActive();
    var rollbackDetected = prefs.getBool(_clockRollbackDetectedKey) ?? false;
    final lastSeenEpochMs = prefs.getInt(_lastSeenEpochMsKey) ?? 0;
    if (!rollbackDetected &&
        lastSeenEpochMs > 0 &&
        nowEpochMs < (lastSeenEpochMs - _rollbackSkewMs)) {
      rollbackDetected = true;
      await prefs.setBool(_clockRollbackDetectedKey, true);
      await Telemetry.logEvent(
        _clockRollbackTelemetryEventV1,
        <String, dynamic>{
          'schemaVersion': 1,
          'skewMs': lastSeenEpochMs - nowEpochMs,
          'nowEpochMs': nowEpochMs,
          'lastSeenEpochMs': lastSeenEpochMs,
        },
      );
    }
    final nextSeenEpochMs = nowEpochMs > lastSeenEpochMs
        ? nowEpochMs
        : lastSeenEpochMs;
    await prefs.setInt(_lastSeenEpochMsKey, nextSeenEpochMs);
    final entitlement = _readEntitlementV1(prefs);
    final isTrialActive = entitlement?.isActive(nowEpochMs) ?? false;
    final remainingDays = entitlement?.remainingDays(nowEpochMs) ?? 0;
    final placementCompleted = prefs.getBool(_placementCompletedKey) ?? false;

    if (isPremium) {
      return const TrialStatusV1(
        isPremium: true,
        isTrialActive: false,
        remainingDays: 0,
        isEligible: false,
        reason: 'premium_active',
      );
    }
    if (rollbackDetected) {
      return const TrialStatusV1(
        isPremium: false,
        isTrialActive: false,
        remainingDays: 0,
        isEligible: false,
        reason: 'clock_rollback',
      );
    }
    if (isTrialActive) {
      return TrialStatusV1(
        isPremium: false,
        isTrialActive: true,
        remainingDays: remainingDays,
        isEligible: false,
        reason: 'trial_active',
      );
    }
    if (entitlement != null) {
      return const TrialStatusV1(
        isPremium: false,
        isTrialActive: false,
        remainingDays: 0,
        isEligible: false,
        reason: 'trial_already_used',
      );
    }
    if (!placementCompleted) {
      return const TrialStatusV1(
        isPremium: false,
        isTrialActive: false,
        remainingDays: 0,
        isEligible: false,
        reason: 'placement_incomplete',
      );
    }
    return const TrialStatusV1(
      isPremium: false,
      isTrialActive: false,
      remainingDays: 0,
      isEligible: true,
      reason: 'eligible',
    );
  }

  static Future<TrialStatusV1> startTrialIfEligibleV1({
    required int nowEpochMs,
  }) async {
    final status = await getTrialStatusV1(nowEpochMs: nowEpochMs);
    if (!status.isEligible) {
      return status;
    }
    final prefs = await SharedPreferences.getInstance();
    final entitlement = TrialEntitlementV1(startEpochMs: nowEpochMs);
    await prefs.setString(_entitlementKey, jsonEncode(entitlement.toJson()));
    EntitlementSyncV1.markChanged();
    return getTrialStatusV1(nowEpochMs: nowEpochMs);
  }

  static Future<bool> consumeOfferShownTelemetryTokenV1() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyLogged = prefs.getBool(_offerShownLoggedKey) ?? false;
    if (alreadyLogged) {
      return false;
    }
    await prefs.setBool(_offerShownLoggedKey, true);
    return true;
  }

  static Future<bool> consumeStatusTelemetryForDayV1({
    required int nowEpochMs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = nowEpochMs ~/ _kMsPerDay;
    final storedDayKey = prefs.getInt(_statusTelemetryDayKey);
    if (storedDayKey == dayKey) {
      return false;
    }
    await prefs.setInt(_statusTelemetryDayKey, dayKey);
    return true;
  }

  static TrialEntitlementV1? _readEntitlementV1(SharedPreferences prefs) {
    final raw = prefs.getString(_entitlementKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      return TrialEntitlementV1.tryParse(decoded);
    } catch (_) {
      return null;
    }
  }
}

const int _kMsPerDay = 24 * 60 * 60 * 1000;

int _safeInt(Object? raw) {
  if (raw is int) return raw;
  return int.tryParse(raw?.toString() ?? '') ?? 0;
}
