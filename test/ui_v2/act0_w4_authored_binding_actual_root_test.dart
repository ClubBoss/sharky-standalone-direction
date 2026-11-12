// Private actual AppRoot journeys. Prior prerequisites and optional old records
// are explicitly SYNTHETIC seeds, not user history. No callback substitution.
import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_predecision_card_focus_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w4_authored_binding_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';

const _key = 'act0_shell_progress_v1';
Future<void> _settle(WidgetTester t) async {
  await t.pumpAndSettle();
  await Act0ProgressStoreV1(key: _key, isValidPayload: (_) => false).flush();
  await t.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  await _settle(t);
  final p = await SharedPreferences.getInstance();
  await p.reload();
  return jsonDecode(p.getString(_key)!) as Map<String, dynamic>;
}

Future<void> _tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  expect(f, findsOneWidget, reason: key);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await _settle(t);
}

Act0LessonTaskV1 _task(Act0W4AuthoredBindingV1 r) => Act0ShellStateV1.sample
    .worldById(r.world)
    .lessons
    .singleWhere((l) => l.lessonId == r.lesson)
    .taskList
    .singleWhere((t) => t.taskId == r.task);
Act0LessonRunnerShellV1 _runner(WidgetTester t, Act0W4AuthoredBindingV1 r) {
  final w = t.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  expect(w.selectedWorldId, r.world);
  expect(w.selectedLessonId, r.lesson);
  expect(w.selectedTaskId, r.task);
  return w;
}

List<Map<String, dynamic>> _records(Map<String, dynamic> p, String id) =>
    (p['learningEvidenceHistory'] as List)
        .cast<Map<String, dynamic>>()
        .where((r) => r['taskId'] == id)
        .toList();
Future<void> _learn(WidgetTester t) async {
  if (find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty)
    await _tap(t, 'act0_shell_runner_back');
  if (find.byType(Act0LearnPathShellV1).evaluate().isEmpty) {
    final f = find.descendant(
      of: find.byKey(const Key('act0_shell_bottom_nav')),
      matching: find.text('Learn'),
    );
    expect(f, findsOneWidget);
    await t.tap(f);
    await _settle(t);
  }
}

Future<void> _open(
  WidgetTester t,
  Act0W4AuthoredBindingV1 r, {
  bool mission = false,
}) async {
  await _learn(t);
  if (mission) {
    await _tap(t, 'act0_shell_current_mission_cta');
  } else {
    final lesson = Act0ShellStateV1.sample.lessonById(r.lesson);
    final key = 'act0_shell_lesson_${lesson.title}';
    if (find.byKey(Key(key)).evaluate().isEmpty)
      await _tap(t, 'act0_shell_learn_v5_view_full_path');
    await _tap(t, key);
    await _tap(t, 'act0_shell_lesson_step_${r.task}');
    await _tap(t, 'act0_shell_selected_lesson_cta');
  }
  _runner(t, r);
}

Future<void> _mount(
  WidgetTester t,
  Act0W4AuthoredBindingV1 r, {
  bool completed = false,
  Act0LearningEvidenceRecordV1? old,
}) async {
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  final worlds = Act0ShellStateV1.sample.worlds;
  final w = worlds.singleWhere((w) => w.worldId == r.world);
  final l = w.lessons.singleWhere((l) => l.lessonId == r.lesson);
  final prior = [
    for (final world in worlds.takeWhile((v) => v.worldId != r.world))
      ...world.lessons,
    ...w.lessons.takeWhile((v) => v.lessonId != r.lesson),
  ];
  final done = [
    for (final lesson in prior)
      for (final task in lesson.taskList) task.taskId,
    ...l.taskList.takeWhile((v) => v.taskId != r.task).map((t) => t.taskId),
    if (completed) r.task,
  ]..sort();
  final history = Act0LearningEvidenceHistoryV1(
    records: [if (old != null) old],
  );
  SharedPreferences.setMockInitialValues({
    'onboardingCompleted': true,
    'onboarding_complete': true,
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    'app_language_code': 'en',
    _key: jsonEncode({
      'schemaVersion': 18,
      'completedTaskIds': done,
      'completedLessonIds': prior.map((l) => l.lessonId).toList(),
      'skippedTaskIds': [],
      'selectedWorldId': r.world,
      'selectedLessonId': r.lesson,
      'selectedTaskId': r.task,
      'earnedXp': completed ? _task(r).rewardXp : 0,
      'learningEvidenceHistory': history.toPayload(),
      'learningEvidenceLineage': history.lineagePayload(),
      'openRepairIntents': [],
    }),
  });
  addTearDown(() async {
    await t.pumpWidget(const SizedBox.shrink());
    await _settle(t);
  });
  await t.pumpWidget(const AppRoot());
  await _settle(t);
}

