import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

/// UI V2 Season Reward Hub
///
/// Displays season rewards, tiers, and progression.
/// Mock data for demonstration with ASCII visualization.
/// Uses BrandTheme colors and AppTypography.
class UiV2SeasonRewardHub extends StatelessWidget {
  const UiV2SeasonRewardHub({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingMedium ?? 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Season Rewards')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Season Header
            _SeasonHeader(seasonNumber: 1, daysRemaining: 14),
            SizedBox(height: spacing),
            // Reward Tiers
            ..._buildRewardTiers(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRewardTiers(BuildContext context) {
    final tiers = [
      _RewardTier(
        tier: 'Bronze',
        reward: '100 Chips',
        icon: '🥉',
        unlocked: true,
      ),
      _RewardTier(
        tier: 'Silver',
        reward: '250 Chips',
        icon: '🥈',
        unlocked: true,
      ),
      _RewardTier(
        tier: 'Gold',
        reward: '500 Chips',
        icon: '🥇',
        unlocked: false,
      ),
      _RewardTier(
        tier: 'Platinum',
        reward: '1000 Chips + Premium 7d',
        icon: '💎',
        unlocked: false,
      ),
      _RewardTier(
        tier: 'Diamond',
        reward: '2500 Chips + Premium 30d',
        icon: '💠',
        unlocked: false,
      ),
    ];

    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingSmall ?? 8.0;

    return [
      for (final tier in tiers) ...[tier, SizedBox(height: spacing)],
    ];
  }
}

class _SeasonHeader extends StatelessWidget {
  final int seasonNumber;
  final int daysRemaining;

  const _SeasonHeader({
    required this.seasonNumber,
    required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final radius = brand?.radius ?? 12.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brand?.primaryBrand ?? Colors.teal,
            (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        children: [
          Text('🏆', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            'Season $seasonNumber',
            style: AppTypography.h1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '$daysRemaining days remaining',
            style: AppTypography.body.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _RewardTier extends StatelessWidget {
  final String tier;
  final String reward;
  final String icon;
  final bool unlocked;

  const _RewardTier({
    required this.tier,
    required this.reward,
    required this.icon,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final radius = brand?.radius ?? 12.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked
            ? (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: unlocked ? (brand?.primaryBrand ?? Colors.teal) : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: unlocked
                  ? (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                unlocked ? icon : '🔒',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier,
                  style: AppTypography.h3.copyWith(
                    color: unlocked ? null : Colors.grey,
                  ),
                ),
                Text(
                  reward,
                  style: AppTypography.body.copyWith(
                    color: unlocked
                        ? (brand?.primaryBrand ?? Colors.teal)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Status
          if (unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(radius / 2),
              ),
              child: Text(
                'Unlocked',
                style: AppTypography.caption.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
