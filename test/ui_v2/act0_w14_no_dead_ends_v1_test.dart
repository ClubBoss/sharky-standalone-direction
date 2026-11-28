import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_cur04b_summary_contract_v1.dart';
import '../support/act0_y5d_catalog_contract_v1.dart';
import '../support/act0_wave6_contract_v1.dart';
import '../support/act0_w11_wave4_contract_v1.dart';
import '../support/act0_w12_wave4_contract_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';
import '../support/act0_w3_catalog_contract_v1.dart';
import '../support/act0_y5b_catalog_contract_v1.dart';
import '../support/act0_y5c_catalog_contract_v1.dart';

// Dead-end classes across the whole W1–W12 route. Progress is a pure function
// of completed task ids, so a learner gets stuck only when a task cannot be
// finished: no correct answer, an id that credits another lesson, an empty
// lesson, or a correct answer that cannot be tapped on the target phone.
class _Bytes extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

final _worlds = Act0ShellStateV1.sample.worlds.where(
  (w) => w.worldNumber <= 12,
);

final _rows = [
  for (final world in _worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task),
];

void main() {
  test('W1–W12 structure has no dead ends', () {
    final problems = <String>[];
    final worlds = _worlds;
    for (final w in worlds) {
      if (w.lessons.isEmpty) problems.add('${w.worldId}: no lessons');
      for (final l in w.lessons) {
        if (l.courseTaskList.isEmpty) problems.add('${l.lessonId}: no tasks');
      }
    }
    final allIds = [
      for (final w in worlds)
        for (final l in w.lessons)
          for (final t in l.taskList) t.taskId,
    ];
    expect(
      _rows.where((r) => r.task.repairOnly).map((r) => r.task.taskId).toSet(),
      {
        'first_table_guide_shared_cards_repair',
        'position_six_seats_position_repair_seat_id_btn',
        'position_six_seats_position_repair_seat_id_utg',
        'button_advantage_position_repair_btn_last_postflop',
        'early_vs_late_position_repair_utg_players_behind',
        'same_hand_different_seat_position_repair_same_hand_different_seat',
        'turn_river_changes_w5_street_repair',
        'w6_wet_board_repair',
      },
    );
    expect(
      worlds.expand((w) => w.lessons).expand((l) => l.courseTaskList),
      hasLength(
        431 +
            w11Wave4ChoiceContractV1.length +
            w12Wave4ChoiceContractV1.length +
            wave6TaskDeltaV1 +
            cur04bSummaryChoicesV1.length +
            w3BlindVsBlindChoicesV1.length +
            y5bNewChoicesV1.length +
            y5cNewChoicesV1.length +
            y5dNewChoicesV1.length,
      ),
    );
    final seen = <String>{};
    for (final id in allIds) {
      if (!seen.add(id)) problems.add('$id: task id used twice');
    }
    for (final r in _rows) {
      final options = r.task.runner.options;
      if (options.isNotEmpty && !options.any((o) => o.isCorrect)) {
        problems.add('${r.task.taskId}: no correct answer');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  testWidgets('every W1–W12 task can be finished on iPhone 14 Pro', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (kAct0F7TableScenePreview) {
      await tester.runAsync(
        () => Act0F7SceneGateV1.premiumStore.warmUp(bundle: _Bytes()),
      );
    }
    final problems = <String>[];
    var checked = 0;
    for (final r in _rows) {
      final task = r.task;
      final theory = task.entryPhase == Act0LessonPhaseV1.theory;
      final recap = !theory && task.runner.options.isEmpty;
      var continued = 0;
      final chosen = <Act0RunnerOptionV1>[];
      final decisions = <Act0CompletedDecisionV1>[];
      String? sizingPresetId;
      // Reuse the unchanged app shell; the task key still resets every piece
      // of runner-owned state between catalog entries.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Act0LessonRunnerShellV1(
                key: ValueKey(task.taskId),
                runner: task.runner.copyWith(
                  phase: task.entryPhase,
                  teachingStepIndex: task.runner.teachingSteps.length,
                  selectedPresetId: sizingPresetId,
                ),
                worldNumber: r.world.worldNumber,
                selectedWorldId: r.world.worldId,
                selectedLessonId: r.lesson.lessonId,
                selectedTaskId: task.taskId,
                selectedTaskTitle: task.title,
                selectedTaskFamily: task.resolvedTaskFamily,
                compositionFamily: task.resolvedCompositionFamily,
                tablePresentation: task.tablePresentation,
                onBack: () {},
                onContinueTheory: () => continued++,
                onChooseOption: chosen.add,
                onCompletedDecision: decisions.add,
                onContinueReview: () => continued++,
                onSelectSizingPreset: (preset) => setState(() {
                  sizingPresetId = preset.id;
                }),
                onConfirmSizingPreset: () {},
              ),
            ),
          ),
        ),
      );
      // This helper always pumps the authored timers and finishes with its own
      // bounded settle, so an extra pre-choreography settle is redundant.
      await pumpSourceChoreographyToDecisionV1(tester, task.runner.table);
      if (recap) {
        // A recap without choices finishes through its own primary button.
        for (var page = 0; page < 8 && continued == 0; page++) {
          final button = find.byType(FilledButton).hitTestable();
          if (button.evaluate().isEmpty) break;
          await tester.tap(button.last, warnIfMissed: false);
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        }
        if (continued == 0) {
          problems.add('${task.taskId}: recap has no way to finish');
        }
        checked++;
        continue;
      }
      if (theory) {
        // Theory finishes with Continue; its authored options are not asked.
        final cta = find.byKey(const Key('act0_shell_continue_cta'));
        if (cta.evaluate().isEmpty) {
          problems.add('${task.taskId}: theory has no Continue');
          continue;
        }
        // Multi-page theory turns pages first; it must finish within a few.
        for (var page = 0; page < 8 && continued == 0; page++) {
          if (cta.evaluate().isEmpty) break;
          await tester.ensureVisible(cta.first);
          await tester.pumpAndSettle();
          await tester.tap(cta.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
        if (continued == 0) {
          problems.add('${task.taskId}: theory Continue does not finish');
        }
        checked++;
        continue;
      }
      final correct = task.runner.options.firstWhere((o) => o.isCorrect);
      Finder? target;
      for (final option in task.runner.options) {
        final candidates = [
          if (task.runner.sizingConfig.isEnabled)
            find.byKey(Key('act0_shell_sizing_preset_${option.id}')),
          find.byKey(Key('act0_shell_option_${option.id}')),
          if (option.seatId != null)
            find.byKey(Key('act0_shell_seat_tap_${option.seatId}')),
        ];
        Finder? reachable;
        for (final candidate in candidates) {
          if (candidate.evaluate().isEmpty) continue;
          // ensureVisible uses zero-duration scrolling here; hit testing sees
          // the updated offset synchronously, before the eventual answer pump.
          await tester.ensureVisible(candidate.first);
          if (candidate.hitTestable().evaluate().isNotEmpty) {
            reachable = candidate.hitTestable().first;
            break;
          }
        }
        if (reachable == null) {
          problems.add('${task.taskId}: option ${option.id} is not tappable');
        } else if (option.id == correct.id) {
          target = find.byKey(tester.widget(reachable).key!).first;
        }
      }
      if (target == null) {
        problems.add('${task.taskId}: correct answer not tappable');
        continue;
      }
      checked++;
      await tester.ensureVisible(target);
      await tester.tap(target, warnIfMissed: false);
      await tester.pumpAndSettle();
      if (task.runner.sizingConfig.isEnabled) {
        final confirm = find.byKey(const Key('act0_shell_sizing_confirm_cta'));
        if (confirm.evaluate().isNotEmpty) {
          await tester.ensureVisible(confirm.first);
          await tester.pumpAndSettle();
        }
        if (confirm.hitTestable().evaluate().isEmpty) {
          problems.add('${task.taskId}: sizing has no tappable confirmation');
        } else {
          await tester.tap(confirm.hitTestable().first);
          await tester.pumpAndSettle();
        }
      }
      final picked = chosen.isNotEmpty
          ? chosen.last.id
          : decisions.isNotEmpty
          ? decisions.last.selectedId
          : null;
      if (picked != correct.id) {
        problems.add(
          '${task.taskId}: tap on ${correct.id} registered as $picked',
        );
      }
    }
    // ignore: avoid_print
    print('W14_CHECKED $checked of ${_rows.length}');
    expect(checked, greaterThan(100), reason: 'the walk must reach the route');
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
