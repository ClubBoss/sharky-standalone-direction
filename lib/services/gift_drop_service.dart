import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'coins_service.dart';

class GiftDropService {
  GiftDropService({this.interval = const Duration(hours: 24)});

  final Duration interval;

  static const _lastKey = 'gift_drop_last';
  static const _installSeedKey = 'gift_drop_install_seed_v1';
  static const _minAmount = 20;
  static const _maxAmount = 50;
  static const _amountRange = _maxAmount - _minAmount + 1;
  static const _msPerDay = 24 * 60 * 60 * 1000;

  bool _canDrop(DateTime now, DateTime? last) {
    if (last == null) return true;
    return now.difference(last) >= interval;
  }

  Future<void> checkAndDropGift({
    required BuildContext context,
    DateTime? nowOverride,
    SharedPreferences? prefsOverride,
  }) async {
    final prefs = prefsOverride ?? await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_lastKey);
    final last = lastStr != null ? DateTime.tryParse(lastStr) : null;
    final now = (nowOverride ?? DateTime.now()).toUtc();
    if (!_canDrop(now, last)) return;

    final installSeed = await _readOrCreateInstallSeedV1(
      prefs: prefs,
      nowUtc: now,
    );
    final dayKey = _utcDayKeyV1(now);
    // Deterministic drop amount per install+day; replaces runtime RNG.
    final amount = _deterministicAmountV1(
      installSeed: installSeed,
      dayKey: dayKey,
    );
    await prefs.setString(_lastKey, now.toIso8601String());
    await CoinsService.instance.addCoins(amount);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('🎁 Подарок: +$amount монет!')));
    }
  }

  static int _utcDayKeyV1(DateTime nowUtc) =>
      nowUtc.millisecondsSinceEpoch ~/ _msPerDay;

  static Future<int> _readOrCreateInstallSeedV1({
    required SharedPreferences prefs,
    required DateTime nowUtc,
  }) async {
    final existing = prefs.getInt(_installSeedKey);
    if (existing != null && existing > 0) {
      return existing;
    }
    final seed = nowUtc.millisecondsSinceEpoch;
    await prefs.setInt(_installSeedKey, seed);
    return seed;
  }

  static int _deterministicAmountV1({
    required int installSeed,
    required int dayKey,
  }) {
    final mixed = _mix32V1(installSeed ^ dayKey);
    return _minAmount + (mixed % _amountRange);
  }

  static int _mix32V1(int value) {
    var x = value & 0x7fffffff;
    x = ((x ^ 0x45d9f3b) * 1103515245 + 12345) & 0x7fffffff;
    return x;
  }

  @visibleForTesting
  static int debugDeterministicAmountV1({
    required int installSeed,
    required int dayKey,
  }) => _deterministicAmountV1(installSeed: installSeed, dayKey: dayKey);
}
