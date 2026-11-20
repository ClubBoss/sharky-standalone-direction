import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w1_rules_check_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';
final _today = DateTime.utc(2026, 11, 20, 12);

Future<void> _mount(WidgetTester tester, {DateTime? clock}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        showPlacementOnStart: true,
        clock: Act0FixedUtcClockV1(clock ?? _today),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<Map<String, Object?>> _saved(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final prefs = await SharedPreferences.getInstance();
  return (jsonDecode(prefs.getString(_progressKey)!) as Map)
      .cast<String, Object?>();
}

Future<void> _tapKey(WidgetTester tester, String name) async {
  final target = find.byKey(Key(name)).hitTestable();
  expect(target, findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _runCheck(WidgetTester tester, int right) async {
  await _tapKey(tester, 'act0_shell_w1_start_check');
  for (final (index, question) in act0W1RulesQuestionsV1.indexed) {
    expect(find.text(question.question), findsWidgets);
    expect(find.text('Need a hint?'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_learning_scene_sharky_avatar')),
      findsNothing,
    );
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsNothing);
    final choice = index < right
        ? question.correctChoice
        : (question.correctChoice + 1) % question.choices.length;
    await _tapKey(tester, 'act0_shell_option_choice_$choice');
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'basics opens one lesson explanation and then the first scored decision',
    (tester) async {
      usePhone(tester);
      await _mount(tester);
      await _tapKey(tester, 'act0_shell_w1_start_basics');
      Act0LessonRunnerShellV1 current() =>
          tester.widget(find.byType(Act0LessonRunnerShellV1));
      expect(current().selectedTaskId, 'what_poker_is_theory');
      expect(current().runner.teachingSteps, hasLength(1));
      await tester.pump(const Duration(milliseconds: 900));
      await _tapKey(tester, 'act0_shell_continue_cta');
      expect(current().selectedTaskId, 'what_poker_is_find_hero');
      expect(current().runner.activeTeachingStep, isNull);
      expect(find.text('Which cards belong to you alone?'), findsWidgets);
      expect(find.text('Your start'), findsNothing);
      await _saved(tester);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final correct in [9, 10]) {
    testWidgets(
      '$correct correct opens W2 with only check XP, including after restart',
      (tester) async {
        usePhone(tester);
        await _mount(tester);
        await _runCheck(tester, correct);
        expect(find.text('Your start'), findsOneWidget);
        expect(
          find.text('W1 passed by test. You start at W2.'),
          findsOneWidget,
        );
        final saved = await _saved(tester);
        expect(
          saved['earnedXp'],
          correct * Act0W1RulesResultV1.xpPerCorrectAnswer,
        );
        expect(saved['completedTaskIds'], isEmpty);
        expect(saved['skippedTaskIds'], isEmpty);
        expect(saved['selectedWorldId'], 'world_2');
        expect(saved['w1RulesBestScore'], correct);
        await _tapKey(tester, 'act0_shell_w1_rules_continue');
        expect(
          tester
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .selectedWorldId,
          'world_2',
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await _mount(tester);
        expect(
          find.byKey(const Key('act0_shell_w1_start_check')),
          findsNothing,
        );
        expect((await _saved(tester))['w1RulesBestScore'], correct);
      },
    );
  }

  testWidgets(
    'eight correct keeps W1 and schedules only the missed questions',
    (tester) async {
      usePhone(tester);
      await _mount(tester);
      await _runCheck(tester, 8);
      expect(find.text('Start with W1.'), findsOneWidget);
      expect(find.text('Focus: Price to call, All-in bets'), findsOneWidget);
      final saved = await _saved(tester);
      expect(saved['selectedWorldId'], 'world_1');
      expect(saved['w1RulesBestScore'], 8);
      expect(
        saved['w1RulesFocusTaskIds'],
        unorderedEquals([
          'w1_rules_check_raise_call_price',
          'w1_rules_check_uncalled_all_in',
        ]),
      );
      final retention = saved['durableRetentionHistory'] as List;
      expect(retention, hasLength(2));
      expect(
        retention.map((row) => (row as Map)['nextDueAtUtc']),
        everyElement(_today.add(const Duration(days: 1)).toIso8601String()),
      );
      await _tapKey(tester, 'act0_shell_w1_rules_continue');
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedWorldId,
        'world_1',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await _mount(tester, clock: _today.add(const Duration(hours: 25)));
      await tester.tap(find.text('Review').last);
      await tester.pumpAndSettle();
      expect(find.text('2 independent reviews due'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const Key('act0_academy_review_leaf_start_due')),
      );
      await _tapKey(tester, 'act0_academy_review_leaf_start_due');
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        startsWith('w1_rules_check_'),
      );
    },
  );

  testWidgets('old saved progress opens without a W1 check', (tester) async {
    usePhone(tester);
    SharedPreferences.setMockInitialValues({
      _progressKey: jsonEncode({
        'schemaVersion': 20,
        'completedTaskIds': ['what_poker_is_theory'],
        'completedLessonIds': [],
        'skippedTaskIds': [],
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'what_poker_is',
        'selectedTaskId': 'what_poker_is_find_hero',
        'earnedXp': 5,
      }),
    });
    await _mount(tester);
    expect(find.byKey(const Key('act0_shell_w1_start_basics')), findsNothing);
    final saved = await _saved(tester);
    expect(saved['earnedXp'], 5);
    expect(saved['completedTaskIds'], ['what_poker_is_theory']);
  });

  testWidgets('leaving the check before answering starts W1 without an award', (
    tester,
  ) async {
    usePhone(tester);
    await _mount(tester);
    await _tapKey(tester, 'act0_shell_w1_start_check');
    await _tapKey(tester, 'act0_shell_runner_back');
    expect(find.text('Your start'), findsNothing);
    final saved = await _saved(tester);
    expect(saved['selectedWorldId'], 'world_1');
    expect(saved['earnedXp'], 0);
    expect(saved['w1RulesFocusTaskIds'], isNull);
  });
}
