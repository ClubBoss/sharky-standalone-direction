import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

Widget _host({required int completedCount}) {
  final hint = world1LadderHintLabel(completedCount);
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: World1LadderProgressBar(
          completedCount: completedCount,
          totalCount: 7,
          hintLabel: hint,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('world1 ladder progresses from 0/7 to 3/7 to 7/7', (
    tester,
  ) async {
    await tester.pumpWidget(_host(completedCount: 0));
    await tester.pump();

    expect(find.byKey(const Key('world1_ladder_progress_bar')), findsOneWidget);
    expect(find.byKey(const Key('world1_ladder_semantics')), findsOneWidget);
    expect(find.byKey(const Key('world1_ladder_hint_label')), findsOneWidget);
    expect(find.text('Foundations 0 / 7'), findsOneWidget);
    expect(find.textContaining('Next checkpoint'), findsOneWidget);

    await tester.pumpWidget(_host(completedCount: 3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Foundations 3 / 7'), findsOneWidget);
    expect(find.text('Next checkpoint L6'), findsOneWidget);

    await tester.pumpWidget(_host(completedCount: 7));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Foundations 7 / 7'), findsOneWidget);
    expect(find.text('All checkpoints cleared'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
