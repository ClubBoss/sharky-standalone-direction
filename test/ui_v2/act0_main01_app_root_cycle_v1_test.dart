// SIMULATED normal production AppRoot journey on English iPhone 14 Pro.
// Uses current-main tasks only. Empty fake preferences are seeded once at boot.
// Widget remount/fake preferences do not prove native restart or Human learning.
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_first_start_preferences_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';
const _source = 'what_poker_is_table_read_transfer';
const _mappedRepair = 'what_poker_is_table_read_recheck';
const _nextTask = 'first_table_guide_one_clear_choice';

void main() {
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
