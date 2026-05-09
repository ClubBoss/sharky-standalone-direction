import 'package:flutter/material.dart';

class V4ToggleQA {
  const V4ToggleQA();

  static Map<String, Object?> inspect(ThemeData? theme) {
    if (theme == null) return {"active": false};
    return {
      "active": true,
      "primary": theme.colorScheme.primary.value,
      "secondary": theme.colorScheme.secondary.value,
      "text_size_body": theme.textTheme.bodyLarge?.fontSize,
      "text_size_headline": theme.textTheme.displayLarge?.fontSize,
    };
  }
}
