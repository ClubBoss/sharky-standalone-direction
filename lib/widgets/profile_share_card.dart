import 'package:flutter/material.dart';
import '../models/training_profile.dart';
import '../models/xp_trophy.dart';
import '../models/league_tier_badge.dart';
import '../services/xp_service.dart';
import '../services/training_profile_service.dart';
import '../services/xp_trophy_service.dart';

/// A visual card displaying user's profile stats for sharing.
/// Designed to be captured as a screenshot via RepaintBoundary.
class ProfileShareCard extends StatelessWidget {
  final String displayName;
  final int totalXp;
  final LeagueTierBadge? leagueBadge;
  final TrainingProfile profile;
  final List<XpTrophyEntry> trophies;

  const ProfileShareCard({
    super.key,
    required this.displayName,
    required this.totalXp,
    this.leagueBadge,
    required this.profile,
    required this.trophies,
  });

  /// Fetches all necessary data and builds the card.
  static Future<ProfileShareCard> create(BuildContext context) async {
    final xpService = XpService();
    await xpService.initialize();
    final totalXp = xpService.getTotalXp();

    final profileType = await TrainingProfileService.instance.currentProfile();
    final profile = TrainingProfile.fromType(profileType);

    // Get league badge (simplified - using XP for tier)
    final leagueBadge = LeagueTierBadge.resolve(xp: totalXp);

    // Get current trophies
    await XpTrophyService.instance.init();
    final trophies = XpTrophyService.instance.unlocked.toList();

    // Get display name (placeholder if not available)
    final displayName = 'Poker Player'; // TODO: Get from auth service

    return ProfileShareCard(
      displayName: displayName,
      totalXp: totalXp,
      leagueBadge: leagueBadge,
      profile: profile,
      trophies: trophies,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header: Avatar + Name
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: profile.color.withValues(alpha: 0.2),
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: profile.color,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (leagueBadge != null)
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: 16,
                            color: leagueBadge!.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isRu ? leagueBadge!.labelRu : leagueBadge!.labelEn,
                            style: TextStyle(
                              fontSize: 14,
                              color: leagueBadge!.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // XP Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  isRu ? 'Всего XP' : 'Total XP',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  totalXp.toString(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Training Profile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: profile.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: profile.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: profile.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(profile.icon, size: 28, color: profile.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRu ? profile.titleRu : profile.titleEn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: profile.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRu ? profile.descriptionRu : profile.descriptionEn,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Trophies
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRu ? 'Трофеи' : 'Trophies',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (trophies.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        isRu
                            ? 'Заработайте свой первый трофей!'
                            : 'Earn your first trophy!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: trophies.take(6).map((entry) {
                      final trophy = entry.type;
                      return Tooltip(
                        message: isRu ? trophy.titleRu : trophy.titleEn,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(
                            trophy.icon(),
                            size: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Footer
          Text(
            'Poker Analyzer',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
