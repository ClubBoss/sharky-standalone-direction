// SIMULATED source/Runner consumer controls. No native or Human proof.
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_session_identity_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _world = 'world_3';
const _lesson = 'same_hand_different_seat';
const _taskId = 'same_hand_different_seat_w3_same_hand_recap';
const _oldFingerprint =
    '13dd28c27603ef3aed59e6dc814ca85952a7e61cec6bebfda26ba16c1e643404';

Act0LessonTaskV1 _task() => Act0ShellStateV1.sample
    .worldById(_world)
    .lessons
    .singleWhere((lesson) => lesson.lessonId == _lesson)
    .taskList
    .singleWhere((task) => task.taskId == _taskId);

Act0SkillReceiptV1? _receipt(Act0RunnerStateV1 runner) =>
    act0FirstValueSkillReceiptForRunnerV1(
      runner: runner,
      option: runner.options.first,
      taskFamily: Act0TaskFamilyV1.review,
    );

Act0RunnerOptionV1 _copyChoice(
  Act0RunnerOptionV1 original, {
  String? id,
  String? label,
  String? seatId,
  bool? isCorrect,
  Act0FeedbackQualityV1? quality,
  String? reason,
  String? betterAnswerLabel,
  String? preferredLabel,
  String? feedbackTitle,
  String? amountLabel,
  List<String>? repairFocusSeatIds,
  List<String>? repairFocusCardIds,
  List<String>? repairFocusLabels,
}) => Act0RunnerOptionV1(
  id: id ?? original.id,
  label: label ?? original.label,
  seatId: seatId ?? original.seatId,
  isCorrect: isCorrect ?? original.isCorrect,
  preferredLabel: preferredLabel ?? original.preferredLabel,
  betterAnswerLabel: betterAnswerLabel ?? original.betterAnswerLabel,
  amountLabel: amountLabel ?? original.amountLabel,
  repairFocusSeatIds: repairFocusSeatIds ?? original.repairFocusSeatIds,
  repairFocusCardIds: repairFocusCardIds ?? original.repairFocusCardIds,
  repairFocusLabels: repairFocusLabels ?? original.repairFocusLabels,
  quality: quality ?? original.quality,
  feedbackTitle: feedbackTitle ?? original.feedbackTitle,
  feedbackReason: reason ?? original.feedbackReason,
);

Act0LearningEvidenceRecordV1 _record({
  required String choice,
  required String fingerprint,
  bool isCorrect = true,
  bool old = false,
}) => Act0LearningEvidenceRecordV1(
  recordId: old ? 'old-seat-receipt' : 'current-context-receipt',
  createdOrder: old ? 1 : 2,
  worldId: _world,
  lessonId: _lesson,
  taskId: _taskId,
  sourceTaskId: _taskId,
  choiceId: choice,
  expectedChoiceId: old ? 'btn' : 'framework',
  isCorrect: isCorrect,
  errorType: isCorrect ? 'none' : 'misread_position_action_order',
  conceptFamilyId: old ? 'hero_button' : 'position_action_order',
  repairFocusId: old ? 'hero_button' : 'position_action_order',
  skillAtomId: old ? 'table_position_read' : 'position_action_order',
  decisionTimeBucket: '3_to_10s',
  resultKind: isCorrect ? 'correct' : 'incorrect',
  runId: old ? 'old-run' : 'context-run',
  runKind: 'lesson',
  sessionId: old ? 'old-session' : 'context-session',
  recordedAtUtc: DateTime.utc(2026, 11, 16, old ? 8 : 9),
  assistanceKind: Act0DecisionAssistanceV1.none,
  authoredSourceFingerprint: fingerprint,
);

