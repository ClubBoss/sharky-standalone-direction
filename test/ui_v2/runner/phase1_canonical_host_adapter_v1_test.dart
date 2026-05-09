import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_runner_surface_v1.dart';

void main() {
  testWidgets(
    'phase1 canonical launcher enters the canonical terminal surface with canonical host launch',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CanonicalLauncherV1.phase1()),
      );

      expect(find.byType(CanonicalLauncherV1), findsOneWidget);
      expect(find.byType(CanonicalTerminalRunnerSurfaceV1), findsOneWidget);
      expect(find.text('Phase 1 Runner'), findsOneWidget);
    },
  );
}
