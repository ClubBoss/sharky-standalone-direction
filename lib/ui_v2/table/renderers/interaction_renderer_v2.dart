import 'package:flutter/widgets.dart';

class InteractionRendererV2 extends StatelessWidget {
  final Map<String, Object?> assemblyV2;

  const InteractionRendererV2({super.key, required this.assemblyV2});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 180,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF999999),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
