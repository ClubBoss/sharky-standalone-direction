import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Bounded follow-up inventory: original 16 candidates, CO393 remains held.
// A named-seat question is a legitimate prompt, not itself a leakage finding.
// Hero identity styling is also legitimate; targetFocus on the correct control
// is a different, answer-exclusive signal. Compare same-role controls separately.
const _cases = {
  'blinds_first_actor': 'named-seat-recognition',
  'blinds_last_actor': 'named-seat-recognition',
  'blinds_postflop_button': 'relative-position-inference',
  'blinds_button_moves': 'dealer-marker-recognition',
  'positions_button': 'named-seat-recognition',
  'positions_utg': 'named-seat-recognition',
  'positions_cutoff': 'named-seat-recognition',
  'positions_late_seat': 'relative-position-inference',
  'positions_early_late': 'relative-position-inference',
  'button_advantage_find_button': 'named-seat-recognition',
  'button_advantage_button_last': 'relative-position-inference',
  'button_advantage_button_vs_cutoff': 'relative-position-inference',
  'button_advantage_position_repair_btn_last_postflop':
      'repair-position-inference',
  'early_vs_late_w2_late_position': 'relative-position-inference',
  'early_vs_late_w2_early_position': 'relative-position-inference',
  'same_hand_different_seat_w3_same_hand_recap': 'transfer-recap',
};

void main() {
  final observations = <Map<String, Object?>>[];
  tearDownAll(() {
    final file = File('output/asm04-seats/adjudication-consumers.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(observations)}\n',
    );
  });
  for (final neutral in [false, true]) {
    for (final entry in _cases.entries) {
      testWidgets(
        '${neutral ? 'neutral comparison' : 'real source'} seat cue inventory: ${entry.key}',
        (tester) async {
          final row = [
            for (final world in Act0ShellStateV1.sample.worlds)
              for (final lesson in world.lessons)
                for (final task in lesson.taskList)
                  if (task.taskId == entry.key)
                    (world: world, lesson: lesson, task: task),
          ].single;
          final task = row.task;
          final correct = task.runner.options.singleWhere((o) => o.isCorrect);
          final wrong = task.runner.options.firstWhere((o) => !o.isCorrect);
          final assistance = <Act0DecisionAssistanceV1>[];
          final decisions = <Act0CompletedDecisionV1>[];
          tester.view.physicalSize = const Size(393, 852);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Act0LessonRunnerShellV1(
                  runner: task.runner.copyWith(
                    phase: task.entryPhase,
                    table: neutral
                        ? task.runner.table.copyWith(
                            highlightedSeatIds: const [],
                            activeSeatId: '',
                          )
                        : task.runner.table,
                    teachingStepIndex: task.runner.teachingSteps.length,
                  ),
                  worldNumber: row.world.worldNumber,
                  selectedWorldId: row.world.worldId,
                  selectedLessonId: row.lesson.lessonId,
                  selectedTaskId: task.taskId,
                  selectedTaskTitle: task.title,
                  selectedTaskFamily: task.resolvedTaskFamily,
                  compositionFamily: task.resolvedCompositionFamily,
                  tablePresentation: task.tablePresentation,
                  onBack: () {},
                  onContinueTheory: () {},
                  onChooseOption: (_) {},
                  onCompletedDecision: decisions.add,
                  onContinueReview: () {},
                  onChoiceAssistance: assistance.add,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          Map<String, Object?> styleFor(String id) {
            final node = find.byWidgetPredicate(
              (w) =>
                  w.runtimeType.toString() == '_SeatNodeV1' &&
                  (w as dynamic).seat.seatId == id,
            );
            expect(node, findsOneWidget);
            final dynamic widget = tester.widget(node);
            final ring = find.descendant(
              of: node,
              matching: find.byKey(const Key('act0_shell_active_seat_ring')),
            );
            final decoration =
                tester.widget<DecoratedBox>(ring).decoration as BoxDecoration;
            return {
              'seatId': id,
              'hero': widget.hero as bool,
              'dealer': widget.seat.isDealerButton as bool,
              'seatLabel': widget.seat.seatLabel as String,
              'selectable': widget.selectable as bool,
              'state': (widget.visualState as Enum).name,
              'ringColor': (decoration.border! as Border).top.color.toARGB32(),
              'ringWidth': (decoration.border! as Border).top.width,
            };
          }

          final correctStyle = styleFor(correct.seatId!);
          final wrongStyle = styleFor(wrong.seatId!);
          final renderedText = tester
              .widgetList<Text>(find.byType(Text))
              .map((t) => t.data ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
          final allEligibleStyles = [
            for (final o in task.runner.options)
              if (o.seatId != null) styleFor(o.seatId!),
          ];
          if (neutral &&
              !const {
                'blinds_first_actor',
                'positions_early_late',
                'early_vs_late_w2_early_position',
              }.contains(entry.key)) {
            final source = observations.singleWhere(
              (r) => r['taskId'] == entry.key && r['neutralControl'] == false,
            );
            expect(
              allEligibleStyles,
              source['allEligibleStyles'],
              reason:
                  'Ordinary Hero/dealer identity must not depend on task answer focus',
            );
            expect(renderedText, source['renderedTextBeforeChoice']);
          }
          final correctTap = find.byKey(
            Key('act0_shell_seat_tap_${correct.seatId}'),
          );
          await tester.ensureVisible(correctTap);
          await tester.tap(correctTap);
          await tester.pump();
          observations.add({
            'taskId': task.taskId,
            'neutralControl': neutral,
            'family': entry.value,
            'question': task.runner.question,
            'title': task.title,
            'caption': task.runner.caption,
            'hint': task.runner.hint,
            'centerLabel': task.runner.table.centerLabel,
            'sourceActiveSeat': task.runner.table.activeSeatId,
            'sourceHighlightedSeats': task.runner.table.highlightedSeatIds,
            'options': [
              for (final o in task.runner.options)
                {
                  'id': o.id,
                  'label': o.label,
                  'seatId': o.seatId,
                  'correct': o.isCorrect,
                },
            ],
            'allEligibleStyles': allEligibleStyles,
            'renderedTextBeforeChoice': renderedText,
            'teaching': [
              for (final t in task.runner.teachingSteps)
                {
                  'title': t.title,
                  'body': t.body,
                  'focusSeats': t.focusSeatIds,
                },
            ],
            'sourceCorrectChoiceId': correct.id,
            'correctStyle': correctStyle,
            'wrongStyle': wrongStyle,
            'assistance': assistance.map((a) => a.name).toList(),
            'chosenId': decisions.single.selectedId,
          });
          print(
            'ASM04-SEAT ${task.taskId} family=${entry.value} correct=$correctStyle wrong=$wrongStyle assistance=$assistance',
          );
          expect(decisions.single.selectedId, correct.id);
          expect(decisions.single.isCorrect, isTrue);
          expect(
            decisions.single.assistanceKind,
            Act0DecisionAssistanceV1.none,
          );
          expect(assistance, [Act0DecisionAssistanceV1.none]);
          // Do not conflate ordinary Hero identity with a correctness spotlight.
          expect(
            correctStyle['state'],
            isNot('targetFocus'),
            reason:
                'Unassisted correct control is pre-marked as the unique target',
          );
          if (correctStyle['hero'] == wrongStyle['hero']) {
            expect(
              correctStyle['ringColor'],
              wrongStyle['ringColor'],
              reason:
                  'Equivalent eligible controls must not encode correctness in their ring color',
            );
          }
        },
        // Held CO393: preserve source inventory, do not investigate its tap route.
        skip: entry.key == 'positions_cutoff',
      );
    }
  }
}
