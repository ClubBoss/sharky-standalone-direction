import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

/// Settings Controller
///
/// Manages user preferences and settings stored in SharedPreferences.
/// Provides reactive updates via ChangeNotifier.
class SettingsController extends ChangeNotifier {
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keySoundEnabled = 'settings_sound_enabled';
  static const String _keyLanguage = 'settings_language';
  static const String _keyUsername = 'settings_username';

  ThemeMode _themeMode = ThemeMode.dark;
  bool _soundEnabled = true;
  String _language = 'en';
  String _username = 'Player';

  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  String get language => _language;
  String get username => _username;
  bool get isInitialized => _isInitialized;

  /// Initialize settings from SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeModeString = prefs.getString(_keyThemeMode);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.dark,
        );
      }

      // Load sound preference
      _soundEnabled = prefs.getBool(_keySoundEnabled) ?? true;

      // Load language
      _language = prefs.getString(_keyLanguage) ?? 'en';

      // Load username
      _username = prefs.getString(_keyUsername) ?? 'Player';

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Silently fail with defaults
      _isInitialized = true;
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
    _logSettingChange('theme_mode', mode.toString());

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, mode.toString());
    } catch (e) {
      // Silently fail - UI already updated
    }
  }

  /// Toggle sound on/off
  Future<void> setSoundEnabled(bool enabled) async {
    if (_soundEnabled == enabled) return;

    _soundEnabled = enabled;
    notifyListeners();
    _logSettingChange('sound_enabled', enabled);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySoundEnabled, enabled);
    } catch (e) {
      // Silently fail - UI already updated
    }
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    if (_language == languageCode) return;

    _language = languageCode;
    notifyListeners();
    _logSettingChange('language', languageCode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, languageCode);
    } catch (e) {
      // Silently fail - UI already updated
    }
  }

  /// Set username
  Future<void> setUsername(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _username == trimmed) return;

    _username = trimmed;
    notifyListeners();
    _logSettingChange('username', trimmed);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsername, trimmed);
    } catch (e) {
      // Silently fail - UI already updated
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.dark;
    _soundEnabled = true;
    _language = 'en';
    _username = 'Player';
    notifyListeners();
    _logSettingChange('reset', 'defaults');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyThemeMode);
      await prefs.remove(_keySoundEnabled);
      await prefs.remove(_keyLanguage);
      await prefs.remove(_keyUsername);
    } catch (e) {
      // Silently fail - UI already updated
    }
  }
}

void _logSettingChange(String key, Object? value) {
  unawaited(FirebaseLiteTelemetryService.instance.logSettingChange(key, value));
}
