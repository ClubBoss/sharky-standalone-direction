import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';

/// Real-time simulation control panel displaying round data and controls.
///
/// Shows street, pot, hero stack, current actor with Pause/Resume/Restart controls.
class SimulationModePanel extends StatelessWidget {
  const SimulationModePanel({
    super.key,
    required this.engine,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onRestart,
  });

  final SimulationEngine engine;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    final onSurface = theme.colorScheme.onSurface;

    final heroPlayer = engine.players.firstWhere(
      (p) => p.seatIndex == engine.heroSeat,
      orElse: () => engine.players.first,
    );
    final currentPlayer = engine.isRoundActive && engine.currentSeat >= 0
        ? engine.players[engine.currentSeat]
        : null;

    return Container(
      padding: EdgeInsets.all(brand?.spacingSmall ?? 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        border: Border.all(
          color: AppColors.primaryBrand.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎮 Simulation Mode',
                style: AppTypography.label.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                engine.isRoundActive ? 'LIVE' : 'WAITING',
                style: AppTypography.caption.copyWith(
                  color: engine.isRoundActive
                      ? AppColors.success
                      : onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Street',
                value: _getStreetName(engine.currentStreet),
                icon: Icons.timeline,
              ),
              _StatItem(
                label: 'Pot',
                value: '\$${engine.pot}',
                icon: Icons.account_balance_wallet,
              ),
              _StatItem(
                label: 'Hero Stack',
                value: '\$${heroPlayer.stack}',
                icon: Icons.person,
              ),
            ],
          ),

          if (currentPlayer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBrand.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: 16,
                    color: AppColors.primaryBrand,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Current: ${currentPlayer.name}',
                    style: AppTypography.caption.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                label: isPaused ? 'RESUME' : 'PAUSE',
                icon: isPaused ? Icons.play_arrow : Icons.pause,
                onPressed: isPaused ? onResume : onPause,
                color: isPaused ? AppColors.success : AppColors.warning,
              ),
              _ControlButton(
                label: 'RESTART',
                icon: Icons.refresh,
                onPressed: onRestart,
                color: AppColors.primaryBrand,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStreetName(SimulationStreet street) {
    switch (street) {
      case SimulationStreet.preFlop:
        return 'PRE-FLOP';
      case SimulationStreet.flop:
        return 'FLOP';
      case SimulationStreet.turn:
        return 'TURN';
      case SimulationStreet.river:
        return 'RIVER';
      case SimulationStreet.showdown:
        return 'SHOWDOWN';
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBrand),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body.copyWith(
            color: onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
