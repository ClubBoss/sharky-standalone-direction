import 'package:flutter/widgets.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';

class SeatContainer extends StatelessWidget {
  const SeatContainer({
    required this.position,
    this.size = const Size(76, 60),
    super.key,
  });

  final Offset position;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - size.width / 2,
      top: position.dy - size.height / 2,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: DesignContainers.card.copyWith(
          color: Color(DesignColors.surfaceElevated),
        ),
      ),
    );
  }
}
