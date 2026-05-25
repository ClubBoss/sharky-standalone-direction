import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
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

String _playCopyV1(
  BuildContext context,
  String atomId, {
  required String fallback,
}) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

String _playTaskLineV1(BuildContext _context, Act0PracticeGroupV1 group) =>
    group.subtitle;

String _playActionLabelV1(BuildContext context, Act0PracticeGroupV1 group) {
  if (!group.isEnabled) {
    if (group.groupId == 'weak_spots') {
      return _playCopyV1(
        context,
        'play_action_no_active_fixes',
        fallback: 'No active fixes',
      );
    }
    return _playCopyV1(context, 'play_later_cta', fallback: 'Later');
  }
  return switch (group.groupId) {
    'daily' => _playCopyV1(
      context,
      'play_action_start_daily_set',
      fallback: 'Start daily set',
    ),
    'weak_spots' => _playCopyV1(
      context,
      'play_action_fix_next_leak',
      fallback: 'Fix next leak',
    ),
    'continue' => _playCopyV1(
      context,
      'play_action_resume_route',
      fallback: 'Continue lesson',
    ),
    'placement' => _playCopyV1(
      context,
      'play_action_run_check',
      fallback: 'Run check',
    ),
    _ => _playCopyV1(context, 'play_action_open', fallback: 'Open'),
  };
}

String _playTileBadgeV1(BuildContext context, Act0PracticeGroupV1 group) {
  return switch (group.groupId) {
    'daily' => _playCopyV1(context, 'play_badge_today', fallback: 'Today'),
    'weak_spots' => _playCopyV1(
      context,
      'play_badge_repair',
      fallback: 'Repair',
    ),
    'continue' => _playCopyV1(context, 'play_badge_route', fallback: 'Route'),
    'placement' => _playCopyV1(
      context,
      'play_badge_skill_check',
      fallback: 'Skill check',
    ),
    'actions' => _playCopyV1(
      context,
      'play_badge_decisions',
      fallback: 'Decisions',
    ),
    'blinds' => _playCopyV1(context, 'play_badge_blinds', fallback: 'Blinds'),
    'positions' => _playCopyV1(context, 'play_badge_seats', fallback: 'Seats'),
    'streets' => _playCopyV1(
      context,
      'play_badge_streets',
      fallback: 'Streets',
    ),
    'rankings' => _playCopyV1(
      context,
      'play_badge_rankings',
      fallback: 'Rankings',
    ),
    'showdown' => _playCopyV1(
      context,
      'play_badge_showdown',
      fallback: 'Showdown',
    ),
    _ => _playCopyV1(context, 'play_badge_pack', fallback: 'Pack'),
  };
}

String _playTileTitleV1(BuildContext context, Act0PracticeGroupV1 group) {
  return switch (group.groupId) {
    'placement' => _playCopyV1(
      context,
      'play_badge_skill_check',
      fallback: 'Skill check',
    ),
    'continue' => _playCopyV1(
      context,
      'play_action_resume_route',
      fallback: 'Continue lesson',
    ),
    _ => group.title,
  };
}

class Act0PlayShellV1 extends StatefulWidget {
  const Act0PlayShellV1({
    super.key,
    required this.groups,
    required this.recommendedGroupId,
    required this.recommendedTitle,
    required this.recommendedSubtitle,
    required this.recommendedReasonLabel,
    required this.recommendedOutcome,
    required this.recommendedOutcomeLead,
    required this.masteryLabel,
    required this.onStartGroup,
    this.screenSubtitle = 'Short reps keep today\'s skill sharp.',
    this.completionTitle,
    this.completionBody,
  });

  final List<Act0PracticeGroupV1> groups;
  final String recommendedGroupId;
  final String recommendedTitle;
  final String recommendedSubtitle;
  final String recommendedReasonLabel;
  final String recommendedOutcome;
  final String recommendedOutcomeLead;
  final String masteryLabel;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;
  final String screenSubtitle;
  final String? completionTitle;
  final String? completionBody;

  @override
  State<Act0PlayShellV1> createState() => _Act0PlayShellV1State();
}

