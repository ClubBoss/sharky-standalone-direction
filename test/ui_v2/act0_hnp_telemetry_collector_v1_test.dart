import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hnp_trace_file_store_v1.dart';

class _MemoryFileStoreV1 implements Act0HnpTraceFileStoreV1 {
  _MemoryFileStoreV1({this.throwOnWrite = false});

  final bool throwOnWrite;
  String contents = 'unchanged';
  int writeCount = 0;

  @override
  Future<String> getPath() async => '/local/act0_hnp_trace_v1.jsonl';

  @override
  Future<void> replace(String jsonl) async {
    writeCount += 1;
    if (throwOnWrite) throw StateError('unavailable');
    contents = jsonl;
  }
}

void main() {
  test('canonical HNP policy is opt-in and never active in release mode', () {
    expect(
      act0CanonicalTelemetrySinkV1(hnpEnabled: false, isReleaseMode: false),
      isNull,
    );
    expect(
      act0CanonicalTelemetrySinkV1(hnpEnabled: true, isReleaseMode: true),
      isNull,
    );
    expect(
      act0CanonicalTelemetrySinkV1(hnpEnabled: true, isReleaseMode: false),
      isA<Act0HnpTelemetrySinkV1>(),
    );
  });

  test('local HNP export is ordered, bounded, and structured', () {
    final sink = Act0HnpTelemetrySinkV1(
      maxEvents: 2,
      fileStore: _MemoryFileStoreV1(),
    );
    sink.record(
      const Act0TelemetryEventV1(
        name: 'task_shown',
        fields: <String, Object?>{},
      ),
    );
    sink.record(
      const Act0TelemetryEventV1(
        name: 'user_choice',
        fields: <String, Object?>{'choiceId': 'fold'},
      ),
    );
    sink.record(
      const Act0TelemetryEventV1(
        name: 'task_result',
        fields: <String, Object?>{'result': 'incorrect'},
      ),
    );

    final trace = jsonDecode(sink.exportJson()) as Map<String, dynamic>;
    expect(trace['schema'], 'act0_hnp_local_trace_v1');
    expect(trace['events'].map((event) => event['name']).toList(), <String>[
      'user_choice',
      'task_result',
    ]);
  });

  test(
    'HNP file export preserves a complete oversized event as JSONL',
    () async {
      final store = _MemoryFileStoreV1();
      final sink = Act0HnpTelemetrySinkV1(fileStore: store);
      final oversized = List<String>.filled(2300, 'x').join();
      sink.record(
        Act0TelemetryEventV1(
          name: 'decision_made',
          fields: <String, Object?>{'detail': oversized},
        ),
      );
      sink.record(
        const Act0TelemetryEventV1(
          name: 'task_result',
          fields: <String, Object?>{'result': 'incorrect'},
        ),
      );

      await sink.flushExport();
      final lines = store.contents.trimRight().split('\n');
      final decoded = lines.map((line) => jsonDecode(line)).toList();
      expect(lines, hasLength(2));
      expect(decoded[0]['name'], 'decision_made');
      expect((decoded[0]['fields']['detail'] as String).length, 2300);
      expect(decoded.map((event) => event['name']), <String>[
        'decision_made',
        'task_result',
      ]);
      expect(sink.events, hasLength(2));
      expect(store.contents, isNot(contains('…')));
    },
  );

  test(
    'HNP JSONL retention and replacement lifecycle are deterministic',
    () async {
      final store = _MemoryFileStoreV1();
      final sink = Act0HnpTelemetrySinkV1(maxEvents: 2, fileStore: store);
      for (final name in <String>['one', 'two', 'three']) {
        sink.record(Act0TelemetryEventV1(name: name, fields: const {}));
      }
      await sink.flushExport();
      final retained = store.contents
          .trimRight()
          .split('\n')
          .map((line) => (jsonDecode(line) as Map<String, dynamic>)['name'])
          .toList();
      expect(retained, <String>['two', 'three']);
      expect(sink.events.map((event) => event.name), retained);

      final replacement = Act0HnpTelemetrySinkV1(fileStore: store);
      await replacement.flushExport();
      expect(store.contents, isEmpty);
    },
  );

  test('HNP export failure does not alter collector events', () async {
    final sink = Act0HnpTelemetrySinkV1(
      fileStore: _MemoryFileStoreV1(throwOnWrite: true),
    );
    sink.record(
      const Act0TelemetryEventV1(
        name: 'task_shown',
        fields: <String, Object?>{},
      ),
    );
    await sink.flushExport();
    expect(sink.events.single.name, 'task_shown');
  });
}
