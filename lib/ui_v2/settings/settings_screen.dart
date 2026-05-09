import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/settings/settings_controller.dart';
import 'package:poker_analyzer/ui_v2/settings/language_selector_panel.dart';
import 'package:poker_analyzer/services/app_language_controller.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

/// Settings Screen
///
/// Provides user customization options including profile, preferences,
/// and language selection. All settings are stored in SharedPreferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _usernameController.text = widget.controller.username;
    _animationController.forward();

    // Listen to controller changes
    widget.controller.addListener(_onControllerUpdate);

    // Load settings and listen for updates to refresh toggles
    AppSettingsService.instance.load();
    AppSettingsService.instance.changes.addListener(_onSettingsChanged);

    // Telemetry: settings_viewed
    FirebaseLiteTelemetryService.instance.logEvent('settings_viewed');
  }

  void _onControllerUpdate() {
    if (mounted && !_isEditingUsername) {
      setState(() {
        _usernameController.text = widget.controller.username;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _animationController.dispose();
    _usernameController.dispose();
    AppSettingsService.instance.changes.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingLarge ?? 24.0;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
        opacity: _fadeAnimation,
        child: ListView(
          padding: EdgeInsets.all(spacing),
          children: [
            // Profile Section
            _buildSection(
              context: context,
              title: 'Profile',
              icon: Icons.person,
              delay: 0,
              children: [
                _ProfileCard(
                  username: widget.controller.username,
                  usernameController: _usernameController,
                  onUsernameChanged: (name) {
                    widget.controller.setUsername(name);
                  },
                  onEditingChanged: (editing) {
                    setState(() => _isEditingUsername = editing);
                  },
                ),
              ],
            ),
            SizedBox(height: spacing),
            // Preferences Section
            _buildSection(
              context: context,
              title: 'Preferences',
              icon: Icons.settings,
              delay: 100,
              children: [
                _SettingsTile(
                  icon: Icons.palette,
                  title: 'Theme',
                  subtitle: _getThemeLabel(widget.controller.themeMode),
                  trailing: _ThemeToggle(
                    currentMode: widget.controller.themeMode,
                    onChanged: (mode) {
                      widget.controller.setThemeMode(mode);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.volume_up,
                  title: 'Sound Effects',
                  subtitle: AppSettingsService.instance.snapshot.soundEnabled
                      ? 'On'
                      : 'Off',
                  trailing: _AnimatedSwitch(
                    value: AppSettingsService.instance.snapshot.soundEnabled,
                    onChanged: AppSettingsService.instance.setSoundEnabled,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.vibration,
                  title: 'Haptics',
                  subtitle: AppSettingsService.instance.snapshot.hapticsEnabled
                      ? 'On'
                      : 'Off',
                  trailing: _AnimatedSwitch(
                    value: AppSettingsService.instance.snapshot.hapticsEnabled,
                    onChanged: AppSettingsService.instance.setHapticsEnabled,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.school,
                  title: 'AI Coach',
                  subtitle: AppSettingsService.instance.snapshot.aiCoachEnabled
                      ? 'On'
                      : 'Off',
                  trailing: _AnimatedSwitch(
                    value: AppSettingsService.instance.snapshot.aiCoachEnabled,
                    onChanged: AppSettingsService.instance.setAiCoachEnabled,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            // Language Section (Stage D16: Navigate to full selector panel)
            _buildSection(
              context: context,
              title: 'Language',
              icon: Icons.language,
              delay: 200,
              children: [
                _LanguageSelectorButton(
                  currentLanguage: widget.controller.language,
                  headerLabel: l10n.languageSelectorTitle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LanguageSelectorPanelWrapper(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: spacing * 2),
            // Reset Button
            _buildResetButton(context),
            SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int delay,
    required List<Widget> children,
  }) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
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
      child: Container(
        decoration: BoxDecoration(
          color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(brand?.radius ?? 12),
          border: Border.all(
            color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (brand?.primaryBrand ?? Colors.teal).withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: brand?.primaryBrand ?? Colors.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: AppTypography.h3.copyWith(
                      fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
                      color: brand?.textPrimary ?? AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
            // Section Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final l10n = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.reset),
              content: Text(l10n.settingsResetConfirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.reset),
                ),
              ],
            ),
          );

          if (confirm == true && mounted) {
            await widget.controller.resetToDefaults();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsResetSuccess),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.refresh),
        label: Text(l10n.reset),
        style: OutlinedButton.styleFrom(
          foregroundColor: brand?.textSecondary ?? AppColors.textSecondaryDark,
          side: BorderSide(
            color: (brand?.textSecondary ?? AppColors.textSecondaryDark)
                .withValues(alpha: 0.3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(brand?.radius ?? 12),
          ),
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

/// Profile Card with avatar and username
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.username,
    required this.usernameController,
    required this.onUsernameChanged,
    required this.onEditingChanged,
  });

  final String username;
  final TextEditingController usernameController;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<bool> onEditingChanged;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  brand?.primaryBrand ?? Colors.teal,
                  (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (brand?.primaryBrand ?? Colors.teal).withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: brand?.textPrimary ?? AppColors.textPrimaryDark,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // Username Field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username',
                  style: AppTypography.caption.copyWith(
                    color: brand?.textSecondary ?? AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: usernameController,
                  style: AppTypography.body.copyWith(
                    color: brand?.textPrimary ?? AppColors.textPrimaryDark,
                    fontWeight: brand?.fontWeightMedium ?? FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: (brand?.primaryBrand ?? Colors.teal).withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: (brand?.primaryBrand ?? Colors.teal).withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: brand?.primaryBrand ?? Colors.teal,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (_) => onEditingChanged(true),
                  onSubmitted: (value) {
                    onEditingChanged(false);
                    onUsernameChanged(value);
                  },
                  onEditingComplete: () => onEditingChanged(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings Tile
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
      ),
      child: Row(
        children: [
          Icon(icon, color: brand?.primaryBrand ?? Colors.teal, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: brand?.fontWeightMedium ?? FontWeight.w500,
                    color: brand?.textPrimary ?? AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: brand?.textSecondary ?? AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Theme Toggle with 3 options
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.currentMode, required this.onChanged});

  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThemeButton(
          icon: Icons.light_mode,
          label: 'Light',
          isSelected: currentMode == ThemeMode.light,
          onPressed: () => onChanged(ThemeMode.light),
          brand: brand,
        ),
        const SizedBox(width: 4),
        _ThemeButton(
          icon: Icons.dark_mode,
          label: 'Dark',
          isSelected: currentMode == ThemeMode.dark,
          onPressed: () => onChanged(ThemeMode.dark),
          brand: brand,
        ),
        const SizedBox(width: 4),
        _ThemeButton(
          icon: Icons.brightness_auto,
          label: 'Auto',
          isSelected: currentMode == ThemeMode.system,
          onPressed: () => onChanged(ThemeMode.system),
          brand: brand,
        ),
      ],
    );
  }
}

/// Theme Button
class _ThemeButton extends StatefulWidget {
  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.brand,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final BrandTheme? brand;

  @override
  State<_ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<_ThemeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 - (_controller.value * 0.1);
        return Transform.scale(scale: scale, child: child);
      },
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? (widget.brand?.primaryBrand ?? Colors.teal).withValues(
                    alpha: 0.3,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? (widget.brand?.primaryBrand ?? Colors.teal)
                  : (widget.brand?.primaryBrand ?? Colors.teal).withValues(
                      alpha: 0.3,
                    ),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: widget.isSelected
                ? (widget.brand?.primaryBrand ?? Colors.teal)
                : (widget.brand?.textSecondary ?? AppColors.textSecondaryDark),
          ),
        ),
      ),
    );
  }
}

/// Animated Switch with smooth transition
class _AnimatedSwitch extends StatefulWidget {
  const _AnimatedSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<_AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(_AnimatedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: widget.value,
      onChanged: widget.onChanged,
      activeTrackColor:
          Theme.of(context).extension<BrandTheme>()?.accentSuccess ??
          AppColors.accentSuccess,
    );
  }
}

/// Language Selector Button (Stage D16: Opens full selector panel)
class _LanguageSelectorButton extends StatelessWidget {
  const _LanguageSelectorButton({
    required this.currentLanguage,
    required this.headerLabel,
    required this.onTap,
  });

  final String currentLanguage;
  final String headerLabel;
  final VoidCallback onTap;

  static const Map<String, String> _languages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'ru': 'Русский',
    'zh': '中文',
  };

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final languageName = _languages[currentLanguage] ?? 'English';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(brand?.radius ?? 12),
            border: Border.all(
              color: (brand?.primaryBrand ?? Colors.teal).withValues(
                alpha: 0.3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: brand?.primaryBrand ?? Colors.teal,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerLabel,
                      style: AppTypography.caption.copyWith(
                        color:
                            brand?.textSecondary ?? AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      languageName,
                      style: AppTypography.body.copyWith(
                        fontWeight: brand?.fontWeightMedium ?? FontWeight.w500,
                        color: brand?.textPrimary ?? AppColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: brand?.textSecondary ?? AppColors.textSecondaryDark,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper for LanguageSelectorPanel with Provider access
/// Stage D16: Provides AppLanguageController to the panel
class LanguageSelectorPanelWrapper extends StatelessWidget {
  const LanguageSelectorPanelWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the language controller from the app's providers
    return LanguageSelectorPanel(
      controller: context.read<AppLanguageController>(),
    );
  }
}
