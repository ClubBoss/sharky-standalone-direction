import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_bottom_action_stack_v1.dart';

void main() {
  testWidgets('shared bottom action stack renders primary above secondary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RunnerBottomActionStackV1(
            surfaceKey: Key('bottom_action_stack'),
            primaryChild: SizedBox(
              height: 48,
              child: ColoredBox(color: Colors.blue),
            ),
            secondaryChild: SizedBox(
              height: 40,
              child: ColoredBox(color: Colors.green),
            ),
          ),
        ),
      ),
    );

    final stack = find.byKey(const Key('bottom_action_stack'));
    expect(stack, findsOneWidget);
    final boxes = find.descendant(of: stack, matching: find.byType(SizedBox));
    expect(boxes, findsNWidgets(3));
    expect(
      tester.getTopLeft(boxes.at(1)).dy,
      greaterThan(tester.getTopLeft(boxes.first).dy),
    );
  });
}
