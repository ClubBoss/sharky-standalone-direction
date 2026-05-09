import 'package:flutter/widgets.dart';

/// Passive layout-only Hole Cards widget for Table UI V4.
class HoleCardsWidgetV4 extends StatelessWidget {
  const HoleCardsWidgetV4({
    required this.cardA,
    required this.cardB,
    required this.v4RuntimeBundle,
    super.key,
  });

  final Object cardA;
  final Object cardB;
  final Object v4RuntimeBundle;

  @override
  Widget build(BuildContext context) {
    final dynamic bundle = v4RuntimeBundle;
    final dynamic materialization = bundle is Map
        ? bundle['materialization']
        : null;
    final double width =
        (materialization is Map && materialization['width'] is num)
        ? (materialization['width'] as num).toDouble()
        : 24;
    final double height =
        (materialization is Map && materialization['height'] is num)
        ? (materialization['height'] as num).toDouble()
        : 36;
    final double gap = (materialization is Map && materialization['gap'] is num)
        ? (materialization['gap'] as num).toDouble()
        : 4;
    Widget buildCard(Object data) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(border: Border.all(width: 1)),
          alignment: Alignment.center,
          child: const SizedBox.shrink(),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildCard(cardA),
        SizedBox(width: gap),
        buildCard(cardB),
      ],
    );
  }
}
