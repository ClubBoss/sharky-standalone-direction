import '../support/act0_source_choreography_test_wait_v1.dart';
import 'dart:async';
// SIMULATED normal production AppRoot journey on English iPhone 14 Pro.
// Uses current-main tasks only. Empty fake preferences are seeded once at boot.
// Widget remount/fake preferences do not prove native restart or Human learning.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show debugPrintSynchronously;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_first_start_preferences_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _progressKey = 'act0_shell_progress_v1';
const _source = 'what_poker_is_table_read_transfer';
const _mappedRepair = 'what_poker_is_table_read_recheck';
const _nextTask = 'first_table_guide_one_clear_choice';

void main() {
  testWidgets(
    'persistent render fault can go Back without losing learner state',
    (tester) async {
      await _openPendingHelpDecision(tester);
      final before = await _saved(tester);
      final learner = tester.state(find.byType(Act0ShellPreviewScreenV1));
      final navigator = Navigator.of(
        tester.element(find.byType(Act0LessonRunnerShellV1)),
      );
      unawaited(
        navigator.push<void>(
          PageRouteBuilder<void>(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => Builder(
              builder: (_) => throw StateError('persistent render fault'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isA<StateError>());
      expect(find.text('Please retry or go back.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isA<StateError>());
      expect(find.text('Something went wrong'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
      expect(
        tester.state(find.byType(Act0ShellPreviewScreenV1)),
        same(learner),
      );
      expect(_stableProgress(await _saved(tester)), _stableProgress(before));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'render Retry rebuilds the failed screen without replacing learner state',
    (tester) async {
      await _openPendingHelpDecision(tester);
      final before = await _saved(tester);
      final learner = tester.state(find.byType(Act0ShellPreviewScreenV1));
      var fail = true;
      final navigator = Navigator.of(
        tester.element(find.byType(Act0LessonRunnerShellV1)),
      );
      unawaited(
        navigator.push<void>(
          PageRouteBuilder<void>(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => Builder(
              builder: (_) {
                if (fail) throw StateError('synthetic render fault');
                return const Scaffold(body: Text('Recovered screen'));
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isA<StateError>());
      expect(find.text('Something went wrong'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Recovered screen'), findsOneWidget);
      expect(
        tester.state(
          find.byType(Act0ShellPreviewScreenV1, skipOffstage: false),
        ),
        same(learner),
      );
      final after = await _saved(tester);
      expect(_stableProgress(after), _stableProgress(before));
      expect(after['dailyPracticeQueue'], before['dailyPracticeQueue']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Practice finite set resumes after restart, ends, and explicitly restarts',
    (tester) async {
      await _openPendingHelpDecision(tester);
      await _choose(
        tester,
        _runner(tester).runner.options.firstWhere((o) => o.isCorrect).id,
      );
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      await _tap(tester, 'act0_shell_runner_back');
      await tester.tap(find.text('Practice').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_academy_practice_leaf_start');
      final first = _runner(tester).selectedTaskId;
      final baseline = await _saved(tester);
      final queue = baseline['dailyPracticeQueue'] as Map;
      final ids = (queue['taskIds'] as List).cast<String>();
      expect(ids.length, greaterThan(1));
      expect(ids.length, lessThanOrEqualTo(3));
      expect(ids.first, first);
      expect(_runner(tester).runner.beatIndex, 1);
      expect(_runner(tester).runner.beatCount, ids.length);
      await _choose(
        tester,
        _runner(tester).runner.options.firstWhere((o) => o.isCorrect).id,
      );
      final answered = await _saved(tester);
      expect((answered['dailyPracticeQueue'] as Map)['answeredTaskIds'], [
        first,
      ]);
      final earned = answered['earnedXp'];

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(() => _pendingWrites().flush());
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Practice').last);
      await tester.pumpAndSettle();
      expect(find.text('Resume practice'), findsOneWidget);
      await _tap(tester, 'act0_academy_practice_leaf_start');
      expect(_runner(tester).selectedTaskId, ids[1]);
      expect(_runner(tester).runner.beatIndex, 2);
      expect(_runner(tester).runner.beatCount, ids.length);
      final seen = <String>{first!};
      for (
        var step = 0;
        step < ids.length + 2 &&
            find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty;
        step++
      ) {
        final shell = _runner(tester);
        expect(
          seen.add(shell.selectedTaskId!),
          isTrue,
          reason: 'No repeated queue task',
        );
        await _choose(
          tester,
          shell.runner.options.firstWhere((o) => o.isCorrect).id,
        );
        if (find
            .byKey(const Key('act0_shell_feedback_continue_cta'))
            .evaluate()
            .isNotEmpty) {
          await _tap(tester, 'act0_shell_feedback_continue_cta');
        }
      }
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
      expect(seen, ids.toSet());
      expect(find.text('Start new set'), findsOneWidget);
      final finished = await _saved(tester);
      expect(finished['earnedXp'], earned);
      expect(finished['completedTaskIds'], answered['completedTaskIds']);
      expect((finished['dailyPracticeQueue'] as Map)['answeredTaskIds'], ids);
      await _tap(tester, 'act0_academy_practice_leaf_start');
      final restarted = await _saved(tester);
      expect(
        (restarted['dailyPracticeQueue'] as Map)['answeredTaskIds'],
        isEmpty,
      );
      expect(
        restarted['dailyCompletedRepCount'],
        finished['dailyCompletedRepCount'],
      );
      expect(restarted['earnedXp'], earned);
    },
  );

  testWidgets('W1 skill miss and its explanation survive an AppRoot remount', (
    tester,
  ) async {
    await _openPendingHelpDecision(tester);
    final wrong = _runner(
      tester,
    ).runner.options.firstWhere((option) => !option.isCorrect);
    await _choose(tester, wrong.id);
    final saved = await _saved(tester);

    Future<List<String>> readSkill() async {
      if (find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty) {
        await _tap(tester, 'act0_shell_runner_back');
      }
      await tester.tap(find.text('You').last);
      await tester.pumpAndSettle();
      final map = find.byKey(const Key('act0_w14_skills'));
      await tester.ensureVisible(map);
      await tester.tap(map);
      await tester.pumpAndSettle();
      final skill = find.byKey(const Key('act0_w14_skill_Table sense'));
      expect(skill, findsOneWidget);
      final text = tester
          .widgetList<Text>(
            find.descendant(of: skill, matching: find.byType(Text)),
          )
          .map((text) => text.data ?? '')
          .toList();
      expect(text, contains('Needs practice'));
      expect(text.join(' '), contains('Recent tasks to revisit: 1'));
      return text;
    }

    final before = await readSkill();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() => _pendingWrites().flush());
    await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
    await tester.pumpAndSettle();
    expect(await readSkill(), before);
    final restored = await _saved(tester);
    expect(restored['completedTaskIds'], saved['completedTaskIds']);
    expect(restored['earnedXp'], saved['earnedXp']);
    expect(
      restored['learningEvidenceHistory'],
      saved['learningEvidenceHistory'],
    );
  });

  for (final reducedMotion in [false, true]) {
    testWidgets(
      'SIMULATED semantic help lifecycle preserves truth with reducedMotion=$reducedMotion',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(
              accessibleNavigation: true,
              disableAnimations: reducedMotion,
              reduceMotion: reducedMotion,
            );
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await _openPendingHelpDecision(tester);
        final runnerContext = tester.element(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(MediaQuery.accessibleNavigationOf(runnerContext), isTrue);
        expect(MediaQuery.disableAnimationsOf(runnerContext), reducedMotion);
        final untouched = await _saved(tester);
        final options = _runner(tester).runner.options;

        Future<void> activate(String key, String label) async {
          final target = find.byKey(Key(key));
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          final node = tester.getSemantics(target);
          final data = node.getSemanticsData();
          expect(
            data.label.trim().isNotEmpty ? data.label : data.tooltip,
            label,
          );
          expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
          expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);
          expect(data.hasAction(SemanticsAction.tap), isTrue);
          node.owner!.performAction(node.id, SemanticsAction.tap);
          await tester.pumpAndSettle();
        }

        await activate('act0_shell_theory_recall_cta', 'Need a hint?');
        final hint = tester
            .widget<Text>(find.byKey(const Key('act0_shell_hint_body')))
            .data!;
        expect(hint.trim(), isNotEmpty);
        expect(find.bySemanticsLabel(hint), findsOneWidget);
        for (final option in options) {
          expect(
            find.byKey(Key('act0_shell_option_${option.id}')),
            findsNothing,
            reason: 'Hidden choices must not remain actionable through help.',
          );
        }
        await activate('act0_shell_review_full_idea_cta', 'Review full idea');
        for (final option in options) {
          expect(
            find.byKey(Key('act0_shell_option_${option.id}')),
            findsNothing,
            reason: 'Full Idea must not expose hidden answer actions.',
          );
        }
        final helpSurface = find.byKey(
          const Key('act0_shell_theory_recall_sheet'),
        );
        final helpTexts = find.descendant(
          of: helpSurface,
          matching: find.byType(Text),
        );
        final readableTexts = tester
            .widgetList<Text>(helpTexts)
            .where((text) => text.data?.trim().isNotEmpty == true)
            .map((text) => text.data!)
            .toList();
        expect(readableTexts, isNotEmpty);
        for (final text in readableTexts) {
          final rendered = find.descendant(
            of: helpSurface,
            matching: find.text(text),
          );
          await tester.ensureVisible(rendered);
          await tester.pumpAndSettle();
          expect(
            find.bySemanticsLabel(text),
            findsOneWidget,
            reason:
                'Every current full-idea paragraph/control needs readable semantics.',
          );
        }
        await activate('act0_shell_theory_recall_close_cta', 'Back to choices');
        expect(find.byKey(const Key('act0_shell_hint_body')), findsNothing);
        final closed = await _saved(tester);
        expect(
          _stableProgress(closed),
          _stableProgress(untouched),
          reason:
              'Help must preserve source/task, debt, completion, XP and evidence.',
        );
        for (final option in options) {
          final choice = find.byKey(Key('act0_shell_option_${option.id}'));
          await tester.ensureVisible(choice);
          await tester.pumpAndSettle();
          final data = tester.getSemantics(choice).getSemanticsData();
          expect(data.label, option.label);
          expect(data.hasAction(SemanticsAction.tap), isTrue);
        }
        final correct = options.singleWhere((option) => option.isCorrect);
        await activate('act0_shell_option_${correct.id}', correct.label);
        final rows = _rows(
          await _saved(tester),
          'learningEvidenceHistory',
        ).where((row) => row['taskId'] == _source).toList();
        expect(rows, hasLength(1));
        expect(rows.single['choiceId'], correct.id);
        expect(rows.single['assistanceKind'], 'theoryRecall');
        expect(
          _runner(tester).runner.reviewQuality,
          Act0FeedbackQualityV1.correct,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('the task honors larger text without scaling table labels', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.65;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _openPendingHelpDecision(tester);
    final runner = _runner(tester).runner;
    final question = find.byKey(const Key('act0_integrated_scene_prompt'));
    final plate = find.byKey(const Key('act0_shell_seat_node_btn'));
    final seatLabel = find.descendant(of: plate, matching: find.text('You'));
    expect(find.text('BTN'), findsNothing);
    expect(find.text('UTG'), findsNothing);
    expect(find.text('Player'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_learning_scene_sharky_avatar')),
      findsNothing,
    );
    final wrong = runner.options.firstWhere((option) => !option.isCorrect);
    final answer = find.descendant(
      of: find.byKey(Key('act0_shell_option_${wrong.id}')),
      matching: find.text(wrong.label),
    );

    void expectScale(Finder text, double size) {
      final paragraph = tester.renderObject<RenderParagraph>(text);
      expect(paragraph.textScaler.scale(10), closeTo(size, 0.001));
      expect(paragraph.didExceedMaxLines, isFalse);
    }

    expectScale(question, 13);
    expectScale(answer, 13);
    expectScale(seatLabel, 10);
    await _choose(tester, wrong.id);
    expectScale(find.byKey(const Key('act0_shell_review_question')), 13);
    expectScale(find.byKey(const Key('act0_learning_scene_v3_support')), 13);
    await _expectFeedbackClearance(tester);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets(
      'The longest authored W1–W4 reason can be read with CTA pinned at $scale×',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);

        final choices = [
          for (final number in [1, 2, 3, 4])
            for (final lesson
                in Act0ShellStateV1.sample.worldById('world_$number').lessons)
              for (final task in lesson.taskList)
                for (final option in task.runner.options)
                  (number: number, lesson: lesson, task: task, option: option),
        ];
        final longest = choices.reduce(
          (a, b) =>
              a.option.feedbackReason.length >= b.option.feedbackReason.length
              ? a
              : b,
        );
        final runner = longest.task.runner.copyWith(
          phase: Act0LessonPhaseV1.review,
          selectedOptionId: longest.option.id,
          teachingStepIndex: longest.task.runner.teachingSteps.length,
        );
        var continued = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: runner,
                worldNumber: longest.number,
                selectedWorldId: 'world_${longest.number}',
                selectedLessonId: longest.lesson.lessonId,
                selectedTaskId: longest.task.taskId,
                selectedTaskFamily: longest.task.resolvedTaskFamily,
                compositionFamily: longest.task.resolvedCompositionFamily,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () => continued = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final question = find.byKey(const Key('act0_shell_review_question'));
        final reason = find.byKey(const Key('act0_learning_scene_v3_support'));
        final viewport = find.byKey(
          const Key('act0_shell_feedback_guide_viewport'),
        );
        final next = find.byKey(const Key('act0_shell_feedback_continue_cta'));
        final initialButtonRect = tester.getRect(next);
        expect(question.hitTestable(), findsOneWidget);
        expect(tester.widget<Text>(reason).data, runner.reviewReason.trim());
        expect(tester.widget<Text>(reason).maxLines, isNull);
        expect(
          tester.getRect(viewport).contains(tester.getTopLeft(reason)),
          isTrue,
        );
        final reasonText = tester.renderObject<RenderParagraph>(reason);
        final reasonLength = reasonText.text.toPlainText().length;
        final lastLine = reasonText
            .getBoxesForSelection(
              TextSelection(
                baseOffset: reasonLength - 1,
                extentOffset: reasonLength,
              ),
            )
            .last;
        Offset lastLineCenter() =>
            reasonText.localToGlobal(lastLine.toRect().center);
        expect(tester.getRect(viewport).contains(lastLineCenter()), isFalse);
        await Scrollable.ensureVisible(tester.element(reason), alignment: 1);
        await tester.pumpAndSettle();
        expect(tester.getRect(viewport).contains(lastLineCenter()), isTrue);
        expect(tester.getRect(next), initialButtonRect);
        expect(question.hitTestable(), findsOneWidget);
        await tester.tap(next);
        expect(continued, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('a second miss can continue the lesson without earning XP', (
    tester,
  ) async {
    await _openPendingHelpDecision(tester);
    final initial = await _saved(tester);
    await _choose(tester, 'five_board_now');
    expect(find.text('Continue lesson'), findsNothing);
    await _tap(tester, 'act0_shell_feedback_continue_cta');
    await _advanceToPrompt(tester);
    expect(_runner(tester).selectedTaskId, _source);
    expect(find.textContaining('Extra practice'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() => _pendingWrites().flush());
    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();
    if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_current_mission_cta');
      await _advanceToPrompt(tester);
    }
    expect(_runner(tester).selectedTaskId, _source);
    expect(find.textContaining('Extra practice'), findsWidgets);

    await _choose(tester, 'five_board_now');
    expect(find.text('Continue lesson'), findsOneWidget);
    await _tap(tester, 'act0_shell_feedback_continue_cta');
    expect(_runner(tester).selectedTaskId, _mappedRepair);
    final saved = await _saved(tester);
    expect(saved['earnedXp'], initial['earnedXp']);
    expect(saved['completedTaskIds'], isNot(contains(_source)));
    expect(saved['skippedTaskIds'], contains(_source));
    expect(
      _rows(saved, 'openRepairIntents').map((row) => row['sourceTaskId']),
      contains(_source),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a second miss can launch a different authored example', (
    tester,
  ) async {
    await _openPendingHelpDecision(tester);
    final saved = await _saved(tester);
    final world = Act0ShellStateV1.sample.worldById('world_1');
    const lessonId = 'what_poker_is_content';
    const firstId = 'what_poker_is_review';
    const otherId = 'what_poker_is_live_win_transfer';
    final precedingLessons = world.lessons
        .takeWhile((lesson) => lesson.lessonId != lessonId)
        .toList();
    final lesson = world.lessons.singleWhere(
      (lesson) => lesson.lessonId == lessonId,
    );
    final task = lesson.courseTaskList.singleWhere(
      (task) => task.taskId == firstId,
    );
    await _replaceCheckpointFixture(tester, {
      ...saved,
      'completedTaskIds': [
        for (final previous in precedingLessons)
          for (final task in previous.courseTaskList) task.taskId,
        for (final item in lesson.courseTaskList.takeWhile(
          (item) => item.taskId != firstId,
        ))
          item.taskId,
      ],
      'completedLessonIds': [
        for (final previous in precedingLessons) previous.lessonId,
      ],
      'selectedWorldId': world.worldId,
      'selectedLessonId': lessonId,
      'selectedTaskId': firstId,
      'resumeInRunner': true,
      'resumePhase': 'drill',
      'resumeTeachingStepIndex': task.runner.teachingSteps.length,
    });
    if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_current_mission_cta');
    }
    await _advanceToPrompt(tester);
    expect(_runner(tester).selectedTaskId, firstId);
    final wrong = _runner(tester).runner.options.firstWhere(
      (option) => option.quality == Act0FeedbackQualityV1.wrong,
    );
    await _choose(tester, wrong.id);
    await _tap(tester, 'act0_shell_feedback_continue_cta');
    await _advanceToPrompt(tester);
    expect(_runner(tester).selectedTaskId, firstId);
    final retryWrong = _runner(tester).runner.options.firstWhere(
      (option) => option.quality == Act0FeedbackQualityV1.wrong,
    );
    await _choose(tester, retryWrong.id);
    expect(find.text('Continue lesson'), findsOneWidget);
    await _tap(tester, 'act0_shell_feedback_another_example');
    await _advanceToPrompt(tester);
    expect(_runner(tester).selectedTaskId, otherId);
    expect(find.textContaining('Extra practice'), findsOneWidget);
    final duringExample = await _saved(tester);
    expect(duringExample['selectedTaskId'], firstId);
    expect(duringExample['earnedXp'], saved['earnedXp']);
    final exampleAnswer = _runner(
      tester,
    ).runner.options.singleWhere((option) => option.isCorrect);
    await _choose(tester, exampleAnswer.id);
    await _tap(tester, 'act0_shell_feedback_continue_cta');
    final completed = await _saved(tester);
    expect(completed['earnedXp'], saved['earnedXp']);
    expect(completed['skippedTaskIds'], contains(firstId));
    expect(completed['completedTaskIds'], isNot(contains(firstId)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an independent replay earns deferred XP once after restart', (
    tester,
  ) async {
    await _openPendingHelpDecision(tester);
    final initial = await _saved(tester);
    await _tap(tester, 'act0_shell_theory_recall_cta');
    await _tap(tester, 'act0_shell_review_full_idea_cta');
    await _tap(tester, 'act0_shell_theory_recall_close_cta');
    await _choose(tester, 'two_three_six');
    await _tap(tester, 'act0_shell_feedback_continue_cta');
    final helped = await _saved(tester);
    expect(helped['earnedXp'], initial['earnedXp']);
    expect(helped['completedTaskIds'], contains(_source));
    expect(helped['tasksWithDeferredXp'], contains(_source));

    await _remount(tester);
    await _replayTableReadForXpV1(tester);
    final independentlyEarned = await _saved(tester);
    final reward = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .first
        .courseTaskList
        .singleWhere((task) => task.taskId == _source)
        .rewardXp;
    expect(
      independentlyEarned['earnedXp'],
      (initial['earnedXp'] as int) + reward,
    );
    expect(independentlyEarned['tasksWithDeferredXp'], isNull);

    await _remount(tester);
    await _replayTableReadForXpV1(tester);
    expect((await _saved(tester))['earnedXp'], independentlyEarned['earnedXp']);

    final legacyPaid = Map<String, dynamic>.from(helped)
      ..remove('tasksWithDeferredXp')
      ..['earnedXp'] = independentlyEarned['earnedXp'];
    await _replaceCheckpointFixture(tester, legacyPaid);
    await _replayTableReadForXpV1(tester);
    expect((await _saved(tester))['earnedXp'], legacyPaid['earnedXp']);
    expect(tester.takeException(), isNull);
  });

  for (final feedbackCase in ['assisted', 'wrong', 'correct']) {
    testWidgets(
      'SIMULATED feedback clears visible source seats and keeps continuation usable - $feedbackCase',
      (tester) async {
        tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);
        await _openPendingHelpDecision(tester);
        final avatar = find.byKey(
          const Key('act0_shell_learning_scene_sharky_avatar'),
        );
        expect(avatar, findsNothing);
        if (feedbackCase == 'assisted') {
          await _tap(tester, 'act0_shell_theory_recall_cta');
          await _tap(tester, 'act0_shell_review_full_idea_cta');
          await _tap(tester, 'act0_shell_theory_recall_close_cta');
        }
        final options = _runner(tester).runner.options;
        final answer = feedbackCase == 'wrong'
            ? options.singleWhere((o) => o.id == 'five_board_now')
            : options.singleWhere((o) => o.isCorrect);
        final originalQuestion = tester
            .widget<Text>(find.byKey(const Key('act0_integrated_scene_prompt')))
            .data;
        await _choose(tester, answer.id);
        final question = find.byKey(const Key('act0_shell_review_question'));
        expect(question.hitTestable(), findsOneWidget);
        expect(tester.widget<Text>(question).data, originalQuestion);
        expect(avatar.hitTestable(), findsOneWidget);
        expect(tester.getSize(avatar), const Size.square(56));
        final ring =
            tester.widget<Container>(avatar).decoration as BoxDecoration;
        expect(ring.shape, BoxShape.circle);
        expect((ring.border as Border).top.color, switch (feedbackCase) {
          'wrong' => Act0ShellTokensV1.repairAttention,
          'assisted' => Act0ShellTokensV1.info,
          _ => Act0ShellTokensV1.successProof,
        });
        final reason = find.byKey(const Key('act0_learning_scene_v3_support'));
        expect(
          tester.getRect(avatar).right,
          lessThan(tester.getRect(reason).left),
        );

        await _expectFeedbackClearance(tester);
        final record = _rows(
          await _saved(tester),
          'learningEvidenceHistory',
        ).lastWhere((row) => row['taskId'] == _source);
        expect(record['choiceId'], answer.id);
        expect(
          record['assistanceKind'],
          feedbackCase == 'assisted' ? 'theoryRecall' : 'none',
        );
        if (feedbackCase == 'wrong') {
          await _tap(tester, 'act0_shell_feedback_continue_cta');
          // Continue launches one familiar rehearsal of the same table read.
          expect(_runner(tester).selectedTaskId, _source);
          expect(_runner(tester).repairResultReceiptLine, isNull);
          await _advanceToPrompt(tester);
          expect(avatar, findsNothing);
          expect(
            tester
                .widget<Text>(
                  find.byKey(const Key('act0_integrated_scene_prompt')),
                )
                .data,
            originalQuestion,
          );
          await _choose(tester, 'two_three_six');
          await _expectFeedbackClearance(tester);
          await _tap(tester, 'act0_shell_feedback_continue_cta');
          expect(_runner(tester).selectedTaskId, _mappedRepair);
          await _advanceToPrompt(tester);
          expect(avatar, findsNothing);
          await _choose(tester, 'two_three_four');
          await _expectFeedbackClearance(tester);
        } else if (feedbackCase == 'correct') {
          await _tap(tester, 'act0_shell_feedback_continue_cta');
          expect(_runner(tester).selectedTaskId, _mappedRepair);
          await _advanceToPrompt(tester);
          expect(avatar, findsNothing);
          await _choose(tester, 'two_three_four');
          await _expectFeedbackClearance(tester);
          await _tap(tester, 'act0_shell_feedback_continue_cta');
          expect(_runner(tester).selectedTaskId, _nextTask);
          await _advanceToPrompt(tester);
          expect(avatar, findsNothing);
          await _choose(tester, 'co_still_acting');
          expect(
            _runner(tester).runner.reviewQuality,
            Act0FeedbackQualityV1.wrong,
          );
          await _expectFeedbackClearance(tester);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'SIMULATED Full Idea has a reachable 48px target and restores choices',
    (tester) async {
      await _openPendingHelpDecision(tester);
      final untouched = await _saved(tester);
      await _tap(tester, 'act0_shell_theory_recall_cta');
      final full = find.byKey(const Key('act0_shell_review_full_idea_cta'));
      await tester.ensureVisible(full);
      await tester.pumpAndSettle();
      final fullRect = tester.getRect(full);
      const viewport = Rect.fromLTWH(0, 0, 393, 852);
      expect(fullRect.width, greaterThanOrEqualTo(48));
      expect(fullRect.height, greaterThanOrEqualTo(48));
      expect(viewport.contains(fullRect.topLeft), isTrue);
      expect(
        viewport.contains(fullRect.bottomRight - const Offset(0.01, 0.01)),
        isTrue,
      );
      expect(full.hitTestable(), findsOneWidget);
      await tester.tapAt(Offset(fullRect.center.dx, fullRect.top + 3));
      await tester.pumpAndSettle();
      expect(full, findsNothing);
      expect(
        find.byKey(const Key('act0_shell_theory_recall_title')),
        findsOneWidget,
      );
      final close = find.byKey(const Key('act0_shell_theory_recall_close_cta'));
      await tester.ensureVisible(close);
      await tester.pumpAndSettle();
      final closeRect = tester.getRect(close);
      expect(closeRect.height, greaterThanOrEqualTo(48));
      await tester.tapAt(Offset(closeRect.center.dx, closeRect.bottom - 3));
      await tester.pumpAndSettle();
      final closed = await _saved(tester);
      for (final field in [
        'earnedXp',
        'completedTaskIds',
        'learningEvidenceHistory',
      ]) {
        expect(closed[field], untouched[field]);
      }
      final options = _runner(tester).runner.options;
      for (final option in options) {
        final choice = find.byKey(Key('act0_shell_option_${option.id}'));
        await tester.ensureVisible(choice);
        await tester.pumpAndSettle();
        expect(choice.hitTestable(), findsOneWidget);
      }
      final answer = options.singleWhere((option) => option.isCorrect);
      await _choose(tester, answer.id);
      final record = _rows(
        await _saved(tester),
        'learningEvidenceHistory',
      ).lastWhere((row) => row['taskId'] == _source);
      expect(record['choiceId'], answer.id);
      expect(record['assistanceKind'], 'theoryRecall');
      expect(tester.takeException(), isNull);
    },
  );

  for (final mode in ['ack', 'failure', 'lowStorage', 'navigation', 'reset']) {
    testWidgets('SIMULATED help waits for durable marker: $mode', (
      tester,
    ) async {
      await _openPendingHelpDecision(tester);
      final original = SharedPreferencesStorePlatform.instance;
      final disk = _HelpWriteGate(original);
      SharedPreferencesStorePlatform.instance = disk;
      addTearDown(() async {
        disk.failWrites = false;
        disk.outOfSpace = false;
        disk.release();
        await tester.runAsync(() async {
          await _pendingWrites().flush().timeout(const Duration(seconds: 2));
        });
        SharedPreferencesStorePlatform.instance = original;
      });
      final untouched = await _saved(tester);
      if (mode == 'failure') {
        disk.failWrites = true;
      } else if (mode == 'lowStorage') {
        disk.outOfSpace = true;
      } else {
        disk.holdNext = true;
      }
      await tester.tap(find.byKey(const Key('act0_shell_theory_recall_cta')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_hint_body')),
        findsNothing,
        reason: 'Unacknowledged help must not be exposed.',
      );
      if (mode == 'failure' || mode == 'lowStorage') {
        expect(
          find.text('Help could not be saved. Please try again.'),
          findsOneWidget,
        );
        disk.failWrites = false;
        if (mode == 'lowStorage') {
          final failed = await _saved(tester);
          expect(_stableProgress(failed), _stableProgress(untouched));
          expect(
            find.text(
              'Progress save not confirmed. Keep Sharky open and retry.',
            ),
            findsOneWidget,
          );
          disk.outOfSpace = false;
          await _tap(tester, 'act0_progress_save_retry');
          final recovered = await _saved(tester);
          expect(_stableProgress(recovered), _stableProgress(untouched));
          expect(
            find.byKey(const Key('act0_progress_save_notice')),
            findsNothing,
          );
        }
        final answer = _runner(
          tester,
        ).runner.options.singleWhere((o) => o.isCorrect);
        await _choose(tester, answer.id);
        final record = _rows(
          await _saved(tester),
          'learningEvidenceHistory',
        ).lastWhere((entry) => entry['taskId'] == _source);
        expect(
          Act0LearningEvidenceRecordV1.tryParse(record)!.assistanceKind,
          Act0DecisionAssistanceV1.legacyUnknown,
        );
        return;
      }
      expect(
        disk.held,
        isNotNull,
        reason: 'The real production writer must reach the blocked backend.',
      );
      if (mode == 'ack') {
        final answer = _runner(
          tester,
        ).runner.options.singleWhere((o) => o.isCorrect);
        await _choose(tester, answer.id);
        expect(
          _runner(tester).runner.selectedOptionId,
          isNull,
          reason: 'Grading is blocked while the help transaction is pending.',
        );
        disk.release();
        await tester.runAsync(() async {
          await _pendingWrites().flush();
        });
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('act0_shell_hint_body')), findsOneWidget);
        final saved = await _saved(tester);
        expect(
          saved['learningEvidenceHistory'],
          untouched['learningEvidenceHistory'],
        );
        expect(saved['earnedXp'], untouched['earnedXp']);
        expect(
          _rows(saved, 'pendingDecisionAssistance').single['assistanceKind'],
          'quickHint',
        );
      } else {
        await _tap(tester, 'act0_shell_runner_back');
        await tester.tap(find.text('Home').last);
        await tester.pumpAndSettle();
        if (mode == 'reset') {
          await tester.tap(find.byTooltip('Dev menu'));
          await tester.pumpAndSettle();
          await _tap(tester, 'act0_shell_dev_menu_reset_progress');
          await tester.tap(
            find.byKey(const Key('act0_shell_dev_menu_reset_confirm')),
          );
          await tester.pumpAndSettle();
        }
        disk.release();
        await tester.runAsync(() async {
          await _pendingWrites().flush();
        });
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('act0_shell_hint_body')),
          findsNothing,
          reason: 'A late acknowledgement cannot reopen help after leaving.',
        );
        if (mode == 'reset') {
          expect(find.text('Find my start'), findsOneWidget);
          await _tap(tester, 'act0_shell_placement_skip_intro');
          final zero = await _saved(tester);
          expect(zero['earnedXp'], 0);
          expect(zero['learningEvidenceHistory'], isEmpty);
          expect(zero['pendingDecisionAssistance'], isEmpty);
        } else {
          await _tap(tester, 'act0_academy_home_leaf_cta');
          await _advanceToPrompt(tester);
          final answer = _runner(
            tester,
          ).runner.options.singleWhere((o) => o.isCorrect);
          await _choose(tester, answer.id);
          final record = _rows(
            await _saved(tester),
            'learningEvidenceHistory',
          ).lastWhere((entry) => entry['taskId'] == _source);
          expect(
            Act0LearningEvidenceRecordV1.tryParse(record)!.assistanceKind,
            Act0DecisionAssistanceV1.legacyUnknown,
          );
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('SIMULATED source identity change cannot carry old local help', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((l) => l.lessonId == 'what_poker_is')
        .taskList
        .firstWhere((t) => t.taskId == _source);
    final decisions = <Act0CompletedDecisionV1>[];
    // Deliberately collide all runner metadata; this tests identity isolation,
    // not the authored grading of the synthetic second source.
    Widget host(String sourceId) => MaterialApp(
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          key: const ValueKey('same-runner-state'),
          runner: task.runner.copyWith(
            phase: Act0LessonPhaseV1.drill,
            teachingStepIndex: task.runner.teachingSteps.length,
          ),
          selectedWorldId: 'world_1',
          selectedLessonId: 'what_poker_is',
          selectedTaskId: sourceId,
          selectedTaskFamily: task.resolvedTaskFamily,
          compositionFamily: task.resolvedCompositionFamily,
          theoryRecallStep: task.runner.teachingSteps.last,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onCompletedDecision: decisions.add,
          onContinueReview: () {},
        ),
      ),
    );
    await tester.pumpWidget(host(_source));
    await tester.pumpAndSettle();
    await _tap(tester, 'act0_shell_theory_recall_cta');
    await _tap(tester, 'act0_shell_theory_recall_close_cta');
    await tester.pumpWidget(host('policy_new_source'));
    await tester.pumpAndSettle();
    final answer = _runner(
      tester,
    ).runner.options.singleWhere((o) => o.isCorrect);
    await _choose(tester, answer.id);
    expect(decisions, hasLength(1));
    expect(decisions.single.taskId, 'policy_new_source');
    expect(decisions.single.assistanceKind, Act0DecisionAssistanceV1.none);
    expect(tester.takeException(), isNull);
  });

  for (final scenario in const [
    (route: 'back', exposure: 'quickHint'),
    (route: 'remount', exposure: 'quickHint'),
    (route: 'back', exposure: 'theoryRecall'),
    (route: 'remount', exposure: 'theoryRecall'),
    (route: 'remount', exposure: 'fullThenQuick'),
    (route: 'remount', exposure: 'none'),
  ]) {
    testWidgets(
      'SIMULATED pending help ${scenario.exposure} survives ${scenario.route} before answer',
      (tester) async {
        await _openPendingHelpDecision(tester);
        final untouched = await _saved(tester);
        if (scenario.exposure != 'none') {
          await _tap(tester, 'act0_shell_theory_recall_cta');
          if (scenario.exposure != 'quickHint') {
            await _tap(tester, 'act0_shell_review_full_idea_cta');
          }
          await _tap(tester, 'act0_shell_theory_recall_close_cta');
          if (scenario.exposure == 'fullThenQuick') {
            await _tap(tester, 'act0_shell_theory_recall_cta');
            await _tap(tester, 'act0_shell_theory_recall_close_cta');
          }
        }
        final exposed = await _saved(tester);
        for (final field in [
          'earnedXp',
          'completedTaskIds',
          'learningEvidenceHistory',
        ]) {
          expect(
            exposed[field],
            untouched[field],
            reason: 'Opening assistance is not a completed decision.',
          );
        }
        if (scenario.route == 'back') {
          await _tap(tester, 'act0_shell_runner_back');
          await tester.tap(find.text('Home').last);
          await tester.pumpAndSettle();
        } else {
          await _remount(tester);
        }
        await _tap(tester, 'act0_academy_home_leaf_cta');
        await _advanceToPrompt(tester);
        expect(_runner(tester).selectedTaskId, _source);
        final answer = _runner(
          tester,
        ).runner.options.singleWhere((o) => o.isCorrect);
        await _choose(tester, answer.id);
        final answered = await _saved(tester);
        final record = _rows(
          answered,
          'learningEvidenceHistory',
        ).lastWhere((entry) => entry['taskId'] == _source);
        final expected = scenario.exposure == 'fullThenQuick'
            ? 'theoryRecall'
            : scenario.exposure;
        expect(record['choiceId'], answer.id);
        expect(record['assistanceKind'], expected);
        expect(
          _rows(
            answered,
            'pendingDecisionAssistance',
          ).where((entry) => entry['taskId'] == _source),
          isEmpty,
          reason: 'Only the recorded decision consumes its pending help.',
        );
        await _tap(tester, 'act0_shell_feedback_continue_cta');
        await _advanceToTask(tester, _nextTask);
        await _advanceToPrompt(tester);
        final nextAnswer = _runner(
          tester,
        ).runner.options.singleWhere((o) => o.isCorrect);
        await _choose(tester, nextAnswer.id);
        final next = _rows(
          await _saved(tester),
          'learningEvidenceHistory',
        ).lastWhere((entry) => entry['taskId'] == _nextTask);
        expect(
          next['assistanceKind'],
          'none',
          reason: 'Prior task help must not taint a distinct new decision.',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final variant in ['legacy19', 'sourceMismatch', 'boundaryMismatch']) {
    testWidgets('SIMULATED pending help $variant is not independent', (
      tester,
    ) async {
      await _openPendingHelpDecision(tester);
      await _tap(tester, 'act0_shell_theory_recall_cta');
      await _tap(tester, 'act0_shell_theory_recall_close_cta');
      final payload = await _saved(tester);
      if (variant == 'legacy19') {
        payload['schemaVersion'] = 19;
        payload.remove('pendingDecisionAssistance');
      } else {
        final pending = _rows(payload, 'pendingDecisionAssistance');
        expect(pending, hasLength(1));
        if (variant == 'sourceMismatch') {
          pending.single['fingerprint'] = 'obsolete-source';
        } else {
          pending.single['afterSourceOrder'] =
              (pending.single['afterSourceOrder'] as int) + 1;
        }
        payload['pendingDecisionAssistance'] = pending;
      }
      await _replaceCheckpointFixture(tester, payload);
      await _tap(tester, 'act0_academy_home_leaf_cta');
      await _advanceToPrompt(tester);
      expect(_runner(tester).selectedTaskId, _source);
      final answer = _runner(
        tester,
      ).runner.options.singleWhere((o) => o.isCorrect);
      await _choose(tester, answer.id);
      final record = _rows(
        await _saved(tester),
        'learningEvidenceHistory',
      ).lastWhere((entry) => entry['taskId'] == _source);
      expect(
        Act0LearningEvidenceRecordV1.tryParse(record)!.assistanceKind,
        Act0DecisionAssistanceV1.legacyUnknown,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final variant in ['missing', 'null', 'duplicate', 'unknownKind']) {
    testWidgets('SIMULATED malformed pending help $variant fails closed', (
      tester,
    ) async {
      await _openPendingHelpDecision(tester);
      await _tap(tester, 'act0_shell_theory_recall_cta');
      await _tap(tester, 'act0_shell_theory_recall_close_cta');
      final payload = await _saved(tester);
      final pending = _rows(payload, 'pendingDecisionAssistance');
      expect(pending, hasLength(1));
      switch (variant) {
        case 'missing':
          payload.remove('pendingDecisionAssistance');
        case 'null':
          payload['pendingDecisionAssistance'] = null;
        case 'duplicate':
          payload['pendingDecisionAssistance'] = [
            pending.single,
            pending.single,
          ];
        case 'unknownKind':
          pending.single['assistanceKind'] = 'invented';
          payload['pendingDecisionAssistance'] = pending;
      }
      await _replaceCheckpointFixture(tester, payload);
      expect(find.byKey(const Key('act0_recovery_options')), findsOneWidget);
      expect(
        find.byType(Act0LessonRunnerShellV1),
        findsNothing,
        reason: 'Malformed provenance cannot silently become unassisted.',
      );
    });
  }

  testWidgets('unreadable first-start preference offers a retry', (
    tester,
  ) async {
    const welcomeKey = 'act0_welcome_completed_v1';
    SharedPreferences.setMockInitialValues(<String, Object>{
      welcomeKey: 'unreadable fixture',
    });
    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    final error = find.text('Sharky could not finish starting.');
    expect(error, findsOneWidget);
    expect(find.text('Recovery options'), findsNothing);
    await _tap(tester, 'act0_recovery_retry');
    expect(error, findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.get(welcomeKey), 'unreadable fixture');
    expect(prefs.getString(_progressKey), isNull);
    await prefs.setBool(welcomeKey, false);
    await _tap(tester, 'act0_recovery_retry');
    expect(error, findsNothing);
    expect(find.text('Start with the basics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'SIMULATED JRN-08 AppRoot retry preserves complete learning truth',
    (tester) async {
      await _openPendingHelpDecision(tester);
      await _tap(tester, 'act0_shell_theory_recall_cta');
      await _tap(tester, 'act0_shell_theory_recall_close_cta');
      final correct = _runner(
        tester,
      ).runner.options.singleWhere((option) => option.isCorrect);
      await _choose(tester, correct.id);
      final earned = await _saved(tester);
      expect(earned['earnedXp'], greaterThan(0));
      expect(earned['learningEvidenceHistory'], isNotEmpty);
      expect(earned['learningEvidenceLineage'], isNotEmpty);
      final sourceRecord = _rows(
        earned,
        'learningEvidenceHistory',
      ).lastWhere((row) => row['taskId'] == _source);
      expect(sourceRecord['choiceId'], correct.id);
      expect(sourceRecord['assistanceKind'], 'quickHint');

      const unrelatedKey = 'jrn08_mock_unrelated_setting';
      const checkpointKeys = <String>[
        _progressKey,
        '${_progressKey}_head',
        '${_progressKey}_recovery',
        '${_progressKey}_backup',
      ];
      Future<Map<String, Object>> mockValues() async {
        late Map<String, Object> values;
        await tester.runAsync(() async {
          await _pendingWrites().flush().timeout(const Duration(seconds: 2));
          final prefs = await SharedPreferences.getInstance();
          await prefs.reload();
          values = {for (final key in prefs.getKeys()) key: prefs.get(key)!};
        });
        return values;
      }

      await tester.runAsync(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(unrelatedKey, 'keep-existing-setting');
      });
      final validValues = await mockValues();
      final validCheckpoint = {
        for (final key in checkpointKeys) key: validValues[key]! as String,
      };
      final unrelatedValues = {
        for (final entry in validValues.entries)
          if (!entry.key.startsWith(_progressKey)) entry.key: entry.value,
      };

      // Existing in-memory corruption fixture; no native preferences or files.
      final malformed = jsonDecode(jsonEncode(earned)) as Map<String, dynamic>;
      malformed['pendingDecisionAssistance'] = null;
      await _replaceCheckpointFixture(tester, malformed);
      const unreadable = 'Your saved progress could not be read.';
      expect(find.text(unreadable), findsOneWidget);
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
      final damagedValues = await mockValues();
      await _tap(tester, 'act0_recovery_retry');
      expect(find.text(unreadable), findsOneWidget);
      expect(await mockValues(), damagedValues);
      await _tap(tester, 'act0_recovery_options');
      await _tap(tester, 'act0_recovery_cancel');
      expect(await mockValues(), damagedValues);

      // Restore only the captured fake checkpoint while AppRoot stays mounted.
      // Actual Retry must reload it; remount is not a substitute for that action.
      await tester.runAsync(() async {
        final prefs = await SharedPreferences.getInstance();
        for (final entry in validCheckpoint.entries) {
          await prefs.setString(entry.key, entry.value);
        }
      });
      await _tap(tester, 'act0_recovery_retry');
      expect(find.text(unreadable), findsNothing);
      final recovered = await _saved(tester);
      expect(_stableProgress(recovered), _stableProgress(earned));
      expect(
        recovered['pendingDecisionAssistance'],
        earned['pendingDecisionAssistance'],
      );
      expect(
        find.byKey(const Key('act0_academy_home_leaf_cta')),
        findsOneWidget,
      );

      await _remount(tester);
      final remounted = await _saved(tester);
      expect(_stableProgress(remounted), _stableProgress(earned));
      expect(
        remounted['pendingDecisionAssistance'],
        earned['pendingDecisionAssistance'],
      );
      final finalValues = await mockValues();
      expect({
        for (final entry in finalValues.entries)
          if (!entry.key.startsWith(_progressKey)) entry.key: entry.value,
      }, unrelatedValues);
      expect(find.text(unreadable), findsNothing);
      expect(
        find.byKey(const Key('act0_academy_home_leaf_cta')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'SIMULATED main AppRoot Back: pending choice and saved miss remain intact',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await _pendingWrites().flush().timeout(const Duration(seconds: 2));
        });
      });
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_placement_skip_intro');
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_current_mission_cta');
      await _advanceToTask(tester, _source);
      await _advanceToPrompt(tester);
      final back = find.byKey(const Key('act0_shell_runner_back'));
      expect(tester.getSemantics(back).getSemanticsData().tooltip, 'Back');
      expect(tester.getSize(back).width, greaterThanOrEqualTo(44));
      expect(tester.getSize(back).height, greaterThanOrEqualTo(44));
      final pending = await _saved(tester);
      await _tap(tester, 'act0_shell_runner_back');
      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_academy_home_leaf_cta');
      expect(_runner(tester).selectedTaskId, _source);
      expect(_runner(tester).runner.phase, Act0LessonPhaseV1.drill);
      expect(_stableProgress(await _saved(tester)), _stableProgress(pending));
      await _advanceToPrompt(tester);
      await _choose(tester, 'five_board_now');
      final missed = await _saved(tester);
      expect(_runner(tester).runner.selectedOptionId, 'five_board_now');
      expect(_runner(tester).runner.phase, Act0LessonPhaseV1.review);
      await _tap(tester, 'act0_shell_runner_back');
      expect(_stableProgress(await _saved(tester)), _stableProgress(missed));
      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();
      // Launching from Home keeps the original miss and the earned progress.
      await _tap(tester, 'act0_academy_home_leaf_cta');
      expect(_runner(tester).selectedTaskId, _source);
      expect(_runner(tester).runner.selectedOptionId, 'five_board_now');
      expect(_runner(tester).runner.phase, Act0LessonPhaseV1.review);
      final resumed = await _saved(tester);
      expect(resumed['earnedXp'], missed['earnedXp']);
      expect(
        resumed['learningEvidenceHistory'],
        missed['learningEvidenceHistory'],
      );
      expect(resumed['completedTaskIds'], missed['completedTaskIds']);
      expect(resumed['openRepairIntents'], missed['openRepairIntents']);
      final intent = _rows(
        resumed,
        'openRepairIntents',
      ).singleWhere((row) => row['sourceTaskId'] == _source);
      expect(intent['mappingType'], 'intentional_exact');
      expect(intent['targetTaskId'], _source);
      expect(intent['repairOccurrenceId'], isNotEmpty);
      expect(_rows(resumed, 'repairOutcomeProjection'), isEmpty);

      await _tap(tester, 'act0_shell_runner_back');
      await tester.tap(find.text('Review').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_academy_review_leaf_repair_cta');
      await _foundationAdvanceToPrompt(tester);
      await _choose(tester, 'two_three_six');
      final answered = await _saved(tester);
      final outcome = _rows(
        answered,
        'repairOutcomeProjection',
      ).singleWhere((row) => row['sourceTaskId'] == _source);
      expect(outcome['repairOccurrenceId'], intent['repairOccurrenceId']);
      expect(outcome['isCorrect'], isTrue);
      expect(answered['earnedXp'], missed['earnedXp']);
      expect(
        _rows(
          answered,
          'openRepairIntents',
        ).where((row) => row['sourceTaskId'] == _source),
        isEmpty,
      );
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      final finished = await _saved(tester);
      expect(finished['earnedXp'], (missed['earnedXp'] as int) + 5);
      expect(
        (finished['completedTaskIds'] as List).where((id) => id == _source),
        hasLength(1),
      );
    },
  );
  testWidgets(
    'SIMULATED main AppRoot: entry, repair, distinct task, saved remount',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await _pendingWrites().flush().timeout(const Duration(seconds: 2));
        });
      });

      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_placement_intro_cta');
      await _tap(tester, 'act0_shell_placement_option_new');
      await _tap(tester, 'act0_shell_placement_next_cta');
      await _tap(tester, 'act0_shell_welcome_primary_cta');
      await _advanceToPrompt(tester);
      // Welcome is an ungraded orientation, not a scored decision.
      final orientationChoice = _runner(tester).runner.options.first;
      await _choose(tester, orientationChoice.id);
      expect(
        find.byKey(const Key('act0_shell_welcome_handoff_preview')),
        findsOneWidget,
      );
      expect(find.text('PREVIEW COMPLETE'), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsNothing);
      await _tap(tester, 'act0_shell_welcome_primary_cta');
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_current_mission_cta');
      expect(_runner(tester).selectedLessonId, 'what_poker_is');
      expect(_runner(tester).selectedTaskId, 'what_poker_is_theory');
      await _advanceToTask(tester, _source);
      expect(_runner(tester).selectedLessonId, 'what_poker_is');
      await _advanceToPrompt(tester);
      final beforeWrong = await _saved(tester);
      expect(beforeWrong['earnedXp'], 10);
      expect(
        beforeWrong['completedTaskIds'],
        containsAll(<String>[
          'what_poker_is_theory',
          'what_poker_is_find_hero',
          'first_table_guide_first_decision',
        ]),
      );

      await _choose(tester, 'five_board_now');
      expect(_runner(tester).repairReasonLine, contains('Replay this spot'));
      final missed = await _saved(tester);
      expect(missed['earnedXp'], 10, reason: 'A wrong choice earns no XP.');
      final miss = _rows(missed, 'learningEvidenceHistory').singleWhere(
        (row) =>
            row['taskId'] == _source && row['choiceId'] == 'five_board_now',
      );
      expect(miss['isCorrect'], isFalse);
      expect(miss['recordId'], isNotEmpty);
      expect(
        _rows(
          missed,
          'openRepairIntents',
        ).any((row) => row['sourceTaskId'] == _source),
        isTrue,
      );

      final heldIntent = _rows(
        missed,
        'openRepairIntents',
      ).singleWhere((row) => row['sourceTaskId'] == _source);
      expect(heldIntent['mappingType'], 'intentional_exact');
      expect(heldIntent['targetTaskId'], _source);
      expect(_rows(missed, 'repairOutcomeProjection'), isEmpty);
      await _tap(tester, 'act0_shell_feedback_continue_cta');

      // The same-source rehearsal has no independent transfer claim.
      expect(_runner(tester).selectedTaskId, _source);
      expect(_runner(tester).repairResultReceiptLine, isNull);
      final retried = await _saved(tester);
      expect(retried['earnedXp'], 10);
      expect(retried['completedTaskIds'], isNot(contains(_mappedRepair)));
      await _advanceToPrompt(tester);
      await _choose(tester, 'two_three_six');
      expect((await _saved(tester))['earnedXp'], 10);
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      final sourceCompleted = await _saved(tester);
      expect(sourceCompleted['earnedXp'], 15);
      expect(sourceCompleted['completedTaskIds'], contains(_source));

      // The ordinary lesson then visits the existing 4 BB task.
      expect(_runner(tester).selectedTaskId, _mappedRepair);
      await _advanceToPrompt(tester);
      await _choose(tester, 'two_three_four');
      expect((await _saved(tester))['earnedXp'], 15);
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      final ordinaryFour = await _saved(tester);
      expect(ordinaryFour['earnedXp'], 20);
      expect(ordinaryFour['completedTaskIds'], contains(_mappedRepair));

      final skillsBeforeFour = Map<String, dynamic>.from(
        sourceCompleted['profileSkillValues'] as Map,
      );
      final skillsAfterFour = Map<String, dynamic>.from(
        ordinaryFour['profileSkillValues'] as Map,
      );
      int skillDelta(String label) =>
          (skillsAfterFour[label] as num? ?? 0).toInt() -
          (skillsBeforeFour[label] as num? ?? 0).toInt();
      expect(skillDelta('Table sense'), 4);
      expect(skillDelta('Board reading'), 1);
      expect(
        skillDelta('Betting decisions'),
        0,
        reason: 'A table-read recheck is not a betting action Check.',
      );

      expect(_runner(tester).selectedTaskId, _nextTask);
      expect(_nextTask, isNot(anyOf(_source, _mappedRepair)));
      await _advanceToPrompt(tester);
      await _choose(tester, 'hero_btn_preflop_setup');
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      expect((await _saved(tester))['earnedXp'], 20);
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      final acknowledged = await _saved(tester);
      expect(acknowledged['earnedXp'], 25);
      final evidence = _rows(acknowledged, 'learningEvidenceHistory');
      expect(
        evidence.singleWhere((row) => row['recordId'] == miss['recordId']),
        miss,
        reason: 'The original wrong answer remains immutable after repair.',
      );
      expect(
        evidence.any(
          (row) =>
              row['taskId'] == _source &&
              row['choiceId'] == 'two_three_six' &&
              row['isCorrect'] == true,
        ),
        isTrue,
      );
      expect(
        evidence.any(
          (row) =>
              row['taskId'] == _mappedRepair &&
              row['choiceId'] == 'two_three_four' &&
              row['isCorrect'] == true,
        ),
        isTrue,
      );
      final nextAnswer = evidence.singleWhere(
        (row) =>
            row['taskId'] == _nextTask &&
            row['choiceId'] == 'hero_btn_preflop_setup',
      );
      expect(nextAnswer['isCorrect'], isTrue);
      expect(nextAnswer['recordId'], isNot(miss['recordId']));
      expect(
        _rows(
          acknowledged,
          'openRepairIntents',
        ).singleWhere((row) => row['sourceTaskId'] == _source),
        heldIntent,
        reason: 'The recorded relation keeps the original miss identity.',
      );
      final rehearsal = _rows(
        acknowledged,
        'repairOutcomeProjection',
      ).singleWhere((row) => row['targetTaskId'] == _source);
      expect(rehearsal['repairOccurrenceId'], miss['recordId']);
      expect(rehearsal['selectedChoiceId'], 'two_three_six');
      expect(rehearsal['isCorrect'], isTrue);
      final completed = (acknowledged['completedTaskIds'] as List)
          .cast<String>();
      expect(
        completed,
        containsAll(<String>[_source, _mappedRepair, _nextTask]),
      );
      expect(completed.toSet().length, completed.length);
      // Main awards each independent first completion once: theory5 +
      // Hero5 + source6BB5 + ordinary4BB5 + distinctpreflop5. The guided
      // choice, earlier wrong answer and same-source retry add no XP.
      expect(acknowledged['selectedWorldId'], 'world_1');
      expect(acknowledged['selectedLessonId'], 'what_poker_is');
      expect(acknowledged['selectedTaskId'], 'first_table_guide_route_roles');
      // Retain a genuine repair-positive on the earliest admitted ordinary
      // exact-replay source. All prerequisites are earned through visible W1
      // curriculum controls; no skipped-credit fixture or injected route.
      const rankTaskId = 'cards_ranks_suits_rank_drill';
      await _advanceOrdinaryW1ToRank(tester);
      expect(_runner(tester).selectedTaskId, rankTaskId);
      final beforeRankMiss = await _saved(tester);
      final beforeRankXp = (beforeRankMiss['earnedXp'] as num).toInt();
      expect(beforeRankMiss['completedTaskIds'], isNot(contains(rankTaskId)));
      await _foundationAdvanceToPrompt(tester);
      await _choose(tester, 'king');
      final rankMissed = await _saved(tester);
      final rankMiss = _rows(rankMissed, 'learningEvidenceHistory').lastWhere(
        (row) => row['taskId'] == rankTaskId && row['choiceId'] == 'king',
      );
      expect(rankMiss['isCorrect'], isFalse);
      expect(rankMiss['assistanceKind'], 'none');
      expect(rankMissed['earnedXp'], beforeRankXp);
      final rankIntent = _rows(
        rankMissed,
        'openRepairIntents',
      ).singleWhere((row) => row['sourceTaskId'] == rankTaskId);
      expect(rankIntent['mappingType'], 'intentional_exact');
      expect(rankIntent['repairOccurrenceId'], rankMiss['recordId']);
      await _tap(tester, 'act0_shell_runner_back');
      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_academy_home_leaf_cta');
      expect(_runner(tester).selectedTaskId, rankTaskId);
      final rankOpened = await _saved(tester);
      for (final field in [
        'earnedXp',
        'completedTaskIds',
        'learningEvidenceHistory',
      ]) {
        expect(rankOpened[field], rankMissed[field]);
      }
      expect(_runner(tester).runner.selectedOptionId, 'king');
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      await _foundationAdvanceToPrompt(tester);
      await _choose(tester, 'ace');
      final rankAnswered = await _saved(tester);
      final outcome = _rows(rankAnswered, 'repairOutcomeProjection').last;
      expect(outcome['repairOccurrenceId'], rankMiss['recordId']);
      expect(outcome['sourceTaskId'], rankTaskId);
      expect(outcome['targetTaskId'], rankTaskId);
      expect(outcome['selectedChoiceId'], 'ace');
      expect(outcome['isCorrect'], isTrue);
      expect(
        _runner(tester).repairResultReceiptLine,
        'Fix landed: you handled this spot correctly.',
      );
      final positiveProof = _runner(tester).repairOutcomeProofLine;
      expect(positiveProof, 'Nice repair. Same spot, cleaner decision.');
      expect(_runner(tester).isAssistedDecision, isFalse);
      expect(_runner(tester).initialChoiceAssistance.name, 'none');
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      expect(rankAnswered['earnedXp'], beforeRankXp);
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      final repairCompleted = await _saved(tester);
      final rankTask = Act0ShellStateV1.sample
          .lessonById('cards_ranks_suits')
          .taskList
          .singleWhere((task) => task.taskId == rankTaskId);
      expect(repairCompleted['earnedXp'], beforeRankXp + rankTask.rewardXp);
      expect(repairCompleted['completedTaskIds'], contains(rankTaskId));
      expect(
        _rows(
          repairCompleted,
          'openRepairIntents',
        ).where((row) => row['sourceTaskId'] == rankTaskId),
        isEmpty,
      );
      expect(
        _rows(
          repairCompleted,
          'learningEvidenceHistory',
        ).singleWhere((row) => row['recordId'] == rankMiss['recordId']),
        rankMiss,
      );
      expect(
        _rows(
          repairCompleted,
          'learningEvidenceHistory',
        ).singleWhere((row) => row['recordId'] == miss['recordId']),
        miss,
      );
      expect(
        _rows(
          repairCompleted,
          'openRepairIntents',
        ).singleWhere((row) => row['sourceTaskId'] == _source),
        heldIntent,
      );
      // Move to the ordinary next unfinished task before testing cold resume.
      // Completed repair pointers may normalize to this next task on load.
      final backToLesson = find.byKey(const Key('act0_shell_runner_back'));
      if (backToLesson.evaluate().isNotEmpty) {
        await _tap(tester, 'act0_shell_runner_back');
      }
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_current_mission_cta');
      expect(
        _runner(tester).selectedTaskId,
        'cards_ranks_suits_premium_decision',
      );
      await _foundationAdvanceToPrompt(tester);
      expect(_runner(tester).runner.selectedOptionId, isNull);
      final pendingNext = await _saved(tester);
      for (final field in [
        'earnedXp',
        'completedTaskIds',
        'completedLessonIds',
        'learningEvidenceHistory',
        'openRepairIntents',
        'repairOutcomeProjection',
      ]) {
        expect(
          pendingNext[field],
          repairCompleted[field],
          reason:
              'Opening the next task must preserve graded learner data: $field',
        );
      }
      expect(
        pendingNext['completedTaskIds'],
        isNot(contains('cards_ranks_suits_premium_decision')),
      );
      final oldHost = tester.state(find.byType(Act0ShellPreviewScreenV1));
      // The normal widget disposal owns persistence of this unanswered choice.
      // Capture its acknowledged checkpoint before comparing either remount.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final prefs = await SharedPreferences.getInstance();
        await _pendingWrites().flush().timeout(const Duration(seconds: 2));
        await prefs.reload().timeout(const Duration(seconds: 2));
      });
      final acknowledgedNext = await _saved(tester);
      expect(acknowledgedNext['selectedWorldId'], 'world_1');
      expect(acknowledgedNext['selectedLessonId'], 'cards_ranks_suits');
      expect(
        acknowledgedNext['selectedTaskId'],
        'cards_ranks_suits_premium_decision',
      );
      for (final field in [
        'earnedXp',
        'completedTaskIds',
        'completedLessonIds',
        'learningEvidenceHistory',
        'openRepairIntents',
        'repairOutcomeProjection',
      ]) {
        expect(
          acknowledgedNext[field],
          repairCompleted[field],
          reason: 'Ordinary disposal must preserve graded learner data: $field',
        );
      }
      final stable = _stableProgress(acknowledgedNext);

      // No preference reseeding, task injection, debug entry or native calls.
      // Two ordinary root remounts cannot award XP or duplicate evidence.
      for (var count = 0; count < 2; count++) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final prefs = await SharedPreferences.getInstance();
          await _pendingWrites().flush().timeout(const Duration(seconds: 2));
          await prefs.reload().timeout(const Duration(seconds: 2));
        });
        await tester.pumpWidget(
          const AppRoot(debugLegacyPlacementOnStart: true),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Act0ShellPreviewScreenV1), findsOneWidget);
        expect(
          identical(
            tester.state(find.byType(Act0ShellPreviewScreenV1)),
            oldHost,
          ),
          isFalse,
        );
        expect(
          find.byKey(const Key('act0_shell_placement_intro_cta')),
          findsNothing,
        );
        expect(_stableProgress(await _saved(tester)), stable);
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets(
    'SIMULATED Skip: zero earned progress, remount and existing work preserved',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await _pendingWrites().flush().timeout(const Duration(seconds: 2));
        });
      });
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_placement_skip_intro');
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
      final fresh = await _saved(tester);
      expect(fresh['selectedTaskId'], 'what_poker_is_theory');
      expect(fresh['earnedXp'], 0);
      expect(fresh['completedTaskIds'], isEmpty);
      expect(fresh['completedLessonIds'], isEmpty);
      expect(_rows(fresh, 'learningEvidenceHistory'), isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('act0_introduction_skipped_v1'), isTrue);
      expect(await ProgressService.isIntakeCompleted(), isFalse);
      expect(await ProgressService.getIntakeProfile(), isNull);
      expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isFalse);

      // No preference reseeding: a fresh process/root must keep the zero path.
      await _remount(tester);
      expect(
        find.byKey(const Key('act0_shell_placement_intro_cta')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_primary_cta')),
        findsNothing,
      );
      expect(_stableProgress(await _saved(tester)), _stableProgress(fresh));
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_current_mission_cta');
      expect(_runner(tester).selectedTaskId, 'what_poker_is_theory');
      await _advanceToTask(tester, 'what_poker_is_find_hero');
      await _advanceToPrompt(tester);
      await _choose(tester, 'top');
      final earned = await _saved(tester);
      expect(earned['earnedXp'], 5);
      expect(_rows(earned, 'learningEvidenceHistory'), isNotEmpty);

      // Existing progress without an intake disposition must not be reset by
      // Skip. Only remove the route flag, leaving real production data intact.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await _pendingWrites().flush().timeout(const Duration(seconds: 2));
        await prefs.remove('act0_introduction_skipped_v1');
      });
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_placement_skip_intro');
      expect(_stableProgress(await _saved(tester)), _stableProgress(earned));
      await _remount(tester);
      expect(_stableProgress(await _saved(tester)), _stableProgress(earned));
      expect(await ProgressService.isIntakeCompleted(), isFalse);
      expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isFalse);
      await Act0FirstStartPreferencesV1.resetWelcome();
      expect(
        await Act0FirstStartPreferencesV1.hasSkippedIntroduction(),
        isFalse,
      );
      expect(_stableProgress(await _saved(tester)), _stableProgress(earned));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'W1 checkpoint opens after a same-session catalog repair in Review',
    (tester) async {
      final world = Act0ShellStateV1.sample.worldById('world_1');
      final checkpoint = world.lessons.last;
      final prerequisites = {
        for (final lesson in world.lessons.take(world.lessons.length - 1))
          for (final task in lesson.courseTaskList) task.taskId,
      };
      expect(prerequisites, contains(_source));

      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await _pendingWrites().flush().timeout(const Duration(seconds: 2));
        });
      });
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_placement_skip_intro');
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_current_mission_cta');
      await _advanceToTask(tester, _source);
      await _advanceToPrompt(tester);
      await _choose(tester, 'five_board_now');
      final miss = _rows(
        await _saved(tester),
        'openRepairIntents',
      ).singleWhere((row) => row['sourceTaskId'] == _source);
      expect(miss['targetTaskId'], _source);
      await _tap(tester, 'act0_shell_feedback_continue_cta');

      // Complete W1 prerequisites through the ordinary content path, including
      // the inline retry. The open Review item still gates the checkpoint.
      for (var step = 0; step < prerequisites.length * 5; step++) {
        final summary = find.byType(Act0BlockCompletionShellV1);
        if (summary.evaluate().isNotEmpty) {
          final completed = (await _saved(tester))['completedTaskIds'] as List;
          if (prerequisites.every(completed.contains)) {
            await _tap(tester, 'act0_shell_block_summary_home_cta');
            break;
          }
          final next = tester
              .widget<Act0BlockCompletionShellV1>(summary)
              .nextUsefulHand
              ?.targetTaskId;
          await _tap(
            tester,
            prerequisites.contains(next) && !completed.contains(next)
                ? 'act0_shell_block_summary_continue_cta'
                : 'act0_shell_block_summary_home_cta',
          );
        } else if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
          if (find
              .byKey(const Key('act0_shell_current_mission_cta'))
              .evaluate()
              .isEmpty) {
            await tester.tap(find.text('Learn').last);
            await tester.pumpAndSettle();
          }
          await _tap(tester, 'act0_shell_current_mission_cta');
        } else {
          expect(prerequisites, contains(_runner(tester).selectedTaskId));
          final active = _runner(tester).runner;
          if (active.phase == Act0LessonPhaseV1.review) {
            await _tap(tester, 'act0_shell_feedback_continue_cta');
          } else if (active.activeTeachingStep != null ||
              active.phase == Act0LessonPhaseV1.theory) {
            await _continueTeaching(tester);
          } else {
            await _foundationAdvanceToPrompt(tester);
            final correct = _runner(
              tester,
            ).runner.options.singleWhere((option) => option.isCorrect);
            await _choose(tester, correct.id);
          }
        }
      }
      final locked = await _saved(tester);
      final completed = (locked['completedTaskIds'] as List).cast<String>();
      expect(prerequisites.difference(completed.toSet()), isEmpty);
      expect(_rows(locked, 'openRepairIntents').single, miss);
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      expect(find.text('Clear weak spots in Review to unlock'), findsOneWidget);

      await tester.tap(find.text('Review').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_academy_review_leaf_repair_cta');
      expect(_runner(tester).selectedTaskId, _source);
      await _foundationAdvanceToPrompt(tester);
      await _choose(tester, 'two_three_six');
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      final repaired = await _saved(tester);
      expect(_rows(repaired, 'openRepairIntents'), isEmpty);
      expect(
        _rows(repaired, 'repairOutcomeProjection'),
        contains(
          allOf(
            containsPair('repairOccurrenceId', miss['repairOccurrenceId']),
            containsPair('isCorrect', true),
          ),
        ),
      );

      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      expect(find.text('Clear weak spots in Review to unlock'), findsNothing);
      await _tap(tester, 'act0_shell_current_mission_cta');
      expect(_runner(tester).selectedLessonId, checkpoint.lessonId);
      expect(
        _runner(tester).selectedTaskId,
        checkpoint.courseTaskList.first.taskId,
      );
    },
  );

  testWidgets('SIMULATED Foundation four-world route and saved ordinary boundaries', (
    tester,
  ) async {
    // Source keys are scripted route inputs, not learner or poker-quality proof.
    final worlds = Act0ShellStateV1.sample.worlds.take(4).toList();
    expect(worlds.map((w) => w.worldId), [
      'world_1',
      'world_2',
      'world_3',
      'world_4',
    ]);
    final lessons = [for (final world in worlds) ...world.lessons];
    final tasks = [for (final lesson in lessons) ...lesson.courseTaskList];
    expect(lessons, hasLength(33));
    expect(tasks, hasLength(201));
    expect(tasks.map((task) => task.taskId).toSet(), hasLength(201));
    final sizingLesson = worlds.last.lessons.singleWhere(
      (lesson) => lesson.lessonId == 'small_half_pot',
    );
    expect(sizingLesson.courseTaskList.map((task) => task.taskId), [
      'w4_sizing_intro',
      'w4_small_bet',
      'w4_half_pot_bet',
      'w4_pot_bet',
      'w4_min_raise_preflop',
      'w4_min_raise_postflop',
      'w4_sizing_recap',
    ]);
    expect(
      tasks.where(
        (task) =>
            task.entryPhase == Act0LessonPhaseV1.drill &&
            task.runner.options.isNotEmpty,
      ),
      hasLength(165),
    );
    final first = lessons.first;
    final required = tasks.map((task) => task.taskId).toSet();
    final byId = {for (final task in tasks) task.taskId: task};
    final requiredLessons = lessons.map((lesson) => lesson.lessonId).toSet();
    final assessedIds = tasks
        .where(
          (task) =>
              task.entryPhase == Act0LessonPhaseV1.drill &&
              task.runner.options.isNotEmpty,
        )
        .map((task) => task.taskId)
        .toSet();
    final answeredIds = <String>{};
    final remountedWorlds = <String>{};
    final summaryVisits = <String, int>{};
    var firstBoundaryChecked = false;
    final visited = <String>{};
    var pendingRemounted = false;
    var feedbackRemounted = false;
    var assessed = 0;
    var w4PurposeDefinitionOffered = false;
    final w4ChoicesAfterDefinition = <String>{};
    final w4OfferedSequenceTrace = <Map<String, Object?>>[];

    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await _pendingWrites().flush().timeout(const Duration(seconds: 2));
      });
    });
    await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
    await tester.pumpAndSettle();
    await _tap(tester, 'act0_shell_placement_skip_intro');
    final zero = await _saved(tester);
    expect(zero['earnedXp'], 0);
    expect(zero['completedTaskIds'], isEmpty);
    expect(zero['skippedTaskIds'], isEmpty);
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    await _tap(tester, 'act0_shell_current_mission_cta');

    for (var step = 0; step < 1800; step++) {
      final saved = await _saved(tester);
      final completed = (saved['completedTaskIds'] as List)
          .cast<String>()
          .toSet();
      if (completed.containsAll(required) &&
          (saved['completedLessonIds'] as List)
              .cast<String>()
              .toSet()
              .containsAll(requiredLessons)) {
        break;
      }
      expect(completed.difference(required), isEmpty);
      expect(
        (saved['skippedTaskIds'] as List).cast<String>().toSet().intersection(
          required,
        ),
        isEmpty,
      );
      expect(
        saved['earnedXp'],
        completed.fold<int>(0, (sum, id) => sum + byId[id]!.rewardXp),
      );
      var remountedBoundary = false;
      for (var index = 0; index < 3; index++) {
        final world = worlds[index];
        final ids = {
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList) task.taskId,
        };
        if (!remountedWorlds.contains(world.worldId) &&
            completed.containsAll(ids)) {
          final before = _foundationLearningTruth(saved);
          await _remount(tester);
          final restored = await _saved(tester);
          expect(_foundationLearningTruth(restored), before);
          // Restore selects the next world in memory; it does not rewrite
          // the old durable selection until a normal save-producing action.
          await _tap(tester, 'act0_academy_home_leaf_cta');
          expect(_runner(tester).selectedWorldId, worlds[index + 1].worldId);
          expect(
            worlds[index + 1].lessons.map((lesson) => lesson.lessonId),
            contains(_runner(tester).selectedLessonId),
          );
          expect(required, contains(_runner(tester).selectedTaskId));
          expect(completed, isNot(contains(_runner(tester).selectedTaskId)));
          remountedWorlds.add(world.worldId);
          debugPrintSynchronously(
            'FOUNDATION_ROUTE_WORLD_BOUNDARY ${world.worldId} -> ${worlds[index + 1].worldId}',
          );
          remountedBoundary = true;
          break;
        }
      }
      if (remountedBoundary) continue;
      final summaryFinder = find.byType(Act0BlockCompletionShellV1);
      if (summaryFinder.evaluate().isNotEmpty) {
        final summary = tester.widget<Act0BlockCompletionShellV1>(
          summaryFinder,
        );
        final lesson = lessons.singleWhere(
          (lesson) => lesson.lessonId == saved['selectedLessonId'],
        );
        final outstanding = lesson.courseTaskList
            .where((task) => !completed.contains(task.taskId))
            .map((task) => task.taskId)
            .toList();
        summaryVisits.update(
          lesson.lessonId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        expect(summaryVisits[lesson.lessonId], lessThanOrEqualTo(4));
        expect(summary.summary.errorCount, 0);
        if (outstanding.isNotEmpty)
          expect(saved['completedLessonIds'], isNot(contains(lesson.lessonId)));
        debugPrintSynchronously(
          'FOUNDATION_ROUTE_SUMMARY ${jsonEncode({'lesson': lesson.lessonId, 'outstanding': outstanding, 'target': summary.nextUsefulHand?.targetTaskId, 'kind': summary.summary.primaryCtaKind.name})}',
        );
        if (!firstBoundaryChecked &&
            lesson.lessonId == first.lessonId &&
            outstanding.isEmpty) {
          expect(
            saved['earnedXp'],
            first.taskList.fold<int>(0, (sum, task) => sum + task.rewardXp),
          );
          expect(saved['studyObservations'], hasLength(1));
          expect(summary.summary.assistedCount, 1);
          final target = summary.nextUsefulHand?.targetTaskId;
          await _tap(tester, 'act0_shell_block_summary_continue_cta');
          expect(_runner(tester).selectedLessonId, lessons[1].lessonId);
          if (target != null) expect(_runner(tester).selectedTaskId, target);
          await _tap(tester, 'act0_shell_runner_back');
          final beforeReplay = await _saved(tester);
          await _foundationReplayTheory(tester, first);
          final afterReplay = await _saved(tester);
          expect(afterReplay['earnedXp'], beforeReplay['earnedXp']);
          expect(
            afterReplay['completedTaskIds'],
            beforeReplay['completedTaskIds'],
          );
          expect(
            afterReplay['studyObservations'],
            beforeReplay['studyObservations'],
          );
          final before = _foundationLearningTruth(afterReplay);
          await _remount(tester);
          expect(_foundationLearningTruth(await _saved(tester)), before);
          await tester.tap(find.text('Learn').last);
          await tester.pumpAndSettle();
          await _tap(tester, 'act0_shell_current_mission_cta');
          expect(_runner(tester).selectedLessonId, lessons[1].lessonId);
          firstBoundaryChecked = true;
          continue;
        }
        final target = summary.nextUsefulHand?.targetTaskId;
        if (outstanding.isEmpty &&
            target != null &&
            required.contains(target) &&
            !completed.contains(target)) {
          await _tap(tester, 'act0_shell_block_summary_continue_cta');
          expect(_runner(tester).selectedTaskId, target);
        } else {
          // Temporary Action orchestration does not complete legal-context.
          // Actual map navigation must retain access to outstanding tasks.
          await _tap(tester, 'act0_shell_block_summary_home_cta');
        }
        continue;
      }
      if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
        expect(
          find.byKey(const Key('act0_shell_current_mission_cta')),
          findsOneWidget,
        );
        await _tap(tester, 'act0_shell_current_mission_cta');
        expect(required, contains(_runner(tester).selectedTaskId));
        expect(completed, isNot(contains(_runner(tester).selectedTaskId)));
        continue;
      }
      expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
      final active = _runner(tester);
      expect(required, contains(active.selectedTaskId));
      if (active.selectedTaskId == 'w4_purpose_intro' &&
          !w4PurposeDefinitionOffered) {
        // Observe the ordinary first-use surface before any W4 answer. The
        // existing Foundation route earns eligibility from empty preferences;
        // it does not inject a task, unlock, completion or study observation.
        expect(active.selectedWorldId, 'world_4');
        expect(active.selectedLessonId, 'why_bets_happen');
        expect(active.runner.phase, Act0LessonPhaseV1.theory);
        expect(active.runner.teachingStepIndex, 0);
        expect(active.runner.selectedOptionId, isNull);
        expect(active.isSourceRecheckAttempt, isFalse);
        expect(active.learningLoopStage, isNull);
        expect(active.reviewKindId, 'initialAssessment');
        for (final id in [
          'w4_purpose_intro',
          'w4_value_purpose',
          'w4_bluff_purpose',
        ]) {
          expect(completed, isNot(contains(id)));
          expect(saved['skippedTaskIds'], isNot(contains(id)));
        }
        const offeredBody =
            'A value bet is a bet you expect weaker hands to call. '
            'A bluff tries to make better hands fold.';
        final definition = find.textContaining(offeredBody);
        expect(definition, findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(definition);
        expect(paragraph.didExceedMaxLines, isFalse);
        final rect = tester.getRect(definition);
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.bottom, lessThanOrEqualTo(852));
        w4OfferedSequenceTrace.add({
          'kind': 'definition_offered',
          'task_id': active.selectedTaskId,
          'phase': active.runner.phase.name,
          'teaching_index': active.runner.teachingStepIndex,
          'selected_option_id': active.runner.selectedOptionId,
          'review_kind': active.reviewKindId,
          'source_recheck': active.isSourceRecheckAttempt,
          'loop_stage': active.learningLoopStage?.name,
          'rendered_text': paragraph.text.toPlainText(),
          'rect': {'top': rect.top, 'bottom': rect.bottom},
          'did_exceed_max_lines': paragraph.didExceedMaxLines,
          'completed_named_ids': completed
              .where(
                (id) => const {
                  'w4_purpose_intro',
                  'w4_value_purpose',
                  'w4_bluff_purpose',
                }.contains(id),
              )
              .toList(),
          'skipped_named_ids': (saved['skippedTaskIds'] as List)
              .where(
                (id) => const {
                  'w4_purpose_intro',
                  'w4_value_purpose',
                  'w4_bluff_purpose',
                }.contains(id),
              )
              .toList(),
        });
        w4PurposeDefinitionOffered = true;
        debugPrintSynchronously(
          'W4_OFFERED_SEQUENCE intro_definition_visible_no_answer',
        );
      }
      if (visited.add(active.selectedTaskId!)) {
        debugPrintSynchronously(
          'FOUNDATION_ROUTE_ENTER ${active.selectedWorldId}/${active.selectedLessonId}/${active.selectedTaskId}',
        );
      }
      // Review owns the feedback CTA even when its retained runner metadata
      // still includes a teaching step (for example the bucket recap).
      if (active.runner.phase == Act0LessonPhaseV1.review) {
        await _tap(tester, 'act0_shell_feedback_continue_cta');
      } else if (active.runner.activeTeachingStep != null ||
          active.runner.phase == Act0LessonPhaseV1.theory) {
        await _continueTeaching(tester);
      } else {
        await _foundationAdvanceToPrompt(tester);
        final taskId = _runner(tester).selectedTaskId;
        final options = [
          for (final option in _runner(tester).runner.options)
            [option.id, option.label],
        ];
        if (!pendingRemounted) {
          final before = _foundationStable(await _saved(tester));
          await _remount(tester);
          expect(_foundationStable(await _saved(tester)), before);
          // The admitted boot policy is Home-first; resume through its real CTA.
          await _tap(tester, 'act0_academy_home_leaf_cta');
          expect(_runner(tester).selectedTaskId, taskId);
          expect(_runner(tester).runner.phase, Act0LessonPhaseV1.drill);
          expect(_runner(tester).runner.selectedOptionId, isNull);
          expect([
            for (final option in _runner(tester).runner.options)
              [option.id, option.label],
          ], options);
          pendingRemounted = true;
          await _foundationAdvanceToPrompt(tester);
        }
        final answer = _runner(
          tester,
        ).runner.options.firstWhere((o) => o.isCorrect);
        if (taskId == 'w4_value_purpose' || taskId == 'w4_bluff_purpose') {
          expect(w4PurposeDefinitionOffered, isTrue);
          expect(_runner(tester).runner.selectedOptionId, isNull);
          expect(_runner(tester).isSourceRecheckAttempt, isFalse);
          expect(_runner(tester).learningLoopStage, isNull);
          expect(_runner(tester).reviewKindId, 'initialAssessment');
          expect(
            find.byKey(Key('act0_shell_option_${answer.id}')),
            findsOneWidget,
          );
          w4OfferedSequenceTrace.add({
            'kind': 'choice_offered',
            'task_id': _runner(tester).selectedTaskId,
            'phase': _runner(tester).runner.phase.name,
            'selected_option_id': _runner(tester).runner.selectedOptionId,
            'review_kind': _runner(tester).reviewKindId,
            'source_recheck': _runner(tester).isSourceRecheckAttempt,
            'loop_stage': _runner(tester).learningLoopStage?.name,
            'option_key': 'act0_shell_option_${answer.id}',
          });
          w4ChoicesAfterDefinition.add(taskId!);
          debugPrintSynchronously(
            'W4_OFFERED_SEQUENCE $taskId choice_visible_after_definition',
          );
        }
        await _choose(tester, answer.id);
        expect(
          find.byKey(const Key('act0_betting_price_unavailable')),
          findsNothing,
        );
        assessed++;
        answeredIds.add(taskId!);
        expect(_runner(tester).selectedTaskId, taskId);
        expect(_runner(tester).runner.selectedOptionId, answer.id);
        expect(
          _runner(tester).runner.reviewQuality,
          Act0FeedbackQualityV1.correct,
        );
        final answered = await _saved(tester);
        final record = _rows(
          answered,
          'learningEvidenceHistory',
        ).lastWhere((row) => row['taskId'] == taskId);
        expect(record['choiceId'], answer.id);
        expect(Act0LearningEvidenceRecordV1.tryParse(record), isNotNull);
        if (!feedbackRemounted) {
          final before = _foundationLearningTruth(answered);
          final completedIds = (answered['completedTaskIds'] as List)
              .cast<String>()
              .toSet();
          final next = first.taskList.firstWhere(
            (task) => !completedIds.contains(task.taskId),
          );
          await _remount(tester);
          final restored = await _saved(tester);
          expect(_foundationLearningTruth(restored), before);
          expect(restored['selectedTaskId'], next.taskId);
          // Home-first boot opens the saved feedback on Continue, preserving
          // the original answer and avoiding a second submission.
          await _tap(tester, 'act0_academy_home_leaf_cta');
          expect(_runner(tester).selectedTaskId, next.taskId);
          expect(_runner(tester).runner.selectedOptionId, answer.id);
          expect(_runner(tester).runner.phase, Act0LessonPhaseV1.review);
          expect((await _saved(tester))['earnedXp'], answered['earnedXp']);
          feedbackRemounted = true;
        }
        await _tap(tester, 'act0_shell_feedback_continue_cta');
      }
      expect(tester.takeException(), isNull);
    }
    final completed = await _saved(tester);
    expect(
      (completed['completedTaskIds'] as List).cast<String>().toSet(),
      required,
    );
    expect(
      (completed['completedLessonIds'] as List).cast<String>().toSet(),
      requiredLessons,
    );
    expect(visited, required);
    expect(answeredIds, assessedIds);
    expect(
      visited.where(
        (id) => sizingLesson.courseTaskList.any((task) => task.taskId == id),
      ),
      sizingLesson.courseTaskList.map((task) => task.taskId),
    );
    expect(w4PurposeDefinitionOffered, isTrue);
    expect(w4ChoicesAfterDefinition, {'w4_value_purpose', 'w4_bluff_purpose'});
    expect(
      pendingRemounted && feedbackRemounted && firstBoundaryChecked,
      isTrue,
    );
    expect(
      remountedWorlds,
      worlds.take(3).map((world) => world.worldId).toSet(),
    );
    expect(completed['skippedTaskIds'], isEmpty);
    expect(
      completed['earnedXp'],
      tasks.fold<int>(0, (sum, task) => sum + task.rewardXp),
    );
    final studyObservations = (completed['studyObservations'] as List)
        .cast<Map<String, dynamic>>();
    expect(studyObservations, hasLength(30));
    expect(
      studyObservations
          .where((row) => row['lessonId'] == 'w2_narrow_three_bet')
          .map((row) => row['taskId']),
      ['w2_narrow_three_bet_intro'],
    );
    expect(
      studyObservations
          .where((row) => row['lessonId'] == 'blinds_action_order')
          .map((row) => row['taskId']),
      ['positions_theory', 'blinds_theory'],
    );
    expect(w4OfferedSequenceTrace.map((row) => row['task_id']).toList(), [
      'w4_purpose_intro',
      'w4_value_purpose',
      'w4_bluff_purpose',
    ]);
    // Reuse the existing CI artifact transport, in a separate test-owned folder.
    // This witness is not one of the two OBS04 diagnostic windows or its claims.
    final witnessRoot = Platform.environment['OBS04_RECEIPT_DIR'];
    if (witnessRoot != null && witnessRoot.isNotEmpty) {
      await tester.runAsync(() async {
        final output = Directory('$witnessRoot/w4-offered-sequence');
        await output.create(recursive: true);
        final source = File(
          'test/ui_v2/act0_main01_app_root_cycle_v1_test.dart',
        );
        await File('${output.path}/ordinary-first-use.json').writeAsString(
          jsonEncode({
            'schema': 'w4_actual_offered_sequence_widget_v1',
            'fixture': 'existing_empty_preferences_ordinary_Foundation_AppRoot',
            'run_id': Platform.environment['GITHUB_RUN_ID'],
            'run_attempt': Platform.environment['GITHUB_RUN_ATTEMPT'],
            'checkout_sha': Platform.environment['GITHUB_SHA'],
            'physical_test_sha256': sha256
                .convert(await source.readAsBytes())
                .toString(),
            'logical_observation_order': w4OfferedSequenceTrace,
            'not_proved': [
              'person_reading',
              'comprehension',
              'native',
              'Human',
              'strategy_grade',
              'full_CUR_or_parent',
              'points',
            ],
          }),
          flush: true,
        );
      });
    }
    debugPrintSynchronously(
      'FOUNDATION_ROUTE_COMPLETE ${jsonEncode({'visited': visited.toList(), 'assessedIds': answeredIds.toList(), 'assessmentEvents': assessed, 'summaryVisits': summaryVisits, 'worldRemounts': remountedWorlds.toList(), 'completed': completed['completedTaskIds'], 'completedLessons': completed['completedLessonIds'], 'earnedXp': completed['earnedXp'], 'studyCount': (completed['studyObservations'] as List).length, 'historyCount': (completed['learningEvidenceHistory'] as List).length})}',
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _remount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    await _pendingWrites().flush().timeout(const Duration(seconds: 2));
  });
  await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
  await tester.pumpAndSettle();
}

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, String optionId) async {
  final runner = _runner(tester);
  final option = runner.runner.options.singleWhere(
    (option) => option.id == optionId,
  );
  if (runner.runner.sizingConfig.isEnabled) {
    await _tap(tester, 'act0_shell_sizing_preset_${option.id}');
    await _tap(tester, 'act0_shell_sizing_confirm_cta');
  } else {
    await _tap(
      tester,
      option.seatId == null
          ? 'act0_shell_option_${option.id}'
          : 'act0_shell_seat_tap_${option.seatId}',
    );
  }
}

Future<void> _continueTeaching(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1000));
  final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
  await _tap(
    tester,
    theory.evaluate().isNotEmpty
        ? 'act0_shell_theory_continue_cta'
        : 'act0_shell_continue_cta',
  );
}

Future<void> _advanceToPrompt(WidgetTester tester) async {
  for (var step = 0; step < 16; step++) {
    final active = _runner(tester).runner;
    if (active.activeTeachingStep == null &&
        active.phase == Act0LessonPhaseV1.drill) {
      expect(active.selectedOptionId, isNull);
      final option = active.options.first;
      final key = active.sizingConfig.isEnabled
          ? 'act0_shell_sizing_preset_${option.id}'
          : option.seatId == null
          ? 'act0_shell_option_${option.id}'
          : 'act0_shell_seat_tap_${option.seatId}';
      await tester.ensureVisible(find.byKey(Key(key)));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byKey(Key(key)).hitTestable(), findsOneWidget);
      return;
    }
    await _continueTeaching(tester);
  }
  fail('Teaching did not reach a visible decision prompt.');
}

Future<void> _advanceToTask(WidgetTester tester, String taskId) async {
  for (var step = 0; step < 30; step++) {
    final active = _runner(tester);
    if (active.selectedTaskId == taskId) return;
    if (active.runner.activeTeachingStep != null ||
        active.runner.phase == Act0LessonPhaseV1.theory) {
      await _continueTeaching(tester);
    } else {
      await _advanceToPrompt(tester);
      final correct = _runner(
        tester,
      ).runner.options.firstWhere((option) => option.isCorrect);
      await _choose(tester, correct.id);
      await _tap(tester, 'act0_shell_feedback_continue_cta');
    }
  }
  fail('The ordinary first lesson did not reach $taskId.');
}

// Only waits on the production store's shared serial queue. The false callback
// fails closed if this test accidentally tries to load/save through this handle;
// payload semantics are validated by AppRoot's real private parser on remount.
Act0ProgressStoreV1 _pendingWrites() =>
    Act0ProgressStoreV1(key: _progressKey, isValidPayload: (_) => false);

Future<Map<String, dynamic>> _saved(WidgetTester tester) async {
  String? payload;
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    await Future<void>.value();
    final store = _pendingWrites();
    await store.flush().timeout(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload().timeout(const Duration(seconds: 2));
    final recovery = prefs.getString('${_progressKey}_recovery');
    expect(recovery, isNotNull);
    expect(prefs.getString('${_progressKey}_backup'), recovery);
    expect(prefs.getString('${_progressKey}_head'), recovery);
    final envelope = jsonDecode(recovery!) as Map<String, dynamic>;
    expect(envelope['format'], 1);
    expect(envelope['revision'], greaterThan(0));
    payload = envelope['payload'] as String;
    expect(
      envelope['digest'],
      sha256
          .convert(utf8.encode(jsonEncode([1, envelope['revision'], payload])))
          .toString(),
      reason: 'Exact production checkpoint digest, before any remount/healing.',
    );
  });
  expect(payload, isNotNull);
  return jsonDecode(payload!) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _rows(Map<String, dynamic> payload, String field) =>
    (payload[field] as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();

Map<String, Object?> _stableProgress(Map<String, dynamic> payload) =>
    <String, Object?>{
      for (final key in <String>[
        'selectedWorldId',
        'selectedLessonId',
        'selectedTaskId',
        'earnedXp',
        'completedTaskIds',
        'completedLessonIds',
        'learningEvidenceHistory',
        'learningEvidenceLineage',
        'openRepairIntents',
        'reviewMistakeHistory',
        'reviewResolutionReceipts',
        'repairOutcomeProjection',
      ])
        key: payload[key],
    };

Future<void> _openPendingHelpDecision(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await _pendingWrites().flush().timeout(const Duration(seconds: 2));
    });
  });
  await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
  await tester.pumpAndSettle();
  await _tap(tester, 'act0_shell_placement_skip_intro');
  await tester.tap(find.text('Learn').last);
  await tester.pumpAndSettle();
  await _tap(tester, 'act0_shell_current_mission_cta');
  await _advanceToTask(tester, _source);
  await _advanceToPrompt(tester);
  expect(_runner(tester).selectedTaskId, _source);
}

// Explicit in-memory legacy/corruption controls, NEVER native execution proof.
// Rebuild the real envelope only to exercise AppRoot's production parser/recovery.
Future<void> _replaceCheckpointFixture(
  WidgetTester tester,
  Map<String, dynamic> payload,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    await _pendingWrites().flush().timeout(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final previous =
        jsonDecode(prefs.getString('${_progressKey}_head')!) as Map;
    final revision = (previous['revision'] as int) + 1;
    final raw = jsonEncode(payload);
    final envelope = jsonEncode({
      'format': 1,
      'revision': revision,
      'payload': raw,
      'digest': sha256
          .convert(utf8.encode(jsonEncode([1, revision, raw])))
          .toString(),
    });
    await prefs.setString('${_progressKey}_head', envelope);
    await prefs.setString('${_progressKey}_recovery', envelope);
    await prefs.setString('${_progressKey}_backup', envelope);
    await prefs.setString(_progressKey, raw);
  });
  await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
  await tester.pumpAndSettle();
}

class _HelpWriteGate extends SharedPreferencesStorePlatform {
  _HelpWriteGate(this.delegate);
  final SharedPreferencesStorePlatform delegate;
  bool holdNext = false;
  bool failWrites = false;
  bool outOfSpace = false;
  Completer<void>? held;
  void release() {
    if (held != null && !held!.isCompleted) held!.complete();
  }

  @override
  Future<Map<String, Object>> getAll() => delegate.getAll();
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key.startsWith('flutter.act0_shell_progress_v1')) {
      if (outOfSpace) {
        throw PlatformException(
          code: 'ENOSPC',
          message: 'No space left on device',
        );
      }
      if (holdNext) {
        holdNext = false;
        held = Completer<void>();
        await held!.future;
      }
      if (failWrites) return false;
    }
    return delegate.setValue(type, key, value);
  }

  @override
  Future<bool> remove(String key) => delegate.remove(key);
  @override
  Future<bool> clear() => delegate.clear();
}

