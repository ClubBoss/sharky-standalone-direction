import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/core/services/audio_service.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';

/// Lightweight single-source-of-truth for ad-hoc UI sound cues.
enum UiSoundEventV1 { tap, success, error }

typedef UiSoundHandlerV1 = void Function(UiSoundEventV1 event);

class UiSoundV1 {
  UiSoundV1._();

  static UiSoundHandlerV1 _handler = _defaultHandler;

  static Iterable<UiSoundEventV1> get supportedEvents => UiSoundEventV1.values;

  static bool get isEnabled => AppSettingsService.instance.soundEnabled;

  static void fire(UiSoundEventV1 event) {
    if (!isEnabled) return;
    try {
      _handler(event);
    } catch (error, stack) {
      debugPrint('UiSoundV1 handler error for $event: $error');
      if (stack != null) {
        debugPrint(stack.toString());
      }
    }
  }

  @visibleForTesting
  static void overrideHandler(UiSoundHandlerV1 handler) {
    _handler = handler;
  }

  @visibleForTesting
  static void resetHandler() {
    _handler = _defaultHandler;
  }

  static void _defaultHandler(UiSoundEventV1 event) {
    unawaited(AudioService.instance.playUiSfx(event.name));
  }
}
