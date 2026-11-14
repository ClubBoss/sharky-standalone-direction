import 'dart:async';
// SIMULATED normal production AppRoot journey on English iPhone 14 Pro.
// Uses current-main tasks only. Empty fake preferences are seeded once at boot.
// Widget remount/fake preferences do not prove native restart or Human learning.
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_first_start_preferences_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _progressKey = 'act0_shell_progress_v1';
const _source = 'what_poker_is_table_read_transfer';
const _mappedRepair = 'what_poker_is_table_read_recheck';
const _nextTask = 'first_table_guide_one_clear_choice';

void main() {
  for (final feedbackCase in ['assisted', 'wrong', 'correct']) {
    testWidgets(
      'SIMULATED feedback clears visible source seats and keeps continuation usable - $feedbackCase',
      (tester) async {
        tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);
        await _openPendingHelpDecision(tester);
        if (feedbackCase == 'assisted') {
          await _tap(tester, 'act0_shell_theory_recall_cta');
          await _tap(tester, 'act0_shell_review_full_idea_cta');
          await _tap(tester, 'act0_shell_theory_recall_close_cta');
        }
        final options = _runner(tester).runner.options;
        final answer = feedbackCase == 'wrong'
            ? options.singleWhere((o) => o.id == 'five_board_now')
            : options.singleWhere((o) => o.isCorrect);
        await _choose(tester, answer.id);
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
          expect(_runner(tester).selectedTaskId, _mappedRepair);
          await _advanceToPrompt(tester);
          await _choose(tester, 'two_three_four');
          expect(_runner(tester).repairResultReceiptLine, isNotEmpty);
          await _expectFeedbackClearance(tester);
          await _tap(tester, 'act0_shell_feedback_continue_cta');
          expect(_runner(tester).selectedTaskId, _source);
          await _advanceToPrompt(tester);
          await _choose(tester, 'two_three_six');
          await _expectFeedbackClearance(tester);
        } else if (feedbackCase == 'correct') {
          await _tap(tester, 'act0_shell_feedback_continue_cta');
          expect(_runner(tester).selectedTaskId, _mappedRepair);
          await _advanceToPrompt(tester);
          await _choose(tester, 'two_three_four');
          await _expectFeedbackClearance(tester);
          await _tap(tester, 'act0_shell_feedback_continue_cta');
          expect(_runner(tester).selectedTaskId, _nextTask);
          await _advanceToPrompt(tester);
          await _choose(tester, 'co_still_acting');
          expect(
            _runner(tester).runner.reviewQuality,
            Act0FeedbackQualityV1.suboptimal,
          );
          await _expectFeedbackClearance(tester, baked: false);
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

  for (final mode in ['ack', 'failure', 'navigation', 'reset']) {
    testWidgets('SIMULATED help waits for durable marker: $mode', (
      tester,
    ) async {
      await _openPendingHelpDecision(tester);
      final original = SharedPreferencesStorePlatform.instance;
      final disk = _HelpWriteGate(original);
      SharedPreferencesStorePlatform.instance = disk;
      addTearDown(() async {
        disk.failWrites = false;
        disk.release();
        await tester.runAsync(() async {
          await _pendingWrites().flush().timeout(const Duration(seconds: 2));
        });
        SharedPreferencesStorePlatform.instance = original;
      });
      final untouched = await _saved(tester);
      if (mode == 'failure') {
        disk.failWrites = true;
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
      if (mode == 'failure') {
        expect(
          find.text('Help could not be saved. Please try again.'),
          findsOneWidget,
        );
        disk.failWrites = false;
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
      await tester.pumpWidget(const AppRoot());
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
      // Home deliberately offers the mapped repair after a miss. It is not a
      // request to restart the old answer or proof of independent correction.
      await _tap(tester, 'act0_academy_home_leaf_cta');
      expect(_runner(tester).selectedTaskId, _mappedRepair);
      final repairOpened = await _saved(tester);
      expect(repairOpened['earnedXp'], missed['earnedXp']);
      expect(
        repairOpened['learningEvidenceHistory'],
        missed['learningEvidenceHistory'],
      );
      expect(repairOpened['completedTaskIds'], missed['completedTaskIds']);
      expect(repairOpened['openRepairIntents'], missed['openRepairIntents']);
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

      await tester.pumpWidget(const AppRoot());
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
        ]),
      );

      await _choose(tester, 'five_board_now');
      expect(_runner(tester).repairReasonLine, isNotEmpty);
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

      await _tap(tester, 'act0_shell_feedback_continue_cta');
      expect(_runner(tester).selectedTaskId, _mappedRepair);
      await _advanceToPrompt(tester);
      await _choose(tester, 'two_three_four');
      expect(_runner(tester).repairResultReceiptLine, isNotEmpty);
      await _tap(tester, 'act0_shell_feedback_continue_cta');

      // The existing main route rechecks the original 6 BB scene. It is a
      // familiar source recheck, not a new unseen task or durable retention.
      expect(_runner(tester).selectedTaskId, _source);
      final guided = await _saved(tester);
      expect(guided['earnedXp'], 10);
      expect(guided['completedTaskIds'], isNot(contains(_mappedRepair)));
      await _advanceToPrompt(tester);
      await _choose(tester, 'two_three_six');
      expect((await _saved(tester))['earnedXp'], 10);
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      final sourceCompleted = await _saved(tester);
      expect(sourceCompleted['earnedXp'], 15);
      expect(sourceCompleted['completedTaskIds'], contains(_source));

      // The ordinary lesson then visits the existing 4 BB task. Its earlier
      // guided appearance does not make this a newly authored exercise.
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
        ).where((row) => row['sourceTaskId'] == _source),
        isEmpty,
      );
      final completed = (acknowledged['completedTaskIds'] as List)
          .cast<String>();
      expect(
        completed,
        containsAll(<String>[_source, _mappedRepair, _nextTask]),
      );
      expect(completed.toSet().length, completed.length);
      // Main awards each admitted first completion once: theory5 + Hero5 +
      // source6BB5 + ordinary4BB5 + distinctpreflop5. The locked inline4BB
      // repair cannot complete its future curriculum task or award its5XP.
      expect(acknowledged['selectedWorldId'], 'world_1');
      expect(acknowledged['selectedLessonId'], 'what_poker_is');
      expect(acknowledged['selectedTaskId'], 'first_table_guide_route_roles');
      final stable = _stableProgress(acknowledged);
      final oldHost = tester.state(find.byType(Act0ShellPreviewScreenV1));

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
        await tester.pumpWidget(const AppRoot());
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
      await tester.pumpWidget(const AppRoot());
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
      await tester.pumpWidget(const AppRoot());
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
}

Future<void> _remount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    await _pendingWrites().flush().timeout(const Duration(seconds: 2));
  });
  await tester.pumpWidget(const AppRoot());
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
      final key = option.seatId == null
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
  await tester.pumpWidget(const AppRoot());
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
  await tester.pumpWidget(const AppRoot());
  await tester.pumpAndSettle();
}

