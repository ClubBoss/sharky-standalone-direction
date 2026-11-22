import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _task = 'w4_cheap_price_marginal_call';
final _recorded = DateTime.utc(2026, 11, 22, 13, 0);
const _trail = [
  Act0ActionTrailItemV1(
    label: 'Turn: CO bets 2 BB',
    displayLabel: 'CO bets 2 BB',
  ),
  Act0ActionTrailItemV1.note(label: 'Action returns to BB'),
];

Act0LearningEvidenceRecordV1 _evidence(
  int n, {
  String revision =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.quickHint,
  bool callIsCorrect = false,
}) => Act0LearningEvidenceRecordV1(
  recordId: 'attempt-$n',
  createdOrder: n,
  worldId: 'world_4',
  lessonId: 'call_price',
  taskId: _task,
  choiceId: 'call',
  expectedChoiceId: callIsCorrect ? 'call' : 'fold',
  isCorrect: callIsCorrect,
  errorType: callIsCorrect ? 'none' : 'price',
  repairFocusId: 'pot',
  skillAtomId: 'call_price',
  decisionTimeBucket: 'under_3s',
  resultKind: callIsCorrect ? 'correct' : 'suboptimal',
  authoredSourceFingerprint: revision,
  recordedAtUtc: _recorded,
  assistanceKind: assistance,
);

Act0ArchivedAttemptV1 _attempt(int n) =>
    Act0ArchivedAttemptV1.fromRecordedDecision(
      _evidence(n),
      reflection: const Act0AttemptReflectionV1(
        confidence: Act0DecisionConfidenceV1.verySure,
        openedClue: Act0CausalClueV1.callPrice,
      ),
      recordedTrail: _trail,
      taskLabel: "How does the price affect your decision?",
      choiceLabel: "Call",
    )!;

