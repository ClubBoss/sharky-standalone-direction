import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_table_screen.dart';

void main() {
  testWidgets('simulation table renders without mascot overlay', (
    tester,
  ) async {
    addTearDown(() {
      kMascotOverlayTestOverride = kEnableMascotOverlay;
    });
    kMascotOverlayTestOverride = false;

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SimulationTableScreen())),
    );

    await tester.pump();

    expect(find.textContaining('Pot'), findsWidgets);
    expect(find.textContaining('BET'), findsWidgets);
    expect(find.byType(SimulationTableScreen), findsOneWidget);
  });
}
