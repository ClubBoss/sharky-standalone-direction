import 'package:flutter/material.dart';
import '../skin/act0_skin_components_v1.dart';
import '../skin/act0_skin_tokens_v1.dart';

import '../act0_settings_view_model_v1.dart';

export '../act0_settings_view_model_v1.dart'
    show Act0AcademySettingsLoadStateV1;

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
    this.reminderPermissionDenied = false,
    this.onPracticeReminderChanged,
    this.reminderTime,
    this.onPickReminderTime,
    this.onRetryLoad,
    this.onOpenBetaMetrics,
    this.onOpenSupport,
    this.onReplayWelcome,
    this.onRetakePlacement,
    this.onOpenPrivacy,
    this.onOpenTerms,
    this.onBack,
    this.version,
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
  final bool reminderPermissionDenied;
  final ValueChanged<bool>? onPracticeReminderChanged;
  final String? reminderTime;
  final VoidCallback? onPickReminderTime;
  final VoidCallback? onRetryLoad;
  final VoidCallback? onOpenBetaMetrics;
  final VoidCallback? onOpenSupport;
  final VoidCallback? onReplayWelcome;
  final VoidCallback? onRetakePlacement;
  final VoidCallback? onOpenPrivacy;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onBack;
  final Future<String>? version;
  final VoidCallback? onRecoveryOptions;
  final VoidCallback? onDeleteLocalData;
}

/// Premium Academy Settings leaf ("Quiet Control", Draft PR #315), as a body
/// widget. Routing, persistence and the boot-time settings load stay with the
/// integration owner.
class Act0AcademySettingsLeafV1 extends StatelessWidget {
  const Act0AcademySettingsLeafV1({super.key, required this.input});

  final Act0AcademySettingsLeafInputV1 input;

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const Key('act0_academy_settings_leaf'),
    color: Act0SkinTokensV1.background,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0SkinTokensV1.screenGutter,
      ),
      child: Column(
        children: [
          Act0SkinScreenHeaderV1(
            title: 'Settings',
            backKey: const Key('act0_academy_settings_leaf_back'),
            onBack: input.onBack,
          ),
          Expanded(
            child: switch (input.loadState) {
              Act0AcademySettingsLoadStateV1.loading => const Center(
                key: Key('act0_academy_settings_leaf_loading'),
                child: CircularProgressIndicator(
                  color: Act0SkinTokensV1.academyAccent,
                ),
              ),
              Act0AcademySettingsLoadStateV1.failed => Center(
                child: Act0SkinSecondaryButtonV1(
                  controlKey: const Key('act0_academy_settings_leaf_retry'),
                  label: 'Could not load preferences. Retry',
                  onPressed: input.onRetryLoad,
                ),
              ),
              Act0AcademySettingsLoadStateV1.ready => ListView(
                key: const Key('act0_academy_settings_leaf_scroll'),
                padding: const EdgeInsets.symmetric(
                  vertical: Act0SkinTokensV1.gapMd,
                ),
                children: [
                  Act0SkinCardV1(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        if (input.practiceReminderEnabled != null)
                          Act0SkinListRowV1(
                            title: 'Practice reminder',
                            subtitle:
                                'At most one on a day without practice, when repeats or drills are ready.',
                            icon: Icons.notifications_outlined,
                            controlKey: const Key(
                              'act0_academy_settings_practice_reminder',
                            ),
                            toggle: input.practiceReminderEnabled,
                            onChanged: input.onPracticeReminderChanged,
                            onTap: null,
                          ),
                        if (input.practiceReminderEnabled != null &&
                            input.reminderTime != null)
                          Act0SkinListRowV1(
                            title: 'Reminder time',
                            subtitle: input.reminderTime!,
                            icon: Icons.schedule,
                            controlKey: const Key(
                              'act0_practice_reminder_time',
                            ),
                            onTap: input.onPickReminderTime,
                          ),
                        if (input.practiceReminderEnabled != null &&
                            input.reminderPermissionDenied)
                          const Act0SkinBannerV1(
                            message:
                                'Allow Sharky Poker notifications in iPhone Settings.',
                          ),
                        if (input.onOpenSupport != null ||
                            input.onOpenBetaMetrics != null)
                          _row(
                            'Support',
                            'Find the support contact and copy diagnostics',
                            Icons.help_outline,
                            input.onOpenBetaMetrics != null
                                ? 'act0_settings_beta_activity'
                                : 'act0_settings_support',
                            input.onOpenSupport ?? input.onOpenBetaMetrics,
                          ),
                        _row(
                          'Recovery options',
                          'Inspect your saved recovery copy',
                          Icons.restore,
                          'act0_academy_settings_leaf_recovery',
                          input.onRecoveryOptions,
                        ),
                        _row(
                          'Privacy Policy',
                          'How Sharky Poker handles your information',
                          Icons.privacy_tip_outlined,
                          'act0_academy_settings_leaf_privacy',
                          input.onOpenPrivacy,
                        ),
                        _row(
                          'Delete learner data',
                          'Erase learning history, recovery copies and preferences',
                          Icons.delete_outline,
                          'act0_settings_delete_local_data',
                          input.onDeleteLocalData,
                          destructive: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Act0SkinTokensV1.gapMd),
                  if (input.onSoundChanged != null)
                    Act0SkinListRowV1(
                      title: 'Sound effects',
                      subtitle: input.soundDetail,
                      toggle: input.soundEnabled,
                      onChanged: input.onSoundChanged,
                      controlKey: const Key('act0_academy_settings_leaf_sound'),
                      icon: Icons.volume_up_outlined,
                      onTap: null,
                    ),
                  if (input.onHapticsChanged != null)
                    Act0SkinListRowV1(
                      title: 'Haptics',
                      subtitle: 'Tactile response to decisions',
                      toggle: input.hapticsEnabled,
                      onChanged: input.onHapticsChanged,
                      controlKey: const Key(
                        'act0_academy_settings_leaf_haptics',
                      ),
                      icon: Icons.vibration,
                      onTap: null,
                    ),
                  _row(
                    'Replay Welcome',
                    'See your introduction again',
                    Icons.replay,
                    'act0_academy_settings_leaf_welcome',
                    input.onReplayWelcome,
                  ),
                  _row(
                    'Retake placement',
                    'Check your starting world',
                    Icons.fact_check_outlined,
                    'act0_academy_settings_leaf_placement',
                    input.onRetakePlacement,
                  ),
                  _row(
                    'Terms of Use',
                    'Read the app terms',
                    Icons.description_outlined,
                    'act0_academy_settings_leaf_terms',
                    input.onOpenTerms,
                  ),
                  if (input.onSoundChanged != null ||
                      input.onHapticsChanged != null)
                    const Text(
                      'Preferences are saved on this device.',
                      key: Key('act0_academy_settings_leaf_saved_note'),
                      style: Act0SkinTokensV1.captionStyle,
                    ),
                  if (input.version case final version?)
                    FutureBuilder<String>(
                      future: version,
                      builder: (context, snapshot) => Text(
                        snapshot.data ?? 'Reading version and build…',
                        style: Act0SkinTokensV1.captionStyle,
                      ),
                    ),
                ],
              ),
            },
          ),
        ],
      ),
    ),
  );

  Widget _row(
    String title,
    String subtitle,
    IconData icon,
    String key,
    VoidCallback? action, {
    bool destructive = false,
  }) => action == null
      ? const SizedBox.shrink()
      : Act0SkinListRowV1(
          title: title,
          subtitle: subtitle,
          icon: icon,
          controlKey: Key(key),
          onTap: action,
          destructive: destructive,
        );
}
