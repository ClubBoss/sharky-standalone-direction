import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

// TEST-ONLY PROPOSAL / NOT_RUN. Reuses the existing W1 repair-route fixture's
// Preview debugHarnessEntry; adds no unlock, injected grade or state setter.
// Tests the Preview consumer contract, not ordinary W1-to-W12 navigation,
// native presentation, durable restart or Human learning.
void main() {
  for (final price in [10, 40]) {
    testWidgets('Preview owns ASM05 Call$price grade and actual outcome evidence',
        (tester) async {
      final taskId = 'asm05_new_known_holes_turn_call_$price';
      final correct = price == 10;
      final sink = Act0InMemoryTelemetrySinkV1();
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'), supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.learn,
          initialPhase: Act0LessonPhaseV1.drill,
          showPlacementOnStart: false,
          state: Act0ShellStateV1.sample,
          telemetrySink: sink,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_12', lessonId: 'decision_over_outcome', taskId: taskId,
          ),
        ),
      ));
      // Let the actual existing choreography/readiness path finish.
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      Act0LessonRunnerShellV1 consumer() => tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(consumer().selectedTaskId, taskId);
      expect(consumer().runner.phase, Act0LessonPhaseV1.drill);
      expect(consumer().runner.selectedOptionId, isNull);
      expect(consumer().runner.table.boardCards, hasLength(4));
      final before = _mountedText(tester);
      // These are instructional model facts, not optional answer hints.
      for (final fact in ['SB holds As Ad', 'both players must check',
          'Raises are excluded', 'No ante or rake', '100 BB', 'Uniform deck',
          'prescribed independently of unknown cards']) {
        expect(before, contains(fact), reason: 'Model assumption must be available in UI: $fact');
      }
      expect(find.textContaining('Call $price BB or fold'), findsOneWidget);
      final modelSupport = find.byKey(
        const Key('act0_learning_scene_v3_model_support_scroll'),
      );
      expect(modelSupport, findsOneWidget);
      final supportScrollable = find.descendant(
        of: modelSupport,
        matching: find.byType(Scrollable),
      );
      expect(supportScrollable, findsOneWidget);
      final supportPosition =
          tester.state<ScrollableState>(supportScrollable).position;
      expect(supportPosition.maxScrollExtent, greaterThan(0));
      await tester.drag(modelSupport, const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(supportPosition.pixels, greaterThan(0));
      final future = RegExp(r'River (Td|5h):|Call EV |SB receives 60 BB|You receive 120 BB|Correct decision|has the higher expected value');
      expect(future.hasMatch(before), isFalse);
      expect(find.bySemanticsLabel(future), findsNothing);
      expect(sink.events.where((e) => e.name == 'decision_evidence_recorded'), isEmpty);

      // Only a real UI tap; Preview owns every callback, grade and evidence append.
      final call = find.byKey(const Key('act0_shell_option_call'));
      await tester.ensureVisible(call);
      await tester.tap(call);
      await tester.pumpAndSettle();
      expect(consumer().runner.phase, Act0LessonPhaseV1.review);
      expect(consumer().runner.selectedOptionId, 'call');
      expect(consumer().runner.reviewQuality,
          correct ? Act0FeedbackQualityV1.correct : Act0FeedbackQualityV1.wrong);
      final after = _mountedText(tester);
      expect(after, contains(correct ? 'River Td: SB receives 60 BB.'
          : 'River 5h: You receive 120 BB.'));
      expect(after, contains(correct ? 'Stacks You 70, SB 130.'
          : 'Stacks You 160, SB 40.'));
      // The production Preview emits this only after appending its real
      // completed decision and resolving current authored evidence.
      final recorded = sink.events.where((e) => e.name == 'decision_evidence_recorded'
          && e.fields['task_id'] == taskId).toList();
      expect(recorded, hasLength(1));
      final fields = recorded.single.fields;
      expect(fields['source_surface'], 'act0_completed_evidence');
      expect(fields['source_current'], isTrue);
      expect(fields['world_id'], 'world_12');
      expect(fields['lesson_id'], 'decision_over_outcome');
      expect(fields['chosen_action'], 'call');
      expect(fields['expected_action'], correct ? 'call' : 'fold');
      expect(fields['correct'], correct);
      expect(fields['concept_family_id'], 'process_over_outcome');
      expect(fields['assistance_kind'], 'none');
      final fingerprint = act0CurrentAuthoredSourceFingerprintForIdentityV1(
        worldId: 'world_12', lessonId: 'decision_over_outcome', taskId: taskId,
      );
      expect(fingerprint, isNotNull);
      expect(fields['source_fingerprint'], fingerprint);
      await tester.pump();
      expect(sink.events.where((e) => e.name == 'decision_evidence_recorded'
          && e.fields['task_id'] == taskId), hasLength(1));
    });
  }
}

String _mountedText(WidgetTester tester) {
  final root = find.byType(Act0ShellPreviewScreenV1);
  final text = tester.widgetList<Text>(find.descendant(of: root, matching: find.byType(Text)))
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '');
  final rich = tester.widgetList<RichText>(find.descendant(of: root, matching: find.byType(RichText)))
      .map((t) => t.text.toPlainText());
  return [...text, ...rich].join(' ');
}
