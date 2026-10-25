import 'package:flutter/material.dart';

/// Source-owned semantic glyph roles for the English Sharky Academy North Star.
///
/// The entire UI family uses ONE Material outlined silhouette family and a
/// single optical scale. Color, stroke-neutral backdrop and glow express the
/// active state; NEVER substitute a checkmark merely for opening a screen.
///
/// These glyphs are isolated from the protected table and existing light shell.
/// Brand mascot/artwork is not a UI icon and may retain a separate art style.
abstract final class Act0AcademyIconographyV1 {
  // Navigation / top-level actions. Use 21-22 logical px.
  static const IconData home = Icons.home_outlined;
  static const IconData learn = Icons.menu_book_outlined;
  static const IconData practice = Icons.track_changes_outlined;
  static const IconData review = Icons.refresh_outlined;
  static const IconData you = Icons.person_outline_rounded;

  // Journey: same metaphor as corresponding destinations, 22px circles.
  static const IconData recall = Icons.history_outlined;
  static const IconData apply = practice;

  // Single navigational direction. Avoid mixing target/chevron/arrow as CTA.
  static const IconData forward = Icons.arrow_forward_outlined;
  static const IconData overflow = Icons.more_horiz_rounded;
}
