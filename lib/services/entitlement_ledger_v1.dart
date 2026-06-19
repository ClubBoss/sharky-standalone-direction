import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entitlement_sync_v1.dart';

const int _kMsPerDayV1 = 24 * 60 * 60 * 1000;

enum EntitlementLedgerStatusV1 {
  free,
  trialEligible,
  trialActive,
  trialExpired,
  premiumActive,
  verificationPending,
  verificationFailed,
  storeUnavailable,
}

enum EntitlementLedgerSourceV1 {
  none,
  migrationPremiumFlag,
  migrationTrial,
  localTrial,
  verifiedPurchase,
  verifiedRestore,
  adminDebug,
  testOnly,
  localProductConvergence,
  localRestore,
}

enum EntitlementLedgerRestoreStateV1 {
  none,
  pending,
  restored,
  noPurchaseFound,
  failed,
}

enum EntitlementLedgerEnvironmentV1 { debug, test, sandbox, production }

enum EntitlementTrialStateKindV1 {
  unknown,
  notEligible,
  eligible,
  active,
  expired,
  blockedByPremium,
  blockedByRollback,
  alreadyUsed,
}

enum EntitlementSubscriptionStateKindV1 {
  none,
  pending,
  active,
  restored,
  expired,
  gracePeriod,
  revoked,
  refunded,
  verificationFailed,
}

enum EntitlementAccessWhyV1 {
  free,
  trialEligible,
  trialActive,
  legacyPremiumFlag,
  verifiedPurchase,
  verifiedRestore,
  expired,
  verificationPending,
  verificationFailed,
  storeUnavailable,
}

@immutable
class EntitlementTrialStateV1 {
  const EntitlementTrialStateV1({
    required this.state,
    this.startEpochMs,
    this.endEpochMs,
    this.durationDays,
    this.remainingDays = 0,
    this.eligibilityReason = 'unknown',
    this.placementCompleted = false,
    this.clockRollbackDetected = false,
    this.lastSeenEpochMs,
  });

  const EntitlementTrialStateV1.unknown()
    : state = EntitlementTrialStateKindV1.unknown,
      startEpochMs = null,
      endEpochMs = null,
      durationDays = null,
      remainingDays = 0,
      eligibilityReason = 'unknown',
      placementCompleted = false,
      clockRollbackDetected = false,
      lastSeenEpochMs = null;

  final EntitlementTrialStateKindV1 state;
  final int? startEpochMs;
  final int? endEpochMs;
  final int? durationDays;
  final int remainingDays;
  final String eligibilityReason;
  final bool placementCompleted;
  final bool clockRollbackDetected;
  final int? lastSeenEpochMs;

  Map<String, Object?> toJson() => <String, Object?>{
    'state': state.name,
    'startEpochMs': startEpochMs,
    'endEpochMs': endEpochMs,
    'durationDays': durationDays,
    'remainingDays': remainingDays,
    'eligibilityReason': eligibilityReason,
    'placementCompleted': placementCompleted,
    'clockRollbackDetected': clockRollbackDetected,
    'lastSeenEpochMs': lastSeenEpochMs,
  };

  static EntitlementTrialStateV1 fromJson(Object? raw) {
    if (raw is! Map) return const EntitlementTrialStateV1.unknown();
    return EntitlementTrialStateV1(
      state: _enumByName(
        EntitlementTrialStateKindV1.values,
        raw['state'],
        EntitlementTrialStateKindV1.unknown,
      ),
      startEpochMs: _nullableInt(raw['startEpochMs']),
      endEpochMs: _nullableInt(raw['endEpochMs']),
      durationDays: _nullableInt(raw['durationDays']),
      remainingDays: _safeInt(raw['remainingDays']),
      eligibilityReason: raw['eligibilityReason']?.toString() ?? 'unknown',
      placementCompleted: raw['placementCompleted'] == true,
      clockRollbackDetected: raw['clockRollbackDetected'] == true,
      lastSeenEpochMs: _nullableInt(raw['lastSeenEpochMs']),
    );
  }
}

@immutable
class EntitlementSubscriptionStateV1 {
  const EntitlementSubscriptionStateV1({
    this.state = EntitlementSubscriptionStateKindV1.none,
    this.verified = false,
    this.productId,
    this.expiresAtEpochMs,
  });

  final EntitlementSubscriptionStateKindV1 state;
  final bool verified;
  final String? productId;
  final int? expiresAtEpochMs;

  Map<String, Object?> toJson() => <String, Object?>{
    'state': state.name,
    'verified': verified,
    'productId': productId,
    'expiresAtEpochMs': expiresAtEpochMs,
  };

