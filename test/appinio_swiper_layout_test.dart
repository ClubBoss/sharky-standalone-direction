import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/widgets/cards/hand_display.dart';

void main() {
  testWidgets('AppinioSwiper renders HandDisplay without layout errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 600,
              child: AppinioSwiper(cardCount: 1, cardBuilder: _buildCard),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  });
}

Widget _buildCard(BuildContext context, int index) {
  return Center(
    child: SizedBox(
      width: 340,
      height: 480,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(width: 200, height: 120, child: HandDisplay(hand: 'AA')),
          ],
        ),
      ),
    ),
  );
}
