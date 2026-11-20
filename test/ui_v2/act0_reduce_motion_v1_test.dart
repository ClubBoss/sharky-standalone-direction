import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('Sharky stays visible without scale or tilt in Reduce Motion', (
    tester,
  ) async {
    Future<void> show(bool reduceMotion) => tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Center(
            child: Act0SharkyMascotV1(
              mood: Act0SharkyMoodV1.celebrate,
              tone: Colors.teal,
              size: 56,
            ),
          ),
        ),
      ),
    );

    final motion = find.byKey(
      const Key('act0_shell_sharky_mascot_motion_celebrate'),
    );
    final art = find.byKey(const Key('act0_shell_sharky_mascot'));
    await show(false);
    expect(
      tester.widget<TweenAnimationBuilder<double>>(motion).duration,
      const Duration(milliseconds: 420),
    );
    await tester.pump(const Duration(milliseconds: 180));
    await show(true);
    expect(
      tester.widget<TweenAnimationBuilder<double>>(motion).duration,
      Duration.zero,
    );
    expect(tester.getSize(art), const Size(56, 56));
    expect(
      find.ancestor(of: art, matching: find.byType(Transform)),
      findsNothing,
    );
  });
}
