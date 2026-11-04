import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Premium Academy presentation leaves (isolated, not wired into the shell).
///
/// Provenance: palette from Draft PR #308
/// `act0_home_north_star_preview_v1.dart` (Act0HomeNorthStarPaletteV1);
/// glyph geometry from Draft PRs #308/#311/#315
/// `assets/design/sharky/iconography/*.svg`, inlined here so the leaves need
/// no new `pubspec.yaml` asset declaration.
///
/// These leaves never read or write learner state. Every number, label and
/// action they show is supplied by the caller from accepted source-owned
/// models.
abstract final class Act0AcademyLeafPaletteV1 {
  static const ink = Color(0xFF020E13);
  static const inkRaised = Color(0xFF071C24);
  static const tealDeep = Color(0xFF0B3530);
  static const teal = Color(0xFF177D70);
  static const aqua = Color(0xFF23E6D2);
  static const aquaSoft = Color(0xFFB9F5E9);
  static const text = Color(0xFFF1FBF8);
  static const textMuted = Color(0xFFB6C8D5);
  static const rule = Color(0xFF23443F);
  static const repair = Color(0xFFF2C46B);
}

/// Owner-selected premium leaves are English-first (iPhone 14 Pro EN V1
/// policy). Donor #308 kept RU users on the existing localized surface; the
/// integration adapter must do the same by checking this gate first.
bool act0AcademyLeafSupportsLocaleV1(Locale locale) =>
    locale.languageCode == 'en';

/// Path of the restored owner-approved backdrop (Draft PR #308). It is NOT
/// declared in `pubspec.yaml` yet, so callers must pass `null` until the
/// integration owner adds `assets/design/sharky/home/` to the asset list.
const String act0AcademyLeafLoungeBackdropAssetV1 =
    'assets/design/sharky/home/poker_lounge_reference_v2.png';

enum Act0AcademyLeafGlyphKindV1 {
  home,
  learn,
  practice,
  review,
  you,
  recall,
  forward,
  overflow,
  lock,
  settings,
  sound,
  haptics,
  privacy,
  terms,
  placement,
}

const String _svgOpenV1 =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
    'viewBox="0 0 24 24" fill="none" stroke="#000000" stroke-width="1.85" '
    'stroke-linecap="round" stroke-linejoin="round">';
const String _svgCloseV1 = '</svg>';

const Map<Act0AcademyLeafGlyphKindV1, String> _glyphBodiesV1 = {
  Act0AcademyLeafGlyphKindV1.home:
      '<path d="M3.4 10.1 12 3l8.6 7.1"/><path d="M5.6 9.7V20h12.8V9.7"/>'
      '<path d="M9.5 20v-7h5v7"/>',
  Act0AcademyLeafGlyphKindV1.learn:
      '<path d="M12 6.8c-2.55-1.6-5.2-1.9-9-1v12.5c3.8-.9 6.45-.6 9 1"/>'
      '<path d="M12 6.8c2.55-1.6 5.2-1.9 9-1v12.5c-3.8-.9-6.45-.6-9 1"/>'
      '<path d="M12 6.8v12.5"/>',
  Act0AcademyLeafGlyphKindV1.practice:
      '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4.2"/>'
      '<circle cx="12" cy="12" r="0.9" fill="#000" stroke="none"/>',
  Act0AcademyLeafGlyphKindV1.review:
      '<path d="M20 7v-4.5M20 7h-4.5"/><path d="M20 7A8.5 8.5 0 0 0 5.4 5.3"/>'
      '<path d="M4 17v4.5M4 17h4.5"/>'
      '<path d="M4 17a8.5 8.5 0 0 0 14.6 1.7"/>',
  Act0AcademyLeafGlyphKindV1.you:
      '<circle cx="12" cy="8" r="3.6"/>'
      '<path d="M4.4 20c0-4.2 3.1-6.7 7.6-6.7s7.6 2.5 7.6 6.7"/>',
  Act0AcademyLeafGlyphKindV1.recall:
      '<path d="M4 4v5h5"/><path d="M4.25 9a8.5 8.5 0 1 1-.45 5.1"/>'
      '<path d="M12 7.4v5l3.1 1.8"/>',
  Act0AcademyLeafGlyphKindV1.forward:
      '<path d="M4 12h16"/><path d="m13 5 7 7-7 7"/>',
  Act0AcademyLeafGlyphKindV1.overflow:
      '<circle cx="5" cy="12" r="1.1"/><circle cx="12" cy="12" r="1.1"/>'
      '<circle cx="19" cy="12" r="1.1"/>',
  Act0AcademyLeafGlyphKindV1.lock:
      '<rect x="5" y="10" width="14" height="11" rx="2"/>'
      '<path d="M8 10V7a4 4 0 0 1 8 0v3"/>',
  Act0AcademyLeafGlyphKindV1.settings:
      '<polygon points="19.69,9.79 21.85,10.26 21.85,13.74 19.69,14.21 '
      '19.00,15.88 20.19,17.74 17.74,20.19 15.88,19.00 14.21,19.69 '
      '13.74,21.85 10.26,21.85 9.79,19.69 8.12,19.00 6.26,20.19 3.81,17.74 '
      '5.00,15.88 4.31,14.21 2.15,13.74 2.15,10.26 4.31,9.79 5.00,8.12 '
      '3.81,6.26 6.26,3.81 8.12,5.00 9.79,4.31 10.26,2.15 13.74,2.15 '
      '14.21,4.31 15.88,5.00 17.74,3.81 20.19,6.26 19.00,8.12"/>'
      '<circle cx="12" cy="12" r="3.2"/>',
  Act0AcademyLeafGlyphKindV1.sound:
      '<path d="M4 9h4l5-4v14l-5-4H4Z M17 8c2 2 2 6 0 8 M20 5c4 4 4 10 0 14"/>',
  Act0AcademyLeafGlyphKindV1.haptics:
      '<rect x="8" y="3" width="8" height="18" rx="2"/>'
      '<path d="m4 8-2 4 2 4 M20 8l2 4-2 4 M11 17h2"/>',
  Act0AcademyLeafGlyphKindV1.privacy:
      '<path d="m12 3 8 3v6c0 4-4 7-8 9-4-2-8-5-8-9V6Z m-4 9 3 3 5-6"/>',
  Act0AcademyLeafGlyphKindV1.terms:
      '<path d="M5 3h9l5 5v13H5Z M14 3v6h5 M9 13h6 M9 17h6"/>',
  Act0AcademyLeafGlyphKindV1.placement:
      '<path d="m12 3 2.8 5.7 6.2.9-4.5 4.4 1.1 6.2-5.6-3-5.6 3 1.1-6.2'
      'L3 9.6l6.2-.9Z"/>',
};

