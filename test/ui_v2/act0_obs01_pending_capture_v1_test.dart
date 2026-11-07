import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hnp_trace_file_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

class _DelayedHistory
    implements Act0HnpTraceFileStoreV1, Act0HnpTraceHistoryReaderV1 {
  final prior = Completer<String?>();
  String contents = '';
  @override
  Future<String?> getPath() async => null;
  @override
  Future<String?> readPrevious() => prior.future;
  @override
  Future<void> replace(String jsonl) async => contents = jsonl;
}

Act0TelemetryEventV1 _event(int index) => Act0TelemetryEventV1(
  name: 'decision_made',
  fields: {'schemaVersion': 2, 'attempt_id': 'attempt_$index'},
);

Map _capture(Act0HnpTelemetrySinkV1 sink) =>
    (jsonDecode(sink.exportJson()) as Map)['capture'] as Map;

void main() {
  test(
    'OBS01 pending restore snapshots and filters before retaining',
    () async {
      final store = _DelayedHistory();
      final sink = Act0HnpTelemetrySinkV1(fileStore: store);
      final options = ['call', 'fold'];
      final fields = <String, Object?>{
        'schemaVersion': 2,
        'attempt_id': 'original_attempt',
        'acceptable_action_ids': options,
        'email': 'private@example.com',
      };
      sink.record(Act0TelemetryEventV1(name: 'decision_made', fields: fields));
      fields['attempt_id'] = 'mutated_attempt';
      options.add('mutated');
      expect(_capture(sink)['complete'], false);
      store.prior.complete(null);
      await sink.flushExport();
      expect(sink.events.single.fields['attempt_id'], 'original_attempt');
      expect(sink.events.single.fields['acceptable_action_ids'], [
        'call',
        'fold',
      ]);
      expect(sink.events.single.fields, isNot(contains('email')));
      expect(_capture(sink)['redactedFieldCount'], 1);
      expect(_capture(sink)['complete'], true);
      expect(store.contents, isNot(contains('private@example.com')));
    },
  );

  test(
    'OBS01 restore backpressure is bounded and losses stay explicit',
    () async {
      final firstStore = _DelayedHistory()..prior.complete(null);
      final first = Act0HnpTelemetrySinkV1(maxEvents: 3, fileStore: firstStore);
      first.record(_event(0));
      await first.flushExport();
      final store = _DelayedHistory();
      final sink = Act0HnpTelemetrySinkV1(maxEvents: 3, fileStore: store);
      for (var i = 1; i <= 20; i++) {
        sink.record(_event(i));
      }
      sink.record(const Act0TelemetryEventV1(name: 'unknown', fields: {}));
      expect(_capture(sink)['pendingEventCount'], 3);
      store.prior.complete(firstStore.contents);
      await sink.flushExport();
      expect(sink.events.map((e) => e.fields['attempt_id']), [
        'attempt_18',
        'attempt_19',
        'attempt_20',
      ]);
      final capture = _capture(sink);
      expect(capture['recordedEventCount'], 22);
      expect(capture['rejectedEventCount'], 1);
      expect(capture['evictedEventCount'], 18);
      expect(capture['complete'], false);
      expect(capture['priorCapture'], 'continued');
      final rows = store.contents.trim().split('\n').map(jsonDecode).toList();
      expect(rows.map((r) => r['sequence']), [19, 20, 21]);
    },
  );
}