  static EntitlementSubscriptionStateV1 fromJson(Object? raw) {
    if (raw is! Map) return const EntitlementSubscriptionStateV1();
    return EntitlementSubscriptionStateV1(
      state: _enumByName(
        EntitlementSubscriptionStateKindV1.values,
        raw['state'],
        EntitlementSubscriptionStateKindV1.none,
      ),
      verified: raw['verified'] == true,
      productId: raw['productId']?.toString(),
      expiresAtEpochMs: _nullableInt(raw['expiresAtEpochMs']),
    );
  }
}

@immutable
class EntitlementAccessV1 {
  const EntitlementAccessV1({
    this.schemaVersion = 1,
    required this.canAccessPremium,
    required this.why,
    required this.entitlementStatus,
    required this.isTrialActive,
    required this.trialRemainingDays,
    required this.isSubscriptionVerified,
    required this.restoreState,
    required this.publicCommerceSafe,
    required this.shouldExposePremiumPreview,
    required this.shouldExposePublicPaywall,
    required this.shouldHidePublicPaywall,
    required this.shouldHidePremiumHub,
  });

  final int schemaVersion;
  final bool canAccessPremium;
  final EntitlementAccessWhyV1 why;
  final EntitlementLedgerStatusV1 entitlementStatus;
  final bool isTrialActive;
  final int trialRemainingDays;
  final bool isSubscriptionVerified;
  final EntitlementLedgerRestoreStateV1 restoreState;
  final bool publicCommerceSafe;
  final bool shouldExposePremiumPreview;
  final bool shouldExposePublicPaywall;
  final bool shouldHidePublicPaywall;
  final bool shouldHidePremiumHub;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'canAccessPremium': canAccessPremium,
    'why': why.name,
    'entitlementStatus': entitlementStatus.name,
    'isTrialActive': isTrialActive,
    'trialRemainingDays': trialRemainingDays,
    'isSubscriptionVerified': isSubscriptionVerified,
    'restoreState': restoreState.name,
    'publicCommerceSafe': publicCommerceSafe,
    'shouldExposePremiumPreview': shouldExposePremiumPreview,
    'shouldExposePublicPaywall': shouldExposePublicPaywall,
    'shouldHidePublicPaywall': shouldHidePublicPaywall,
    'shouldHidePremiumHub': shouldHidePremiumHub,
  };
}

@immutable
class EntitlementLedgerV1 {
  const EntitlementLedgerV1({
    this.schemaVersion = 1,
    required this.entitlementStatus,
    required this.source,
    required this.trialState,
    this.subscriptionState = const EntitlementSubscriptionStateV1(),
    this.storeProductId,
    this.expiresAtEpochMs,
    this.lastVerifiedAtEpochMs,
    this.restoreState = EntitlementLedgerRestoreStateV1.none,
    this.environment = EntitlementLedgerEnvironmentV1.debug,
    required this.updatedAtEpochMs,
    this.migrationSourceKeys = const <String>[],
    this.productCacheProductIds = const <String>[],
    this.isPublicCommerceSafe = false,
    this.lastErrorCode,
  });

