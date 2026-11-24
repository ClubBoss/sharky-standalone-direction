# Act0 skin layer · B32

Baseline source is `de65222fc` on `codex/b32-skin-layer`. The skin and capture test are staged as additive files. Screen adoption is pending a pre-migration baseline.

## Token audit

| Learner surface | Current source and owner |
|---|---|
| Home | `Act0AcademyHomeLeafV1` uses the Academy leaf palette and inline treatments, with Club Night secondary text. The fallback `act0_home_shell_v1.dart` combines Academy Editorial and Shell tokens. |
| Map / Learn / Worlds | `act0_learn_path_shell_v1.dart` and its journey, mission, and world-menu parts mix Academy Editorial surfaces/type with Shell sizing, colors, and motion. |
| Lesson intro / task | The runner and its parts use Shell tokens for lesson chrome, typography, and table and answer colors. The Learn mission card uses Academy Editorial. |
| Result | `act0_lesson_runner_completion_v1.dart` uses Academy Reading Style (from Academy Editorial) for paint and text, Shell tokens for geometry and motion. |
| Review | The English Academy leaf uses its teal palette and inline styles. `act0_review_shell_v1.dart` uses Academy Reading Style plus Shell. |
| Profile / You | The English Academy leaf uses Club Night cards, text, and accents with inline type and Academy glyphs. The fallback `act0_profile_shell_v1.dart` uses Academy Reading Style and Shell. |
| Practice / Settings | Academy leaves use their teal palette. Settings also uses inherited Material values. |
| Welcome / Placement | Shell and Academy Editorial appear together in their surface owners. B23's draft also owns their presentation-state changes. |
| Archive / manual hand / replay | Archive uses Academy Reading Style and inherited Material list controls. Manual hand uses Club Night. Replay remains with its existing table and replay owners. |
| Shared shell chrome | `act0_shell_chrome_v1.dart` and the preview shell combine Shell, Academy Editorial, and Academy leaf palette. `app_root.dart` supplies dark Material 3 and InkRipple. |
| Other requested sources | Direct Act0 and app-root searches found no use of `DesignColors`, `DesignSpacing`, `DesignRadii`, `BrandTheme` from `theme_v2.dart`, or `VisualCohesionTokensV3`. Those files have consumers elsewhere in UI V2, including older shared components, themes, and table primitives. |

| Role overlap | Duplicates and conflicts |
|---|---|
| Surface and foreground | Shell navy `#101A2B / #FFFFFF`, Academy Editorial ivory `#FFFEF9 / #182E32`, Club Night green-black `#161D1A / #F4EFE4`, Academy leaf ink `#020E13 / #F1FBF8`, legacy Design `#0E0E10 / #E5E5E7`. Legacy `surfaceLight` and `surfaceElevated` are both `#1A1A1D`. Shell `surface` and `surface3` both use navy. |
| Accent / warning / success | Shell uses `#0A64D8 / #FFC84D / #16C784`. Academy Editorial uses teal focus `#126761`, review brown `#7F4C13`, and success `#226844`. Club Night uses brass `#D8B46A` for accent and attention, green `#4FC891` for success. The Academy leaf accent is `#23E6D2`. Legacy Design accent is `#4F8BFF`. |
| Line and muted text | Shell `#1F2E43 / #B7C4D6`, Editorial `#CBD1C7 / #536560`, Club Night `#1AE8D6AA / #B8B2A3`, legacy Design `#2C2C2F / #B3B3B6`. Club Night line includes alpha. |
| Space and radius | Shell, Club Night and legacy Design share 4/8/12/16 gaps. Editorial starts at 8 and increments by 4. Cohesion uses 6/12/20. Club Night card radius is 20, Editorial card 6, Shell `radiusCard` 18 and Shell surface decoration 16. Legacy Design radii are 6/10/14 and Cohesion radii 4/8/12. |
| Type and elevation | Club Night body is 17 pt and Shell body 13 pt. Editorial uses Georgia for headings and Arial for body. Club Night primary elevation is 0. Shell surface decoration uses a shadow with 18 pt blur and 10 pt offset. Cohesion defines 2/6/12 elevations and separate shadows. `ThemeV2` is empty and its adjacent `BrandTheme` extension has independent runtime color values. |
| Motion | Club Night declares 350 ms ease-out cubic. Shell declares 140/260/420/900 ms and separate curves. Learn also specifies inline durations, such as 150 ms for path row expansion. |

