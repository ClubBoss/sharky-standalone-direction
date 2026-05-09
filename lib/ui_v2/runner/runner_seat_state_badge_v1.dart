import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';

enum RunnerSeatStateBadgeToneV1 {
  action,
  role,
  forcedBet,
  live,
  folded,
  neutral,
  hero,
}

enum RunnerSeatStateBadgePriorityV1 { primary, secondary }

class RunnerSeatStateBadgeV1 extends StatelessWidget {
  const RunnerSeatStateBadgeV1({
    super.key,
    required this.label,
    required this.tone,
    required this.padding,
    required this.textStyle,
    this.visualPriorityV1 = RunnerSeatStateBadgePriorityV1.primary,
  });

  final String label;
  final RunnerSeatStateBadgeToneV1 tone;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final RunnerSeatStateBadgePriorityV1 visualPriorityV1;

  @override
  Widget build(BuildContext context) {
    return RunnerSeatStateBadgeShellV1(
      tone: tone,
      padding: padding,
      visualPriorityV1: visualPriorityV1,
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: textStyle,
      ),
    );
  }
}

class RunnerSeatStateBadgeShellV1 extends StatelessWidget {
  const RunnerSeatStateBadgeShellV1({
    super.key,
    required this.tone,
    required this.padding,
    required this.child,
    this.visualPriorityV1 = RunnerSeatStateBadgePriorityV1.primary,
  });

  final RunnerSeatStateBadgeToneV1 tone;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final RunnerSeatStateBadgePriorityV1 visualPriorityV1;

  @override
  Widget build(BuildContext context) {
    final decoration = resolveRunnerSeatStateBadgeDecorationV1(
      tone,
      visualPriorityV1: visualPriorityV1,
    );
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: decoration.gradient,
        border: Border.all(
          color: decoration.borderColor,
          width: decoration.borderWidth,
        ),
        boxShadow: decoration.boxShadow,
      ),
      child: child,
    );
  }
}

RunnerSeatStateBadgeDecorationV1 resolveRunnerSeatStateBadgeDecorationV1(
  RunnerSeatStateBadgeToneV1 tone, {
  RunnerSeatStateBadgePriorityV1 visualPriorityV1 =
      RunnerSeatStateBadgePriorityV1.primary,
}) {
  return _RunnerSeatStateBadgePaletteV1.forTone(
    tone,
    visualPriorityV1: visualPriorityV1,
  );
}

class RunnerSeatStateBadgeDecorationV1 {
  const RunnerSeatStateBadgeDecorationV1({
    required this.gradient,
    required this.borderColor,
    required this.borderWidth,
    required this.boxShadow,
  });

  final Gradient gradient;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> boxShadow;
}

class _RunnerSeatStateBadgePaletteV1 extends RunnerSeatStateBadgeDecorationV1 {
  const _RunnerSeatStateBadgePaletteV1({
    required super.gradient,
    required super.borderColor,
    required super.borderWidth,
    required super.boxShadow,
  });

  static _RunnerSeatStateBadgePaletteV1 forTone(
    RunnerSeatStateBadgeToneV1 tone, {
    RunnerSeatStateBadgePriorityV1 visualPriorityV1 =
        RunnerSeatStateBadgePriorityV1.primary,
  }) {
    final basePalette = switch (tone) {
      RunnerSeatStateBadgeToneV1.action => _RunnerSeatStateBadgePaletteV1(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF4F9BFF), Color(0xFF1E40AF)],
        ),
        borderColor: Colors.white.withOpacity(0.22),
        borderWidth: 0.9,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x441E40AF),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      RunnerSeatStateBadgeToneV1.role => _RunnerSeatStateBadgePaletteV1(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primaryBrand.withOpacity(0.92),
            AppColors.primaryBrand.withOpacity(0.68),
          ],
        ),
        borderColor: Colors.white.withOpacity(0.18),
        borderWidth: 0.8,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      RunnerSeatStateBadgeToneV1.forcedBet => _RunnerSeatStateBadgePaletteV1(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF14532D), Color(0xFF166534)],
        ),
        borderColor: Colors.white.withOpacity(0.14),
        borderWidth: 0.8,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33166534),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      RunnerSeatStateBadgeToneV1.live => _RunnerSeatStateBadgePaletteV1(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF0F766E), Color(0xFF115E59)],
        ),
        borderColor: Colors.white.withOpacity(0.14),
        borderWidth: 0.8,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x330F766E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      RunnerSeatStateBadgeToneV1.folded => _RunnerSeatStateBadgePaletteV1(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF313846), Color(0xFF1A1F29)],
        ),
        borderColor: Colors.white.withOpacity(0.12),
        borderWidth: 0.8,
        boxShadow: const <BoxShadow>[],
      ),
      RunnerSeatStateBadgeToneV1.neutral => _RunnerSeatStateBadgePaletteV1(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF475569), Color(0xFF334155)],
        ),
        borderColor: Colors.white.withOpacity(0.14),
        borderWidth: 0.8,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22334155),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      RunnerSeatStateBadgeToneV1.hero => _RunnerSeatStateBadgePaletteV1(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderColor: Colors.white.withOpacity(0.18),
        borderWidth: 0.8,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33D97706),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
    };
    if (visualPriorityV1 == RunnerSeatStateBadgePriorityV1.secondary) {
      return basePalette._softenedForSecondaryPriorityV1();
    }
    return basePalette;
  }

  _RunnerSeatStateBadgePaletteV1 _softenedForSecondaryPriorityV1() {
    return _RunnerSeatStateBadgePaletteV1(
      gradient: _softenGradientV1(gradient),
      borderColor: borderColor.withOpacity(borderColor.opacity * 0.72),
      borderWidth: borderWidth * 0.85,
      boxShadow: boxShadow
          .map(
            (shadow) => shadow.copyWith(
              color: shadow.color.withOpacity(shadow.color.opacity * 0.4),
              blurRadius: shadow.blurRadius * 0.7,
              offset: Offset(shadow.offset.dx, shadow.offset.dy * 0.6),
            ),
          )
          .toList(growable: false),
    );
  }

  Gradient _softenGradientV1(Gradient baseGradient) {
    if (baseGradient case final LinearGradient gradient) {
      const neutralTarget = Color(0xFF334155);
      return LinearGradient(
        begin: gradient.begin,
        end: gradient.end,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
        stops: gradient.stops,
        colors: gradient.colors
            .map((color) => Color.lerp(color, neutralTarget, 0.38)!)
            .toList(growable: false),
      );
    }
    return baseGradient;
  }
}
