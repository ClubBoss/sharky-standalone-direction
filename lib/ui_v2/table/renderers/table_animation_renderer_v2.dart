import 'package:flutter/widgets.dart';

class TableAnimationRendererV2 extends StatelessWidget {
  final Map<String, Object?> assemblyV2;

  const TableAnimationRendererV2({super.key, required this.assemblyV2});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.center,
        child: Container(
          width: 140,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF888888),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
