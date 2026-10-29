// LEARN.UX.P1 (#331): every source-authored teaching step in the English
// Academy catalog is mounted in the real runner and must be genuinely readable
// on the table, in authored order, with one Continue per step, before the real
// decision (or, for an answer-free recap, before its takeaway).
//
// "Readable" is measured on the rendered text, not its presence in the tree:
// painted, entirely on screen, never ellipsized, and at the reference text
// scale fully visible without scrolling. At 200% text a bounded scroll is
// allowed.
//
// Set LEARN_UX_P1_LEDGER_DIR to also write the per-step coverage ledger
// (`teaching_coverage_en_<scale>.csv`). The ledger is evidence output and is
// not committed.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_teaching_integrity_harness_v1.dart';

String _csv(String value) => '"${value.replaceAll('"', '""')}"';

bool _sameIds(List<String> a, List<String> b) =>
    a.length == b.length && a.toSet().containsAll(b);

void _runCatalog({required double textScale}) {
  final label = textScale == 1 ? '100' : '${(textScale * 100).round()}';
  final allowScroll = textScale > 1;
  final ledger = <List<String>>[];
  final failures = <String>[];
  var stepsAuthored = 0;
  var stepsPresented = 0;
  var drillPreambleSteps = 0;
  var recapSteps = 0;
  var continueTaps = 0;
  final catalog = act0TeachingCatalogV1();
  final taught = catalog
      .where((ref) => ref.task.runner.teachingSteps.isNotEmpty)
      .toList();

  tearDownAll(() {
    // ignore: avoid_print
    print(
      'LEARN_UX_P1_COVERAGE en scale=$label tasks=${catalog.length} '
      'taught_tasks=${taught.length} steps_authored=$stepsAuthored '
      'steps_presented=$stepsPresented '
      'drill_preamble_steps=$drillPreambleSteps recap_steps=$recapSteps '
      'continue_taps=$continueTaps failures=${failures.length}',
    );
    final dir = Platform.environment['LEARN_UX_P1_LEDGER_DIR'];
    if (dir == null || dir.isEmpty) return;
    File('$dir/teaching_coverage_en_$label.csv')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        [
          'task_id,teaching_step_index,authored_title,authored_body,'
              'presented_title,presented_body,phase,action,verdict',
          for (final row in ledger) row.map(_csv).join(','),
        ].join('\n'),
      );
  });

  for (final ref in taught) {
    testWidgets('en@$label ${ref.task.taskId}', (tester) async {
      final events = <String>[];
      await act0PumpTeachingHarnessV1(
        tester,
        ref,
        events: events,
        textScale: textScale,
      );
      final runner = ref.task.runner;
      final steps = runner.teachingSteps;
      final entry = ref.task.entryPhase;
      final taskFailures = <String>[];
      for (var index = 0; index < steps.length; index++) {
        stepsAuthored += 1;
        if (entry == Act0LessonPhaseV1.drill) drillPreambleSteps += 1;
        if (entry == Act0LessonPhaseV1.review) recapSteps += 1;
        final step = steps[index];
        final stepFailures = <String>[];
        final titleVisible = act0CopyPresentedV1(
          tester,
          step.title,
          allowScroll: allowScroll,
        );
        final bodyVisible = act0CopyPresentedV1(
          tester,
          step.body,
          allowScroll: allowScroll,
        );
        if (!titleVisible) stepFailures.add('title_not_readable');
        if (!bodyVisible) stepFailures.add('body_not_readable');
        if (act0VisibleOptionCountV1(tester, runner.options) > 0) {
          stepFailures.add('decision_before_teaching');
        }
        if (act0TextByKeyV1(tester, 'act0_integrated_scene_purpose') ==
            'YOUR MOVE') {
          stepFailures.add('decision_label_during_teaching');
        }
        if (find
            .byKey(const Key('act0_shell_feedback_continue_cta'))
            .evaluate()
            .isNotEmpty) {
          stepFailures.add('feedback_before_teaching');
        }
        final stage = act0StageTableV1(tester);
        if (stage != null &&
            step.focusSeatIds.isNotEmpty &&
            !_sameIds(stage.highlightedSeatIds, step.focusSeatIds)) {
          stepFailures.add('seat_focus_mismatch');
        }
        if (stage != null &&
            step.focusCardIds.isNotEmpty &&
            !_sameIds(stage.highlightedCardIds, step.focusCardIds)) {
          stepFailures.add('card_focus_mismatch');
        }
        if (stage != null &&
            step.table != null &&
            stage.boardCards.length != step.table!.boardCards.length) {
          stepFailures.add('board_state_mismatch');
        }
        if (titleVisible && bodyVisible) stepsPresented += 1;
        ledger.add(<String>[
          ref.task.taskId,
          '$index',
          step.title,
          step.body,
          titleVisible ? step.title : '',
          bodyVisible ? step.body : '',
          entry.name,
          'continue',
          stepFailures.isEmpty ? 'PASS' : stepFailures.join('|'),
        ]);
        taskFailures.addAll(stepFailures.map((f) => 'step$index:$f'));
        final before = events.length;
        await act0TapTeachingContinueV1(tester);
        continueTaps += 1;
        if (events.length != before + 1) {
          taskFailures.add('step$index:continue_did_not_advance_step');
          break;
        }
      }
      if (ref.task.phase == Act0LessonPhaseV1.theory) {
        if (!events.contains('theory_task_completed')) {
          taskFailures.add('theory_not_completed');
        }
      } else if (entry == Act0LessonPhaseV1.review) {
        // Answer-free recap: the authored takeaway follows the teaching.
        final takeaway = find
            .byKey(const Key('act0_shell_feedback_continue_cta'))
            .evaluate()
            .isNotEmpty;
        if (!takeaway) taskFailures.add('takeaway_not_presented');
        ledger.add(<String>[
          ref.task.taskId,
          'takeaway',
          runner.reviewTitle,
          '',
          act0TextByKeyV1(tester, 'act0_integrated_scene_prompt') ?? '',
          '',
          entry.name,
          'continue_review',
          takeaway ? 'PASS' : 'takeaway_not_presented',
        ]);
      } else {
        // Source-owned table choreography (e.g. an action trail replay) may
        // still be playing before the hero decision is ready.
        for (
          var guard = 0;
          guard < 8 &&
              act0VisibleOptionCountV1(tester, runner.options) <
                  runner.options.length;
          guard++
        ) {
          await tester.pump(const Duration(seconds: 1));
        }
        final visible = act0VisibleOptionCountV1(tester, runner.options);
        final decisionOk = visible == runner.options.length;
        if (!decisionOk) taskFailures.add('decision_not_presented');
        ledger.add(<String>[
          ref.task.taskId,
          'decision',
          runner.question,
          runner.options.map((o) => o.id).join(' / '),
          act0TextByKeyV1(tester, 'act0_integrated_scene_prompt') ?? '',
          '$visible options',
          entry.name,
          'choose',
          decisionOk ? 'PASS' : 'decision_not_presented',
        ]);
      }
      if (taskFailures.isNotEmpty) {
        failures.add('${ref.task.taskId}: ${taskFailures.join(', ')}');
      }
      expect(taskFailures, isEmpty, reason: ref.task.taskId);
    });
  }
}

void main() {
  setUpAll(act0LoadRealTextFontsV1);
  group('EN catalog teaching coverage at 100%', () {
    _runCatalog(textScale: 1);
  });
  group('EN catalog teaching coverage at 200%', () {
    _runCatalog(textScale: 2);
  });
}
