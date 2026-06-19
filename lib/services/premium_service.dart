// lib/services/premium_service.dart
// Stage 24: Premium Tier & Monetization Layer
//
// Manages premium subscription status with SharedPreferences persistence.
// Provides foundation for monetization without requiring payment SDK integration yet.

import 'package:shared_preferences/shared_preferences.dart';
import 'payment_gateway_service.dart';
import 'entitlement_sync_v1.dart';
import 'entitlement_ledger_v1.dart';

/// Service for managing premium subscription status.
///
/// Stores isPremium flag in SharedPreferences and provides methods for
/// enabling/disabling premium mode. In production, premium activation
/// would be tied to payment verification (IAP, Stripe, etc.).
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String _keyIsPremium = 'premium_is_active';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if premium mode is currently active.
  ///
  /// Returns false if SharedPreferences not initialized or flag not set.
  Future<bool> isPremiumActive() async {
    await init();
    return _prefs?.getBool(_keyIsPremium) ?? false;
  }

  /// Enable premium mode.
  ///
  /// In production, this should only be called after successful payment
  /// verification. For development/testing, can be toggled manually.
  Future<void> enablePremium() async {
    await init();
    await _prefs?.setBool(_keyIsPremium, true);
    await EntitlementLedgerServiceV1.instance.recordDebugPremiumFlagV1(
      active: true,
      nowEpochMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    EntitlementSyncV1.markChanged();
  }

  /// Disable premium mode.
  ///
  /// Used for subscription expiration, refunds, or manual testing.
  Future<void> disablePremium() async {
    await init();
    await _prefs?.setBool(_keyIsPremium, false);
    await EntitlementLedgerServiceV1.instance.recordDebugPremiumFlagV1(
      active: false,
      nowEpochMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    EntitlementSyncV1.markChanged();
  }

  /// Get premium status for health dashboard.
  ///
  /// Returns map with active flag and pass status (always true since
  /// premium being off is not a failure condition).
  Future<Map<String, dynamic>> getPremiumStatus() async {
    final isActive = await isPremiumActive();
    return {
      'active': isActive,
      'pass': true, // Premium being off is not a system failure
    };
  }

  /// Clear all premium data.
  ///
  /// Used for testing or complete user data reset.
  Future<void> clear() async {
    await init();
    await _prefs?.remove(_keyIsPremium);
    await EntitlementLedgerServiceV1.instance.recordDebugPremiumFlagV1(
      active: false,
      nowEpochMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    EntitlementSyncV1.markChanged();
  }

  /// Purchase premium via mock payment gateway and enable premium on success.
  ///
  /// Returns a summary map with receipt, validated flag, and validation score.
  Future<Map<String, Object>> buyPremium() async {
    final gateway = PaymentGatewayService();
    await gateway.initGateway();
    final receipt = await gateway.purchasePremium();
    final validation = await gateway.validateReceipt(receipt);
    final validated = validation['success'] == true;
    final score = (validation['score'] as num?)?.toDouble() ?? 0.0;
    if (validated) {
      await enablePremium();
    }
    return {'receipt': receipt, 'validated': validated, 'score': score};
  }
}
