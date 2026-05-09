import 'package:flutter/widgets.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';

class PotChipStackWidget extends StatelessWidget {
  const PotChipStackWidget({required this.position, super.key});

  static const double _width = 48;
  static const double _height = 32;

  final Offset position;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - _width / 2,
      top: position.dy - 48,
      child: Container(
        width: _width,
        height: _height,
        decoration: DesignContainers.card.copyWith(
          color: Color(DesignColors.surfaceElevated),
        ),
      ),
    );
  }
}
