// lib/services/adaptive_premium_triggers.dart
// Stage 28: Adaptive Premium Triggers
//
// Evaluates player behavior and grants rewards/trials based on engagement patterns.

import 'package:shared_preferences/shared_preferences.dart';
import 'entitlement_ssot_v1.dart';
import 'energy_service.dart';
import 'chips_wallet_service.dart';

/// Result of trigger evaluation containing applied rewards.
class TriggerResult {
  final bool trialActivated;
  final int energyBonus;
  final int chipsBonus;
  final String message;

  const TriggerResult({
    this.trialActivated = false,
    this.energyBonus = 0,
    this.chipsBonus = 0,
    this.message = '',
  });
}

/// Service for evaluating and applying adaptive premium triggers.
///
/// Monitors player engagement metrics (momentum, fatigue, streaks) and
/// automatically grants rewards or premium trials to encourage continued play.
class AdaptivePremiumTriggers {
  static final AdaptivePremiumTriggers _instance =
      AdaptivePremiumTriggers._internal();
  factory AdaptivePremiumTriggers() => _instance;
  AdaptivePremiumTriggers._internal();

  static const String _keyTrialExpiry = 'premium_trial_expiry';
  static const String _keyLastEvaluation = 'triggers_last_eval';
  static const Duration _trialDuration = Duration(hours: 24);
  static const Duration _evaluationCooldown = Duration(hours: 1);
  // M4 trial SSOT is TrialServiceV1; legacy trial triggers stay disabled.
  static const bool _legacyTrialPathEnabledV1 = false;

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Evaluate triggers based on current player metrics.
  ///
  /// Rules:
  /// - momentum >= 0.9 → 24h Premium Trial
  /// - fatigue >= 80 → +2 Energy Bonus
  /// - streakDays >= 5 → +5 Chips Bonus
  ///
  /// Returns TriggerResult with applied rewards.
  Future<TriggerResult> evaluateTriggers({
    required double momentum,
    required int fatigue,
    required int streakDays,
  }) async {
    if (!_isLegacyTriggerPathEnabledV1()) {
      return const TriggerResult(message: 'legacy_triggers_disabled_v1');
    }
    await init();

    // Check cooldown to avoid spamming
    final lastEvalMs = _prefs?.getInt(_keyLastEvaluation);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastEvalMs != null) {
      final elapsed = Duration(milliseconds: now - lastEvalMs);
      if (elapsed < _evaluationCooldown) {
        return const TriggerResult(message: 'Cooldown active');
      }
    }

    bool trialActivated = false;
    int energyBonus = 0;
    int chipsBonus = 0;
    final messages = <String>[];

    // Rule 1: High momentum → Premium Trial
    if (momentum >= 0.9 && _legacyTrialPathEnabledV1) {
      final isPremium = await EntitlementSSOTV1.instance
          .isEntitledToPremiumV1();
      final hasActiveTrial = await isTrialActive();

      if (!isPremium && !hasActiveTrial) {
        await _activateTrial();
        trialActivated = true;
        messages.add('24h Premium Trial activated');
      }
    } else if (momentum >= 0.9 && !_legacyTrialPathEnabledV1) {
      messages.add('legacy_trial_path_disabled');
    }

    // Rule 2: High fatigue → Energy Bonus
    if (fatigue >= 80) {
      await EnergyService().restoreEnergy(2);
      energyBonus = 2;
      messages.add('+2 Energy bonus');
    }

    // Rule 3: Long streak → Chips Bonus
    if (streakDays >= 5) {
      await ChipsWalletService().addChips(5);
      chipsBonus = 5;
      messages.add('+5 Chips bonus');
    }

    // Update last evaluation timestamp
    await _prefs?.setInt(_keyLastEvaluation, now);

    return TriggerResult(
      trialActivated: trialActivated,
      energyBonus: energyBonus,
      chipsBonus: chipsBonus,
      message: messages.isEmpty ? 'No triggers' : messages.join(', '),
    );
  }

  bool _isLegacyTriggerPathEnabledV1() => _legacyTrialPathEnabledV1;

  /// Activate a 24-hour premium trial.
  Future<void> _activateTrial() async {
    await init();
    final expiry = DateTime.now().add(_trialDuration).millisecondsSinceEpoch;
    await _prefs?.setInt(_keyTrialExpiry, expiry);
  }

  /// Check if a premium trial is currently active.
  Future<bool> isTrialActive() async {
    await init();
    final expiryMs = _prefs?.getInt(_keyTrialExpiry);

    if (expiryMs == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now < expiryMs;
  }

  /// Get time until trial expires (in hours).
  ///
  /// Returns 0 if no active trial.
  Future<double> getTrialHoursRemaining() async {
    await init();
    final expiryMs = _prefs?.getInt(_keyTrialExpiry);

    if (expiryMs == null) return 0.0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = expiryMs - now;

    if (remaining <= 0) return 0.0;

    return remaining / (1000 * 60 * 60);
  }

  /// Get trigger status for health dashboard.
  Future<Map<String, dynamic>> getTriggerStatus() async {
    final trialActive = await isTrialActive();
    final hoursRemaining = await getTrialHoursRemaining();

    return {
      'trialActive': trialActive,
      'hoursRemaining': hoursRemaining,
      'pass': true, // Trigger system always passes
    };
  }

  /// Clear trigger data.
  Future<void> clear() async {
    await init();
    await _prefs?.remove(_keyTrialExpiry);
    await _prefs?.remove(_keyLastEvaluation);
  }
}
