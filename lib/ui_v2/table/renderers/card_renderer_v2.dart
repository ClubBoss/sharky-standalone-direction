import 'package:flutter/widgets.dart';

class CardRendererV2 extends StatelessWidget {
  final Map<String, Object?> assemblyV2;

  const CardRendererV2({super.key, required this.assemblyV2});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _cardPlaceholder(),
          const SizedBox(width: 8),
          _cardPlaceholder(),
          const SizedBox(width: 8),
          _cardPlaceholder(),
          const SizedBox(width: 8),
          _cardPlaceholder(),
          const SizedBox(width: 8),
          _cardPlaceholder(),
        ],
      ),
    );
  }

  Widget _cardPlaceholder() {
    return Container(
      width: 32,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF444444),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
