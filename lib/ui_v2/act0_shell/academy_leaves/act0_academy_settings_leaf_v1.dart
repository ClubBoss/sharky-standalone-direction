import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';

/// Loading state of the persisted preferences the caller owns
/// (`AppSettingsService.instance.load()` in the accepted runtime).
enum Act0AcademySettingsLoadStateV1 { loading, failed, ready }

/// Source-owned Settings inputs. The leaf owns NO persistence:
/// - [soundEnabled]/[hapticsEnabled] are the saved snapshot values.
/// - A toggle row renders only when its change callback is wired to the real
///   persisted setting; a `null` callback hides the row (no fake toggles).
/// - [soundDetail] lets the caller state honestly what sound does today.
/// - Learning/legal rows render only when the caller provides the existing
///   destination (Welcome replay, Placement retake, PrivacyScreen, TermsScreen).
class Act0AcademySettingsLeafInputV1 {
  const Act0AcademySettingsLeafInputV1({
    this.loadState = Act0AcademySettingsLoadStateV1.ready,
    this.soundEnabled = false,
    this.hapticsEnabled = false,
    this.soundDetail = 'Sound effects for decisions',
    this.onSoundChanged,
    this.onHapticsChanged,
    this.onRetryLoad,
    this.onReplayWelcome,
    this.onRetakePlacement,
    this.onOpenPrivacy,
    this.onOpenTerms,
    this.onBack,
  });

  final Act0AcademySettingsLoadStateV1 loadState;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final String soundDetail;
  final ValueChanged<bool>? onSoundChanged;
  final ValueChanged<bool>? onHapticsChanged;
  final VoidCallback? onRetryLoad;
  final VoidCallback? onReplayWelcome;
  final VoidCallback? onRetakePlacement;
  final VoidCallback? onOpenPrivacy;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onBack;
}

/// Premium Academy Settings leaf ("Quiet Control", Draft PR #315), as a body
/// widget. Routing, persistence and the boot-time settings load stay with the
/// integration owner.
class Act0AcademySettingsLeafV1 extends StatelessWidget {
  const Act0AcademySettingsLeafV1({super.key, required this.input});

  final Act0AcademySettingsLeafInputV1 input;

  static const _text = Act0AcademyLeafPaletteV1.text;
  static const _muted = Act0AcademyLeafPaletteV1.textMuted;
  static const _aqua = Act0AcademyLeafPaletteV1.aqua;
  static const _rule = Act0AcademyLeafPaletteV1.rule;
  static const _gold = Color(0xFFE4BB68);

