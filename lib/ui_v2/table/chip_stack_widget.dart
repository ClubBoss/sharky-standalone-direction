import 'package:flutter/widgets.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';

class ChipStackWidget extends StatelessWidget {
  const ChipStackWidget({required this.position, super.key});

  static const double _width = 40;
  static const double _height = 28;

  final Offset position;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - _width / 2,
      top: position.dy - 36,
      child: Container(
        width: _width,
        height: _height,
        decoration: DesignContainers.card.copyWith(
          color: Color(DesignColors.accentStrong),
        ),
      ),
    );
  }
}