Future<void> _answer(
  WidgetTester t,
  Act0W4AuthoredBindingV1 r,
  bool correct, {
  bool advance = false,
}) async {
  for (
    var i = 0;
    i < 8 && find.byKey(const Key('act0_shell_option_call')).evaluate().isEmpty;
    i++
  ) {
    _runner(t, r);
    await t.pump(const Duration(seconds: 1));
    await _tap(t, 'act0_shell_continue_cta');
  }
  // Real AppRoot uses runtime choreography, unlike isolated settled widgets.
  // Advance the existing timers beat-by-beat (owner max duration500ms), never
  // override readiness or call its private completion callbacks.
  final plan = act0TableChoreographyPlanForTableV1(_runner(t, r).runner.table);
  final beatCount = plan?.beats.length ?? 0;
  expect(beatCount, lessThan(80));
  for (var i = 0; i <= beatCount; i++) {
    await t.pump(const Duration(milliseconds: 600));
  }
  await _settle(t);
  final runner = _runner(t, r);
  expect(runner.runner.phase, Act0LessonPhaseV1.drill);
  expect(runner.runner.selectedOptionId, isNull);
  if (act0W4BindingForTaskV1(
        world: r.world,
        lesson: r.lesson,
        task: _task(r),
        runner: runner.runner,
        expectedRouteLessonTitle: Act0ShellStateV1.sample
            .lessonById(r.lesson)
            .title,
      ) ==
      null) {
    final task = _task(r);
    final active = Act0LessonTaskV1(
      taskId: task.taskId,
      title: task.title,
      phase: task.phase,
      runner: runner.runner,
      rewardXp: task.rewardXp,
      stepKind: task.stepKind,
      taskFamily: task.taskFamily,
      tablePresentation: task.tablePresentation,
      summary: task.summary,
      lockedSummary: task.lockedSummary,
    );
    final source = _diagnosticSourcePayload(
      worldId: r.world,
      lessonId: r.lesson,
      task: task,
    );
    final actual = _diagnosticSourcePayload(
      worldId: r.world,
      lessonId: r.lesson,
      task: active,
    );
    void differences(Object? a, Object? b, String path) {
      if (a is List && b is List && a.length == b.length) {
        for (var i = 0; i < a.length; i++) differences(a[i], b[i], '$path/$i');
      } else if (jsonEncode(a) != jsonEncode(b)) {
        debugPrint(
          'W4_ACTIVE_SOURCE_DIFF $path source=${jsonEncode(a)} actual=${jsonEncode(b)}',
        );
      }
    }

    differences(source, actual, 'fingerprint-payload');
  }
  expect(
    act0W4BindingForTaskV1(
      world: r.world,
      lesson: r.lesson,
      task: _task(r),
      runner: runner.runner,
      expectedRouteLessonTitle: Act0ShellStateV1.sample
          .lessonById(r.lesson)
          .title,
    ),
    same(r),
  );
  final text = find.text(_task(r).runner.caption);
  expect(text, findsOneWidget);
  expect(t.widget<Text>(text).maxLines, isNull);
  final scroll = find.byKey(
    const Key('act0_learning_scene_v3_model_support_scroll'),
  );
  expect(scroll, findsOneWidget);
  final state = t.state<ScrollableState>(
    find.descendant(of: scroll, matching: find.byType(Scrollable)),
  );
  for (var i = 0; i < 30 && state.position.extentAfter > .5; i++) {
    await t.drag(scroll, const Offset(0, -80));
    await t.pumpAndSettle();
  }
  expect(state.position.extentAfter, lessThanOrEqualTo(.5));
  expect(
    t.getRect(text).bottom,
    lessThanOrEqualTo(t.getRect(scroll).bottom + 1),
  );
  for (final id in ['call', 'fold']) {
    final f = find.byKey(Key('act0_shell_option_$id'));
    await t.ensureVisible(f);
    expect(f.hitTestable(), findsOneWidget);
  }
  final option = _task(
    r,
  ).runner.options.singleWhere((o) => o.isCorrect == correct);
  await _tap(t, 'act0_shell_option_${option.id}');
  if (_runner(t, r).runner.selectedOptionId == null) {
    final live = _runner(t, r).runner;
    final price = act0BettingPriceForOptionV1(
      live.table,
      option,
      taskId: r.task,
      question: live.question,
    );
    debugPrint(
      'W4_CHOICE_REJECTED beats=$beatCount sourceReady=${price.sourceReady} reason=${price.reason} texts=${t.widgetList<Text>(find.byType(Text)).map((w) => w.data).toList()}',
    );
  }
  expect(_runner(t, r).runner.selectedOptionId, option.id);
  expect(_runner(t, r).runner.phase, Act0LessonPhaseV1.review);
  if (advance) await _tap(t, 'act0_shell_feedback_continue_cta');
}

