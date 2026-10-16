import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// S11 progress truth: Placement may CLEAR lessons so the path opens at the
// right place, but a cleared lesson is not an earned completion. Home/Learn
// "N of 9 lessons complete" must count earned lessons; cleared ones are named
// honestly and never counted as earned. Routing, skips, XP and evidence are
// unchanged. Real casual first-install route; no seeded learner state.
const _progressKey = 'act0_shell_progress_v1';
const _fixture =
    'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json';

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  expect(f, findsOneWidget, reason: key);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester tester) async {
  (tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
      .debugPersistProgressV1();
  await tester.pump(const Duration(milliseconds: 250));
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _mount(WidgetTester tester, {required bool fresh}) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: fresh,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _homeLabel(WidgetTester tester) =>
    tester
        .widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1))
        .pathProgressLabel ??
    '';

int _earnedLessons(Map<String, dynamic> saved) {
  final done = (saved['completedTaskIds'] as List).cast<String>().toSet();
  return Act0ShellStateV1.sample
      .worldById('world_1')
      .lessons
      .where((l) => l.taskList.every((t) => done.contains(t.taskId)))
      .length;
}

Future<Map<String, dynamic>> _placementRouteToRunner(
  WidgetTester tester,
) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await _mount(tester, fresh: true);
  await _tapKey(tester, 'act0_shell_placement_intro_cta');
  for (final option in const ['friends', 'rules']) {
    await _tapKey(tester, 'act0_shell_placement_option_$option');
    await _tapKey(tester, 'act0_shell_placement_next_cta');
  }
  await _tapKey(tester, 'act0_shell_placement_start_diagnostic');
  for (var i = 0; i < 3; i++) {
    final o = _runner(tester).runner.options.firstWhere((o) => o.isCorrect);
    await _tapKey(
      tester,
      o.seatId == null
          ? 'act0_shell_option_${o.id}'
          : 'act0_shell_seat_tap_${o.seatId}',
    );
    await _tapKey(tester, 'act0_shell_feedback_continue_cta');
  }
  await _tapKey(tester, 'act0_shell_placement_start_recommended');
  await _tapKey(tester, 'act0_shell_welcome_primary_cta');
  final a = _runner(tester).runner.options.firstWhere((o) => o.isCorrect);
  await _tapKey(tester, 'act0_shell_option_${a.id}');
  await _tapKey(tester, 'act0_shell_welcome_primary_cta');
  return _saved(tester);
}

Future<Map<String, dynamic>> _coldRestart(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
  await _mount(tester, fresh: false);
  return _saved(tester);
}

const _guardedKeys = <String>[
  'completedTaskIds',
  'completedLessonIds',
  'earnedXp',
  'learningEvidenceHistory',
  'durableRetentionHistory',
  'openRepairIntents',
  'selectedLessonId',
  'selectedTaskId',
];

