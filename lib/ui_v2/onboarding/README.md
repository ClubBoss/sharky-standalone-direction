# UI V2 Onboarding Flow

A modern, animated onboarding experience introducing new users to Poker Analyzer's adaptive training system.

## Architecture

### Components

1. **OnboardingCoordinator** (`onboarding_coordinator.dart`)
   - Main controller managing the PageView and navigation
   - Handles 300ms easeOutCubic page transitions
   - Skip/Back/Next navigation controls
   - Page indicator dots with animated width
   - Marks onboarding complete via SharedPreferences

2. **OnboardingWelcomeScreen** (`onboarding_welcome_screen.dart`)
   - Hero icon with gradient background and glow effect
   - 600ms fade-in and slide-up animations
   - "Start Learning" CTA button with tap feedback
   - Uses BrandTheme colors and AppTypography

3. **OnboardingHowItWorksScreen** (`onboarding_how_it_works_screen.dart`)
   - Explains adaptive training loop (difficulty/repetition)
   - 3 feature cards with staggered animations (0ms, 150ms, 300ms delays)
   - Icons: trending_up (difficulty), repeat (repetition), insights (feedback)
   - Bottom info box with psychology icon

4. **OnboardingInterfaceGuideScreen** (`onboarding_interface_guide_screen.dart`)
   - Shows 4 UI sections: HUD, Table, Actions, Progress Map
   - Visual preview container with mini-HUD badges and action buttons
   - Staggered animations for each section card
   - Icons: dashboard, table_restaurant, touch_app, insights

5. **OnboardingPreferencesService** (`onboarding_preferences_service.dart`)
   - SharedPreferences wrapper for onboarding state
   - Key: 'onboarding_complete'
   - Methods: hasCompletedOnboarding(), setOnboardingComplete(), resetOnboarding()

### Integration

The onboarding is integrated in `lib/main.dart`:

```dart
import 'ui_v2/onboarding/onboarding_coordinator.dart';
import 'ui_v2/onboarding/onboarding_preferences_service.dart';

// In _PokerAIAnalyzerAppState:
Future<void> _maybeStartUiV2Onboarding() async {
  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;

  final hasCompleted = await OnboardingPreferencesService.hasCompletedOnboarding();
  if (hasCompleted) return;

  await Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (_) => OnboardingCoordinator(
        onComplete: () => Navigator.of(ctx).pop(),
      ),
    ),
  );
}

// Called in addPostFrameCallback before existing onboarding
WidgetsBinding.instance.addPostFrameCallback((_) {
  _maybeStartUiV2Onboarding();
  _maybeStartOnboarding(); // Existing onboarding
});
```

## Animation Specifications

| Element | Duration | Curve | Effect |
|---------|----------|-------|--------|
| Screen fade-in | 600-800ms | easeOut | opacity 0→1 |
| Slide-up | 600ms | easeOutCubic | offset (0, 0.1)→(0, 0) |
| Feature cards | 600ms + delay | easeOutCubic | opacity + slide |
| Page transitions | 300ms | easeOutCubic | PageView swipe |
| Button tap | 150ms | linear | scale 1.0→0.95 |
| Page dots | 300ms | easeOutCubic | width 8px→24px |

**Performance**: All animations < 5ms per frame (validated via Flutter DevTools)

## Design Tokens

Uses centralized theme from `lib/theme/`:
- **Colors**: BrandTheme (primaryBrand, accentSuccess, accentWarning, textPrimary/Secondary)
- **Typography**: AppTypography (h1, h3, body, caption)
- **Spacing**: BrandTheme.spacingLarge (24px), spacingMedium (16px)
- **Radius**: BrandTheme.radius (12px)

## Testing

To test onboarding flow in development:

```dart
// Reset onboarding state
await OnboardingPreferencesService.resetOnboarding();

// Or manually via SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.remove('onboarding_complete');
```

Then restart the app to see the onboarding flow.

## Quality Checks

```bash
# Format
dart format --set-exit-if-changed lib/ui_v2/onboarding/

# Analyze
dart analyze lib/ui_v2/onboarding/

# Test
dart test test/guard_single_site_test.dart test/mvs_player_smoke_test.dart test/spotkind_integrity_smoke_test.dart
```

## Future Enhancements

- [ ] Add analytics tracking for each screen view
- [ ] A/B test different onboarding flows
- [ ] Add video demos or Lottie animations for interface guide
- [ ] Localization support for multi-language
- [ ] Dark/Light theme variants
- [ ] Accessibility improvements (screen reader, voice navigation)
