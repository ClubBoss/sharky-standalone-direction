# Designer skin pack · v1 (B111)

Deliver a directory containing `tokens.json` and a flat `assets/` directory.
The sample at `test/fixtures/skin_pack_sample_v1/` contains B101's test-only
Variant C values and generated, non-art B104 placeholders (gray RGB icon and
transparent RGBA mascots). It is not an approved design; never apply it to a
production checkout merely to test the importer.

```sh
python3 tools/skin_pack_apply_v1.py --check /path/to/pack
python3 tools/skin_pack_apply_v1.py --apply /path/to/pack
```

Both commands validate the whole pack; errors name the offending key or file
and exit 1. `--check` never writes. `--apply` checks first, then updates only
initializers in `lib/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart` and copies
exactly the five files to `assets/skin_v1/`. Review the resulting Git diff and
run the normal tests and visual review before merging. B104 reserves slots;
this tool does not wire screens, generate a native launcher icon or change
Modern Table. An I/O failure during writing is not an atomic transaction.

**Dry run before PR.**
Run `python3 tools/skin_drop_in_dryrun_v1.py /path/to/pack` for the HTML preview, would-change paths and B103 affected tests; invalid packs fail.
Only pass `--keep` to apply the checked changes to the working skin files; otherwise only the local HTML report is retained.

The existing B101 rehearsal is palette-only; if an approved pack changes
non-color values or exactly matches its test palette, refresh that rehearsal
control in the landing PR rather than weakening its visual checks.

Preview before PR: `python3 tools/skin_pack_preview_v1.py /path/to/pack --out preview.html` (default output: `skin_pack_preview.html`; review the sheet even on FAIL).

## Token keys

