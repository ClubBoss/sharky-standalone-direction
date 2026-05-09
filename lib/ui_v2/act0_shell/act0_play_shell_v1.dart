import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

// Quick-action group IDs get primary/gold treatment; drill sets get info tint.
const _kQuickGroupIds = {'continue', 'placement', 'daily', 'weak_spots'};
const _kRepairGroupIds = {'weak_spots'};

Color _groupIconColor(String groupId) {
  if (_kRepairGroupIds.contains(groupId)) return Act0ShellTokensV1.gold;
  if (_kQuickGroupIds.contains(groupId)) return Act0ShellTokensV1.primary;
  return Act0ShellTokensV1.info;
}

class Act0PlayShellV1 extends StatelessWidget {
  const Act0PlayShellV1({
    super.key,
    required this.groups,
    required this.recommendedTitle,
    required this.recommendedSubtitle,
    required this.recommendedReasonLabel,
    required this.recommendedOutcome,
    required this.recommendedOutcomeLead,
    required this.masteryLabel,
    required this.onStartGroup,
    this.screenSubtitle = 'Pick one drill. Sharpen one edge.',
  });

  final List<Act0PracticeGroupV1> groups;
  final String recommendedTitle;
  final String recommendedSubtitle;
  final String recommendedReasonLabel;
  final String recommendedOutcome;
  final String recommendedOutcomeLead;
  final String masteryLabel;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;
  final String screenSubtitle;

  @override
  Widget build(BuildContext context) {
    final primaryGroup = _primaryGroup(groups);
    final quickGroups = groups
        .where((g) => _kQuickGroupIds.contains(g.groupId))
        .toList();
    final drillGroups = groups
        .where((g) => !_kQuickGroupIds.contains(g.groupId))
        .toList();

    return ListView(
      key: const Key('act0_shell_play_screen'),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapLg,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Text('Play', style: Act0ShellTokensV1.screenTitle),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          screenSubtitle,
          key: const Key('act0_shell_play_subtitle'),
          style: Act0ShellTokensV1.muted,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),

        // ── Hero recommended card ──────────────────────────────────────────
        Container(
          key: const Key('act0_shell_play_recommended_card'),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.heroDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _GroupIconV1(groupId: primaryGroup.groupId, large: true),
                  const SizedBox(width: Act0ShellTokensV1.gapMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendedTitle,
                          style: Act0ShellTokensV1.sectionTitle,
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapXs),
                        Text(
                          masteryLabel,
                          key: const Key('act0_shell_play_mastery_label'),
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.gold,
                          ),
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapXs),
                        Text(
                          recommendedSubtitle,
                          style: Act0ShellTokensV1.muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Container(
                key: const Key('act0_shell_play_rationale_panel'),
                padding: const EdgeInsets.symmetric(
                  horizontal: Act0ShellTokensV1.gapMd,
                  vertical: Act0ShellTokensV1.gapXs,
                ),
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.surface2.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusXl,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.gold.withOpacity(0.24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendedReasonLabel,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.gold,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(
                      '$recommendedOutcomeLead $recommendedOutcome',
                      key: const Key('act0_shell_play_outcome_line'),
                      style: Act0ShellTokensV1.muted.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapLg),
              FilledButton(
                key: const Key('act0_shell_play_primary_cta'),
                onPressed: primaryGroup.isEnabled
                    ? () => onStartGroup(primaryGroup)
                    : null,
                style: Act0ShellTokensV1.primaryButtonStyle(),
                child: Text(primaryGroup.ctaLabel),
              ),
            ],
          ),
        ),

        // ── Quick picks section ────────────────────────────────────────────
        if (quickGroups.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _SectionHeaderV1(
            label: 'Quick picks',
            activeCount: quickGroups.where((g) => g.isEnabled).length,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          for (final group in quickGroups) ...[
            _PracticeGroupCardV1(group: group, onStartGroup: onStartGroup),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],

        // ── Drill sets section ─────────────────────────────────────────────
        if (drillGroups.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          _SectionHeaderV1(
            label: 'Drill sets',
            activeCount: drillGroups.where((g) => g.isEnabled).length,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          for (final group in drillGroups) ...[
            _PracticeGroupCardV1(group: group, onStartGroup: onStartGroup),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
      ],
    );
  }

  Act0PracticeGroupV1 _primaryGroup(List<Act0PracticeGroupV1> groups) {
    for (final group in groups) {
      if (group.isEnabled && group.isRecommended) {
        return group;
      }
    }
    for (final groupId in const <String>['weak_spots', 'continue']) {
      for (final group in groups) {
        if (group.groupId == groupId && group.isEnabled) {
          return group;
        }
      }
    }
    return groups.firstWhere(
      (group) => group.isEnabled,
      orElse: () => groups.first,
    );
  }
}

class _SectionHeaderV1 extends StatelessWidget {
  const _SectionHeaderV1({required this.label, required this.activeCount});

  final String label;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Act0ShellTokensV1.sectionTitle),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        if (activeCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              border: Border.all(
                color: Act0ShellTokensV1.primary.withOpacity(0.30),
              ),
            ),
            child: Text(
              '$activeCount active',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.primary,
                letterSpacing: 0.4,
              ),
            ),
          ),
      ],
    );
  }
}

