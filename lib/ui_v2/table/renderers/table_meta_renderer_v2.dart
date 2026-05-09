import 'package:flutter/widgets.dart';

class TableMetaRendererV2 extends StatelessWidget {
  final Widget skeleton;
  final Widget cards;
  final Widget chips;
  final Widget highlights;
  final Widget animations;
  final Widget interaction;

  const TableMetaRendererV2({
    super.key,
    required this.skeleton,
    required this.cards,
    required this.chips,
    required this.highlights,
    required this.animations,
    required this.interaction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        skeleton,
        Positioned.fill(child: Align(child: cards)),
        Positioned.fill(child: Align(child: chips)),
        Positioned.fill(child: Align(child: highlights)),
        Positioned.fill(child: Align(child: animations)),
        Positioned.fill(child: Align(child: interaction)),
      ],
    );
  }
}
