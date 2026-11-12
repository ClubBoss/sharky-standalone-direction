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
  bool _hasExplicitSelection = false;
  Future<void>? _initialization;
  Future<void> _pendingWrites = Future<void>.value();
  String? _lastSavedLanguageCode;

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

  /// Initialize once. A selection made before the read settles takes priority.
  Future<void> initialize() {
    if (_isInitialized) return Future<void>.value();
    return _initialization ??= _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.get(_keyLanguageCode);
      if (!_hasExplicitSelection) {
        if (savedCode is String && supportedLanguages.containsKey(savedCode)) {
          _currentLocale = Locale(savedCode);
          _lastSavedLanguageCode = savedCode;
        } else {
          _currentLocale = const Locale('en');
        }
      }
    } catch (error, stack) {
      // Keep the English default, or any newer explicit selection.
      _reportStorageError(error, stack, 'loading the saved language');
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Set the visible language and await its queued persistence attempt.
  ///
  /// Returns whether the visible language changed, NOT whether it was saved.
  /// Storage failures are reported through [FlutterError.reportError]. Selecting
  /// the same language can retry a failed save while still returning false.
  Future<bool> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) return false;

    _hasExplicitSelection = true;
    final changed = _currentLocale.languageCode != languageCode;
    _currentLocale = Locale(languageCode);

    // Queue before notifying: a listener may synchronously select another code.
    final saving = _pendingWrites.then((_) => _saveLanguage(languageCode));
    _pendingWrites = saving;
    if (changed) notifyListeners();
    await saving;
    return changed;
  }

  Future<void> _saveLanguage(String languageCode) async {
    if (_lastSavedLanguageCode == languageCode) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(_keyLanguageCode, languageCode)) {
        throw StateError('Language preference write was not acknowledged');
      }
      _lastSavedLanguageCode = languageCode;
    } catch (error, stack) {
      _lastSavedLanguageCode = null;
      // SharedPreferences updates its cache before acknowledging storage. Do
      // not use that optimistic cache to suppress a retry after a failed write.
      _reportStorageError(error, stack, 'saving the selected language');
    }
  }

  static void _reportStorageError(
    Object error,
    StackTrace stack,
    String operation,
  ) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'app_language_controller',
        context: ErrorDescription('while $operation'),
      ),
    );
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
