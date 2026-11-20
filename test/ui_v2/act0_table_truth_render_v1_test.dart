import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

Rect _paintedTableBounds(WidgetTester tester) {
  final plate = find.byKey(const Key('act0_f7_baked_room_cast_hero'));
  if (plate.evaluate().isEmpty) {
    return _paintBounds(tester, find.byKey(const Key('act0_shell_table_felt')));
  }

  final painter =
      tester.widget<CustomPaint>(plate).painter!
          as Act0F7RegisteredScenePainterV1;
  final registration = painter.registration;
  final render = tester.renderObject<RenderBox>(plate);
  final points = registration.profile.tableBoundary
      .map(registration.map)
      .map((point) => render.localToGlobal(point))
      .toList();
  return Rect.fromLTRB(
    points.map((point) => point.dx).reduce(math.min),
    points.map((point) => point.dy).reduce(math.min),
    points.map((point) => point.dx).reduce(math.max),
    points.map((point) => point.dy).reduce(math.max),
  );
}

Rect _paintBounds(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  return MatrixUtils.transformRect(
    box.getTransformTo(null),
    Offset.zero & box.size,
  );
}

Rect _visibleBounds(WidgetTester tester, Finder finder) {
  var bounds = _paintBounds(tester, finder);
  RenderObject child = tester.renderObject(finder);
  for (var parent = child.parent; parent != null; parent = child.parent) {
    final clip = parent.describeApproximatePaintClip(child);
    if (clip != null) {
      bounds = bounds.intersect(
        MatrixUtils.transformRect(parent.getTransformTo(null), clip),
      );
    }
    child = parent;
  }
  return bounds;
}

void _expectStationaryTable(
  Rect reference,
  Rect actual, {
  required String stage,
}) {
  final deltas = [
    actual.left - reference.left,
    actual.top - reference.top,
    actual.right - reference.right,
    actual.bottom - reference.bottom,
    actual.width - reference.width,
    actual.height - reference.height,
  ];
  expect(
    deltas.map((delta) => delta.abs()).reduce(math.max),
    lessThanOrEqualTo(0.5),
    reason: '$stage changed the painted table from $reference to $actual',
  );
}