Future<void> _expectFeedbackClearance(WidgetTester tester) async {
  final registered = find.byKey(const Key('act0_f7_registered_scene'));
  for (var frame = 0; frame < 20 && registered.evaluate().isEmpty; frame++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    });
    await tester.pump(const Duration(milliseconds: 25));
  }
  await tester.pumpAndSettle();
  expect(registered, findsOneWidget);
  final guide = tester.getRect(
    find.byKey(const Key('act0_wave_a_learning_context')),
  );
  for (final seat in _runner(
    tester,
  ).runner.table.seats.where((s) => s.isOccupied)) {
    final node = find.byKey(Key('act0_shell_seat_node_${seat.seatId}'));
    expect(node, findsOneWidget);
    final bounds = tester.getRect(node);
    // Seat labels are live source context on the baked image. Moving the
    // explanation must not trade the upper seat for a hidden Hero label.
    expect(
      guide.overlaps(bounds),
      isFalse,
      reason: 'Feedback obscures ${seat.seatId}: guide=$guide seat=$bounds',
    );
  }
  final next = find.byKey(const Key('act0_shell_feedback_continue_cta'));
  final nextRect = tester.getRect(next);
  expect(next.hitTestable(), findsOneWidget);
  expect(nextRect.height, greaterThanOrEqualTo(48));
  expect(const Rect.fromLTWH(0, 0, 393, 852).contains(nextRect.center), isTrue);
  final guideScroll = find.byKey(const Key('act0_shell_feedback_guide_scroll'));
  expect(guideScroll, findsOneWidget);
  final scrollable = tester.state<ScrollableState>(
    find.descendant(of: guideScroll, matching: find.byType(Scrollable)).first,
  );
  final support = find.byKey(const Key('act0_learning_scene_v3_support'));
  expect(tester.widget<Text>(support).data, isNotEmpty);
  expect(tester.widget<Text>(support).maxLines, isNull);
  final guideViewport = find.byKey(
    const Key('act0_shell_feedback_guide_viewport'),
  );
  final verdict = find.byKey(const Key('act0_integrated_scene_prompt'));
  expect(
    tester.getTopLeft(support).dy,
    lessThan(tester.getTopLeft(verdict).dy),
  );
  expect(
    tester.getTopLeft(support).dy,
    lessThan(tester.getBottomLeft(guideViewport).dy - 16),
    reason: 'The first line of the reason is visible before scrolling.',
  );
  await tester.ensureVisible(support);
  await tester.pumpAndSettle();
  expect(support.hitTestable(), findsOneWidget);
  expect(find.byIcon(Icons.north_rounded), findsOneWidget);
  expect(scrollable.position.maxScrollExtent, greaterThan(0));
  await tester.drag(guideScroll, const Offset(0, -250));
  await tester.pumpAndSettle();
  expect(scrollable.position.pixels, scrollable.position.maxScrollExtent);
  final focus = find.byKey(const Key('act0_learning_scene_v3_focus'));
  expect(focus.hitTestable(), findsOneWidget);
  expect(
    tester.getSemantics(focus).getSemanticsData().label,
    tester.widget<Text>(focus).data,
  );
  final guideSemantics = tester.widget<Semantics>(
    find
        .ancestor(
          of: find.byKey(const Key('act0_wave_a_learning_context')),
          matching: find.byType(Semantics),
        )
        .first,
  );
  expect(guideSemantics.explicitChildNodes, isTrue);
  expect(guideSemantics.properties.label, isNull);
  expect(next.hitTestable(), findsOneWidget);
}