void _attribution(Map<String, dynamic> record, Act0W4AuthoredBindingV1 r) {
  expect(record['worldId'], r.world);
  expect(record['lessonId'], r.lesson);
  expect(record['taskId'], r.task);
  expect(record['sourceTaskId'], r.task);
  expect(record['authoredSourceFingerprint'], r.fingerprint);
  expect(record['recordId'], isNotEmpty);
  expect(record['recordId'], isNot(r.record));
  expect(record['recordId'], isNot(r.decision));
  expect(record['assistanceKind'], 'none');
  final parsed = Act0LearningEvidenceRecordV1.tryParse(record);
  expect(
    parsed,
    isNotNull,
    reason: 'Actual persisted new evidence must parse through its owner.',
  );
  expect(
    act0CurrentAuthoredSourceProofForTaskV1(
      record: parsed!,
      worldId: r.world,
      lessonId: r.lesson,
      task: _task(r),
    ),
    isNotNull,
    reason: 'Actual new evidence must prove current authored source.',
  );
  final changed = Map<String, dynamic>.from(record)
    ..['authoredSourceFingerprint'] = List.filled(64, '0').join();
  expect(
    record['authoredSourceFingerprint'],
    isNot(changed['authoredSourceFingerprint']),
  );
  expect(
    Map<String, dynamic>.from(changed)..remove('authoredSourceFingerprint'),
    Map<String, dynamic>.from(record)..remove('authoredSourceFingerprint'),
  );
  final stale = Act0LearningEvidenceRecordV1.tryParse(changed);
  expect(stale, isNotNull);
  expect(
    act0CurrentAuthoredSourceProofForTaskV1(
      record: stale!,
      worldId: r.world,
      lessonId: r.lesson,
      task: _task(r),
    ),
    isNull,
  );
}

void main() {
  for (final row in act0PrivateW4BindingsV1) {
    testWidgets(
      '${row.task}: actual new completion then earned replay once XP',
      (t) async {
        await _mount(t, row);
        final before = await _saved(t);
        expect(_records(before, row.task), isEmpty);
        await _open(t, row, mission: true);
        await _answer(t, row, true, advance: true);
        final first = await _saved(t);
        expect(first['earnedXp'], _task(row).rewardXp);
        expect(
          first['completedTaskIds'],
          unorderedEquals([...(before['completedTaskIds'] as List), row.task]),
        );
        final evidence = _records(first, row.task);
        expect(evidence, hasLength(1));
        _attribution(evidence.single, row);
        expect(evidence.single['isCorrect'], true);
        expect(evidence.single['resultKind'], 'correct');
        await _open(t, row);
        await _answer(t, row, true, advance: true);
        final replay = await _saved(t);
        expect(replay['earnedXp'], first['earnedXp']);
        expect(replay['completedTaskIds'], first['completedTaskIds']);
        final repeated = _records(replay, row.task);
        expect(repeated, hasLength(2));
        expect(repeated.first, evidence.single);
        _attribution(repeated.last, row);
        expect(repeated.last['isCorrect'], true);
        expect(repeated.last['resultKind'], 'correct');
        expect(repeated.last['recordId'], isNot(evidence.single['recordId']));
      },
    );
    testWidgets(
      '${row.task}: actual wrong answer creates new attributed miss without reward',
      (t) async {
        await _mount(t, row);
        final before = await _saved(t);
        await _open(t, row, mission: true);
        await _answer(t, row, false);
        final after = await _saved(t);
        expect(after['earnedXp'], before['earnedXp']);
        expect(after['completedTaskIds'], before['completedTaskIds']);
        final records = _records(after, row.task);
        expect(records, hasLength(1));
        _attribution(records.single, row);
        expect(records.single['isCorrect'], false);
        expect(records.single['resultKind'], 'incorrect');
      },
    );
    testWidgets(
      '${row.task}: synthetic completed old source remains unchanged after real new attempt',
      (t) async {
        final old = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic-old-attempt-${row.task}',
          createdOrder: 1,
          worldId: row.world,
          lessonId: row.lesson,
          taskId: row.task,
          sourceTaskId: row.task,
          choiceId: 'call',
          expectedChoiceId: 'fold',
          isCorrect: false,
          errorType: 'synthetic-old-miss',
          repairFocusId: 'old-focus',
          skillAtomId: 'old-skill',
          decisionTimeBucket: 'unknown',
          resultKind: 'incorrect',
          authoredSourceFingerprint: List.filled(64, '0').join(),
        );
        expect(
          act0CurrentAuthoredSourceProofForTaskV1(
            record: old,
            worldId: row.world,
            lessonId: row.lesson,
            task: _task(row),
          ),
          isNull,
        );
        // A synthetic legacy record must survive the production parser before
        // this route can test preservation rather than invalid-input rejection.
        expect(Act0LearningEvidenceRecordV1.tryParse(old.toPayload()), old);
        expect(
          Act0LearningEvidenceRecordV1.tryParse({
            ...old.toPayload(),
            'resultKind': 'wrong',
          }),
          isNull,
        );
        await _mount(t, row, completed: true, old: old);
        final before = await _saved(t);
        expect(_records(before, row.task), [old.toPayload()]);
        await _open(t, row);
        await _answer(t, row, true, advance: true);
        final after = await _saved(t);
        expect(after['earnedXp'], before['earnedXp']);
        expect(after['completedTaskIds'], before['completedTaskIds']);
        final records = _records(after, row.task);
        expect(records, hasLength(2));
        expect(records.first, old.toPayload());
        _attribution(records.last, row);
        expect(records.last['recordId'], isNot(old.recordId));
        expect(records.last['isCorrect'], true);
      },
    );
  }
}

