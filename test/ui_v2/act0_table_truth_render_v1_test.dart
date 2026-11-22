import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';

import '../support/act0_catalog_snapshot_v1.dart';
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

bool _hasOverlap(Rect left, Rect right, {double tolerance = .5}) {
  final intersection = left.intersect(right);
  return intersection.width > tolerance && intersection.height > tolerance;
}

Iterable<Rect> _visibleTextBounds(WidgetTester tester, Finder root) sync* {
  final text = find.descendant(
    of: root,
    matching: find.byType(RichText),
    matchRoot: true,
  );
  for (var i = 0; i < text.evaluate().length; i++) {
    final finder = text.at(i);
    final paragraph = tester.renderObject<RenderParagraph>(finder);
    final transform = paragraph.getTransformTo(null);
    final clip = _visibleBounds(tester, finder);
    final selection = TextSelection(
      baseOffset: 0,
      extentOffset: paragraph.text.toPlainText().length,
    );
    for (final line in paragraph.getBoxesForSelection(selection)) {
      yield MatrixUtils.transformRect(transform, line.toRect()).intersect(clip);
    }
  }
}

Finder _paintedTableLabel(Finder root, Key? key) {
  if (key != const Key('act0_f7_clue')) return root;
  final pill = find.descendant(
    of: root,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget.key == const Key('act0_shell_late_route_table_signal') ||
          widget.key == const Key('act0_shell_wave1b_table_signal_chip'),
    ),
  );
  return pill.evaluate().length == 1 ? pill : root;
}

