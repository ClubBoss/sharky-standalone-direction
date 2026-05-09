import 'package:flutter/widgets.dart';

class HighlightRendererV2 extends StatelessWidget {
  final Map<String, Object?> assemblyV2;

  const HighlightRendererV2({super.key, required this.assemblyV2});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: 120,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF777777),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
