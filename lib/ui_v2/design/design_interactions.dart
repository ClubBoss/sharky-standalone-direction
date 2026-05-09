import 'package:flutter/material.dart';

import 'design_tokens.dart';

class DesignInteractions {
  static BoxDecoration hover = BoxDecoration(
    color: Color(DesignColors.surfaceLight),
    borderRadius: BorderRadius.circular(DesignRadii.sm),
  );

  static BoxDecoration press = BoxDecoration(
    color: Color(DesignColors.surface),
    borderRadius: BorderRadius.circular(DesignRadii.sm),
  );

  static BoxDecoration active = BoxDecoration(
    color: Color(DesignColors.accent),
    borderRadius: BorderRadius.circular(DesignRadii.sm),
  );

  static BoxDecoration disabled = BoxDecoration(
    color: const Color(0xFF2A2A2D),
    borderRadius: BorderRadius.circular(DesignRadii.sm),
  );
}
