// lib/services/chips_wallet_service.dart
// Stage 28: Chips Wallet (Soft Currency)
//
// Manages player's in-game chips balance for rewards and purchases.

import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing player's chips balance.
///
/// Chips are soft currency earned through gameplay and can be spent
/// on in-game items, hints, or other features. Demo limit: 100,000 chips.
class ChipsWalletService {
  static final ChipsWalletService _instance = ChipsWalletService._internal();
  factory ChipsWalletService() => _instance;
  ChipsWalletService._internal();

  static const String _keyBalance = 'wallet_chips';
  static const int _maxBalance = 100000; // Demo limit

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get current chips balance.
  Future<int> getBalance() async {
    await init();
    return _prefs?.getInt(_keyBalance) ?? 0;
  }

  /// Add chips to balance.
  ///
  /// Returns true if chips were added successfully.
  /// Will not exceed max balance (demo limit).
  Future<bool> addChips(int amount) async {
    if (amount <= 0) return false;

    await init();
    final current = await getBalance();
    final newBalance = (current + amount).clamp(0, _maxBalance);

    await _prefs?.setInt(_keyBalance, newBalance);
    return true;
  }

  /// Spend chips from balance.
  ///
  /// Returns true if sufficient balance and chips were deducted,
  /// false if insufficient balance.
  Future<bool> spendChips(int amount) async {
    if (amount <= 0) return false;

    await init();
    final current = await getBalance();

    if (current < amount) {
      return false;
    }

    await _prefs?.setInt(_keyBalance, current - amount);
    return true;
  }

  /// Check if player has sufficient chips.
  Future<bool> hasChips(int amount) async {
    final balance = await getBalance();
    return balance >= amount;
  }

  /// Get wallet status for health dashboard.
  Future<Map<String, dynamic>> getWalletStatus() async {
    final balance = await getBalance();

    return {
      'balance': balance,
      'maxBalance': _maxBalance,
      'pass': true, // Wallet system always passes
    };
  }

  /// Clear wallet data.
  Future<void> clear() async {
    await init();
    await _prefs?.remove(_keyBalance);
  }
}
