// B7 canonical scene composition: the table-geometry invariant guard.
//
// `TABLE_GEOMETRY_INVARIANT_V1` says one viewport owns one physical poker
// scene. Before B7 the same renderer received a different `maxTableHeight` in
// review states, so answering a question rescaled the physical world. This
// guard drives the real learning loop and asserts the physical scene does not
// move, at one canonical text scale, on all three phone viewports.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The physical scene anchors that may not move between learning states.
const _invariantAnchorsV1 = <String, Key>{
  'felt rect': Key('act0_shell_table_felt'),
  'table object': Key('act0_integrated_scene_perspective_silhouette'),
  'board anchor': Key('act0_shell_card_board_0'),
  'hero anchor': Key('act0_shell_card_hero_0'),
  'pot anchor': Key('act0_shell_wave1_pot_priority_stat'),
  'far seat anchor': Key('act0_scene_player_figure_utg'),
};

const _viewportsV1 = <String, Size>{
  'compact_375x812': Size(375, 812),
  'canonical_402x874': Size(402, 874),
  'large_430x932': Size(430, 932),
};

/// One physical pixel of tolerance is already too generous for a geometry that
/// is supposed to be resolved from a single camera, so hold half of one.
const _toleranceV1 = 0.5;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  Widget host(Object remountKey) => MaterialApp(
    home: Act0ShellPreviewScreenV1(
      key: ValueKey<Object>(remountKey),
      state: Act0ShellStateV1.sample,
      showPlacementOnStart: false,
      debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
        mode: Act0ControlledDemoCaptureModeV1.directState,
        surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
        worldId: 'world_1',
        lessonId: 'fold_check_call_raise',
        taskId: 'actions_check_drill',
      ),
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    var frames = 0;
    while (tester.binding.hasScheduledFrame && frames < 400) {
      await tester.pump(const Duration(milliseconds: 16));
      frames++;
    }
  }

  Future<void> hop(WidgetTester tester, Key key) async {
    expect(find.byKey(key), findsWidgets, reason: 'route control $key');
    await tester.tap(find.byKey(key).first, warnIfMissed: false);
    await settle(tester);
  }

  Map<String, Rect> physicalScene(WidgetTester tester) {
    final scene = <String, Rect>{};
    _invariantAnchorsV1.forEach((name, key) {
      final finder = find.byKey(key);
      expect(finder, findsWidgets, reason: '$name must exist in every state');
      scene[name] = tester.getRect(finder.first);
    });
    return scene;
  }

  void expectSameScene(
    Map<String, Rect> reference,
    Map<String, Rect> actual,
    String state,
    String viewport,
  ) {
    reference.forEach((name, expected) {
      final got = actual[name]!;
      for (final (axis, a, b) in <(String, double, double)>[
        ('left', expected.left, got.left),
        ('top', expected.top, got.top),
        ('width', expected.width, got.width),
        ('height', expected.height, got.height),
      ]) {
        expect(
          (a - b).abs(),
          lessThanOrEqualTo(_toleranceV1),
          reason:
              '$viewport: $name $axis moved by ${(a - b).abs().toStringAsFixed(2)} '
              'logical px between decision and $state',
        );
      }
    });
  }

  for (final entry in _viewportsV1.entries) {
    testWidgets('one physical scene across the learning loop — ${entry.key}', (
      tester,
    ) async {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Run A — the correct-first path.
      await tester.pumpWidget(host('${entry.key}_a'));
      await settle(tester);
      final decision = physicalScene(tester);
      await hop(tester, const Key('act0_shell_option_check'));
      expectSameScene(
        decision,
        physicalScene(tester),
        'correct feedback',
        entry.key,
      );

      // Run B — the canonical repair loop.
      await tester.pumpWidget(host('${entry.key}_b'));
      await settle(tester);
      expectSameScene(decision, physicalScene(tester), 'decision', entry.key);
      await hop(tester, const Key('act0_shell_option_fold'));
      expectSameScene(
        decision,
        physicalScene(tester),
        'wrong feedback',
        entry.key,
      );
      await hop(tester, const Key('act0_shell_feedback_continue_cta'));
      expectSameScene(decision, physicalScene(tester), 'repair', entry.key);
      await hop(tester, const Key('act0_shell_option_check'));
      // Continuation / result: clearing the repair raises the completion
      // summary over the same scene. This is the sixth state the invariant
      // covers, and the last one on this route that still owns a table.
      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsWidgets,
        reason: 'the repaired answer must reach the continuation/result state',
      );
      expectSameScene(
        decision,
        physicalScene(tester),
        'continuation/result',
        entry.key,
      );
      await hop(tester, const Key('act0_shell_feedback_continue_cta'));
      expectSameScene(decision, physicalScene(tester), 'recheck', entry.key);
    });

    testWidgets(
      'the control shelf stays reachable and unclipped — ${entry.key}',
      (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(host('${entry.key}_shelf'));
        await settle(tester);

        // Every answer is inside the viewport, carries a real tap target, and
        // is reachable without scrolling. The last of those is the contract
        // the shelf could most easily break by growing: an answer list that
        // fits only because it can be scrolled to is not a decision surface.
        for (final option in const <Key>[
          Key('act0_shell_option_fold'),
          Key('act0_shell_option_check'),
          Key('act0_shell_option_call'),
        ]) {
          final finder = find.byKey(option);
          final rect = tester.getRect(finder.first);
          expect(
            rect.height,
            greaterThanOrEqualTo(44.0),
            reason: '$option must keep a 44dp tap target',
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(entry.value.height),
            reason: '$option must not be clipped by the viewport',
          );
          expect(rect.top, greaterThanOrEqualTo(0.0));
          expect(
            finder.hitTestable(),
            findsOneWidget,
            reason: '$option must be reachable where it is drawn',
          );
          // Where a scroll view still wraps the answers it must have nothing
          // to scroll: the answers fit their shelf outright.
          for (final scrollable
              in find
                  .ancestor(of: finder.first, matching: find.byType(Scrollable))
                  .evaluate()) {
            final position =
                ((scrollable as StatefulElement).state as ScrollableState)
                    .position;
            expect(
              position.maxScrollExtent,
              0.0,
              reason: '$option must not require scrolling to reach',
            );
            expect(position.pixels, 0.0);
          }
        }

        // The physical table clears the shelf, so the hero foreground survives.
        final felt = tester.getRect(
          find.byKey(const Key('act0_shell_table_felt')).first,
        );
        final shelf = tester.getRect(
          find
              .byKey(const Key('act0_shell_shared_runner_cycle_envelope'))
              .first,
        );
        debugPrint(
          'B7GEOM ${entry.key} felt=$felt shelf=$shelf '
          'heroBand=${shelf.top - felt.bottom}',
        );
        expect(
          shelf.top - felt.bottom,
          greaterThan(0),
          reason: 'the near rail must not be buried under the control shelf',
        );
        expect(
          shelf.height,
          lessThan(entry.value.height * 0.45),
          reason:
              'the control shelf must stay a shelf, not a half-screen panel',
        );

        // The shelf is content-aware: its height follows what the state needs
        // (three answers, or an outcome line plus one continuation control),
        // and which of those is taller depends on the viewport's answer
        // layout. What must never follow is the physical table.
        await hop(tester, const Key('act0_shell_option_check'));
        final feedbackShelf = tester.getRect(
          find
              .byKey(const Key('act0_shell_shared_runner_cycle_envelope'))
              .first,
        );
        expect(
          feedbackShelf.height,
          lessThan(entry.value.height * 0.45),
          reason: 'the feedback shelf must also stay a shelf',
        );
        final feedbackFelt = tester.getRect(
          find.byKey(const Key('act0_shell_table_felt')).first,
        );
        expect(
          (feedbackFelt.top - felt.top).abs(),
          lessThanOrEqualTo(_toleranceV1),
          reason: 'a taller or shorter shelf must not move the physical table',
        );
        expect(
          (feedbackFelt.height - felt.height).abs(),
          lessThanOrEqualTo(_toleranceV1),
          reason: 'a taller or shorter shelf must not resize the table',
        );
      },
    );
  }
}
