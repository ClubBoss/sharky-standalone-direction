import 'package:flutter/widgets.dart';

class TableSkeletonRendererV1 extends StatelessWidget {
  final Map<String, Object?> assemblyV2;

  const TableSkeletonRendererV1({super.key, required this.assemblyV2});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Container(
                width: 200,
                height: 120,
                color: const Color(0xFF222222),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 160,
                height: 40,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
