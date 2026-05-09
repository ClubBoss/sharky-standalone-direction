import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'booster_service.dart';
import 'xp_booster_inventory_service.dart';

/// Service that grants one free XP booster every 24 hours, with rotating type.
class BoosterMarketService {
  BoosterMarketService._();
  static final BoosterMarketService instance = BoosterMarketService._();

  static const String _lastClaimKey = 'booster_market_last_claim_iso_v1';
  static const String _rotationKey = 'booster_market_rotation_idx_v1';
  static const Duration _cooldown = Duration(hours: 24);

  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Returns the next booster type in round-robin order.
  Future<BoosterType> nextType() async {
    await _ensurePrefs();
    final idx = _prefs?.getInt(_rotationKey) ?? 0;
    final mod = idx % 3;
    switch (mod) {
      case 0:
        return BoosterType.study;
      case 1:
        return BoosterType.play;
      default:
        return BoosterType.review;
    }
  }

  /// Returns true if a booster can be claimed right now.
  Future<bool> canClaimNow() async {
    final remaining = await timeUntilNext();
    return remaining <= Duration.zero;
  }

  /// Returns time remaining until the next claim is available.
  /// If no cooldown, returns Duration.zero.
  Future<Duration> timeUntilNext() async {
    await _ensurePrefs();
    final iso = _prefs?.getString(_lastClaimKey);
    if (iso == null || iso.isEmpty) return Duration.zero;
    DateTime? last;
    try {
      last = DateTime.tryParse(iso);
    } catch (_) {
      last = null;
    }
    if (last == null) return Duration.zero;
    final now = DateTime.now();
    final elapsed = now.difference(last);
    final remaining = _cooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Attempts to claim the daily booster.
  /// Returns true if claimed and added to inventory; false otherwise.
  Future<bool> claimBooster() async {
    await _ensurePrefs();
    if (!await canClaimNow()) return false;

    final inv = XpBoosterInventoryService.instance;
    if (await inv.isFull()) {
      // Respect inventory cap; don't consume the daily claim.
      return false;
    }

    final type = await nextType();
    final added = await inv.addBooster(type);
    if (!added) return false;

    // Persist last claim time and advance rotation.
    final now = DateTime.now();
    await _prefs!.setString(
      _lastClaimKey,
      DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(now.toUtc()),
    );
    final idx = _prefs!.getInt(_rotationKey) ?? 0;
    await _prefs!.setInt(_rotationKey, idx + 1);
    return true;
  }

  /// For tests: resets state.
  Future<void> reset() async {
    await _ensurePrefs();
    await _prefs!.remove(_lastClaimKey);
    await _prefs!.remove(_rotationKey);
  }
}
