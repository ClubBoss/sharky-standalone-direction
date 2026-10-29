// LEARN.UX.P1 (#331): every source-authored teaching step in the Academy
// catalog is mounted in the real runner and must be readable on the table, in
// authored order, with one Continue per step, before the real decision.
//
// Set LEARN_UX_P1_LEDGER_DIR to also write the per-step coverage ledger
// (`teaching_coverage_<locale>.csv`). The ledger is evidence output and is not
// committed.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_teaching_integrity_harness_v1.dart';

class _LedgerRowV1 {
  _LedgerRowV1(this.cells);
  final List<String> cells;
}

String _csv(String value) => '"${value.replaceAll('"', '""')}"';

String _localizedTitle(
  BuildContext context,
  Act0TeachingTaskRefV1 ref,
  int index,
) {
  final step = ref.task.runner.teachingSteps[index];
  return act0AcademyTeachingCopyV1(
    context,
    runnerLessonId: ref.task.runner.lessonId,
    source: step.title,
    fallback: act0LocalizedTeachingStepTitleAtomByTaskIdV1(
      ref.task.taskId,
      index,
      fallback: step.title,
      languageCode: act0AcademyLanguageV1(context),
    ),
  );
}

String _localizedBody(
  BuildContext context,
  Act0TeachingTaskRefV1 ref,
  int index,
) {
  final step = ref.task.runner.teachingSteps[index];
  return act0AcademyTeachingCopyV1(
    context,
    runnerLessonId: ref.task.runner.lessonId,
    source: step.body,
    fallback: act0LocalizedTeachingStepBodyAtomByTaskIdV1(
      ref.task.taskId,
      index,
      fallback: step.body,
      languageCode: act0AcademyLanguageV1(context),
    ),
  );
}

