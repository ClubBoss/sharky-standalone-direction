import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../../engine/action_bar_engine.dart';
import '../../engine/motion_frame_composer.dart';
import '../../engine/table_layout_resolver.dart';
import '../../engine/table_seat_slots.dart';
import 'action_bar_model.dart';
import 'action_surface.dart';
import 'board_surface.dart';
import 'card_motion_surface.dart';
import 'chip_stack_widget.dart';
import 'widgets/hole_cards_widget_v1.dart';
import 'pot_chip_stack_widget.dart';
import 'pot_stack_widget.dart';
import 'player_seat_widget.dart';
import 'seat_container.dart';
import 'table_outline.dart';
import 'table_surface.dart';
import 'table_surface_v4.dart';
import '../design/design_typography.dart';

class SeatVisualState {
  const SeatVisualState({
    required this.seatIndex,
    required this.isActive,
    required this.isFolded,
    required this.isActed,
    required this.isAllIn,
  });

  final int seatIndex;
  final bool isActive;
  final bool isFolded;
  final bool isActed;
  final bool isAllIn;
}

class HoleCardFaces {
  const HoleCardFaces({
    required this.seatIndex,
    required this.rank1,
    required this.suit1,
    required this.rank2,
    required this.suit2,
  });

  final int seatIndex;
  final String rank1;
  final String suit1;
  final String rank2;
  final String suit2;
}

class TableCompositeSurface extends StatelessWidget {
  const TableCompositeSurface({
    super.key,
    required this.layout,
    this.motion,
    required this.actionModel,
    required this.seatStates,
    this.boardCards = const <BoardCardData>[],
    this.holeCards = const <HoleCardFaces>[],
    this.potAmount = 0,
    this.onAction,
    this.onSelectRaise,
    this.showRaiseConfirm = false,
    this.raiseAmount = 0,
    this.onConfirmRaise,
    this.onCancelRaise,
    this.isV4Active = false,
  });

  final TableLayoutResolved layout;
  final MotionFrameSnapshot? motion;
  final ActionBarModel actionModel;
  final List<SeatVisualState> seatStates;
  final void Function(ActionBarIntent)? onAction;
  final ValueChanged<double>? onSelectRaise;
  final bool showRaiseConfirm;
  final double raiseAmount;
  final VoidCallback? onConfirmRaise;
  final VoidCallback? onCancelRaise;
  final bool isV4Active;

  SeatVisualState _stateForSeat(int index) {
    return seatStates.firstWhere(
      (state) => state.seatIndex == index,
      orElse: () => SeatVisualState(
        seatIndex: index,
        isActive: false,
        isFolded: false,
        isActed: false,
        isAllIn: false,
      ),
    );
  }

  double _holeCardProgress() {
    if (motion != null) {
      final value = motion!.timelineValue;
      if (value >= 0.0 && value <= 1.0) {
        return value;
      }
    }
    final fallback = ((motion?.timeMs ?? 0) / 300).clamp(0.0, 1.0);
    return fallback;
  }

  HoleCardFaces? _holeCardsForSeat(int index) {
    for (final card in holeCards) {
      if (card.seatIndex == index) {
        return card;
      }
    }
    return null;
  }

  final List<BoardCardData> boardCards;
  final List<HoleCardFaces> holeCards;
  final double potAmount;

  @override
  Widget build(BuildContext context) {
    final slots = buildTableSeatSlots(layout);
    final _ = _holeCardProgress();
    final surface = TableSurface(
      child: Stack(
        children: [
          TableOutline(center: layout.boardPosition),
          for (final seatPosition in layout.seatPositions)
            SeatContainer(position: seatPosition),
          for (final slot in slots) ...[
            (() {
              final state = _stateForSeat(slot.index);
              final holeCards = _holeCardsForSeat(slot.index);
              if (!state.isFolded && holeCards != null) {
                return Positioned(
                  left: slot.position.dx - 32,
                  top: slot.position.dy - 96,
                  child: HoleCardsWidgetV1(
                    seatState: state,
                    card1: '${holeCards.rank1}${holeCards.suit1}',
                    card2: '${holeCards.rank2}${holeCards.suit2}',
                    isFaceUp: !state.isFolded,
                    visualStyleBundle: const {},
                  ),
                );
              }
              return const SizedBox.shrink();
            })(),
            PlayerSeatWidget(
              position: slot.position,
              isActive: _stateForSeat(slot.index).isActive,
              isFolded: _stateForSeat(slot.index).isFolded,
              isActed: _stateForSeat(slot.index).isActed,
              isAllIn: _stateForSeat(slot.index).isAllIn,
            ),
          ],
          for (final slot in slots) ChipStackWidget(position: slot.position),
          BoardSurface(
            position: layout.boardPosition,
            dealerPosition: layout.dealerPosition,
            cards: boardCards,
          ),
          PotChipStackWidget(position: layout.boardPosition),
          Align(
            alignment: const Alignment(0, -0.05),
            child: PotStackWidget(amount: potAmount),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: VisualThemeV3.spacingL * 3,
              ),
              child: FittedBox(
                alignment: Alignment.bottomCenter,
                fit: BoxFit.scaleDown,
                child: _buildActionPanel(context),
              ),
            ),
          ),
          CardMotionSurface(snapshot: motion),
        ],
      ),
    );
    if (isV4Active) {
      return TableSurfaceV4(child: surface);
    }
    return surface;
  }

  Widget _buildActionPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
        boxShadow: const [VisualThemeV3.shadowMedium],
      ),
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius / 2),
              boxShadow: const [VisualThemeV3.shadowMedium],
            ),
            padding: const EdgeInsets.all(VisualThemeV3.spacingS),
            child: ActionSurface(
              model: actionModel,
              onAction: onAction,
              onSelectRaise: onSelectRaise,
              confirmPanelVisible: showRaiseConfirm,
            ),
          ),
          if (showRaiseConfirm &&
              onConfirmRaise != null &&
              onCancelRaise != null) ...[
            const SizedBox(height: VisualThemeV3.spacingM),
            Flexible(fit: FlexFit.loose, child: _buildConfirmBlock(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmBlock(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius / 2),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
        boxShadow: const [VisualThemeV3.shadowLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confirm Raise: ${raiseAmount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: DesignTypography.body,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: VisualThemeV3.spacingS),
          Text(
            'Current: ${raiseAmount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: DesignTypography.caption,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: VisualThemeV3.spacingM),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      VisualThemeV3.cardRadius / 2,
                    ),
                    boxShadow: const [VisualThemeV3.shadowLight],
                  ),
                  child: TextButton(
                    onPressed: onCancelRaise,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          VisualThemeV3.cardRadius / 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: VisualThemeV3.spacingS,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: VisualThemeV3.spacingS),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      VisualThemeV3.cardRadius / 2,
                    ),
                    boxShadow: const [VisualThemeV3.shadowLight],
                  ),
                  child: TextButton(
                    onPressed: onConfirmRaise,
                    style: TextButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          VisualThemeV3.cardRadius / 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: VisualThemeV3.spacingS,
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