void main() {
  test(
    'active recap retains context goal and versioned contextual choices',
    () {
      final task = _task();
      expect(task.phase, Act0LessonPhaseV1.review);
      expect(task.entryPhase, Act0LessonPhaseV1.drill);
      expect(task.stepKind, Act0LessonStepKindV1.review);
      expect(task.resolvedTaskFamily, Act0TaskFamilyV1.review);
      expect(task.rewardXp, 12);
      expect(
        task.runner.question,
        'What prevents one-hand-one-answer thinking?',
      );
      expect(task.runner.teachingSteps.single.title, 'Frame checklist.');
      expect(
        task.runner.teachingSteps.single.body,
        'Ask if the pot is unopened or if a raise already happened.',
      );
      expect(task.runner.options.map((option) => option.id), <String>[
        'one_answer',
        'framework',
      ]);
      expect(
        task.runner.options.singleWhere((option) => option.isCorrect).id,
        'framework',
      );
      expect(task.runner.table.selectableSeatIds, isEmpty);
      final normalized = normalizeAct0SeatTapRunnerV1(task.runner);
      expect(normalized.options, hasLength(2));
      expect(normalized.table.selectableSeatIds, isEmpty);
      expect(
        normalized.options.every((option) => option.seatId == null),
        isTrue,
      );
      // The recap override must not clear the ancestor or real seat tasks.
      const seatControls = <String, List<String>>{
        'same_hand_different_seat_w3_same_hand_intro': <String>['btn', 'utg'],
        'button_advantage_find_button': <String>['btn', 'co'],
      };
      for (final entry in seatControls.entries) {
        final control = Act0ShellStateV1.sample.worlds
            .expand((world) => world.lessons)
            .expand((lesson) => lesson.taskList)
            .singleWhere((task) => task.taskId == entry.key);
        expect(
          control.runner.table.selectableSeatIds,
          entry.value,
          reason: 'Keep the source-owned seat controls: ${entry.key}',
        );
        final normalizedControl = normalizeAct0SeatTapRunnerV1(control.runner);
        expect(normalizedControl.table.selectableSeatIds, hasLength(6));
        expect(
          normalizedControl.table.selectableSeatIds,
          containsAll(entry.value),
        );
      }
      for (final option in normalized.options) {
        final receipt = act0FirstValueSkillReceiptForRunnerV1(
          runner: normalized,
          option: option,
          taskFamily: task.resolvedTaskFamily,
        );
        expect(receipt, isNotNull);
        expect(receipt!.skillAtomId, 'position_action_order');
        expect(receipt.sourceSignalId, 'position_action_order');
        expect(receipt.sourceSignalLabel, 'Bucket, seat, frame');
        expect(receipt.nextRepId, 'repeat_position_action_order');
      }
    },
  );

  test(
    'context source rejects stale identity, question, options and metadata',
    () {
      final runner = _task().runner;
      final first = runner.options.first;
      final last = runner.options.last;
      final invalid = <Act0RunnerStateV1>[
        runner.copyWith(lessonId: 'position_apply'),
        runner.copyWith(question: 'Which seat acts last after the flop?'),
        runner.copyWith(phase: Act0LessonPhaseV1.theory),
        runner.copyWith(options: <Act0RunnerOptionV1>[first]),
        runner.copyWith(options: <Act0RunnerOptionV1>[first, first]),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            _copyChoice(first, id: 'btn'),
            last,
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            _copyChoice(first, seatId: 'utg'),
            last,
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            _copyChoice(
              first,
              isCorrect: true,
              quality: Act0FeedbackQualityV1.correct,
            ),
            last,
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            first,
            _copyChoice(last, reason: 'Forged source rationale.'),
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            first,
            _copyChoice(last, label: 'BTN'),
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            _copyChoice(first, betterAnswerLabel: 'BTN'),
            last,
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            _copyChoice(first, amountLabel: '3 BB'),
            last,
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            _copyChoice(first, repairFocusSeatIds: <String>['btn']),
            last,
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            _copyChoice(first, repairFocusCardIds: <String>['hero_0']),
            last,
          ],
        ),
        runner.copyWith(
          options: <Act0RunnerOptionV1>[
            _copyChoice(first, repairFocusLabels: <String>['BTN']),
            last,
          ],
        ),
        runner.copyWith(feedbackSignalId: ''),
        runner.copyWith(
          feedbackSignalId: 'unknown_context_revision',
          table: runner.table.copyWith(toCallLabel: 'To call 99 BB'),
        ),
      ];
      for (final candidate in invalid) {
        expect(_receipt(candidate), isNull);
      }
      expect(
        act0FirstValueSkillReceiptForRunnerV1(
          runner: runner,
          option: first,
          taskFamily: Act0TaskFamilyV1.decision,
        ),
        isNull,
      );
      expect(
        _receipt(runner.copyWith(options: runner.options.reversed.toList())),
        isNotNull,
        reason: 'Answer order is presentation; source IDs own meaning.',
      );
      final withUnrelatedPrice = _receipt(
        runner.copyWith(
          table: runner.table.copyWith(toCallLabel: 'To call 99 BB'),
        ),
      );
      expect(withUnrelatedPrice?.sourceSignalId, 'position_action_order');
      expect(withUnrelatedPrice?.skillAtomId, isNot('price_read'));
    },
  );

  test('context proof rejects detached old and forged selected choices', () {
    final task = _task();
    final wrong = task.runner.options.singleWhere(
      (option) => !option.isCorrect,
    );
    final correct = task.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    for (final option in <Act0RunnerOptionV1>[
      _copyChoice(wrong, id: 'btn'),
      _copyChoice(wrong, id: ''),
      _copyChoice(wrong, id: 'unknown_choice'),
      _copyChoice(wrong, quality: Act0FeedbackQualityV1.correct),
      _copyChoice(wrong, isCorrect: true),
      _copyChoice(wrong, label: 'BTN'),
      _copyChoice(wrong, reason: 'Forged source rationale.'),
      _copyChoice(wrong, preferredLabel: 'BTN'),
      _copyChoice(wrong, betterAnswerLabel: 'BTN'),
      _copyChoice(wrong, feedbackTitle: 'Forged title'),
      _copyChoice(wrong, seatId: 'btn'),
      _copyChoice(wrong, amountLabel: '3 BB'),
      _copyChoice(wrong, repairFocusSeatIds: <String>['btn']),
      _copyChoice(wrong, repairFocusCardIds: <String>['hero_0']),
      _copyChoice(wrong, repairFocusLabels: <String>['BTN']),
    ]) {
      expect(
        act0FirstValueSkillReceiptForRunnerV1(
          runner: task.runner,
          option: option,
          taskFamily: task.resolvedTaskFamily,
        ),
        isNull,
      );
    }
    for (final option in <Act0RunnerOptionV1>[wrong, correct]) {
      final receipt = act0FirstValueSkillReceiptForRunnerV1(
        runner: task.runner,
        option: option,
        taskFamily: task.resolvedTaskFamily,
      );
      expect(
        receipt?.outcome,
        option.isCorrect
            ? Act0SkillReceiptOutcomeV1.learned
            : Act0SkillReceiptOutcomeV1.repairStarted,
      );
    }
  });

  test('existing explicit conceptual mapping retains its current meaning', () {
    final task = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .singleWhere((task) => task.taskId == 'w6_turn_shift_bucket');
    final receipt = act0FirstValueSkillReceiptForRunnerV1(
      runner: task.runner,
      option: task.runner.options.singleWhere((option) => option.isCorrect),
      taskFamily: task.resolvedTaskFamily,
    );
    expect(receipt?.sourceSignalId, 'range_bucket_shift');
    expect(receipt?.skillAtomId, 'range_bucket_reasoning');
  });

  test(
    'new context source regrades current choices and retains old history',
    () {
      final task = _task();
      final fingerprint = act0AuthoredSourceFingerprintV1(
        worldId: _world,
        lessonId: _lesson,
        task: task,
      )!;
      expect(fingerprint, isNot(_oldFingerprint));
      final old = _record(
        choice: 'btn',
        fingerprint: _oldFingerprint,
        old: true,
      );
      final oldBytes = jsonEncode(old.toPayload());
      final current = _record(choice: 'framework', fingerprint: fingerprint);
      final history = Act0LearningEvidenceHistoryV1(
        records: [old],
      ).append(current).append(current);
      final restored = Act0LearningEvidenceHistoryV1.tryParse(
        jsonDecode(history.toStorageString()),
      )!;
      expect(restored.records, hasLength(2));
      expect(jsonEncode(restored.records.first.toPayload()), oldBytes);
      expect(act0CurrentAuthoredSourceProofV1(restored.records.first), isNull);
      final proof = act0CurrentAuthoredSourceProofV1(restored.records.last);
      expect(proof, isNotNull);
      expect(proof!.isCurrentlyCorrect, isTrue);
      expect(proof.skillAtomId, 'position_action_order');
      expect(proof.conceptFamilyId, 'position_action_order');
      // Stored grade is historical fact, not authority for the current answer.
      final forgedCorrect = _record(
        choice: 'one_answer',
        fingerprint: fingerprint,
      );
      expect(
        act0CurrentAuthoredSourceProofV1(forgedCorrect)?.isCurrentlyCorrect,
        isFalse,
      );
      expect(forgedCorrect.isCorrect, isTrue);
      expect(
        act0CurrentAuthoredSourceProofV1(
          _record(choice: 'btn', fingerprint: fingerprint),
        ),
        isNull,
      );
    },
  );

  test('context misconception has explicit honest same-source repair', () {
    final task = _task();
    final wrong = task.runner.options.singleWhere(
      (option) => !option.isCorrect,
    );
    final intent = buildAct0RepairIntentV1(
      sourceWorldId: _world,
      sourceLessonId: _lesson,
      sourceTaskId: _taskId,
      runner: task.runner,
      selectedOption: wrong,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    );
    expect(intent, isNotNull);
    expect(intent!.choiceId, 'one_answer');
    expect(intent.errorType, 'misread_position_action_order');
    expect(intent.skillAtomId, 'position_action_order');
    expect(intent.missedSignalId, 'position_action_order');
    expect(intent.mappingType, 'intentional_exact');
    expect(intent.targetWorldId, _world);
    expect(intent.targetLessonId, _lesson);
    expect(intent.targetTaskId, _taskId);
    expect(task.resolvedTaskFamily, Act0TaskFamilyV1.review);
    for (final identity in <(String, String, String)>[
      ('world_2', _lesson, _taskId),
      (_world, 'position_apply', _taskId),
      (_world, _lesson, 'same_hand_different_seat_same_hand_late_open'),
    ]) {
      final forged = buildAct0RepairIntentV1(
        sourceWorldId: identity.$1,
        sourceLessonId: identity.$2,
        sourceTaskId: identity.$3,
        runner: task.runner,
        selectedOption: wrong,
      );
      expect(forged?.missedSignalId, isNot('position_action_order'));
    }
    final disposition = act0RepairGapAdjudicationForSourceTaskV1(_taskId)!;
    expect(disposition.outcome, Act0RepairGapOutcomeV1.intentionalExactReplay);
    expect(disposition.requiresFutureKnowledge, isFalse);
  });

  testWidgets(
    'SIMULATED normal AppRoot context repair, familiar replay and saved remount',
    (tester) async {
      // testWidgets owns enabled semantics and its teardown.
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      final priorPlatform = SharedPreferencesStorePlatform.instance;
      final sample = Act0ShellStateV1.sample;
      final world = sample.worldById(_world);
      final lesson = world.lessons.singleWhere(
        (item) => item.lessonId == _lesson,
      );
      // Explicit prerequisite-skipped fixture, NOT earned learning progress.
      // This only makes W3/the recap normally available; no production unlock,
      // route, private shell state or assessed answer is injected.
      final fixtureSkips = <String>{
        for (final earlier in sample.worlds.takeWhile(
          (item) => item.worldId != _world,
        ))
          for (final priorLesson in earlier.lessons)
            for (final task in priorLesson.taskList) task.taskId,
        for (final priorLesson in world.lessons.takeWhile(
          (item) => item.lessonId != _lesson,
        ))
          for (final task in priorLesson.taskList) task.taskId,
        for (final task in lesson.taskList.takeWhile(
          (item) => item.taskId != _taskId,
        ))
          task.taskId,
      };
      expect(fixtureSkips, isNotEmpty);
      expect(fixtureSkips, isNot(contains(_taskId)));
      const emptyHistory = Act0LearningEvidenceHistoryV1();
      final disk = _W24Disk(<String, Object>{
        'app_language_code': 'en',
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        _w24ProgressKey: jsonEncode(<String, Object?>{
          'schemaVersion': 20,
          'completedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'skippedTaskIds': fixtureSkips.toList()..sort(),
          'selectedWorldId': _world,
          'selectedLessonId': _lesson,
          'selectedTaskId': _taskId,
          'earnedXp': 0,
          'pendingDecisionAssistance': <Object?>[],
          'learningEvidenceHistory': emptyHistory.toPayload(),
          'learningEvidenceLineage': emptyHistory.lineagePayload(),
          'sessionIdentityState': const Act0SessionIdentityStateV1()
              .toPayload(),
        }),
      });
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = disk;
      addTearDown(() async {
        try {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            await _w24PendingWrites().flush().timeout(
              const Duration(seconds: 2),
            );
          });
        } finally {
          SharedPreferences.resetStatic();
          SharedPreferencesStorePlatform.instance = priorPlatform;
        }
      });
      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_academy_home_leaf_cta')),
        findsOneWidget,
      );
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await _w24Tap(tester, 'act0_shell_current_mission_cta');
      // Legacy restore and ordinary Learn launch are read-only. The first
      // required durable boundary below is the actual completed decision.
      await _w24Ready(tester);
      _w24ExpectContextButtons(tester);
      final currentFingerprint = act0AuthoredSourceFingerprintV1(
        worldId: _world,
        lessonId: _lesson,
        task: _task(),
      )!;
      expect(currentFingerprint, isNot(_oldFingerprint));
      await _w24Tap(tester, 'act0_shell_option_one_answer');
      expect(
        _w24Runner(tester).runner.reviewQuality,
        Act0FeedbackQualityV1.wrong,
      );
      expect(
        _w24Runner(tester).runner.reviewReason,
        'One hand can change action when position or action frame changes.',
      );
      final missed = await _w24Saved(tester, disk);
      expect(missed['earnedXp'], 0);
      expect(missed['completedTaskIds'], isEmpty);
      expect(missed['completedLessonIds'], isEmpty);
      expect(
        (missed['skippedTaskIds'] as List).cast<String>().toSet(),
        fixtureSkips,
      );
      final miss = _w24TargetRecords(missed).single;
      final missBytes = jsonEncode(miss.toPayload());
      expect(miss.choiceId, 'one_answer');
      expect(miss.expectedChoiceId, 'framework');
      expect(miss.isCorrect, isFalse);
      expect(miss.errorType, 'misread_position_action_order');
      expect(miss.runKind, 'lesson');
      expect(miss.assistanceKind, Act0DecisionAssistanceV1.none);
      _w24ExpectCurrentEvidence(missed, currentFingerprint, count: 1);
      _w24ExpectSameTargetDebt(missed);
      // Use the ordinary wrong-feedback CTA; same task ID is intentional,
      // and the repair reason distinguishes this from an ordinary replay.
      await _w24Tap(tester, 'act0_shell_feedback_continue_cta');
      expect(_w24Runner(tester).selectedTaskId, _taskId);
      expect(_w24Runner(tester).repairReasonLine, isNotEmpty);
      expect(
        _w24Runner(tester).selectedTaskId,
        isNot('position_checkpoint_position_checkpoint_table_notice'),
      );
      await _w24Tap(tester, 'act0_shell_runner_back');
      final savedDebt = await _w24Saved(tester, disk);
      _w24ExpectSameTargetDebt(savedDebt);
      final restoredDebt = await _w24Remount(tester, disk);
      expect(_w24LearningTruth(restoredDebt), _w24LearningTruth(savedDebt));
      _w24ExpectSameTargetDebt(restoredDebt);
      expect(
        jsonEncode(_w24TargetRecords(restoredDebt).single.toPayload()),
        missBytes,
      );
      // Home resumes the real persisted same-target debt, with no fixture
      // reseed and no private state restoration supplied by the test.
      await _w24Tap(tester, 'act0_academy_home_leaf_cta');
      expect(_w24Runner(tester).selectedTaskId, _taskId);
      expect(_w24Runner(tester).repairReasonLine, isNotEmpty);
      await _w24Ready(tester);
      _w24ExpectContextButtons(tester);
      await _w24Tap(tester, 'act0_shell_option_framework');
      expect(
        _w24Runner(tester).runner.reviewQuality,
        Act0FeedbackQualityV1.correct,
      );
      expect(_w24Runner(tester).repairResultReceiptLine, isNotEmpty);
      final correctedBeforeAck = await _w24Saved(tester, disk);
      expect(correctedBeforeAck['earnedXp'], 0);
      final repairRecord = _w24TargetRecords(correctedBeforeAck).last;
      expect(repairRecord.choiceId, 'framework');
      expect(repairRecord.expectedChoiceId, 'framework');
      expect(repairRecord.isCorrect, isTrue);
      expect(repairRecord.errorType, 'none');
      expect(repairRecord.runKind, 'repair');
      expect(repairRecord.assistanceKind, Act0DecisionAssistanceV1.none);
      _w24ExpectCurrentEvidence(
        correctedBeforeAck,
        currentFingerprint,
        count: 2,
      );
      await _w24Tap(tester, 'act0_shell_feedback_continue_cta');
      final closed = await _w24Saved(tester, disk);
      _w24ExpectNoTargetDebt(closed);
      expect(closed['earnedXp'], _task().rewardXp);
      expect((closed['completedTaskIds'] as List).cast<String>(), <String>[
        _taskId,
      ]);
      expect(
        closed['completedLessonIds'],
        isEmpty,
        reason: 'Skipped prerequisites do not become earned lesson completion.',
      );
      expect(
        (closed['skippedTaskIds'] as List).cast<String>().toSet(),
        fixtureSkips,
      );
      expect(
        jsonEncode(_w24TargetRecords(closed).first.toPayload()),
        missBytes,
      );
      final restoredClosed = await _w24Remount(tester, disk);
      expect(_w24LearningTruth(restoredClosed), _w24LearningTruth(closed));
      _w24ExpectNoTargetDebt(restoredClosed);
      // Authored phase remains review. Existing Preview only auto-starts a
      // formal inline runKind=recheck for authored drills. This is an ordinary
      // familiar current-source replay through Learn, never unseen/elapsed proof.
      await _w24OpenFamiliarReplay(tester, lesson);
      await _w24Ready(tester);
      _w24ExpectContextButtons(tester);
      await _w24Tap(tester, 'act0_shell_option_framework');
      expect(
        _w24Runner(tester).runner.reviewQuality,
        Act0FeedbackQualityV1.correct,
      );
      final replayBeforeAck = await _w24Saved(tester, disk);
      expect(replayBeforeAck['earnedXp'], _task().rewardXp);
      await _w24Tap(tester, 'act0_shell_feedback_continue_cta');
      final replayed = await _w24Saved(tester, disk);
      expect(
        replayed['earnedXp'],
        _task().rewardXp,
        reason: 'A familiar replay cannot award the same task XP twice.',
      );
      expect(replayed['completedTaskIds'], closed['completedTaskIds']);
      expect((replayed['completedTaskIds'] as List).toSet(), hasLength(1));
      expect(
        (replayed['skippedTaskIds'] as List).cast<String>().toSet(),
        fixtureSkips,
      );
      _w24ExpectNoTargetDebt(replayed);
      final records = _w24TargetRecords(replayed);
      expect(records, hasLength(3));
      expect(records.map((record) => record.recordId).toSet(), hasLength(3));
      expect(records.last.choiceId, 'framework');
      expect(records.last.isCorrect, isTrue);
      expect(records.last.runKind, 'lesson');
      expect(records.where((record) => record.runKind == 'recheck'), isEmpty);
      expect(jsonEncode(records.first.toPayload()), missBytes);
      _w24ExpectCurrentEvidence(replayed, currentFingerprint, count: 3);
      // Read-only stale proof controls, never injected into saved history.
      expect(
        act0CurrentAuthoredSourceProofV1(
          _record(choice: 'btn', fingerprint: _oldFingerprint, old: true),
        ),
        isNull,
      );
      final stalePayload = Map<String, Object?>.from(records.last.toPayload())
        ..['authoredSourceFingerprint'] = _oldFingerprint;
      final stale = Act0LearningEvidenceRecordV1.tryParse(stalePayload)!;
      expect(act0CurrentAuthoredSourceProofV1(stale), isNull);
      final remounted = await _w24Remount(tester, disk);
      expect(_w24LearningTruth(remounted), _w24LearningTruth(replayed));
      // Normal launch reads restored memory; ordinary disposal is the actual
      // production save owner. No new answer or debug writer is supplied.
      await _w24OpenFamiliarReplay(tester, lesson);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      final resaved = await _w24Saved(tester, disk);
      expect(_w24LearningTruth(resaved), _w24LearningTruth(replayed));
      _w24ExpectCurrentEvidence(resaved, currentFingerprint, count: 3);
      _w24ExpectNoTargetDebt(resaved);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('SIMULATED stale BTN/UTG flags expose forbidden seat actions', (
    tester,
  ) async {
    // testWidgets owns enabled semantics and its teardown.
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final task = _task();
    final stale = normalizeAct0SeatTapRunnerV1(
      task.runner.copyWith(
        phase: task.entryPhase,
        teachingStepIndex: task.runner.teachingSteps.length,
        table: task.runner.table.copyWith(
          selectableSeatIds: const <String>['btn', 'utg'],
        ),
      ),
    );
    final completed = <Act0CompletedDecisionV1>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: stale,
            selectedWorldId: _world,
            selectedLessonId: _lesson,
            selectedTaskId: _taskId,
            selectedTaskTitle: task.title,
            selectedTaskFamily: task.resolvedTaskFamily,
            compositionFamily: task.resolvedCompositionFamily,
            tablePresentation: task.tablePresentation,
            worldNumber: 3,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onChooseSeat: (_) {},
            onContinueReview: () {},
            onCompletedDecision: completed.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final exposed = <String>{};
    for (final widget in tester.widgetList<Widget>(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_SeatNodeV1',
      ),
    )) {
      final dynamic node = widget;
      if (node.selectable as bool) {
        exposed.add(node.seat.seatId as String);
        expect(node.onTap, isNotNull);
      }
    }
    // These are exactly the source/rendered/AX conditions rejected by the
    // valid context contract above; do not silently ignore the stale actions.
    expect(stale.table.selectableSeatIds, <String>['btn', 'utg']);
    expect(exposed, <String>{'btn', 'utg'});
    for (final id in <String>['btn', 'utg']) {
      expect(find.byKey(Key('act0_shell_seat_tap_$id')), findsOneWidget);
      final seat = stale.table.seats.singleWhere((seat) => seat.seatId == id);
      expect(find.bySemanticsLabel('Select ${seat.seatLabel}'), findsOneWidget);
    }
    expect(completed, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final selected in <String>['framework', 'one_answer']) {
    testWidgets(
      'SIMULATED context $selected uses real option controls and grade',
      (tester) async {
        // testWidgets owns enabled semantics and its teardown.
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final task = _task();
        // Focused decision consumer fixture; this does not claim normal AppRoot
        // traversal or native persistence, which need their separate receipts.
        var runner = normalizeAct0SeatTapRunnerV1(
          task.runner.copyWith(
            phase: task.entryPhase,
            teachingStepIndex: task.runner.teachingSteps.length,
          ),
        );
        final completed = <Act0CompletedDecisionV1>[];
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, update) {
                  return Act0LessonRunnerShellV1(
                    runner: runner,
                    selectedWorldId: _world,
                    selectedLessonId: _lesson,
                    selectedTaskId: _taskId,
                    selectedTaskTitle: task.title,
                    selectedTaskFamily: task.resolvedTaskFamily,
                    compositionFamily: task.resolvedCompositionFamily,
                    tablePresentation: task.tablePresentation,
                    worldNumber: 3,
                    onBack: () {},
                    onContinueTheory: () {},
                    onChooseOption: (option) => update(() {
                      runner = runner.copyWith(
                        selectedOptionId: option.id,
                        phase: Act0LessonPhaseV1.review,
                      );
                    }),
                    onChooseSeat: (_) {},
                    onContinueReview: () {},
                    onCompletedDecision: completed.add,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        _w24ExpectContextButtons(tester);
        expect(completed, isEmpty);
        expect(find.text('Correct answer recorded'), findsNothing);
        await tester.tap(find.byKey(Key('act0_shell_option_$selected')));
        await tester.pumpAndSettle();
        expect(completed, hasLength(1));
        final decision = completed.single;
        expect(decision.decisionKind, Act0CompletedDecisionKindV1.actionList);
        expect(decision.selectedId, selected);
        expect(decision.expectedId, 'framework');
        expect(decision.isCorrect, selected == 'framework');
        expect(
          decision.errorType,
          selected == 'framework' ? 'none' : 'misread_position_action_order',
        );
        expect(decision.skillAtomId, 'position_action_order');
        expect(decision.missedSignalId, 'position_action_order');
        expect(decision.assistanceKind, Act0DecisionAssistanceV1.none);
        expect(decision.taskId, _taskId);
        expect(
          runner.reviewReason,
          contains(
            selected == 'framework'
                ? 'hand bucket, position, and action frame'
                : 'position or action frame changes',
          ),
        );
        expect(
          find
              .byKey(const Key('act0_shell_feedback_continue_cta'))
              .hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

const _w24ProgressKey = 'act0_shell_progress_v1';

// Test-only durable preferences backend. Production AppRoot/ProgressStore own
// every write after this explicit prerequisite-skipped initial fixture.
class _W24Disk extends SharedPreferencesStorePlatform {
  _W24Disk(Map<String, Object> initial)
    : values = <String, Object>{
        for (final entry in initial.entries)
          'flutter.${entry.key}': entry.value,
      };
  final Map<String, Object> values;
  int readCount = 0;
  @override
  Future<Map<String, Object>> getAll() async {
    readCount++;
    return Map<String, Object>.of(values);
  }

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async => throw StateError(
    'This case must never clear/reseed its durable fixture.',
  );
}

Act0ProgressStoreV1 _w24PendingWrites() => Act0ProgressStoreV1(
  key: _w24ProgressKey,
  isValidPayload: (_) =>
      false, // Wait only; cannot replace the production parser.
);

Act0LessonRunnerShellV1 _w24Runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Future<void> _w24Tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _w24Ready(WidgetTester tester) async {
  for (var step = 0; step < 16; step++) {
    final runner = _w24Runner(tester);
    expect(runner.selectedTaskId, _taskId);
    if (runner.runner.activeTeachingStep == null &&
        runner.runner.phase == Act0LessonPhaseV1.drill) {
      expect(runner.runner.selectedOptionId, isNull);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      return;
    }
    await tester.pump(const Duration(milliseconds: 1000));
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    await _w24Tap(
      tester,
      theory.evaluate().isNotEmpty
          ? 'act0_shell_theory_continue_cta'
          : 'act0_shell_continue_cta',
    );
  }
  fail('Ordinary teaching did not reach the context decision.');
}

void _w24ExpectContextButtons(WidgetTester tester) {
  final runner = _w24Runner(tester);
  expect(runner.selectedWorldId, _world);
  expect(runner.selectedLessonId, _lesson);
  expect(runner.selectedTaskId, _taskId);
  expect(runner.runner.question, 'What prevents one-hand-one-answer thinking?');
  expect(runner.runner.options.map((option) => option.id), <String>[
    'one_answer',
    'framework',
  ]);
  expect(
    runner.runner.options.every((option) => option.seatId == null),
    isTrue,
  );
  for (final id in <String>['one_answer', 'framework']) {
    expect(
      find.byKey(Key('act0_shell_option_$id')).hitTestable(),
      findsOneWidget,
    );
  }
  expect(find.byKey(const Key('act0_shell_option_btn')), findsNothing);
  expect(find.byKey(const Key('act0_shell_option_utg')), findsNothing);
  expect(runner.runner.table.selectableSeatIds, isEmpty);
  expect(
    normalizeAct0SeatTapRunnerV1(runner.runner).table.selectableSeatIds,
    isEmpty,
  );
  final nodes = tester
      .widgetList<Widget>(
        find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_SeatNodeV1',
        ),
      )
      .toList();
  expect(
    nodes,
    isNotEmpty,
    reason: 'Inspect real rendered seats, not a vacuous list.',
  );
  final renderedIds = <String>{};
  for (final widget in nodes) {
    final dynamic node = widget;
    renderedIds.add(node.seat.seatId as String);
    expect(node.selectable as bool, isFalse);
    expect(node.onTap, isNull);
  }
  expect(renderedIds, containsAll(<String>['btn', 'utg']));
  for (final seat in runner.runner.table.seats) {
    expect(find.byKey(Key('act0_shell_seat_tap_${seat.seatId}')), findsNothing);
    expect(
      find.bySemanticsLabel('Select ${seat.seatLabel}'),
      findsNothing,
      reason: 'A decorative seat must not advertise a selection action.',
    );
  }
  debugPrint('W24_NO_SEAT_ACTIONS ${runner.selectedTaskId}');
}

Future<Map<String, dynamic>> _w24Saved(
  WidgetTester tester,
  _W24Disk disk,
) async {
  await tester.pumpAndSettle();
  String? payload;
  final readsBefore = disk.readCount;
  await tester.runAsync(() async {
    await Future<void>.value();
    await _w24PendingWrites().flush().timeout(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload().timeout(const Duration(seconds: 2));
    final head = prefs.getString('${_w24ProgressKey}_head');
    expect(head, isNotNull);
    expect(prefs.getString('${_w24ProgressKey}_recovery'), head);
    expect(prefs.getString('${_w24ProgressKey}_backup'), head);
    final envelope = jsonDecode(head!) as Map<String, dynamic>;
    expect(envelope['format'], 1);
    expect(envelope['revision'], greaterThan(0));
    payload = envelope['payload'] as String;
    expect(
      envelope['digest'],
      sha256
          .convert(
            utf8.encode(
              jsonEncode(<Object?>[1, envelope['revision'], payload]),
            ),
          )
          .toString(),
    );
  });
  expect(disk.readCount, greaterThan(readsBefore));
  expect(payload, isNotNull);
  return Map<String, dynamic>.from(jsonDecode(payload!) as Map);
}

Future<Map<String, dynamic>> _w24Remount(
  WidgetTester tester,
  _W24Disk disk,
) async {
  final oldHost = tester.state(find.byType(Act0ShellPreviewScreenV1));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    await _w24PendingWrites().flush().timeout(const Duration(seconds: 2));
  });
  final durableBefore = Map<String, Object>.of(disk.values);
  final readsBefore = disk.readCount;
  // Public cache reset only; same backend and durable map, no setMock/reseed.
  SharedPreferences.resetStatic();
  expect(identical(SharedPreferencesStorePlatform.instance, disk), isTrue);
  expect(disk.values, durableBefore);
  await tester.pumpWidget(const AppRoot());
  await tester.pumpAndSettle();
  expect(disk.readCount, greaterThan(readsBefore));
  expect(
    identical(tester.state(find.byType(Act0ShellPreviewScreenV1)), oldHost),
    isFalse,
  );
  expect(find.byKey(const Key('act0_shell_placement_intro_cta')), findsNothing);
  return _w24Saved(tester, disk);
}

Act0LearningEvidenceHistoryV1 _w24History(Map<String, dynamic> payload) {
  final history = Act0LearningEvidenceHistoryV1.restore(
    payload['learningEvidenceHistory'],
    payload['learningEvidenceLineage'],
  );
  if (history == null) fail('Production history/lineage did not restore.');
  expect(history.hasCompleteLineage, isTrue);
  return history;
}

List<Act0LearningEvidenceRecordV1> _w24TargetRecords(
  Map<String, dynamic> payload,
) => _w24History(
  payload,
).records.where((record) => record.taskId == _taskId).toList();

void _w24ExpectCurrentEvidence(
  Map<String, dynamic> payload,
  String fingerprint, {
  required int count,
}) {
  final history = _w24History(payload);
  final rows = _w24TargetRecords(payload);
  expect(rows, hasLength(count));
  for (final row in rows) {
    expect(row.authoredSourceFingerprint, fingerprint);
    expect(row.authoredSourceFingerprint, isNot(_oldFingerprint));
    expect(row.choiceId, anyOf('one_answer', 'framework'));
    expect(row.runId, isNotEmpty);
    expect(row.sessionId, isNotEmpty);
    final proof = act0CurrentAuthoredSourceProofV1(row);
    expect(proof, isNotNull);
    expect(proof!.conceptFamilyId, 'position_action_order');
    expect(proof.skillAtomId, 'position_action_order');
    expect(proof.isCurrentlyCorrect, row.choiceId == 'framework');
  }
  final deck = act0CompleteCurrentAuthoredEvidenceV1(history);
  expect(
    deck.records
        .where((record) => record.taskId == _taskId)
        .map((record) => record.recordId),
    rows.map((record) => record.recordId),
  );
}

void _w24ExpectSameTargetDebt(Map<String, dynamic> payload) {
  final raw = payload['openRepairIntents'] as List;
  final intents = raw
      .map(Act0RepairIntentV1.tryParse)
      .whereType<Act0RepairIntentV1>()
      .toList();
  expect(intents, hasLength(1));
  final intent = intents.single;
  expect(intent.sourceWorldId, _world);
  expect(intent.sourceLessonId, _lesson);
  expect(intent.sourceTaskId, _taskId);
  expect(intent.targetWorldId, _world);
  expect(intent.targetLessonId, _lesson);
  expect(intent.targetTaskId, _taskId);
  expect(
    intent.targetTaskId,
    isNot('position_checkpoint_position_checkpoint_table_notice'),
  );
  expect(intent.mappingType, 'intentional_exact');
  expect(intent.errorType, 'misread_position_action_order');
  expect(intent.missedSignalId, 'position_action_order');
  expect(intent.skillAtomId, 'position_action_order');
  final queue = Act0MultiRepairQueueV1.tryParse(payload['multiRepairQueue']);
  expect(queue.entries, hasLength(1));
  expect(queue.entries.single.sourceTaskId, _taskId);
  expect(queue.entries.single.repairIntent.toPayload(), intent.toPayload());
}

void _w24ExpectNoTargetDebt(Map<String, dynamic> payload) {
  expect(
    (payload['openRepairIntents'] as List).cast<Map>().where(
      (row) => row['sourceTaskId'] == _taskId,
    ),
    isEmpty,
  );
  expect(
    Act0MultiRepairQueueV1.tryParse(
      payload['multiRepairQueue'],
    ).entries.where((entry) => entry.sourceTaskId == _taskId),
    isEmpty,
  );
}

Map<String, Object?> _w24LearningTruth(Map<String, dynamic> payload) =>
    <String, Object?>{
      for (final key in <String>[
        'earnedXp',
        'completedTaskIds',
        'completedLessonIds',
        'skippedTaskIds',
        'learningEvidenceHistory',
        'learningEvidenceLineage',
        'openRepairIntents',
        'multiRepairQueue',
        'reviewMistakeHistory',
        'reviewResolutionReceipts',
        'repairOutcomeProjection',
      ])
        key: payload[key],
    };

Future<void> _w24OpenFamiliarReplay(
  WidgetTester tester,
  Act0LessonCardV1 lesson,
) async {
  await tester.tap(find.text('Learn').last);
  await tester.pumpAndSettle();
  final all = find.text('All lessons');
  if (all.evaluate().isNotEmpty) {
    await tester.ensureVisible(all.last);
    await tester.tap(all.last);
    await tester.pumpAndSettle();
  }
  await _w24Tap(tester, 'act0_shell_lesson_${lesson.title}');
  await _w24Tap(tester, 'act0_shell_lesson_step_$_taskId');
  await _w24Tap(tester, 'act0_shell_selected_lesson_cta');
  expect(_w24Runner(tester).selectedTaskId, _taskId);
}
