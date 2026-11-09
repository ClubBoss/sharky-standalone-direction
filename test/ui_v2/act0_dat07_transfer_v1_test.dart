import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_transfer_v1.dart';

class _MemoryPort implements Act0Dat07ProgressPortV1 {
  _MemoryPort([this.current]);

  String? current;
  bool interruptNextWrite = false;
  bool loseAckAfterLanding = false;
  bool changeAtWrite = false;
  int writes = 0;

  @override
  Future<String?> readDurablePayload() async => current;

  @override
  Future<Act0Dat07WriteResultV1> restoreIfUnchanged({
    required String? expectedPayload,
    required String incomingPayload,
  }) async {
    if (changeAtWrite) {
      changeAtWrite = false;
      current = _progress(xp: 3, task: 'concurrent');
    }
    if (current != expectedPayload) return Act0Dat07WriteResultV1.changed;
    if (interruptNextWrite) {
      interruptNextWrite = false;
      return Act0Dat07WriteResultV1.unverified;
    }
    current = incomingPayload;
    writes++;
    if (loseAckAfterLanding) {
      loseAckAfterLanding = false;
      return Act0Dat07WriteResultV1.unverified;
    }
    return Act0Dat07WriteResultV1.committed;
  }
}

String _progress({int xp = 35, String task = 'w1_a'}) => jsonEncode({
  'schemaVersion': 19,
  'earnedXp': xp,
  'completedTaskIds': [task],
  'completedLessonIds': ['guide'],
  'learningEvidenceHistory': [
    {
      'recordId': 'attempt-a',
      'taskId': task,
      'choiceId': 'call',
      'assistanceKind': 'quickHint',
      'isCorrect': false,
      'errorType': 'missed_signal',
      'runId': 'run-1',
      'sessionId': 'session-1',
    },
    {
      'recordId': 'attempt-b',
      'taskId': task,
      'choiceId': 'fold',
      'assistanceKind': 'none',
      'isCorrect': true,
      'errorType': 'none',
      'runId': 'run-2',
      'sessionId': 'session-2',
    },
  ],
  'openRepairIntents': [
    {'sourceTaskId': task, 'repairOccurrenceId': 'repair-1'},
  ],
});

final _codec = Act0Dat07CodecV1(
  supportedProgressSchema: 19,
  isValidProgress: (raw) {
    final decoded = jsonDecode(raw);
    return decoded is Map && decoded['schemaVersion'] == 19;
  },
);

Uint8List _file(String progress) => _codec.exportPayload(
  progress,
  exportedAtUtc: DateTime.utc(2026, 11, 9),
);

Uint8List _rewrite(
  Uint8List raw,
  void Function(Map<String, dynamic> data) edit,
) {
  final map = Map<String, dynamic>.from(jsonDecode(utf8.decode(raw)) as Map);
  edit(map);
  return Uint8List.fromList(utf8.encode(jsonEncode(map)));
}