  factory EntitlementLedgerV1.free({required int nowEpochMs}) =>
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.free,
        source: EntitlementLedgerSourceV1.none,
        trialState: const EntitlementTrialStateV1.unknown(),
        updatedAtEpochMs: nowEpochMs,
      );

  final int schemaVersion;
  final EntitlementLedgerStatusV1 entitlementStatus;
  final EntitlementLedgerSourceV1 source;
  final EntitlementTrialStateV1 trialState;
  final EntitlementSubscriptionStateV1 subscriptionState;
  final String? storeProductId;
  final int? expiresAtEpochMs;
  final int? lastVerifiedAtEpochMs;
  final EntitlementLedgerRestoreStateV1 restoreState;
  final EntitlementLedgerEnvironmentV1 environment;
  final int updatedAtEpochMs;
  final List<String> migrationSourceKeys;
  final List<String> productCacheProductIds;
  final bool isPublicCommerceSafe;
  final String? lastErrorCode;

  EntitlementAccessV1 toAccess({required int nowEpochMs}) {
    final effectiveStatus =
        entitlementStatus == EntitlementLedgerStatusV1.trialActive &&
            expiresAtEpochMs != null &&
            nowEpochMs >= expiresAtEpochMs!
        ? EntitlementLedgerStatusV1.trialExpired
        : entitlementStatus;
    final trialActive =
        effectiveStatus == EntitlementLedgerStatusV1.trialActive;
    final trialRemainingDays = trialActive && expiresAtEpochMs != null
        ? _remainingDays(nowEpochMs, expiresAtEpochMs!)
        : 0;
    final premiumActive =
        effectiveStatus == EntitlementLedgerStatusV1.premiumActive;
    final canAccessPremium = premiumActive || trialActive;
    return EntitlementAccessV1(
      canAccessPremium: canAccessPremium,
      why: _whyForStatus(effectiveStatus, source),
      entitlementStatus: effectiveStatus,
      isTrialActive: trialActive,
      trialRemainingDays: trialRemainingDays,
      isSubscriptionVerified: subscriptionState.verified,
      restoreState: restoreState,
      publicCommerceSafe: canAccessPremium && isPublicCommerceSafe,
      shouldExposePremiumPreview: canAccessPremium,
      shouldExposePublicPaywall: false,
      shouldHidePublicPaywall: true,
      shouldHidePremiumHub: true,
    );
  }

  EntitlementLedgerV1 copyWith({
    EntitlementLedgerStatusV1? entitlementStatus,
    EntitlementLedgerSourceV1? source,
    EntitlementTrialStateV1? trialState,
    EntitlementSubscriptionStateV1? subscriptionState,
    String? storeProductId,
    int? expiresAtEpochMs,
    int? lastVerifiedAtEpochMs,
    EntitlementLedgerRestoreStateV1? restoreState,
    EntitlementLedgerEnvironmentV1? environment,
    int? updatedAtEpochMs,
    List<String>? migrationSourceKeys,
    List<String>? productCacheProductIds,
    bool? isPublicCommerceSafe,
    String? lastErrorCode,
  }) {
    return EntitlementLedgerV1(
      schemaVersion: schemaVersion,
      entitlementStatus: entitlementStatus ?? this.entitlementStatus,
      source: source ?? this.source,
      trialState: trialState ?? this.trialState,
      subscriptionState: subscriptionState ?? this.subscriptionState,
      storeProductId: storeProductId ?? this.storeProductId,
      expiresAtEpochMs: expiresAtEpochMs ?? this.expiresAtEpochMs,
      lastVerifiedAtEpochMs:
          lastVerifiedAtEpochMs ?? this.lastVerifiedAtEpochMs,
      restoreState: restoreState ?? this.restoreState,
      environment: environment ?? this.environment,
      updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
      migrationSourceKeys: migrationSourceKeys ?? this.migrationSourceKeys,
      productCacheProductIds:
          productCacheProductIds ?? this.productCacheProductIds,
      isPublicCommerceSafe: isPublicCommerceSafe ?? this.isPublicCommerceSafe,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'entitlementStatus': entitlementStatus.name,
    'source': source.name,
    'trialState': trialState.toJson(),
    'subscriptionState': subscriptionState.toJson(),
    'storeProductId': storeProductId,
    'expiresAtEpochMs': expiresAtEpochMs,
    'lastVerifiedAtEpochMs': lastVerifiedAtEpochMs,
    'restoreState': restoreState.name,
    'environment': environment.name,
    'updatedAtEpochMs': updatedAtEpochMs,
    'migrationSourceKeys': migrationSourceKeys,
    'productCacheProductIds': productCacheProductIds,
    'isPublicCommerceSafe': isPublicCommerceSafe,
    'lastErrorCode': lastErrorCode,
  };

  static EntitlementLedgerV1? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final schemaVersion = _safeInt(decoded['schemaVersion']);
      if (schemaVersion != 1) return null;
      return EntitlementLedgerV1(
        schemaVersion: schemaVersion,
        entitlementStatus: _enumByName(
          EntitlementLedgerStatusV1.values,
          decoded['entitlementStatus'],
          EntitlementLedgerStatusV1.free,
        ),
        source: _enumByName(
          EntitlementLedgerSourceV1.values,
          decoded['source'],
          EntitlementLedgerSourceV1.none,
        ),
        trialState: EntitlementTrialStateV1.fromJson(decoded['trialState']),
        subscriptionState: EntitlementSubscriptionStateV1.fromJson(
          decoded['subscriptionState'],
        ),
        storeProductId: decoded['storeProductId']?.toString(),
        expiresAtEpochMs: _nullableInt(decoded['expiresAtEpochMs']),
        lastVerifiedAtEpochMs: _nullableInt(decoded['lastVerifiedAtEpochMs']),
        restoreState: _enumByName(
          EntitlementLedgerRestoreStateV1.values,
          decoded['restoreState'],
          EntitlementLedgerRestoreStateV1.none,
        ),
        environment: _enumByName(
          EntitlementLedgerEnvironmentV1.values,
          decoded['environment'],
          EntitlementLedgerEnvironmentV1.debug,
        ),
        updatedAtEpochMs: _safeInt(decoded['updatedAtEpochMs']),
        migrationSourceKeys: _stringList(decoded['migrationSourceKeys']),
        productCacheProductIds: _stringList(decoded['productCacheProductIds']),
        isPublicCommerceSafe: decoded['isPublicCommerceSafe'] == true,
        lastErrorCode: decoded['lastErrorCode']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }
}

class EntitlementLedgerServiceV1 {
  EntitlementLedgerServiceV1._();

