import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_same_session_learning_delta_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_hand_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Same-session learning delta projection', () {
    test('exact W2 recovered outcome produces one stable delta', () {
      final outcome = _outcome(
        id: 'starting_hand:apply_hj_decision|attempt_1',
        taskId: 'apply_hj_decision',
        skillId: 'table_read',
        missedSignal: 'hero_seat',
      );

      final first = Act0SameSessionLearningDeltaProjectionV1.fromOutcomes(
        <Act0LearningRunOutcomeV1>[outcome],
      ).primaryDelta;
      final second = Act0SameSessionLearningDeltaProjectionV1.fromOutcomes(
        <Act0LearningRunOutcomeV1>[outcome],
      ).primaryDelta;

      expect(first, isNotNull);
      expect(first!.deltaId, second!.deltaId);
      expect(first.deltaKind, 'same_session_recovery');
      expect(first.outcomeType, 'recovered_after_repair');
      expect(first.sourceTaskId, 'apply_hj_decision');
      expect(first.skillId, 'table_read');
      expect(first.missedSignalId, 'hero_seat');
      expect(
        first.line,
        "You missed Hero's seat first. On the recheck, you used it correctly.",
      );
    });

    test('correct-first, incomplete, and failed repair/recheck yield none', () {
      final cases = <Act0LearningRunOutcomeV1>[
        _outcome(firstCorrect: true),
        _outcome(
          finalOutcome: Act0LearningRunFinalOutcomeV1.incomplete,
          repaired: false,
          recheck: null,
        ),
        _outcome(
          finalOutcome: Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
          recheck: false,
        ),
        _outcome(repaired: false),
        _outcome(recheck: false),
      ];

      for (final outcome in cases) {
        expect(
          Act0SameSessionLearningDeltaProjectionV1.fromOutcomes(
            <Act0LearningRunOutcomeV1>[outcome],
          ).primaryDelta,
          isNull,
        );
      }
    });

    test('unknown skill/signal combinations produce no delta', () {
      final cases = <Act0LearningRunOutcomeV1>[
        _outcome(skillId: ''),
        _outcome(missedSignal: ''),
        _outcome(taskId: ''),
        _outcome(skillId: 'unknown_skill'),
        _outcome(skillId: 'table_read', missedSignal: 'unknown_signal'),
      ];

      for (final outcome in cases) {
        expect(
          Act0SameSessionLearningDeltaProjectionV1.fromOutcomes(
            <Act0LearningRunOutcomeV1>[outcome],
          ).primaryDelta,
          isNull,
        );
      }
    });

    test('latest event order wins with a stable delta-id tie-break', () {
      final selected = Act0SameSessionLearningDeltaProjectionV1.fromOutcomes(
        <Act0LearningRunOutcomeV1>[
          _outcome(id: 'z', order: 2),
          _outcome(id: 'b', order: 3),
          _outcome(id: 'a', order: 3),
          _outcome(
            id: 'clean',
            order: 9,
            firstCorrect: true,
            repaired: false,
            recheck: null,
            finalOutcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
          ),
        ],
      ).primaryDelta;

      expect(selected, isNotNull);
      expect(selected!.deltaId, 'same_session_delta_v1|a|table_read|hero_seat');
    });

    test('copy and telemetry stay inside the claim and privacy allowlists', () {
      final delta = Act0SameSessionLearningDeltaProjectionV1.fromOutcomes(
        <Act0LearningRunOutcomeV1>[
          _outcome(skillId: 'table_read', missedSignal: 'hero_seat'),
        ],
      ).primaryDelta!;
      final lower = delta.line.toLowerCase();
      for (final forbidden in <String>[
        'kqo',
        'apply_hj_decision',
        'mastered',
        'fixed forever',
        'solved',
        'guaranteed',
        'leak eliminated',
        'perfect',
        'gto',
        'ai',
      ]) {
        expect(lower, isNot(contains(forbidden)));
      }
      expect(delta.telemetryFields.keys.toSet(), <String>{
        'schemaVersion',
        'delta_kind',
        'outcome_type',
        'skill_id',
        'missed_signal_id',
        'surface',
        'evidence_count',
      });
      expect(delta.telemetryFields['surface'], 'source_recheck_feedback');
      final physical = jsonEncode(delta.telemetryFields);
      for (final forbidden in <String>[
        'KQo',
        'apply_hj_decision',
        'sessionId',
        'session_id',
      ]) {
        expect(physical, isNot(contains(forbidden)));
      }
    });
  });

  testWidgets('completed-lesson W2 replay shows one delta on the source recheck '
      'feedback, keeps the CTA reachable, emits once, then closes the run '
      'normally through Review', (tester) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    _seedW2ApplyPrecondition(sourceCompleted: true);
    await _pumpW2Route(tester, sink);

    await _openCompletedW2SourceReplay(tester);
    await _answerW2Route(tester, correct: false);
    await tester.tap(find.text('Try same clue'));
    await tester.pumpAndSettle();
    await _answerW2Route(tester, correct: true);
    await _continueW2Feedback(tester);

    // Correct source recheck: the delta should render on this terminal
    // feedback screen, before Review closes the Learning Run.
    await _answerW2Route(tester, correct: true);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_repair_outcome_proof_line')),
      findsOneWidget,
    );
    expect(
      find.text(
        "You missed Hero's seat first. On the recheck, you used it correctly.",
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_repair_outcome_proof_title')),
      findsOneWidget,
    );
    expect(find.text('Repair landed'), findsOneWidget);

    final viewedAfterFirstRender = sink.events
        .where((event) => event.name == 'learning_effect_delta_viewed')
        .toList(growable: false);
    expect(viewedAfterFirstRender, hasLength(1));

    // Rebuild without a code change must not duplicate the viewed event.
    await tester.pump();
    final viewedAfterRebuild = sink.events
        .where((event) => event.name == 'learning_effect_delta_viewed')
        .toList(growable: false);
    expect(viewedAfterRebuild, hasLength(1));
    expect(viewedAfterRebuild.single.fields, <String, Object?>{
      'schemaVersion': 1,
      'delta_kind': 'same_session_recovery',
      'outcome_type': 'recovered_after_repair',
      'skill_id': 'table_read',
      'missed_signal_id': 'hero_seat',
      'surface': 'source_recheck_feedback',
      'evidence_count': 1,
    });

    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    expect(cta, findsOneWidget);
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(cta).bottom,
      lessThanOrEqualTo(
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      ),
    );
    await tester.tap(cta);
    await tester.pumpAndSettle();

    final completed = sink.events
        .where((event) => event.name == 'learning_effect_delta_completed')
        .toList(growable: false);
    expect(completed, hasLength(1));
    expect(completed.single.fields, viewedAfterRebuild.single.fields);

    // Production route continues to Review and does not show a
    // Session Summary claim for this delta.
    expect(
      find.byKey(const Key('act0_shell_repair_outcome_proof_line')),
      findsNothing,
    );
    expect(find.text('You corrected this read'), findsNothing);

    final outcomes = sink.events
        .where((event) => event.name == 'learning_run_outcome_recorded')
        .toList(growable: false);
    final recoveredOutcomes = outcomes
        .where(
          (event) => event.fields['outcome_type'] == 'recoveredAfterRepair',
        )
        .toList(growable: false);
    expect(recoveredOutcomes, hasLength(1));
    expect(recoveredOutcomes.single.fields['skill_id'], 'table_read');
    expect(recoveredOutcomes.single.fields['repair_attempted'], isTrue);
    expect(recoveredOutcomes.single.fields['recheck_result'], isTrue);
    expect(recoveredOutcomes.single.fields['missed_signal'], 'hero_seat');
  });

  testWidgets(
    'a clean correct-first task shows no delta on its recheck feedback',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      _seedW2ApplyPrecondition(sourceCompleted: true);
      await _pumpW2Route(tester, sink);

      await _openCompletedW2SourceReplay(tester);
      await _answerW2Route(tester, correct: true);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_repair_outcome_proof_line')),
        findsNothing,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'learning_effect_delta_viewed',
        ),
        isEmpty,
      );
    },
  );
}

