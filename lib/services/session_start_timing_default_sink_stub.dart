/// Default sink used when Flutter's `dart:ui` is unavailable (e.g., `dart test`).
Future<void> sessionStartTimingDefaultSink(
  int elapsedMs, {
  String? source,
}) async {}
