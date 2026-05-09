import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_canonical_host_adapter_v1.dart';

void main() {
  testWidgets(
    'legacy drill canonical host adapter resolves launch items before entering the canonical terminal surface',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Canonical launch prompt',
          'options': <String>['A', 'B'],
          'answer_index': 0,
          'rationale': 'Explanation',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: LegacyDrillCanonicalHostAdapterV1(
            input: LegacyDrillCanonicalHostLaunchInputV1(
              moduleId: 'legacy_alignment_v1',
              debugItemsOverrideV1: items,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LegacyDrillCanonicalHostAdapterV1), findsOneWidget);
      expect(find.byType(CanonicalTerminalRunnerSurfaceV1), findsOneWidget);
      expect(find.text('Canonical launch prompt'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
