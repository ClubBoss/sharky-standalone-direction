import '../constants/telemetry_events.dart';
import '../infra/telemetry.dart';

Future<void> sessionStartTimingDefaultSink(
  int elapsedMs, {
  String? source,
}) async {
  await Telemetry.logEvent(TelemetryEvents.sessionStartTiming, {
    'elapsed_ms': elapsedMs,
    if (source != null) 'source': source,
  });
}
