import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('Review empty state stacks icon and copy on compact portrait', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0ReviewShellV1(
            review: const Act0ReviewStateV1(
              title: 'Repair board',
              subtitle: 'Fix the biggest leak first.',
              weaknessLabel: 'Action order',
              reason: 'Late action keeps getting rushed.',
              stats: <Act0ReviewStatV1>[
                Act0ReviewStatV1(label: 'Open', value: '0'),
              ],
              chosenLabel: 'Call',
              betterLabel: 'Fold',
            ),
            selected: null,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final layout = find.byKey(
      const Key('act0_shell_review_empty_state_layout'),
    );
    expect(layout, findsOneWidget);
    expect(tester.widget<Flex>(layout).direction, Axis.vertical);
    expect(find.text('No weak spots yet.'), findsOneWidget);
    expect(
      find.text('Finish a drill to build your review list.'),
      findsOneWidget,
    );
  });

  testWidgets('Review active repair state reads like a recovery plan', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0ReviewShellV1(
            review: const Act0ReviewStateV1(
              title: 'Repair board',
              subtitle: 'Fix the biggest leak first.',
              weaknessLabel: 'Board texture',
              reason: 'Wet boards keep getting misread under pressure.',
              stats: <Act0ReviewStatV1>[
                Act0ReviewStatV1(label: 'Open', value: '3'),
              ],
              chosenLabel: 'Call',
              betterLabel: 'Fold',
              mistakes: <Act0MistakeCardV1>[
                Act0MistakeCardV1(
                  taskId: 'w6_wet_board_repair',
                  lessonId: 'w6_board_texture',
                  title: 'Wet board pressure',
                  weaknessLabel: 'Board texture',
                  selectedOptionId: 'call',
                  selectedLabel: 'Call',
                  betterLabel: 'Fold',
                  reason: 'Wet boards keep getting misread under pressure.',
                  attempts: 2,
                  contextLabels: <String>['Turn', 'Pressure spot'],
                  repairActionLabel: 'Name the draw pressure, then re-run it.',
                ),
                Act0MistakeCardV1(
                  taskId: 'w6_repair_2',
                  lessonId: 'w6_board_texture',
                  title: 'Second spot',
                  weaknessLabel: 'Board texture',
                  selectedOptionId: 'raise',
                  selectedLabel: 'Raise',
                  betterLabel: 'Check',
                  reason: 'Second leak.',
                  attempts: 1,
                ),
                Act0MistakeCardV1(
                  taskId: 'w6_repair_3',
                  lessonId: 'w6_board_texture',
                  title: 'Third spot',
                  weaknessLabel: 'Board texture',
                  selectedOptionId: 'bet',
                  selectedLabel: 'Bet',
                  betterLabel: 'Check',
                  reason: 'Third leak.',
                  attempts: 1,
                ),
              ],
            ),
            selected: null,
            onSelected: (_) {},
            onFixMistake: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recovery plan'), findsOneWidget);
    expect(find.text('Start here'), findsOneWidget);
    expect(find.text('Start repair rep'), findsOneWidget);
    expect(find.text('Review repair cue'), findsOneWidget);
    expect(
      find.text('After this, 2 more spots can settle one by one.'),
      findsOneWidget,
    );
    expect(
      find.text('2 more repairs are waiting after this one.'),
      findsNothing,
    );
    expect(find.text('Repair next'), findsNothing);

    final repairTop = tester.getTopLeft(
      find.byKey(const Key('act0_shell_mistake_card')),
    );
    final reviewBoardTop = tester.getTopLeft(
      find.byKey(const Key('act0_shell_review_board')),
    );
    expect(repairTop.dy, lessThan(reviewBoardTop.dy));
  });
}
