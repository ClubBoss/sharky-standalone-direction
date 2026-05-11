import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'session result keeps next-step text and primary CTA readable under larger text scale',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 780);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 780),
              textScaler: TextScaler.linear(1.35),
            ),
            child: const SessionResultScreen(
              moduleId: 'intro_welcome',
              correctCount: 2,
              totalCount: 3,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final whatsNext = find.byKey(
        const Key('session_result_whats_next_block'),
      );
      final finishLabel = find.byKey(
        const Key('session_result_finish_label_v1'),
      );
      final primaryCta = find.byKey(
        const Key('session_result_back_to_map_cta'),
      );

      expect(whatsNext, findsOneWidget);
      expect(finishLabel, findsOneWidget);
      expect(primaryCta, findsWidgets);

      await tester.ensureVisible(primaryCta.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
