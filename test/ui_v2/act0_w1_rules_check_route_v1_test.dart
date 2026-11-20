import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
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
  await _answerCheck(tester, right);
}

Future<void> _answerCheck(WidgetTester tester, int right) async {
  for (final (index, question) in act0W1RulesQuestionsV1.indexed) {
    expect(find.text(question.question), findsWidgets);
    expect(find.text('Step ${index + 1} of 10'), findsOneWidget);
    if (question.id == 'preflop_after_hj' ||
        question.id == 'postflop_two_left') {
      final runner = tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .runner;
      final seats = runner.table.seats;
      expect(seats.where((seat) => seat.isOccupied), hasLength(6));
      expect(runner.table.highlightedSeatIds, isEmpty);
      expect(
        seats.where((seat) => seat.isInHand).map((seat) => seat.seatId),
        unorderedEquals(
          question.id == 'preflop_after_hj'
              ? ['utg', 'co', 'btn', 'sb', 'bb']
              : ['sb', 'btn'],
        ),
      );
      expect(seats.singleWhere((seat) => seat.seatId == 'hj').isFolded, isTrue);
    }

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
      final next = find.byKey(const Key('act0_shell_continue_cta'));
      expect(
        find.descendant(of: next, matching: find.text('Next')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_shell_previous_cta')), findsNothing);
      expect(tester.getSize(next).height, greaterThanOrEqualTo(48));

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

  testWidgets('answers use one light tap without exposing quiz results', (
    tester,
  ) async {
    usePhone(tester);
    final calls = <Object?>[];
    final platform = tester.binding.defaultBinaryMessenger;
    platform.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments);
      return null;
    });
    addTearDown(
      () => platform.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final settings = AppSettingsService.instance;
    await settings.load();
    addTearDown(() => settings.setHapticsEnabled(true));

    await _mount(tester);
    await _tapKey(tester, 'act0_shell_w1_start_check');
    final first = act0W1RulesQuestionsV1[0];
    final second = act0W1RulesQuestionsV1[1];
    final third = act0W1RulesQuestionsV1[2];
    await _tapKey(tester, 'act0_shell_option_choice_${first.correctChoice}');
    final wrong = (second.correctChoice + 1) % second.choices.length;
    await _tapKey(tester, 'act0_shell_option_choice_$wrong');
    expect(calls, [
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.lightImpact',
    ]);
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsNothing);
    await settings.setHapticsEnabled(false);
    await _tapKey(tester, 'act0_shell_option_choice_${third.correctChoice}');
    expect(calls, hasLength(2));
  });

  testWidgets('ordinary wrong and correct decisions use light haptics', (
    tester,
  ) async {
    usePhone(tester);
    final calls = <Object?>[];
    final platform = tester.binding.defaultBinaryMessenger;
    platform.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments);
      return null;
    });
    addTearDown(
      () => platform.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await AppSettingsService.instance.load();
    await _mount(tester);
    await _tapKey(tester, 'act0_shell_w1_start_basics');
    await tester.pump(const Duration(milliseconds: 900));
    await _tapKey(tester, 'act0_shell_continue_cta');
    Act0LessonRunnerShellV1 current() =>
        tester.widget(find.byType(Act0LessonRunnerShellV1));
    final wrong = current().runner.options.firstWhere(
      (option) => !option.isCorrect,
    );
    await _tapKey(tester, 'act0_shell_option_${wrong.id}');
    expect(calls, ['HapticFeedbackType.lightImpact']);
    await _tapKey(tester, 'act0_shell_feedback_continue_cta');
    for (
      var step = 0;
      step < 5 && current().runner.activeTeachingStep != null;
      step++
    ) {
      await tester.pump(const Duration(milliseconds: 900));
      final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
      await _tapKey(
        tester,
        theory.evaluate().isNotEmpty
            ? 'act0_shell_theory_continue_cta'
            : 'act0_shell_continue_cta',
      );
    }
    final correct = current().runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    final optionKey = 'act0_shell_option_${correct.id}';
    await _tapKey(
      tester,
      find.byKey(Key(optionKey)).evaluate().isNotEmpty
          ? optionKey
          : 'act0_shell_seat_tap_${correct.seatId}',
    );
    expect(calls, [
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.lightImpact',
    ]);
    await _saved(tester);
    await tester.pumpWidget(const SizedBox.shrink());
  });

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
      expect(find.text('2 reviews due'), findsOneWidget);
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

  testWidgets('passing a retake clears only the old check reviews', (
    tester,
  ) async {
    usePhone(tester);
    final dueAt = _today.add(const Duration(days: 1));
    final lessonReview = Act0DurableRetentionFamilyV1(
      conceptFamilyId: 'hero_cards',
      worldId: 'world_1',
      sourceLessonId: 'what_poker_is',
      sourceTaskId: 'what_poker_is_find_hero',
      retentionState: Act0RetentionStateV1.recoveredPendingSpacedReview,
      nextDueAtUtc: dueAt,
      lastSpacedReviewAtUtc: null,
      spacedSuccessStage: 0,
      lapseCount: 0,
      incorrectCount: 1,
      correctCount: 1,
      lastRecordedAtUtc: _today,
      lastCreatedOrder: 2,
      lastSessionId: 'review-regression',
      lastReviewKind: Act0ReviewKindV1.immediateRepair,
      hasLegacyUnspacedEvidence: false,
    );
    SharedPreferences.setMockInitialValues({
      _progressKey: jsonEncode({
        'schemaVersion': 18,
        'completedTaskIds': ['what_poker_is_theory'],
        'completedLessonIds': [],
        'skippedTaskIds': [],
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'what_poker_is',
        'selectedTaskId': 'what_poker_is_find_hero',
        'earnedXp': 5,
        'durableRetentionHistory': [lessonReview.toPayload()],
      }),
    });
    await _mount(tester);

    Future<void> openSettingsCheck() async {
      await tester.tap(find.text('You').last);
      await tester.pumpAndSettle();
      await _tapKey(tester, 'act0_academy_you_leaf_settings');
      await tester.ensureVisible(
        find.byKey(const Key('act0_academy_settings_leaf_placement')),
      );
      await _tapKey(tester, 'act0_academy_settings_leaf_placement');
    }

    await openSettingsCheck();
    await _answerCheck(tester, 8);
    final failed = await _saved(tester);
    expect(failed['earnedXp'], 21);
    expect(failed['durableRetentionHistory'], hasLength(3));

    await tester.pumpWidget(const SizedBox.shrink());
    await _mount(tester, clock: _today.add(const Duration(hours: 1)));
    await openSettingsCheck();
    await _answerCheck(tester, 10);
    final passed = await _saved(tester);
    expect(passed['earnedXp'], 25);
    expect(passed['w1RulesFocusTaskIds'], isNull);
    expect(passed['durableRetentionHistory'], [lessonReview.toPayload()]);

    await tester.pumpWidget(const SizedBox.shrink());
    await _mount(tester, clock: _today.add(const Duration(hours: 25)));
    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('act0_academy_you_leaf_settings')),
    );
    await _tapKey(tester, 'act0_academy_you_leaf_settings');
    expect(find.text('Take the W1 rules check'), findsNothing);
    expect(find.text('Replay Welcome'), findsNothing);
    await _tapKey(tester, 'act0_academy_settings_leaf_back');
    final skills = find.byKey(const Key('act0_w14_skills'));
    await tester.ensureVisible(skills);
    await _tapKey(tester, 'act0_w14_skills');
    expect(find.text('Topics checked in the W1 rules check'), findsOneWidget);
    final topics = act0W1RulesQuestionsV1.map((item) => item.topic).toSet();
    expect(find.text(topics.join(' · ')), findsOneWidget);

    await tester.tap(find.text('Review').last);
    await tester.pumpAndSettle();
    expect(find.text('1 review due'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('act0_academy_review_leaf_start_due')),
    );
    await _tapKey(tester, 'act0_academy_review_leaf_start_due');
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      lessonReview.sourceTaskId,
    );
  });

  testWidgets('old saved progress opens without a W1 check', (tester) async {
    usePhone(tester);
    SharedPreferences.setMockInitialValues({
      _progressKey: jsonEncode({
        'schemaVersion': 18,
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
    expect(find.text('Your saved progress could not be read.'), findsNothing);
    expect(find.text('Learn'), findsWidgets);
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
