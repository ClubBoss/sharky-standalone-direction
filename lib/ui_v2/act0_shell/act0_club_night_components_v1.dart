import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_tokens_v1.dart';

/// Shared Club Night components. One widget per role, so every screen
/// around the table uses the same button, card, tag, step bar, Sharky ring,
/// answer row, tab bar and sheet. Values come only from
/// [Act0ClubNightTokensV1].

typedef _T = Act0ClubNightTokensV1;

/// Keeps text growing with the iPhone setting up to 1.3×, never beyond.
class Act0ClubTextScaleV1 extends StatelessWidget {
  const Act0ClubTextScaleV1({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(
          minScaleFactor: 1,
          maxScaleFactor: _T.maxTextScale,
        ),
      ),
      child: child,
    );
  }
}

/// Club Night buttons. They return the plain Material buttons, so a caller's
/// key lands on the [FilledButton], [OutlinedButton] or [TextButton] itself
/// and existing finders such as `widget<FilledButton>(find.byKey(...))` keep
/// working.
class Act0ClubButtonsV1 {
  const Act0ClubButtonsV1._();

  /// The one brass action on a screen: 56 pt, full width.
  static FilledButton primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return FilledButton(
      key: key,
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _T.brass,
        foregroundColor: _T.onBrass,
        disabledBackgroundColor: _T.raised,
        disabledForegroundColor: _T.caption,
        minimumSize: const Size.fromHeight(_T.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: _T.button,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_T.radiusControl),
        ),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  /// A second choice next to the brass action.
  static OutlinedButton secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool destructive = false,
  }) {
    return OutlinedButton(
      key: key,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: destructive ? _T.mistakeSoft : _T.raised,
        foregroundColor: destructive ? _T.mistake : _T.text,
        disabledForegroundColor: _T.caption,
        minimumSize: const Size.fromHeight(_T.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        textStyle: _T.button,
        side: destructive
            ? const BorderSide(color: _T.mistakeEdge, width: 1.5)
            : _T.controlBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_T.radiusControl),
        ),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  /// A quiet brass text action, at least 44 pt tall.
  static TextButton link({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return TextButton(
      key: key,
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _T.brass,
        minimumSize: const Size(_T.minTouch, _T.minTouch),
        textStyle: _T.link,
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

/// A card on the wall: surface fill and a 1 px brass hairline.
class Act0ClubCardV1 extends StatelessWidget {
  const Act0ClubCardV1({
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
        color: quiet ? _T.wall : _T.surface,
        borderRadius: BorderRadius.circular(_T.radiusCard),
        border: Border.fromBorderSide(
          emphasized ? const BorderSide(color: _T.brassEdge) : _T.cardBorder,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

enum Act0ClubTagToneV1 { brass, correct, neutral }

/// A capsule label: "Extra practice", "On your own", "With help", "Day 2".
class Act0ClubTagV1 extends StatelessWidget {
  const Act0ClubTagV1({
    super.key,
    required this.label,
    this.tone = Act0ClubTagToneV1.brass,
  });

  final String label;
  final Act0ClubTagToneV1 tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      Act0ClubTagToneV1.brass => (_T.brassSoft, _T.brass),
      Act0ClubTagToneV1.correct => (_T.correctSoft, _T.correct),
      Act0ClubTagToneV1.neutral => (_T.raised, _T.text2),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: _T.tag.copyWith(color: fg)),
    );
  }
}

/// Lesson steps: done in brass, current in light, ahead in track colour.
/// The count never changes when the player makes a mistake.
class Act0ClubStepBarV1 extends StatelessWidget {
  const Act0ClubStepBarV1({
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
                      ? _T.brass
                      : i == current
                      ? _T.text
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
enum Act0ClubSharkyMomentV1 { hint, mistake, selfFix, milestone }

/// Sharky in one ring: 56 pt next to a reason or hint, 120 pt on summaries.
class Act0ClubSharkyRingV1 extends StatelessWidget {
  const Act0ClubSharkyRingV1({
    super.key,
    required this.moment,
    this.size = _T.ringSmall,
    this.asset = defaultAsset,
  });

  static const String defaultAsset =
      'assets/images/mascot/sharky_neutral_fallback_v1.png';

  final Act0ClubSharkyMomentV1 moment;
  final double size;
  final String asset;

  static Color ringColorFor(Act0ClubSharkyMomentV1 moment) {
    return switch (moment) {
      Act0ClubSharkyMomentV1.hint => _T.hairlineRing,
      Act0ClubSharkyMomentV1.mistake => _T.brass,
      Act0ClubSharkyMomentV1.selfFix => _T.correct,
      Act0ClubSharkyMomentV1.milestone => _T.correct,
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
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          excludeFromSemantics: true,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

enum Act0ClubAnswerVerdictV1 { none, notThisOne, better }

/// One answer, 56 pt. After the answer the chosen wrong row turns coral
/// with ✕ and "Not this one"; the better row turns green with ✓ and
/// "Better". Colour is never the only signal.
class Act0ClubAnswerRowV1 extends StatelessWidget {
  const Act0ClubAnswerRowV1({
    super.key,
    required this.label,
    this.verdict = Act0ClubAnswerVerdictV1.none,
    this.onTap,
  });

  final String label;
  final Act0ClubAnswerVerdictV1 verdict;
  final VoidCallback? onTap;

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
      Act0ClubAnswerVerdictV1.none => (null, _T.raised, null, null),
      Act0ClubAnswerVerdictV1.notThisOne => (
        _T.mistake,
        _T.mistakeSoft,
        notThisOneLabel,
        Icons.close_rounded,
      ),
      Act0ClubAnswerVerdictV1.better => (
        _T.correct,
        _T.correctSoft,
        betterLabel,
        Icons.check_rounded,
      ),
    };
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

class Act0ClubTabItemV1 {
  const Act0ClubTabItemV1({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Five tabs on the wall. The active tab is brass with its label.
class Act0ClubTabBarV1 extends StatelessWidget {
  const Act0ClubTabBarV1({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<Act0ClubTabItemV1> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _T.wall,
        border: Border(top: _T.cardBorder),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == selectedIndex,
                    button: true,
                    label: items[i].label,
                    excludeSemantics: true,
                    child: InkResponse(
                      key: Key('act0_club_tab_$i'),
                      onTap: () => onSelected(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].icon,
                            size: 26,
                            color: i == selectedIndex ? _T.brass : _T.caption,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].label,
                            style: _T.tab.copyWith(
                              color: i == selectedIndex ? _T.brass : _T.caption,
                            ),
                            textScaler: TextScaler.noScaling,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen header: 28 pt title on the left, optional line under it and an
/// optional trailing control (for example the settings gear on You).
class Act0ClubScreenHeaderV1 extends StatelessWidget {
  const Act0ClubScreenHeaderV1({
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

/// Shows a Club Night bottom sheet: raised fill, 28 pt top corners,
/// a grabber and a 62 % scrim.
Future<T?> showAct0ClubSheetV1<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: _T.raised,
    barrierColor: _T.scrim,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(_T.radiusSheet)),
      side: _T.controlBorder,
    ),
    builder: (context) => Act0ClubTextScaleV1(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _T.screenGutter,
            0,
            _T.screenGutter,
            _T.gapLg,
          ),
          child: builder(context),
        ),
      ),
    ),
  );
}