The different paints are visible today. Adoption needs to preserve the roles used by each existing presentation. B32 leaves the Modern Table geometry, camera, and artwork under their current owners.

## Designer interface

Supply the value for each role below and widget implementations with the component inputs and states listed after it. Screens own learner data, localized copy, navigation, and callbacks. The kit uses projected values, so it can consume B23's models without importing the Welcome, Placement, or Archive screens. B23's Placement model supplies primary-action availability, the Welcome state supplies the current beat, and the Archive model supplies filtering and browsing state. Home and Review continue to get data from their existing projections. B25 owns the dedicated Map, Lesson intro and Result view models per the screen vision.

### Tokens

| Name | Role | Current value |
|---|---|---|
| `background` | Club Night page backing | `Color(0xFF0E1311)` |
| `surface` | Club Night card fill | `Color(0xFF161D1A)` |
| `raised` | Club Night elevated/control fill | `Color(0xFF1F2925)` |
| `track` | Track | `Color(0xFF2A3430)` |
| `scrim` | Scrim | `Color(0x9E050807)` |
| `line` | Default Club Night outline | `Color(0x1AE8D6AA)` |
| `lineStrong` | Line strong | `Color(0x24E8D6AA)` |
| `lineRing` | Line ring | `Color(0x4DE8D6AA)` |
| `onSurface` | Primary Club Night foreground | `Color(0xFFF4EFE4)` |
| `muted` | Secondary Club Night text | `Color(0xFFB8B2A3)` |
| `caption` | Tertiary Club Night foreground | `Color(0xFF9C9789)` |
| `accent` | Primary Club Night action and emphasis | `Color(0xFFD8B46A)` |
| `onAccent` | Foreground on accent fill | `Color(0xFF1A1508)` |
| `accentSoft` | Accent soft | `Color(0x29D8B46A)` |
| `accentEdge` | Accent edge | `Color(0x47D8B46A)` |
| `ok` | Positive feedback | `Color(0xFF4FC891)` |
| `okSoft` | Ok soft | `Color(0x1A4FC891)` |
| `bad` | Negative feedback | `Color(0xFFFF8A73)` |
| `badSoft` | Bad soft | `Color(0x1FFF8A73)` |
| `badEdge` | Bad edge | `Color(0x8CFF8A73)` |
| `screenGutter` | Screen gutter | `20` |
| `gapXs` | Gap xs | `4` |
| `gapSm` | Gap sm | `8` |
| `gapMd` | Gap md | `12` |
| `gapLg` | Gap lg | `16` |
| `gapXl` | Gap xl | `24` |
| `cardPadding` | Card padding | `20` |
| `radiusControl` | Radius control | `16` |
| `radiusGroup` | Radius group | `16` |
| `radiusCard` | Radius card | `20` |
| `radiusSheet` | Radius sheet | `28` |
| `controlHeight` | Control height | `56` |
| `minTouch` | Min touch | `44` |
| `ringSmall` | Ring small | `56` |
| `ringLarge` | Ring large | `120` |
| `maxTextScale` | Max text scale | `1.3` |
| `motion` | Club Night transition duration | `Duration(milliseconds: 350)` |
| `motionCurve` | Club Night transition curve | `Curves.easeOutCubic` |
| `pressedScale` | Pressed scale | `0.97` |
| `tabular` | Tabular numerals | `[FontFeature.tabularFigures()]` |
| `figure` | Large numeric value | `TextStyle( color: onSurface, fontSize: 34, height: 41 / 34, fontWeight: FontWeight.w700, letterSpacing: -0.6, fontFeatures: tabular,)` |
| `title` | Main Club Night heading | `TextStyle( color: onSurface, fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700, letterSpacing: -0.4,)` |
| `question` | Question | `TextStyle( color: onSurface, fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w600,)` |
| `headline` | Headline | `TextStyle( color: onSurface, fontSize: 17, height: 22 / 17, fontWeight: FontWeight.w600,)` |
| `body` | Main Club Night prose | `TextStyle( color: onSurface, fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w400,)` |
| `secondary` | Secondary Club Night prose | `TextStyle( color: muted, fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w400,)` |
| `captionStyle` | Caption style | `TextStyle( color: caption, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w400,)` |
| `sectionLabel` | Section label | `TextStyle( color: caption, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w600, letterSpacing: 0.3,)` |
| `button` | Button | `TextStyle( fontSize: 17, height: 22 / 17, fontWeight: FontWeight.w600,)` |
| `link` | Link | `TextStyle( color: accent, fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w600,)` |
| `tag` | Chip label typography | `TextStyle( fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w600,)` |
| `tab` | Tab | `TextStyle( fontSize: 11, height: 13 / 11, fontWeight: FontWeight.w600,)` |
| `cardBorder` | Card border | `BorderSide(color: line)` |
| `controlBorder` | Control border | `BorderSide(color: lineStrong)` |
| `editorialPageSurface` | Editorial page surface | `Color(0xFFF7F5ED)` |
| `editorialCardSurface` | Editorial card surface | `Color(0xFFFFFEF9)` |
| `editorialInk` | Editorial ink | `Color(0xFF182E32)` |
| `editorialInkMuted` | Editorial ink muted | `Color(0xFF536560)` |
| `editorialFocus` | Editorial focus | `Color(0xFF126761)` |
| `editorialPrimaryAction` | Editorial primary action | `Color(0xFF17393A)` |
| `editorialOnPrimaryAction` | Editorial on primary action | `Color(0xFFFFFEF8)` |
| `editorialNeedsReviewFg` | Editorial needs review fg | `Color(0xFF7F4C13)` |
| `editorialNeedsReviewBg` | Editorial needs review bg | `Color(0xFFF2E5CD)` |
| `editorialCorrectFg` | Editorial correct fg | `Color(0xFF226844)` |
| `editorialCorrectBg` | Editorial correct bg | `Color(0xFFE1EEE2)` |
| `editorialFolioBrass` | Editorial folio brass | `Color(0xFFE4CDA5)` |
| `editorialFolioEditorial` | Editorial folio editorial | `Color(0xFF7A414D)` |
| `editorialRule` | Editorial rule | `Color(0xFFCBD1C7)` |
| `editorialGapXs` | Editorial gap xs | `8` |
| `editorialGapSm` | Editorial gap sm | `12` |
| `editorialGapMd` | Editorial gap md | `16` |
| `editorialGapLg` | Editorial gap lg | `20` |
| `editorialGapXl` | Editorial gap xl | `24` |
| `editorialRadiusCard` | Editorial radius card | `6` |
| `editorialRadiusCoachFrame` | Editorial radius coach frame | `12` |
| `editorialDisplayFont` | Editorial display font | `'Georgia'` |
| `editorialDisplayFallback` | Editorial display fallback | `[ 'Times New Roman', 'Noto Serif', 'serif',]` |
| `editorialDisplay` | Editorial display | `TextStyle( fontFamily: editorialDisplayFont, fontFamilyFallback: editorialDisplayFallback, color: editorialInk, fontSize: 38, height: 1.12, fontWeight: FontWeight.w700,)` |
| `editorialSectionHeading` | Editorial section heading | `TextStyle( fontFamily: editorialDisplayFont, fontFamilyFallback: editorialDisplayFallback, color: editorialInk, fontSize: 24, height: 1.14, fontWeight: FontWeight.w700,)` |
| `editorialLessonHeading` | Editorial lesson heading | `TextStyle( fontFamily: editorialDisplayFont, fontFamilyFallback: editorialDisplayFallback, color: editorialInk, fontSize: 30, height: 1.16, fontWeight: FontWeight.w700,)` |
| `editorialBody` | Editorial body | `TextStyle( fontFamily: 'Arial', fontFamilyFallback: ['Roboto', 'sans-serif'], color: editorialInk, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500,)` |
| `editorialSupporting` | Editorial supporting | `TextStyle( fontFamily: 'Arial', fontFamilyFallback: ['Roboto', 'sans-serif'], color: editorialInkMuted, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500,)` |
| `editorialLabel` | Editorial label | `TextStyle( fontFamily: 'Arial', fontFamilyFallback: ['Roboto', 'sans-serif'], color: editorialInkMuted, fontSize: 10, height: 1.5, fontWeight: FontWeight.w700, letterSpacing: 1.2,)` |
| `micro` | Small transitions | `Duration(milliseconds: 140)` |
| `standard` | Navigation or ordinary transitions | `Duration(milliseconds: 260)` |
| `emphasis` | Stronger confirmation transition | `Duration(milliseconds: 420)` |
| `milestone` | Rare completion transition | `Duration(milliseconds: 900)` |
| `enter` | Entry motion curve | `Curves.easeOutCubic` |
| `exit` | Exit motion curve | `Curves.easeIn` |
| `settle` | Settling motion curve | `Curves.easeInOutCubic` |
| `emphasisCurve` | Emphasis curve | `Curves.easeOut` |
| `warn` | Attention | `accent` |
| `feltCenter` | Felt center | `Color(0xFF146B56)` |
| `feltMid` | Felt mid | `Color(0xFF0F5A47)` |
| `feltEdge` | Felt edge | `Color(0xFF0B4A3B)` |
| `navySurface` | Navy surface | `Color(0xFF101A2B)` |
| `navyRaised` | Navy raised | `Color(0xFF0D1726)` |
| `navyLine` | Navy line | `Color(0xFF1F2E43)` |
| `navyAccent` | Navy accent | `Color(0xFF0A64D8)` |
| `navyOnSurface` | Navy on surface | `Color(0xFFFFFFFF)` |
| `navyMuted` | Navy muted | `Color(0xFFB7C4D6)` |
| `navyOk` | Navy ok | `Color(0xFF16C784)` |
| `navyWarn` | Navy warn | `Color(0xFFFFC84D)` |
| `navyBad` | Navy bad | `Color(0xFFFF5A5A)` |
| `controlElevation` | Material control elevation | `0.0` |
| `academyBackground` | Academy leaf page background | `#FF020E13` |
| `academyRaised` | Academy leaf raised fill | `#FF071C24` |
| `academyTealDeep` | Academy leaf dark teal | `#FF0B3530` |
| `academyTeal` | Academy leaf teal | `#FF177D70` |
| `academyAccent` | Academy leaf aqua action | `#FF23E6D2` |
| `academyAccentSoft` | Academy leaf aqua support | `#FFB9F5E9` |
| `academyOnSurface` | Academy leaf primary text | `#FFF1FBF8` |
| `academyMuted` | Academy leaf supporting text | `#FFB6C8D5` |
| `academyLine` | Academy leaf outline | `#FF23443F` |
| `academyWarn` | Academy leaf repair emphasis | `#FFF2C46B` |
| `courseProgressTrack` | Course progress track | `Color(0xFF102A35)` |
| `courseProgressFill` | Course progress fill | `academyAccent` |
| `courseProgressHeight` | Course progress height | `12.0` |
| `courseProgressRadius` | Course progress radius | `7.0` |
| `expandIcon` | Expand icon | `Icons.expand_more` |
| `collapseIcon` | Collapse icon | `Icons.expand_less` |
| `correctIcon` | Correct icon | `Icons.check_rounded` |
| `mistakeIcon` | Mistake icon | `Icons.close_rounded` |
| `sharkyMistakeAsset` | Sharky mistake asset | `sharkyHintAsset` |
| `sharkyFixedItAsset` | Sharky fixed it asset | `sharkyHintAsset` |
| `sharkyLessonDoneAsset` | Sharky lesson done asset | `sharkyHintAsset` |
| `reviewEmptyTitle` | Review empty title | `TextStyle( color: academyOnSurface, fontSize: 25, height: 1.2, fontWeight: FontWeight.w600,)` |
| `reviewEmptyBody` | Review empty body | `TextStyle( color: academyMuted, fontSize: 14, height: 1.4,)` |
| `navyStatLabel` | Navy stat label | `TextStyle( color: navyMuted, fontSize: 10, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: 1.4,)` |
| `navyStatValue` | Navy stat value | `TextStyle( color: navyOnSurface, fontSize: 13, height: 1.35, fontWeight: FontWeight.w700,)` |
| `navyStatSupport` | Navy stat support | `TextStyle( color: navyMuted, fontSize: 12, height: 1.32, fontWeight: FontWeight.w600,)` |
| `navyCompactStatRadius` | Navy compact stat radius | `14.0` |
| `navyStatRadius` | Navy stat radius | `16.0` |
| `navyStatShadow` | Navy stat shadow | `BoxShadow( color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 10),)` |
| `durationFor(context, duration)` | Reduced Motion resolution | MediaQuery disableAnimations gives zero; otherwise the input duration |
| `themeSurface(context)` | Material notice fill | Inherited dark Material 3 color scheme surface |

