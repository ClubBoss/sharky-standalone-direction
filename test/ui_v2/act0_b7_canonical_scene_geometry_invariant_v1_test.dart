// B7 canonical scene composition: the table-geometry invariant guard.
//
// `TABLE_GEOMETRY_INVARIANT_V1` says one viewport owns one physical poker
// scene. Before B7 the same renderer received a different `maxTableHeight` in
// review states, so answering a question rescaled the physical world. This
// guard drives the real learning loop and asserts the physical scene does not
// move, at one canonical text scale, on all three phone viewports.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
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

const _commitmentSeatIdsV1 = <String>['hero', 'sb', 'bb', 'utg', 'hj', 'btn'];

const _commitmentSeatBasesV1 = <Offset>[
  Offset(0.50, 0.91),
  Offset(0.12, 0.75),
  Offset(0.12, 0.33),
  Offset(0.50, 0.12),
  Offset(0.88, 0.33),
  Offset(0.88, 0.75),
];

// The established B4 ring, retained as a clearance input rather than a second
// renderer-owned slot system.
const _establishedCommitmentRingV1 = <Offset>[
  Offset(0.50, 0.71),
  Offset(0.24, 0.64),
  Offset(0.26, 0.30),
  Offset(0.50, 0.29),
  Offset(0.74, 0.30),
  Offset(0.76, 0.64),
];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('seat-local commitments preserve one physical slot per player', () {
    final seats = act0SceneSeatSlotsV1(
      baseSlots: _commitmentSeatBasesV1,
      seatIds: _commitmentSeatIdsV1,
      heroSeatId: 'hero',
    );
    final ring = _establishedCommitmentRingV1
        .map(Act0ScenePerspectiveV1.canonical.project)
        .toList();
    final commitments = act0SceneCommitmentAnchorsV1(
      seatSlots: seats,
      establishedRing: ring,
    );

    // SB/BB posts, opener/caller, and raise/3-bet-style multiway states all
    // consume this same owner map; semantic kind and amount never add a lane.
    expect(
      commitments.map((anchor) => anchor.seatId).toSet(),
      hasLength(_commitmentSeatIdsV1.length),
    );
    expect(
      commitments.map((anchor) => anchor.anchor).toSet(),
      hasLength(_commitmentSeatIdsV1.length),
    );
    for (var index = 0; index < commitments.length; index++) {
      final commitment = commitments[index].anchor;
      final seat = seats[index].plateAnchor;
      expect(
        commitment.distance,
        greaterThan(0),
        reason: 'each active commitment must remain a physical table object',
      );
      expect(
        (commitment - act0SceneCentreV1).distance,
        lessThan((seat - act0SceneCentreV1).distance),
        reason: '${commitments[index].seatId} commitment must point inward',
      );
    }

    // Re-resolving for decision, feedback, repair, recheck, and result must
    // retain the exact owner position: only semantic state/amount may change.
    final replay = act0SceneCommitmentAnchorsV1(
      seatSlots: seats,
      establishedRing: ring,
    );
    expect(
      replay.map((anchor) => anchor.anchor),
      orderedEquals(commitments.map((anchor) => anchor.anchor)),
    );
  });

  testWidgets('side-pot fixture keeps concurrent commitments seat-owned', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final task = Act0ShellStateV1.sample
        .worldById('world_8')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'spr_and_commitment')
        .taskList
        .firstWhere(
          (candidate) => candidate.taskId == 'what_poker_is_side_pot_intro',
        );
    await tester.pumpWidget(
      MaterialApp(
        home: Act0LessonRunnerShellV1(
          runner: task.runner,
          selectedTaskId: task.taskId,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // This production fixture expresses three concurrent player commitments:
    // hero all-in, CO match-plus-side-pot contribution, and BB match-plus-side
    // pot contribution. Each player has exactly one rendered owner subtree;
    // amount/kind does not create a second blind/bet lane.
    for (final seatId in const <String>['btn', 'co', 'bb']) {
      expect(
        find.byKey(Key('act0_shell_bet_chip_owner_$seatId')),
        findsOneWidget,
        reason: '$seatId has one physical commitment owner',
      );
      expect(
        find.byKey(Key('act0_shell_seat_node_$seatId')),
        findsOneWidget,
        reason: '$seatId retains its physical seat owner',
      );
    }
    expect(
      find.byKey(const Key('act0_shell_wave1_pot_priority_stat')),
      findsOneWidget,
      reason: 'the center pot remains independently owned',
    );
    expect(
      find.byKey(const Key('act0_shell_wave1_dealer_marker')),
      findsOneWidget,
      reason: 'the dealer remains independently anchored',
    );
  });

  for (final entry in _viewportsV1.entries) {
    test('commitment-to-pot clearance survives ${entry.key}', () {
      final seats = act0SceneSeatSlotsV1(
        baseSlots: _commitmentSeatBasesV1,
        seatIds: _commitmentSeatIdsV1,
        heroSeatId: 'hero',
      );
      final ring = _establishedCommitmentRingV1
          .map(Act0ScenePerspectiveV1.canonical.project)
          .toList();
      final commitments = act0SceneCommitmentAnchorsV1(
        seatSlots: seats,
        establishedRing: ring,
      );
      final stage = Act0SceneCameraV1.canonical.stageRect(entry.value);
      for (final commitment in commitments) {
        final dx = (commitment.anchor.dx - act0SceneCentreV1.dx) * stage.width;
        final dy = (commitment.anchor.dy - act0SceneCentreV1.dy) * stage.height;
        expect(
          Offset(dx, dy).distance,
          greaterThan(30),
          reason: '${commitment.seatId} must retain a clear center-pot gap',
        );
      }
    });
  }

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

  Map<String, Rect> renderedCommitmentRects(WidgetTester tester) =>
      <String, Rect>{
        for (final seatId in const <String>['sb', 'bb'])
          'commitment $seatId': tester.getRect(
            find.byKey(Key('act0_shell_bet_chip_owner_$seatId')),
          ),
      };

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
      final decisionCommitments = renderedCommitmentRects(tester);
      await hop(tester, const Key('act0_shell_option_check'));
      expectSameScene(
        decision,
        physicalScene(tester),
        'correct feedback',
        entry.key,
      );
      expectSameScene(
        decisionCommitments,
        renderedCommitmentRects(tester),
        'correct feedback commitment',
        entry.key,
      );

      // Run B — the canonical repair loop.
      await tester.pumpWidget(host('${entry.key}_b'));
      await settle(tester);
      expectSameScene(decision, physicalScene(tester), 'decision', entry.key);
      expectSameScene(
        decisionCommitments,
        renderedCommitmentRects(tester),
        'decision commitment',
        entry.key,
      );
      await hop(tester, const Key('act0_shell_option_fold'));
      expectSameScene(
        decision,
        physicalScene(tester),
        'wrong feedback',
        entry.key,
      );
      expectSameScene(
        decisionCommitments,
        renderedCommitmentRects(tester),
        'wrong feedback commitment',
        entry.key,
      );
      await hop(tester, const Key('act0_shell_feedback_continue_cta'));
      expectSameScene(decision, physicalScene(tester), 'repair', entry.key);
      expectSameScene(
        decisionCommitments,
        renderedCommitmentRects(tester),
        'repair commitment',
        entry.key,
      );
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
      expectSameScene(
        decisionCommitments,
        renderedCommitmentRects(tester),
        'continuation commitment',
        entry.key,
      );
      await hop(tester, const Key('act0_shell_feedback_continue_cta'));
      expectSameScene(decision, physicalScene(tester), 'recheck', entry.key);
      expectSameScene(
        decisionCommitments,
        renderedCommitmentRects(tester),
        'recheck commitment',
        entry.key,
      );
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
