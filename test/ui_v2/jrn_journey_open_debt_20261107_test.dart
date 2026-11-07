// Owner 2026-11-07: retire inline action-history strip in Review feedback;
// retain full mistakes/results on Review. Guard Practice target and parity.
// Uses fresh real UI choices; host remount is not native process restart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart';

const _progressKey = 'act0_shell_progress_v1';
final _store = Act0ProgressStoreV1(
  key: _progressKey,
  isValidPayload: (_) => true,
);
const _sourceTask = 'what_poker_is_table_read_transfer';
Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

dynamic _host(WidgetTester tester) =>
    tester.state(find.byType(Act0ShellPreviewScreenV1));

Future<void> _tapKey(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget, reason: key);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _mount(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(key: UniqueKey()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openReview(WidgetTester tester) async {
  final tab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Review'),
  );
  expect(tab, findsOneWidget);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester tester) async {
  // Observe the ordinary save; do not call a debug persist/state hook.
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 250));
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_progressKey);
  expect(raw, isNotNull, reason: 'The ordinary route must persist itself.');
  return jsonDecode(raw!) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _rows(Map<String, dynamic> saved, String key) =>
    (saved[key] as List).cast<Map<String, dynamic>>();

Future<void> _placementToReview(
  WidgetTester tester,
  List<String> choices,
) async {
  await _tapKey(tester, 'act0_shell_placement_intro_cta');
  for (final option in const ['friends', 'rules']) {
    await _tapKey(tester, 'act0_shell_placement_option_$option');
    await _tapKey(tester, 'act0_shell_placement_next_cta');
  }
  await _tapKey(tester, 'act0_shell_placement_start_diagnostic');
  for (final choice in choices) {
    expect(_runner(tester).selectedTaskId, _sourceTask);
    await _tapKey(tester, 'act0_shell_option_$choice');
    await _tapKey(tester, 'act0_shell_feedback_continue_cta');
  }
  await _tapKey(tester, 'act0_shell_placement_start_recommended');
  await _tapKey(tester, 'act0_shell_welcome_primary_cta');
  // Same source-owned Welcome option lookup as the existing provenance test;
  // selection still occurs by tapping its rendered button, not a callback.
  final answer = _runner(tester).runner.options.firstWhere((o) => o.isCorrect);
  await _tapKey(tester, 'act0_shell_option_${answer.id}');
  await _tapKey(tester, 'act0_shell_welcome_primary_cta');
  await _tapKey(tester, 'act0_shell_runner_back');
  await _openReview(tester);
}

