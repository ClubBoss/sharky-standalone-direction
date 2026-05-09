import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// A presentational card showing XP milestone status for the recap views.
///
/// Inputs (data-only, no side effects):
/// - [totalXp]: current total XP
/// - [unclaimedMilestone]: the lowest unlocked-but-unclaimed milestone, if any
/// - [upcomingMilestone]: the next milestone strictly greater than [totalXp]
///
/// The widget mirrors the visual language used in the XP Share card for
/// milestone styling (icons, colors, paddings) but contains no business logic.
class XpRecappedMilestonePreviewCard extends StatelessWidget {
  final int totalXp;
  final int? unclaimedMilestone;
  final int? upcomingMilestone;

  const XpRecappedMilestonePreviewCard({
    super.key,
    required this.totalXp,
    required this.unclaimedMilestone,
    required this.upcomingMilestone,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Determine visual state
    final bool hasUnclaimed = unclaimedMilestone != null;
    final int? next = upcomingMilestone ?? unclaimedMilestone;
    final int? remaining = (next != null)
        ? (next - totalXp).clamp(0, next)
        : null;

    final Color iconColor = hasUnclaimed
        ? Colors.green[700]!
        : Colors.blue[700]!;
    final IconData icon = hasUnclaimed ? Icons.verified : Icons.flag;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.xpRecapMilestonesTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasUnclaimed)
              Text(
                l10n.xpRecapMilestoneAvailable(unclaimedMilestone!),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (next != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.xpRecapNextMilestoneLabel(next),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (remaining != null)
                    Text(
                      l10n.xpRecapRemainingXp(remaining),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              )
            else
              Text(
                l10n.xpRecapAllMilestonesAchieved,
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}
