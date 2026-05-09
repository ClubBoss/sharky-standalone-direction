import 'package:flutter/material.dart';

/// Stateless toggle for showing or hiding the QA overlay in the Table V4 preview.
class TableV4QAOverlayToggleV1 extends StatelessWidget {
  const TableV4QAOverlayToggleV1({
    super.key,
    required this.qaVisible,
    required this.onToggle,
  });

  final bool qaVisible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            qaVisible ? 'QA' : 'QA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
