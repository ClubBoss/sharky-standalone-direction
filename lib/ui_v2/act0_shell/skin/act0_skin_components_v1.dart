import 'package:flutter/material.dart';

import 'act0_skin_tokens_v1.dart';

typedef _T = Act0SkinTokensV1;

/// Full-width brass action. A null callback disables the action.
class Act0SkinPrimaryButtonV1 extends StatelessWidget {
  const Act0SkinPrimaryButtonV1({
    super.key,
    required this.label,
    required this.onPressed,
    this.controlKey,
    this.labelKey,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Key? controlKey;
  final Key? labelKey;
  final bool compact;

  static final _compactStyle = _buttonStyle(compact: true);
  static final _regularStyle = _buttonStyle(compact: false);

  static ButtonStyle _buttonStyle({required bool compact}) =>
      FilledButton.styleFrom(
        splashFactory: InkRipple.splashFactory,
        backgroundColor: _T.accent,
        foregroundColor: _T.onAccent,
        disabledBackgroundColor: _T.raised,
        disabledForegroundColor: _T.caption,
        minimumSize: Size.fromHeight(compact ? _T.minTouch : _T.controlHeight),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 20,
          vertical: compact ? 6 : 16,
        ),
        textStyle: _T.button,
        elevation: _T.controlElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_T.radiusControl),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: controlKey,
      onPressed: onPressed,
      style: compact ? _compactStyle : _regularStyle,
      child: Text(label, key: labelKey, textAlign: TextAlign.center),
    );
  }
}

/// Outlined alternative, with the existing destructive treatment.
class Act0SkinSecondaryButtonV1 extends StatelessWidget {
  const Act0SkinSecondaryButtonV1({
    super.key,
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.controlKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;
  final Key? controlKey;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: controlKey,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        splashFactory: InkRipple.splashFactory,
        backgroundColor: destructive ? _T.badSoft : _T.raised,
        foregroundColor: destructive ? _T.bad : _T.onSurface,
        disabledForegroundColor: _T.caption,
        minimumSize: const Size.fromHeight(_T.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        textStyle: _T.button,
        side: destructive
            ? const BorderSide(color: _T.badEdge, width: 1.5)
            : _T.controlBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_T.radiusControl),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// A card on the wall: surface fill and a 1 px brass hairline.
class Act0SkinCardV1 extends StatelessWidget {
  const Act0SkinCardV1({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(_T.cardPadding),
    this.emphasized = false,
    this.quiet = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Brass edge for the one card that holds the screen's main action.
  final bool emphasized;

  /// Wall fill for later or inactive items.
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: quiet ? _T.background : _T.surface,
        borderRadius: BorderRadius.circular(_T.radiusCard),
        border: Border.fromBorderSide(
          emphasized ? const BorderSide(color: _T.accentEdge) : _T.cardBorder,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

enum Act0SkinChipToneV1 { brass, correct, neutral }

/// A capsule label: "Extra practice", "On your own", "With help", "Day 2".
class Act0SkinChipV1 extends StatelessWidget {
  const Act0SkinChipV1({
    super.key,
    required this.label,
    this.tone = Act0SkinChipToneV1.brass,
    this.onPressed,
    this.selected = false,
  });

  final String label;
  final Act0SkinChipToneV1 tone;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      Act0SkinChipToneV1.brass => (_T.accentSoft, _T.accent),
      Act0SkinChipToneV1.correct => (_T.okSoft, _T.ok),
      Act0SkinChipToneV1.neutral => (_T.raised, _T.muted),
    };
    final chip = Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: _T.tag.copyWith(color: fg)),
    );
    if (onPressed == null) return chip;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _T.minTouch),
          child: Center(widthFactor: 1, child: chip),
        ),
      ),
    );
  }
}

