// B6 semantic-motion guard.
//
// B5 resolved the scene's attention phase correctly and applied it as a hard
// cut: measured on the canonical route, the room plane dropped from 0.876 to
// 0.5412 opacity between one frame and the next, with zero animated frames.
//
// B6 interpolates between two already-accepted B5 states. These tests lock the
// three properties that make that motion *semantic* rather than decorative:
//
// 1. every learning-loop hop actually animates;
// 2. every endpoint is still exactly B5's settled value, and reduced motion
//    reaches it with zero animated frames;
// 3. motion never owns truth — the phase flips on the same frame the state
//    does, and no clue is ever animating during a recheck.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_salience_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

String _phase(WidgetTester tester) {
  final matches = find
      .byWidgetPredicate(
        (widget) =>
            widget.key?.toString().contains('act0_scene_attention_phase_') ??
            false,
      )
      .evaluate();
  expect(matches, isNotEmpty, reason: 'the scene must publish its phase');
  return matches.first.widget.key
      .toString()
      .split('act0_scene_attention_phase_')
      .last
      .replaceAll(RegExp(r"['>\]]"), '');
}

/// The rendered recession of the B2 room plane, read off the live tree.
double _roomOpacity(WidgetTester tester) {
  final matches = find
      .ancestor(
        of: find.byKey(const Key('act0_scene_environment_plane')),
        matching: find.byType(Opacity),
      )
      .evaluate();
  expect(matches, isNotEmpty, reason: 'the room plane must render a recession');
  return (matches.first.widget as Opacity).opacity;
}

bool _clueVisible() => find
    .byKey(const Key('act0_scene_clue_bracket_signal'))
    .evaluate()
    .isNotEmpty;

Widget _host({
  required bool reducedMotion,
  double textScale = 1.0,
  Key? remountKey,
}) {
  final screen = Act0ShellPreviewScreenV1(
    key: remountKey,
    state: Act0ShellStateV1.sample,
    showPlacementOnStart: false,
    debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
      mode: Act0ControlledDemoCaptureModeV1.directState,
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_check_drill',
    ),
  );
  return MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reducedMotion ? true : null,
          textScaler: TextScaler.linear(textScale),
        ),
        child: screen,
      ),
    ),
  );
}

/// Taps without settling, so the frames the transition produces stay visible.
Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key).first;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
}

/// Drives the scene to rest, returning how many frames the hop produced and
/// whether the clue bracket was visible at any point along the way.
Future<({int frames, bool clueSeen})> _settle(WidgetTester tester) async {
  var frames = 0;
  var clueSeen = _clueVisible();
  while (tester.binding.hasScheduledFrame && frames < 300) {
    await tester.pump(const Duration(milliseconds: 16));
    frames++;
    clueSeen = clueSeen || _clueVisible();
  }
  return (frames: frames, clueSeen: clueSeen);
}

