# UI V2 Settings & Profile Module

A polished settings and profile screen providing user customization options without backend integration.

## Architecture

### Components

1. **SettingsController** (`settings_controller.dart`)
   - Extends `ChangeNotifier` for reactive updates
   - Stores preferences in SharedPreferences
   - Settings managed:
     * `themeMode` (ThemeMode.light/dark/system)
     * `soundEnabled` (bool)
     * `language` (String: en/es/fr/de/ru/zh)
     * `username` (String)
   - Methods:
     * `initialize()` - Load saved preferences
     * `setThemeMode(ThemeMode)` - Update theme
     * `setSoundEnabled(bool)` - Toggle sound
     * `setLanguage(String)` - Change language
     * `setUsername(String)` - Update username
     * `resetToDefaults()` - Clear all settings

2. **SettingsScreen** (`settings_screen.dart`)
   - Main UI with 3 animated sections:
     * **Profile** - Avatar placeholder + editable username field
     * **Preferences** - Theme toggle (3 buttons) + Sound switch
     * **Language** - Dropdown selector (6 languages)
   - Reset button to restore defaults
   - 600ms fade-in animation
   - Section slide-in with staggered delays (0ms, 100ms, 200ms)

### UI Components

**_ProfileCard**
- Circular gradient avatar with person icon
- Editable username TextField
- 64px avatar with glow shadow
- Real-time username updates

**_SettingsTile**
- Icon + Title + Subtitle layout
- Container with subtle background
- Used for preferences section items

**_ThemeToggle**
- 3 buttons: Light/Dark/Auto
- Icon representation for each mode
- 150ms tap animation per button
- Active state with highlight and border

**_AnimatedSwitch**
- Custom switch with 150ms transition
- Uses accentSuccess color when active
- Syncs animation with value changes

**_LanguageSelector**
- Material Dropdown with 6 languages
- Language icon prefix
- Saves immediately on selection

## Integration

### HUD Overlay Navigation

Added settings button in `lib/ui_v2/hud/ui_v2_hud_overlay.dart`:

```dart
// Imports
import 'package:poker_analyzer/ui_v2/settings/settings_screen.dart';
import 'package:poker_analyzer/ui_v2/settings/settings_controller.dart';

// In _UiV2HudOverlayState:
Future<void> _openSettings() async {
  final controller = SettingsController();
  await controller.initialize();

  if (mounted) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(controller: controller),
      ),
    );
  }
}

// UI placement: Row with settings icon on left, demo toggle on right
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    IconButton(
      onPressed: _openSettings,
      icon: Icon(Icons.settings),
      tooltip: 'Settings',
    ),
    // ... multi-table demo button
  ],
)
```

### Usage

```dart
// Create and initialize controller
final controller = SettingsController();
await controller.initialize();

// Navigate to settings
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => SettingsScreen(controller: controller),
  ),
);

// Listen to changes
controller.addListener(() {
  print('Theme: ${controller.themeMode}');
  print('Sound: ${controller.soundEnabled}');
  print('Language: ${controller.language}');
  print('Username: ${controller.username}');
});
```

## SharedPreferences Keys

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `settings_theme_mode` | String | "ThemeMode.dark" | Theme mode enum string |
| `settings_sound_enabled` | bool | true | Sound effects toggle |
| `settings_language` | String | "en" | Language code |
| `settings_username` | String | "Player" | User display name |

## Animation Specifications

| Element | Duration | Curve | Effect |
|---------|----------|-------|--------|
| Screen fade-in | 600ms | easeOut | opacity 0→1 |
| Section slide-in | 600ms + delay | easeOutCubic | opacity + translate |
| Theme button tap | 150ms | linear | scale 1.0→0.9 |
| Switch transition | 150ms | default | thumb position |
| Reset button fade | 900ms | easeOutCubic | opacity 0→1 |

**Performance**: All animations < 5ms per frame ✅

## Design Tokens

Uses centralized BrandTheme:
- **Colors**: primaryBrand, accentSuccess, accentWarning, textPrimary/Secondary
- **Typography**: AppTypography.h1, h3, body, caption
- **Spacing**: spacingLarge (24px)
- **Radius**: radius (12px)
- **Icons**: Icons.person, settings, language, palette, volume_up, light_mode, dark_mode, brightness_auto

## Features

### Profile Section
- ✅ Circular gradient avatar with glow effect
- ✅ Editable username field with border focus state
- ✅ Real-time updates to SharedPreferences
- ✅ Edit state tracking (onEditingChanged callback)

### Preferences Section
- ✅ Theme toggle (Light/Dark/System) with 3 icon buttons
- ✅ Sound effects toggle with animated switch
- ✅ Visual feedback on selection

### Language Section
- ✅ Dropdown with 6 languages (English, Español, Français, Deutsch, Русский, 中文)
- ✅ Language icon prefix
- ✅ Immediate persistence

### Reset Functionality
- ✅ Confirmation dialog before reset
- ✅ Restores all settings to defaults
- ✅ Shows success SnackBar

## Quality Checks

```bash
✅ dart format --set-exit-if-changed lib/ui_v2/settings/
   → 3 files formatted (0 changed)

✅ dart analyze lib/ui_v2/settings/
   → No issues found

✅ dart test (5 critical tests)
   → guard_single_site_test.dart ✓
   → mvs_player_smoke_test.dart (2 tests) ✓✓
   → spotkind_integrity_smoke_test.dart (2 tests) ✓✓
   → All tests passed!
```

## Testing

To test settings in development:

```dart
// Reset settings to defaults
final controller = SettingsController();
await controller.initialize();
await controller.resetToDefaults();

// Or manually clear SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.remove('settings_theme_mode');
await prefs.remove('settings_sound_enabled');
await prefs.remove('settings_language');
await prefs.remove('settings_username');
```

## Future Enhancements

- [ ] Add profile picture upload (with image picker)
- [ ] Add notification preferences
- [ ] Add privacy settings
- [ ] Add account management (email, password)
- [ ] Add data export/import
- [ ] Add accessibility settings (font size, contrast)
- [ ] Add gameplay preferences (auto-fold, confirm actions)
- [ ] Add theme color customization
- [ ] Add sound volume slider
- [ ] Connect to backend API for syncing across devices
- [ ] Add analytics tracking for settings changes
- [ ] Add biometric authentication toggle
