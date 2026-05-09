import 'dart:math' as math;
import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';

class CampaignUiMotionV1 {
  CampaignUiMotionV1._();

  static bool microAnimationsEnabled = false;

  static Duration resolveDuration(Duration duration, {bool? enabled}) {
    return (enabled ?? microAnimationsEnabled) ? duration : Duration.zero;
  }

  static ({Duration duration, Curve curve}) maybeAnimate({
    required Duration duration,
    Curve curve = Curves.easeOut,
    bool? enabled,
  }) {
    return (
      duration: resolveDuration(duration, enabled: enabled),
      curve: curve,
    );
  }
}

class CampaignPrimaryCtaV1 extends StatefulWidget {
  const CampaignPrimaryCtaV1({
    super.key,
    required this.label,
    required this.onPressed,
    this.controlKey,
    this.compact = false,
    this.leadingIcon,
    this.height,
    this.textStyle,
    this.semanticsLabel,
    this.microAnimationsEnabled,
  });

  final String label;
  final VoidCallback? onPressed;
  final Key? controlKey;
  final bool compact;
  final IconData? leadingIcon;
  final double? height;
  final TextStyle? textStyle;
  final String? semanticsLabel;
  final bool? microAnimationsEnabled;

  @override
  State<CampaignPrimaryCtaV1> createState() => _CampaignPrimaryCtaV1State();
}

class _CampaignPrimaryCtaV1State extends State<CampaignPrimaryCtaV1> {
  bool _isPressed = false;

  void _handlePressed() {
    unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
    widget.onPressed?.call();
  }

  TextStyle _resolvedLabelStyle() {
    return widget.textStyle ??
        AppTypography.label.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.35,
          color: Colors.white,
        );
  }

  @override
  Widget build(BuildContext context) {
    final microAnimationsEnabled =
        widget.microAnimationsEnabled ??
        CampaignUiMotionV1.microAnimationsEnabled;
    final enabled = widget.onPressed != null;
    final minHeight = math
        .max(widget.height ?? (widget.compact ? 52 : 56), 44)
        .toDouble();
    final pressMotion = CampaignUiMotionV1.maybeAnimate(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      enabled: microAnimationsEnabled,
    );

    final child = widget.leadingIcon == null
        ? Text(
            widget.label,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: _resolvedLabelStyle(),
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.leadingIcon, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: _resolvedLabelStyle(),
                ),
              ),
            ],
          );

    final button = ElevatedButton(
      key: widget.controlKey,
      onPressed: widget.onPressed == null ? null : _handlePressed,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(Size(44, minHeight)),
        tapTargetSize: MaterialTapTargetSize.padded,
        alignment: Alignment.center,
        animationDuration: CampaignUiMotionV1.resolveDuration(
          const Duration(milliseconds: 120),
          enabled: microAnimationsEnabled,
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return SharkyTokensV1.slate600.withOpacity(0.45);
          }
          if (states.contains(MaterialState.pressed) &&
              microAnimationsEnabled) {
            return SharkyTokensV1.brandPrimary.withOpacity(0.9);
          }
          return SharkyTokensV1.brandPrimary;
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return SharkyTokensV1.textMuted;
          }
          return Colors.white;
        }),
        elevation: MaterialStateProperty.resolveWith<double>((states) {
          if (states.contains(MaterialState.disabled)) return 0;
          if (states.contains(MaterialState.pressed) &&
              microAnimationsEnabled) {
            return 2;
          }
          return 4;
        }),
        shadowColor: MaterialStateProperty.all<Color>(
          Colors.black.withOpacity(0.28),
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        side: MaterialStateProperty.resolveWith<BorderSide>((states) {
          if (states.contains(MaterialState.disabled)) {
            return BorderSide(color: SharkyTokensV1.slate600.withOpacity(0.3));
          }
          return BorderSide(color: SharkyTokensV1.brandGlow.withOpacity(0.5));
        }),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            vertical: widget.compact ? 11 : 13,
            horizontal: widget.compact ? 18 : 22,
          ),
        ),
      ),
      child: child,
    );

    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      button: true,
      enabled: enabled,
      child: AnimatedOpacity(
        duration: pressMotion.duration,
        curve: pressMotion.curve,
        opacity: enabled ? 1 : 0.66,
        child: AnimatedScale(
          duration: pressMotion.duration,
          curve: pressMotion.curve,
          scale: (enabled && microAnimationsEnabled && _isPressed) ? 0.985 : 1,
          child: Listener(
            onPointerDown: enabled
                ? (_) {
                    if (!microAnimationsEnabled || !mounted) return;
                    setState(() {
                      _isPressed = true;
                    });
                  }
                : null,
            onPointerCancel: enabled
                ? (_) {
                    if (!_isPressed || !mounted) return;
                    setState(() {
                      _isPressed = false;
                    });
                  }
                : null,
            onPointerUp: enabled
                ? (_) {
                    if (!_isPressed || !mounted) return;
                    setState(() {
                      _isPressed = false;
                    });
                  }
                : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 44, minHeight: minHeight),
              child: button,
            ),
          ),
        ),
      ),
    );
  }
}

class CampaignSecondaryCtaV1 extends StatefulWidget {
  const CampaignSecondaryCtaV1({
    super.key,
    required this.label,
    required this.onPressed,
    this.controlKey,
    this.compact = false,
    this.height,
    this.textStyle,
    this.highlight = false,
    this.semanticsLabel,
    this.microAnimationsEnabled,
  });

  final String label;
  final VoidCallback? onPressed;
  final Key? controlKey;
  final bool compact;
  final double? height;
  final TextStyle? textStyle;
  final bool highlight;
  final String? semanticsLabel;
  final bool? microAnimationsEnabled;