void main() {
  testWidgets('V3 table stays in place through the actual W1 retry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    expect(
      await tester.runAsync(() => Act0F7SceneGateV1.premiumStore.warmUp()),
      isNotNull,
    );

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start with the basics'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    final wrong = find.text('The shared cards in the middle');
    expect(wrong.hitTestable(), findsOneWidget);
    final reference = _paintedTableBounds(tester);
    await tester.tap(wrong);
    await tester.pump();
    _expectStationaryTable(
      reference,
      _paintedTableBounds(tester),
      stage: 'first answer frame',
    );
    await tester.pumpAndSettle();
    final retry = find.text('Try same clue');
    expect(retry.hitTestable(), findsOneWidget);
    _expectStationaryTable(
      reference,
      _paintedTableBounds(tester),
      stage: 'settled wrong feedback',
    );

    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pumpAndSettle();
    _expectStationaryTable(
      reference,
      _paintedTableBounds(tester),
      stage: 'wrong feedback at 1.3×',
    );
    await tester.tap(retry);
    await tester.pumpAndSettle();
    final correct = find.text('Private cards');
    expect(correct.hitTestable(), findsOneWidget);
    expect(find.text('Shared board'), findsNothing);
    _expectStationaryTable(
      reference,
      _paintedTableBounds(tester),
      stage: 'retry decision at 1.3×',
    );
    await tester.tap(correct);
    await tester.pumpAndSettle();
    _expectStationaryTable(
      reference,
      _paintedTableBounds(tester),
      stage: 'retry feedback at 1.3×',
    );
    expect(tester.takeException(), isNull);
  });

  final geometryTasks = [
    for (final world in Act0ShellStateV1.sample.worlds.take(4))
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          if (task.entryPhase != Act0LessonPhaseV1.theory &&
              task.runner.options.any((option) => option.isCorrect) &&
              task.runner.options.any((option) => !option.isCorrect))
            (world: world, lesson: lesson, task: task),
  ];
  for (final (:world, :lesson, :task) in geometryTasks) {
    final id = task.taskId;
    testWidgets('V3 table geometry and readable cards · $id', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      expect(
        await tester.runAsync(() => Act0F7SceneGateV1.premiumStore.warmUp()),
        isNotNull,
      );

      final source = task.runner;
      final wrong = source.options.firstWhere((option) => !option.isCorrect);
      final correct = source.options.firstWhere((option) => option.isCorrect);

      Future<void> show(
        Act0LessonPhaseV1 phase, {
        String? selected,
        double textScale = 1,
      }) async {
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Act0LessonRunnerShellV1(
                  runner: source.copyWith(
                    phase: phase,
                    teachingStepIndex: source.teachingSteps.length,
                    selectedOptionId: selected,
                  ),
                  worldNumber: world.worldNumber,
                  selectedWorldId: world.worldId,
                  selectedLessonId: lesson.lessonId,
                  selectedTaskId: id,
                  selectedTaskFamily: task.resolvedTaskFamily,
                  compositionFamily: task.resolvedCompositionFamily,
                  tablePresentation: task.tablePresentation,
                  tableIdentityPolicy: lesson.lessonId == 'what_poker_is'
                      ? Act0TableIdentityPolicyV1.learnerOnly
                      : null,
                  onBack: () {},
                  onContinueTheory: () {},
                  onContinueReview: () {},
                  onChooseOption: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await pumpSourceChoreographyToDecisionV1(tester, source.table);
        expect(
          tester.takeException(),
          isNull,
          reason: '$id $phase @$textScale',
        );
      }

      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await show(Act0LessonPhaseV1.drill);
      if (kAct0F7TableScenePreview && id == 'what_poker_is_find_hero') {
        expect(
          find.byKey(const Key('act0_f7_baked_room_cast_hero')),
          findsOneWidget,
        );
      }
      final reference = _paintedTableBounds(tester);
      expect(reference.isEmpty, isFalse);
      expect(
        find.byKey(const Key('act0_shell_learning_scene_sharky_avatar')),
        findsNothing,
      );
      var checkedCardFrames = 0;
      final states = [
        (phase: Act0LessonPhaseV1.drill, selected: null, scale: 1.0),
        (phase: Act0LessonPhaseV1.drill, selected: wrong.id, scale: 1.0),
        (phase: Act0LessonPhaseV1.review, selected: wrong.id, scale: 1.0),
        (phase: Act0LessonPhaseV1.review, selected: correct.id, scale: 1.0),
        (phase: Act0LessonPhaseV1.drill, selected: null, scale: 1.3),
        (phase: Act0LessonPhaseV1.drill, selected: wrong.id, scale: 1.3),
        (phase: Act0LessonPhaseV1.review, selected: wrong.id, scale: 1.3),
        (phase: Act0LessonPhaseV1.review, selected: correct.id, scale: 1.3),
      ];
      for (final state in states) {
        await show(
          state.phase,
          selected: state.selected,
          textScale: state.scale,
        );
        final actual = _paintedTableBounds(tester);
        _expectStationaryTable(reference, actual, stage: '$id $state');
        final controls = [
          find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
          find.byKey(const Key('act0_integrated_scene_prompt')),
          find.byKey(const Key('act0_shell_review_question')),
        ];
        final tableLabels = find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              (key.value.startsWith('act0_shell_seat_identity_') ||
                  key.value.startsWith('act0_shell_hero_identity_') ||
                  key.value.startsWith('act0_shell_bet_chip_owner_') ||
                  const {
                    'act0_shell_center_pot_stat',
                    'act0_shell_center_to_call_stat',
                    'act0_f7_street',
                    'act0_f7_clue',
                  }.contains(key.value));
        });
        final overlays =
            [
                  ...controls.where((control) => control.evaluate().isNotEmpty),
                  for (var i = 0; i < tableLabels.evaluate().length; i++)
                    tableLabels.at(i),
                ]
                .map(
                  (finder) => (
                    key: finder.evaluate().single.widget.key,
                    bounds: _visibleBounds(tester, finder),
                  ),
                )
                .toList();
        final cards = find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('act0_shell_card_');
        });
        for (var i = 0; i < cards.evaluate().length; i++) {
          final card = cards.at(i);
          final bounds = _paintBounds(tester, card);
          checkedCardFrames++;
          for (final overlay in overlays) {
            expect(
              overlay.bounds.overlaps(bounds),
              isFalse,
              reason:
                  '$id $state: overlay $overlay covers ${card.evaluate().single.widget.key} at $bounds',
            );
          }
        }
      }
      // These authored questions have long answer panels on the compact
      // viewport. Every choice must remain reachable at larger text size.
      if (const {
        'actions_check_drill',
        'apply_hj_decision',
        'w4_half_pot_bet',
      }.contains(id)) {
        await show(Act0LessonPhaseV1.drill, textScale: 1.3);
        for (final option in source.options) {
          final choice = find.byKey(Key('act0_shell_option_${option.id}'));
          expect(choice, findsOneWidget);
          await tester.ensureVisible(choice);
          await tester.pumpAndSettle();
          expect(choice.hitTestable(), findsOneWidget);
          _expectStationaryTable(
            reference,
            _paintedTableBounds(tester),
            stage: '$id: scroll to ${option.id} at 1.3×',
          );
        }
      }
      if (source.table.heroCards.isNotEmpty ||
          source.table.boardCards.isNotEmpty) {
        expect(checkedCardFrames, greaterThan(0));
      }
    });
  }

  testWidgets(
    'fallback renderer respects source actor and street-owned chip identities',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPadding);
      Future<void> mount(
        String lesson,
        String id, {
        bool feedback = false,
      }) async {
        final task = Act0ShellStateV1.sample
            .lessonById(lesson)
            .taskList
            .firstWhere((t) => t.taskId == id);
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                key: ValueKey('$id:$feedback'),
                runner: task.runner.copyWith(
                  phase: feedback
                      ? Act0LessonPhaseV1.review
                      : Act0LessonPhaseV1.drill,
                  teachingStepIndex: task.runner.teachingSteps.length,
                  selectedOptionId: feedback
                      ? task.runner.options.first.id
                      : null,
                ),
                selectedWorldId: Act0ShellStateV1.sample.worlds
                    .firstWhere(
                      (w) => w.lessons.any((l) => l.lessonId == lesson),
                    )
                    .worldId,
                selectedLessonId: lesson,
                selectedTaskId: id,
                selectedTaskFamily: task.resolvedTaskFamily,
                tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () {},
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }

      await mount(
        'what_poker_is',
        'what_poker_is_table_read_transfer',
        feedback: true,
      );
      expect(find.textContaining('To act'), findsNothing);
      await mount('fold_check_call_raise', 'actions_check_drill');
      expect(
        find.byKey(const Key('act0_shell_bet_chip_owner_sb')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_bet_chip_owner_bb')),
        findsNothing,
      );
      expect(find.text('0.5 BB'), findsNothing);
      expect(find.text('1 BB'), findsNothing);
      await mount('price_checkpoint', 'w4_checkpoint_table_price');
      expect(
        find.byKey(const Key('act0_shell_bet_chip_owner_bb')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_bet_chip_owner_hj')),
        findsNothing,
      );
    },
  );
}
