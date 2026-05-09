import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CosmeticStoreService extends ChangeNotifier {
  CosmeticStoreService._();
  static final CosmeticStoreService instance = CosmeticStoreService._();

  static const _avatarKey = 'active_avatar';
  static const _tableKey = 'active_table';
  static const _themeKey = 'active_theme';
  static const _badgeKey = 'active_badge';

  Future<void> setActiveItem(String category, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForCategory(category);
    if (key == null) return;
    await prefs.setString(key, id);
    notifyListeners();
  }

  Future<String?> getActiveItem(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForCategory(category);
    if (key == null) return null;
    return prefs.getString(key);
  }

  String? _keyForCategory(String category) {
    final normalized = category.toLowerCase();
    if (normalized.startsWith('hat') || normalized.contains('avatar')) {
      return _avatarKey;
    }
    if (normalized.startsWith('table')) {
      return _tableKey;
    }
    if (normalized.contains('theme')) {
      return _themeKey;
    }
    if (normalized.contains('badge')) {
      return _badgeKey;
    }
    return null;
  }
}
