import 'package:flutter/material.dart';

class MaterialAppShellV4 {
  const MaterialAppShellV4({
    required this.child,
    required this.isV4Active,
    required this.v3FallbackTheme,
    this.v4ThemeData,
    this.v4ActivationBundle,
    this.v4ColorDelta,
  });

  final Widget child;
  final bool isV4Active;
  final ThemeData v3FallbackTheme;
  final ThemeData? v4ThemeData;
  final Map<String, Object?>? v4ActivationBundle;
  final Map<String, Object?>? v4ColorDelta;

  MaterialApp build() {
    final ThemeData theme = isV4Active && v4ThemeData != null
        ? v4ThemeData!
        : v3FallbackTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: child,
      theme: theme,
    );
  }
}