/// Lesson steps: done in brass, current in light, ahead in track colour.
/// The count never changes when the player makes a mistake.
class Act0SkinStepBarV1 extends StatelessWidget {
  const Act0SkinStepBarV1({
    super.key,
    required this.total,
    required this.current,
  }) : assert(total > 0),
       assert(current >= 0 && current <= total);

  /// Number of steps.
  final int total;

  /// 1-based current step; steps before it are done.
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $current of $total',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: 3),
            Expanded(
              child: Container(
                key: Key('act0_club_step_$i'),
                height: 4,
                decoration: BoxDecoration(
                  color: i < current
                      ? _T.accent
                      : i == current
                      ? _T.onSurface
                      : _T.track,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Why Sharky is on screen. Sharky is never shown while the player decides.
enum Act0SkinSharkyMomentV1 {
  hint,
  mistake,
  selfFix,
  milestone,
  lessonDone,
  idle,
}

/// Sharky in one ring: 56 pt next to a reason or hint, 120 pt on summaries.
class Act0SkinSharkyExpressionV1 extends StatelessWidget {
  const Act0SkinSharkyExpressionV1({
    super.key,
    required this.moment,
    this.size = _T.ringSmall,
  });

  final Act0SkinSharkyMomentV1 moment;
  final double size;

  static Color ringColorFor(Act0SkinSharkyMomentV1 moment) {
    return switch (moment) {
      Act0SkinSharkyMomentV1.hint || Act0SkinSharkyMomentV1.idle => _T.lineRing,
      Act0SkinSharkyMomentV1.mistake => _T.accent,
      Act0SkinSharkyMomentV1.selfFix => _T.ok,
      Act0SkinSharkyMomentV1.milestone ||
      Act0SkinSharkyMomentV1.lessonDone => _T.ok,
    };
  }

  @override
  Widget build(BuildContext context) {
    final border = size >= _T.ringLarge ? 3.0 : 2.0;
    return Semantics(
      label: 'Sharky',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _T.raised,
          border: Border.all(color: ringColorFor(moment), width: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          switch (moment) {
            Act0SkinSharkyMomentV1.hint ||
            Act0SkinSharkyMomentV1.idle => _T.sharkyHintAsset,
            Act0SkinSharkyMomentV1.mistake => _T.sharkyMistakeAsset,
            Act0SkinSharkyMomentV1.selfFix => _T.sharkyFixedItAsset,
            Act0SkinSharkyMomentV1.milestone => _T.sharkyFixedItAsset,
            Act0SkinSharkyMomentV1.lessonDone => _T.sharkyLessonDoneAsset,
          },
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          excludeFromSemantics: true,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

enum Act0SkinAnswerVerdictV1 { none, notThisOne, better }

/// One answer, 56 pt. After the answer the chosen wrong row turns coral
/// with ✕ and "Not this one"; the better row turns green with ✓ and
/// "Better". Colour is never the only signal.
class Act0SkinAnswerOptionRowV1 extends StatelessWidget {
  const Act0SkinAnswerOptionRowV1({
    super.key,
    required this.label,
    this.verdict = Act0SkinAnswerVerdictV1.none,
    this.onTap,
    this.compact = false,
    this.verdictLabel,
  });

  final String label;
  final Act0SkinAnswerVerdictV1 verdict;
  final VoidCallback? onTap;
  final bool compact;
  final String? verdictLabel;

  static const String notThisOneLabel = 'Not this one';
  static const String betterLabel = 'Better';

  @override
  Widget build(BuildContext context) {
    final (
      Color? tone,
      Color fill,
      String? word,
      IconData? icon,
    ) = switch (verdict) {
      Act0SkinAnswerVerdictV1.none => (null, _T.raised, null, null),
      Act0SkinAnswerVerdictV1.notThisOne => (
        _T.bad,
        _T.badSoft,
        notThisOneLabel,
        _T.mistakeIcon,
      ),
      Act0SkinAnswerVerdictV1.better => (
        _T.ok,
        _T.okSoft,
        betterLabel,
        _T.correctIcon,
      ),
    };
    if (compact && icon != null) {
      final caption = verdictLabel ?? word!;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$caption: $label',
              style: _T.tag.copyWith(color: tone),
            ),
          ),
        ],
      );
    }
    final semantics = word == null ? label : '$label, ${word.toLowerCase()}';
    return Semantics(
      button: onTap != null,
      label: semantics,
      excludeSemantics: true,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_T.radiusControl),
          side: tone == null
              ? _T.controlBorder
              : BorderSide(color: tone, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _T.controlHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: tone),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: Text(label, style: _T.body)),
                  if (word != null) ...[
                    const SizedBox(width: 8),
                    Text(word, style: _T.tag.copyWith(color: tone)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Act0SkinSheetHeaderV1 extends StatelessWidget {
  const Act0SkinSheetHeaderV1({
    super.key,
    required this.title,
    this.overline,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? overline;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null) ...[
                Text(overline!, style: _T.captionStyle),
                const SizedBox(height: 2),
              ],
              Semantics(header: true, child: Text(title, style: _T.title)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: _T.secondary),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Archive-style selectable row. Selection and ordering belong to the caller.
enum Act0SkinListRowKindV1 { pattern, retry, hand, destructive }

class Act0SkinListRowV1 extends StatelessWidget {
  const Act0SkinListRowV1({
    super.key,
    required this.title,
    this.subtitle,
    this.expanded,
    this.icon,
    this.toggle,
    this.onChanged,
    this.destructive = false,
    required this.onTap,
    this.controlKey,
    this.kind = Act0SkinListRowKindV1.pattern,
    this.dark = false,
  });

  final String title;
  final String? subtitle;
  final bool? expanded;
  final IconData? icon;
  final bool? toggle;
  final ValueChanged<bool>? onChanged;
  final bool destructive;
  final VoidCallback? onTap;
  final Key? controlKey;
  final Act0SkinListRowKindV1 kind;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final isDestructive =
        destructive || kind == Act0SkinListRowKindV1.destructive;
    if (expanded == null &&
        ((!dark && kind == Act0SkinListRowKindV1.pattern) ||
            icon != null ||
            toggle != null ||
            destructive)) {
      final color = isDestructive ? _T.bad : _T.onSurface;
      return MergeSemantics(
        child: ListTile(
          key: toggle == null ? controlKey : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: _T.gapMd),
          minTileHeight: _T.controlHeight,
          leading: icon == null ? null : Icon(icon, color: color),
          title: Text(title, style: _T.body.copyWith(color: color)),
          subtitle: subtitle?.isNotEmpty != true
              ? null
              : Text(subtitle!, style: _T.secondary),
          trailing: toggle == null
              ? onTap == null
                    ? null
                    : Icon(Icons.chevron_right, color: color)
              : Switch(
                  key: controlKey,
                  value: toggle!,
                  onChanged: onChanged,
                  activeThumbColor: _T.academyOnSurface,
                  activeTrackColor: _T.academyTeal,
                  inactiveThumbColor: _T.muted,
                  inactiveTrackColor: _T.track,
                  trackOutlineColor: const WidgetStatePropertyAll(
                    _T.lineStrong,
                  ),
                ),
          onTap: onTap,
        ),
      );
    }
    return Semantics(
      expanded: expanded,
      child: ListTile(
        key: controlKey,
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: isDestructive
              ? _T.body.copyWith(color: _T.bad)
              : dark
              ? _T.body
              : _T.editorialBody,
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: dark ? _T.secondary : _T.editorialSupporting,
              ),
        selected: expanded ?? false,
        iconColor: isDestructive
            ? _T.bad
            : dark
            ? _T.muted
            : null,
        trailing: Icon(switch (expanded) {
          true => _T.collapseIcon,
          false => _T.expandIcon,
          null => isDestructive ? Icons.delete_outline : Icons.chevron_right,
        }),
        onTap: onTap,
      ),
    );
  }
}

class Act0SkinScreenHeaderV1 extends StatelessWidget {
  const Act0SkinScreenHeaderV1({
    super.key,
    required this.title,
    this.onBack,
    this.backKey,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Key? backKey;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (onBack != null)
        IconButton(
          key: backKey,
          onPressed: onBack,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.chevron_left),
          color: _T.onSurface,
        ),
      if (onBack != null) const SizedBox(width: _T.gapSm),
      Expanded(child: Text(title, style: _T.title)),
      if (trailing != null) trailing!,
    ],
  );
}

/// Shared theme for dark routes that contain Material fields and controls.
class Act0SkinDarkAreaV1 extends StatelessWidget {
  const Act0SkinDarkAreaV1({
    super.key,
    required this.child,
    this.paintBackground = true,
    this.maxContentWidth,
  });
  final bool paintBackground;
  final double? maxContentWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = maxContentWidth;
    final content = width == null
        ? child
        : Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: child,
            ),
          );
    return Theme(
      data: theme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _T.background,
        colorScheme: const ColorScheme.dark(
          primary: _T.accent,
          onPrimary: _T.onAccent,
          surface: _T.surface,
          onSurface: _T.onSurface,
          onSurfaceVariant: _T.muted,
          outline: _T.muted,
          outlineVariant: _T.line,
          error: _T.bad,
        ),
        textTheme: theme.textTheme
            .apply(bodyColor: _T.onSurface, displayColor: _T.onSurface)
            .copyWith(
              bodyLarge: _T.body,
              bodyMedium: _T.body,
              bodySmall: _T.secondary,
              labelLarge: _T.button,
              labelMedium: _T.tag,
              labelSmall: _T.captionStyle,
              titleLarge: _T.title,
              titleMedium: _T.headline,
              titleSmall: _T.secondary,
            ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: _T.secondary,
          helperStyle: _T.secondary,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _T.accent,
            disabledForegroundColor: _T.caption,
            textStyle: _T.button,
          ),
        ),
        dividerColor: _T.line,
      ),
      child: paintBackground
          ? Material(color: _T.background, child: content)
          : content,
    );
  }
}