Map<String, Object?> _foundationStable(Map<String, dynamic> payload) => {
  ..._stableProgress(payload),
  for (final key in [
    'studyObservations',
    'pendingDecisionAssistance',
    'skippedTaskIds',
    'perfectTaskIds',
  ])
    key: payload[key],
};

Map<String, Object?> _foundationLearningTruth(Map<String, dynamic> payload) => {
  for (final entry in _foundationStable(payload).entries)
    if (![
      'selectedWorldId',
      'selectedLessonId',
      'selectedTaskId',
    ].contains(entry.key))
      entry.key: entry.value,
};

// Finite ordinary W1 prefix only, reusing the full-route owner's existing
// visible controls and authored answer/choreography helpers. No progress seed.
Future<void> _advanceOrdinaryW1ToRank(WidgetTester tester) async {
  const target = 'cards_ranks_suits_rank_drill';
  final lessons = Act0ShellStateV1.sample.worldById('world_1').lessons;
  final end = lessons.indexWhere(
    (lesson) => lesson.lessonId == 'cards_ranks_suits',
  );
  expect(end, greaterThanOrEqualTo(0));
  final allowed = {
    for (final lesson in lessons.take(end + 1))
      for (final task in lesson.taskList) task.taskId,
  };
  for (var step = 0; step < 160; step++) {
    if (find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty) {
      final active = _runner(tester);
      expect(active.selectedWorldId, 'world_1');
      expect(allowed, contains(active.selectedTaskId));
      if (active.selectedTaskId == target) return;
      if (active.runner.phase == Act0LessonPhaseV1.review) {
        await _tap(tester, 'act0_shell_feedback_continue_cta');
      } else if (active.runner.activeTeachingStep != null ||
          active.runner.phase == Act0LessonPhaseV1.theory) {
        await _continueTeaching(tester);
      } else {
        await _foundationAdvanceToPrompt(tester);
        final correct = _runner(
          tester,
        ).runner.options.singleWhere((o) => o.isCorrect);
        await _choose(tester, correct.id);
        expect(
          _runner(tester).runner.reviewQuality,
          Act0FeedbackQualityV1.correct,
        );
        await _tap(tester, 'act0_shell_feedback_continue_cta');
      }
      continue;
    }
    final summary = find.byType(Act0BlockCompletionShellV1);
    if (summary.evaluate().isNotEmpty) {
      final next = tester
          .widget<Act0BlockCompletionShellV1>(summary)
          .nextUsefulHand
          ?.targetTaskId;
      final completed = (await _saved(tester))['completedTaskIds'] as List;
      await _tap(
        tester,
        next != null && allowed.contains(next) && !completed.contains(next)
            ? 'act0_shell_block_summary_continue_cta'
            : 'act0_shell_block_summary_home_cta',
      );
      continue;
    }
    if (find
        .byKey(const Key('act0_shell_current_mission_cta'))
        .evaluate()
        .isEmpty) {
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
    }
    await _tap(tester, 'act0_shell_current_mission_cta');
  }
  fail('Ordinary W1 prefix did not reach the authored rank repair source.');
}

