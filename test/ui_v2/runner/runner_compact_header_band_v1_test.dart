import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_compact_header_band_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_prompt_status_capsule_v1.dart';

void main() {
  testWidgets('compact header band renders deterministic stacked grammar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RunnerCompactHeaderBandV1(
            surfaceKey: Key('header_band'),
            statusText: 'Campaign Spine',
            statusTextKey: Key('header_status'),
            headlineText: 'Step 1 of 12',
            headlineTextKey: Key('header_title'),
            compact: true,
            bottomChild: RunnerPromptStatusCapsuleV1(
              surfaceKey: Key('header_prompt_capsule'),
              promptText: 'Choose the best action.',
              compact: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('header_band')), findsOneWidget);
    expect(find.byKey(const Key('header_status')), findsOneWidget);
    expect(find.byKey(const Key('header_title')), findsOneWidget);
    expect(find.byKey(const Key('header_prompt_capsule')), findsOneWidget);
    expect(find.text('Campaign Spine'), findsOneWidget);
    expect(find.text('Step 1 of 12'), findsOneWidget);
    expect(find.text('Choose the best action.'), findsOneWidget);
  });

  testWidgets(
    'compact header band stays lighter than the regular header band',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                RunnerCompactHeaderBandV1(
                  surfaceKey: Key('regular_header_band'),
                  statusText: 'Campaign Spine',
                  headlineText: 'World 1',
                  bottomChild: RunnerPromptStatusCapsuleV1(
                    promptText: 'Choose the best action.',
                  ),
                ),
                SizedBox(height: 12),
                RunnerCompactHeaderBandV1(
                  surfaceKey: Key('compact_header_band'),
                  statusText: 'Campaign Spine',
                  headlineText: 'World 1',
                  compact: true,
                  bottomChild: RunnerPromptStatusCapsuleV1(
                    promptText: 'Choose the best action.',
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final regularRect = tester.getRect(
        find.byKey(const Key('regular_header_band')),
      );
      final compactRect = tester.getRect(
        find.byKey(const Key('compact_header_band')),
      );

      expect(compactRect.height, lessThan(regularRect.height));
      expect(tester.takeException(), isNull);
    },
  );
}