class Act0SkinConfirmSheetV1 extends StatelessWidget {
  const Act0SkinConfirmSheetV1({
    super.key,
    required this.title,
    this.confirmLabel = 'Delete',
    this.description,
    this.onCancel,
    this.onConfirm,
    this.cancelKey,
    this.confirmKey,
  });

  final String title;
  final String confirmLabel;
  final String? description;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Key? cancelKey;
  final Key? confirmKey;

  Future<bool> show(BuildContext context) async =>
      await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: _T.surface,
        barrierColor: _T.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_T.radiusSheet),
          ),
        ),
        builder: (_) => this,
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    if (description != null || onCancel != null || onConfirm != null) {
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_T.cardPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: _T.headline),
              const SizedBox(height: _T.gapMd),
              if (description != null) Text(description!, style: _T.secondary),
              const SizedBox(height: _T.gapLg),
              Act0SkinSecondaryButtonV1(
                label: 'Cancel',
                onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                controlKey: cancelKey,
              ),
              const SizedBox(height: _T.gapSm),
              Act0SkinSecondaryButtonV1(
                label: confirmLabel,
                destructive: true,
                onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                controlKey: confirmKey,
              ),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      minimum: const EdgeInsets.all(_T.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _T.title),
          const SizedBox(height: _T.gapMd),
          Act0SkinSecondaryButtonV1(
            controlKey: confirmKey,
            label: confirmLabel,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: _T.gapSm),
          Act0SkinSecondaryButtonV1(
            label: 'Cancel',
            controlKey: cancelKey,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

/// Home's course bar. A missing ratio draws a track without announcing a value.
class Act0SkinProgressBarV1 extends StatelessWidget {
  const Act0SkinProgressBarV1({
    super.key,
    required this.ratio,
    required this.label,
    this.valueLabel,
    this.indicatorKey,
  });

  final double? ratio;
  final String label;
  final String? valueLabel;
  final Key? indicatorKey;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: ratio == null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_T.courseProgressRadius),
        child: LinearProgressIndicator(
          key: indicatorKey,
          minHeight: _T.courseProgressHeight,
          value: ratio ?? 0,
          semanticsLabel: label,
          semanticsValue: valueLabel,
          backgroundColor: _T.courseProgressTrack,
          color: _T.courseProgressFill,
        ),
      ),
    );
  }
}

