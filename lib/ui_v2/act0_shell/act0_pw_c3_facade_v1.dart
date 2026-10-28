import 'package:flutter/material.dart';
import 'act0_academy_iconography_v1.dart';
import 'act0_home_north_star_preview_v1.dart';

const kAct0PwC3PreviewV1 = bool.fromEnvironment('SHARKY_PW_C3_PREVIEW');
// Temporary owner image, decorative intros only. The canonical Runner cannot
// register its baked cast/Hero safely and deliberately never reads this flag.
const kAct0PwC3RenderPreviewV1 = bool.fromEnvironment(
  'SHARKY_PW_C3_RENDER_PREVIEW',
);
const kAct0PwC3RenderAssetV1 =
    'assets/design/sharky/pw_c3/owner_clean_table_candidate_965x1629.png';
bool act0PwC3EnabledV1(BuildContext context) =>
    kAct0PwC3PreviewV1 && Localizations.localeOf(context).languageCode == 'en';

/// Presentation only: no learning state, storage, routing or grading owner.
class Act0PwC3PageV1 extends StatelessWidget {
  const Act0PwC3PageV1({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.content,
    this.primaryLabel = '',
    this.primaryKey = const Key('pw_c3_primary'),
    this.onPrimary,
    this.secondaryLabel,
    this.secondaryKey,
    this.onSecondary,
    this.onBack,
    this.backKey,
    this.backLabel = 'Back',
    this.footer,
    this.hero = false,
    this.stage,
    this.actions,
  });
  final String eyebrow, title, subtitle, primaryLabel;
  final Key primaryKey;
  final Widget content;
  final Widget? actions;
  final VoidCallback? onPrimary, onSecondary, onBack;
  final String? secondaryLabel, footer, stage;
  final Key? secondaryKey, backKey;
  final String backLabel;
  final bool hero;
  static const text = Act0HomeNorthStarPaletteV1.text;
  static const muted = Act0HomeNorthStarPaletteV1.textMuted;
  static const aqua = Act0HomeNorthStarPaletteV1.aqua;
  static const ink = Act0HomeNorthStarPaletteV1.ink;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: ink,
    child: Stack(
      children: [
        if (hero)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: kAct0PwC3RenderPreviewV1 ? 664 : 390,
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: AssetImage(
                        kAct0PwC3RenderPreviewV1
                            ? kAct0PwC3RenderAssetV1
                            : 'assets/design/sharky/home/poker_lounge_reference_v2.png',
                      ),
                      fit: kAct0PwC3RenderPreviewV1
                          ? BoxFit.contain
                          : BoxFit.cover,
                      alignment: kAct0PwC3RenderPreviewV1
                          ? Alignment.topCenter
                          : Alignment.topRight,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xB3020E13), Color(0xB3020E13), ink],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SafeArea(
          child: Column(
            key: const Key('act0_pw_c3_page'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 24, 6),
                child: Row(
                  children: [
                    if (onBack != null)
                      IconButton(
                        key: backKey,
                        tooltip: backLabel,
                        onPressed: onBack,
                        icon: const RotatedBox(
                          quarterTurns: 2,
                          child: Act0AcademyGlyphV1(
                            asset: Act0AcademyIconographyV1.forward,
                            color: muted,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 8),
                    const Act0AcademyGlyphV1(
                      asset: Act0AcademyIconographyV1.learn,
                      color: aqua,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'SHARKY',
                        style: TextStyle(
                          color: text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    if (stage != null)
                      Text(
                        stage!,
                        style: const TextStyle(color: muted, fontSize: 11),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  key: const Key('pw_c3_scroll'),
                  padding: EdgeInsets.fromLTRB(24, hero ? 40 : 18, 24, 24),
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      style: const TextStyle(
                        color: aqua,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: text,
                          fontSize: hero ? 39 : 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.9,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: hero ? 36 : 24),
                    content,
                  ],
                ),
              ),
              actions ??
                  Act0PwC3ActionsV1(
                    primaryLabel: primaryLabel,
                    primaryKey: primaryKey,
                    onPrimary: onPrimary,
                    secondaryLabel: secondaryLabel,
                    secondaryKey: secondaryKey,
                    onSecondary: onSecondary,
                    footer: footer,
                  ),
            ],
          ),
        ),
      ],
    ),
  );
}

class Act0PwC3PanelV1 extends StatelessWidget {
  const Act0PwC3PanelV1({
    super.key,
    required this.title,
    required this.body,
    this.child,
  });
  final String title, body;
  final Widget? child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Act0HomeNorthStarPaletteV1.inkRaised,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Act0HomeNorthStarPaletteV1.rule),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Act0PwC3PageV1.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(
            color: Act0PwC3PageV1.muted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        if (child != null) child!,
      ],
    ),
  );
}

class Act0PwC3ChoiceV1 extends StatelessWidget {
  const Act0PwC3ChoiceV1({
    super.key,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected
              ? const Color(0xFF103C39)
              : Act0HomeNorthStarPaletteV1.inkRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: selected
                  ? Act0PwC3PageV1.aqua
                  : Act0HomeNorthStarPaletteV1.rule,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Act0PwC3PageV1.text,
                            fontSize: 15,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: Act0PwC3PageV1.muted,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (selected)
                    const Act0AcademyGlyphV1(
                      asset: Act0AcademyIconographyV1.practice,
                      color: Act0PwC3PageV1.aqua,
                      size: 22,
                    )
                  else
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Act0PwC3PageV1.muted),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class Act0PwC3ActionsV1 extends StatelessWidget {
  const Act0PwC3ActionsV1({
    super.key,
    required this.primaryLabel,
    required this.primaryKey,
    required this.onPrimary,
    this.secondaryLabel,
    this.secondaryKey,
    this.onSecondary,
    this.footer,
  });
  final String primaryLabel;
  final Key primaryKey;
  final VoidCallback? onPrimary, onSecondary;
  final String? secondaryLabel, footer;
  final Key? secondaryKey;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
    decoration: const BoxDecoration(
      color: Act0PwC3PageV1.ink,
      border: Border(top: BorderSide(color: Act0HomeNorthStarPaletteV1.rule)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (footer != null) ...[
          Text(
            footer!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Act0PwC3PageV1.muted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
        ],
        FilledButton(
          key: primaryKey,
          onPressed: onPrimary,
          style: FilledButton.styleFrom(
            backgroundColor: Act0PwC3PageV1.aqua,
            foregroundColor: Act0PwC3PageV1.ink,
            disabledBackgroundColor: const Color(0xFF173735),
            disabledForegroundColor: Act0PwC3PageV1.muted,
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(primaryLabel, textAlign: TextAlign.center),
        ),
        if (onSecondary != null)
          TextButton(
            key: secondaryKey,
            onPressed: onSecondary,
            style: TextButton.styleFrom(
              foregroundColor: Act0PwC3PageV1.muted,
              minimumSize: const Size.fromHeight(44),
            ),
            child: Text(secondaryLabel!, textAlign: TextAlign.center),
          ),
      ],
    ),
  );
}
