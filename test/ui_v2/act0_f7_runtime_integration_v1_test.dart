import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

class _PlateBytes extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

final _task = Act0ShellStateV1.sample
    .lessonById('your_first_hand')
    .taskList
    .singleWhere((t) => t.taskId == 'your_first_hand_private_cards_recheck');

Act0TableStateV1 _empty(Act0TableStateV1 table) => table.copyWith(
  seats: [
    for (final seat in table.seats)
      seat.seatId == 'utg'
          ? Act0SeatStateV1(
              seatId: seat.seatId,
              seatLabel: seat.seatLabel,
              displayName: seat.displayName,
              isOccupied: false,
              isInHand: false,
              cardsVisibleMode: Act0CardsVisibleModeV1.none,
            )
          : seat,
  ],
);

Future<void> _mount(
  WidgetTester tester,
  Act0RunnerStateV1 runner, {
  Act0TeachingStepV1? recall,
  ValueChanged<Act0RunnerOptionV1>? choose,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Act0LessonRunnerShellV1(
            key: const Key('same-runtime-runner'),
            runner: runner,
            selectedWorldId: 'world_1',
            selectedLessonId: 'your_first_hand',
            selectedTaskId: _task.taskId,
            selectedTaskFamily: _task.resolvedTaskFamily,
            compositionFamily: _task.resolvedCompositionFamily,
            tablePresentation: _task.tablePresentation,
            theoryRecallStep: recall,
            onBack: () {},
            onContinueTheory: () {},
            onContinueReview: () {},
            onChooseOption: choose ?? (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  if (!kAct0F7TableScenePreview) {
    test(
      'F7 remains default OFF',
      () => expect(kAct0F7TableScenePreview, isFalse),
    );
    return;
  }
  setUp(() {
    Act0F7SceneGateV1.premiumStore.clear();
  });
  Future<void> setup(WidgetTester t) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(() async {
      await t.pumpWidget(const SizedBox.shrink());
      t.view.reset();
      Act0F7SceneGateV1.premiumStore.clear();
    });
    await t.runAsync(
      () => Act0F7SceneGateV1.premiumStore.warmUp(bundle: _PlateBytes()),
    );
  }

  testWidgets(
    'actual Runner uses one PNG scene and preserves every default answer and callback',
    (t) async {
      await setup(t);
      final runner = _task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingStepIndex: _task.runner.teachingSteps.length,
      );
      String? chosen;
      await _mount(t, runner, choose: (o) => chosen = o.id);
      expect(
        find.byKey(const Key('act0_f7_baked_room_cast_hero')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_scene_environment_plane')),
        findsNothing,
      );
      expect(find.byType(Act0ScenePlayerLayerV1), findsNothing);
      expect(find.byKey(const Key('act0_f7_dynamic_table')), findsOneWidget);
      for (final option in runner.options) {
        final target = find.byKey(Key('act0_shell_option_${option.id}'));
        expect(target, findsOneWidget);
        expect(t.getSize(target).height, greaterThanOrEqualTo(44));
        expect(
          target.hitTestable(),
          findsOneWidget,
          reason: 'Initial answer ${option.id} must be exposed',
        );
      }
      final answer = runner.options.first;
      await t.tap(find.byKey(Key('act0_shell_option_${answer.id}')));
      await t.pump();
      expect(chosen, answer.id);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'runtime occupancy under an unchanged catalog ID fails closed and latches until actual replay',
    (t) async {
      await setup(t);
      final runner = _task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingStepIndex: _task.runner.teachingSteps.length,
      );
      await _mount(t, runner);
      final key = t
          .widget<Act0F7SceneGateV1>(find.byType(Act0F7SceneGateV1))
          .source
          .scenarioKey;
      final review = runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: runner.options.first.id,
      );
      await _mount(t, review);
      expect(
        t
            .widget<Act0F7SceneGateV1>(find.byType(Act0F7SceneGateV1))
            .source
            .scenarioKey,
        key,
      );
      await _mount(t, review.copyWith(table: _empty(review.table)));
      expect(
        find.byKey(const Key('act0_f7_baked_room_cast_hero')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_scene_environment_plane')),
        findsOneWidget,
      );
      await _mount(t, review);
      expect(
        find.byKey(const Key('act0_f7_baked_room_cast_hero')),
        findsNothing,
      );
      await _mount(t, runner);
      expect(
        t
            .widget<Act0F7SceneGateV1>(find.byType(Act0F7SceneGateV1))
            .source
            .scenarioKey,
        isNot(key),
      );
      expect(
        find.byKey(const Key('act0_f7_baked_room_cast_hero')),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('external recall is included before selecting scenery', (
    t,
  ) async {
    await setup(t);
    final runner = _task.runner.copyWith(
      phase: Act0LessonPhaseV1.drill,
      teachingStepIndex: _task.runner.teachingSteps.length,
    );
    final recall = Act0TeachingStepV1(
      title: 'External source',
      body: 'External recall',
      table: _empty(runner.table),
    );
    await _mount(t, runner, recall: recall);
    final input = t
        .widget<Act0F7SceneGateV1>(find.byType(Act0F7SceneGateV1))
        .source;
    expect(input.tables, contains('external-recall/raw'));
    expect(find.byKey(const Key('act0_f7_baked_room_cast_hero')), findsNothing);
    expect(
      find.byKey(const Key('act0_scene_environment_plane')),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });
}
