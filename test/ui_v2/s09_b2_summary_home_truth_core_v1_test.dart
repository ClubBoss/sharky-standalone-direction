import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _oldSeed = Act0AchievementSeedConsumerV1(
  moments: [
    Act0AchievementMomentViewModelV1(
      seedId: act0AchievementSeedFirstCorrectReadV1,
      label: 'First correct read',
    ),
  ],
);

const _sourceHandoff = Act0SummaryNextHandoffV1(
  sourceTaskId: 'what_poker_is_find_hero',
  targetWorldId: 'world_1',
  targetLessonId: 'what_poker_is',
  targetTaskId: 'what_poker_is_find_hero',
  reasonCode: 'exact_replay_hero_identity',
  selectionSource: 'repair_intent_exact_replay',
  copyLine: 'Repeat the same hero clue before your next decision.',
);

const _cleanSummary = Act0BlockCompletionSummaryV1(
  lessonTitle: 'First table',
  xpEarned: 12,
  errorCount: 0,
  assistedCount: 0,
  independentProvenanceKnown: true,
  taskCount: 2,
  correctCount: 2,
  startLevel: 1,
  endLevel: 1,
  startXp: 10,
  endXp: 22,
  xpTarget: 100,
  nextLessonTitle: 'Next lesson',
);

const _assistedSummary = Act0BlockCompletionSummaryV1(
  lessonTitle: 'First table',
  xpEarned: 0,
  errorCount: 1,
  assistedCount: 1,
  independentProvenanceKnown: true,
  taskCount: 2,
  correctCount: 1,
  startLevel: 1,
  endLevel: 1,
  startXp: 10,
  endXp: 10,
  xpTarget: 100,
  nextLessonTitle: 'Next lesson',
);

