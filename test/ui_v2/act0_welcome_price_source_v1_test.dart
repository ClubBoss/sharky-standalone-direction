import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

void main() {
  for (final choiceId in <String>['fold', 'check', 'call']) {
    testWidgets(
      'Welcome $choiceId only acknowledges an ungraded source-owned preview',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues(<String, Object>{});
        var completionCallbacks = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Act0WelcomeShellV1(
              replayMode: false,
              handoffStartsRecommendedTask: true,
              onCompleted: () => completionCallbacks++,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('act0_shell_welcome_primary_cta')),
        );
        await tester.pumpAndSettle();
        final preview = tester.widget<Act0LessonRunnerShellV1>(
          find.byKey(const Key('act0_shell_welcome_demo_spot')),
        );
        expect(preview.selectedTaskId, 'actions_check_drill');
        expect(preview.selectedLessonId, isNull);
        expect(preview.telemetrySink, isNull);
        expect(preview.onCompletedDecision, isNull);
        expect(preview.runner.returnTarget, 'Welcome');
        final option = preview.runner.options.singleWhere(
          (option) => option.id == choiceId,
        );
        final price = act0BettingPriceForOptionV1(
          preview.runner.table,
          option,
          taskId: preview.selectedTaskId,
          question: preview.runner.question,
        );
        expect(price.reason, 'source_action_definition');
        expect(price.appliesToWager, isFalse);
        expect(price.sourceReady, isFalse);
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            preview.runner.table,
            option,
            taskId: preview.selectedTaskId,
            question: preview.runner.question,
          ),
          isFalse,
        );
        await tester.tap(find.byKey(Key('act0_shell_option_$choiceId')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('act0_shell_welcome_handoff_preview')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_shell_welcome_demo_spot')),
          findsNothing,
        );
        expect(completionCallbacks, 0);
        expect(
          (await SharedPreferences.getInstance()).getString(
            'act0_shell_progress_v1',
          ),
          isNull,
        );
        await tester.tap(
          find.byKey(const Key('act0_shell_welcome_primary_cta')),
        );
        await tester.pumpAndSettle();
        expect(completionCallbacks, 1);
      },
    );
  }
}
