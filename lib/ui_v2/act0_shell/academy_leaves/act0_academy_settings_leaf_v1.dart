import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_components_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_tokens_v1.dart';

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
    this.practiceReminderEnabled,
    this.onPracticeReminderChanged,
    this.onRetryLoad,
    this.onOpenBetaMetrics,
    this.onReplayWelcome,
    this.onRetakePlacement,
    this.onOpenPrivacy,
    this.onOpenTerms,
    this.onBack,
    this.onRecoveryOptions,
    this.onDeleteLocalData,
  });

  final Act0AcademySettingsLoadStateV1 loadState;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final String soundDetail;
  final ValueChanged<bool>? onSoundChanged;
  final ValueChanged<bool>? onHapticsChanged;
  final bool? practiceReminderEnabled;
  final ValueChanged<bool>? onPracticeReminderChanged;
  final VoidCallback? onRetryLoad;
  final VoidCallback? onOpenBetaMetrics;
  final VoidCallback? onReplayWelcome;
  final VoidCallback? onRetakePlacement;
  final VoidCallback? onOpenPrivacy;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onBack;
  final VoidCallback? onRecoveryOptions;
  final VoidCallback? onDeleteLocalData;
}

/// Premium Academy Settings leaf ("Quiet Control", Draft PR #315), as a body
/// widget. Routing, persistence and the boot-time settings load stay with the
/// integration owner.
class Act0AcademySettingsLeafV1 extends StatelessWidget {
  const Act0AcademySettingsLeafV1({super.key, required this.input});

  final Act0AcademySettingsLeafInputV1 input;

  static const _text = Act0ClubNightTokensV1.text;
  static const _muted = Act0ClubNightTokensV1.text2;
  static const _brass = Act0ClubNightTokensV1.brass;
  static const _rule = Act0ClubNightTokensV1.hairline;

  @override
  Widget build(BuildContext context) {
    final feel = <Widget>[
      if (input.onSoundChanged != null)
        _row(
          'Sound effects',
          input.soundDetail,
          Act0AcademyLeafGlyphKindV1.sound,
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
      if (input.practiceReminderEnabled != null)
        _row(
          'Practice reminder',
          'One reminder at 6 pm local time when practice is available.',
          Act0AcademyLeafGlyphKindV1.recall,
          trailing: Switch(
            key: const Key('act0_academy_settings_practice_reminder'),
            value: input.practiceReminderEnabled!,
            onChanged: input.onPracticeReminderChanged,
          ),
        ),
    ];
    final learning = <Widget>[
      if (input.onOpenBetaMetrics != null)
        _row(
          'Beta activity',
          'See local progress and answer a short survey',
          Act0AcademyLeafGlyphKindV1.recall,
          key: const Key('act0_settings_beta_activity'),
          onTap: input.onOpenBetaMetrics,
        ),
      if (input.onRecoveryOptions != null)
        _row(
          'Recovery options',
          'Inspect your saved recovery copy',
          Act0AcademyLeafGlyphKindV1.recall,
          key: const Key('act0_academy_settings_leaf_recovery'),
          onTap: input.onRecoveryOptions,
        ),
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
          'Take the W1 rules check',
          'Check your starting world',
          Act0AcademyLeafGlyphKindV1.placement,
          key: const Key('act0_academy_settings_leaf_placement'),
          onTap: input.onRetakePlacement,
        ),
    ];
    final legal = <Widget>[
      if (input.onDeleteLocalData != null)
        _row(
          'Delete local data',
          'Erase learning history, recovery copies and preferences',
          Act0AcademyLeafGlyphKindV1.privacy,
          key: const Key('act0_settings_delete_local_data'),
          color: Act0ClubNightTokensV1.mistake,
          titleColor: Act0ClubNightTokensV1.mistake,
          onTap: input.onDeleteLocalData,
        ),
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
        child: CircularProgressIndicator(color: _brass),
      ),
      Act0AcademySettingsLoadStateV1.failed => Center(
        child: TextButton(
          key: const Key('act0_academy_settings_leaf_retry'),
          onPressed: input.onRetryLoad,
          style: TextButton.styleFrom(foregroundColor: _brass),
          child: const Text('Could not load preferences. Retry'),
        ),
      ),
      Act0AcademySettingsLoadStateV1.ready => ListView(
        key: const Key('act0_academy_settings_leaf_scroll'),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            'A few choices for a focused learning experience.',
            style: Act0ClubNightTokensV1.secondary,
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
                style: TextStyle(
                  color: Act0ClubNightTokensV1.caption,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    };

    // Club Night switches: brass when on, raised when off.
    final themed = Theme.of(context).copyWith(
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Act0ClubNightTokensV1.onBrass
              : Act0ClubNightTokensV1.text2,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? _brass
              : Act0ClubNightTokensV1.raised,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? _brass
              : Act0ClubNightTokensV1.hairlineStrong,
        ),
      ),
    );
    return Theme(
      data: themed,
      child: Act0ClubTextScaleV1(child: _frame(body)),
    );
  }

  Widget _frame(Widget body) {
    return DecoratedBox(
      key: const Key('act0_academy_settings_leaf'),
      decoration: const BoxDecoration(color: Act0ClubNightTokensV1.wall),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
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
                        color: _brass,
                      ),
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: _text,
                    fontSize: 28,
                    height: 34 / 28,
                    letterSpacing: -0.4,
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
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(text, style: Act0ClubNightTokensV1.sectionLabel),
  );

  Widget _group(List<Widget> rows) => Material(
    // Material surface so row ink is painted above the group colour.
    color: Act0ClubNightTokensV1.surface,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Act0ClubNightTokensV1.radiusGroup),
      side: Act0ClubNightTokensV1.cardBorder,
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
    Color color = Act0ClubNightTokensV1.text2,
    Color titleColor = _text,
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
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 17,
                    height: 22 / 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: Act0ClubNightTokensV1.captionStyle),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else if (onTap != null)
            const Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.forward,
              color: Act0ClubNightTokensV1.caption,
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