void main() {
  test('DAT07 success: exact IDs, assistance, answers, repairs and XP survive', () async {
    final original = _progress();
    final source = Act0Dat07TransferV1(
      codec: _codec,
      port: _MemoryPort(original),
    );
    final bytes = await source.export(exportedAtUtc: DateTime.utc(2026, 11, 9));
    final destination = _MemoryPort();
    final transfer = Act0Dat07TransferV1(codec: _codec, port: destination);
    final preview = await transfer.inspect(bytes);
    expect(preview.backup.schemaVersion, 19);
    expect(preview.backup.earnedXp, 35);
    expect(preview.backup.completedTasks, 1);
    expect(preview.backup.includesEvidence, true);
    expect(preview.mayRestore, true);
    expect(await transfer.confirm(preview), Act0Dat07RestoreOutcomeV1.restored);
    expect(destination.current, original);
    expect(destination.writes, 1);
    final evidence = (jsonDecode(destination.current!) as Map)['learningEvidenceHistory'];
    expect((evidence as List).map((e) => e['recordId']), ['attempt-a', 'attempt-b']);
  });

  test('DAT07 duplicate import: idempotent, zero new XP or writes', () async {
    final original = _progress();
    final destination = _MemoryPort();
    final transfer = Act0Dat07TransferV1(codec: _codec, port: destination);
    final bytes = _file(original);
    expect(
      await transfer.confirm(await transfer.inspect(bytes)),
      Act0Dat07RestoreOutcomeV1.restored,
    );
    final second = await transfer.inspect(bytes);
    expect(second.alreadyPresent, true);
    expect(
      await transfer.confirm(second),
      Act0Dat07RestoreOutcomeV1.alreadyPresent,
    );
    expect(destination.writes, 1);
    expect((jsonDecode(destination.current!) as Map)['earnedXp'], 35);
  });

  test('DAT07 conflict refuses to replace nonempty local learner history', () async {
    final local = _progress(xp: 12, task: 'local');
    final destination = _MemoryPort(local);
    final transfer = Act0Dat07TransferV1(codec: _codec, port: destination);
    final preview = await transfer.inspect(_file(_progress()));
    expect(preview.conflict, true);
    expect(preview.mayRestore, false);
    expect(
      await transfer.confirm(preview),
      Act0Dat07RestoreOutcomeV1.conflict,
    );
    expect(destination.current, local);
    expect(destination.writes, 0);
  });

  test('DAT07 unknown envelope and progress schema are rejected', () {
    final source = _file(_progress());
    final futureEnvelope = _rewrite(
      source,
      (m) => m['formatRevision'] = 99,
    );
    expect(
      () => _codec.inspectBytes(futureEnvelope),
      throwsA(isA<Act0Dat07ErrorV1>().having(
        (e) => e.code,
        'code',
        Act0Dat07ErrorCodeV1.unsupportedFormat,
      )),
    );
    final futureSchema = _rewrite(
      source,
      (m) => m['progressSchemaVersion'] = 999,
    );
    expect(
      () => _codec.inspectBytes(futureSchema),
      throwsA(isA<Act0Dat07ErrorV1>().having(
        (e) => e.code,
        'code',
        Act0Dat07ErrorCodeV1.unsupportedSchema,
      )),
    );
  });

  test('DAT07 corruption and partial parsed payload never reach the port', () async {
    final source = _file(_progress());
    final damaged = _rewrite(
      source,
      (m) => m['payload'] = '${m['payload']}X',
    );
    expect(
      () => _codec.inspectBytes(damaged),
      throwsA(isA<Act0Dat07ErrorV1>().having(
        (e) => e.code,
        'code',
        Act0Dat07ErrorCodeV1.invalidDigest,
      )),
    );
    final partial = _rewrite(source, (m) {
      final payload = Map<String, dynamic>.from(
        jsonDecode(m['payload'] as String) as Map,
      );
      payload.remove('learningEvidenceHistory');
      final newPayload = jsonEncode(payload);
      m['payload'] = newPayload;
      m['payloadLength'] = utf8.encode(newPayload).length;
      m['payloadSha256'] = Act0Dat07CodecV1.digest(newPayload);
    });
    expect(
      () => _codec.inspectBytes(partial),
      throwsA(isA<Act0Dat07ErrorV1>().having(
        (e) => e.code,
        'code',
        Act0Dat07ErrorCodeV1.invalidProgress,
      )),
    );
    final destination = _MemoryPort();
    expect(destination.writes, 0);
    expect(destination.current, isNull);
  });

  test('DAT07 interrupted write stays unverified, never claims success', () async {
    final destination = _MemoryPort()..interruptNextWrite = true;
    final transfer = Act0Dat07TransferV1(codec: _codec, port: destination);
    final preview = await transfer.inspect(_file(_progress()));
    expect(
      await transfer.confirm(preview),
      Act0Dat07RestoreOutcomeV1.notVerified,
    );
    expect(destination.current, isNull);
    expect(destination.writes, 0);
  });

  test('DAT07 CAS race during commit does not overwrite a new decision', () async {
    final destination = _MemoryPort()..changeAtWrite = true;
    final transfer = Act0Dat07TransferV1(codec: _codec, port: destination);
    final preview = await transfer.inspect(_file(_progress()));
    expect(
      await transfer.confirm(preview),
      Act0Dat07RestoreOutcomeV1.conflict,
    );
    expect(destination.current, contains('concurrent'));
    expect(destination.writes, 0);
  });

  test('DAT07 indeterminate ACK cannot award twice on retry', () async {
    final original = _progress();
    final destination = _MemoryPort()..loseAckAfterLanding = true;
    final transfer = Act0Dat07TransferV1(codec: _codec, port: destination);
    expect(
      await transfer.confirm(await transfer.inspect(_file(original))),
      Act0Dat07RestoreOutcomeV1.notVerified,
    );
    expect(destination.current, original);
    expect(destination.writes, 1);
    final retry = await transfer.inspect(_file(original));
    expect(retry.alreadyPresent, true);
    expect(
      await transfer.confirm(retry),
      Act0Dat07RestoreOutcomeV1.alreadyPresent,
    );
    expect(destination.writes, 1);
  });

  test('DAT07 rejects invalid timestamp, truncation, and oversized files', () {
    final source = _file(_progress());
    final dateDamaged = _rewrite(
      source,
      (m) => m['createdAtUtc'] = 'not-a-date',
    );
    expect(
      () => _codec.inspectBytes(dateDamaged),
      throwsA(isA<Act0Dat07ErrorV1>().having(
        (e) => e.code,
        'code',
        Act0Dat07ErrorCodeV1.invalidFile,
      )),
    );
    expect(
      () => _codec.inspectBytes(Uint8List.fromList(
        source.sublist(0, source.length ~/ 2),
      )),
      throwsA(isA<Act0Dat07ErrorV1>()),
    );
    expect(
      () => _codec.inspectBytes(Uint8List(act0Dat07MaxFileBytesV1 + 1)),
      throwsA(isA<Act0Dat07ErrorV1>().having(
        (e) => e.code,
        'code',
        Act0Dat07ErrorCodeV1.tooLarge,
      )),
    );
  });

  test('DAT07 preview cancellation and changed-local race never write', () async {
    final destination = _MemoryPort();
    final transfer = Act0Dat07TransferV1(codec: _codec, port: destination);
    final preview = await transfer.inspect(_file(_progress()));
    // User cancelled the preview: confirm() is intentionally not invoked.
    expect(preview.mayRestore, true);
    expect(destination.writes, 0);
    destination.current = _progress(xp: 1, task: 'arrived-later');
    expect(
      await transfer.confirm(preview),
      Act0Dat07RestoreOutcomeV1.conflict,
    );
    expect(destination.writes, 0);
    expect(destination.current, contains('arrived-later'));
  });

  test('DAT07 a store rejecting source payload is never bypassed', () {
    final rejecting = Act0Dat07CodecV1(
      supportedProgressSchema: 19,
      isValidProgress: (_) => false,
    );
    expect(
      () => rejecting.inspectBytes(_file(_progress())),
      throwsA(isA<Act0Dat07ErrorV1>().having(
        (e) => e.code,
        'code',
        Act0Dat07ErrorCodeV1.invalidProgress,
      )),
    );
  });
}