class _PracticeGroupCardV1 extends StatelessWidget {
  const _PracticeGroupCardV1({required this.group, required this.onStartGroup});

  final Act0PracticeGroupV1 group;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;

  @override
  Widget build(BuildContext context) {
    final enabled = group.isEnabled;
    final accentColor = _groupIconColor(group.groupId);
    return Opacity(
      opacity: enabled ? 1 : 0.56,
      child: InkWell(
        key: Key('act0_shell_practice_group_${group.groupId}'),
        onTap: enabled ? () => onStartGroup(group) : null,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            borderColor: enabled
                ? accentColor.withOpacity(0.34)
                : Act0ShellTokensV1.border,
            color: Act0ShellTokensV1.surface2,
          ),
          child: Row(
            children: [
              _GroupIconV1(groupId: group.groupId),
              const SizedBox(width: Act0ShellTokensV1.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: Act0ShellTokensV1.gapSm,
                      runSpacing: Act0ShellTokensV1.gapXs,
                      children: [
                        _SmallChipV1(
                          label: group.categoryLabel,
                          color: enabled
                              ? accentColor
                              : Act0ShellTokensV1.textDim,
                        ),
                        if (group.sessionLabel.isNotEmpty)
                          _SmallChipV1(
                            label: group.sessionLabel,
                            color: Act0ShellTokensV1.gold,
                          ),
                        if (group.countLabel.isNotEmpty)
                          _SmallChipV1(
                            label: group.countLabel,
                            color: Act0ShellTokensV1.textMuted,
                          ),
                        if (group.durationLabel.isNotEmpty)
                          _SmallChipV1(
                            label: group.durationLabel,
                            color: Act0ShellTokensV1.textDim,
                          ),
                      ],
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(group.title, style: Act0ShellTokensV1.cardTitle),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(group.subtitle, style: Act0ShellTokensV1.muted),
                  ],
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Text(
                enabled ? group.ctaLabel : 'Later',
                style: Act0ShellTokensV1.body.copyWith(
                  color: enabled ? accentColor : Act0ShellTokensV1.textDim,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupIconV1 extends StatelessWidget {
  const _GroupIconV1({required this.groupId, this.large = false});

  final String groupId;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final icon = switch (groupId) {
      'continue' => Icons.play_arrow_rounded,
      'placement' => Icons.route_rounded,
      'weak_spots' => Icons.build_circle_rounded,
      'daily' => Icons.flash_on_rounded,
      'actions' => Icons.touch_app_rounded,
      'positions' => Icons.event_seat_rounded,
      'streets' => Icons.timeline_rounded,
      'rankings' => Icons.style_rounded,
      'showdown' => Icons.emoji_events_rounded,
      _ => Icons.school_rounded,
    };
    final color = _groupIconColor(groupId);
    final size = large ? 52.0 : 42.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(large ? 18 : 14),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Icon(icon, color: color, size: large ? 27 : 22),
    );
  }
}

class _SmallChipV1 extends StatelessWidget {
  const _SmallChipV1({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: color.withOpacity(0.26)),
      ),
      child: Text(label, style: Act0ShellTokensV1.label.copyWith(color: color)),
    );
  }
}