The 134 keys below are exactly the constant rows in the B32 designer contract
[`SKIN_LAYER_v1.md`](../../docs/plan/SKIN_LAYER_v1.md#tokens), not every internal
constant or method in the Dart class. No missing, extra or duplicate keys.
`feltCenter`, `feltMid` and `feltEdge` must echo their current values unchanged
because table paint is outside this package. All other fixed token references
must remain references to the same role (including nested references).

- Colors are strings `#AARRGGBB` (alpha first, eight hex digits).
- Numbers are finite JSON numbers, not quoted strings or booleans. Dimensions
  are logical points, height is the font-size multiplier, and opacity/scale
  values are fractions. Duration values are nonnegative integer milliseconds.
- Curve names: `linear`, `ease`, `easeIn`, `easeOut`, `easeInOut`,
  `easeOutCubic`, `easeInCubic`, `easeInOutCubic`. Icon names are the existing
  B32 glyph choices: `expand_more`, `expand_less`, `chevron_right`,
  `check_rounded`, `close_rounded`.
- Font names are strings (letters, digits, spaces, dots, hyphens, underscores);
  fallbacks are arrays of names. Font weights are integers 100–900 in steps of
  100. `tabular` is the fixed array `["tabularFigures"]`.
- Composite styles are JSON objects with exactly their existing fields, as
  illustrated by the sample. `offset` is `[x, y]`; color references and font
  references are role-name strings, not arbitrary Dart. No Dart code is accepted.
  For example, `cardBorder` is `{"color": "line"}` and `title` is
  `{"color": "onSurface", "fontSize": 28, "height": 1.2142857142857142,
  "fontWeight": 700, "letterSpacing": -0.4}`.

| Token | JSON value type |
| --- | --- |
| `background` | ARGB color (#AARRGGBB) |
| `surface` | ARGB color (#AARRGGBB) |
| `raised` | ARGB color (#AARRGGBB) |
| `track` | ARGB color (#AARRGGBB) |
| `scrim` | ARGB color (#AARRGGBB) |
| `line` | ARGB color (#AARRGGBB) |
| `lineStrong` | ARGB color (#AARRGGBB) |
| `lineRing` | ARGB color (#AARRGGBB) |
| `onSurface` | ARGB color (#AARRGGBB) |
| `muted` | ARGB color (#AARRGGBB) |
| `caption` | ARGB color (#AARRGGBB) |
| `accent` | ARGB color (#AARRGGBB) |
| `onAccent` | ARGB color (#AARRGGBB) |
| `accentSoft` | ARGB color (#AARRGGBB) |
| `accentEdge` | ARGB color (#AARRGGBB) |
| `ok` | ARGB color (#AARRGGBB) |
| `okSoft` | ARGB color (#AARRGGBB) |
| `bad` | ARGB color (#AARRGGBB) |
| `badSoft` | ARGB color (#AARRGGBB) |
| `badEdge` | ARGB color (#AARRGGBB) |
| `screenGutter` | finite number |
| `gapXs` | finite number |
| `gapSm` | finite number |
| `gapMd` | finite number |
| `gapLg` | finite number |
| `gapXl` | finite number |
| `cardPadding` | finite number |
| `radiusControl` | finite number |
| `radiusGroup` | finite number |
| `radiusCard` | finite number |
| `radiusSheet` | finite number |
| `controlHeight` | finite number |
| `minTouch` | finite number |
| `ringSmall` | finite number |
| `ringLarge` | finite number |
| `maxTextScale` | finite number |
| `motion` | milliseconds (nonnegative integer) |
| `motionCurve` | Curves name |
| `pressedScale` | finite number |
| `tabular` | fixed tabular font feature |
| `figure` | TextStyle object with fields color, fontSize, height, fontWeight, letterSpacing, fontFeatures |
| `title` | TextStyle object with fields color, fontSize, height, fontWeight, letterSpacing |
| `question` | TextStyle object with fields color, fontSize, height, fontWeight |
| `headline` | TextStyle object with fields color, fontSize, height, fontWeight |
| `body` | TextStyle object with fields color, fontSize, height, fontWeight |
| `secondary` | TextStyle object with fields color, fontSize, height, fontWeight |
| `captionStyle` | TextStyle object with fields color, fontSize, height, fontWeight |
| `sectionLabel` | TextStyle object with fields color, fontSize, height, fontWeight, letterSpacing |
| `button` | TextStyle object with fields fontSize, height, fontWeight |
| `link` | TextStyle object with fields color, fontSize, height, fontWeight |
| `tag` | TextStyle object with fields fontSize, height, fontWeight |
| `tab` | TextStyle object with fields fontSize, height, fontWeight |
| `cardBorder` | BorderSide object with fields color |
| `controlBorder` | BorderSide object with fields color |
| `editorialPageSurface` | ARGB color (#AARRGGBB) |
| `editorialCardSurface` | ARGB color (#AARRGGBB) |
| `editorialInk` | ARGB color (#AARRGGBB) |
| `editorialInkMuted` | ARGB color (#AARRGGBB) |
| `editorialFocus` | ARGB color (#AARRGGBB) |
| `editorialPrimaryAction` | ARGB color (#AARRGGBB) |
| `editorialOnPrimaryAction` | ARGB color (#AARRGGBB) |
| `editorialNeedsReviewFg` | ARGB color (#AARRGGBB) |
| `editorialNeedsReviewBg` | ARGB color (#AARRGGBB) |
| `editorialCorrectFg` | ARGB color (#AARRGGBB) |
| `editorialCorrectBg` | ARGB color (#AARRGGBB) |
| `editorialFolioBrass` | ARGB color (#AARRGGBB) |
| `editorialFolioEditorial` | ARGB color (#AARRGGBB) |
| `editorialRule` | ARGB color (#AARRGGBB) |
| `editorialGapXs` | finite number |
| `editorialGapSm` | finite number |
| `editorialGapMd` | finite number |
| `editorialGapLg` | finite number |
| `editorialGapXl` | finite number |
| `editorialRadiusCard` | finite number |
| `editorialRadiusCoachFrame` | finite number |
| `editorialDisplayFont` | font name |
| `editorialDisplayFallback` | font name list |
| `editorialDisplay` | TextStyle object with fields fontFamily, fontFamilyFallback, color, fontSize, height, fontWeight |
| `editorialSectionHeading` | TextStyle object with fields fontFamily, fontFamilyFallback, color, fontSize, height, fontWeight |
| `editorialLessonHeading` | TextStyle object with fields fontFamily, fontFamilyFallback, color, fontSize, height, fontWeight |
| `editorialBody` | TextStyle object with fields fontFamily, fontFamilyFallback, color, fontSize, height, fontWeight |
| `editorialSupporting` | TextStyle object with fields fontFamily, fontFamilyFallback, color, fontSize, height, fontWeight |
| `editorialLabel` | TextStyle object with fields fontFamily, fontFamilyFallback, color, fontSize, height, fontWeight, letterSpacing |
| `micro` | milliseconds (nonnegative integer) |
| `standard` | milliseconds (nonnegative integer) |
| `emphasis` | milliseconds (nonnegative integer) |
| `milestone` | milliseconds (nonnegative integer) |
| `enter` | Curves name |
| `exit` | Curves name |
| `settle` | Curves name |
| `emphasisCurve` | Curves name |
| `warn` | fixed token reference accent |
| `feltCenter` | ARGB color (#AARRGGBB) (protected; echo unchanged) |
| `feltMid` | ARGB color (#AARRGGBB) (protected; echo unchanged) |
| `feltEdge` | ARGB color (#AARRGGBB) (protected; echo unchanged) |
| `navySurface` | ARGB color (#AARRGGBB) |
| `navyRaised` | ARGB color (#AARRGGBB) |
| `navyLine` | ARGB color (#AARRGGBB) |
| `navyAccent` | ARGB color (#AARRGGBB) |
| `navyOnSurface` | ARGB color (#AARRGGBB) |
| `navyMuted` | ARGB color (#AARRGGBB) |
| `navyOk` | ARGB color (#AARRGGBB) |
| `navyWarn` | ARGB color (#AARRGGBB) |
| `navyBad` | ARGB color (#AARRGGBB) |
| `controlElevation` | finite number |
| `academyBackground` | ARGB color (#AARRGGBB) |
| `academyRaised` | ARGB color (#AARRGGBB) |
| `academyTealDeep` | ARGB color (#AARRGGBB) |
| `academyTeal` | ARGB color (#AARRGGBB) |
| `academyAccent` | ARGB color (#AARRGGBB) |
| `academyAccentSoft` | ARGB color (#AARRGGBB) |
| `academyOnSurface` | ARGB color (#AARRGGBB) |
| `academyMuted` | ARGB color (#AARRGGBB) |
| `academyLine` | ARGB color (#AARRGGBB) |
| `academyWarn` | ARGB color (#AARRGGBB) |
| `courseProgressTrack` | ARGB color (#AARRGGBB) |
| `courseProgressFill` | fixed token reference academyAccent |
| `courseProgressHeight` | finite number |
| `courseProgressRadius` | finite number |
| `expandIcon` | Icons name |
| `collapseIcon` | Icons name |
| `correctIcon` | Icons name |
| `mistakeIcon` | Icons name |
| `sharkyMistakeAsset` | fixed token reference sharkyHintAsset |
| `sharkyFixedItAsset` | fixed token reference sharkyHintAsset |
| `sharkyLessonDoneAsset` | fixed token reference sharkyHintAsset |
| `reviewEmptyTitle` | TextStyle object with fields color, fontSize, height, fontWeight |
| `reviewEmptyBody` | TextStyle object with fields color, fontSize, height |
| `navyStatLabel` | TextStyle object with fields color, fontSize, height, fontWeight, letterSpacing |
| `navyStatValue` | TextStyle object with fields color, fontSize, height, fontWeight |
| `navyStatSupport` | TextStyle object with fields color, fontSize, height, fontWeight |
| `navyCompactStatRadius` | finite number |
| `navyStatRadius` | finite number |
| `navyStatShadow` | BoxShadow object with fields color, blurRadius, offset |

## Asset files

All five are required in the pack; no extra files or subdirectories in `assets/`.
The [B104 slot specification](../../assets/skin_v1/README.md) remains the owner
of the canvas and art requirements.

| File | Pixels | Art requirement |
| --- | --- | --- |
| `app_icon.png` | 1024 × 1024 | opaque PNG, no alpha |
| `sharky_neutral.png` | 360 × 360 | PNG, transparent background |
| `sharky_happy.png` | 360 × 360 | PNG, transparent background |
| `sharky_thinking.png` | 360 × 360 | PNG, transparent background |
| `sharky_concerned.png` | 360 × 360 | PNG, transparent background |

The checker verifies PNG signature, chunk structure/checksums, exact pixel
size and absence of alpha/transparency metadata on the icon; mascots must
support transparency. It is not an image decoder, visual approval or rights
check: review the actual transparent background, framing, recognition at
56/120 pt and provenance separately.
