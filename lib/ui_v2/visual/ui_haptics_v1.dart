import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';

/// Canonical haptics contract for v2 (non-table) UI surfaces.
/// The settings screen already exposes a [haptics_enabled] toggle stored by
/// [AppSettingsService], so we rely on that toggle to gate the feedback calls.
enum UiHapticEventV1 { success, error }

class UiHapticsV1 {
  UiHapticsV1._();

  static final Map<UiHapticEventV1, Future<void> Function()> _defaultHandlers =
      {
        UiHapticEventV1.success: HapticFeedback.lightImpact,
        UiHapticEventV1.error: HapticFeedback.heavyImpact,
      };

  static Map<UiHapticEventV1, Future<void> Function()> _handlers = Map.from(
    _defaultHandlers,
  );

  static bool get enabled =>
      AppSettingsService.instance.snapshot.hapticsEnabled;

  static Future<void> fire(UiHapticEventV1 event) async {
    if (!enabled) return;
    final handler = _handlers[event];
    if (handler != null) {
      await handler();
    }
  }

  @visibleForTesting
  static void setHandler(
    UiHapticEventV1 event,
    Future<void> Function() handler,
  ) {
    _handlers[event] = handler;
  }

  @visibleForTesting
  static void resetHandlers() {
    _handlers = Map.from(_defaultHandlers);
  }
}
