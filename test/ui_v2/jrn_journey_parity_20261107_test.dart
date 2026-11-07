// JRN-07/03/05: ordinary Learn UI with empty progress; no learner evidence seed.
// Host remount proves widget persistence consumption, NOT native restart.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';

const _progressKey = 'act0_shell_progress_v1';
final _store = Act0ProgressStoreV1(
  key: _progressKey,
  isValidPayload: (_) => true,
);
Future<void> _mount(
  WidgetTester t, {
  Act0ShellTabV1 tab = Act0ShellTabV1.home,
}) async {
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: false,
        initialTab: tab,
      ),
    ),
  );
  await t.pumpAndSettle();
}

Future<void> _tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  expect(f, findsOneWidget, reason: key);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  expect(f.hitTestable(), findsOneWidget, reason: '$key must be reachable');
  await t.tap(f);
  await t.pumpAndSettle();
}

Future<List<String>> _answerGuideToSummary(
  WidgetTester tester, {
  required bool missFirst,
}) async {
  final answered = <String>[];
  for (var step = 0; step < 80; step++) {
    if (find
        .byKey(const Key('act0_shell_block_summary_title'))
        .evaluate()
        .isNotEmpty) {
      return answered;
    }
    final runners = find.byType(Act0LessonRunnerShellV1);
    if (runners.evaluate().isNotEmpty) {
      final runner = tester.widget<Act0LessonRunnerShellV1>(runners);
      final correct = runner.runner.options.where(
        (o) => missFirst && answered.isEmpty ? !o.isCorrect : o.isCorrect,
      );
      if (correct.isNotEmpty &&
          runner.runner.phase == Act0LessonPhaseV1.drill &&
          runner.runner.selectedOptionId == null) {
        final choice = correct.first;
        final seat = find.byKey(Key('act0_shell_seat_tap_${choice.seatId}'));
        final option = find.byKey(Key('act0_shell_option_${choice.id}'));
        final target = seat.evaluate().isNotEmpty ? seat : option;
        if (target.evaluate().isNotEmpty) {
          answered.add(runner.selectedTaskId ?? '');
          await tester.ensureVisible(target.first);
          await tester.tap(target.first);
          await tester.pumpAndSettle();
          continue;
        }
      }
    }
    final forward = <String>[
      'act0_shell_theory_continue_cta',
      'act0_shell_continue_cta',
      'act0_shell_feedback_continue_cta',
    ].map((key) => find.byKey(Key(key))).where((f) => f.evaluate().isNotEmpty);
    expect(forward, isNotEmpty, reason: 'no forward route at step $step');
    await tester.ensureVisible(forward.first.first);
    await tester.tap(forward.first.first);
    await tester.pumpAndSettle();
  }
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  fail(
    'Session Summary not reached: ${runner.selectedTaskId} ${runner.runner.phase} selected=${runner.runner.selectedOptionId} answered=$answered',
  );
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data ?? '';

Future<Map<String, dynamic>> _persisted() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final tab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('JRN Review has no phantom focus CTA without source evidence', (
    t,
  ) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    addTearDown(() async {
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
      await _store.flush();
    });
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
    });
    await _mount(t, tab: Act0ShellTabV1.review);
    final focus = t
        .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
        .input
        .nextStep;
    expect(
      focus?.recommendedAction,
      isNot(isIn(['resume_focus', 'reinforce'])),
    );
    expect(
      find.byKey(const Key('act0_academy_review_leaf_next_step_cta')),
      findsNothing,
    );
  });
  for (final exit in [
    'Review',
    'ReviewFocus',
    'You',
    'tab',
    'Home',
    'liveCarry',
    'mismatchedCarry',
    'closedCarryRestart',
    'nonrepairCarry',
  ]) {
    testWidgets('JRN03/07 cross-world repair returns to honest curriculum via $exit', (
      t,
    ) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      t.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.reset);
      addTearDown(() async {
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        await _store.flush();
      });
      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        _progressKey: jsonEncode({
          'schemaVersion': 18,
          'completedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'what_poker_is',
          'selectedTaskId': 'what_poker_is_theory',
          'earnedXp': 0,
        }),
      });
      await _mount(t, tab: Act0ShellTabV1.learn);
      await _tap(t, 'act0_shell_current_mission_cta');
      Future<void> toDecision() async {
        for (var step = 0; step < 24; step++) {
          final seats = find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key as ValueKey<String>).value.startsWith(
                  'act0_shell_option_',
                ),
          );
          if (seats.evaluate().isNotEmpty ||
              find
                  .byKey(const Key('act0_shell_theory_recall_cta'))
                  .evaluate()
                  .isNotEmpty)
            return;
          final forwards = [
            'act0_shell_theory_continue_cta',
            'act0_shell_continue_cta',
            'act0_shell_runner_primary_cta',
          ].where((k) => find.byKey(Key(k)).evaluate().isNotEmpty);
          expect(forwards, isNotEmpty);
          await _tap(t, forwards.first);
        }
        fail('No decision reached by real controls');
      }

      await toDecision();
      final source = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(source.selectedTaskId, 'what_poker_is_find_hero');
      final miss = source.runner.options.firstWhere((o) => !o.isCorrect);
      await _tap(t, 'act0_shell_option_${miss.id}');
      await _tap(t, 'act0_shell_runner_back');
      await _openTab(t, 'Review');
      final before = await _persisted();
      final intent = (before['openRepairIntents'] as List)
          .cast<Map<String, dynamic>>()
          .single;
      expect(intent['targetWorldId'], 'world_3');
      Map<String, Object?> carry({
        bool mismatch = false,
        bool learned = false,
      }) => {
        'skillReceiptId': mismatch
            ? 'table_read_repair_started_hero_cards_board_pot'
            : 'table_position_read_${learned ? "learned" : "repair_started"}_hero_button',
        'skillAtomId': mismatch ? 'table_read' : 'table_position_read',
        'skillLabel': mismatch
            ? 'MISMATCHED FIXTURE CUE'
            : 'Table position read',
        'sourceSignalId': mismatch ? 'hero_cards_board_pot' : 'hero_button',
        'sourceSignalLabel': mismatch
            ? 'Hand, board and pot'
            : 'Hero on the Button',
        'outcomeId': learned ? 'learned' : 'repair_started',
        'nextRepId': mismatch
            ? 'repeat_table_read'
            : 'repeat_table_position_read',
        'nextRepLabel': 'use the same source clue once more',
        'sourceWorldId': 'world_1',
        'sourceLessonId': 'what_poker_is',
        'sourceTaskId': 'what_poker_is_find_hero',
      };
      Future<void> restoreCarryFixture(
        Map<String, dynamic> earned,
        Map<String, Object?> cue,
      ) async {
        // Controlled descriptive-cue fixture over UI-earned truth, not native data injection.
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        await _store.flush();
        SharedPreferences.setMockInitialValues({
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          _progressKey: jsonEncode({...earned, 'firstValueReturnCarry': cue}),
        });
        await _mount(t);
      }

      if (exit == 'liveCarry' || exit == 'mismatchedCarry') {
        await restoreCarryFixture(
          before,
          carry(mismatch: exit == 'mismatchedCarry'),
        );
        final home = t
            .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
            .input;
        if (exit == 'liveCarry') {
          expect(home.nextAction!.title, 'Repair: Table position read');
        } else {
          expect(
            home.nextAction!.title,
            isNot(contains('MISMATCHED FIXTURE CUE')),
            reason:
                'An old cue must match the live source signal/skill, not just its task id',
          );
        }
        await _tap(t, 'act0_academy_home_leaf_cta');
        final launched = t.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(launched.selectedTaskId, intent['targetTaskId']);
        expect(
          (await _persisted())['openRepairIntents'],
          before['openRepairIntents'],
        );
        return;
      }

      await _tap(t, 'act0_academy_review_leaf_repair_cta');
      await toDecision();
      final target = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(target.selectedWorldId, 'world_3');
      final correct = target.runner.options.firstWhere((o) => o.isCorrect);
      final seat = find.byKey(Key('act0_shell_seat_tap_${correct.seatId}'));
      await _tap(
        t,
        seat.evaluate().isNotEmpty
            ? 'act0_shell_seat_tap_${correct.seatId}'
            : 'act0_shell_option_${correct.id}',
      );
      await _tap(t, 'act0_shell_feedback_continue_cta');
      final resolved = await _persisted();
      expect(resolved['openRepairIntents'], isEmpty);
      expect(resolved['completedLessonIds'], before['completedLessonIds']);
      expect(resolved['earnedXp'], before['earnedXp']);
      if (exit == 'closedCarryRestart' || exit == 'nonrepairCarry') {
        await restoreCarryFixture(
          resolved,
          carry(learned: exit == 'nonrepairCarry'),
        );
        final home = t
            .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
            .input;
        expect(home.nextAction!.title, isNot(startsWith('Repair:')));
        if (exit == 'nonrepairCarry') {
          expect(home.nextAction!.title, startsWith('Next: one more'));
          return;
        }
        await _tap(t, 'act0_academy_home_leaf_cta');
        expect(
          t
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .selectedWorldId,
          'world_1',
        );
        expect((await _persisted())['openRepairIntents'], isEmpty);
        return;
      }
      if (exit == 'Home') {
        await _openTab(t, 'Home');
        final home = t
            .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
            .input;
        expect(
          home.nextAction!.title,
          isNot(startsWith('Repair:')),
          reason:
              'Resolved source debt cannot keep the persisted first-value repair cue actionable',
        );
        expect(
          home.courseTitle,
          contains('Poker from Zero'),
          reason: 'Home must describe the actionable curriculum world',
        );
        await _tap(t, 'act0_academy_home_leaf_cta');
        final runner = t.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(runner.selectedWorldId, 'world_1');
        return;
      } else if (exit == 'ReviewFocus') {
        final focus = t
            .widget<Act0AcademyReviewLeafV1>(
              find.byType(Act0AcademyReviewLeafV1),
            )
            .input
            .nextStep;
        expect(focus, isNotNull);
        expect(focus!.recommendedAction, isIn(['resume_focus', 'reinforce']));
        expect(focus.sourceTaskId, isNotEmpty);
        await _tap(t, 'act0_academy_review_leaf_next_step_cta');
      } else if (exit == 'Review') {
        await _tap(t, 'act0_academy_review_leaf_learn');
      } else if (exit == 'You') {
        await _openTab(t, 'You');
        await _tap(t, 'act0_academy_you_leaf_learn');
      } else {
        await _openTab(t, 'Learn');
      }
      final learn = t.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      expect(
        learn.selectedWorldId,
        'world_1',
        reason:
            'Directed future-world repair must not strand normal Learn in locked world_3',
      );
      final start = t.widget<FilledButton>(
        find.byKey(const Key('act0_shell_current_mission_cta')),
      );
      expect(
        start.onPressed,
        isNotNull,
        reason: 'Normal curriculum continuation must stay actionable',
      );
      final nextTask = learn.selectedTaskId;
      final nextLesson = learn.selectedLessonId;
      await _tap(t, 'act0_shell_current_mission_cta');
      final continued = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(continued.selectedWorldId, 'world_1');
      expect(continued.selectedLessonId, nextLesson);
      expect(continued.selectedTaskId, nextTask);
      expect((await _persisted())['openRepairIntents'], isEmpty);
    });
  }
  for (final miss in [false, true]) {
    testWidgets('JRN07 Summary Home You persisted parity; miss=$miss', (
      t,
    ) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      t.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.reset);
      addTearDown(() async {
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        await _store.flush();
      });
      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        _progressKey: jsonEncode({
          'schemaVersion': 18,
          'completedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'what_poker_is',
          'selectedTaskId': 'what_poker_is_theory',
          'earnedXp': 0,
        }),
      });
      await _mount(t, tab: Act0ShellTabV1.learn);
      final start = t.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      expect(start.completedTaskIds, isEmpty);
      expect(start.selectedWorldId, 'world_1');
      await _tap(t, 'act0_shell_current_mission_cta');
      await _answerGuideToSummary(t, missFirst: miss);
      final summary = t
          .widget<Act0BlockCompletionShellV1>(
            find.byType(Act0BlockCompletionShellV1),
          )
          .summary;
      expect(summary.curriculumCompleted, isTrue);
      expect(summary.qualifiesForNextLesson, isTrue);
      expect(summary.errorCount, miss ? 1 : 0);
      if (miss) {
        expect(summary.masteryStatus.name, isNot('cleanPass'));
        expect(
          summary.suggestedNextAction,
          isNot(contains('before moving on')),
          reason:
              'Completed curriculum must not make optional practice sound like a locked prerequisite',
        );
        expect(find.text('Clean pass'), findsNothing);
      }
      final saved = await _persisted();
      expect(saved['completedLessonIds'], contains('what_poker_is'));
      final immutable = {
        for (final k in [
          'completedTaskIds',
          'completedLessonIds',
          'earnedXp',
          'learningEvidenceHistory',
          'openRepairIntents',
          'reviewMistakeHistory',
          'reviewResolutionReceipts',
        ])
          k: saved[k],
      };
      await _tap(t, 'act0_shell_block_summary_continue_cta');
      final nextRunner = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(
        nextRunner.selectedLessonId,
        'what_poker_is_content',
        reason: 'Completed Guide advances even after a genuine first miss',
      );
      await _tap(t, 'act0_shell_runner_back');
      await _openTab(t, 'Home');
      final homeBefore = t
          .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
          .input;
      expect(homeBefore.earnedLessonCount, 1);
      expect(homeBefore.nextAction, isNotNull);
      await _openTab(t, 'You');
      final youBefore = t
          .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
          .input;
      expect(
        youBefore.completedTaskCount,
        (saved['completedTaskIds'] as List).length,
      );
      expect(
        youBefore.openRepairCount,
        (saved['openRepairIntents'] as List).length,
      );
      expect(
        youBefore.dueReviewCount,
        0,
        reason: 'Same-session practice is not elapsed due',
      );
      await _openTab(t, 'Review');
      final reviewBefore = t
          .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
          .input;
      expect(reviewBefore.openMistakes.length, youBefore.openRepairCount);
      expect(reviewBefore.dueItems, isEmpty);
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
      await _store.flush();
      await _mount(t);
      final homeAfter = t
          .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
          .input;
      expect(homeAfter.earnedLessonCount, homeBefore.earnedLessonCount);
      expect(homeAfter.nextAction!.title, homeBefore.nextAction!.title);
      expect(homeAfter.nextAction!.ctaLabel, homeBefore.nextAction!.ctaLabel);
      await _openTab(t, 'You');
      final youAfter = t
          .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
          .input;
      expect(youAfter.completedTaskCount, youBefore.completedTaskCount);
      expect(youAfter.openRepairCount, youBefore.openRepairCount);
      expect(youAfter.bankedRepairCount, youBefore.bankedRepairCount);
      expect(youAfter.dueReviewCount, youBefore.dueReviewCount);
      expect(youAfter.xpLine, youBefore.xpLine);
      await _tap(t, 'act0_academy_you_leaf_learn');
      final learn = t.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      final current = learn.lessons.singleWhere(
        (l) => l.isSelectable && l.state == Act0LessonStateV1.current,
      );
      expect(current.lessonId, isNot('what_poker_is'));
      expect(
        learn.completedTaskIds,
        containsAll((saved['completedTaskIds'] as List).cast<String>()),
      );
      await _tap(t, 'act0_shell_levels_menu_button');
      expect(find.byKey(const Key('act0_shell_levels_menu')), findsOneWidget);
      expect(
        _text(t, 'act0_shell_levels_selected_world_current_line'),
        contains('Poker from Zero'),
      );
      await _tap(t, 'act0_shell_world_2');
      expect(
        find.byKey(const Key('act0_shell_selected_world_panel')),
        findsOneWidget,
      );
      expect(
        _text(t, 'act0_shell_world_unlock_label'),
        contains('Finish Poker from Zero'),
      );
      expect(
        (await _persisted())['completedLessonIds'],
        saved['completedLessonIds'],
      );
      await _tap(t, 'act0_shell_world_continue_current_cta');
      final returned = t.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      expect(returned.selectedWorldId, 'world_1');
      expect(returned.showWorldMenu, isFalse);
      final finalSave = await _persisted();
      expect(
        {for (final k in immutable.keys) k: finalSave[k]},
        immutable,
        reason:
            'Navigation/remount cannot rewrite evidence, completion, reward or debt',
      );
      // Controlled shortened-history fixture from this UI-earned payload.
      // This is a widget negative control, never native progress injection.
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
      await _store.flush();
      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        _progressKey: jsonEncode({
          ...finalSave,
          'learningEvidenceHistory': <Object>[],
        }),
      });
      await _mount(t);
      final shortHome = t
          .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
          .input;
      expect(shortHome.earnedLessonCount, homeAfter.earnedLessonCount);
      expect(shortHome.nextAction!.title, homeAfter.nextAction!.title);
      await _openTab(t, 'You');
      final shortYou = t
          .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
          .input;
      expect(shortYou.completedTaskCount, youAfter.completedTaskCount);
      expect(shortYou.openRepairCount, youAfter.openRepairCount);
      expect(shortYou.dueReviewCount, youAfter.dueReviewCount);
      expect(shortYou.xpLine, youAfter.xpLine);
      final out = Directory('output/jrn-journey-20261107');
      out.createSync(recursive: true);
      File('${out.path}/parity_miss_$miss.json').writeAsStringSync(
        jsonEncode({
          'class': 'widget_host_remount_not_native',
          'firstMiss': miss,
          'summary': {
            'correct': summary.correctCount,
            'errors': summary.errorCount,
            'curriculumCompleted': summary.curriculumCompleted,
            'primaryCta': summary.primaryCtaLabel,
          },
          'home': {
            'earnedLessons': homeAfter.earnedLessonCount,
            'next': homeAfter.nextAction!.title,
          },
          'you': {
            'completedTasks': youAfter.completedTaskCount,
            'openRepair': youAfter.openRepairCount,
            'due': youAfter.dueReviewCount,
          },
          'learnNext': current.lessonId,
          'persistedUnchanged': true,
          'shortenedHistoryParity': true,
        }),
      );
    });
  }
}
