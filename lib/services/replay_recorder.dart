import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';

/// Lightweight replay recorder for simulation hands.
///
/// Captures SimulationEvent objects in a circular buffer and exports to JSONL.
/// ASCII-safe output suitable for later review by AI Coach and analytics modules.
///
/// Features:
/// - Circular buffer (default 100 events) to prevent memory bloat
/// - Timestamp-ordered event capture
/// - JSONL export format (one event per line)
/// - Named replay files: replay_YYYYMMDD_HHMM.jsonl
class ReplayRecorder {
  ReplayRecorder({
    required this.engine,
    this.maxEvents = 100,
    this.replayDir = 'tools/replays',
  }) {
    _subscription = engine.eventStream.listen(_captureEvent);
  }

  final SimulationEngine engine;
  final int maxEvents;
  final String replayDir;

  final List<_ReplayEvent> _buffer = [];
  StreamSubscription<SimulationEvent>? _subscription;
  bool _disposed = false;

  /// Captures event and adds to circular buffer.
  void _captureEvent(SimulationEvent event) {
    if (_disposed) return;

    final replayEvent = _ReplayEvent(
      timestamp: event.timestamp,
      type: event.type,
      seatIndex: event.seatIndex,
      action: event.action?.toString(),
      amount: event.amount,
      street: event.street?.toString(),
      pot: event.pot,
    );

    _buffer.add(replayEvent);

    // Maintain circular buffer size
    if (_buffer.length > maxEvents) {
      _buffer.removeAt(0);
    }
  }

  /// Exports captured events to JSONL file.
  ///
  /// Returns the file path on success, null on failure.
  /// File naming: replay_YYYYMMDD_HHMM.jsonl
  Future<String?> exportReplay() async {
    if (_buffer.isEmpty) {
      return null; // No events to export
    }

    try {
      // Create directory if needed
      final dir = Directory(replayDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // Generate filename with timestamp
      final now = DateTime.now();
      final filename =
          'replay_${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}.jsonl';
      final filePath = '$replayDir/$filename';

      // Write events as JSONL (one JSON object per line)
      final file = File(filePath);
      final sink = file.openWrite();

      for (final event in _buffer) {
        final json = event.toJson();
        final line = jsonEncode(json);
        sink.writeln(line);
      }

      await sink.flush();
      await sink.close();

      return filePath;
    } catch (e) {
      // Fail silently in production, log in dev
      return null;
    }
  }

  /// Helper to zero-pad numbers.
  String _pad(int value) => value.toString().padLeft(2, '0');

  /// Clears the buffer (useful for testing).
  void clearBuffer() {
    _buffer.clear();
  }

  /// Returns current buffer size.
  int get eventCount => _buffer.length;

  /// Disposes resources.
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Internal representation of a replay event for JSON serialization.
class _ReplayEvent {
  _ReplayEvent({
    required this.timestamp,
    required this.type,
    required this.seatIndex,
    this.action,
    this.amount,
    this.street,
    this.pot,
  });

  final DateTime timestamp;
  final String type;
  final int seatIndex;
  final String? action;
  final int? amount;
  final String? street;
  final int? pot;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'seat_index': seatIndex,
      if (action != null) 'action': action,
      if (amount != null) 'amount': amount,
      if (street != null) 'street': street,
      if (pot != null) 'pot': pot,
    };
  }
}
