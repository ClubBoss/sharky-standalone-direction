import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_lite_telemetry_service.dart';

class AppSettingsService {
  static final AppSettingsService instance = AppSettingsService._();
  AppSettingsService._();

  @visibleForTesting
  static bool? debugCheckpointModeOverrideV1;

  static const _notificationsKey = 'notifications_enabled';
  static const _newTrainerUiKey = 'use_new_trainer_ui';
  static const _useIcmKey = 'use_icm_mode';
  static const _soundEnabledKey = 'settings_sound_enabled';
  static const _hapticsEnabledKey = 'haptics_enabled';
  static const _aiCoachEnabledKey = 'ai_coach_enabled';
  static const _engineV2BackendEnabledV1Key = 'engine_v2_backend_enabled_v1';

  bool _notificationsEnabled = true;
  bool _useNewTrainerUi = false;
  bool _useIcm = false;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _aiCoachEnabled = true;
  bool _engineV2BackendEnabledV1 = false;

  // Reactive snapshot to allow listeners in UI to update automatically.
  final ValueNotifier<AppSettingsSnapshot> _notifier =
      ValueNotifier<AppSettingsSnapshot>(const AppSettingsSnapshot());

  bool get notificationsEnabled => _notificationsEnabled;
  bool get useNewTrainerUi => _useNewTrainerUi;
  bool get useIcm => _useIcm;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get aiCoachEnabled => _aiCoachEnabled;
  bool get engineV2BackendEnabledV1 => _engineV2BackendEnabledV1;
  bool get isCheckpointModeV1 {
    final override = debugCheckpointModeOverrideV1;
    if (override != null) return override;
    const rawCheckpoint = String.fromEnvironment('CHECKPOINT');
    const rawCheckpointMode = String.fromEnvironment('CHECKPOINT_MODE');
    const marker = String.fromEnvironment('CHECKPOINT_MARKER');
    final cp = rawCheckpoint.trim().toLowerCase();
    final cpMode = rawCheckpointMode.trim().toLowerCase();
    return cp == '1' ||
        cp == 'true' ||
        cpMode == '1' ||
        cpMode == 'true' ||
        marker.trim().isNotEmpty;
  }

  // Expose a read-only listenable for settings changes
  ValueListenable<AppSettingsSnapshot> get changes => _notifier;
  AppSettingsSnapshot get snapshot => _notifier.value;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _useNewTrainerUi = prefs.getBool(_newTrainerUiKey) ?? false;
    _useIcm = prefs.getBool(_useIcmKey) ?? false;
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _hapticsEnabled = prefs.getBool(_hapticsEnabledKey) ?? true;
    _aiCoachEnabled = prefs.getBool(_aiCoachEnabledKey) ?? true;
    final persistedEngineV2 =
        prefs.getBool(_engineV2BackendEnabledV1Key) ?? false;
    _engineV2BackendEnabledV1 = _clampEngineV2BackendEnabledV1(
      persistedEngineV2,
    );
    if (_engineV2BackendEnabledV1 != persistedEngineV2) {
      await prefs.setBool(
        _engineV2BackendEnabledV1Key,
        _engineV2BackendEnabledV1,
      );
    }
    _emitSnapshot();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<void> setUseNewTrainerUi(bool value) async {
    _useNewTrainerUi = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newTrainerUiKey, value);
  }

  Future<void> setUseIcm(bool value) async {
    _useIcm = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useIcmKey, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled == value) return;
    _soundEnabled = value;
    _emitSnapshot();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
    _logSettingChange('sound_enabled', value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    if (_hapticsEnabled == value) return;
    _hapticsEnabled = value;
    _emitSnapshot();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsEnabledKey, value);
    _logSettingChange('haptics_enabled', value);
  }

  Future<void> setAiCoachEnabled(bool value) async {
    if (_aiCoachEnabled == value) return;
    _aiCoachEnabled = value;
    _emitSnapshot();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiCoachEnabledKey, value);
    _logSettingChange('ai_coach_enabled', value);
  }

  Future<void> setEngineV2BackendEnabledV1(bool value) async {
    final gatedValue = _clampEngineV2BackendEnabledV1(value);
    if (_engineV2BackendEnabledV1 == gatedValue) {
      if (!isCheckpointModeV1 && value) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_engineV2BackendEnabledV1Key, false);
      }
      return;
    }
    _engineV2BackendEnabledV1 = gatedValue;
    _emitSnapshot();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_engineV2BackendEnabledV1Key, gatedValue);
    _logSettingChange('engine_v2_backend_enabled_v1', gatedValue);
  }

  bool _clampEngineV2BackendEnabledV1(bool value) {
    if (!isCheckpointModeV1) {
      return false;
    }
    return value;
  }

  void _emitSnapshot() {
    _notifier.value = AppSettingsSnapshot(
      soundEnabled: _soundEnabled,
      hapticsEnabled: _hapticsEnabled,
      aiCoachEnabled: _aiCoachEnabled,
      engineV2BackendEnabledV1: _engineV2BackendEnabledV1,
    );
  }
}

/// Immutable snapshot of the current app settings which are consumed by UI.
class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.aiCoachEnabled = true,
    this.engineV2BackendEnabledV1 = false,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool aiCoachEnabled;
  final bool engineV2BackendEnabledV1;
}

void _logSettingChange(String key, Object? value) {
  // Non-blocking telemetry of settings changes
  FirebaseLiteTelemetryService.instance.logSettingChange(key, value);
}
