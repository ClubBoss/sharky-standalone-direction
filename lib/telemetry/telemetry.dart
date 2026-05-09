import "dart:core" as core;
import 'dart:core';
// ASCII-only; pure Dart (no Flutter deps)

import 'package:poker_analyzer/live/live_runtime.dart';

String liveModeTag() => LiveRuntime.isLive ? 'live' : 'online';

Map<String, Object?> withMode(Map<String, Object?> base) {
  final out = Map<String, Object?>.from(base);
  out['mode'] = liveModeTag();
  return out;
}
