import 'package:flutter/material.dart';
import 'xp_award_badge.dart';

/// A compact banner displaying total XP gained during a training session.
///
/// Shows a small card with "XP Gained: +X" text and a star icon.
/// Reuses [formatXpLabel] for consistent label formatting.
///
/// Usage:
/// ```dart
/// XpSessionRecapBanner(xp: 5)  // For drills, packs, daily challenge
/// XpSessionRecapBanner(xp: 10) // For module completion
/// ```
class XpSessionRecapBanner extends StatelessWidget {
  final int xp;

  const XpSessionRecapBanner({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    if (xp <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            'XP Gained: ${formatXpLabel(context, xp)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
