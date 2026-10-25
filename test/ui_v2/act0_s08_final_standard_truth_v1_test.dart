import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_salience_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

void main() {
  testWidgets('Home neutral Learn is never earned by Practice callback', (
    tester,
  ) async {
    var practiceOpened = false;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0HomeShellV1(
            state: Act0ShellStateV1.sample,
            pathProgressLabel: '0 of 9 lessons complete',
            onContinue: () {},
            onOpenPracticeContext: () => practiceOpened = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final learn = find.byKey(const Key('act0_shell_home_checklist_row_learn'));
    expect(learn, findsOneWidget);
    expect(
      find.descendant(of: learn, matching: find.byIcon(Icons.check_rounded)),
      findsNothing,
    );
    expect(
      find.descendant(
        of: learn,
        matching: find.byIcon(Icons.check_circle_outline_rounded),
      ),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_home_checklist_step_label_learn')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_proof_momentum_line')),
      findsNothing,
    );
    final practice = find.byKey(
      const Key('act0_shell_home_daily_practice_now'),
    );
    await tester.ensureVisible(practice);
    await tester.tap(practice);
    expect(practiceOpened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Home hero is the sole next callout and source repair stays reachable',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final size in <Size>[
        const Size(375, 667),
        const Size(402, 874),
        const Size(430, 932),
      ]) {
        String? openedJobId;
        tester.view.physicalSize = size;
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(size),
            home: Scaffold(
              body: Act0HomeShellV1(
                state: Act0ShellStateV1.sample,
                nextActionTitle: 'Repair the position read',
                nextActionCtaLabel: 'Repair now',
                dailyGoalValue: '0/3',
                showChecklist: true,
                dailyPlanJobs: const <Act0HomePlanJobV1>[
                  Act0HomePlanJobV1(
                    jobId: 'repair:position_read',
                    label: 'Repair',
                    title: 'Miss: table position',
                  ),
                ],
                onOpenDailyPlanJob: (jobId) => openedJobId = jobId,
                onOpenPracticeContext: () {},
                onOpenReviewContext: () {},
                onContinue: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('act0_shell_home_v6_primary_cta')),
          findsOneWidget,
        );
        expect(find.text('Repair now'), findsOneWidget);
        expect(find.text('Next'), findsNothing);
        expect(
          find.text('Next useful hand'),
          findsNothing,
          reason: 'No second priority cue below the primary hero CTA',
        );

        final repair = find.byKey(
          const Key('act0_shell_home_plan_job_repair:position_read'),
        );
        expect(repair, findsOneWidget);
        await tester.ensureVisible(repair);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('act0_shell_home_repair_panel')),
          findsOneWidget,
        );
        expect(find.text('Miss: table position'), findsOneWidget);
        await tester.tap(repair);
        expect(openedJobId, 'repair:position_read');
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0HomeShellV1(
              state: Act0ShellStateV1.sample,
              dailyGoalValue: '0/3',
              showChecklist: true,
              onOpenPracticeContext: () {},
              onOpenReviewContext: () {},
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_home_repair_panel')),
        findsNothing,
      );
      final neutralReview = find.descendant(
        of: find.byKey(const Key('act0_shell_home_checklist_row_review')),
        matching: find.byType(InkWell),
      );
      expect(tester.widget<InkWell>(neutralReview).onTap, isNull);
      expect(find.text('Next'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0HomeShellV1(
              state: Act0ShellStateV1.sample,
              dailyGoalValue: '3/3',
              showChecklist: true,
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_home_daily_done_badge')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_home_focus_checklist')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Standard RU theory support stays fully scroll-reachable', (
    tester,
  ) async {
    const support =
        '\u0423 \u043a\u0430\u0436\u0434\u043e\u0433\u043e \u0438\u0433\u0440\u043e\u043a\u0430 2 \u0437\u0430\u043a\u0440\u044b\u0442\u044b\u0435 \u043a\u0430\u0440\u0442\u044b. '
        '\u041d\u0430 \u0441\u0442\u043e\u043b \u0432\u044b\u0445\u043e\u0434\u044f\u0442 5 \u043e\u0431\u0449\u0438\u0445 \u043a\u0430\u0440\u0442. '
        '\u041b\u0443\u0447\u0448\u0430\u044f \u0440\u0443\u043a\u0430 \u0441\u043e\u0431\u0438\u0440\u0430\u0435\u0442\u0441\u044f \u0438\u0437 \u043b\u044e\u0431\u044b\u0445 \u043f\u044f\u0442\u0438 '
        '\u043a\u0430\u0440\u0442 \u0438\u0437 \u0441\u0435\u043c\u0438. '
        '\u0426\u0435\u043d\u043d\u043e\u0441\u0442\u044c \u0444\u0438\u0448\u0435\u043a \u0432 \u043a\u044d\u0448-\u0438\u0433\u0440\u0435 \u043d\u0435 \u043c\u0435\u043d\u044f\u0435\u0442\u0441\u044f.';
    tester.view.physicalSize = const Size(360, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: Act0LearningSceneGuideV3(
              phase: Act0LearningScenePhaseV3.theory,
              attentionPhase: Act0SceneAttentionPhaseV1.theory,
              sharkyState: Act0SharkyCompanionStateV1.neutral,
              eyebrow: 'ONE TABLE IDEA',
              headline: 'Cash game basics',
              support: support,
              focusLabel: 'Look at: Read',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scroll = find.byKey(
      const Key('act0_learning_scene_v3_theory_support_scroll'),
    );
    expect(scroll, findsOneWidget);
    final content = tester.widget<Text>(
      find.byKey(const Key('act0_learning_scene_v3_support')),
    );
    expect(content.data, support);
    expect(content.maxLines, isNull);
    final render = tester.renderObject<RenderParagraph>(
      find.byKey(const Key('act0_learning_scene_v3_support')),
    );
    expect(render.didExceedMaxLines, isFalse);
    final scroller = tester.state<ScrollableState>(
      find.descendant(of: scroll, matching: find.byType(Scrollable)),
    );
    expect(scroller.position.maxScrollExtent, greaterThan(0));
    await tester.drag(scroll, const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(scroller.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Welcome CTA tells the truth for recommended lesson vs path', (
    tester,
  ) async {
    Future<void> verify(bool direct, String targetLabel) async {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey('welcome_$direct'),
          home: Act0WelcomeShellV1(
            replayMode: false,
            handoffStartsRecommendedTask: direct,
            onCompleted: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
      await tester.pumpAndSettle();
      final demo = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      demo.onChooseOption(demo.runner.options.first);
      await tester.pumpAndSettle();
      expect(find.text(targetLabel), findsOneWidget);
    }

    await verify(false, 'Open my path');
    await verify(true, 'Start recommended lesson');
  });
}