  static final EntitlementLedgerServiceV1 instance =
      EntitlementLedgerServiceV1._();

  static const String ledgerKeyV1 = 'entitlement_ledger_v1';
  static EntitlementLedgerV1? _debugOverrideLedgerV1;

  Future<EntitlementLedgerV1> readLedgerV1({int? nowEpochMs}) async {
    final safeNowEpochMs =
        nowEpochMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    final debugOverride = _debugOverrideLedgerV1;
    if (debugOverride != null) {
      return debugOverride;
    }
    final prefs = await SharedPreferences.getInstance();
    final existing = EntitlementLedgerV1.tryParse(prefs.getString(ledgerKeyV1));
    if (existing != null && !_shouldReconcileLegacyForRead(existing)) {
      return existing;
    }
    final premiumActive = prefs.getBool('premium_is_active') ?? false;
    final migrated = _buildFromLegacyPrefs(
      prefs,
      safeNowEpochMs,
      premiumActive: premiumActive,
    );
    await _writeLedgerV1(prefs, migrated);
    return migrated;
  }

  Future<EntitlementAccessV1> readAccessV1({int? nowEpochMs}) async {
    final safeNowEpochMs =
        nowEpochMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    final ledger = await readLedgerV1(nowEpochMs: safeNowEpochMs);
    return ledger.toAccess(nowEpochMs: safeNowEpochMs);
  }

  Future<bool> isEntitledToPremiumV1({int? nowEpochMs}) async {
    final access = await readAccessV1(nowEpochMs: nowEpochMs);
    return access.canAccessPremium;
  }

