import 'package:flutter/widgets.dart';

import '../design/design_containers.dart';

class TableOutline extends StatelessWidget {
  const TableOutline({
    required this.center,
    this.size = const Size(420, 260),
    super.key,
  });

  final Offset center;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size.width / 2,
      top: center.dy - size.height / 2,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: DesignContainers.panel,
      ),
    );
  }
}
