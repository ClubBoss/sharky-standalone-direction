import 'dart:async' show unawaited;

import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';

import '../constants/telemetry_events.dart';
import '../infra/telemetry.dart';
import '../services/training_session_outcome.dart';

class TrainingSessionOutcomeTracker {
  TrainingSessionOutcomeTracker({required this.sessionId, this.onSessionEnd});

  final String sessionId;
  final TrainingSessionEndCallback? onSessionEnd;

  bool _signaled = false;
  bool _disposed = false;
  TrainingSessionEndReasonV1? _reason;

  TrainingSessionEndReasonV1? get endReason => _reason;
  bool get hasSignaled => _signaled;

  void signalEnd(TrainingSessionEndReasonV1 reason) {
    if (_signaled) return;
    _signaled = true;
    _reason = reason;
    if (reason == TrainingSessionEndReasonV1.aborted) {
      unawaited(UiHapticsV1.fire(UiHapticEventV1.error));
      UiSoundV1.fire(UiSoundEventV1.error);
      Telemetry.logEvent(TelemetryEvents.sessionAbort, {
        'sessionId': sessionId,
        'reason': reason.name,
      });
    }
    onSessionEnd?.call(reason);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_reason != TrainingSessionEndReasonV1.aborted) {
      unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
      UiSoundV1.fire(UiSoundEventV1.success);
      Telemetry.logEvent(TelemetryEvents.sessionEnd, {'sessionId': sessionId});
    }
  }
}