class _Act0PlayShellV1State extends State<Act0PlayShellV1> {
  @override
  Widget build(BuildContext context) {
    final quickDrillGroup = _groupById(widget.groups, 'daily');
    final fixLeakGroup = _groupById(widget.groups, 'weak_spots');
    final featuredGroup =
        _groupById(widget.groups, widget.recommendedGroupId) ??
        quickDrillGroup ??
        fixLeakGroup ??
        (widget.groups.isEmpty ? null : widget.groups.first);
    final excludedGroupIds = <String>{
      if (featuredGroup != null) featuredGroup.groupId,
      if (quickDrillGroup != null) quickDrillGroup.groupId,
      if (fixLeakGroup != null) fixLeakGroup.groupId,
      'placement',
      'continue',
    };
    final topicGroups =
        widget.groups
            .where((group) => !excludedGroupIds.contains(group.groupId))
            .toList()
          ..sort((a, b) {
            final topicCompare = _topicSortIndex(
              a,
            ).compareTo(_topicSortIndex(b));
            if (topicCompare != 0) {
              return topicCompare;
            }
            if (a.isEnabled != b.isEnabled) {
              return a.isEnabled ? -1 : 1;
            }
            return a.title.compareTo(b.title);
          });
    final primaryGroups = <Act0PracticeGroupV1>[
      if (quickDrillGroup != null &&
          quickDrillGroup.groupId != featuredGroup?.groupId)
        quickDrillGroup,
      if (fixLeakGroup != null &&
          fixLeakGroup.isEnabled &&
          fixLeakGroup.groupId != featuredGroup?.groupId)
        fixLeakGroup,
    ];
    final hasRepairEmptyState =
        fixLeakGroup != null &&
        !fixLeakGroup.isEnabled &&
        fixLeakGroup.groupId != featuredGroup?.groupId;
    final topicShelfGroups = <Act0PracticeGroupV1>[...topicGroups];

    return ListView(
      key: const Key('act0_shell_play_screen'),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapLg,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Act0ShellScreenHeaderV1(
          title: _playCopyV1(context, 'play_title', fallback: 'Practice'),
          subtitle: widget.screenSubtitle,
          subtitleKey: const Key('act0_shell_play_subtitle'),
          eyebrow: _playCopyV1(
            context,
            'play_quick_practice_label',
            fallback: 'Quick practice',
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        if (featuredGroup != null) ...[
          _FeaturedPracticeCardV1(
            group: featuredGroup,
            title: widget.recommendedTitle,
            subtitle: widget.recommendedSubtitle,
            reasonLabel: widget.recommendedReasonLabel,
            outcomeLead: widget.recommendedOutcomeLead,
            outcome: widget.recommendedOutcome,
            masteryLabel: widget.masteryLabel,
            onStartGroup: widget.onStartGroup,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapLg),
        ],
        if (widget.completionTitle != null &&
            widget.completionBody != null) ...[
          _PlayIntroCardV1(
            title: widget.completionTitle!,
            body: widget.completionBody!,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapLg),
        ],
        if (primaryGroups.isNotEmpty ||
            hasRepairEmptyState ||
            topicShelfGroups.isNotEmpty) ...[
          if (primaryGroups.isNotEmpty || hasRepairEmptyState) ...[
            _SectionHeaderV1(
              label: _playCopyV1(
                context,
                'play_quick_drills_label',
                fallback: 'Quick reps',
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            if (primaryGroups.isNotEmpty)
              _PlayLaneListV1(
                sectionKey: const Key('act0_shell_play_active_hub'),
                groups: primaryGroups,
                builder: (group) => _PracticeGroupCardV1(
                  group: group,
                  onStartGroup: widget.onStartGroup,
                ),
              ),
            if (hasRepairEmptyState) ...[
              if (primaryGroups.isNotEmpty)
                const SizedBox(height: Act0ShellTokensV1.gapSm),
              _PlayRepairEmptyCardV1(localeIsRu: act0IsRuLocaleV1(context)),
            ],
            const SizedBox(height: Act0ShellTokensV1.gapLg),
          ],
          if (topicShelfGroups.isNotEmpty) ...[
            _SectionHeaderV1(
              label: _playCopyV1(
                context,
                'play_topic_packs_label',
                fallback: 'Skill packs',
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            _PlayGridSectionV1(
              sectionKey: const Key('act0_shell_play_topic_hub'),
              groups: topicShelfGroups,
              staggerOddTiles: false,
              builder: (group) => _TopicPracticeCardV1(
                group: group,
                onStartGroup: widget.onStartGroup,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Act0PracticeGroupV1? _groupById(
    List<Act0PracticeGroupV1> groups,
    String groupId,
  ) {
    for (final group in groups) {
      if (group.groupId == groupId) {
        return group;
      }
    }
    return null;
  }

  String _topicFamilyForGroup(BuildContext context, Act0PracticeGroupV1 group) {
    return switch (group.groupId) {
      'actions' => _playCopyV1(
        context,
        'play_topic_preflop',
        fallback: 'Preflop',
      ),
      'blinds' => _playCopyV1(
        context,
        'play_topic_preflop',
        fallback: 'Preflop',
      ),
      'positions' => _playCopyV1(
        context,
        'play_topic_position',
        fallback: 'Position',
      ),
      'streets' => _playCopyV1(
        context,
        'play_topic_postflop',
        fallback: 'Postflop',
      ),
      'rankings' => _playCopyV1(
        context,
        'play_topic_hand_reading',
        fallback: 'Hand reading',
      ),
      'showdown' => _playCopyV1(
        context,
        'play_topic_showdown',
        fallback: 'Showdown',
      ),
      _ => group.categoryLabel,
    };
  }

  int _topicFilterSortIndex(String label) {
    return switch (label) {
      'All topics' || 'Все темы' => 0,
      'Preflop' || 'Префлоп' => 1,
      'Position' || 'Позиция' => 2,
      'Postflop' || 'Постфлоп' => 3,
      'Hand reading' || 'Чтение руки' => 4,
      'Showdown' || 'Шоудаун' => 5,
      _ => 100,
    };
  }

  int _topicSortIndex(Act0PracticeGroupV1 group) {
    return _topicFilterSortIndex(_topicFamilyForGroup(context, group));
  }
}

class _TopicFilterChipV1 extends StatelessWidget {
  const _TopicFilterChipV1({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('act0_shell_play_topic_filter_$label'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? Act0ShellTokensV1.primary.withOpacity(0.14)
              : Act0ShellTokensV1.surface3,
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
          border: Border.all(
            color: selected
                ? Act0ShellTokensV1.primary.withOpacity(0.34)
                : Act0ShellTokensV1.border,
          ),
        ),
        child: Text(
          label,
          style: Act0ShellTokensV1.label.copyWith(
            color: selected
                ? Act0ShellTokensV1.primary
                : Act0ShellTokensV1.textMuted,
          ),
        ),
      ),
    );
  }
}

class _FeaturedPracticeCardV1 extends StatelessWidget {
  const _FeaturedPracticeCardV1({
    required this.group,
    required this.title,
    required this.subtitle,
    required this.reasonLabel,
    required this.outcomeLead,
    required this.outcome,
    required this.masteryLabel,
    required this.onStartGroup,
  });

  final Act0PracticeGroupV1 group;
  final String title;
  final String subtitle;
  final String reasonLabel;
  final String outcomeLead;
  final String outcome;
  final String masteryLabel;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;

  String? _repeatValueLineV1(BuildContext context) {
    if (group.groupId != 'daily' || !group.isEnabled) {
      return null;
    }
    return _playCopyV1(
      context,
      'play_featured_daily_repeat_value',
      fallback:
          'Tomorrow\'s short set keeps this skill feeling like part of your game.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = group.isEnabled;
    final accentColor = _groupIconColor(group.groupId);
    final repeatValueLine = _repeatValueLineV1(context);
    final metaLine = [
      if (group.sessionLabel.isNotEmpty) group.sessionLabel,
      if (group.durationLabel.isNotEmpty) group.durationLabel,
    ].join(' · ');
    return Opacity(
      opacity: enabled ? 1 : 0.64,
      child: InkWell(
        key: const Key('act0_shell_play_featured_card'),
        onTap: enabled ? () => onStartGroup(group) : null,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                accentColor.withOpacity(0.24),
                accentColor.withOpacity(0.08),
                Act0ShellTokensV1.surface,
                Act0ShellTokensV1.surface2,
              ],
            ),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
            border: Border.all(
              color: enabled
                  ? accentColor.withOpacity(0.38)
                  : Act0ShellTokensV1.border,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accentColor.withOpacity(enabled ? 0.14 : 0.06),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -34,
                right: -24,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.10),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 2,
                    width: 96,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          accentColor.withOpacity(0.9),
                          Act0ShellTokensV1.gold.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(
                                      Act0ShellTokensV1.radiusPill,
                                    ),
                                    border: Border.all(
                                      color: accentColor.withOpacity(0.22),
                                    ),
                                  ),
                                  child: Text(
                                    masteryLabel,
                                    key: const Key(
                                      'act0_shell_play_featured_mastery_label',
                                    ),
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: accentColor,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                if (metaLine.isNotEmpty)
                                  Text(
                                    metaLine,
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: Act0ShellTokensV1.textDim,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: Act0ShellTokensV1.gapSm),
                            Text(
                              title,
                              key: const Key('act0_shell_play_featured_title'),
                              style: Act0ShellTokensV1.sectionTitle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                  Text(
                    subtitle,
                    key: const Key('act0_shell_play_featured_subtitle'),
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                    ),
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapMd),
                  Container(
                    key: const Key('act0_shell_play_featured_reason'),
                    padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.surface2.withOpacity(0.84),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusLg,
                      ),
                      border: Border.all(color: Act0ShellTokensV1.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reasonLabel,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapXs),
                        Text(
                          '$outcomeLead $outcome',
                          key: const Key('act0_shell_play_featured_outcome'),
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (repeatValueLine != null) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapXs),
                          Text(
                            repeatValueLine,
                            key: const Key(
                              'act0_shell_play_featured_repeat_value',
                            ),
                            style: Act0ShellTokensV1.label.copyWith(
                              color: Act0ShellTokensV1.textDim,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapMd),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      key: const Key('act0_shell_play_featured_cta'),
                      onPressed: enabled ? () => onStartGroup(group) : null,
                      style: Act0ShellTokensV1.primaryButtonStyle(
                        height: Act0ShellTokensV1.compactCtaHeight,
                      ),
                      child: Text(_playActionLabelV1(context, group)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayRepairEmptyCardV1 extends StatelessWidget {
  const _PlayRepairEmptyCardV1({required this.localeIsRu});

  final bool localeIsRu;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_play_repair_empty'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.22),
        glow: false,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Act0ShellTokensV1.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _playCopyV1(
                    context,
                    'play_repair_empty_title',
                    fallback: 'Nothing to repair right now.',
                  ),
                  style: Act0ShellTokensV1.body,
                ),
                const SizedBox(height: 2),
                Text(
                  _playCopyV1(
                    context,
                    'play_repair_empty_body',
                    fallback: 'Use Play for extra reps by topic instead.',
                  ),
                  key: const Key('act0_shell_play_repair_empty_body'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayGridIntroV1 extends StatelessWidget {
  const _PlayGridIntroV1({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_play_grid_intro'),
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: Act0ShellTokensV1.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Act0ShellTokensV1.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(child: Text(summary, style: Act0ShellTokensV1.muted)),
        ],
      ),
    );
  }
}

class _PlayIntroCardV1 extends StatelessWidget {
  const _PlayIntroCardV1({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_play_intro_card'),
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Act0ShellTokensV1.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.body,
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayGridSectionV1 extends StatelessWidget {
  const _PlayGridSectionV1({
    required this.sectionKey,
    required this.groups,
    required this.builder,
    this.staggerOddTiles = true,
  });

  final Key sectionKey;
  final List<Act0PracticeGroupV1> groups;
  final Widget Function(Act0PracticeGroupV1 group) builder;
  final bool staggerOddTiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface3.withOpacity(0.74),
        borderColor: Act0ShellTokensV1.border.withOpacity(0.88),
        glow: false,
      ),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = constraints.maxWidth >= 720
              ? 3
              : (constraints.maxWidth >= 320 ? 2 : 1);
          final tileWidth =
              (constraints.maxWidth -
                  (Act0ShellTokensV1.gapSm * (columnCount - 1))) /
              columnCount;
          final diagonalOffset = columnCount == 2 && staggerOddTiles
              ? Act0ShellTokensV1.gapSm + 2
              : 0.0;
          return Wrap(
            spacing: Act0ShellTokensV1.gapSm,
            runSpacing: Act0ShellTokensV1.gapSm,
            children: [
              for (var index = 0; index < groups.length; index += 1)
                SizedBox(
                  width: tileWidth,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: columnCount == 2 && index.isOdd ? diagonalOffset : 0,
                    ),
                    child: builder(groups[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayLaneListV1 extends StatelessWidget {
  const _PlayLaneListV1({
    required this.sectionKey,
    required this.groups,
    required this.builder,
  });

  final Key sectionKey;
  final List<Act0PracticeGroupV1> groups;
  final Widget Function(Act0PracticeGroupV1 group) builder;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
      child: Column(
        children: [
          for (var index = 0; index < groups.length; index += 1) ...[
            builder(groups[index]),
            if (index != groups.length - 1)
              const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
      ),
    );
  }
}

class _PracticeTileCardV1 extends StatelessWidget {
  const _PracticeTileCardV1({required this.group, required this.onStartGroup});

  final Act0PracticeGroupV1 group;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;

  @override
  Widget build(BuildContext context) {
    final enabled = group.isEnabled;
    final accentColor = _groupIconColor(group.groupId);
    final compactSubtitle = switch (group.groupId) {
      'daily' when !enabled => group.subtitle,
      'daily' => _playCopyV1(
        context,
        'play_tile_daily_subtitle',
        fallback: 'One short set to stay warm.',
      ),
      'weak_spots' => _playCopyV1(
        context,
        enabled
            ? 'play_tile_weak_spots_enabled_subtitle'
            : 'play_tile_weak_spots_disabled_subtitle',
        fallback: enabled
            ? 'Fix the mistake that keeps repeating.'
            : 'New mistakes will show up here.',
      ),
      'continue' => _playCopyV1(
        context,
        'play_tile_continue_subtitle',
        fallback: 'Go back to your best next step.',
      ),
      'placement' => _playCopyV1(
        context,
        'play_tile_placement_subtitle',
        fallback: 'Short check before tuning your route.',
      ),
      _ => group.subtitle,
    };
    return Opacity(
      opacity: enabled ? 1 : 0.56,
      child: InkWell(
        key: Key('act0_shell_practice_group_${group.groupId}'),
        onTap: enabled ? () => onStartGroup(group) : null,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface3,
            borderColor: enabled
                ? accentColor.withOpacity(0.28)
                : Act0ShellTokensV1.border,
            glow: false,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GroupIconV1(
                    groupId: group.groupId,
                    colorOverride: accentColor,
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Expanded(
                    child: Text(
                      _playTileBadgeV1(context, group),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: accentColor,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                _playTileTitleV1(context, group),
                style: Act0ShellTokensV1.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 32,
                child: Text(
                  compactSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _playActionLabelV1(context, group),
                      textAlign: TextAlign.left,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: enabled
                            ? accentColor
                            : Act0ShellTokensV1.textDim,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: enabled
                        ? accentColor.withOpacity(0.92)
                        : Act0ShellTokensV1.textDim,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayLaneIntroV1 extends StatelessWidget {
  const _PlayLaneIntroV1({
    required this.localeIsRu,
    required this.selectedTopic,
    required this.visibleLaneCount,
  });

  final bool localeIsRu;
  final String selectedTopic;
  final int visibleLaneCount;

  @override
  Widget build(BuildContext context) {
    final allTopicsLabel = _playCopyV1(
      context,
      'play_all_topics_label',
      fallback: 'All topics',
    );
    final subtitle = selectedTopic == allTopicsLabel
        ? (localeIsRu
              ? '$visibleLaneCount линий готовы. Выбери одну и сделай несколько повторов.'
              : '$visibleLaneCount lanes ready. Pick one and run a few reps.')
        : (localeIsRu
              ? '$visibleLaneCount ${visibleLaneCount == 1 ? 'линия' : 'линии'} внутри темы $selectedTopic.'
              : '$visibleLaneCount ${visibleLaneCount == 1 ? 'lane' : 'lanes'} inside $selectedTopic.');
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: Act0ShellTokensV1.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.info.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Act0ShellTokensV1.info,
              size: 18,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(child: Text(subtitle, style: Act0ShellTokensV1.muted)),
        ],
      ),
    );
  }
}

class _TopicPracticeCardV1 extends StatelessWidget {
  const _TopicPracticeCardV1({required this.group, required this.onStartGroup});

  final Act0PracticeGroupV1 group;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;

  @override
  Widget build(BuildContext context) {
    final enabled = group.isEnabled;
    final accentColor = Act0ShellTokensV1.info;
    final compactSubtitle = !enabled
        ? group.subtitle
        : switch (group.groupId) {
            'placement' => _playCopyV1(
              context,
              'play_topic_placement_subtitle',
              fallback: 'Short check before you tune your route.',
            ),
            'actions' => _playCopyV1(
              context,
              'play_topic_actions_subtitle',
              fallback: 'Read the price and choose the legal action fast.',
            ),
            'blinds' => _playCopyV1(
              context,
              'play_topic_blinds_subtitle',
              fallback: 'Track the blinds and who acts first preflop.',
            ),
            'positions' => _playCopyV1(
              context,
              'play_topic_positions_subtitle',
              fallback: 'Separate early seats from late seats at a glance.',
            ),
            'streets' => _playCopyV1(
              context,
              'play_topic_streets_subtitle',
              fallback:
                  'Follow the hand in order instead of losing the street.',
            ),
            'rankings' => _playCopyV1(
              context,
              'play_topic_rankings_subtitle',
              fallback: 'Choose the best five cards on a real board.',
            ),
            'showdown' => _playCopyV1(
              context,
              'play_topic_showdown_subtitle',
              fallback: 'Compare the final hands and settle the pot cleanly.',
            ),
            _ => group.subtitle,
          };
    return Opacity(
      opacity: enabled ? 0.94 : 0.50,
      child: InkWell(
        key: Key('act0_shell_practice_group_${group.groupId}'),
        onTap: enabled ? () => onStartGroup(group) : null,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface2.withOpacity(0.72),
            borderColor: enabled
                ? accentColor.withOpacity(0.16)
                : Act0ShellTokensV1.border,
            glow: false,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GroupIconV1(groupId: group.groupId),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Expanded(
                    child: Text(
                      _playTileBadgeV1(context, group),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: accentColor.withOpacity(0.88),
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                  if (!enabled)
                    _DisabledPracticeChipV1(
                      keyName:
                          'act0_shell_practice_group_${group.groupId}_disabled_chip',
                      label: _playActionLabelV1(context, group),
                    ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                _playTileTitleV1(context, group),
                style: Act0ShellTokensV1.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 30,
                child: Text(
                  compactSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted,
                ),
              ),
              if (enabled) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _playActionLabelV1(context, group),
                        textAlign: TextAlign.left,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: accentColor.withOpacity(0.90),
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: accentColor.withOpacity(0.92),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeaderV1 extends StatelessWidget {
  const _SectionHeaderV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Act0ShellTokensV1.sectionTitle.copyWith(fontSize: 20),
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
    final metaLine = [
      group.categoryLabel,
      if (group.durationLabel.isNotEmpty) group.durationLabel,
    ].join(' · ');
    final supportLine = [
      if (group.sessionLabel.isNotEmpty) group.sessionLabel,
      if (group.countLabel.isNotEmpty) group.countLabel,
    ].join(' · ');
    return Opacity(
      opacity: enabled ? 1 : 0.56,
      child: InkWell(
        key: Key('act0_shell_practice_group_${group.groupId}'),
        onTap: enabled ? () => onStartGroup(group) : null,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration:
              Act0ShellTokensV1.surfaceDecoration(
                borderColor: enabled
                    ? accentColor.withOpacity(0.36)
                    : Act0ShellTokensV1.border,
                color: Act0ShellTokensV1.surface2,
              ).copyWith(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    enabled
                        ? accentColor.withOpacity(0.08)
                        : Act0ShellTokensV1.surface3.withOpacity(0.72),
                    Act0ShellTokensV1.surface2,
                    Act0ShellTokensV1.surface,
                  ],
                ),
              ),
          child: Row(
            children: [
              _GroupIconV1(groupId: group.groupId),
              const SizedBox(width: Act0ShellTokensV1.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metaLine,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: enabled
                            ? accentColor
                            : Act0ShellTokensV1.textDim,
                        letterSpacing: 0.25,
                      ),
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(group.title, style: Act0ShellTokensV1.cardTitle),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(
                      group.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Act0ShellTokensV1.muted,
                    ),
                    if (supportLine.isNotEmpty) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      Text(
                        supportLine,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.textDim,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              enabled
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _playActionLabelV1(context, group),
                          style: Act0ShellTokensV1.label.copyWith(
                            color: accentColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: accentColor.withOpacity(0.92),
                        ),
                      ],
                    )
                  : _DisabledPracticeChipV1(
                      keyName:
                          'act0_shell_practice_group_${group.groupId}_disabled_chip',
                      label: _playActionLabelV1(context, group),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisabledPracticeChipV1 extends StatelessWidget {
  const _DisabledPracticeChipV1({required this.keyName, required this.label});

  final String keyName;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(keyName),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: Act0ShellTokensV1.border),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.textDim,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _GroupIconV1 extends StatelessWidget {
  const _GroupIconV1({required this.groupId, this.colorOverride});

  final String groupId;
  final Color? colorOverride;

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
    final color = colorOverride ?? _groupIconColor(groupId);
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
