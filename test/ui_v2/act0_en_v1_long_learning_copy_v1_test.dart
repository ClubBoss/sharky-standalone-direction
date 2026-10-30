import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_salience_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'act0_teaching_integrity_harness_v1.dart';

void main() {
  setUpAll(act0LoadRealTextFontsV1);
  testWidgets(
    'long source question and causal feedback remain readable by swipe on 14 Pro',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final source = act0TeachingTaskByIdV1(
        'w11_trigger_bad_price_fold',
      ).task.runner;
      final feedback = source.options
          .firstWhere((o) => !o.isCorrect)
          .feedbackReason;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: Act0LearningSceneGuideV3(
                phase: Act0LearningScenePhaseV3.feedbackWrong,
                attentionPhase: Act0SceneAttentionPhaseV1.wrongFeedback,
                sharkyState: Act0SharkyCompanionStateV1.neutral,
                eyebrow: 'Read the source evidence',
                headline: source.question,
                support: feedback,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final text = find.byKey(const Key('act0_learning_scene_v3_support'));
      expect(tester.widget<Text>(text).data, feedback);
      expect(
        tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
        isFalse,
        reason: 'Causal explanation must not end at an ellipsis',
      );
      final scroll = find.byKey(
        const Key('act0_learning_scene_v3_feedback_scroll'),
      );
      expect(scroll, findsOneWidget);
      final state = tester.state<ScrollableState>(
        find.descendant(of: scroll, matching: find.byType(Scrollable)),
      );
      expect(state.position.maxScrollExtent, greaterThan(0));
      await tester.drag(scroll, const Offset(0, -160));
      await tester.pumpAndSettle();
      expect(state.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );
}
