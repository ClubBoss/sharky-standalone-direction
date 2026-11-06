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
        fields: <String, Object?>{'schemaVersion': 1},
      ),
    );
    sink.record(
      const Act0TelemetryEventV1(
        name: 'user_choice',
        fields: <String, Object?>{'schemaVersion': 1, 'choiceId': 'fold'},
      ),
    );
    sink.record(
      const Act0TelemetryEventV1(
        name: 'task_result',
        fields: <String, Object?>{'schemaVersion': 1, 'result': 'incorrect'},
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
      final oversized = List<String>.generate(
        64,
        (i) => 'action_${i}_${List.filled(40, 'x').join()}',
      );
      sink.record(
        Act0TelemetryEventV1(
          name: 'decision_made',
          fields: <String, Object?>{
            'schemaVersion': 1,
            'acceptable_action_ids': oversized,
          },
        ),
      );
      sink.record(
        const Act0TelemetryEventV1(
          name: 'task_result',
          fields: <String, Object?>{'schemaVersion': 1, 'result': 'incorrect'},
        ),
      );

      await sink.flushExport();
      final lines = store.contents.trimRight().split('\n');
      final decoded = lines.map((line) => jsonDecode(line)).toList();
      expect(lines, hasLength(2));
      expect(decoded[0]['name'], 'decision_made');
      expect(decoded[0]['fields']['acceptable_action_ids'], oversized);
      expect(lines.first.length, greaterThan(2300));
      expect(decoded.map((event) => event['name']), <String>[
        'decision_made',
        'task_result',
      ]);
      expect(sink.events, hasLength(2));
      expect(store.contents, isNot(contains('…')));
    },
  );

  test(
    'HNP JSONL retains permitted Action telemetry projection fields',
    () async {
      final store = _MemoryFileStoreV1();
      final sink = Act0HnpTelemetrySinkV1(fileStore: store);
      sink.record(
        const Act0TelemetryEventV1(
          name: 'task_result',
          fields: <String, Object?>{
            'schemaVersion': 1,
            'taskId': 'actions_check_drill',
            'choiceId': 'fold',
            'result': 'incorrect',
            'errorType': 'misread_action_legality',
            'decisionTimeBucket': '3_to_10s',
          },
        ),
      );

      await sink.flushExport();
      final physical =
          jsonDecode(store.contents.trim()) as Map<String, dynamic>;
      final fields = physical['fields'] as Map<String, dynamic>;
      expect(fields['choiceId'], 'fold');
      expect(fields['result'], 'incorrect');
      expect(fields['errorType'], 'misread_action_legality');
      expect(fields['decisionTimeBucket'], '3_to_10s');
      expect(fields, isNot(contains('tableContextKey')));
      expect(fields, isNot(contains('table_context_key')));
      expect(
        jsonEncode(fields),
        isNot(contains('w1_action_words_no_bet_read_v1')),
      );
    },
  );

  test(
    'HNP JSONL retention and replacement lifecycle are deterministic',
    () async {
      final store = _MemoryFileStoreV1();
      final sink = Act0HnpTelemetrySinkV1(maxEvents: 2, fileStore: store);
      for (final name in <String>['task_shown', 'user_choice', 'task_result']) {
        sink.record(
          Act0TelemetryEventV1(name: name, fields: const {'schemaVersion': 1}),
        );
      }
      await sink.flushExport();
      final retained = store.contents
          .trimRight()
          .split('\n')
          .map((line) => (jsonDecode(line) as Map<String, dynamic>)['name'])
          .toList();
      expect(retained, <String>['user_choice', 'task_result']);
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
        fields: <String, Object?>{'schemaVersion': 1},
      ),
    );
    await sink.flushExport();
    expect(sink.events.single.name, 'task_shown');
  });
}
