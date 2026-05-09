import 'package:flutter/material.dart';

import 'design_tokens.dart';
import '../theme/v4_token_registry.dart';

class DesignContainers {
  static const V4TokenRegistry _tokens = V4TokenRegistry();

  static BoxDecoration card = BoxDecoration(
    color: Color(DesignColors.surfaceElevated),
    borderRadius: BorderRadius.circular(_tokens.v4RadiusM),
    border: Border.all(color: Color(DesignColors.borderSubtle)),
    boxShadow: [
      BoxShadow(
        color: Color(0x66000000).withValues(alpha: _tokens.v4ShadowOpacity),
        blurRadius: _tokens.v4ShadowBlur,
        offset: Offset(0, _tokens.v4ShadowOffset),
      ),
    ],
  );

  static BoxDecoration panel = BoxDecoration(
    color: Color(DesignColors.surfaceBackground),
    borderRadius: BorderRadius.circular(_tokens.v4RadiusM),
    border: Border.all(color: Color(DesignColors.borderSubtle)),
    boxShadow: [
      BoxShadow(
        color: Color(0x66000000).withValues(alpha: _tokens.v4ShadowOpacity),
        blurRadius: _tokens.v4ShadowBlur,
        offset: Offset(0, _tokens.v4ShadowOffset),
      ),
    ],
  );
}
