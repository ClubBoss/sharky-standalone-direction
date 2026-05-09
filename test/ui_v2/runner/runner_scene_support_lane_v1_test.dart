import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_scene_support_lane_v1.dart';

void main() {
  testWidgets('shared scene support lane renders deterministic child stack', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RunnerSceneSupportLaneV1(
            surfaceKey: Key('scene_support_lane'),
            compact: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Coach status'),
                SizedBox(height: 6),
                Text('Primary action'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('scene_support_lane')), findsOneWidget);
    expect(find.text('Coach status'), findsOneWidget);
    expect(find.text('Primary action'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('scene_support_lane'))).height,
      greaterThan(40),
    );
  });

  testWidgets('compact scene support lane stays calmer than the regular lane', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RunnerSceneSupportLaneV1(
                surfaceKey: Key('regular_scene_support_lane'),
                child: Text('Regular support'),
              ),
              SizedBox(height: 12),
              RunnerSceneSupportLaneV1(
                surfaceKey: Key('compact_scene_support_lane'),
                compact: true,
                child: Text('Compact support'),
              ),
            ],
          ),
        ),
      ),
    );

    final regularRect = tester.getRect(
      find.byKey(const Key('regular_scene_support_lane')),
    );
    final compactRect = tester.getRect(
      find.byKey(const Key('compact_scene_support_lane')),
    );

    expect(compactRect.height, lessThan(regularRect.height));
    expect(tester.takeException(), isNull);
  });
}
