import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_seat_state_badge_v1.dart';

class World1CanonicalSeatBodyContractV1 {
  const World1CanonicalSeatBodyContractV1({
    required this.displaySeatId,
    required this.logicalSeatId,
    required this.labelText,
    required this.canonicalOrderBadgeText,
    required this.seatSize,
    required this.seatColor,
    required this.textColor,
    required this.borderColor,
    required this.borderWidth,
    required this.opacity,
    required this.glowShadows,
    required this.canRotateSeatDisplay,
    required this.rotatingHeroSeatId,
    required this.showHeroBadge,
    required this.showActBadge,
    required this.showFoldBadge,
    required this.showOutBadge,
    required this.tablePracticeSession,
  });

  final String displaySeatId;
  final String logicalSeatId;
  final String labelText;
  final String? canonicalOrderBadgeText;
  final double seatSize;
  final Color seatColor;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final double opacity;
  final List<BoxShadow>? glowShadows;
  final bool canRotateSeatDisplay;
  final String? rotatingHeroSeatId;
  final bool showHeroBadge;
  final bool showActBadge;
  final bool showFoldBadge;
  final bool showOutBadge;
  final bool tablePracticeSession;
}

Widget buildWorld1CanonicalSeatBodyV1(
  World1CanonicalSeatBodyContractV1 contract,
) {
  final seatDisplay =
      (contract.displaySeatId == 'sb' || contract.displaySeatId == 'bb')
      ? RunnerSeatStateBadgeShellV1(
          tone: RunnerSeatStateBadgeToneV1.neutral,
          visualPriorityV1: RunnerSeatStateBadgePriorityV1.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Text(
            contract.labelText,
            key: contract.displaySeatId == 'btn'
                ? const Key('microtask_hero_position_badge_v1')
                : null,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textPrimary.withOpacity(0.94),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08,
            ),
          ),
        )
      : Text(
          contract.labelText,
          key: contract.displaySeatId == 'btn'
              ? const Key('microtask_hero_position_badge_v1')
              : null,
          style: AppTypography.caption.copyWith(
            color: contract.textColor,
            fontWeight: FontWeight.w700,
          ),
        );

  return Opacity(
    opacity: contract.opacity,
    child: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        KeyedSubtree(
          key: Key('microtask_seat_ring_rect_${contract.displaySeatId}_v1'),
          child: Container(
            key: contract.tablePracticeSession
                ? Key('table_practice_seat_${contract.displaySeatId}')
                : Key('microtask_seat_${contract.displaySeatId}'),
            width: contract.seatSize,
            height: contract.seatSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: contract.seatColor,
              shape: BoxShape.circle,
              boxShadow: contract.glowShadows,
              border: Border.all(
                color: contract.borderColor,
                width: contract.borderWidth,
              ),
            ),
            child: KeyedSubtree(
              key: Key('microtask_seat_display_${contract.displaySeatId}_v1'),
              child: KeyedSubtree(
                key:
                    contract.canRotateSeatDisplay &&
                        contract.displaySeatId == 'btn' &&
                        contract.logicalSeatId == contract.rotatingHeroSeatId
                    ? const Key('microtask_hero_display_btn_v1')
                    : null,
                child: seatDisplay,
              ),
            ),
          ),
        ),
        if (contract.showHeroBadge)
          Positioned(
            left: -4,
            top: -3,
            child: RunnerSeatStateBadgeV1(
              key: const Key('microtask_seat_state_badge_hero_v1'),
              label: 'HERO',
              tone: RunnerSeatStateBadgeToneV1.hero,
              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
              textStyle: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 7.6,
                letterSpacing: 0.12,
                height: 1.0,
              ),
            ),
          ),
        if (contract.canonicalOrderBadgeText != null)
          Positioned(
            left: -5,
            bottom: -5,
            child: RunnerSeatStateBadgeV1(
              key: Key(
                'microtask_seat_order_badge_${contract.displaySeatId}_v1',
              ),
              label: contract.canonicalOrderBadgeText!,
              tone: RunnerSeatStateBadgeToneV1.neutral,
              visualPriorityV1: RunnerSeatStateBadgePriorityV1.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
              textStyle: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 7.4,
                letterSpacing: 0.04,
                height: 1.0,
              ),
            ),
          ),
        if (contract.showActBadge)
          Positioned(
            right: -4,
            top: -3,
            child: RunnerSeatStateBadgeV1(
              key: const Key('microtask_seat_state_badge_act_v1'),
              label: 'ACT',
              tone: RunnerSeatStateBadgeToneV1.action,
              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
              textStyle: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 7.8,
                letterSpacing: 0.16,
                height: 1.0,
              ),
            ),
          ),
        if (contract.showFoldBadge)
          Positioned(
            right: -4,
            top: contract.rotatingHeroSeatId == contract.logicalSeatId
                ? 16
                : -3,
            child: RunnerSeatStateBadgeV1(
              key: Key(
                'microtask_seat_state_badge_folded_${contract.displaySeatId}',
              ),
              label: 'FOLD',
              tone: RunnerSeatStateBadgeToneV1.folded,
              visualPriorityV1: RunnerSeatStateBadgePriorityV1.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
              textStyle: AppTypography.caption.copyWith(
                color: const Color(0xFFD7DCE4).withOpacity(0.94),
                fontWeight: FontWeight.w700,
                fontSize: 7.2,
                letterSpacing: 0.14,
                height: 1.0,
              ),
            ),
          ),
        if (contract.showOutBadge)
          Positioned(
            right: -4,
            top: contract.rotatingHeroSeatId == contract.logicalSeatId
                ? 16
                : -3,
            child: RunnerSeatStateBadgeV1(
              key: Key(
                'microtask_seat_state_badge_out_${contract.displaySeatId}',
              ),
              label: 'OUT',
              tone: RunnerSeatStateBadgeToneV1.neutral,
              visualPriorityV1: RunnerSeatStateBadgePriorityV1.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
              textStyle: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary.withOpacity(0.92),
                fontWeight: FontWeight.w700,
                fontSize: 7.2,
                letterSpacing: 0.14,
                height: 1.0,
              ),
            ),
          ),
      ],
    ),
  );
}
