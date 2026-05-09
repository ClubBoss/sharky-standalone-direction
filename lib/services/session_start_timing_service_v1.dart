import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import 'session_start_timing_default_sink_stub.dart'
    if (dart.library.ui) 'session_start_timing_default_sink_flutter.dart';

typedef SessionStartTimingSink =
    Future<void> Function(int elapsedMs, {String? source});

class SessionStartTimingServiceV1 {
  SessionStartTimingServiceV1({
    DateTime Function()? clock,
    SessionStartTimingSink? sink,
  }) : _clock = clock ?? DateTime.now,
       _sink = sink ?? sessionStartTimingDefaultSink;

  static final SessionStartTimingServiceV1 instance =
      SessionStartTimingServiceV1();

  static const int sessionStartBudgetMs = 500;

  final DateTime Function() _clock;
  final SessionStartTimingSink _sink;

  DateTime? _startTime;
  String? _source;
  bool _captured = false;
  int? _lastElapsedMs;

  @visibleForTesting
  int? get lastElapsedMs => _lastElapsedMs;

  void start({String? source}) {
    if (_startTime != null) {
      return;
    }
    _startTime = _clock();
    _source = source;
    _captured = false;
    _lastElapsedMs = null;
  }

  void markFirstFrameRendered() {
    final start = _startTime;
    if (start == null || _captured) {
      return;
    }
    var elapsedMs = _clock().difference(start).inMilliseconds;
    if (elapsedMs < 0) {
      elapsedMs = 0;
    }
    _captured = true;
    _startTime = null;
    _lastElapsedMs = elapsedMs;
    final source = _source;
    _source = null;
    unawaited(_sink(elapsedMs, source: source));
  }
}
