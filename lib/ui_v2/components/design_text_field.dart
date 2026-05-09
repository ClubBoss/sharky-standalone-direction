import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../design/design_layout.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';

class DesignTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const DesignTextField({
    required this.controller,
    required this.hint,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DesignContainers.card,
      padding: const EdgeInsets.all(DesignLayout.itemSpacing),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: DesignTypography.body,
          fontWeight: FontWeight.w400,
          color: Color(DesignColors.accent),
        ),
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}
