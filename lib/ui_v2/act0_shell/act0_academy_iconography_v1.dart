import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Sharky original 24x24 outline SVG family. Every stroke uses 1.85 width,
/// round caps/joins; UI color is assigned outside each monotone symbol.
/// Mascot and background art remain separate illustrative categories.
abstract final class Act0AcademyIconographyV1 {
  static const home = 'assets/design/sharky/iconography/home.svg';
  static const learn = 'assets/design/sharky/iconography/book.svg';
  static const practice = 'assets/design/sharky/iconography/focus.svg';
  static const review = 'assets/design/sharky/iconography/review.svg';
  static const you = 'assets/design/sharky/iconography/user.svg';
  static const recall = 'assets/design/sharky/iconography/recall.svg';
  static const apply = practice;
  static const forward = 'assets/design/sharky/iconography/forward.svg';
  static const lock = 'assets/design/sharky/iconography/lock.svg';
  static const overflow = 'assets/design/sharky/iconography/more.svg';
}

/// Decorative glyph, excluding semantics; parent control carries voice label.
class Act0AcademyGlyphV1 extends StatelessWidget {
  const Act0AcademyGlyphV1({
    super.key,
    required this.asset,
    required this.color,
    this.size = 22,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}