  @override
  Widget build(BuildContext context) {
    final feel = <Widget>[
      if (input.onSoundChanged != null)
        _row(
          'Sound effects',
          input.soundDetail,
          Act0AcademyLeafGlyphKindV1.sound,
          color: const Color(0xFF86C9F5),
          trailing: Switch(
            key: const Key('act0_academy_settings_leaf_sound'),
            value: input.soundEnabled,
            onChanged: input.onSoundChanged,
          ),
        ),
      if (input.onHapticsChanged != null)
        _row(
          'Haptics',
          'Tactile response to decisions',
          Act0AcademyLeafGlyphKindV1.haptics,
          trailing: Switch(
            key: const Key('act0_academy_settings_leaf_haptics'),
            value: input.hapticsEnabled,
            onChanged: input.onHapticsChanged,
          ),
        ),
    ];
    final learning = <Widget>[
      if (input.onReplayWelcome != null)
        _row(
          'Replay Welcome',
          'See your introduction again',
          Act0AcademyLeafGlyphKindV1.recall,
          key: const Key('act0_academy_settings_leaf_welcome'),
          onTap: input.onReplayWelcome,
        ),
      if (input.onRetakePlacement != null)
        _row(
          'Retake Placement',
          'Revisit your starting assessment',
          Act0AcademyLeafGlyphKindV1.placement,
          key: const Key('act0_academy_settings_leaf_placement'),
          color: _gold,
          onTap: input.onRetakePlacement,
        ),
    ];
    final legal = <Widget>[
      if (input.onOpenPrivacy != null)
        _row(
          'Privacy Policy',
          'How Sharky handles your information',
          Act0AcademyLeafGlyphKindV1.privacy,
          key: const Key('act0_academy_settings_leaf_privacy'),
          onTap: input.onOpenPrivacy,
        ),
      if (input.onOpenTerms != null)
        _row(
          'Terms of Use',
          'Read the app terms',
          Act0AcademyLeafGlyphKindV1.terms,
          key: const Key('act0_academy_settings_leaf_terms'),
          color: _muted,
          onTap: input.onOpenTerms,
        ),
    ];

    final Widget body = switch (input.loadState) {
      Act0AcademySettingsLoadStateV1.loading => const Center(
        key: Key('act0_academy_settings_leaf_loading'),
        child: CircularProgressIndicator(color: _aqua),
      ),
      Act0AcademySettingsLoadStateV1.failed => Center(
        child: TextButton(
          key: const Key('act0_academy_settings_leaf_retry'),
          onPressed: input.onRetryLoad,
          style: TextButton.styleFrom(foregroundColor: _aqua),
          child: const Text('Could not load preferences. Retry'),
        ),
      ),
      Act0AcademySettingsLoadStateV1.ready => ListView(
        key: const Key('act0_academy_settings_leaf_scroll'),
        padding: const EdgeInsets.fromLTRB(23, 18, 23, 24),
        children: [
          const Text(
            'YOUR EXPERIENCE',
            style: TextStyle(
              color: _aqua,
              fontSize: 10,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Make Sharky\n'),
                TextSpan(
                  text: 'feel right.',
                  style: TextStyle(color: _gold),
                ),
              ],
            ),
            style: TextStyle(
              color: _text,
              fontSize: 36,
              height: 1.08,
              letterSpacing: -1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'A few choices for a focused learning experience.',
            style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
          ),
          if (feel.isNotEmpty) ...[_label('FEEL & FEEDBACK'), _group(feel)],
          if (learning.isNotEmpty) ...[
            _label('YOUR LEARNING'),
            _group(learning),
          ],
          if (legal.isNotEmpty) ...[
            _label('PRIVACY & INFORMATION'),
            _group(legal),
          ],
          if (feel.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Preferences are saved on this device.',
                key: Key('act0_academy_settings_leaf_saved_note'),
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 11),
              ),
            ),
        ],
      ),
    };

    // Donor #315 switch styling (aqua/teal), scoped to this leaf.
    final themed = Theme.of(context).copyWith(
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF1BBFB2)
              : const Color(0xFF345354),
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _aqua : _rule,
        ),
      ),
    );
    return Theme(data: themed, child: _frame(body));
  }

  Widget _frame(Widget body) {
    return DecoratedBox(
      key: const Key('act0_academy_settings_leaf'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF03282A), Color(0xFF001719), Color(0xFF001113)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 23, 6),
            child: Row(
              children: [
                if (input.onBack != null) ...[
                  IconButton(
                    key: const Key('act0_academy_settings_leaf_back'),
                    tooltip: 'Back',
                    onPressed: input.onBack,
                    icon: const RotatedBox(
                      quarterTurns: 2,
                      child: Act0AcademyLeafGlyphV1(
                        kind: Act0AcademyLeafGlyphKindV1.forward,
                        color: _muted,
                      ),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2A2C),
                      minimumSize: const Size(44, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                        side: const BorderSide(color: _rule),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: _text,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
    child: Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _group(List<Widget> rows) => Material(
    // Material surface so row ink is painted above the group colour.
    color: const Color(0xCC0A2A2C),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: _rule),
    ),
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            const Divider(height: 1, indent: 56, endIndent: 14, color: _rule),
          rows[i],
        ],
      ],
    ),
  );

  Widget _row(
    String title,
    String subtitle,
    Act0AcademyLeafGlyphKindV1 glyph, {
    Key? key,
    Color color = _aqua,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Act0AcademyLeafGlyphV1(kind: glyph, color: color, size: 24),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else if (onTap != null)
            const Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.forward,
              color: _muted,
              size: 18,
            ),
        ],
      ),
    );
    // Merge so a screen reader hears "Haptics ... switch" / "Privacy Policy
    // ... button" as one control (donor #315 row semantics).
    if (onTap == null) return MergeSemantics(child: content);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          key: key,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: content,
          ),
        ),
      ),
    );
  }
}