void main() {
  test(
    'actions_legal_context asks for staying in the hand, not any free action',
    () {
      final task = Act0ShellStateV1.sample
          .lessonById('fold_check_call_raise')
          .taskList
          .firstWhere((task) => task.taskId == 'actions_legal_context');
      expect(task.runner.question, contains('keeps you in the hand'));
      expect(task.runner.question, contains('without adding chips'));
      expect(
        task.runner.options.map((option) => option.id),
        containsAll(<String>['fold', 'check', 'call']),
      );
      expect(
        task.runner.options.where((option) => option.isCorrect).single.id,
        'check',
      );
      expect(
        task.runner.options
            .firstWhere((option) => option.id == 'fold')
            .isCorrect,
        isFalse,
      );
    },
  );

  testWidgets('Placement-cleared lessons are not shown as earned lesson '
      'completions on Home; You agrees', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _mount(tester, fresh: true);
    await _tapKey(tester, 'act0_shell_placement_intro_cta');
    for (final option in const ['friends', 'rules']) {
      await _tapKey(tester, 'act0_shell_placement_option_$option');
      await _tapKey(tester, 'act0_shell_placement_next_cta');
    }
    await _tapKey(tester, 'act0_shell_placement_start_diagnostic');
    for (var i = 0; i < 3; i++) {
      final o = _runner(tester).runner.options.firstWhere((o) => o.isCorrect);
      await _tapKey(
        tester,
        o.seatId == null
            ? 'act0_shell_option_${o.id}'
            : 'act0_shell_seat_tap_${o.seatId}',
      );
      await _tapKey(tester, 'act0_shell_feedback_continue_cta');
    }
    await _tapKey(tester, 'act0_shell_placement_start_recommended');
    await _tapKey(tester, 'act0_shell_welcome_primary_cta');
    final welcomeAnswer = _runner(
      tester,
    ).runner.options.firstWhere((o) => o.isCorrect);
    await _tapKey(tester, 'act0_shell_option_${welcomeAnswer.id}');
    await _tapKey(tester, 'act0_shell_welcome_primary_cta');
    final saved = await _saved(tester);
    final skipped = (saved['skippedTaskIds'] as List).cast<String>();
    expect(skipped, isNotEmpty, reason: 'Placement cleared part of the path');
    expect(saved['completedTaskIds'], isEmpty);
    expect(saved['earnedXp'], 0);

    // In-session (no restart): leave the runner for Home, as the learner does.
    await _tapKey(tester, 'act0_shell_runner_back');
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    final label = _homeLabel(tester);
    expect(
      label,
      '0 of 9 lessons complete',
      reason: 'cleared lessons must not be counted as earned completions',
    );
    // The Home "route proof is active" receipt is only for a source-earned
    // lesson; Placement clearance alone must not trigger it.
    expect(
      find.byKey(const Key('act0_shell_home_proof_momentum_line')),
      findsNothing,
    );
    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('0 tasks complete'), findsWidgets);

    // Learn presents Placement-cleared routing separately from earned progress.
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    final learnBar = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('act0_shell_learn_progress_bar')),
    );
    expect(learnBar.value, 0.0);
    expect(
      find.textContaining('Placement cleared - available to practice'),
      findsWidgets,
    );
    expect(
      find.byKey(const Key('act0_shell_journey_completed_achieved_v5')),
      findsNothing,
      reason: 'Placement clearance cannot draw an earned green check',
    );

    // Skips/navigation/XP are preserved by the correction.
    final after = await _saved(tester);
    expect(after['skippedTaskIds'], saved['skippedTaskIds']);
    expect(after['completedTaskIds'], saved['completedTaskIds']);
    expect(after['earnedXp'], saved['earnedXp']);

    // After a cold restart Home still counts exactly the canonical earned
    // lessons (whatever restore holds), never the cleared ones on top.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await _mount(tester, fresh: false);
    final restored = await _saved(tester);
    expect(
      _homeLabel(tester),
      startsWith('${_earnedLessons(restored)} of 9 lessons complete'),
    );
    expect(restored['skippedTaskIds'], saved['skippedTaskIds']);
    expect(restored['earnedXp'], 0);
  });

  testWidgets('earned lessons still count and no placement wording appears '
      'when nothing was cleared by placement', (tester) async {
    final raw =
        jsonDecode(File(_fixture).readAsStringSync()) as Map<String, dynamic>;
    final progress =
        jsonDecode(
              raw['flutter.$_progressKey'] as String? ??
                  raw[_progressKey] as String,
            )
            as Map<String, dynamic>;
    SharedPreferences.setMockInitialValues(<String, Object>{
      for (final e in raw.entries) e.key: e.value as Object,
    });
    await _mount(tester, fresh: false);
    final saved = await _saved(tester);
    final label = _homeLabel(tester);
    expect(label, '${_earnedLessons(saved)} of 9 lessons complete');
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    final learnBar = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('act0_shell_learn_progress_bar')),
    );
    expect(
      learnBar.value,
      closeTo(_earnedLessons(saved) / 9, 0.00001),
      reason: 'actual earned lessons still count toward Learn progress',
    );
    expect(
      find.textContaining('Placement cleared - available to practice'),
      findsNothing,
    );
  });

  testWidgets('cold restart (twice) never promotes Placement skips to earned '
      'completion; routing, XP, evidence and repair state are stable', (
    tester,
  ) async {
    final before = await _placementRouteToRunner(tester);
    expect(before['completedTaskIds'], isEmpty);
    expect((before['skippedTaskIds'] as List), isNotEmpty);
    for (var restart = 1; restart <= 2; restart++) {
      final after = await _coldRestart(tester);
      for (final key in _guardedKeys) {
        expect(
          after[key],
          before[key],
          reason: '$key changed on cold restart #$restart',
        );
      }
      expect(
        (after['skippedTaskIds'] as List).toSet().containsAll(
          (before['skippedTaskIds'] as List).toSet(),
        ),
        isTrue,
        reason: 'Placement skip/navigation closure preserved (#$restart)',
      );
      expect(_homeLabel(tester), '0 of 9 lessons complete');
      expect(
        find.byKey(const Key('act0_shell_home_proof_momentum_line')),
        findsNothing,
      );
      await tester.tap(find.text('You').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('0 tasks complete'), findsWidgets);
    }
    // After both persistence assertions, inspect Learn without changing
    // the selected lesson between the two restarts.
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const Key('act0_shell_learn_progress_bar')),
          )
          .value,
      0.0,
    );
    expect(
      find.textContaining('Placement cleared - available to practice'),
      findsWidgets,
    );
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
  });

  testWidgets('legacy save with only skipped tasks beyond the guide stays '
      'path-closed as a skip, earning nothing', (tester) async {
    final before = await _placementRouteToRunner(tester);
    // An older save whose skip list lacks the content-lesson tasks: restore may
    // close them for routing as skips but must not earn them.
    final content = Act0ShellStateV1.sample
        .lessonById('what_poker_is_content')
        .taskList
        .map((t) => t.taskId)
        .toSet();
    final prefs = await SharedPreferences.getInstance();
    final legacy = jsonDecode(prefs.getString(_progressKey)!) as Map;
    legacy['skippedTaskIds'] = [
      for (final id in (legacy['skippedTaskIds'] as List))
        if (!content.contains(id)) id,
    ];
    await prefs.setString(_progressKey, jsonEncode(legacy));
    final after = await _coldRestart(tester);
    expect(after['completedTaskIds'], isEmpty);
    expect(after['earnedXp'], 0);
    expect(
      (after['skippedTaskIds'] as List).toSet().containsAll(content),
      isTrue,
      reason: 'content lesson stays closed for routing as a skip',
    );
    expect(after['selectedLessonId'], before['selectedLessonId']);
    expect(_homeLabel(tester), '0 of 9 lessons complete');
  });

  testWidgets('genuine legacy completion beyond the guide still auto-completes '
      'the content lesson on restore', (tester) async {
    final raw =
        jsonDecode(File(_fixture).readAsStringSync()) as Map<String, dynamic>;
    final key = raw.containsKey('flutter.$_progressKey')
        ? 'flutter.$_progressKey'
        : _progressKey;
    final progress = jsonDecode(raw[key] as String) as Map<String, dynamic>;
    final content = Act0ShellStateV1.sample
        .lessonById('what_poker_is_content')
        .taskList
        .map((t) => t.taskId)
        .toSet();
    // A pre-split legacy save: the guide plus GENUINE completions beyond it
    // (cards lesson started), the content lesson not yet recorded.
    progress['completedTaskIds'] = [
      for (final id in (progress['completedTaskIds'] as List))
        if (!content.contains(id)) id,
      'cards_ranks_suits_theory',
    ];
    progress['completedLessonIds'] = <String>['what_poker_is'];
    progress['skippedTaskIds'] = <String>[];
    progress['selectedLessonId'] = 'cards_ranks_suits';
    progress['selectedTaskId'] = 'cards_ranks_suits_private_board';
    raw[key] = jsonEncode(progress);
    SharedPreferences.setMockInitialValues(<String, Object>{
      for (final e in raw.entries) e.key: e.value as Object,
    });
    await _mount(tester, fresh: false);
    final saved = await _saved(tester);
    expect(
      (saved['completedTaskIds'] as List).toSet().containsAll(content),
      isTrue,
      reason: 'genuine legacy compatibility is preserved',
    );
    expect(saved['completedLessonIds'], contains('what_poker_is_content'));
  });

  testWidgets('Placement then one genuinely earned task: cold restart still '
      'earns nothing for the Placement-skipped lessons', (tester) async {
    await _placementRouteToRunner(tester);
    expect(_runner(tester).selectedTaskId, 'actions_legal_context');
    final right = _runner(tester).runner.options.firstWhere((o) => o.isCorrect);
    for (var i = 0; i < 12; i++) {
      if (find
          .byKey(Key('act0_shell_option_${right.id}'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
      await _tapKey(
        tester,
        theory.evaluate().isNotEmpty
            ? 'act0_shell_theory_continue_cta'
            : 'act0_shell_continue_cta',
      );
    }
    await _tapKey(tester, 'act0_shell_option_${right.id}');
    await _tapKey(tester, 'act0_shell_feedback_continue_cta');
    final before = await _saved(tester);
    expect(before['completedTaskIds'], ['actions_legal_context']);
    expect(before['earnedXp'], 5);
    for (var restart = 1; restart <= 2; restart++) {
      final after = await _coldRestart(tester);
      for (final key in _guardedKeys) {
        expect(
          after[key],
          before[key],
          reason:
              '$key changed on cold restart #$restart after one earned task',
        );
      }
      expect(_homeLabel(tester), '0 of 9 lessons complete');
    }
  });
}