  Future<void> recordTrialStartedV1({
    required int startEpochMs,
    required int durationDays,
    required int nowEpochMs,
    bool placementCompleted = true,
    int? lastSeenEpochMs,
  }) async {
    final endEpochMs = startEpochMs + (durationDays * _kMsPerDayV1);
    await _writeLedgerFromValueV1(
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.trialActive,
        source: EntitlementLedgerSourceV1.localTrial,
        trialState: EntitlementTrialStateV1(
          state: EntitlementTrialStateKindV1.active,
          startEpochMs: startEpochMs,
          endEpochMs: endEpochMs,
          durationDays: durationDays,
          remainingDays: _remainingDays(nowEpochMs, endEpochMs),
          eligibilityReason: 'trial_active',
          placementCompleted: placementCompleted,
          lastSeenEpochMs: lastSeenEpochMs,
        ),
        expiresAtEpochMs: endEpochMs,
        updatedAtEpochMs: nowEpochMs,
        migrationSourceKeys: const <String>['trial_entitlement_v1'],
        isPublicCommerceSafe: false,
      ),
    );
  }

  Future<void> recordTrialExpiredV1({
    required int startEpochMs,
    required int durationDays,
    required int nowEpochMs,
    bool placementCompleted = true,
    int? lastSeenEpochMs,
  }) async {
    final endEpochMs = startEpochMs + (durationDays * _kMsPerDayV1);
    await _writeLedgerFromValueV1(
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.trialExpired,
        source: EntitlementLedgerSourceV1.localTrial,
        trialState: EntitlementTrialStateV1(
          state: EntitlementTrialStateKindV1.expired,
          startEpochMs: startEpochMs,
          endEpochMs: endEpochMs,
          durationDays: durationDays,
          remainingDays: 0,
          eligibilityReason: 'trial_already_used',
          placementCompleted: placementCompleted,
          lastSeenEpochMs: lastSeenEpochMs,
        ),
        expiresAtEpochMs: endEpochMs,
        updatedAtEpochMs: nowEpochMs,
        migrationSourceKeys: const <String>['trial_entitlement_v1'],
        isPublicCommerceSafe: false,
      ),
    );
  }

  Future<void> recordTrialClockRollbackV1({
    required int nowEpochMs,
    int? startEpochMs,
    int? durationDays,
    int? lastSeenEpochMs,
    bool placementCompleted = true,
  }) async {
    final endEpochMs = startEpochMs == null || durationDays == null
        ? null
        : startEpochMs + (durationDays * _kMsPerDayV1);
    await _writeLedgerFromValueV1(
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.verificationFailed,
        source: EntitlementLedgerSourceV1.localTrial,
        trialState: EntitlementTrialStateV1(
          state: EntitlementTrialStateKindV1.blockedByRollback,
          startEpochMs: startEpochMs,
          endEpochMs: endEpochMs,
          durationDays: durationDays,
          remainingDays: 0,
          eligibilityReason: 'clock_rollback',
          placementCompleted: placementCompleted,
          clockRollbackDetected: true,
          lastSeenEpochMs: lastSeenEpochMs,
        ),
        expiresAtEpochMs: endEpochMs,
        updatedAtEpochMs: nowEpochMs,
        migrationSourceKeys: const <String>[
          'trial_entitlement_v1',
          'trial_clock_rollback_detected_v1',
        ],
        isPublicCommerceSafe: false,
        lastErrorCode: 'clock_rollback',
      ),
    );
  }

  Future<void> recordRestorePendingV1({required int nowEpochMs}) async {
    await _writeLedgerFromValueV1(
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.verificationPending,
        source: EntitlementLedgerSourceV1.localRestore,
        trialState: const EntitlementTrialStateV1.unknown(),
        restoreState: EntitlementLedgerRestoreStateV1.pending,
        updatedAtEpochMs: nowEpochMs,
        isPublicCommerceSafe: false,
      ),
    );
  }

  Future<void> recordNoPurchaseFoundRestoreV1({required int nowEpochMs}) async {
    final base = await _readLedgerForWriteV1(nowEpochMs: nowEpochMs);
    final shouldClearPending =
        base.entitlementStatus == EntitlementLedgerStatusV1.verificationPending;
    await _writeLedgerFromValueV1(
      base.copyWith(
        entitlementStatus: shouldClearPending
            ? EntitlementLedgerStatusV1.free
            : base.entitlementStatus,
        source: EntitlementLedgerSourceV1.localRestore,
        restoreState: EntitlementLedgerRestoreStateV1.noPurchaseFound,
        updatedAtEpochMs: nowEpochMs,
        isPublicCommerceSafe: false,
      ),
    );
  }

  Future<void> recordVerificationFailedV1({
    required int nowEpochMs,
    EntitlementLedgerRestoreStateV1 restoreState =
        EntitlementLedgerRestoreStateV1.failed,
    String? errorCode,
  }) async {
    final base = await _readLedgerForWriteV1(nowEpochMs: nowEpochMs);
    final keepExistingAccess = base
        .toAccess(nowEpochMs: nowEpochMs)
        .canAccessPremium;
    await _writeLedgerFromValueV1(
      base.copyWith(
        entitlementStatus: keepExistingAccess
            ? base.entitlementStatus
            : EntitlementLedgerStatusV1.verificationFailed,
        source: restoreState == EntitlementLedgerRestoreStateV1.failed
            ? EntitlementLedgerSourceV1.localRestore
            : base.source,
        restoreState: restoreState,
        updatedAtEpochMs: nowEpochMs,
        isPublicCommerceSafe: false,
        lastErrorCode: errorCode ?? 'verification_failed',
      ),
    );
  }

  Future<void> recordLocalRestoreSuccessV1({
    required int nowEpochMs,
    String? storeProductId,
  }) async {
    await _writeLedgerFromValueV1(
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.premiumActive,
        source: EntitlementLedgerSourceV1.localRestore,
        trialState: const EntitlementTrialStateV1(
          state: EntitlementTrialStateKindV1.blockedByPremium,
          eligibilityReason: 'premium_active',
        ),
        subscriptionState: EntitlementSubscriptionStateV1(
          state: EntitlementSubscriptionStateKindV1.restored,
          verified: false,
          productId: storeProductId,
        ),
        storeProductId: storeProductId,
        restoreState: EntitlementLedgerRestoreStateV1.restored,
        updatedAtEpochMs: nowEpochMs,
        productCacheProductIds: storeProductId == null
            ? const <String>[]
            : <String>[storeProductId],
        isPublicCommerceSafe: false,
      ),
    );
  }

  Future<void> recordPurchasePendingV1({
    required String productId,
    required int nowEpochMs,
  }) async {
    await _writeLedgerFromValueV1(
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.verificationPending,
        source: EntitlementLedgerSourceV1.localProductConvergence,
        trialState: const EntitlementTrialStateV1.unknown(),
        subscriptionState: EntitlementSubscriptionStateV1(
          state: EntitlementSubscriptionStateKindV1.pending,
          productId: productId,
          verified: false,
        ),
        storeProductId: productId,
        updatedAtEpochMs: nowEpochMs,
        productCacheProductIds: <String>[productId],
        isPublicCommerceSafe: false,
      ),
    );
  }

  Future<void> recordLocalProductConvergenceV1({
    required String productId,
    required bool grantsPremium,
    required int nowEpochMs,
  }) async {
    final base = await _readLedgerForWriteV1(nowEpochMs: nowEpochMs);
    final productCache = _addUnique(base.productCacheProductIds, productId);
    if (!grantsPremium) {
      await _writeLedgerFromValueV1(
        base.copyWith(
          source: EntitlementLedgerSourceV1.localProductConvergence,
          productCacheProductIds: productCache,
          updatedAtEpochMs: nowEpochMs,
          isPublicCommerceSafe: false,
        ),
      );
      return;
    }
    await _writeLedgerFromValueV1(
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.premiumActive,
        source: EntitlementLedgerSourceV1.localProductConvergence,
        trialState: const EntitlementTrialStateV1(
          state: EntitlementTrialStateKindV1.blockedByPremium,
          eligibilityReason: 'premium_active',
        ),
        subscriptionState: EntitlementSubscriptionStateV1(
          state: EntitlementSubscriptionStateKindV1.active,
          productId: productId,
          verified: false,
        ),
        storeProductId: productId,
        updatedAtEpochMs: nowEpochMs,
        productCacheProductIds: productCache,
        isPublicCommerceSafe: false,
      ),
    );
  }

  Future<void> recordDebugPremiumFlagV1({
    required bool active,
    required int nowEpochMs,
  }) async {
    if (!active) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ledgerKeyV1);
      EntitlementSyncV1.markChanged();
      return;
    }
    await _writeLedgerFromValueV1(
      EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.premiumActive,
        source: EntitlementLedgerSourceV1.adminDebug,
        trialState: const EntitlementTrialStateV1(
          state: EntitlementTrialStateKindV1.blockedByPremium,
          eligibilityReason: 'premium_active',
        ),
        environment: EntitlementLedgerEnvironmentV1.debug,
        updatedAtEpochMs: nowEpochMs,
        migrationSourceKeys: const <String>['premium_is_active'],
        isPublicCommerceSafe: false,
      ),
    );
  }

  @visibleForTesting
  Future<void> debugSetLedgerForTestsOnlyV1(EntitlementLedgerV1 ledger) async {
    _debugOverrideLedgerV1 = ledger.copyWith(
      source: ledger.source == EntitlementLedgerSourceV1.adminDebug
          ? EntitlementLedgerSourceV1.adminDebug
          : EntitlementLedgerSourceV1.testOnly,
      environment: EntitlementLedgerEnvironmentV1.test,
      isPublicCommerceSafe: false,
    );
  }

  @visibleForTesting
  Future<void> debugClearLedgerForTestsOnlyV1() async {
    _debugOverrideLedgerV1 = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ledgerKeyV1);
  }

  Future<void> _writeLedgerV1(
    SharedPreferences prefs,
    EntitlementLedgerV1 ledger,
  ) async {
    await prefs.setString(ledgerKeyV1, jsonEncode(ledger.toJson()));
  }

  Future<void> _writeLedgerFromValueV1(EntitlementLedgerV1 ledger) async {
    final prefs = await SharedPreferences.getInstance();
    await _writeLedgerV1(prefs, ledger);
    EntitlementSyncV1.markChanged();
  }

  Future<EntitlementLedgerV1> _readLedgerForWriteV1({
    required int nowEpochMs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = EntitlementLedgerV1.tryParse(prefs.getString(ledgerKeyV1));
    if (existing != null) return existing;
    final premiumActive = prefs.getBool('premium_is_active') ?? false;
    return _buildFromLegacyPrefs(
      prefs,
      nowEpochMs,
      premiumActive: premiumActive,
    );
  }

  bool _shouldReconcileLegacyForRead(EntitlementLedgerV1 existing) {
    return existing.source == EntitlementLedgerSourceV1.none ||
        existing.source == EntitlementLedgerSourceV1.migrationPremiumFlag ||
        existing.source == EntitlementLedgerSourceV1.migrationTrial;
  }

  EntitlementLedgerV1 _buildFromLegacyPrefs(
    SharedPreferences prefs,
    int nowEpochMs, {
    required bool premiumActive,
  }) {
    final migrationSourceKeys = <String>[];
    if (premiumActive || prefs.containsKey('premium_is_active')) {
      migrationSourceKeys.add('premium_is_active');
    }
    final rawTrialJson = prefs.getString('trial_entitlement_v1');
    final trialEntitlement = _readTrialEntitlement(rawTrialJson);
    if (rawTrialJson != null) {
      migrationSourceKeys.add('trial_entitlement_v1');
    }
    final placementCompleted =
        prefs.getBool('trial_placement_completed_v1') ?? false;
    if (prefs.containsKey('trial_placement_completed_v1')) {
      migrationSourceKeys.add('trial_placement_completed_v1');
    }
    final lastSeenEpochMs = prefs.getInt('trial_last_seen_epoch_ms_v1');
    if (lastSeenEpochMs != null) {
      migrationSourceKeys.add('trial_last_seen_epoch_ms_v1');
    }
    final clockRollbackDetected =
        prefs.getBool('trial_clock_rollback_detected_v1') ?? false;
    if (prefs.containsKey('trial_clock_rollback_detected_v1')) {
      migrationSourceKeys.add('trial_clock_rollback_detected_v1');
    }
    final productCache =
        prefs.getStringList('purchased_products') ?? <String>[];
    if (prefs.containsKey('purchased_products')) {
      migrationSourceKeys.add('purchased_products');
    }

    if (premiumActive) {
      return EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.premiumActive,
        source: EntitlementLedgerSourceV1.migrationPremiumFlag,
        trialState: _trialStateFromEntitlement(
          trialEntitlement,
          nowEpochMs,
          placementCompleted: placementCompleted,
          clockRollbackDetected: clockRollbackDetected,
          lastSeenEpochMs: lastSeenEpochMs,
          premiumActive: true,
        ),
        updatedAtEpochMs: nowEpochMs,
        migrationSourceKeys: migrationSourceKeys,
        productCacheProductIds: productCache,
        isPublicCommerceSafe: false,
      );
    }

    if (clockRollbackDetected && trialEntitlement != null) {
      return EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.verificationFailed,
        source: EntitlementLedgerSourceV1.migrationTrial,
        trialState: _trialStateFromEntitlement(
          trialEntitlement,
          nowEpochMs,
          placementCompleted: placementCompleted,
          clockRollbackDetected: true,
          lastSeenEpochMs: lastSeenEpochMs,
          premiumActive: false,
        ),
        updatedAtEpochMs: nowEpochMs,
        migrationSourceKeys: migrationSourceKeys,
        productCacheProductIds: productCache,
        isPublicCommerceSafe: false,
        lastErrorCode: 'clock_rollback',
      );
    }

    if (trialEntitlement != null) {
      final active = trialEntitlement.isActive(nowEpochMs);
      return EntitlementLedgerV1(
        entitlementStatus: active
            ? EntitlementLedgerStatusV1.trialActive
            : EntitlementLedgerStatusV1.trialExpired,
        source: EntitlementLedgerSourceV1.migrationTrial,
        trialState: _trialStateFromEntitlement(
          trialEntitlement,
          nowEpochMs,
          placementCompleted: placementCompleted,
          clockRollbackDetected: false,
          lastSeenEpochMs: lastSeenEpochMs,
          premiumActive: false,
        ),
        expiresAtEpochMs: trialEntitlement.endEpochMs,
        updatedAtEpochMs: nowEpochMs,
        migrationSourceKeys: migrationSourceKeys,
        productCacheProductIds: productCache,
        isPublicCommerceSafe: false,
      );
    }

    if (placementCompleted) {
      return EntitlementLedgerV1(
        entitlementStatus: EntitlementLedgerStatusV1.trialEligible,
        source: EntitlementLedgerSourceV1.none,
        trialState: EntitlementTrialStateV1(
          state: EntitlementTrialStateKindV1.eligible,
          eligibilityReason: 'eligible',
          placementCompleted: true,
          clockRollbackDetected: clockRollbackDetected,
          lastSeenEpochMs: lastSeenEpochMs,
        ),
        updatedAtEpochMs: nowEpochMs,
        migrationSourceKeys: migrationSourceKeys,
        productCacheProductIds: productCache,
        isPublicCommerceSafe: false,
      );
    }

    return EntitlementLedgerV1(
      entitlementStatus: EntitlementLedgerStatusV1.free,
      source: EntitlementLedgerSourceV1.none,
      trialState: EntitlementTrialStateV1(
        state: clockRollbackDetected
            ? EntitlementTrialStateKindV1.blockedByRollback
            : EntitlementTrialStateKindV1.notEligible,
        eligibilityReason: clockRollbackDetected
            ? 'clock_rollback'
            : 'placement_incomplete',
        placementCompleted: false,
        clockRollbackDetected: clockRollbackDetected,
        lastSeenEpochMs: lastSeenEpochMs,
      ),
      updatedAtEpochMs: nowEpochMs,
      migrationSourceKeys: migrationSourceKeys,
      productCacheProductIds: productCache,
      isPublicCommerceSafe: false,
    );
  }

  _TrialEntitlementSnapshotV1? _readTrialEntitlement(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return _TrialEntitlementSnapshotV1.tryParse(decoded);
    } catch (_) {
      return null;
    }
  }

  EntitlementTrialStateV1 _trialStateFromEntitlement(
    _TrialEntitlementSnapshotV1? entitlement,
    int nowEpochMs, {
    required bool placementCompleted,
    required bool clockRollbackDetected,
    required int? lastSeenEpochMs,
    required bool premiumActive,
  }) {
    if (premiumActive) {
      return EntitlementTrialStateV1(
        state: EntitlementTrialStateKindV1.blockedByPremium,
        eligibilityReason: 'premium_active',
        placementCompleted: placementCompleted,
        clockRollbackDetected: clockRollbackDetected,
        lastSeenEpochMs: lastSeenEpochMs,
      );
    }
    if (clockRollbackDetected) {
      return EntitlementTrialStateV1(
        state: EntitlementTrialStateKindV1.blockedByRollback,
        startEpochMs: entitlement?.startEpochMs,
        endEpochMs: entitlement?.endEpochMs,
        durationDays: entitlement?.durationDays,
        remainingDays: 0,
        eligibilityReason: 'clock_rollback',
        placementCompleted: placementCompleted,
        clockRollbackDetected: true,
        lastSeenEpochMs: lastSeenEpochMs,
      );
    }
    if (entitlement == null) {
      return EntitlementTrialStateV1(
        state: placementCompleted
            ? EntitlementTrialStateKindV1.eligible
            : EntitlementTrialStateKindV1.notEligible,
        eligibilityReason: placementCompleted
            ? 'eligible'
            : 'placement_incomplete',
        placementCompleted: placementCompleted,
        clockRollbackDetected: false,
        lastSeenEpochMs: lastSeenEpochMs,
      );
    }
    final active = entitlement.isActive(nowEpochMs);
    return EntitlementTrialStateV1(
      state: active
          ? EntitlementTrialStateKindV1.active
          : EntitlementTrialStateKindV1.expired,
      startEpochMs: entitlement.startEpochMs,
      endEpochMs: entitlement.endEpochMs,
      durationDays: entitlement.durationDays,
      remainingDays: entitlement.remainingDays(nowEpochMs),
      eligibilityReason: active ? 'trial_active' : 'trial_already_used',
      placementCompleted: placementCompleted,
      clockRollbackDetected: false,
      lastSeenEpochMs: lastSeenEpochMs,
    );
  }
}

