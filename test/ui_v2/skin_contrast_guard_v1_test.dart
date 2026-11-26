import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart';

typedef _T = Act0SkinTokensV1;
typedef _Pair = ({
  String id,
  Color foreground,
  Color background,
  double minimum,
});

const _normal = 4.5;
const _largeOrIcon = 3.0;

const _darkSurfaces = {
  'background': _T.background,
  'surface': _T.surface,
  'raised': _T.raised,
};

// Same checks apply to each pack. A new pack must register its own pair
// inventory here using live tokens, and must not inherit another pack's debt.
Iterable<_Pair> _currentPairs() sync* {
  // Body, secondary, captions, links and compact feedback labels may occur
  // on any of the kit's dark card/page/control surfaces.
  const textRoles = {
    'onSurface': _T.onSurface,
    'muted': _T.muted,
    'caption': _T.caption,
    'accent': _T.accent,
    'ok': _T.ok,
    'bad': _T.bad,
  };
  for (final surface in _darkSurfaces.entries) {
    for (final text in textRoles.entries) {
      yield (
        id: '${text.key}/${surface.key}',
        foreground: text.value,
        background: surface.value,
        minimum: _normal,
      );
    }
  }

  yield _pair('onAccent/accent', _T.onAccent, _T.accent);
  // Primary disabled label is retained as a stronger-than-WCAG kit contract:
  // inactive controls are otherwise exempt from the AA text requirement.
  // caption/raised is already covered above.

  // Chip and answer/secondary-button fills have alpha; evaluate the painted
  // fill over each opaque page/card surface, not the tint's unblended RGB.
  for (final base in _darkSurfaces.entries) {
    for (final (role, fg, fillRole, fill) in [
      ('accent', _T.accent, 'accentSoft', _T.accentSoft),
      ('ok', _T.ok, 'okSoft', _T.okSoft),
      ('bad', _T.bad, 'badSoft', _T.badSoft),
      ('onSurface', _T.onSurface, 'okSoft', _T.okSoft),
      ('onSurface', _T.onSurface, 'badSoft', _T.badSoft),
    ]) {
      yield _pair(
        '$role/$fillRole@${base.key}',
        fg,
        Color.alphaBlend(fill, base.value),
      );
    }
  }

  // Editorial reader and result cards.
  for (final surface in const {
    'editorialPageSurface': _T.editorialPageSurface,
    'editorialCardSurface': _T.editorialCardSurface,
  }.entries) {
    for (final text in const {
      'editorialInk': _T.editorialInk,
      'editorialInkMuted': _T.editorialInkMuted,
      'editorialFocus': _T.editorialFocus,
      'editorialNeedsReviewFg': _T.editorialNeedsReviewFg,
    }.entries) {
      yield _pair('${text.key}/${surface.key}', text.value, surface.value);
    }
  }
  yield _pair(
    'editorialOnPrimaryAction/editorialPrimaryAction',
    _T.editorialOnPrimaryAction,
    _T.editorialPrimaryAction,
  );
  yield _pair(
    'editorialNeedsReviewFg/editorialNeedsReviewBg',
    _T.editorialNeedsReviewFg,
    _T.editorialNeedsReviewBg,
  );
  yield _pair(
    'editorialCorrectFg/editorialCorrectBg',
    _T.editorialCorrectFg,
    _T.editorialCorrectBg,
  );

  // Empty-state heading (large) and support copy, including the Club Night
  // card used by You and Archive, and the Academy surface roles.
  for (final surface in {
    ..._darkSurfaces,
    'academyBackground': _T.academyBackground,
    'academyRaised': _T.academyRaised,
  }.entries) {
    yield _pair(
      'academyOnSurface/${surface.key}',
      _T.academyOnSurface,
      surface.value,
      minimum: _largeOrIcon,
    );
    yield _pair('academyMuted/${surface.key}', _T.academyMuted, surface.value);
  }

  // Normal and compact profile metrics (compact tiles inherit card fill).
  for (final surface in const {
    'navyRaised': _T.navyRaised,
    'navySurface': _T.navySurface,
    'surface': _T.surface,
  }.entries) {
    yield _pair(
      'navyOnSurface/${surface.key}',
      _T.navyOnSurface,
      surface.value,
    );
    yield _pair('navyMuted/${surface.key}', _T.navyMuted, surface.value);
  }

  // Meaningful non-text control glyphs/indicators.
  yield _pair(
    'academyAccent/background',
    _T.academyAccent,
    _T.background,
    minimum: _largeOrIcon,
  );
  yield _pair(
    'academyOnSurface/academyTeal',
    _T.academyOnSurface,
    _T.academyTeal,
    minimum: _largeOrIcon,
  );
  yield _pair('muted/track', _T.muted, _T.track, minimum: _largeOrIcon);
  yield _pair(
    'courseProgressFill/courseProgressTrack',
    _T.courseProgressFill,
    _T.courseProgressTrack,
    minimum: _largeOrIcon,
  );
}

