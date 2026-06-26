import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Language Controller
///
/// Manages the app's current locale and persists language selection.
/// Notifies listeners when language changes to trigger MaterialApp rebuild.
///
/// Stage D16: Runtime language switching without app restart.
class AppLanguageController extends ChangeNotifier {
  static const String _keyLanguageCode = 'app_language_code';

  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  /// Supported languages with their native names
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ru': 'Русский',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'zh': '中文',
  };

  /// Flag emojis for each language
  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'ru': '🇷🇺',
    'es': '🇪🇸',
    'fr': '🇫🇷',
    'de': '🇩🇪',
    'zh': '🇨🇳',
  };

  /// Current locale
  Locale get currentLocale => _currentLocale;

  /// Current language code
  String get languageCode => _currentLocale.languageCode;

  /// Whether controller is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize from SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_keyLanguageCode);

      if (savedLanguageCode != null &&
          supportedLanguages.containsKey(savedLanguageCode)) {
        _currentLocale = Locale(savedLanguageCode);
      } else {
        // Public v1 is English-first. RU remains opt-in until the rollout lands.
        _currentLocale = const Locale('en');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Silently fail with the launch default locale.
      _currentLocale = const Locale('en');
      _isInitialized = true;
    }
  }

  /// Set language and persist to preferences
  ///
  /// Returns true if language changed, false if already set to this language.
  Future<bool> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      return false;
    }

    if (_currentLocale.languageCode == languageCode) {
      return false;
    }

    _currentLocale = Locale(languageCode);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguageCode, languageCode);
    } catch (e) {
      // Silently fail - UI already updated
    }

    return true;
  }

  /// Get native name for language code
  static String getLanguageName(String languageCode) {
    return supportedLanguages[languageCode] ?? 'English';
  }

  /// Get flag emoji for language code
  static String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🌐';
  }
}
