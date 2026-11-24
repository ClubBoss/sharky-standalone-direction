import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/skin/act0_skin_components_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final expression = find.byType(Act0SkinSharkyExpressionV1);
  final legacyMascot = find.byType(Act0SharkyPresenceMascotV1);
  void expectSlot(WidgetTester tester, Act0SkinSharkyMomentV1? allowed) {
    expect(legacyMascot, findsNothing);
    if (allowed == null) {
      expect(expression, findsNothing);
    } else {
      expect(expression, findsOneWidget);
      expect(
        tester.widget<Act0SkinSharkyExpressionV1>(expression).moment,
        allowed,
      );
    }
  }

  testWidgets('Sharky stays off the shell tabs and Settings', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboardingCompleted': true,
      'act0_welcome_completed_v1': true,
    });
    await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
    await tester.pumpAndSettle();
    for (final tab in ['home', 'learn', 'play', 'review', 'profile']) {
      await tester.tap(find.byKey(Key('act0_shell_nav_$tab')));
      await tester.pumpAndSettle();
      expectSlot(tester, null);
    }
    await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
    await tester.pumpAndSettle();
    expectSlot(tester, null);
  });

  testWidgets('Welcome and Result use their assigned expressions', (
    tester,
  ) async {
    Future<void> show(Widget child) =>
        tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    await show(Act0WelcomeShellV1(replayMode: false, onCompleted: () {}));
    expectSlot(tester, Act0SkinSharkyMomentV1.idle);
    expect(tester.getSize(expression), const Size.square(56));
    await show(
      Act0BlockCompletionShellV1(
        summary: const Act0BlockCompletionSummaryV1(
          lessonTitle: 'Read the table',
          xpEarned: 10,
          errorCount: 0,
          taskCount: 1,
          correctCount: 1,
          startLevel: 1,
          endLevel: 1,
          startXp: 0,
          endXp: 10,
          xpTarget: 100,
          curriculumCompleted: true,
        ),
        onContinue: () {},
        onBackToMap: () {},
      ),
    );
    expectSlot(tester, Act0SkinSharkyMomentV1.lessonDone);
  });

  testWidgets('decision and ordinary correct feedback have no Sharky slot', (
    tester,
  ) async {
    for (final (phase, grade, assisted, slot) in [
      (Act0LearningScenePhaseV3.tableTask, null, false, null),
      (
        Act0LearningScenePhaseV3.feedbackCorrect,
        Act0SkinFeedbackGradeV1.correct,
        false,
        null,
      ),
      (
        Act0LearningScenePhaseV3.feedbackWrong,
        Act0SkinFeedbackGradeV1.wrong,
        false,
        Act0SkinSharkyMomentV1.mistake,
      ),
      (
        Act0LearningScenePhaseV3.feedbackCorrect,
        Act0SkinFeedbackGradeV1.assisted,
        true,
        Act0SkinSharkyMomentV1.hint,
      ),
      (
        Act0LearningScenePhaseV3.feedbackCorrect,
        Act0SkinFeedbackGradeV1.repaired,
        true,
        Act0SkinSharkyMomentV1.selfFix,
      ),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LearningSceneGuideV3(
              phase: phase,
              feedbackGrade: grade,
              isAssistedFeedback: assisted,
              sharkyState: Act0SharkyCompanionStateV1.neutral,
              eyebrow: 'Feedback',
              headline: 'Read the table',
              support: 'Look at the pot.',
            ),
          ),
        ),
      );
      expectSlot(tester, slot);
    }
  });
}
