import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_prompt_status_capsule_v1.dart';

void main() {
  testWidgets(
    'prompt/status capsule renders badge, prompt, and details affordance',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RunnerPromptStatusCapsuleV1(
              surfaceKey: Key('capsule_surface'),
              statusText: 'Board Texture',
              statusTextKey: Key('capsule_status'),
              promptText: 'Classify the board before you act.',
              promptTextKey: Key('capsule_prompt'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('capsule_surface')), findsOneWidget);
      expect(find.byKey(const Key('capsule_status')), findsOneWidget);
      expect(find.byKey(const Key('capsule_prompt')), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    },
  );

  testWidgets(
    'compact prompt/status capsule stays calmer than the regular capsule while preserving the details affordance',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                RunnerPromptStatusCapsuleV1(
                  surfaceKey: Key('regular_capsule_surface'),
                  statusText: 'Board Texture',
                  promptText: 'Classify the board before you act.',
                ),
                SizedBox(height: 12),
                RunnerPromptStatusCapsuleV1(
                  surfaceKey: Key('compact_capsule_surface'),
                  statusText: 'Board Texture',
                  promptText: 'Classify the board before you act.',
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      );

      final regularRect = tester.getRect(
        find.byKey(const Key('regular_capsule_surface')),
      );
      final compactRect = tester.getRect(
        find.byKey(const Key('compact_capsule_surface')),
      );

      expect(compactRect.height, lessThan(regularRect.height));
      expect(find.text('Details'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
}
