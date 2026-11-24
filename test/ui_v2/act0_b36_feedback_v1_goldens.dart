// Run explicitly, like B32's skin goldens. Baselines are local output.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/skin/act0_skin_components_v1.dart';

void main() {
  const captureKey = Key('b36_feedback_capture');
  for (final grade in [
    Act0SkinFeedbackGradeV1.correct,
    Act0SkinFeedbackGradeV1.wrong,
    Act0SkinFeedbackGradeV1.repaired,
  ]) {
    testWidgets('Feedback panel · ${grade.name}', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final wrong = grade == Act0SkinFeedbackGradeV1.wrong;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: RepaintBoundary(
                key: captureKey,
                child: Act0LearningSceneGuideV3(
                  phase: wrong
                      ? Act0LearningScenePhaseV3.feedbackWrong
                      : Act0LearningScenePhaseV3.feedbackCorrect,
                  sharkyState: Act0SharkyCompanionStateV1.neutral,
                  feedbackGrade: grade,
                  eyebrow: grade.label,
                  headline: wrong
                      ? 'Not this one: Fold\nRight answer: Check'
                      : 'Right answer: Check',
                  support: 'No bet faces you.',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final verdict = find.byKey(const Key('act0_integrated_scene_purpose'));
      expect(verdict, findsOneWidget);
      final label = tester.widget<Text>(verdict);
      expect(label.data, grade.label);
      expect(label.style?.color, grade.tone);
      await expectLater(
        find.byKey(captureKey),
        matchesGoldenFile('../../output/b36_feedback/${grade.name}.png'),
      );
    });
  }
}