Future<void> _replayTableReadForXpV1(WidgetTester tester) async {
  await tester.tap(find.text('Learn').last);
  await tester.pumpAndSettle();
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final lesson = world.lessons.first;
  tester
      .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
      .onStartTask(lesson.lessonId, _source);
  await tester.pumpAndSettle();
  expect(_runner(tester).selectedTaskId, _source);
  await _advanceToPrompt(tester);
  await _choose(tester, 'two_three_six');
  await _tap(tester, 'act0_shell_feedback_continue_cta');
}

Future<void> _foundationReplayTheory(
  WidgetTester tester,
  Act0LessonCardV1 lesson,
) async {
  final all = find.text('All lessons');
  if (all.evaluate().isNotEmpty) {
    await tester.ensureVisible(all);
    await tester.tap(all);
    await tester.pumpAndSettle();
  }
  await _tap(tester, 'act0_shell_lesson_${lesson.title}');
  final taskId = lesson.taskList.first.taskId;
  await _tap(tester, 'act0_shell_lesson_step_$taskId');
  await _tap(tester, 'act0_shell_selected_lesson_cta');
  expect(_runner(tester).selectedTaskId, taskId);
  for (var step = 0; step < 16; step++) {
    if (_runner(tester).selectedTaskId != taskId) break;
    await _continueTeaching(tester);
  }
  expect(_runner(tester).selectedTaskId, isNot(taskId));
  await _tap(tester, 'act0_shell_runner_back');
}

