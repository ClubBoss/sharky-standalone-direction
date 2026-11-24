import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_catalog_snapshot_v1.dart';

void main() {
  final off = Act0ShellStateV1.catalog(liveRoomV1: false);
  final on = Act0ShellStateV1.catalog(liveRoomV1: true);
  final tasks = {
    for (final lesson in on.liveRoom!.lessons)
      for (final task in lesson.taskList) task.taskId: task,
  };

  test('Live Room is isolated from the numbered catalog', () {
    expect(off.liveRoom, isNull);
    expect(off.learningSections, orderedEquals(off.worlds));
    expect(
      Act0ShellStateV1.authoredCatalog.liveRoom != null,
      const bool.fromEnvironment('liveRoomV1'),
    );
    // The snapshot uses the same authored objects, in the same order.
    expect(on.worlds, same(off.worlds));
    expect(on.lessons, same(off.lessons));
    expect(on.worldById('live_room_v1'), same(on.liveRoom));
    expect(on.forLearners().liveRoom, same(on.liveRoom));
    expect(() => off.lessonById('verbal_action'), throwsStateError);
    expect(on.liveRoom!.lessons.map((lesson) => lesson.lessonId), [
      'verbal_action',
      'string_bets',
      'oversized_chip',
      'showdown',
      'room_fees',
      'live_open_sizes',
      'table_etiquette',
    ]);
    expect(
      tasks.keys,
      orderedEquals([
        'live_room_call_first',
        'live_room_raise_then_chips',
        'live_room_spoken_amount',
        'live_room_speak_first',
        'live_room_late_raise',
        'live_room_first_bet',
        'live_room_avoid_string',
        'live_room_silent_chip',
        'live_room_declare_chip_raise',
        'live_room_no_wager',
        'live_room_river_bet',
        'live_room_river_raise',
        'live_room_checked_river',
        'live_room_table_both',
        'live_room_cards_speak',
        'live_room_rake_below_cap',
        'live_room_rake_above_cap',
        'live_room_rake_win_rate',
        'live_room_time_charge',
        'live_room_time_win_rate',
        'live_room_unopened',
        'live_room_one_limper',
        'live_room_two_limpers',
        'live_room_early_call_unchanged',
        'live_room_early_call_changed',
        'live_room_protect_cards',
        'live_room_announce_all_in',
      ]),
    );
    expect(
      on.liveRoom!.lessons.expand((lesson) => lesson.taskList),
      hasLength(27),
    );
    for (final task in tasks.values) {
      expect(
        task.runner.options.where(act0RunnerOptionIsAuthoredCorrectV1),
        hasLength(1),
      );
      expect(task.entryPhase, Act0LessonPhaseV1.drill);
    }
    expect(
      tasks['live_room_checked_river']!.runner.caption,
      startsWith('In this room, when the river is checked around'),
    );
  });

  test('the numbered catalog still matches the release snapshot bytes', () {
    expect(
      utf8.encode(renderCatalogSnapshot(excludePilot: true)),
      File('test/fixtures/act0_catalog_snapshot_v1.txt').readAsBytesSync(),
    );
  });

  test('answer and feedback values follow the authored inputs', () {
    const bigBlind = 2;
    const cap = 5;
    const rakePercent = 10;
    const halfHourCharge = 6;
    const hours = 2;
    const baseOpen = 5;
    const perLimper = 1;
    String dollars(int value) => '\$$value';
    int rate(int dollars, int hands) =>
        (dollars / bigBlind * 100 / hands).round();

    void check(String id, String label, Iterable<String> feedback) {
      final answer = tasks['live_room_$id']!.runner.options.singleWhere(
        act0RunnerOptionIsAuthoredCorrectV1,
      );
      expect(answer.label, label);
      for (final fragment in feedback) {
        expect(answer.feedbackReason, contains(fragment), reason: id);
      }
    }

    for (final (id, pot) in [('rake_below_cap', 30), ('rake_above_cap', 80)]) {
      final uncapped = pot * rakePercent ~/ 100;
      final rake = math.min(cap, uncapped);
      final payout = pot - rake;
      check(id, dollars(payout), [
        dollars(uncapped),
        dollars(cap),
        dollars(pot),
        dollars(payout),
      ]);
    }
    const rakeHands = 100;
    const grossRakeDollars = 50;
    const paidRake = 20;
    const netRakeDollars = grossRakeDollars - paidRake;
    check(
      'rake_win_rate',
      'From +${rate(grossRakeDollars, rakeHands)} to +${rate(netRakeDollars, rakeHands)} BB/100',
      [
        dollars(netRakeDollars),
        '${rate(netRakeDollars, rakeHands)} BB',
        '${paidRake ~/ bigBlind} BB over $rakeHands hands',
      ],
    );
    const timeFee = hours * 2 * halfHourCharge;
    check('time_charge', '${dollars(timeFee)}, or ${timeFee ~/ bigBlind} BB', [
      dollars(halfHourCharge),
      dollars(timeFee),
      '${timeFee ~/ bigBlind} BB',
    ]);
    const timeHands = 60;
    const grossTimeDollars = 36;
    const netTimeDollars = grossTimeDollars - timeFee;
    check('time_win_rate', '+${rate(netTimeDollars, timeHands)} BB/100', [
      dollars(timeFee),
      dollars(netTimeDollars),
      '${netTimeDollars ~/ bigBlind} BB',
      '${rate(netTimeDollars, timeHands)} BB/100',
      '${rate(grossTimeDollars, timeHands)} BB/100',
      '${rate(timeFee, timeHands)} BB/100',
    ]);
    const highOpen = 6;
    const onlineOpen = 2.5;
    check(
      'unopened',
      'Live ${dollars(baseOpen * bigBlind)}–${dollars(highOpen * bigBlind)}, online-style ${dollars((onlineOpen * bigBlind).round())}',
      [dollars(bigBlind), '$baseOpen–$highOpen BB', '$onlineOpen BB'],
    );
    for (final (id, limpers) in [('one_limper', 1), ('two_limpers', 2)]) {
      final totalBb = baseOpen + limpers * perLimper;
      final total = dollars(totalBb * bigBlind);
      check(id, '$total total', ['$totalBb BB', total]);
    }
    final oneLimperMiss = tasks['live_room_one_limper']!.runner.options
        .singleWhere((option) => !option.isCorrect);
    expect(
      oneLimperMiss.feedbackReason,
      contains('Add ${dollars(perLimper * bigBlind)}'),
    );
  });

  testWidgets('Learn hides the entry with Live Room off', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.learn,
          showPlacementOnStart: false,
          state: off,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_live_room_v1')), findsNothing);
  });

  testWidgets(
    'Learn completes a Live Room lesson with a miss and restores it',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> boot() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Act0ShellPreviewScreenV1(
              initialTab: Act0ShellTabV1.learn,
              showPlacementOnStart: false,
              state: on,
              debugPersistFixtureProgress: true,
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> tap(String key) async {
        final target = find.byKey(Key(key));
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      Act0LessonRunnerShellV1 runner() =>
          tester.widget(find.byType(Act0LessonRunnerShellV1));

      Future<void> answer(String taskId, {bool correct = true}) async {
        expect(runner().selectedTaskId, taskId);
        final option = tasks[taskId]!.runner.options.singleWhere(
          (option) => option.isCorrect == correct,
        );
        await tap('act0_shell_option_${option.id}');
        expect(runner().runner.reviewQuality, option.quality);
        await tester.pump(const Duration(milliseconds: 900));
        await tap('act0_shell_continue_cta');
      }

      await boot();
      await tap('act0_shell_live_room_v1');
      await tap('act0_shell_current_mission_cta');
      expect(
        find.textContaining('This room binds the first clear'),
        findsWidgets,
      );
      await answer('live_room_call_first', correct: false);
      await answer('live_room_call_first');
      await answer('live_room_raise_then_chips');
      await answer('live_room_spoken_amount');
      await answer('live_room_speak_first');
      final shell = find.byType(Act0LessonRunnerShellV1);
      // The generic lesson wrap-up can recheck the earlier mistake.
      if (shell.evaluate().isNotEmpty) {
        await answer('live_room_call_first');
      }
      expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
      final store = Act0ProgressStoreV1(
        key: 'act0_shell_progress_v1',
        isValidPayload: (_) => true,
      );
      await tester.runAsync(store.flush);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await boot();

      if (find.byKey(const Key('act0_shell_learn_screen')).evaluate().isEmpty) {
        final learn = find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Learn'),
        );
        await tester.tap(learn);
        await tester.pumpAndSettle();
      }
      final moduleEntry = find.byKey(const Key('act0_shell_live_room_v1'));
      if (moduleEntry.evaluate().isNotEmpty) {
        await tap('act0_shell_live_room_v1');
      }
      await tap('act0_shell_current_mission_cta');
      expect(runner().selectedLessonId, 'string_bets');
      expect(runner().selectedTaskId, 'live_room_late_raise');
    },
  );
}