### Components

Names below expand to `Act0Skin<Name>V1`. Flutter keys remain optional. Pass learner-facing text from the owning route or view model.

| Name | Props | States | Today's look |
|---|---|---|---|
| PrimaryButton | label, onPressed, controlKey | enabled, pressed, disabled | Club Night full-width 56 pt brass FilledButton with 16 pt corners. |
| SecondaryButton | label, onPressed, destructive, controlKey | enabled, pressed, disabled, destructive | Raised outlined Club Night button; coral fill and outline for destructive actions. |
| Card | child, padding, emphasized, quiet | standard, emphasized, quiet | Club Night surface or wall fill, 20 pt corners and hairline; stronger brass outline on emphasis. |
| ListRow | title, subtitle, expanded, onTap, controlKey | collapsed, expanded, disabled | Archive Material ListTile with Editorial text and existing expand/collapse glyphs. |
| ProgressBar | ratio, label, valueLabel, indicatorKey | value, missing | Home's 12 pt aqua bar with 7 pt clipping radius. Missing data draws the decorative track. |
| ProgressRing | ratio, label, valueLabel | determinate, loading, reduced motion | Settings' Material aqua indicator. Loading uses a static zero indicator with Reduce Motion. |
| StepBar | total, current | done, current, ahead | Club Night segmented lesson progress with brass completed and light current segments. |
| Chip | label, tone | brass, correct, neutral | Club Night pill with semantic tint and text. |
| Banner | message, actionLabel, onAction | message, message with action | Progress-save notice treatment, with Material surface and live-region message. |
| EmptyState | title, description, titleKey | empty | Review's 25 pt heading and 14 pt helper copy. |
| SheetHeader | title, overline, subtitle, trailing | title only, supporting copy, trailing widget | Club Night header typography with a semantic heading. |
| StatTile | label, value, subLine, compact | standard, compact, optional support line | Legacy Profile navy stat tile with outline and shadow, or compact outline. |
| AnswerOptionRow | label, verdict, onTap | available, disabled, not-this-one, better | Club Night answer row with coral or green and both icon and label for feedback. |
| SharkyExpression | moment, size | hint, mistake, selfFix, milestone | Existing neutral mascot bitmap with a distinct ring role, 56 pt inline or 120 pt in summary. |

