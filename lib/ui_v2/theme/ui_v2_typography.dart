/// UI V2 Typography Tokens
///
/// This file provides centralized typography tokens for UI V2 components.
/// For design handoff, see: lib/ui_v2/theme/design_tokens.md
///
/// All typography tokens are re-exported from the main theme system for consistency.
library;

export 'package:poker_analyzer/theme/app_typography.dart' show AppTypography;

/// Typography Reference (from AppTypography):
///
/// HEADINGS:
/// - h1: 18sp, w600, textPrimaryDark - Main headings (titles, screen names)
/// - h3: 16sp, w600, textPrimaryDark - Section headings (card headers)
///
/// BODY:
/// - body: 16sp, textSecondaryDark - Regular body text (paragraphs, descriptions)
/// - label: 14sp, w500, textSecondaryDark - Labels (buttons, form fields, badges)
/// - caption: 12sp, textSecondaryDark - Small text (hints, timestamps, footnotes)
///
/// Usage:
/// ```dart
/// Text('Main Title', style: AppTypography.h1)
/// Text('Section Header', style: AppTypography.h3)
/// Text('Body content here', style: AppTypography.body)
/// Text('Label', style: AppTypography.label)
/// Text('Caption or hint', style: AppTypography.caption)
/// ```
///
/// Theme Integration:
/// Typography is automatically applied via ThemeData.textTheme:
/// - titleLarge -> h1
/// - titleMedium -> h3
/// - bodyLarge -> body
/// - bodyMedium -> label
/// - labelSmall -> caption
///
/// This allows using Theme.of(context).textTheme.titleLarge instead of AppTypography.h1
/// for better Material Design integration.
