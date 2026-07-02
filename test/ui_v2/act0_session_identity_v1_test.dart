import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_session_identity_v1.dart';

void main() {
  test('first session gets a deterministic local id', () {
    final result = const Act0SessionIdentityStateV1().startOrResume(
      startedAtOrder: 1,
      startedWorldId: 'world_1',
      startedLessonId: 'fold_check_call_raise',
    );

    expect(result.startedNewSession, isTrue);
    expect(result.session.sessionId, 'session_v1|1');
    expect(result.state.currentActiveSessionId, 'session_v1|1');
    expect(result.session.status, act0SessionIdentityStatusActiveV1);
  });

  test('same active session reuses the same id on repeated reads', () {
    final first = const Act0SessionIdentityStateV1().startOrResume(
      startedAtOrder: 1,
      startedWorldId: 'world_1',
      startedLessonId: 'fold_check_call_raise',
    );
    final second = first.state.startOrResume(
      startedAtOrder: 2,
      startedWorldId: 'world_1',
      startedLessonId: 'fold_check_call_raise',
    );

    expect(second.startedNewSession, isFalse);
    expect(second.session.sessionId, first.session.sessionId);
    expect(second.state.nextSessionOrdinal, 2);
  });

  test('serialization rebuild does not create a new id', () {
    final first = const Act0SessionIdentityStateV1().startOrResume(
      startedAtOrder: 1,
      startedWorldId: 'world_1',
    );
    final parsed = Act0SessionIdentityStateV1.tryParse(
      jsonDecode(first.state.toStorageString()),
    );
    final resumed = parsed.startOrResume(
      startedAtOrder: 3,
      startedWorldId: 'world_1',
    );

    expect(resumed.startedNewSession, isFalse);
    expect(resumed.session.sessionId, 'session_v1|1');
    expect(resumed.state.nextSessionOrdinal, 2);
  });

  test('completion uses the same id and is idempotent', () {
    final first = const Act0SessionIdentityStateV1().startOrResume(
      startedAtOrder: 1,
      startedWorldId: 'world_1',
    );
    final completed = first.state.complete(
      completedAtOrder: 7,
      completionReason: 'act0_completion',
    );
    final repeated = completed.state.complete(
      completedAtOrder: 8,
      completionReason: 'act0_completion',
    );

    expect(completed.completedNow, isTrue);
    expect(completed.session!.sessionId, first.session.sessionId);
    expect(completed.session!.status, act0SessionIdentityStatusCompletedV1);
    expect(completed.session!.completedAtOrder, 7);
    expect(repeated.completedNow, isFalse);
    expect(repeated.session!.sessionId, first.session.sessionId);
  });

  test('next session after completion receives a new id', () {
    final first = const Act0SessionIdentityStateV1().startOrResume(
      startedAtOrder: 1,
      startedWorldId: 'world_1',
    );
    final completed = first.state.complete(
      completedAtOrder: 3,
      completionReason: 'practice_complete',
    );
    final next = completed.state.startOrResume(
      startedAtOrder: 4,
      startedWorldId: 'world_1',
    );

    expect(next.startedNewSession, isTrue);
    expect(next.session.sessionId, 'session_v1|2');
    expect(next.session.sessionId, isNot(first.session.sessionId));
  });

  test('persisted monotonic ordinal avoids collision after reload', () {
    const persisted = <String, Object?>{
      'schemaVersion': 1,
      'nextSessionOrdinal': 1,
      'latestSession': <String, Object?>{
        'schemaVersion': 1,
        'sessionId': 'session_v1|4',
        'startedAtOrder': 9,
        'startedWorldId': 'world_1',
        'status': 'completed',
        'completedAtOrder': 11,
      },
    };

    final parsed = Act0SessionIdentityStateV1.tryParse(persisted);
    final next = parsed.startOrResume(
      startedAtOrder: 12,
      startedWorldId: 'world_1',
    );

    expect(parsed.nextSessionOrdinal, 5);
    expect(next.session.sessionId, 'session_v1|5');
  });

  test('old or malformed optional state falls back safely', () {
    expect(
      Act0SessionIdentityStateV1.tryParse(null),
      const Act0SessionIdentityStateV1(),
    );
    expect(
      Act0SessionIdentityStateV1.tryParse(<String, Object?>{
        'schemaVersion': 1,
        'nextSessionOrdinal': 'bad',
        'currentSession': <String, Object?>{'schemaVersion': 1},
      }),
      const Act0SessionIdentityStateV1(),
    );
  });

  test('source has no random, wall-clock, dependency, or telemetry owner', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_session_identity_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('DateTime.now')));
    expect(source, isNot(contains('Random')));
    expect(source, isNot(contains('uuid')));
    expect(source, isNot(contains('Telemetry')));
    expect(source, isNot(contains('package:flutter/')));
  });
}
