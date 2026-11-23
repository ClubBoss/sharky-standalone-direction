import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_replay_table_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_view_model_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_replay_screen_v1.dart';
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

Act0ArchivedAttemptV1 _verifiedAttempt({bool tampered = false}) {
  final lesson = Act0ShellStateV1.sample.worlds
      .singleWhere((world) => world.worldId == 'world_4')
      .lessons
      .singleWhere((lesson) => lesson.lessonId == 'call_price');
  final task = lesson.taskList.singleWhere((task) => task.taskId == _task);
  final table = task.runner.table;
  final revision = act0AuthoredSourceFingerprintV1(
    worldId: 'world_4',
    lessonId: 'call_price',
    task: task,
  )!;
  return Act0ArchivedAttemptV1.fromRecordedDecision(
    _evidence(1, revision: revision, callIsCorrect: true),
    tableFingerprint: act0ReplayTableFingerprintV1(table),
    recordedTrail: [
      if (tampered) const Act0ActionTrailItemV1(label: 'BTN bets 500 BB'),
      ...table.actionTrail,
      const Act0ActionTrailItemV1.note(label: 'Your choice: Call'),
    ],
  )!;
}

void main() {
  test('archive view searches labels and IDs and preserves return targets', () {
    final view = Act0AttemptArchiveViewModelV1();
    final attempt = _attempt(1);
    final archive = const Act0AttemptArchiveV1.empty().add(attempt);
    expect(view.visibleAttempts(const Act0AttemptArchiveV1.empty()), isEmpty);
    expect(view.visibleAttempts(archive), [attempt]);
    for (final query in ['  PRICE ', ' Call ', _task, 'unmatched']) {
      view.query = query;
      expect(
        view.visibleAttempts(archive),
        query == 'unmatched' ? [] : [attempt],
      );
    }
    view.replayingAttempt = attempt;
    expect(view.atArchiveRoot, isFalse);
    view.backToParent();
    expect(view.atArchiveRoot, isTrue);
    expect(view.query, 'unmatched');

    view.showOwnHands = true;
    final hand = archive
        .importPokerStars(
          File(
            'test/fixtures/hand_history/pokerstars_nlhe_usd_fold.txt',
          ).readAsStringSync(),
        )
        .importedHands
        .single;
    view.replayingHand = hand;
    view.backToParent();
    expect(view.replayingHand, isNull);
    expect(view.showOwnHands, isTrue);
    view.backToParent();
    expect(view.atArchiveRoot, isTrue);
  });

  test(
    'hidden learner input survives linked and inline storage without grading changes',
    () {
      final attempt = _attempt(1);
      final archive = const Act0AttemptArchiveV1.empty()
          .add(attempt)
          .select(attempt.id);
      final input = Act0LearnerReflectionInputV1(
        confidence: Act0DecisionConfidenceV1.unsure,
        mistakeReason: '  I misread the price. ',
      );
      final updated = archive.withLearnerInput(attempt.id, input);
      for (final records in [
        <Act0LearningEvidenceRecordV1>[],
        [attempt.evidence],
      ]) {
        final restored = Act0AttemptArchiveV1.restore(
          jsonDecode(jsonEncode(updated.toPayload(snapshotRecords: records))),
          snapshotRecords: records,
        ).selected!;
        expect(restored.learnerInput?.mistakeReason, 'I misread the price.');
        expect(
          restored.learnerInput?.confidence,
          Act0DecisionConfidenceV1.unsure,
        );
        expect(restored.evidence.toPayload(), attempt.evidence.toPayload());
        expect(restored.reflection.confidence, attempt.reflection.confidence);
        expect(restored.reflection.openedClue, attempt.reflection.openedClue);
        expect(
          restored.events.map((event) => event.label),
          _trail.map((event) => event.label),
        );
      }
      expect(archive.selected!.learnerInput, isNull);
      expect(
        updated.withLearnerInput(attempt.id, null).selected!.learnerInput,
        isNull,
      );
      expect(updated.withLearnerInput('missing', input), same(updated));
    },
  );

  test(
    'legacy saves and malformed optional input retain archived evidence',
    () {
      final attempt = _attempt(1);
      final old = attempt.toPayload();
      expect(Act0ArchivedAttemptV1.tryParse(old)!.learnerInput, isNull);
      old['learnerInput'] = {'confidence': 'future', 'mistakeReason': 4};
      final restored = Act0ArchivedAttemptV1.tryParse(old)!;
      expect(restored.learnerInput, isNull);
      expect(restored.evidence.toPayload(), attempt.evidence.toPayload());
    },
  );

  test(
    'winner swap preserves source grade and confidence and only keeps a reason for the mistake',
    () {
      final input = Act0LearnerReflectionInputV1(
        confidence: Act0DecisionConfidenceV1.somewhatSure,
        mistakeReason: 'My explanation.',
      );
      for (final correct in [false, true]) {
        final evidence = _evidence(1, callIsCorrect: correct);
        final archived = Act0ArchivedAttemptV1.fromRecordedDecision(
          evidence,
          learnerInput: input,
        )!;
        expect(archived.evidence, same(evidence));
        expect(archived.learnerInput!.confidence, input.confidence);
        expect(
          archived.learnerInput!.mistakeReason,
          correct ? null : input.mistakeReason,
        );
        expect(
          archived.learnerInput!.toPayload().keys,
          correct ? ['confidence'] : ['confidence', 'mistakeReason'],
        );
      }
    },
  );

  testWidgets(
    'archive still shows historical confidence and hides learner input',
    (tester) async {
      final attempt = _attempt(1);
      final archive = const Act0AttemptArchiveV1.empty()
          .add(attempt)
          .select(attempt.id)
          .withLearnerInput(
            attempt.id,
            Act0LearnerReflectionInputV1(
              confidence: Act0DecisionConfidenceV1.unsure,
              mistakeReason: 'I misread the price.',
            ),
          );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0AttemptArchiveScreenV1(
              archive: archive,
              onClose: () {},
              onSelect: (_) {},
              onRemove: (_) {},
              onOwnHandsChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Confidence: very sure'), findsOneWidget);
      expect(find.text('Confidence: unsure'), findsNothing);
      expect(find.text('I misread the price.'), findsNothing);
    },
  );

  group('Review replay', () {
    Future<void> mount(
      WidgetTester tester,
      Act0ArchivedAttemptV1 attempt, {
      bool reduceMotion = false,
    }) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
          home: Scaffold(
            body: Act0AttemptReplayScreenV1(attempt: attempt, onClose: () {}),
          ),
        ),
      );
    }

    testWidgets(
      'reads only revealed journal steps and moves back and forward',
      (tester) async {
        await mount(tester, _attempt(1));
        final previous = find.byKey(const Key('act0_attempt_replay_previous'));
        final next = find.byKey(const Key('act0_attempt_replay_next'));

        expect(find.text('Step 0 of 2'), findsOneWidget);
        expect(tester.widget<TextButton>(previous).onPressed, isNull);
        expect(find.text('CO bets 2 BB'), findsNothing);

        await tester.tap(next);
        await tester.pump();
        expect(find.text('Step 1 of 2'), findsOneWidget);
        expect(find.text('CO bets 2 BB'), findsOneWidget);
        expect(find.text('Action returns to BB'), findsNothing);

        await tester.tap(next);
        await tester.pump();
        expect(find.text('Step 2 of 2'), findsOneWidget);
        expect(find.text('Action returns to BB'), findsOneWidget);
        expect(tester.widget<TextButton>(next).onPressed, isNull);
        await tester.tap(find.text('Earlier steps'));
        await tester.pumpAndSettle();
        expect(find.text('CO bets 2 BB'), findsOneWidget);

        await tester.tap(previous);
        await tester.pumpAndSettle();
        expect(find.text('Step 1 of 2'), findsOneWidget);
        expect(find.text('CO bets 2 BB'), findsOneWidget);
        expect(find.text('Action returns to BB'), findsNothing);
      },
    );

    testWidgets('pauses playback and resets to the start', (tester) async {
      await mount(tester, _attempt(1));
      await tester.tap(find.text('Play'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Step 1 of 2'), findsOneWidget);
      await tester.tap(find.text('Pause'));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Step 1 of 2'), findsOneWidget);
      await tester.tap(find.text('Play'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('Step 0 of 2'), findsOneWidget);
      expect(find.text('CO bets 2 BB'), findsNothing);
    });

    for (final reduceMotion in [false, true]) {
      testWidgets(
        'replays saved table commitments (Reduce Motion $reduceMotion)',
        (tester) async {
          final attempt = _verifiedAttempt();
          await mount(tester, attempt, reduceMotion: reduceMotion);
          expect(find.byType(Act0TableSceneV1), findsNothing);
          await tester.tap(find.text('Play'));
          final projection = Act0AttemptReplayTableV1.fromAttempt(attempt)!;
          final firstCommitment =
              Iterable<int>.generate(
                attempt.events.length,
                (i) => i + 1,
              ).firstWhere(
                (position) =>
                    projection.atPosition(position)?.newCommitment ?? false,
              );
          await tester.pump(Duration(seconds: firstCommitment));
          final scene = tester.widget<Act0TableSceneV1>(
            find.byType(Act0TableSceneV1),
          );
          expect(
            scene.table.activeSeatId,
            projection.atPosition(firstCommitment)!.table.activeSeatId,
          );
          final motion = find.byWidgetPredicate(
            (widget) =>
                widget.key.toString().contains('act0_shell_bet_chip_motion_'),
          );
          expect(motion, reduceMotion ? findsNothing : findsOneWidget);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          await tester.pump(const Duration(seconds: 2));
          expect(
            find.text('Step $firstCommitment of ${attempt.events.length}'),
            findsOneWidget,
          );
          expect(find.text('Play'), findsOneWidget);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        },
      );
    }

    testWidgets('shows the missing journal for a migrated attempt', (
      tester,
    ) async {
      final attempt = Act0ArchivedAttemptV1.fromRecordedDecision(_evidence(1))!;
      await mount(tester, attempt);
      expect(
        find.text('No event history was saved for this attempt.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_attempt_replay_next')), findsNothing);
    });
  });

  test(
    'table replay requires matching capture and journal without future cards',
    () {
      final attempt = _verifiedAttempt();
      final restored = Act0ArchivedAttemptV1.tryParse(attempt.toPayload())!;
      final projection = Act0AttemptReplayTableV1.fromAttempt(restored)!;
      expect(projection.atPosition(0), isNull);
      final frames = [
        for (var position = 1; position <= attempt.events.length; position++)
          if (projection.atPosition(position) case final frame?) frame.table,
      ];
      expect(frames.first.boardCards, hasLength(0));
      expect(frames.last.boardCards, hasLength(4));
      expect(
        Act0AttemptReplayTableV1.fromAttempt(_verifiedAttempt(tampered: true)),
        isNull,
      );
      expect(Act0AttemptReplayTableV1.fromAttempt(_attempt(1)), isNull);
    },
  );

  test('W4 replay restores the saved decision and steps back to the bet', () {
    final attempt = _verifiedAttempt();
    final projection = Act0AttemptReplayTableV1.fromAttempt(attempt)!;
    var replay = Act0AttemptReplayV1(attempt);
    while (replay.position < attempt.events.length - 1) {
      replay = replay.forward();
    }
    final choice = replay.forward();
    final decision = projection.atPosition(choice.position)!;
    expect(decision.table.activeSeatId, decision.table.heroSeatId);
    expect(decision.table.potLabel, 'Pot 10 BB');
    expect(decision.table.toCallLabel, 'To call 1 BB');
    expect(decision.newCommitment, isFalse);

    final previous = projection.atPosition(choice.back().position)!;
    expect(previous.table.activeSeatId, 'hj');
    expect(previous.table.potLabel, isEmpty);
    expect(previous.table.toCallLabel, isEmpty);
    expect(previous.newCommitment, isTrue);
  });

  test('shares exact evidence and keeps expired records self-contained', () {
    final archive = const Act0AttemptArchiveV1.empty()
        .add(_attempt(1))
        .add(_attempt(2))
        .add(_attempt(3))
        .select('attempt-2');
    final shared = [_evidence(2), _evidence(3, callIsCorrect: true)];
    final payload = archive.toPayload(snapshotRecords: shared);
    final [third, second, first] = (payload['entries'] as List).cast<Map>();
    expect(first['evidence'], isNotNull);
    expect(second['recordId'], 'attempt-2');
    expect(second.containsKey('evidence'), isFalse);
    expect(third['evidence'], isNotNull);
    final restored = Act0AttemptArchiveV1.restore(
      payload,
      snapshotRecords: shared,
    );
    expect(restored.toPayload(), archive.toPayload());
    final missing = Act0AttemptArchiveV1.restore(payload);
    expect(missing.attempts.map((attempt) => attempt.id), [
      'attempt-3',
      'attempt-1',
    ]);
    expect(missing.selected, isNull);
  });

  test('an imported hand persists beside linked graded evidence', () {
    final recorded = _attempt(1);
    final original = const Act0AttemptArchiveV1.empty()
        .add(recorded)
        .select(recorded.id);
    final raw = File(
      'test/fixtures/hand_history/pokerstars_nlhe_usd_fold.txt',
    ).readAsStringSync();
    final archive = original.importPokerStars(raw);
    final shared = [recorded.evidence];
    final payload = archive.toPayload(snapshotRecords: shared);
    expect(
      payload['entries'],
      original.toPayload(snapshotRecords: shared)['entries'],
    );
    final restored = Act0AttemptArchiveV1.restore(
      jsonDecode(jsonEncode(payload)),
      snapshotRecords: shared,
    );
    expect(restored.selected!.evidence, same(recorded.evidence));
    expect(restored.importedHands.single.potCents, 20);
    expect(
      restored.select(null).remove(recorded.id).importedHands,
      hasLength(1),
    );
    expect(
      restored
          .removeImportedHand(restored.importedHands.single.sourceKey)
          .toPayload(),
      original.toPayload(),
    );
  });

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
