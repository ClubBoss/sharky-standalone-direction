/// UI V2 Color Palette Tokens
///
/// This file provides centralized color palette tokens for UI V2 components.
/// For design handoff, see: lib/ui_v2/theme/design_tokens.md
///
/// All color tokens are re-exported from the main theme system for consistency.
library;

export 'package:poker_analyzer/theme/app_colors.dart' show AppColors;

/// Color Palette Reference (from AppColors):
///
/// PRIMARY BRAND:
/// - primaryBrand: #00B894 (teal-green) - Main brand color
/// - accentSuccess: #2ECC71 (green) - Success states
/// - accentWarning: #F1C40F (yellow) - Warnings
///
/// SURFACES (Dark Mode):
/// - neutralBg: #121212 - Main background
/// - surface: #1E1E1E - Card/container surfaces
/// - surfaceVariant: #232325 - AppBar and elevated surfaces
/// - darkBackground: #1A1A1C - Alternative dark background
/// - darkCard: #242428 - Alternative dark card
///
/// SURFACES (Light Mode):
/// - lightBackground: #F2F2F4 - Main background
/// - lightCard: #FFFFFF - Card surfaces
///
/// TEXT:
/// - textPrimaryDark: #FFFFFF - Primary text (dark mode)
/// - textSecondaryDark: #FFFFFFB3 - Secondary text (dark mode)
/// - textPrimaryLight: #000000 - Primary text (light mode)
/// - textSecondaryLight: #0000008A - Secondary text (light mode)
///
/// SEMANTIC:
/// - success: Colors.greenAccent - Success indicators
/// - error: Colors.red - Error states
/// - warning: Colors.yellow - Warning states
/// - info: Colors.blue - Informational states
///
/// BORDERS:
/// - outlineSoft: #33FFFFFF - Subtle borders and dividers
///
/// Usage:
/// ```dart
/// Container(
///   color: AppColors.surface,
///   decoration: BoxDecoration(
///     border: Border.all(color: AppColors.outlineSoft),
///   ),
///   child: Text('Hello', style: TextStyle(color: AppColors.textPrimaryDark)),
/// )
/// ```