Future<void> _foundationAdvanceToPrompt(WidgetTester tester) async {
  await _advanceToPrompt(tester);
  final source = _runner(tester).runner;
  final plan = act0TableChoreographyPlanForTableV1(source.table);
  final replay = act0StreetReplayFromTableV1(source.table);
  if (plan == null || replay?.isConsumerSafe != true) return;
  if (source.table.decisionSeatId != null &&
      source.table.toCallLabel.trim().isNotEmpty) {
    // Priced snapshots deliberately suppress legacy per-action pot annotations.
    // Their replay affordance is therefore not a decision-ready signal.
    expect(_runner(tester).runner.selectedOptionId, isNull);
    await pumpSourceChoreographyToDecisionV1(tester, source.table);
    expect(_runner(tester).runner.selectedOptionId, isNull);
    expect(
      find.byKey(const Key('act0_shell_street_replay_inline')),
      findsNothing,
    );
    return;
  }
  // This actual rendered affordance appears only once the source action
  // choreography is decision-ready. Incremental pumps drain chained timers;
  // one large time jump does not. The public plan bounds the finite wait.
  final ready = find.byKey(const Key('act0_shell_street_replay_inline'));
  for (
    var tick = 0;
    tick < plan.beats.length + 2 && ready.evaluate().isEmpty;
    tick++
  ) {
    expect(_runner(tester).runner.selectedOptionId, isNull);
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(ready, findsOneWidget);
  expect(_runner(tester).runner.selectedOptionId, isNull);
}
