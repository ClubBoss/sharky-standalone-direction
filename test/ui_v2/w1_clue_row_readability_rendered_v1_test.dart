import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _viewport = Size(375, 812);
const _clueKey = Key('act0_shell_feedback_signal_proof_label');
const _clueRowKey = Key('act0_shell_feedback_signal_proof');
const _ctaKey = Key('act0_shell_feedback_continue_cta');

void main() {
  Future<void> pumpActionSurface(
    WidgetTester tester, {
    required Act0ControlledDemoCaptureSurfaceV1 surface,
    required double textScale,
  }) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: RepaintBoundary(
          child: Act0ShellPreviewScreenV1(
            key: ValueKey<String>('w1_clue_${surface.name}_$textScale'),
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: surface,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_check_drill',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapReachable(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    final rect = tester.getRect(finder);
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(_viewport.height));
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  void expectVisibleClue(WidgetTester tester) {
    final clue = find.byKey(_clueKey);
    final row = find.byKey(_clueRowKey);
    expect(clue, findsOneWidget);
    expect(row, findsOneWidget);
    expect(
      tester.widget<Text>(clue).data,
      'Nobody had bet yet - that was the clue.',
    );
    final clueRect = tester.getRect(clue);
    final rowRect = tester.getRect(row);
    expect(clueRect.top, greaterThanOrEqualTo(rowRect.top));
    expect(clueRect.bottom, lessThanOrEqualTo(rowRect.bottom));
    expect(clueRect.height, greaterThan(20));
    expect(tester.takeException(), isNull);
  }

  Future<Rect> reachRecheckReceipt(WidgetTester tester) async {
    await tapReachable(
      tester,
      find.byKey(const Key('act0_shell_option_check')),
    );
    await tapReachable(tester, find.byKey(_ctaKey));
    await tapReachable(
      tester,
      find.byKey(const Key('act0_shell_option_check')),
    );
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    return tester.getRect(find.byKey(const Key('act0_shell_table')));
  }

  testWidgets(
    'W1 wrong feedback and recheck receipt keep the wrapped clue visible at compact 1.0x',
    (tester) async {
      await pumpActionSurface(
        tester,
        surface: Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback,
        textScale: 1,
      );
      final wrongTable = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      expectVisibleClue(tester);
      await tapReachable(tester, find.byKey(_ctaKey));

      final recheckTable = await reachRecheckReceipt(tester);
      expectVisibleClue(tester);
      expect(recheckTable.width, closeTo(wrongTable.width, 0.1));
      expect(recheckTable.height, closeTo(wrongTable.height, 0.1));
      expect(
        tester.widget<FilledButton>(find.byKey(_ctaKey)).onPressed,
        isNotNull,
      );
    },
  );

  testWidgets(
    'W1 wrong feedback and recheck receipt keep clue and CTA reachable at compact 1.4x',
    (tester) async {
      await pumpActionSurface(
        tester,
        surface: Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback,
        textScale: 1.4,
      );
      await tester.ensureVisible(find.byKey(_clueKey));
      await tester.pumpAndSettle();
      expectVisibleClue(tester);
      await tapReachable(tester, find.byKey(_ctaKey));

      await reachRecheckReceipt(tester);
      await tester.ensureVisible(find.byKey(_clueKey));
      await tester.pumpAndSettle();
      expectVisibleClue(tester);
      await tapReachable(tester, find.byKey(_ctaKey));
    },
  );
}