Act0LearningRunOutcomeV1 _outcome({
  String id = 'w2_source',
  String taskId = 'apply_hj_decision',
  String skillId = 'table_read',
  String missedSignal = 'hero_seat',
  bool firstCorrect = false,
  bool repaired = true,
  bool? recheck = true,
  Act0LearningRunFinalOutcomeV1 finalOutcome =
      Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
  int order = 1,
}) => Act0LearningRunOutcomeV1(
  outcomeId: id,
  lessonId: 'hand_discipline_apply',
  taskId: taskId,
  skillId: skillId,
  firstAttemptCorrect: firstCorrect,
  errorType: firstCorrect ? 'none' : 'misread_starting_hand_discipline',
  repairAttempted: repaired,
  recheckResult: recheck,
  finalOutcome: finalOutcome,
  missedSignal: missedSignal,
  recommendationSignal: 'compare_seat_and_action_frame',
  eventOrder: order,
);

void _seedW2ApplyPrecondition({bool sourceCompleted = false}) {
  final state = Act0ShellStateV1.sample;
  final world = state.worldById(Act0StartingHandPersonalizationV1.worldId);
  final worldIndex = state.worlds.indexWhere(
    (candidate) => candidate.worldId == world.worldId,
  );
  final targetLessonIndex = world.lessons.indexWhere(
    (lesson) =>
        lesson.lessonId == Act0StartingHandPersonalizationV1.sourceLessonId,
  );
  final targetLesson = world.lessons[targetLessonIndex];
  final sourceTaskIndex = targetLesson.taskList.indexWhere(
    (task) => task.taskId == Act0StartingHandPersonalizationV1.sourceTaskId,
  );
  final completedLessons = <String>[
    for (final priorWorld in state.worlds.take(worldIndex))
      ...priorWorld.lessons.map((lesson) => lesson.lessonId),
    ...world.lessons.take(targetLessonIndex).map((lesson) => lesson.lessonId),
  ];
  final completedTasks = <String>[
    for (final priorWorld in state.worlds.take(worldIndex))
      for (final lesson in priorWorld.lessons)
        ...lesson.taskList.map((task) => task.taskId),
    for (final lesson in world.lessons.take(targetLessonIndex))
      ...lesson.taskList.map((task) => task.taskId),
    ...targetLesson.taskList.take(sourceTaskIndex).map((task) => task.taskId),
  ];
  if (sourceCompleted) {
    completedLessons.add(targetLesson.lessonId);
    completedTasks.addAll(targetLesson.taskList.map((task) => task.taskId));
  }
  final progressPayload = <String, Object>{
    'schemaVersion': 17,
    'completedTaskIds': completedTasks,
    'skippedTaskIds': <String>[],
    'completedLessonIds': completedLessons,
    'selectedWorldId': world.worldId,
    'selectedLessonId': targetLesson.lessonId,
    'selectedTaskId': Act0StartingHandPersonalizationV1.sourceTaskId,
    'earnedXp': 0,
  };
  SharedPreferences.setMockInitialValues(<String, Object>{
    'intake_completed_v1': true,
    'act0_welcome_completed_v1': true,
    'act0_shell_progress_v1': jsonEncode(progressPayload),
  });
}