/// Circular indicator in the current Settings treatment.
class Act0SkinProgressRingV1 extends StatelessWidget {
  const Act0SkinProgressRingV1({
    super.key,
    this.ratio,
    this.label,
    this.valueLabel,
  });

  final double? ratio;
  final String? label;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      value: ratio ?? (MediaQuery.disableAnimationsOf(context) ? 0 : null),
      color: _T.courseProgressFill,
      semanticsLabel: label,
      semanticsValue: valueLabel,
    );
  }
}

/// Uses the progress-save notice treatment of the current shell.
class Act0SkinBannerV1 extends StatelessWidget {
  const Act0SkinBannerV1({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionKey,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Key? secondaryActionKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _T.themeSurface(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _T.gapLg,
          vertical: _T.gapSm,
        ),
        child: Row(
          children: [
            Expanded(child: Semantics(liveRegion: true, child: Text(message))),
            if (actionLabel case final label?)
              TextButton(
                style: const ButtonStyle(
                  splashFactory: InkRipple.splashFactory,
                ),
                key: actionKey,
                onPressed: onAction,
                child: Text(label),
              ),
            if (secondaryActionLabel case final label?)
              TextButton(
                style: const ButtonStyle(
                  splashFactory: InkRipple.splashFactory,
                ),
                key: secondaryActionKey,
                onPressed: onSecondaryAction,
                child: Text(label),
              ),
          ],
        ),
      ),
    );
  }
}