## Adoption and visual comparison

First migration candidates are Home, Map, Review and Profile. Each still uses its current widgets. Lesson intro/task, Result, Practice, Settings, Welcome, Placement, Archive, manual hand and replay remain outside that first group. The target is per-screen replacement of styling with the existing corresponding treatment inside the kit. Shared chrome needs its own follow-through because it affects all six captures.

The opt-in widget golden test uses existing Act0 capture fixtures, English, 393×852 logical pixels at DPR 1, 1.0× and 1.3× text, dark Material 3, and Reduce Motion. Map is the Learn path, Lesson intro is the opening W1 authored theory state, and Result is the lesson session summary. Keep the same SDK, OS, fonts, and device settings for both passes. From the project root, before any screen migration:

```sh
flutter test test/ui_v2/act0_skin_parity_v1_goldens.dart --update-goldens
```

Keep the 12 generated PNGs in `output/b32_skin/`. After migration, compare to those images without regenerating them:

```sh
flutter test test/ui_v2/act0_skin_parity_v1_goldens.dart
```

Golden evidence is pending. Flutter startup was denied writes to the cached SDK stamp and the Dart telemetry session in this sandbox. The test has been written against the existing fixtures, with its rendering and parity still to be exercised.

## Shell literal guard · B66

Tier A runs `test/guards/act0_skin_literal_guard_v1_test.dart`. It scans Act0
shell Dart source for inline colors, `TextStyle` font sizes and colors,
circular border radii, and numeric `EdgeInsets`. The skin kit, existing token
owners, frozen Modern Table presentation files, and generated code are exempt.
Transparent Material color is allowed.

Run `dart test test/guards/act0_skin_literal_guard_v1_test.dart -r expanded`
from the project root. Use the ten highest counts to sequence B35, B37, B38,
and ALPHA2. Each file has its own ceiling in
`test/guards/act0_skin_literal_baseline_v1.json`. When a file migrates, lower
its entry to the new count or remove the entry at zero. New files start at zero.