/// Raw SVG markup for a glyph (exposed for tests and adapters).
String act0AcademyLeafGlyphSvgV1(Act0AcademyLeafGlyphKindV1 kind) =>
    '$_svgOpenV1${_glyphBodiesV1[kind]!}$_svgCloseV1';

/// Decorative monotone glyph; the parent control carries the voice label.
class Act0AcademyLeafGlyphV1 extends StatelessWidget {
  const Act0AcademyLeafGlyphV1({
    super.key,
    required this.kind,
    required this.color,
    this.size = 22,
  });

  final Act0AcademyLeafGlyphKindV1 kind;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    act0AcademyLeafGlyphSvgV1(kind),
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}

/// Shared dark Academy surface (donor #311 `_surface`).
class Act0AcademyLeafSurfaceV1 extends StatelessWidget {
  const Act0AcademyLeafSurfaceV1({
    super.key,
    required this.child,
    this.emphasized = false,
  });

  final Widget child;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Act0AcademyLeafPaletteV1.inkRaised,
      borderRadius: BorderRadius.circular(emphasized ? 22 : 18),
      border: Border.all(
        color: emphasized
            ? const Color(0xFF19796F)
            : Act0AcademyLeafPaletteV1.rule,
      ),
      boxShadow: emphasized
          ? const [
              BoxShadow(
                color: Color(0x38000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ]
          : null,
    ),
    child: child,
  );
}

/// Optional decorative backdrop. `null` renders an honest gradient only; the
/// leaf never ships an undeclared asset reference that would fail at runtime.
class Act0AcademyLeafBackdropV1 extends StatelessWidget {
  const Act0AcademyLeafBackdropV1({
    super.key,
    required this.image,
    this.alignment = Alignment.topRight,
  });

  final ImageProvider? image;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final provider = image;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: provider == null
            ? const DecoratedBox(
                key: Key('act0_academy_leaf_backdrop_fallback'),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.7, -0.6),
                    radius: 1.1,
                    colors: [
                      Act0AcademyLeafPaletteV1.tealDeep,
                      Act0AcademyLeafPaletteV1.ink,
                    ],
                  ),
                ),
              )
            : Image(
                key: const Key('act0_academy_leaf_backdrop_image'),
                image: provider,
                fit: BoxFit.cover,
                alignment: alignment,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Act0AcademyLeafPaletteV1.ink),
              ),
      ),
    );
  }
}