Future<void> _pump(
  WidgetTester tester, {
  required Act0BlockCompletionSummaryV1 summary,
  required bool earnedNow,
  bool ru = false,
  Act0SummaryNextHandoffV1? next,
  VoidCallback? onNext,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(ru ? 'ru' : 'en'),
      supportedLocales: const [Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Act0BlockCompletionShellV1(
          summary: summary,
          firstCorrectEarnedThisRun: earnedNow,
          earnedMomentConsumer: _oldSeed,
          nextUsefulHand: next,
          onNextUsefulHand: onNext,
          onContinue: () {},
          onReplay: () {},
          onOpenReview: () {},
          onBackToMap: () {},
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 2200));
}

void main() {
  testWidgets(
    'root shares the exact Home source task, target and reason with Summary',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final sample = Act0ShellStateV1.sample;
      final baseWorld = sample.worldById('world_1');
      final baseLesson = baseWorld.lessons.firstWhere(
        (lesson) => lesson.lessonId == 'fold_check_call_raise',
      );
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: [
          baseLesson.taskList.firstWhere(
            (task) => task.taskId == 'actions_legal_context',
          ),
          baseLesson.taskList.firstWhere(
            (task) => task.taskId == 'actions_check_drill',
          ),
        ],
      );
      final world = baseWorld.copyWith(
        status: Act0WorldStateV1.current,
        isSelectable: true,
        isLocked: false,
        lessons: [lesson],
      );
      final state = Act0ShellStateV1(
        courseTitle: sample.courseTitle,
        courseSubtitle: sample.courseSubtitle,
        levelLabel: sample.levelLabel,
        xp: sample.xp,
        xpTarget: sample.xpTarget,
        streakDays: sample.streakDays,
        dailyGoalLabel: sample.dailyGoalLabel,
        dailyGoalValue: sample.dailyGoalValue,
        pathProgressLabel: sample.pathProgressLabel,
        selectedWorldId: 'world_1',
        worlds: [world],
        lessons: [lesson],
        review: sample.review,
        profile: sample.profile,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: state,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_legal_context',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
      await tester.pumpAndSettle();
      final shell =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final home =
          shell.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>;
      final summary =
          shell.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      expect(summary['sourceTaskId'], home['sourceTaskId']);
      expect(summary['targetTaskId'], home['targetTaskId']);
      expect(summary['targetLessonId'], home['targetLessonId']);
      expect(summary['targetWorldId'], home['targetWorldId']);
      expect(summary['reasonCode'], home['reasonCode']);
      expect(summary['selectionSource'], home['selectionSource']);
      expect(summary['copyLine'], shell.debugHomeNextUsefulHandReasonLineV1());
      expect(summary['sourceTaskId'], 'actions_legal_context');
      expect(summary['targetTaskId'], 'actions_check_drill');
    },
  );

  testWidgets('old saved first read is not presented as freshly earned', (
    tester,
  ) async {
    await _pump(tester, summary: _cleanSummary, earnedNow: false);
    expect(
      find.byKey(const Key('act0_shell_block_summary_earned_moment')),
      findsOneWidget,
    );
    expect(find.text('Saved earlier'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
      findsNothing,
    );
  });

  testWidgets('current independently earned first read retains source payoff', (
    tester,
  ) async {
    await _pump(tester, summary: _cleanSummary, earnedNow: true);
    expect(find.text('Collected read'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
      findsOneWidget,
    );
  });

  testWidgets('RU assisted result keeps original wrong and separate help', (
    tester,
  ) async {
    await _pump(tester, summary: _assistedSummary, earnedNow: false, ru: true);
    final outcome = find.byKey(const Key('act0_b2_summary_ru_assessed_truth'));
    expect(outcome, findsOneWidget);
    final line = tester.widget<Text>(outcome).data!;
    expect(
      line,
      contains(
        '\u043d\u0435 \u0434\u043e\u043a\u0430\u0437\u044b\u0432\u0430\u0435\u0442 \u0441\u0430\u043c\u043e\u0441\u0442\u043e\u044f\u0442\u0435\u043b\u044c\u043d\u043e\u0435 \u0440\u0435\u0448\u0435\u043d\u0438\u0435',
      ),
    );
    expect(
      find.text(
        '\u0421\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u043e \u0440\u0430\u043d\u0435\u0435',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
      findsNothing,
    );
    expect(find.text('1 with help'), findsNothing);
    final title = tester
        .widget<Text>(
          find.byKey(const Key('act0_shell_block_summary_habit_reward_label')),
        )
        .data!;
    expect(
      title,
      '\u0427\u0442\u043e \u0442\u0440\u0435\u043d\u0438\u0440\u043e\u0432\u0430\u043b\u0438',
    );
    final detail = tester
        .widget<Text>(
          find.byKey(const Key('act0_shell_block_summary_habit_reward_detail')),
        )
        .data!;
    expect(detail, contains('\u041e\u0448\u0438\u0431\u043a'));
    expect(detail, isNot(contains('This read will help')));
  });

  testWidgets('RU primary and secondary Summary CTA labels are native', (
    tester,
  ) async {
    await _pump(tester, summary: _cleanSummary, earnedNow: true, ru: true);
    expect(find.text('Replay for perfect'), findsNothing);
    expect(find.text('Back to map'), findsNothing);
    expect(find.text('What improved'), findsNothing);
    if (_cleanSummary.secondaryCtaLabel != null) {
      expect(find.text('Replay for perfect'), findsNothing);
    }
    expect(
      find.text(
        '\u041a \u043a\u0430\u0440\u0442\u0435 \u0443\u0440\u043e\u043a\u043e\u0432',
      ),
      findsOneWidget,
    );
  });

  testWidgets('RU unknown independent evidence never invents a clean result', (
    tester,
  ) async {
    const uncertain = Act0BlockCompletionSummaryV1(
      lessonTitle: 'First table',
      xpEarned: 0,
      errorCount: 0,
      assistedCount: 1,
      independentProvenanceKnown: false,
      taskCount: 2,
      correctCount: 2,
      startLevel: 1,
      endLevel: 1,
      startXp: 0,
      endXp: 0,
      xpTarget: 100,
    );
    await _pump(tester, summary: uncertain, earnedNow: false, ru: true);
    final line = tester
        .widget<Text>(
          find.byKey(const Key('act0_b2_summary_ru_assessed_truth')),
        )
        .data!;
    expect(
      line,
      contains(
        '\u043d\u0435 \u043f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0451\u043d',
      ),
    );
    expect(
      line,
      isNot(
        contains(
          '\u0432\u0435\u0440\u043d\u043e \u0441 \u043f\u0435\u0440\u0432\u043e\u0439',
        ),
      ),
    );
  });

  testWidgets('source task, target and reason survive Summary CTA unchanged', (
    tester,
  ) async {
    var invoked = 0;
    await _pump(
      tester,
      summary: _assistedSummary,
      earnedNow: false,
      next: _sourceHandoff,
      onNext: () => invoked++,
    );
    expect(find.text(_sourceHandoff.copyLine), findsOneWidget);
    expect(_sourceHandoff.toPayload(), {
      'sourceTaskId': 'what_poker_is_find_hero',
      'targetWorldId': 'world_1',
      'targetLessonId': 'what_poker_is',
      'targetTaskId': 'what_poker_is_find_hero',
      'reasonCode': 'exact_replay_hero_identity',
      'selectionSource': 'repair_intent_exact_replay',
      'copyLine': 'Repeat the same hero clue before your next decision.',
    });
    final action = tester.widget<FilledButton>(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    action.onPressed!();
    expect(invoked, 1);
  });

  testWidgets(
    'one real wrong answer generates identical Summary/Home receipt IDs',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final sample = Act0ShellStateV1.sample;
      final baseWorld = sample.worldById('world_1');
      final baseLesson = baseWorld.lessons.firstWhere(
        (lesson) => lesson.lessonId == 'fold_check_call_raise',
      );
      final taskIds = ['actions_legal_context', 'actions_check_drill'];
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: [
          for (final id in taskIds)
            baseLesson.taskList.firstWhere((task) => task.taskId == id),
        ],
      );
      final world = baseWorld.copyWith(
        status: Act0WorldStateV1.current,
        isSelectable: true,
        isLocked: false,
        lessons: [lesson],
      );
      final host = Act0ShellStateV1(
        courseTitle: sample.courseTitle,
        courseSubtitle: sample.courseSubtitle,
        levelLabel: sample.levelLabel,
        xp: sample.xp,
        xpTarget: sample.xpTarget,
        streakDays: sample.streakDays,
        dailyGoalLabel: sample.dailyGoalLabel,
        dailyGoalValue: sample.dailyGoalValue,
        pathProgressLabel: sample.pathProgressLabel,
        selectedWorldId: 'world_1',
        worlds: [world],
        lessons: [lesson],
        review: sample.review,
        profile: sample.profile,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ru')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: host,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_legal_context',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
      await tester.pumpAndSettle();
      final root =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final legacy =
          root.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>?;
      final b2 = root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      final copy =
          root.debugNextUsefulHandCopyBridgePayloadV1() as Map<String, Object?>;
      expect(legacy, isNotNull);
      for (final key in [
        'sourceTaskId',
        'targetWorldId',
        'targetLessonId',
        'targetTaskId',
        'selectionSource',
        'reasonCode',
      ]) {
        expect(
          b2[key],
          legacy![key],
          reason: 'Summary and Home divergent at $key',
        );
      }
      expect(b2['sourceTaskId'], 'actions_legal_context');
      expect(b2['targetTaskId'], 'actions_check_drill');
      expect(b2['copyLine'], root.debugHomeNextUsefulHandReasonLineV1());
      expect(b2['reasonCode'], copy['reasonCode']);
    },
  );

  testWidgets('fallback without source repair cannot hijack continuation', (
    tester,
  ) async {
    const fallback = Act0SummaryNextHandoffV1(
      sourceTaskId: '',
      targetWorldId: 'world_1',
      targetLessonId: 'what_poker_is',
      targetTaskId: 'what_poker_is_find_hero',
      reasonCode: '',
      selectionSource: 'existing_fallback',
      copyLine: 'Should not replace forward plan.',
    );
    var invoked = 0;
    await _pump(
      tester,
      summary: _cleanSummary,
      earnedNow: false,
      next: fallback,
      onNext: () => invoked++,
    );
    expect(fallback.isActionableRepair, false);
    expect(find.text('Should not replace forward plan.'), findsNothing);
    final action = tester.widget<FilledButton>(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    action.onPressed!();
    expect(invoked, 0);
  });
}