void main() {
  testWidgets('every learning-loop hop interpolates between B5 states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(reducedMotion: false));
    await tester.pumpAndSettle();
    expect(_phase(tester), 'decision');
    final atDecision = _roomOpacity(tester);

    // decision -> wrong feedback.
    await _tap(tester, const Key('act0_shell_option_fold'));
    expect(
      _phase(tester),
      'wrongFeedback',
      reason:
          'motion must never own or delay truth: the phase flips on the same '
          'frame the state does',
    );
    expect(
      _roomOpacity(tester),
      closeTo(atDecision, 0.001),
      reason:
          'the transition must depart from what the learner was looking at, '
          'not flash the new state first',
    );
    final toFeedback = await _settle(tester);
    expect(
      toFeedback.frames,
      greaterThan(4),
      reason: 'the decision -> feedback cut is the gap B6 exists to close',
    );
    final atWrongFeedback = _roomOpacity(tester);
    expect(atWrongFeedback, lessThan(atDecision));

    // wrong feedback -> targeted repair.
    await _tap(tester, const Key('act0_shell_feedback_continue_cta'));
    expect(_phase(tester), 'repair');
    final toRepair = await _settle(tester);
    expect(toRepair.frames, greaterThan(4));
    expect(_roomOpacity(tester), greaterThan(atWrongFeedback));

    // repair success -> targeted recheck.
    await _tap(tester, const Key('act0_shell_option_check'));
    expect(_phase(tester), 'correctFeedback');
    await _settle(tester);

    await _tap(tester, const Key('act0_shell_feedback_continue_cta'));
    expect(_phase(tester), 'recheck');
    final toRecheck = await _settle(tester);
    expect(toRecheck.frames, greaterThan(4));
    expect(
      toRecheck.clueSeen,
      isFalse,
      reason:
          'no clue may be visible at any frame of a recheck — the release is '
          'instant, never a fade, so nothing is ever animating during a '
          'recognition attempt',
    );
    expect(
      _roomOpacity(tester),
      greaterThan(atWrongFeedback),
      reason: 'recheck restores near-normal recognition context',
    );
  });

  testWidgets('reduced motion reaches identical endpoints in zero frames', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(reducedMotion: true));
    await tester.pumpAndSettle();

    Future<double> hop(Key key, String expectedPhase) async {
      await _tap(tester, key);
      expect(_phase(tester), expectedPhase);
      // The endpoint must already be reached on the transition's first frame.
      final immediate = _roomOpacity(tester);
      await _settle(tester);
      expect(
        _roomOpacity(tester),
        closeTo(immediate, 0.0001),
        reason:
            'reduced motion is an immediate transition with zero animated '
            'scene frames',
      );
      return immediate;
    }

    final wrongFeedback = await hop(
      const Key('act0_shell_option_fold'),
      'wrongFeedback',
    );
    final repair = await hop(
      const Key('act0_shell_feedback_continue_cta'),
      'repair',
    );
    await hop(const Key('act0_shell_option_check'), 'correctFeedback');
    final recheck = await hop(
      const Key('act0_shell_feedback_continue_cta'),
      'recheck',
    );

    // Reduced motion loses no meaning: the same hierarchy B5 encodes is intact.
    expect(wrongFeedback, lessThan(repair));
    expect(recheck, greaterThan(repair));
    expect(_clueVisible(), isFalse);
  });

  test('settled motion renders exactly the accepted B5 values', () {
    for (final phase in Act0SceneAttentionPhaseV1.values) {
      final settled = Act0SceneAttentionMotionV1.settled(phase);
      final b5 = Act0SceneAttentionV1(phase);
      expect(settled.current.roomRecession, b5.roomRecession);
      expect(settled.current.playerRecession, b5.playerRecession);
      expect(settled.current.clueEmphasis, b5.clueEmphasis);
    }
  });

  test('interpolation stays bounded by the two B5 states it connects', () {
    const from = Act0SceneAttentionValuesV1(
      roomRecession: 0.20,
      playerRecession: 0.16,
      clueEmphasis: 0.30,
    );
    const to = Act0SceneAttentionValuesV1(
      roomRecession: 0.74,
      playerRecession: 0.64,
      clueEmphasis: 1.0,
    );
    expect(Act0SceneAttentionValuesV1.lerp(from, to, 0).roomRecession, 0.20);
    expect(Act0SceneAttentionValuesV1.lerp(from, to, 1).roomRecession, 0.74);
    for (final t in <double>[0.1, 0.25, 0.5, 0.75, 0.9]) {
      final mid = Act0SceneAttentionValuesV1.lerp(from, to, t);
      expect(mid.roomRecession, inInclusiveRange(0.20, 0.74));
      expect(mid.playerRecession, inInclusiveRange(0.16, 0.64));
      expect(mid.clueEmphasis, inInclusiveRange(0.30, 1.0));
      expect(
        mid.playerRecession,
        lessThan(mid.roomRecession),
        reason:
            'B5 keeps players less receded than the room; interpolation must '
            'not invert that mid-flight',
      );
    }
  });

  testWidgets('the verdict arrives without ever gating the CTA', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(reducedMotion: false));
    await tester.pumpAndSettle();

    await _tap(tester, const Key('act0_shell_option_fold'));
    expect(
      find.byKey(const Key('act0_shell_feedback_card_motion_reveal')),
      findsOneWidget,
      reason: 'the verdict must arrive rather than cut',
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsOneWidget,
      reason:
          'the continue CTA must be present on the transition first frame - '
          'motion may never gate interaction behind its own duration',
    );

    // Act on the CTA mid-transition. If any part of the motion blocked input,
    // the phase would not advance.
    await tester.pump(const Duration(milliseconds: 32));
    await tester.tap(
      find.byKey(const Key('act0_shell_feedback_continue_cta')).first,
      warnIfMissed: false,
    );
    await tester.pump();
    expect(
      _phase(tester),
      'repair',
      reason: 'an in-flight transition must never absorb or delay input',
    );
  });

  testWidgets('motion holds at compact, large and 1.4x text', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final endpoints = <String, double>{};
    for (final variant in <({String name, Size size, double textScale})>[
      (name: 'canonical', size: Size(402, 874), textScale: 1.0),
      (name: 'compact', size: Size(375, 812), textScale: 1.0),
      (name: 'large', size: Size(430, 932), textScale: 1.0),
      (name: 'text1.4x', size: Size(402, 874), textScale: 1.4),
    ]) {
      tester.view.physicalSize = variant.size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        _host(
          reducedMotion: false,
          textScale: variant.textScale,
          // Each variant must start from a fresh decision, not inherit the
          // previous variant's position in the loop.
          remountKey: ValueKey<String>(variant.name),
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, const Key('act0_shell_option_fold'));
      expect(_phase(tester), 'wrongFeedback');
      final hop = await _settle(tester);
      expect(
        hop.frames,
        greaterThan(4),
        reason: 'the transition must survive ${variant.name}',
      );
      endpoints[variant.name] = _roomOpacity(tester);
    }

    // Recession is a phase property, never a layout property: every viewport
    // and text scale must settle on the same B5 value.
    for (final entry in endpoints.entries) {
      expect(
        entry.value,
        closeTo(endpoints['canonical']!, 0.0001),
        reason: '${entry.key} must settle on the canonical B5 endpoint',
      );
    }
  });
}
