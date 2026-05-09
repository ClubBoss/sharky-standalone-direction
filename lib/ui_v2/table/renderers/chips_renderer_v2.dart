import 'package:flutter/widgets.dart';

class ChipsRendererV2 extends StatelessWidget {
  final Map<String, Object?> assemblyV2;

  const ChipsRendererV2({super.key, required this.assemblyV2});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chip(),
          const SizedBox(width: 6),
          _chip(),
          const SizedBox(width: 6),
          _chip(),
          const SizedBox(width: 18),
          _pot(),
        ],
      ),
    );
  }

  Widget _chip() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFF555555),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _pot() {
    return Container(
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF666666),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
