import 'package:flutter/widgets.dart';

import '../design/design_tokens.dart';

class DealerButton extends StatelessWidget {
  const DealerButton({required this.position, super.key});

  static const double size = 38;

  final Offset position;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(DesignColors.accentStrong),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
