import 'package:poker_analyzer/services/debug_panel_preferences.dart';
import 'package:flutter/foundation.dart';

final _retentionPref = <DebugPanelPreferences, bool>{};
final _delayPref = <DebugPanelPreferences, int>{};
final _listeners = <DebugPanelPreferences, List<VoidCallback>>{};

extension DebugPanelPreferencesCompat on DebugPanelPreferences {
  void addListener(VoidCallback listener) =>
      _listeners.putIfAbsent(this, () => <VoidCallback>[]).add(listener);
  void removeListener(VoidCallback listener) =>
      _listeners[this]?.remove(listener);
  bool get snapshotRetentionEnabled => _retentionPref[this] ?? false;
  set snapshotRetentionEnabled(bool value) => _retentionPref[this] = value;
  int get processingDelay => _delayPref[this] ?? 500;
  Future<void> loadSnapshotRetention() async {}
  Future<void> loadProcessingDelay() async {}
}