_Pair _pair(
  String id,
  Color foreground,
  Color background, {
  double minimum = _normal,
}) =>
    (id: id, foreground: foreground, background: background, minimum: minimum);

// WCAG sRGB relative luminance, including fractional channels after blending.
double _luminance(Color color) {
  double linear(double channel) => channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * linear(color.r) +
      0.7152 * linear(color.g) +
      0.0722 * linear(color.b);
}

// Composite translucent foregrounds before measuring; the backing must be
// opaque (never silently treat an alpha tint as an opaque surface).
double _contrast(Color foreground, Color background) {
  if (background.a != 1) {
    throw ArgumentError('Contrast requires an opaque backing surface');
  }
  final a = _luminance(Color.alphaBlend(foreground, background));
  final b = _luminance(background);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

// Existing failures only. Keys are pack/pair IDs; each exception must have
// its measured unrounded minimum ratio and a specific reason. Never add new
// debt or lower an existing floor. Remove entries as soon as the pair passes.
const _allowlist = <String, ({double floor, String reason})>{};

void main() {
  test('contrast calculation matches WCAG reference cases', () {
    expect(_contrast(Colors.white, Colors.black), closeTo(21, 1e-10));
    expect(_contrast(Colors.black, Colors.white), closeTo(21, 1e-10));
    expect(_contrast(Colors.black, Colors.black), 1);
    expect(
      _contrast(const Color(0xFF777777), Colors.white),
      closeTo(4.478089, 1e-6),
    );
    expect(_contrast(Colors.transparent, Colors.white), 1);
  });

  final packs = {'B32': _currentPairs().toList()};
  test(
    'skin contrast AA: no new failures, no worsening or stale exceptions',
    () {
      final seen = <String>{};
      final failures = <String>[];
      for (final pack in packs.entries) {
        for (final pair in pack.value) {
          final id = '${pack.key}/${pair.id}';
          expect(seen.add(id), isTrue, reason: 'Duplicate contrast pair: $id');
          final ratio = _contrast(pair.foreground, pair.background);
          final exception = _allowlist[id];
          final diagnostic =
              '$id: ${ratio.toStringAsFixed(4)}:1 (AA ${pair.minimum}:1)';
          if (ratio >= pair.minimum) {
            if (exception != null) {
              failures.add('$diagnostic; remove repaired allowlist entry');
            }
          } else if (exception == null) {
            failures.add('$diagnostic; new contrast failure');
          } else if (ratio < exception.floor ||
              exception.reason.trim().isEmpty) {
            failures.add('$diagnostic; worsened or undocumented baseline debt');
          }
        }
      }
      for (final id in _allowlist.keys.where((id) => !seen.contains(id))) {
        failures.add('$id: remove orphaned allowlist entry');
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    },
  );
}
