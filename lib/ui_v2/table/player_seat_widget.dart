import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';
import '../app_root.dart';
import '../components/help_info_icon_v4.dart';

class PlayerSeatWidget extends StatelessWidget {
  const PlayerSeatWidget({
    required this.position,
    this.isActive = false,
    this.isFolded = false,
    this.isActed = false,
    this.isAllIn = false,
    super.key,
  });

  static const Size _size = Size(76, 60);
  static final double _halfWidth = _size.width / 2;
  static final double _halfHeight = _size.height / 2;

  final Offset position;
  final bool isActive;
  final bool isFolded;
  final bool isActed;
  final bool isAllIn;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - _halfWidth,
      top: position.dy - _halfHeight,
      child: Stack(
        children: [
          Container(
            width: _size.width,
            height: _size.height,
            decoration: DesignContainers.card.copyWith(
              color: _seatColor(),
              border: isActive
                  ? Border.all(
                      color: Color(DesignColors.accentStrong),
                      width: 2,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                if (isActed)
                  const Positioned(top: 4, right: 4, child: Text('✓')),
                if (isAllIn)
                  Positioned(
                    bottom: 2,
                    left: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      color: Color(DesignColors.accentStrong),
                      child: const Center(
                        child: Text(
                          'ALL-IN',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: HelpInfoIconV4(
              componentId: 'player_seat_panel_v4',
              binder: appRoot.exportInlineExplanationBinderV4,
              isV4Active: appRoot.isV4Active,
            ),
          ),
        ],
      ),
    );
  }

  Color _seatColor() {
    final base = Color(DesignColors.surfaceElevated);
    if (!isFolded) return base;
    final fadedAlpha = ((base.a * 0.4).round()).clamp(0, 255);
    return base.withAlpha(fadedAlpha);
  }
}