class _HelpWriteGate extends SharedPreferencesStorePlatform {
  _HelpWriteGate(this.delegate);
  final SharedPreferencesStorePlatform delegate;
  bool holdNext = false;
  bool failWrites = false;
  Completer<void>? held;
  void release() {
    if (held != null && !held!.isCompleted) held!.complete();
  }

  @override
  Future<Map<String, Object>> getAll() => delegate.getAll();
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key.startsWith('flutter.act0_shell_progress_v1')) {
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

Future<void> _expectFeedbackClearance(
  WidgetTester tester, {
  bool baked = true,
}) async {
  final registered = find.byKey(const Key('act0_f7_registered_scene'));
  for (var frame = 0; frame < 20 && registered.evaluate().isEmpty; frame++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    });
    await tester.pump(const Duration(milliseconds: 25));
  }
  await tester.pumpAndSettle();
  if (baked) {
    expect(registered, findsOneWidget);
  } else {
    expect(registered, findsNothing);
    expect(find.byKey(const Key('act0_shell_table_felt')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_guide_viewport')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_guide_scroll')),
      findsNothing,
    );
    expect(find.byIcon(Icons.south_rounded), findsOneWidget);
    final next = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    expect(next.hitTestable(), findsOneWidget);
    expect(tester.getRect(next).height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
    return;
  }
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
