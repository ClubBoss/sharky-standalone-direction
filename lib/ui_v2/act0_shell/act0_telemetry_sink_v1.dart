import 'dart:convert';
import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show debugPrint;

import 'act0_hnp_trace_file_store_v1.dart';

class Act0TelemetryEventV1 {
  const Act0TelemetryEventV1({required this.name, required this.fields});

  final String name;
  final Map<String, Object?> fields;
}

abstract class Act0TelemetrySinkV1 {
  void record(Act0TelemetryEventV1 event);
}

class Act0InMemoryTelemetrySinkV1 implements Act0TelemetrySinkV1 {
  final List<Act0TelemetryEventV1> events = <Act0TelemetryEventV1>[];

  @override
  void record(Act0TelemetryEventV1 event) {
    events.add(event);
  }
}

/// Local-only, bounded Human Novice Proof collector.
///
/// It writes the authoritative complete JSONL export only to a local,
/// HNP-session file. Debug-console rows remain diagnostic because platform log
/// rendering may truncate large payloads.
class Act0HnpTelemetrySinkV1 extends Act0InMemoryTelemetrySinkV1 {
  Act0HnpTelemetrySinkV1({
    this.maxEvents = 256,
    Act0HnpTraceFileStoreV1? fileStore,
  }) : _fileStore = fileStore ?? createAct0HnpTraceFileStoreV1() {
    _scheduleExport();
  }

  final int maxEvents;
  final Act0HnpTraceFileStoreV1? _fileStore;
  Future<void> _pendingExport = Future<void>.value();
  bool _exportFailureReported = false;
  bool _exportPathReported = false;

  @override
  void record(Act0TelemetryEventV1 event) {
    if (events.length == maxEvents) {
      events.removeAt(0);
    }
    super.record(event);
    debugPrint(
      'HNP_TRACE_V1 ${jsonEncode(<String, Object?>{'name': event.name, 'fields': event.fields})}',
    );
    _scheduleExport();
  }

  String exportJson() => jsonEncode(<String, Object?>{
    'schema': 'act0_hnp_local_trace_v1',
    'events': events
        .map(
          (event) => <String, Object?>{
            'name': event.name,
            'fields': event.fields,
          },
        )
        .toList(growable: false),
  });

  /// One complete event per physical line, in the collector's retained order.
  String exportJsonl() {
    final jsonl = events
        .map(
          (event) => jsonEncode(<String, Object?>{
            'name': event.name,
            'fields': event.fields,
          }),
        )
        .join('\n');
    return jsonl.isEmpty ? '' : '$jsonl\n';
  }

  /// Lets deterministic tests and proof tooling wait for the non-blocking
  /// local export. Failures never affect collector or learner execution.
  Future<void> flushExport() => _pendingExport;

  void _scheduleExport() {
    if (_fileStore == null) return;
    _pendingExport = _pendingExport.then((_) async {
      try {
        await _fileStore.replace(exportJsonl());
        if (!_exportPathReported) {
          _exportPathReported = true;
          final path = await _fileStore.getPath();
          if (path != null) debugPrint('HNP_TRACE_EXPORT_V1 $path');
        }
      } catch (_) {
        if (!_exportFailureReported) {
          _exportFailureReported = true;
          debugPrint('HNP_TRACE_V1 local export unavailable.');
        }
      }
    });
    unawaited(_pendingExport);
  }
}

/// The one canonical-entry policy: HNP capture is debug-only and opt-in.
Act0TelemetrySinkV1? act0CanonicalTelemetrySinkV1({
  required bool hnpEnabled,
  required bool isReleaseMode,
}) => hnpEnabled && !isReleaseMode ? Act0HnpTelemetrySinkV1() : null;
