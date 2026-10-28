import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// The Placement quick check reuses this lesson scene, whose own actor (HJ)
// and seat highlight (CO) do not belong to the Hero-view diagnostic checks.
Act0LessonTaskV1 _baseTask() => Act0ShellStateV1.sample
    .worldById('world_1')
    .lessons
    .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
    .taskList
    .firstWhere((entry) => entry.taskId == 'what_poker_is_table_read_transfer');

const _checks = <(String, int, List<String>, String)>[
  (
    'table_read',
    1,
    ['two_five_six', 'not_sure_yet', 'two_three_six'],
    'two_three_six',
  ),
  (
    'board_private_cards',
    2,
    ['hero_private_cards', 'not_sure_yet', 'board_cards'],
    'board_cards',
  ),
  ('action_basics', 3, ['call', 'not_sure_yet', 'check'], 'check'),
];

Act0RunnerStateV1 _quickCheck(String signalId, int index, [String? choice]) =>
    placementQuickCheckRunnerV1(
      choice == null
          ? _baseTask().runner
          : _baseTask().runner.copyWith(
              phase: Act0LessonPhaseV1.review,
              selectedOptionId: choice,
            ),
      signalId: signalId,
      checkIndex: index,
      checkCount: 3,
    );

Future<void> _pump(
  WidgetTester t,
  Act0RunnerStateV1 runner,
  String signalId,
) async {
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPadding);
  await t.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          runner: runner,
          selectedTaskFamily: _baseTask().resolvedTaskFamily,
          framingProfile: placementQuickCheckFramingProfileV1(signalId),
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
}

void main() {
  test('base lesson scene keeps its own actor and highlight', () {
    final table = _baseTask().runner.table;
    expect(table.seats.where((s) => s.isActive).map((s) => s.seatId), ['hj']);
    expect(table.highlightedSeatIds, ['co']);
  });

  for (final (signalId, index, _, correct) in _checks) {
    test('$signalId check carries no inherited actor or seat highlight', () {
      final runner = _quickCheck(signalId, index);
      expect(runner.table.activeSeatId, isEmpty);
      expect(runner.table.highlightedSeatIds, isEmpty);
      // Grading and choice ids are unchanged.
      expect(runner.options.where((o) => o.isCorrect).map((o) => o.id), [
        correct,
      ]);
      expect(runner.options.map((o) => o.id), contains('not_sure_yet'));
      // The clue stays the source-owned cards/labels, never a seat.
      for (final o in runner.options) {
        expect(o.repairFocusSeatIds, isEmpty, reason: o.id);
        expect(
          o.repairFocusCardIds.isNotEmpty || o.repairFocusLabels.isNotEmpty,
          isTrue,
          reason: o.id,
        );
      }
      // Scene facts other than focus stay those of the lesson scene.
      final base = _baseTask().runner.table;
      expect(runner.table.seats.length, base.seats.length);
      expect(runner.table.streetLabel, base.streetLabel);
      expect(runner.table.potLabel, base.potLabel);
    });
  }

  for (final (signalId, index, choices, _) in _checks) {
    for (final choice in choices) {
      testWidgets('$signalId feedback after $choice marks no opponent to act', (
        t,
      ) async {
        await _pump(t, _quickCheck(signalId, index, choice), signalId);
        expect(t.takeException(), isNull);
        expect(find.textContaining('To act'), findsNothing);
      });
    }
  }
}