Object? _diagnosticSourcePayload({
  required String worldId,
  required String lessonId,
  required Act0LessonTaskV1 task,
}) {
  if (worldId.trim().isEmpty ||
      lessonId.trim().isEmpty ||
      task.taskId.trim().isEmpty) {
    return null;
  }
  final table = task.runner.table;
  final sizingPresets = task.runner.sizingConfig.presets.toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  final optionSemantics =
      task.runner.options
          .map(
            (option) => <Object?>[
              option.id,
              option.isCorrect,
              option.quality.name,
              option.amountLabel,
              option.feedbackReason,
              option.seatId,
              option.repairFocusSeatIds.toList()..sort(),
              option.repairFocusCardIds.toList()..sort(),
              option.repairFocusLabels.toList()..sort(),
            ],
          )
          .toList()
        ..sort((a, b) => (a[0] as String).compareTo(b[0] as String));
  final cardFocusRevision = act0PredecisionCardFocusSourceRevisionV1(task);
  final answerCueRevision = act0PrechoiceAnswerCueSourceRevisionV1(
    task,
    lessonId: lessonId,
  );
  final payload = <Object?>[
    'act0_authored_source_v1',
    if (cardFocusRevision != null) cardFocusRevision,
    if (answerCueRevision != null) answerCueRevision,
    worldId,
    lessonId,
    task.taskId,
    task.phase.name,
    task.stepKind.name,
    task.resolvedTaskFamily.name,
    task.tablePresentation.name,
    task.runner.lessonId,
    task.runner.lessonTitle,
    task.runner.caption,
    task.runner.hint,
    task.runner.question,
    task.runner.feedbackReason,
    task.runner.feedbackSignalId,
    task.runner.sizingConfig.mode.name,
    task.runner.sizingConfig.showGuidance,
    <Object?>[
      for (final preset in sizingPresets)
        <Object?>[preset.id, preset.potFraction, preset.isPrimary],
    ],
    <Object?>[
      table.scope.name,
      table.tableFormat.name,
      table.playerCount,
      table.density.name,
      table.streetLabel,
      table.potLabel,
      table.toCallLabel,
      table.centerLabel,
      table.focusCalloutLabel,
      table.emptyBoardLabel,
      table.activeSeatId,
      table.heroSeatId,
      for (final seat in table.seats)
        <Object?>[
          seat.seatId,
          seat.seatLabel,
          seat.displayName,
          seat.isHero,
          seat.isDealerButton,
          seat.isSmallBlind,
          seat.isBigBlind,
          seat.blindAmountLabel,
          seat.isActive,
          seat.isTarget,
          seat.isInHand,
          seat.isFolded,
          seat.hasActed,
          seat.isLastAggressor,
          seat.isOccupied,
          seat.stackLabel,
          seat.currentBetLabel,
          seat.cardsVisibleMode.name,
          _cards(seat.holeCards),
          seat.bet == null
              ? null
              : <Object?>[
                  seat.bet!.kind.name,
                  seat.bet!.label,
                  seat.bet!.amountLabel,
                ],
        ],
      _cards(table.heroCards),
      _cards(table.boardCards),
      for (final action in table.actionTrail)
        <Object?>[action.kind.name, action.label],
      table.selectableSeatIds.toList()..sort(),
    ],
    optionSemantics,
  ];
  return payload;
}

List<Object?> _cards(Iterable<Act0CardStateV1> cards) => [
  for (final c in cards) [c.rank, c.suit],
];
