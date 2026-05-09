import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'booster_service.dart';

/// SharedPreferences-backed inventory for XP boosters (max 3).
class XpBoosterInventoryService {
  XpBoosterInventoryService._();
  static final XpBoosterInventoryService instance =
      XpBoosterInventoryService._();

  static const String _prefsKey = 'booster_inventory_v1';
  static const int _capacity = 3;

  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Returns a copy of current inventory.
  Future<List<BoosterType>> getInventory() async {
    await _ensurePrefs();
    final raw = _prefs?.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => (e as String).toLowerCase())
          .map(
            (name) => BoosterType.values.firstWhere(
              (t) => t.name == name,
              orElse: () => BoosterType.study,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _save(List<BoosterType> items) async {
    await _ensurePrefs();
    final encoded = jsonEncode(items.map((e) => e.name).toList());
    await _prefs?.setString(_prefsKey, encoded);
  }

  /// Returns true if inventory reached capacity.
  Future<bool> isFull() async {
    final inv = await getInventory();
    return inv.length >= _capacity;
  }

  /// Adds a booster if capacity allows; returns true if added.
  Future<bool> addBooster(BoosterType type) async {
    final inv = List<BoosterType>.from(await getInventory());
    if (inv.length >= _capacity) return false;
    inv.add(type);
    await _save(inv);
    return true;
  }

  /// Removes one booster of the specified type and returns true if removed.
  Future<bool> useBooster(BoosterType type) async {
    final inv = List<BoosterType>.from(await getInventory());
    final idx = inv.indexOf(type);
    if (idx == -1) return false;
    inv.removeAt(idx);
    await _save(inv);
    return true;
  }

  /// Removes one booster of the specified type without activation.
  /// Returns true if removed, false if not found.
  Future<bool> removeBooster(BoosterType type) async {
    final inv = List<BoosterType>.from(await getInventory());
    final idx = inv.indexOf(type);
    if (idx == -1) return false;
    inv.removeAt(idx);
    await _save(inv);
    return true;
  }

  /// For testing: clear all inventory.
  Future<void> reset() async {
    await _ensurePrefs();
    await _prefs?.remove(_prefsKey);
  }
}
