// Actual host callbacks with synthetic directState bootstrap. NOT AppRoot,
// cold-start, genuine history, or a played-hand strategic truth certificate.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

Act0RunnerStateV1 current(WidgetTester t) => t
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
    .runner;
void main() {
  testWidgets(
    'controlled W7 miss CTA stays unavailable without repair or advance',
    (t) async {
      SharedPreferences.setMockInitialValues({});
      final sink = Act0InMemoryTelemetrySinkV1();
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      // Controlled directState harness only; sample locks and owner flags untouched.
      await t.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ru')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: Act0ShellStateV1.sample,
            telemetrySink: sink,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_7',
              lessonId: 'range_thinking_lite_combo_density',
              taskId: 'visible_king_combo_reduction_intro',
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      for (var i = 0; i < 12 && current(t).activeTeachingStep != null; i++) {
        final cta = find.byKey(const Key('act0_shell_theory_continue_cta'));
        await t.ensureVisible(cta);
        await t.pumpAndSettle();
        expect(cta.hitTestable(), findsOneWidget);
        await t.tap(cta);
        await t.pumpAndSettle();
      }
      expect(current(t).activeTeachingStep, isNull);
      final wrong = find.byKey(
        const Key('act0_shell_option_king_combos_unchanged'),
      );
      await t.ensureVisible(wrong);
      await t.pumpAndSettle();
      expect(wrong.hitTestable(), findsOneWidget);
      await t.tap(wrong);
      await t.pumpAndSettle();
      final dynamic host = t.state(find.byType(Act0ShellPreviewScreenV1));
      expect(host.debugSelectedWorldIdV1(), 'world_7');
      expect(current(t).selectedOptionId, 'king_combos_unchanged');
      expect(
        host.debugSelectedTaskIdV1(),
        'visible_king_combo_reduction_intro',
      );
      expect(host.debugPhaseV1(), 'review');
      final beforeEvents = sink.events.length;
      final beforeOutcomes = jsonEncode(
        host.debugRepairOutcomeProjectionPayloadV1(),
      );
      final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      await t.ensureVisible(cta);
      await t.pumpAndSettle();
      expect(cta.hitTestable(), findsOneWidget);
      await t.tap(cta);
      await t.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_explicit_repair_unavailable')),
        findsOneWidget,
      );
      expect(
        host.debugSelectedTaskIdV1(),
        'visible_king_combo_reduction_intro',
      );
      expect(host.debugSelectedWorldIdV1(), 'world_7');
      expect(host.debugPhaseV1(), 'review');
      expect(host.debugActiveRepairContextPayloadV1(), isEmpty);
      expect(
        jsonEncode(host.debugRepairOutcomeProjectionPayloadV1()),
        beforeOutcomes,
      );
      final events = sink.events.skip(beforeEvents).map((e) => e.name).toList();
      expect(
        events.where(
          (e) =>
              e.contains('repair_started') ||
              e.contains('task_completed') ||
              e.contains('xp_award'),
        ),
        isEmpty,
      );
      expect(t.takeException(), isNull);
      final output = Platform.environment['CUR01_OUTPUT'];
      expect(output, isNotNull);
      final dir = Directory(output!);
      dir.createSync(recursive: true);
      File('${dir.path}/w7-unavailable-host.json').writeAsStringSync(
        jsonEncode({
          'scope': 'CONTROLLED_DIRECT_STATE_NOT_ADMITTED_ROUTE',
          'taskUnchanged': true,
          'newTelemetryEvents': events,
          'fullAcceptance': false,
          'remaining': 'persisted legacy debt and XP storage proof not covered',
        }),
      );
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
    },
  );
}