Future<void> _pumpW2Route(
  WidgetTester tester,
  Act0InMemoryTelemetrySinkV1 sink,
) async {
  tester.view.physicalSize = const Size(375, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.learn,
        initialPhase: Act0LessonPhaseV1.drill,
        showPlacementOnStart: false,
        telemetrySink: sink,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openCompletedW2SourceReplay(WidgetTester tester) async {
  await tester.tap(find.text('All lessons'));
  await tester.pumpAndSettle();
  final lesson = find.text('Discipline at the table');
  await tester.ensureVisible(lesson);
  await tester.tap(lesson);
  await tester.pumpAndSettle();
  final sourceTask = find.text('HJ, medium hand');
  final learnScroll = find.descendant(
    of: find.byKey(const Key('act0_shell_learn_screen')),
    matching: find.byType(Scrollable),
  );
  await tester.drag(learnScroll, const Offset(0, -520));
  await tester.pumpAndSettle();
  await tester.tap(sourceTask);
  await tester.pumpAndSettle();
  final replay = find.byKey(const Key('act0_shell_selected_lesson_cta'));
  await tester.ensureVisible(replay);
  await tester.tap(replay);
  tester.view.physicalSize = const Size(375, 812);
  await tester.pumpAndSettle();
}

Future<void> _answerW2Route(
  WidgetTester tester, {
  required bool correct,
}) async {
  var runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  var option = runner.runner.options.firstWhere(
    (candidate) => candidate.isCorrect == correct,
  );
  var finder = find.byKey(Key('act0_shell_option_${option.id}'));
  for (var i = 0; i < 4 && finder.evaluate().isEmpty; i++) {
    final continueCta = find.byKey(const Key('act0_shell_continue_cta'));
    expect(continueCta, findsOneWidget);
    await tester.tap(continueCta);
    await tester.pumpAndSettle();
    runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    option = runner.runner.options.firstWhere(
      (candidate) => candidate.isCorrect == correct,
    );
    finder = find.byKey(Key('act0_shell_option_${option.id}'));
  }
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _continueW2Feedback(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    if (cta.evaluate().isEmpty) return;
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}

Future<void> _openW2Repair(WidgetTester tester) async {
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Practice'));
  await tester.pumpAndSettle();
  final queue = find.byKey(const Key('act0_shell_play_repair_queue'));
  expect(queue, findsOneWidget);
  await tester.tap(
    find.descendant(of: queue, matching: find.text('Practice this')),
  );
  await tester.pumpAndSettle();
}
