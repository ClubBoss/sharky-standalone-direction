// lib/services/energy_service.dart
// Stage 28: Energy System
//
// Manages player energy for training sessions with auto-refill and premium bypass.

import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_status_v1.dart';

/// Service for managing player energy.
///
/// Energy is consumed during training sessions and refills automatically
/// (1 energy per 30 minutes). Premium users have infinite energy.
class EnergyService {
  static final EnergyService _instance = EnergyService._internal();
  factory EnergyService() => _instance;
  EnergyService._internal();

  static const String _keyCurrentEnergy = 'energy_current';
  static const String _keyLastRefill = 'energy_last_refill';
  static const int _maxEnergy = 5;
  static const Duration _refillInterval = Duration(minutes: 30);

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get current energy count.
  ///
  /// Returns max energy if premium is active (infinite energy).
  /// Otherwise returns stored energy count after applying auto-refill.
  Future<int> getCurrentEnergy() async {
    await init();

    // Premium users have infinite energy
    final status = await SubscriptionServiceV1.getStatusV1();
    final isEntitled = status.isEntitled;
    if (isEntitled) {
      return _maxEnergy;
    }

    // Apply auto-refill before returning
    await autoRefill();
    return _prefs?.getInt(_keyCurrentEnergy) ?? _maxEnergy;
  }

  /// Get maximum energy capacity.
  int getMaxEnergy() => _maxEnergy;

  /// Use one energy unit.
  ///
  /// Returns true if energy was available and consumed, false otherwise.
  /// Premium users always return true (infinite energy).
  Future<bool> useEnergy() async {
    await init();

    // Premium users have infinite energy
    final status = await SubscriptionServiceV1.getStatusV1();
    final isEntitled = status.isEntitled;
    if (isEntitled) {
      return true;
    }

    await autoRefill();
    final current = _prefs?.getInt(_keyCurrentEnergy) ?? _maxEnergy;

    if (current <= 0) {
      return false;
    }

    await _prefs?.setInt(_keyCurrentEnergy, current - 1);
    return true;
  }

  /// Restore energy (e.g., from bonus or reward).
  ///
  /// Adds specified amount without exceeding max energy.
  Future<void> restoreEnergy(int amount) async {
    await init();

    final current = _prefs?.getInt(_keyCurrentEnergy) ?? _maxEnergy;
    final newEnergy = (current + amount).clamp(0, _maxEnergy);
    await _prefs?.setInt(_keyCurrentEnergy, newEnergy);
  }

  /// Auto-refill energy based on elapsed time.
  ///
  /// Refills 1 energy per 30 minutes since last refill, up to max energy.
  Future<void> autoRefill() async {
    await init();

    final lastRefillMs = _prefs?.getInt(_keyLastRefill);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Initialize if first time
    if (lastRefillMs == null) {
      await _prefs?.setInt(_keyLastRefill, now);
      await _prefs?.setInt(_keyCurrentEnergy, _maxEnergy);
      return;
    }

    final current = _prefs?.getInt(_keyCurrentEnergy) ?? _maxEnergy;

    // Already at max, just update timestamp
    if (current >= _maxEnergy) {
      await _prefs?.setInt(_keyLastRefill, now);
      return;
    }

    // Calculate refill amount
    final elapsed = Duration(milliseconds: now - lastRefillMs);
    final refillCount = elapsed.inMinutes ~/ _refillInterval.inMinutes;

    if (refillCount > 0) {
      final newEnergy = (current + refillCount).clamp(0, _maxEnergy);
      await _prefs?.setInt(_keyCurrentEnergy, newEnergy);

      // Update last refill to current time minus remainder
      final remainder = elapsed.inMinutes % _refillInterval.inMinutes;
      final newRefillTime = now - Duration(minutes: remainder).inMilliseconds;
      await _prefs?.setInt(_keyLastRefill, newRefillTime);
    }
  }

  /// Get energy status for health dashboard.
  Future<Map<String, dynamic>> getEnergyStatus() async {
    final current = await getCurrentEnergy();
    final max = getMaxEnergy();
    final status = await SubscriptionServiceV1.getStatusV1();
    final isPremium = status.isEntitled;

    return {
      'current': current,
      'max': max,
      'isPremium': isPremium,
      'pass': true, // Energy system always passes (low energy is not a failure)
    };
  }

  /// Clear all energy data.
  Future<void> clear() async {
    await init();
    await _prefs?.remove(_keyCurrentEnergy);
    await _prefs?.remove(_keyLastRefill);
  }
}
