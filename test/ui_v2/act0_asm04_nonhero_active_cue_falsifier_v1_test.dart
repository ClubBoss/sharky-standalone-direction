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
  'positions_early_late': 'relative-position-inference',
  'early_vs_late_w2_early_position': 'relative-position-inference',
};

void main() {
  final observations = <Map<String, Object?>>[];
  tearDownAll(() {
    final file = File('output/asm04-seats/nonhero-active-counterexamples.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(observations)}\n',
    );
  });
  for (final neutral in [false, true]) {
    for (final entry in _cases.entries) {
      testWidgets(
        '${neutral ? 'neutral control' : 'real source'} non-Hero active cue must not reveal answer: ${entry.key}',
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
          // Hero styling remains legitimate and unchanged; compare the non-Hero
          // correct seat to its own eligible-neutral state, not to Hero's color.
          expect(correctStyle['hero'], isFalse);
          expect(wrongStyle['hero'], isTrue);
          expect(wrongStyle['state'], 'hero');
          expect(wrongStyle['ringColor'], 1795843288);
          expect(correctStyle['selectable'], isTrue);
          expect(
            correctStyle['state'],
            'selectable',
            reason:
                'Correct UTG has an extra active-focus answer cue, independent of legitimate Hero identity',
          );
          expect(correctStyle['ringColor'], 1797646066);
          expect(renderedText, isNot(contains('To act')));
        },
        // Held CO393: preserve source inventory, do not investigate its tap route.
        skip: entry.key == 'positions_cutoff',
      );
    }
  }
}