/// The empty Review heading and support copy.
class Act0SkinEmptyStateV1 extends StatelessWidget {
  const Act0SkinEmptyStateV1({
    super.key,
    required this.title,
    required this.description,
    this.titleKey,
    this.action,
  });

  final String title;
  final String description;
  final Key? titleKey;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, key: titleKey, style: _T.reviewEmptyTitle),
        const SizedBox(height: _T.gapSm),
        Text(description, style: _T.reviewEmptyBody),
        if (action case final button?) ...[
          const SizedBox(height: _T.gapSm),
          button,
        ],
      ],
    );
  }
}

/// Profile's standard and compact metric treatments.
class Act0SkinStatTileV1 extends StatelessWidget {
  const Act0SkinStatTileV1({
    super.key,
    required this.label,
    required this.value,
    this.subLine = '',
    this.compact = false,
  });

  final String label;
  final String value;
  final String subLine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? _T.gapSm : _T.gapMd),
      decoration: BoxDecoration(
        color: compact ? Colors.transparent : _T.navyRaised,
        borderRadius: BorderRadius.circular(
          compact ? _T.navyCompactStatRadius : _T.navyStatRadius,
        ),
        border: Border.all(
          color: compact ? _T.navyLine : _T.navyLine.withValues(alpha: 0.86),
        ),
        boxShadow: compact ? null : const [_T.navyStatShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _T.navyStatLabel),
          const SizedBox(height: _T.gapSm),
          Text(
            value,
            style: compact
                ? _T.navyStatValue.copyWith(fontWeight: FontWeight.w800)
                : _T.navyStatValue,
          ),
          if (subLine.isNotEmpty) ...[
            const SizedBox(height: _T.gapXs),
            Text(subLine, style: _T.navyStatSupport),
          ],
        ],
      ),
    );
  }
}

