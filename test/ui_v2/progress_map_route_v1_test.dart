import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  testWidgets('progress map route preserves review queue auto-open flag', (
    tester,
  ) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final route =
        progressMapRouteV1(autoOpenReviewQueueForNextPackV1: true)
            as MaterialPageRoute<void>;
    final built = route.builder(capturedContext) as UiV2ProgressMapScreenV2;

    expect(built.autoOpenReviewQueueForNextPackV1, isTrue);
  });
}