class _TrialEntitlementSnapshotV1 {
  const _TrialEntitlementSnapshotV1({
    required this.startEpochMs,
    required this.durationDays,
  });

  final int startEpochMs;
  final int durationDays;

  int get endEpochMs => startEpochMs + (durationDays * _kMsPerDayV1);

  bool isActive(int nowEpochMs) => nowEpochMs < endEpochMs;

  int remainingDays(int nowEpochMs) {
    if (!isActive(nowEpochMs)) return 0;
    return _remainingDays(nowEpochMs, endEpochMs);
  }

  static _TrialEntitlementSnapshotV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final schemaVersion = _safeInt(raw['schemaVersion']);
    final startEpochMs = _safeInt(raw['startEpochMs']);
    final durationDays = _safeInt(raw['durationDays']);
    if (schemaVersion != 1 || startEpochMs <= 0 || durationDays <= 0) {
      return null;
    }
    return _TrialEntitlementSnapshotV1(
      startEpochMs: startEpochMs,
      durationDays: durationDays,
    );
  }
}

EntitlementAccessWhyV1 _whyForStatus(
  EntitlementLedgerStatusV1 status,
  EntitlementLedgerSourceV1 source,
) {
  switch (status) {
    case EntitlementLedgerStatusV1.free:
      return EntitlementAccessWhyV1.free;
    case EntitlementLedgerStatusV1.trialEligible:
      return EntitlementAccessWhyV1.trialEligible;
    case EntitlementLedgerStatusV1.trialActive:
      return EntitlementAccessWhyV1.trialActive;
    case EntitlementLedgerStatusV1.trialExpired:
      return EntitlementAccessWhyV1.expired;
    case EntitlementLedgerStatusV1.premiumActive:
      if (source == EntitlementLedgerSourceV1.verifiedPurchase) {
        return EntitlementAccessWhyV1.verifiedPurchase;
      }
      if (source == EntitlementLedgerSourceV1.verifiedRestore) {
        return EntitlementAccessWhyV1.verifiedRestore;
      }
      return EntitlementAccessWhyV1.legacyPremiumFlag;
    case EntitlementLedgerStatusV1.verificationPending:
      return EntitlementAccessWhyV1.verificationPending;
    case EntitlementLedgerStatusV1.verificationFailed:
      return EntitlementAccessWhyV1.verificationFailed;
    case EntitlementLedgerStatusV1.storeUnavailable:
      return EntitlementAccessWhyV1.storeUnavailable;
  }
}

int _remainingDays(int nowEpochMs, int endEpochMs) {
  if (nowEpochMs >= endEpochMs) return 0;
  final remainingMs = endEpochMs - nowEpochMs;
  final fullDays = remainingMs ~/ _kMsPerDayV1;
  return fullDays <= 0 ? 1 : fullDays;
}

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  final name = raw?.toString();
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

List<String> _stringList(Object? raw) {
  if (raw is List) {
    return raw.map((value) => value.toString()).toList(growable: false);
  }
  return const <String>[];
}

List<String> _addUnique(List<String> values, String value) {
  final next = <String>{...values, value}.toList(growable: false);
  next.sort();
  return next;
}

int _safeInt(Object? raw) {
  if (raw is int) return raw;
  return int.tryParse(raw?.toString() ?? '') ?? 0;
}

int? _nullableInt(Object? raw) {
  if (raw == null) return null;
  final value = _safeInt(raw);
  return value == 0 ? null : value;
}