class Act0SkinTaskHeaderV1 extends StatelessWidget {
  const Act0SkinTaskHeaderV1({
    super.key,
    required this.step,
    required this.total,
    required this.onClose,
    this.modeLabel,
    this.onHelp,
    this.closeLabel = 'Close',
    this.progressLabel,
  });

  final int step;
  final int total;
  final VoidCallback onClose;
  final String? modeLabel;
  final VoidCallback? onHelp;
  final String closeLabel;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final count = progressLabel ?? '$step of $total';
    // Fixed height: the mode label must never change the header's layout.
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              style: const ButtonStyle(splashFactory: InkRipple.splashFactory),
              key: const Key('act0_shell_runner_back'),
              tooltip: closeLabel,
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          Expanded(
            child: Semantics(
              label: 'Lesson progress',
              value: count,
              child: CustomPaint(
                size: const Size(0, _T.courseProgressHeight),
                painter: _TaskHeaderProgressPainterV1(
                  total > 0 ? (step / total).clamp(0.0, 1.0) : 0,
                  Directionality.of(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: _T.gapMd),
          if (modeLabel case final mode?)
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(count, style: _T.captionStyle),
                Text(mode, style: _T.tag.copyWith(color: _T.accent)),
              ],
            )
          else
            Text(count, style: _T.captionStyle),
          if (onHelp != null)
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                style: const ButtonStyle(
                  splashFactory: InkRipple.splashFactory,
                ),
                key: const Key('act0_shell_runner_glossary'),
                tooltip: 'Glossary',
                onPressed: onHelp,
                icon: const Icon(Icons.menu_book_rounded, size: 22),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// Task progress is determinate. Paint the track and fill in one render object
// so each task transition skips the Material progress indicator subtree.
class _TaskHeaderProgressPainterV1 extends CustomPainter {
  const _TaskHeaderProgressPainterV1(this.fraction, this.direction);

  final double fraction;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final track = RRect.fromRectAndRadius(
      bounds,
      const Radius.circular(_T.courseProgressRadius),
    );
    final paint = Paint()..color = _T.courseProgressTrack;
    canvas.drawRRect(track, paint);
    final fillWidth = size.width * fraction;
    canvas.save();
    canvas.clipRRect(track);
    canvas.drawRect(
      Rect.fromLTWH(
        direction == TextDirection.rtl ? size.width - fillWidth : 0,
        0,
        fillWidth,
        size.height,
      ),
      paint..color = _T.courseProgressFill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TaskHeaderProgressPainterV1 oldDelegate) =>
      fraction != oldDelegate.fraction || direction != oldDelegate.direction;
}

enum Act0SkinFeedbackGradeV1 {
  correct('CORRECT READ'),
  wrong('MISSED CLUE'),
  repaired('Fixed after a hint'),
  assisted('CORRECT WITH HELP');

  const Act0SkinFeedbackGradeV1(this.label);
  final String label;

  Color get tone => switch (this) {
    correct => _T.ok,
    wrong => _T.bad,
    repaired || assisted => _T.accent,
  };
}

class Act0SkinStreetSummaryStripV1 extends StatelessWidget {
  const Act0SkinStreetSummaryStripV1({
    super.key,
    required this.jumps,
    required this.position,
    required this.onJump,
    required this.lines,
  });

  final Map<String, int> jumps;
  final int position;
  final ValueChanged<int> onJump;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final active = jumps.entries
        .where((entry) => entry.value <= position)
        .lastOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: _T.gapSm,
          children: [
            for (final entry in jumps.entries)
              Act0SkinChipV1(
                label: entry.key,
                selected: entry.key == active?.key,
                tone: entry.key == active?.key
                    ? Act0SkinChipToneV1.brass
                    : Act0SkinChipToneV1.neutral,
                onPressed: () => onJump(entry.value),
              ),
          ],
        ),
        for (final line in lines) Text(line, style: _T.secondary),
      ],
    );
  }
}
