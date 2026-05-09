import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('non-blank fallback is visible when builder child is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          if (child == null) {
            return const NonBlankFallbackSurfaceV1(
              title: 'Screen is unavailable',
              message: 'Please retry or go back.',
              retryLabel: null,
            );
          }
          return child;
        },
      ),
    );

    expect(
      find.byKey(const Key('non_blank_fallback_surface_v1')),
      findsOneWidget,
    );
    expect(find.text('Screen is unavailable'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