Future<void> _tab(WidgetTester t, String name) async {
  final f = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(name),
  );
  expect(f, findsOneWidget);
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'JRN06 retired strip hides a nonempty source trail; feedback CTA survives',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      t.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.reset);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .firstWhere(
            (t) =>
                t.runner.table.actionTrail.isNotEmpty &&
                t.runner.options.any((o) => o.isCorrect),
          );
      final correct = task.runner.options.firstWhere((o) => o.isCorrect);
      var continued = false;
      await t.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: correct.id,
              ),
              selectedTaskId: task.taskId,
              selectedTaskTitle: task.title,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {
                continued = true;
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(task.runner.table.actionTrail, isNotEmpty);
      expect(find.byKey(const Key('act0_shell_action_trail')), findsNothing);
      expect(find.byKey(const Key('act0_shell_table_notes')), findsNothing);
      final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      expect(cta, findsOneWidget);
      await t.ensureVisible(cta);
      await t.pumpAndSettle();
      expect(cta.hitTestable(), findsOneWidget);
      await t.tap(cta);
      await t.pumpAndSettle();
      expect(continued, isTrue);
    },
  );
  for (final boardMiss in [true, false]) {
    testWidgets(
      'JRN05/06/07 Practice target, Review history and Home You reload; board=$boardMiss',
      (t) async {
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
        SharedPreferences.setMockInitialValues(<String, Object>{});
        await _mount(t);
        await _placementToReview(t, [
          'two_three_six',
          boardMiss ? 'hero_private_cards' : 'board_cards',
          boardMiss ? 'check' : 'not_sure_yet',
        ]);
        final saved = await _saved(t);
        final intent = _rows(saved, 'openRepairIntents').single;
        final historical = _rows(saved, 'learningEvidenceHistory');
        final review = t
            .widget<Act0AcademyReviewLeafV1>(
              find.byType(Act0AcademyReviewLeafV1),
            )
            .input;
        expect(review.openMistakes, hasLength(1));
        expect(review.dueItems, isEmpty);
        await _tab(t, 'Home');
        final beforeHome = t
            .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
            .input;
        expect(beforeHome.earnedLessonCount, 0);
        expect(beforeHome.nextAction!.title.toLowerCase(), contains('repair'));
        await _tab(t, 'You');
        final beforeYou = t
            .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
            .input;
        expect(beforeYou.openRepairCount, 1);
        expect(beforeYou.dueReviewCount, 0);
        expect(beforeYou.completedTaskCount, 0);
        await _tab(t, 'Practice');
        final input = t
            .widget<Act0AcademyPracticeLeafV1>(
              find.byType(Act0AcademyPracticeLeafV1),
            )
            .input;
        final item = input.repairQueue.items.singleWhere(
          (i) => i.launchTarget != null,
        );
        expect(item.launchTarget!.taskId, intent['targetTaskId']);
        expect(item.launchTarget!.lessonId, intent['targetLessonId']);
        final cta = find.byKey(
          Key('act0_academy_practice_leaf_repair_cta_${item.itemId}'),
        );
        expect(cta, findsOneWidget);
        await t.ensureVisible(cta);
        await t.pumpAndSettle();
        expect(cta.hitTestable(), findsOneWidget);
        await t.tap(cta);
        await t.pumpAndSettle();
        expect(_runner(t).selectedWorldId, intent['targetWorldId']);
        expect(_runner(t).selectedLessonId, intent['targetLessonId']);
        expect(_runner(t).selectedTaskId, intent['targetTaskId']);
        await _tapKey(t, 'act0_shell_runner_back');
        expect(
          find.byType(Act0AcademyReviewLeafV1),
          findsOneWidget,
          reason:
              'Directed repair Back returns to the canonical Review debt owner',
        );
        final afterCancel = await _saved(t);
        expect(afterCancel['openRepairIntents'], saved['openRepairIntents']);
        expect(afterCancel['learningEvidenceHistory'], historical);
        expect(afterCancel['earnedXp'], saved['earnedXp']);
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        await _store.flush();
        await _mount(t);
        final home = t
            .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
            .input;
        expect(home.nextAction!.title, beforeHome.nextAction!.title);
        await _tab(t, 'You');
        final you = t
            .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
            .input;
        expect(you.openRepairCount, beforeYou.openRepairCount);
        expect(you.completedTaskCount, beforeYou.completedTaskCount);
        expect(you.dueReviewCount, 0);
        await _tapKey(t, 'act0_academy_you_leaf_review');
        final after = t
            .widget<Act0AcademyReviewLeafV1>(
              find.byType(Act0AcademyReviewLeafV1),
            )
            .input;
        expect(
          after.openMistakes.single.taskId,
          review.openMistakes.single.taskId,
        );
        expect(
          after.openMistakes.single.selectedOptionId,
          review.openMistakes.single.selectedOptionId,
        );
        // The owner retired the inline strip, not the Review history.
        await _tapKey(t, 'act0_academy_review_leaf_repair_cta');
        for (var step = 0; step < 16; step++) {
          if (find
              .byWidgetPredicate(
                (w) =>
                    w.key is ValueKey<String> &&
                    (w.key as ValueKey<String>).value.startsWith(
                      'act0_shell_option_',
                    ),
              )
              .evaluate()
              .isNotEmpty)
            break;
          final forward = [
            'act0_shell_runner_primary_cta',
            'act0_shell_continue_cta',
            'act0_shell_theory_continue_cta',
          ].where((key) => find.byKey(Key(key)).evaluate().isNotEmpty);
          expect(forward, isNotEmpty);
          await _tapKey(t, forward.first);
        }
        final answer = _runner(t).runner.options.firstWhere((o) => o.isCorrect);
        await _tapKey(t, 'act0_shell_option_${answer.id}');
        expect(_runner(t).runner.phase, Act0LessonPhaseV1.review);
        expect(
          find.byKey(const Key('act0_shell_action_trail')),
          findsNothing,
          reason:
              'Owner retired the inline hand-history strip in Review feedback',
        );
        expect(find.byKey(const Key('act0_shell_table_notes')), findsNothing);
        expect(
          find.byKey(const Key('act0_shell_feedback_continue_cta')),
          findsOneWidget,
        );
        final repaired = await _saved(t);
        for (final record in historical) {
          expect(
            _rows(
              repaired,
              'learningEvidenceHistory',
            ).singleWhere((r) => r['recordId'] == record['recordId']),
            record,
          );
        }
        expect(repaired['openRepairIntents'], isEmpty);
        expect(
          repaired['reviewMistakeHistory'],
          saved['reviewMistakeHistory'],
          reason: 'Resolving a miss must not delete its original history',
        );
        await _tapKey(t, 'act0_shell_runner_back');
        final resolved = t
            .widget<Act0AcademyReviewLeafV1>(
              find.byType(Act0AcademyReviewLeafV1),
            )
            .input;
        expect(resolved.openMistakes, isEmpty);
        expect(resolved.pastRepairs, hasLength(1));
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        await _store.flush();
        await _mount(t);
        await _openReview(t);
        final reloaded = t
            .widget<Act0AcademyReviewLeafV1>(
              find.byType(Act0AcademyReviewLeafV1),
            )
            .input;
        expect(reloaded.openMistakes, isEmpty);
        expect(
          reloaded.pastRepairs.single.taskId,
          resolved.pastRepairs.single.taskId,
        );
        expect(
          (await _saved(t))['reviewResolutionReceipts'],
          repaired['reviewResolutionReceipts'],
        );
        final dir = Directory('output/jrn-journey-20261107')
          ..createSync(recursive: true);
        File('${dir.path}/open_debt_board_$boardMiss.json').writeAsStringSync(
          jsonEncode({
            'class': 'widget_host_remount_not_native',
            'sourceTask': intent['sourceTaskId'],
            'targetTask': intent['targetTaskId'],
            'open': you.openRepairCount,
            'due': you.dueReviewCount,
            'cancelPreservesEvidence': true,
            'inlineStripRetired': true,
            'resolvedHistoryPreservedAfterRemount': true,
            'homeNext': home.nextAction!.title,
          }),
        );
      },
    );
  }
}
