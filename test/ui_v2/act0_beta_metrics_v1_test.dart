import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_beta_metrics_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _first = DateTime.utc(2026, 11, 19, 12);

class _Clock implements Act0UtcClockV1 {
  DateTime time = _first;

  @override
  DateTime nowUtc() => time;
}

void main() {
  test('return windows are elapsed time and can be missed or still open', () {
    final start = DateTime.parse('2026-03-07T18:00:00-05:00');
    final beforeDay2 = DateTime.parse('2026-03-08T18:59:59-04:00');
    final atDay2 = DateTime.parse('2026-03-08T19:00:00-04:00');
    final day7 = start.add(const Duration(days: 6));
    final afterDay7 = start.add(const Duration(days: 7));
    final empty = Act0BetaActivityV1.firstVisit(start);
    expect(
      empty.visitAt(beforeDay2).day2At(beforeDay2),
      Act0BetaReturnV1.pending,
    );
    final returned = empty.visitAt(atDay2).visitAt(day7);
    expect(returned.day2At(afterDay7), Act0BetaReturnV1.returned);
    expect(returned.day7At(afterDay7), Act0BetaReturnV1.returned);
    expect(returned.visitAt(day7), same(returned));
    final late = empty.visitAt(afterDay7);
    expect(late.day2At(afterDay7), Act0BetaReturnV1.missed);
    expect(late.day7At(afterDay7), Act0BetaReturnV1.missed);
    expect(late.visitAt(atDay2), same(late));
    expect(late.day2At(start), Act0BetaReturnV1.missed);
    expect(
      empty.visitAt(start.subtract(const Duration(minutes: 1))),
      same(empty),
    );
    expect(
      empty.visitAt(start.add(const Duration(days: 2))).returnedDay2,
      isFalse,
    );
  });

  test('course numbers count earned tasks; route skips do not count', () {
    final w1 = Act0ShellStateV1.sample.worldById('world_1');
    final all = {
      for (final lesson in w1.lessons)
        ...lesson.taskList.map((task) => task.taskId),
    };
    final first = w1.lessons.first.taskList.map((task) => task.taskId).toSet();
    final started = Act0BetaLearningMetricsV1.fromProgress(
      firstWorld: w1,
      completedTaskIds: all.difference(first),
      correctedMistakes: 0,
    );
    expect(started.firstLessonCompleted, isFalse);
    expect(started.worldOneCompleted, isFalse);
    final finished = Act0BetaLearningMetricsV1.fromProgress(
      firstWorld: w1,
      completedTaskIds: all,
      correctedMistakes: 3,
    );
    expect(finished.firstLessonCompleted, isTrue);
    expect(finished.worldOneCompleted, isTrue);
    expect(finished.correctedMistakes, 3);
  });

  test('only bounded return and survey data survive reload', () async {
    SharedPreferences.setMockInitialValues({});
    await Act0BetaMetricsStoreV1.recordVisit(_first);
    await Future.wait([
      Act0BetaMetricsStoreV1.recordVisit(_first.add(const Duration(days: 1))),
      Act0BetaMetricsStoreV1.setAnswer(0, Act0BetaSurveyAnswerV1.yes),
      Act0BetaMetricsStoreV1.setAnswer(1, Act0BetaSurveyAnswerV1.unsure),
    ]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = jsonDecode(prefs.getString(Act0BetaMetricsStoreV1.key)!) as Map;
    expect(raw.keys.toSet(), {
      'version',
      'firstVisitUtc',
      'observedDay',
      'returnedDay2',
      'returnedDay7',
      'answers',
    });
    final restored = (await Act0BetaMetricsStoreV1.read())!;
    expect(restored.returnedDay2, isTrue);
    expect(restored.answers, [
      Act0BetaSurveyAnswerV1.yes,
      Act0BetaSurveyAnswerV1.unsure,
      null,
    ]);
  });

  test(
    'invalid activity is unavailable instead of becoming a fresh cohort',
    () async {
      SharedPreferences.setMockInitialValues({
        Act0BetaMetricsStoreV1.key: '{"version":100}',
      });
      await Act0BetaMetricsStoreV1.recordVisit(_first);
      expect(await Act0BetaMetricsStoreV1.read(), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(Act0BetaMetricsStoreV1.key), '{"version":100}');
    },
  );

  testWidgets(
    'beta foreground records a return and Settings shows local feedback',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      Future<void> settle() async {
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 3),
        );
      }

      final clock = _Clock();
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.profile,
            showPlacementOnStart: false,
            enableBetaMetrics: true,
            clock: clock,
          ),
        ),
      );
      await settle();
      clock.time = _first.add(const Duration(days: 1));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle();
      final interruption = await tester.runAsync(Act0BetaMetricsStoreV1.read);
      expect(interruption!.returnedDay2, isFalse);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle();

      await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
      await settle();
      final entry = find.byKey(const Key('act0_settings_beta_activity'));
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await settle();
      expect(find.text('Day 2: Returned'), findsOneWidget);
      expect(find.text('Day 7: Still open'), findsOneWidget);
      expect(find.text('Corrected mistakes: 0'), findsOneWidget);

      final yes = find.widgetWithText(ChoiceChip, 'Yes').first;
      await tester.ensureVisible(yes);
      await tester.tap(yes);
      await settle();
      expect(tester.widget<ChoiceChip>(yes).selected, isTrue);
      final activity = await tester.runAsync(Act0BetaMetricsStoreV1.read);
      expect(activity!.answers.first, Act0BetaSurveyAnswerV1.yes);

      final prefs = await tester.runAsync(SharedPreferences.getInstance);
      expect(prefs!.containsKey('act0_shell_progress_v1_head'), isFalse);
    },
  );
}
