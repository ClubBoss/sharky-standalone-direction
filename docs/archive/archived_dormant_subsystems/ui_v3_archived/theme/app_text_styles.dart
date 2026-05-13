import 'package:flutter/material.dart';

/// Shared typography tokens for the V3 UI layer.
class AppTextStyles {
  const AppTextStyles._();

  static TextStyle pageTitle(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.headlineSmall ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle pageSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      height: 1.3,
    );
  }

  static TextStyle cardTitle(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w600,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle cardDetail(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.9),
    );
  }

  static TextStyle statusLabel(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: color ?? theme.colorScheme.onSurface,
    );
  }
}