  @override
  State<CampaignSecondaryCtaV1> createState() => _CampaignSecondaryCtaV1State();
}

class _CampaignSecondaryCtaV1State extends State<CampaignSecondaryCtaV1> {
  bool _isPressed = false;

  void _handlePressed() {
    unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final microAnimationsEnabled =
        widget.microAnimationsEnabled ??
        CampaignUiMotionV1.microAnimationsEnabled;
    final enabled = widget.onPressed != null;
    final minHeight = math
        .max(widget.height ?? (widget.compact ? 44 : 48), 44)
        .toDouble();
    final baseTone = widget.highlight
        ? SharkyTokensV1.amber500
        : SharkyTokensV1.slate500;
    final pressMotion = CampaignUiMotionV1.maybeAnimate(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      enabled: microAnimationsEnabled,
    );

    final button = OutlinedButton(
      key: widget.controlKey,
      onPressed: widget.onPressed == null ? null : _handlePressed,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(Size(44, minHeight)),
        tapTargetSize: MaterialTapTargetSize.padded,
        alignment: Alignment.center,
        animationDuration: CampaignUiMotionV1.resolveDuration(
          const Duration(milliseconds: 120),
          enabled: microAnimationsEnabled,
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return SharkyTokensV1.textMuted;
          }
          return SharkyTokensV1.textPrimary;
        }),
        side: MaterialStateProperty.resolveWith<BorderSide>((states) {
          if (states.contains(MaterialState.disabled)) {
            return BorderSide(color: baseTone.withOpacity(0.35), width: 1.1);
          }
          final pressedShift =
              states.contains(MaterialState.pressed) && microAnimationsEnabled;
          return BorderSide(
            color: baseTone.withOpacity(pressedShift ? 0.98 : 0.9),
            width: widget.highlight ? 1.4 : 1.1,
          );
        }),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return SharkyTokensV1.surfaceCard.withOpacity(0.12);
          }
          final base = widget.highlight
              ? SharkyTokensV1.amber500.withOpacity(0.1)
              : SharkyTokensV1.surfaceCard.withOpacity(0.24);
          if (states.contains(MaterialState.pressed) &&
              microAnimationsEnabled) {
            return widget.highlight
                ? SharkyTokensV1.amber500.withOpacity(0.16)
                : SharkyTokensV1.surfaceCard.withOpacity(0.34);
          }
          return base;
        }),
        elevation: MaterialStateProperty.resolveWith<double>((states) {
          if (states.contains(MaterialState.disabled)) return 0;
          if (states.contains(MaterialState.pressed) &&
              microAnimationsEnabled) {
            return 0.5;
          }
          return 1.2;
        }),
        shadowColor: MaterialStateProperty.all<Color>(
          Colors.black.withOpacity(0.2),
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            vertical: widget.compact ? 10 : 12,
            horizontal: widget.compact ? 16 : 20,
          ),
        ),
      ),
      child: Text(
        widget.label,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style:
            widget.textStyle ??
            AppTypography.label.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.25,
            ),
      ),
    );

    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      button: true,
      enabled: enabled,
      child: AnimatedOpacity(
        duration: pressMotion.duration,
        curve: pressMotion.curve,
        opacity: enabled ? 1 : 0.66,
        child: AnimatedScale(
          duration: pressMotion.duration,
          curve: pressMotion.curve,
          scale: (enabled && microAnimationsEnabled && _isPressed) ? 0.985 : 1,
          child: Listener(
            onPointerDown: enabled
                ? (_) {
                    if (!microAnimationsEnabled || !mounted) return;
                    setState(() {
                      _isPressed = true;
                    });
                  }
                : null,
            onPointerCancel: enabled
                ? (_) {
                    if (!_isPressed || !mounted) return;
                    setState(() {
                      _isPressed = false;
                    });
                  }
                : null,
            onPointerUp: enabled
                ? (_) {
                    if (!_isPressed || !mounted) return;
                    setState(() {
                      _isPressed = false;
                    });
                  }
                : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 44, minHeight: minHeight),
              child: button,
            ),
          ),
        ),
      ),
    );
  }
}

class CampaignRankBadgeV1 extends StatelessWidget {
  const CampaignRankBadgeV1({
    super.key,
    required this.label,
    required this.valueKey,
    this.compact = false,
    this.semanticsLabel,
  });

  final String label;
  final Key valueKey;
  final bool compact;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? 'Campaign rank $label',
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 28 : 30),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: SharkyTokensV1.surfaceCard.withOpacity(0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SharkyTokensV1.brandGlow.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_rounded,
              size: compact ? 14 : 16,
              color: SharkyTokensV1.amber500,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                key: valueKey,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CampaignInfoCardV1 extends StatelessWidget {
  const CampaignInfoCardV1({
    super.key,
    required this.child,
    this.containerKey,
    this.compact = false,
    this.padding,
    this.decoration,
    this.duration = Duration.zero,
    this.curve = Curves.easeOut,
    this.microAnimationsEnabled,
  });

  final Widget child;
  final Key? containerKey;
  final bool compact;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final Duration duration;
  final Curve curve;
  final bool? microAnimationsEnabled;

  @override
  Widget build(BuildContext context) {
    final motion = CampaignUiMotionV1.maybeAnimate(
      duration: duration,
      curve: curve,
      enabled: microAnimationsEnabled,
    );
    return AnimatedContainer(
      key: containerKey,
      duration: motion.duration,
      curve: motion.curve,
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 6 : 8,
          ),
      decoration:
          decoration ??
          BoxDecoration(
            color: SharkyTokensV1.surfaceCard.withOpacity(0.74),
            borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
            border: Border.all(
              color: SharkyTokensV1.slate500.withOpacity(0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 0,
              maxWidth: constraints.maxWidth,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