bool _paintedCommitmentCovers(
  WidgetTester tester,
  Finder commitment,
  Rect target,
) {
  final box = find
      .descendant(
        of: commitment,
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        ),
      )
      .first;
  final carrier = tester.widget<Container>(box);
  final decoration = carrier.decoration! as BoxDecoration;
  final render = tester.renderObject<RenderBox>(box);
  final localBounds = Offset.zero & render.size;
  final radii = decoration.borderRadius?.resolve(TextDirection.ltr);
  if (radii == null) {
    return _hasOverlap(_visibleBounds(tester, box), target);
  }
  final clip = target.intersect(_visibleBounds(tester, box));
  if (clip.width <= .5 || clip.height <= .5) return false;
  final outline = radii.toRRect(localBounds).scaleRadii();
  final center = render.localToGlobal(localBounds.center);
  // Rounded rectangles are convex and their corners curve toward the center.
  // The closest point to the center witnesses whether the overlap reaches ink.
  final nearest = Offset(
    center.dx.clamp(clip.left + .01, clip.right - .01),
    center.dy.clamp(clip.top + .01, clip.bottom - .01),
  );
  return outline.contains(render.globalToLocal(nearest));
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

  final capture = Platform.environment['ACT0_V3_CAPTURE_DIR'];
  final captureScale = Platform.environment['ACT0_V3_CAPTURE_LARGE_TEXT'] == '1'
      ? 1.3
      : 1.0;
  final sweep = Platform.environment['ACT0_V3_SWEEP'] == '1' || capture != null;
  final fontDirectory = Platform.environment['ACT0_V3_FONT_DIR'];
  final symbolFont = Platform.environment['ACT0_V3_SYMBOL_FONT'];
  if (fontDirectory != null) {
    setUpAll(() async {
      for (final family in ['Act0VisualSweep', 'Roboto']) {
        final loader = FontLoader(family);
        for (final weight in ['Regular', 'Medium', 'Bold', 'Black']) {
          final bytes = File(
            '$fontDirectory/Roboto-$weight.ttf',
          ).readAsBytesSync();
          loader.addFont(Future.value(ByteData.sublistView(bytes)));
        }
        await loader.load();
      }
      for (final (family, path) in [
        ('MaterialIcons', '$fontDirectory/MaterialIcons-Regular.otf'),
        if (symbolFont != null) ('Act0VisualSweepSymbols', symbolFont),
      ]) {
        final bytes = File(path).readAsBytesSync();
        await (FontLoader(
          family,
        )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      }
    });
  }
  final geometryTasks = [
    for (final (route, rows) in [
      ('course', [...catalogTasks, if (sweep) ...rulesCheckCatalogTasks]),
      ('day7', day7CatalogTasks),
    ])
      for (final row in rows)
        if (row.task.runner.table.seats.isNotEmpty) (route: route, row: row),
  ];
  test('V3 registers tables from every world and Day 7', () {
    expect(geometryTasks.map((item) => item.row.world.worldNumber).toSet(), {
      for (var world = 1; world <= 12; world++) world,
    });
    expect(geometryTasks.where((item) => item.route == 'day7'), isNotEmpty);
  });
  const exposedCardRegressions = {
    'asm05_new_known_holes_turn_call_10',
    'asm05_new_known_holes_turn_call_40',
    'spaced_review_w1_showdown_winning_hero_cards_board_pot_v1',
    'spaced_review_w1_showdown_winning_w1_rules_check_board_tie_v1',
  };
  const shelfRegressions = {
    'board_texture_basics_w5_dry_board',
    'board_texture_basics_w5_wet_board',
    'w6_checkpoint_table_combo_weight',
    'w7_ajs_btn_100bb_transfer',
    'w7_ajs_btn_25bb_transfer',
    'w9_bubble_table_risk_transfer',
  };
  for (final (route: route, row: (:world, :lesson, :task, lessonIndex: _))
      in geometryTasks) {
    final id = task.taskId;
    final checkLateShelf = !sweep && shelfRegressions.contains(id);
    final checkExposedCards = exposedCardRegressions.contains(id);
    if (!sweep &&
        !checkLateShelf &&
        !checkExposedCards &&
        (route != 'course' ||
            world.worldNumber > 4 ||
            task.entryPhase == Act0LessonPhaseV1.theory ||
            !task.runner.options.any((option) => option.isCorrect) ||
            !task.runner.options.any((option) => !option.isCorrect)))
      continue;
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
      final wrong = source.options
          .where((option) => !option.isCorrect)
          .firstOrNull;
      final correct = source.options
          .where((option) => option.isCorrect)
          .firstOrNull;
      final hasChoice =
          task.entryPhase != Act0LessonPhaseV1.theory &&
          source.options.isNotEmpty;
      final captureKey = GlobalKey();
      final widgetErrors = <String>[];
      final geometryErrors = <String>{};
      final boundsOnly = <String>{};
      final cosmetic = <String>{};
      final files = <String, String>{};

      Future<void> snapshot(String frame) async {
        if (capture == null) return;
        final name = '$route-w${world.worldNumber}-$id-$frame.png';
        final boundary =
            captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          try {
            final bytes = (await image.toByteData(
              format: ui.ImageByteFormat.png,
            ))!;
            final folder = Directory(capture)..createSync(recursive: true);
            await File(
              '${folder.path}/$name',
            ).writeAsBytes(bytes.buffer.asUint8List());
            files[frame] = name;
          } finally {
            image.dispose();
          }
        });
      }

      Future<void> show(
        Act0LessonPhaseV1 phase, {
        String? selected,
        double textScale = 1,
        int? teachingStepIndex,
      }) async {
        final sizingConfig = phase == Act0LessonPhaseV1.drill
            ? source.sizingConfig
            : const Act0SizingConfigV1.disabled();
        final selectingSize = sizingConfig.presets.any(
          (preset) => preset.id == selected,
        );
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            theme: fontDirectory == null
                ? null
                : ThemeData(
                    fontFamily: 'Act0VisualSweep',
                    fontFamilyFallback: symbolFont == null
                        ? null
                        : const ['Act0VisualSweepSymbols'],
                  ),
            home: RepaintBoundary(
              key: captureKey,
              child: Scaffold(
                body: SafeArea(
                  child: Act0LessonRunnerShellV1(
                    runner: source.copyWith(
                      phase: phase,
                      teachingStepIndex:
                          teachingStepIndex ?? source.teachingSteps.length,
                      sizingConfig: sizingConfig,
                      selectedOptionId: selectingSize ? null : selected,
                      selectedPresetId: selectingSize ? selected : null,
                    ),
                    worldNumber: world.worldNumber,
                    selectedWorldId: world.worldId,
                    selectedLessonId: lesson.lessonId,
                    selectedTaskId: id,
                    selectedTaskTitle: sweep ? task.title : null,
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
                    onSelectSizingPreset: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await pumpSourceChoreographyToDecisionV1(tester, source.table);
        if (tester.takeException() case final error?) {
          widgetErrors.add('$phase @$textScale: $error');
        }
      }

      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final states = [
        if (hasChoice)
          for (final scale in [1.0, 1.3]) ...[
            (
              label: 'decision',
              phase: Act0LessonPhaseV1.drill,
              selected: null,
              scale: scale,
              step: null,
            ),
            if (wrong != null) ...[
              (
                label: 'selected',
                phase: Act0LessonPhaseV1.drill,
                selected: wrong.id,
                scale: scale,
                step: null,
              ),
              (
                label: 'feedback',
                phase: Act0LessonPhaseV1.review,
                selected: wrong.id,
                scale: scale,
                step: null,
              ),
              (
                label: 'repeat',
                phase: Act0LessonPhaseV1.drill,
                selected: null,
                scale: scale,
                step: null,
              ),
            ],
            if (correct != null)
              (
                label: wrong == null ? 'feedback' : 'correct',
                phase: Act0LessonPhaseV1.review,
                selected: correct.id,
                scale: scale,
                step: null,
              ),
          ],
        if (!hasChoice)
          for (final scale in [1.0, 1.3])
            for (
              var index = 0;
              index < math.max(source.teachingSteps.length, 1);
              index++
            )
              (
                label: 'teach-$index',
                phase: Act0LessonPhaseV1.theory,
                selected: null,
                scale: scale,
                step: index,
              ),
      ];
      Rect? reference;
      var checkedCardFrames = 0;
      var checkedExposedCards = 0;
      var checkedTableFrames = 0;
      final viewport = const Rect.fromLTWH(0, 59, 393, 759);
      for (final state in states) {
        await show(
          state.phase,
          selected: state.selected,
          textScale: state.scale,
          teachingStepIndex: state.step,
        );
        if (state.scale == captureScale &&
            (state.label == 'decision' ||
                state.label == 'feedback' ||
                state.label == 'teach-0')) {
          await snapshot(state.label);
        }
        final hasTable = [
          find.byKey(const Key('act0_shell_table_felt')),
          find.byKey(const Key('act0_f7_baked_room_cast_hero')),
        ].any((finder) => finder.evaluate().isNotEmpty);
        if (!hasTable) {
          if (!sweep) geometryErrors.add('${state.label}: table is missing');
          continue;
        }
        if (!sweep && checkedTableFrames == 0) {
          expect(
            find.byKey(const Key('act0_shell_learning_scene_sharky_avatar')),
            findsNothing,
          );
          if (kAct0F7TableScenePreview && id == 'what_poker_is_find_hero') {
            expect(
              find.byKey(const Key('act0_f7_baked_room_cast_hero')),
              findsOneWidget,
            );
          }
        }
        checkedTableFrames++;
        final actual = _paintedTableBounds(tester);
        reference ??= actual;
        if (hasChoice) {
          final movement = [
            (reference.left - actual.left).abs(),
            (reference.top - actual.top).abs(),
            (reference.right - actual.right).abs(),
            (reference.bottom - actual.bottom).abs(),
            (reference.width - actual.width).abs(),
            (reference.height - actual.height).abs(),
          ].reduce(math.max);
          if (movement > 0.5) {
            geometryErrors.add(
              '${state.label} @${state.scale}: table moved $movement pt',
            );
          }
        }
        final controls = [
          find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
          find.byKey(const Key('act0_integrated_scene_prompt')),
          find.byKey(const Key('act0_shell_review_question')),
          if (sweep) find.byKey(const Key('act0_shell_action_trail')),
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
                    finder: finder,
                    key: finder.evaluate().single.widget.key,
                    bounds: _visibleBounds(tester, finder),
                  ),
                )
                .toList();
        final subjects = find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              (key.value.startsWith('act0_shell_card_') ||
                  key.value.startsWith('act0_shell_bet_chip_owner_') ||
                  key.value == 'act0_shell_center_pot_stat' ||
                  key.value == 'act0_shell_center_to_call_stat');
        });
        for (var i = 0; i < subjects.evaluate().length; i++) {
          final subject = subjects.at(i);
          final key = subject.evaluate().single.widget.key!;
          final bounds = _paintBounds(tester, subject);
          final isCard = (key as ValueKey<String>).value.startsWith(
            'act0_shell_card_',
          );
          if (isCard) checkedCardFrames++;
          final isExposedOpponentCard =
              isCard &&
              !key.value.startsWith('act0_shell_card_hero_') &&
              !key.value.startsWith('act0_shell_card_board_');
          if (isExposedOpponentCard) checkedExposedCards++;
          if (!sweep && checkExposedCards && !isExposedOpponentCard) continue;
          if (!sweep && !checkLateShelf && !isCard) continue;
          final visible = _visibleBounds(tester, subject).intersect(viewport);
          if (sweep &&
              (visible.width + 0.5 < bounds.width ||
                  visible.height + 0.5 < bounds.height)) {
            geometryErrors.add(
              '${state.label} @${state.scale}: $key is clipped',
            );
          }
          for (final overlay in overlays) {
            if (overlay.key == key ||
                (checkLateShelf &&
                    overlay.key !=
                        const Key('act0_shell_shared_runner_lower_surface'))) {
              continue;
            }
            if (!_hasOverlap(
              overlay.bounds,
              bounds,
              tolerance: sweep ? .5 : 0,
            )) {
              continue;
            }
            final signal =
                '${state.label} @${state.scale}: ${overlay.key} overlaps $key';
            final overlayKey = overlay.key;
            if (sweep &&
                key.value.startsWith('act0_shell_bet_chip_owner_') &&
                overlayKey is ValueKey<String> &&
                (overlayKey.value.startsWith('act0_shell_seat_identity_') ||
                    overlayKey == const Key('act0_f7_clue'))) {
              final label = _paintedTableLabel(overlay.finder, overlayKey);
              final paintedLabel = _visibleBounds(tester, label);
              if (!_hasOverlap(paintedLabel, visible)) {
                boundsOnly.add(signal);
                continue;
              }
              final chipText = _visibleTextBounds(tester, subject).toList();
              final labelText = _visibleTextBounds(tester, label).toList();
              final commitmentSeat = key.value.substring(
                'act0_shell_bet_chip_owner_'.length,
              );
              final ownLabel =
                  overlayKey == Key('act0_shell_seat_identity_$commitmentSeat');
              final hidesText = ownLabel
                  // The registered table paints an owner's chips above its
                  // own plate. The plate cannot hide the chip amount.
                  ? labelText.any(
                      (line) => _paintedCommitmentCovers(tester, subject, line),
                    )
                  : chipText.any(
                      (line) =>
                          labelText.any((label) => _hasOverlap(line, label)),
                    );
              if (chipText.isNotEmpty && labelText.isNotEmpty && !hidesText) {
                cosmetic.add(signal);
                continue;
              }
            }
            geometryErrors.add(signal);
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
            reference!,
            _paintedTableBounds(tester),
            stage: '$id: scroll to ${option.id} at 1.3×',
          );
        }
      }
      if (sweep && checkedTableFrames == 0) {
        geometryErrors.add('Source table has no rendered table frame');
      }
      if (capture != null) {
        final folder = Directory(capture)..createSync(recursive: true);
        File(
          '${folder.path}/$route-w${world.worldNumber}-$id.json',
        ).writeAsStringSync(
          jsonEncode({
            'route': route,
            'world': world.worldNumber,
            'lesson': lesson.lessonId,
            'task': id,
            'title': task.title,
            'files': files,
            'captureScale': captureScale,
            'street': source.table.streetLabel,
            'boardCards': source.table.boardCards.length,
            'bets': source.table.seats.where((seat) => seat.bet != null).length,
            'trail': source.table.actionTrail.length,
            'sidePot':
                source.table.potLabel.toLowerCase().contains('side') ||
                source.table.actionTrail.any(
                  (item) =>
                      item.learnerLabel.toLowerCase().contains('side pot'),
                ),
            'allIn': source.table.seats.any(
              (seat) => seat.bet?.kind == Act0SeatBetKindV1.allIn,
            ),
            'checkedTableFrames': checkedTableFrames,
            'checkedCardFrames': checkedCardFrames,
            'issues': [...widgetErrors, ...geometryErrors],
            'boundsOnly': boundsOnly.toList(),
            'cosmetic': cosmetic.toList(),
          }),
        );
      }
      if (checkExposedCards) {
        expect(checkedExposedCards, greaterThan(0), reason: id);
      }
      expect(widgetErrors, isEmpty, reason: id);
      expect(geometryErrors, isEmpty, reason: id);
      if (checkedTableFrames > 0 &&
          hasChoice &&
          (source.table.heroCards.isNotEmpty ||
              source.table.boardCards.isNotEmpty)) {
        expect(checkedCardFrames, greaterThan(0), reason: id);
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
        'first_table_guide',
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
