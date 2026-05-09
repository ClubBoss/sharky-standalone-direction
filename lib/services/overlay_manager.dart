import 'dart:async';
import 'dart:collection';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

/// Types of transient overlays coordinated by [OverlayManager].
enum OverlayType { reward, levelUp, summary }

typedef OverlayDelegate = Future<void> Function(Map<String, Object?> payload);

class OverlayManager {
  OverlayManager._();

  static final OverlayManager instance = OverlayManager._();

  final Queue<_OverlayRequest> _queue = Queue<_OverlayRequest>();
  final Map<OverlayType, OverlayDelegate> _delegates =
      <OverlayType, OverlayDelegate>{};
  bool _isProcessing = false;

  /// Registers a delegate that can render the given [type] of overlay.
  void registerDelegate(OverlayType type, OverlayDelegate delegate) {
    _delegates[type] = delegate;
  }

  /// Unregisters the delegate for [type] if it matches [delegate].
  void unregisterDelegate(OverlayType type, OverlayDelegate delegate) {
    final current = _delegates[type];
    if (current == delegate) {
      _delegates.remove(type);
    }
  }

  /// Queues a new overlay request and returns a future that completes
  /// once the overlay has finished displaying.
  Future<void> show(OverlayType type, Map<String, Object?> payload) {
    final request = _OverlayRequest(
      type: type,
      payload: Map<String, Object?>.from(payload),
    );
    _queue.add(request);
    _logQueueLength();
    _processQueue();
    return request.completer.future;
  }

  void _processQueue() {
    if (_isProcessing || _queue.isEmpty) {
      return;
    }

    final request = _queue.removeFirst();
    final delegate = _delegates[request.type];
    if (delegate == null) {
      request.completer.complete();
      _processQueue();
      return;
    }

    _isProcessing = true;
    _logOverlayStart(request.type);

    Future<void>(() async {
      try {
        await delegate(request.payload);
      } finally {
        _isProcessing = false;
        request.completer.complete();
        _processQueue();
      }
    });
  }

  void _logQueueLength() {
    final length = _queue.length + (_isProcessing ? 1 : 0);
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'overlay_queue_length',
        params: <String, Object>{'length': length},
      ),
    );
  }

  void _logOverlayStart(OverlayType type) {
    final name = type.name;
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent('overlay_${name}_shown'),
    );
  }

  /// Clears the queue. Intended for tests.
  void resetForTesting() {
    _queue.clear();
    _isProcessing = false;
    _delegates.clear();
  }
}

class _OverlayRequest {
  _OverlayRequest({required this.type, required this.payload});

  final OverlayType type;
  final Map<String, Object?> payload;
  final Completer<void> completer = Completer<void>();
}