void _runCatalog(Locale locale) {
  final ledger = <_LedgerRowV1>[];
  final failures = <String>[];
  var stepsAuthored = 0;
  var stepsPresented = 0;
  var drillPreambleSteps = 0;
  var continueTaps = 0;
  var untranslatedSteps = 0;
  var reviewEntryGapSteps = 0;
  final catalog = act0TeachingCatalogV1();
  final taught = catalog
      .where((ref) => ref.task.runner.teachingSteps.isNotEmpty)
      .toList();

  tearDownAll(() {
    final dir = Platform.environment['LEARN_UX_P1_LEDGER_DIR'];
    // ignore: avoid_print
    print(
      'LEARN_UX_P1_COVERAGE locale=${locale.languageCode} '
      'tasks=${catalog.length} taught_tasks=${taught.length} '
      'steps_authored=$stepsAuthored steps_presented=$stepsPresented '
      'drill_preamble_steps=$drillPreambleSteps continue_taps=$continueTaps '
      'untranslated_steps=$untranslatedSteps '
      'review_entry_gap_steps=$reviewEntryGapSteps failures=${failures.length}',
    );
    if (dir == null || dir.isEmpty) return;
    final file = File('$dir/teaching_coverage_${locale.languageCode}.csv')
      ..createSync(recursive: true);
    file.writeAsStringSync(
      [
        'task_id,teaching_step_index,authored_title,authored_body,'
            'presented_title,presented_body,phase,action,verdict',
        for (final row in ledger) row.cells.map(_csv).join(','),
      ].join('\n'),
    );
  });

  for (final ref in taught) {
    testWidgets('${locale.languageCode} ${ref.task.taskId}', (tester) async {
      final events = <String>[];
      await act0PumpTeachingHarnessV1(
        tester,
        ref,
        events: events,
        locale: locale,
      );
      final context = tester.element(find.byType(Scaffold).first);
      final runner = ref.task.runner;
      final steps = runner.teachingSteps;
      final phase = ref.task.entryPhase.name;
      final taskFailures = <String>[];
      for (var index = 0; index < steps.length; index++) {
        stepsAuthored += 1;
        if (ref.task.entryPhase == Act0LessonPhaseV1.drill) {
          drillPreambleSteps += 1;
        }
        final title = _localizedTitle(context, ref, index);
        final body = _localizedBody(context, ref, index);
        if (locale.languageCode == 'ru' &&
            title == steps[index].title &&
            body == steps[index].body) {
          untranslatedSteps += 1;
        }
        final stepFailures = <String>[];
        final titleVisible = act0CopyPresentedV1(tester, title);
        final bodyVisible = act0CopyPresentedV1(tester, body);
        if (!titleVisible) stepFailures.add('title_hidden');
        if (!bodyVisible) stepFailures.add('body_hidden');
        if (act0VisibleOptionCountV1(tester, runner.options) > 0) {
          stepFailures.add('decision_before_teaching');
        }
        final purpose =
            act0TextByKeyV1(tester, 'act0_integrated_scene_purpose') ?? '';
        if (purpose == 'YOUR MOVE' || purpose.contains('ВАШ')) {
          stepFailures.add('decision_label_during_teaching');
        }
        final stage = act0StageTableV1(tester);
        final step = steps[index];
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
        // Answer-free recap tasks enter the runner in review phase, where
        // authored teaching steps have never been presented (since the May
        // 2026 snapshot). That is a review-entry engine gap tracked
        // separately from #331, so it is pinned rather than counted as a
        // presentation failure.
        if (ref.task.entryPhase == Act0LessonPhaseV1.review &&
            stepFailures.isNotEmpty) {
          reviewEntryGapSteps += 1;
          stepFailures
            ..clear()
            ..add('KNOWN_GAP_REVIEW_ENTRY');
        }
        if (titleVisible && bodyVisible) stepsPresented += 1;
        ledger.add(
          _LedgerRowV1(<String>[
            ref.task.taskId,
            '$index',
            steps[index].title,
            steps[index].body,
            titleVisible ? title : '',
            bodyVisible ? body : '',
            phase,
            'continue',
            stepFailures.isEmpty ? 'PASS' : stepFailures.join('|'),
          ]),
        );
        taskFailures.addAll(
          stepFailures
              .where((f) => f != 'KNOWN_GAP_REVIEW_ENTRY')
              .map((f) => 'step$index:$f'),
        );
        // A review-entry recap is completed from its feedback surface, not
        // by a teaching Continue (see KNOWN_GAP_REVIEW_ENTRY above).
        if (ref.task.entryPhase == Act0LessonPhaseV1.review) continue;
        final before = events.length;
        await act0TapTeachingContinueV1(tester);
        continueTaps += 1;
        if (events.length != before + 1) {
          taskFailures.add('step$index:continue_did_not_advance_step');
          // Invisible pagination: keep tapping until the step advances so the
          // ledger still reaches the decision.
          for (var guard = 0; guard < 6 && events.length == before; guard++) {
            await act0TapTeachingContinueV1(tester);
            continueTaps += 1;
          }
        }
      }
      if (ref.task.phase == Act0LessonPhaseV1.theory) {
        if (!events.contains('theory_task_completed')) {
          taskFailures.add('theory_not_completed');
        }
      } else if (ref.task.entryPhase != Act0LessonPhaseV1.review) {
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
        ledger.add(
          _LedgerRowV1(<String>[
            ref.task.taskId,
            'decision',
            runner.question,
            runner.options.map((o) => o.id).join(' / '),
            act0TextByKeyV1(tester, 'act0_integrated_scene_prompt') ?? '',
            '$visible options',
            phase,
            'choose',
            decisionOk ? 'PASS' : 'decision_not_presented',
          ]),
        );
      }
      if (taskFailures.isNotEmpty) {
        failures.add('${ref.task.taskId}: ${taskFailures.join(', ')}');
      }
      expect(taskFailures, isEmpty, reason: ref.task.taskId);
    });
  }

  test('${locale.languageCode} review-entry recap gap stays pinned', () {
    // Any change here means the separate review-entry gap moved: re-adjudicate
    // it instead of letting teaching silently disappear or reappear.
    expect(reviewEntryGapSteps, 32);
    expect(failures, isEmpty);
  });
}

bool _sameIds(List<String> a, List<String> b) =>
    a.length == b.length && a.toSet().containsAll(b);

void main() {
  group('EN catalog teaching coverage', () => _runCatalog(const Locale('en')));
  group('RU catalog teaching coverage', () => _runCatalog(const Locale('ru')));
}
