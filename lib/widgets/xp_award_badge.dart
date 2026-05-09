import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Formats an XP value into a localized label string.
///
/// Always uses AppLocalizations.xpAwardLabel to produce the string.
/// This function requires a valid [BuildContext] with localizations.
String formatXpLabel(BuildContext context, int xp) {
  // TODO: Add xpAwardLabel to app localizations
  return '+$xp XP';
}

/// A lightweight, reusable XP award badge overlay.
///
/// Usage: place inside a Stack; it renders in the top-right corner.
/// Controls visibility via [visible] and fades with AnimatedOpacity.
///
/// Supports flexible XP amounts via [overrideXp]; defaults to 5 if not provided.
/// Use [formatXpLabel] to generate consistent label text.
class XpAwardBadge extends StatelessWidget {
  final bool visible;
  final int? overrideXp;

  const XpAwardBadge({super.key, required this.visible, this.overrideXp});

  @override
  Widget build(BuildContext context) {
    final xp = overrideXp ?? 5;
    final label = formatXpLabel(context, xp);

    return Positioned(
      top: 12,
      right: 12,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: visible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF263238),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
