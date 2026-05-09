import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/app_language_controller.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';

/// Language Selector Panel
///
/// Displays a scrollable list of available languages with flag icons.
/// Provides instant language switching with animated transitions.
///
/// Stage D16: Runtime language selection UI.
class LanguageSelectorPanel extends StatefulWidget {
  const LanguageSelectorPanel({super.key, required this.controller});

  final AppLanguageController controller;

  @override
  State<LanguageSelectorPanel> createState() => _LanguageSelectorPanelState();
}

class _LanguageSelectorPanelState extends State<LanguageSelectorPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.controller.languageCode;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    widget.controller.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        _selectedLanguage = widget.controller.languageCode;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onLanguageChanged);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLanguageSelection(String languageCode) async {
    if (languageCode == _selectedLanguage) return;

    setState(() {
      _selectedLanguage = languageCode;
    });

    // Animate selection change
    await _animationController.reverse();

    // Update controller (this will rebuild MaterialApp with new locale)
    final changed = await widget.controller.setLanguage(languageCode);

    if (changed && mounted) {
      _animationController.forward();

      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.languageChangedSnackbar(
              AppLanguageController.getLanguageName(languageCode),
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.languageSelectorTitle,
          style: AppTypography.h1.copyWith(
            fontSize: 20,
            color: brand?.textPrimary ?? AppColors.textPrimaryDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: brand?.primaryBrand ?? Colors.teal),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: ListView(
            padding: EdgeInsets.all(brand?.spacingLarge ?? 24.0),
            children: [
              // Header description
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  l10n.languageSelectorDescription,
                  style: AppTypography.body.copyWith(
                    color: brand?.textSecondary ?? AppColors.textSecondaryDark,
                  ),
                ),
              ),

              // Language list
              ...AppLanguageController.supportedLanguages.entries
                  .map(
                    (entry) => _buildLanguageItem(
                      context,
                      languageCode: entry.key,
                      languageName: entry.value,
                      isSelected: entry.key == _selectedLanguage,
                      brand: brand,
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context, {
    required String languageCode,
    required String languageName,
    required bool isSelected,
    required BrandTheme? brand,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds:
            400 +
            (AppLanguageController.supportedLanguages.keys.toList().indexOf(
                  languageCode,
                ) *
                50),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleLanguageSelection(languageCode),
            borderRadius: BorderRadius.circular(brand?.radius ?? 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (brand?.primaryBrand ?? Colors.teal).withValues(
                        alpha: 0.15,
                      )
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(brand?.radius ?? 12),
                border: Border.all(
                  color: isSelected
                      ? (brand?.primaryBrand ?? Colors.teal)
                      : (brand?.primaryBrand ?? Colors.teal).withValues(
                          alpha: 0.2,
                        ),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (brand?.primaryBrand ?? Colors.teal)
                              .withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Flag icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (brand?.primaryBrand ?? Colors.teal).withValues(
                              alpha: 0.2,
                            )
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        AppLanguageController.getLanguageFlag(languageCode),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Language name
                  Expanded(
                    child: Text(
                      languageName,
                      style: AppTypography.body.copyWith(
                        fontSize: 18,
                        fontWeight: isSelected
                            ? (brand?.fontWeightSemiBold ?? FontWeight.w600)
                            : (brand?.fontWeightMedium ?? FontWeight.w500),
                        color: isSelected
                            ? (brand?.primaryBrand ?? Colors.teal)
                            : (brand?.textPrimary ?? AppColors.textPrimaryDark),
                      ),
                    ),
                  ),

                  // Checkmark for selected language
                  if (isSelected)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: brand?.primaryBrand ?? Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color:
                              brand?.textPrimary ?? AppColors.textPrimaryDark,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