void main() {
  test(
    'migrates only exact older decisions and leaves their journal empty',
    () {
      final history = Act0LearningEvidenceHistoryV1(
        records: [
          _evidence(1, revision: ''),
          _evidence(2),
          _evidence(3, assistance: Act0DecisionAssistanceV1.legacyUnknown),
        ],
      );
      final archive = Act0AttemptArchiveV1.fromOlderSave(history);
      final attempt = archive.attempts.single;
      expect(attempt.id, 'attempt-2');
      expect(attempt.events, isEmpty);
      expect(attempt.taskLabel, isNull);
      expect(attempt.choiceLabel, isNull);
    },
  );

  test('restores exact version, choice, help, grade, time and journal', () {
    final archive = const Act0AttemptArchiveV1.empty()
        .add(_attempt(1))
        .select('attempt-1');
    final restored = Act0AttemptArchiveV1.restore(
      jsonDecode(jsonEncode(archive.toPayload())),
    );
    expect(restored.toPayload(), archive.toPayload());
    final row = restored.selected!;
    expect(row.evidence.recordedAtUtc, _recorded);
    expect(row.evidence.resultKind, 'suboptimal');
    expect(row.evidence.isCorrect, isFalse);
    expect(row.evidence.assistanceKind, Act0DecisionAssistanceV1.quickHint);
    expect(row.reflection.confidence, Act0DecisionConfidenceV1.verySure);
  });

  test(
    'bounds the archive, never substitutes on missing or deleted selection',
    () {
      var archive = const Act0AttemptArchiveV1.empty()
          .add(_attempt(1))
          .select('attempt-1');
      for (var n = 2; n <= 201; n++) {
        archive = archive.add(_attempt(n));
      }
      expect(archive.attempts, hasLength(200));
      expect(archive.attempts.first.id, 'attempt-201');
      expect(archive.attempts.last.id, 'attempt-2');
      expect(archive.selected, isNull);
      expect(archive.add(_attempt(201)), same(archive));
      expect(
        archive.select('attempt-201').remove('attempt-201').selected,
        isNull,
      );
      expect(archive.select('missing').selectedId, isNull);
    },
  );

  test('missing version or help and malformed journal never create facts', () {
    expect(
      Act0ArchivedAttemptV1.fromRecordedDecision(_evidence(1, revision: '')),
      isNull,
    );
    expect(
      Act0ArchivedAttemptV1.fromRecordedDecision(
        _evidence(1, assistance: Act0DecisionAssistanceV1.legacyUnknown),
      ),
      isNull,
    );
    expect(Act0AttemptArchiveV1.restore('corrupt').attempts, isEmpty);
    final corrupt = _attempt(1).toPayload()
      ..['events'] = [
        {'kind': 'unknown', 'label': 'made up'},
      ];
    final restored = Act0AttemptArchiveV1.restore({
      'format': 1,
      'entries': [corrupt, _attempt(2).toPayload()],
      'selectedId': 'attempt-1',
    });
    expect(restored.attempts.map((attempt) => attempt.id), ['attempt-2']);
    expect(restored.selected, isNull);
  });

  test('replay advances, pauses, resets and exposes saved text in order', () {
    final start = Act0AttemptReplayV1(_attempt(1));
    expect(start.current, isNull);
    expect(start.back().position, 0);
    final first = start.play().tick();
    expect(first.current?.learnerLabel, 'CO bets 2 BB');
    expect(first.isPlaying, isTrue);
    expect(first.pause().tick().position, 1);
    final end = first.forward();
    expect(end.textAlternative, ['CO bets 2 BB', 'Action returns to BB']);
    expect(end.current?.isNote, isTrue);
    expect(end.play().isPlaying, isFalse);
    expect(end.forward(), same(end));
    expect(end.back().position, 1);
    expect(end.reset().textAlternative, isEmpty);
    final noJournal = Act0AttemptReplayV1(
      Act0ArchivedAttemptV1.fromRecordedDecision(_evidence(3))!,
    );
    expect(noJournal.atEnd, isTrue);
    expect(noJournal.play().current, isNull);
  });

  test(
    'confidence does not grant help and a received clue requires assistance',
    () {
      const confidenceOnly = Act0AttemptReflectionV1(
        confidence: Act0DecisionConfidenceV1.unsure,
      );
      expect(
        confidenceOnly.assistanceFor(Act0DecisionAssistanceV1.none),
        Act0DecisionAssistanceV1.none,
      );
      const clue = Act0AttemptReflectionV1(
        openedClue: Act0CausalClueV1.callPrice,
      );
      expect(
        clue.assistanceFor(Act0DecisionAssistanceV1.none),
        Act0DecisionAssistanceV1.quickHint,
      );
      expect(
        Act0ArchivedAttemptV1.fromRecordedDecision(
          _evidence(1, assistance: Act0DecisionAssistanceV1.none),
          reflection: clue,
        ),
        isNull,
      );
      expect(
        clue.openedClue?.text,
        'Compare the chips you still owe with the pot after your call.',
      );
    },
  );

  test(
    'swapping the correct choice leaves the optional reflection independent',
    () {
      const reflection = Act0AttemptReflectionV1(
        confidence: Act0DecisionConfidenceV1.verySure,
        openedClue: Act0CausalClueV1.callPrice,
      );
      final attempts = [
        for (final callIsCorrect in [false, true])
          Act0ArchivedAttemptV1.fromRecordedDecision(
            _evidence(1, callIsCorrect: callIsCorrect),
            reflection: reflection,
          )!,
      ].map((attempt) => Act0ArchivedAttemptV1.tryParse(attempt.toPayload())!);
      expect(attempts.map((attempt) => attempt.evidence.expectedChoiceId), [
        'fold',
        'call',
      ]);
      expect(attempts.map((attempt) => attempt.evidence.isCorrect), [
        false,
        true,
      ]);
      expect(
        attempts.map((attempt) => attempt.evidence.assistanceKind),
        everyElement(Act0DecisionAssistanceV1.quickHint),
      );
      expect(
        attempts.map((attempt) => attempt.reflection.confidence),
        everyElement(Act0DecisionConfidenceV1.verySure),
      );
      expect(
        attempts.map((attempt) => attempt.reflection.openedClue!.text),
        everyElement(Act0CausalClueV1.callPrice.text),
      );
    },
  );
}
