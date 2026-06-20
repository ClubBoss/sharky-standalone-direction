import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

// Quick-action group IDs get blue treatment; repair stays gold as priority tone.
const _kQuickGroupIds = {'continue', 'placement', 'daily', 'weak_spots'};
const _kRepairGroupIds = {'weak_spots'};

Color _groupIconColor(String groupId) {
  if (_kRepairGroupIds.contains(groupId)) return Act0ShellTokensV1.gold;
  if (_kQuickGroupIds.contains(groupId)) return Act0ShellTokensV1.actionBlue;
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
    'daily' =>
      _dailyGroupCompleteV1(group)
          ? group.ctaLabel
          : _playCopyV1(
              context,
              'play_action_start_daily_set',
              fallback: 'Start daily set',
            ),
    'weak_spots' => _playCopyV1(
      context,
      'play_action_practice_repair',
      fallback: 'Practice repair',
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

bool _dailyGroupCompleteV1(Act0PracticeGroupV1 group) =>
    group.groupId == 'daily' &&
    group.sessionLabel.trim().toLowerCase() == 'complete';

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

String _topicPackSubtitleV1(BuildContext context, Act0PracticeGroupV1 group) {
  return switch (group.groupId) {
    'actions' => _playCopyV1(
      context,
      'play_topic_actions_short_subtitle',
      fallback: 'Betting and lines',
    ),
    'blinds' => _playCopyV1(
      context,
      'play_topic_blinds_short_subtitle',
      fallback: 'Reads and ranges',
    ),
    'positions' => _playCopyV1(
      context,
      'play_topic_positions_short_subtitle',
      fallback: 'Seats and spots',
    ),
    'showdown' => _playCopyV1(
      context,
      'play_topic_showdown_short_subtitle',
      fallback: 'Showdown play',
    ),
    'rankings' => _playCopyV1(
      context,
      'play_topic_rankings_short_subtitle',
      fallback: 'Hand strength',
    ),
    'streets' => _playCopyV1(
      context,
      'play_topic_streets_short_subtitle',
      fallback: 'Street order',
    ),
    _ => group.subtitle,
  };
}

List<String> _dailyHeroMetaItemsV1(Act0PracticeGroupV1 group) {
  final countLabel = group.countLabel.trim();
  final sessionLabel = group.sessionLabel.trim();
  final durationLabel = group.durationLabel.trim();
  final items = <String>[];
  final normalizedSession = _normalizedDailySessionMetaV1(sessionLabel);
  final countLooksLikeProgress =
      countLabel.contains('/') && countLabel.toLowerCase().contains('daily');

  if (countLabel.isNotEmpty && !countLooksLikeProgress) {
    items.add(countLabel);
  } else if (normalizedSession != null) {
    items.add(normalizedSession);
  }
  if (durationLabel.isNotEmpty) {
    items.add(durationLabel);
  }
  return items;
}

String? _normalizedDailySessionMetaV1(String sessionLabel) {
  final lower = sessionLabel.toLowerCase();
  final spotCountMatch = RegExp(r'^(\d+)\s+spot').firstMatch(lower);
  if (spotCountMatch == null) return null;
  final count = spotCountMatch.group(1)!;
  return count == '1' ? '1 spot' : '$count spots';
}

Color _topicAccentColorV1(String groupId) {
  return switch (groupId) {
    'actions' => Act0ShellTokensV1.actionCyan,
    'blinds' => Act0ShellTokensV1.actionBlue,
    'positions' => Act0ShellTokensV1.actionCyan,
    'showdown' => Act0ShellTokensV1.gold,
    _ => Act0ShellTokensV1.info,
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
    this.onOpenPremiumPreview,
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
  final VoidCallback? onOpenPremiumPreview;
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
    final recommendedGroup = _groupById(
      widget.groups,
      widget.recommendedGroupId,
    );
    final recommendedRepairGroup =
        recommendedGroup != null &&
        recommendedGroup.isEnabled &&
        _kRepairGroupIds.contains(recommendedGroup.groupId);
    final fallbackFeaturedGroup =
        recommendedGroup ??
        fixLeakGroup ??
        (widget.groups.isEmpty ? null : widget.groups.first);
    final featuredGroup = recommendedRepairGroup
        ? recommendedGroup
        : quickDrillGroup ?? fallbackFeaturedGroup;
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
    final topicShelfGroups = <Act0PracticeGroupV1>[...topicGroups]
      ..sort(
        (a, b) =>
            _topicPreviewSortIndex(a).compareTo(_topicPreviewSortIndex(b)),
      );
    final hasLockedTopicGroups = topicGroups.any((group) => !group.isEnabled);

    return ListView(
      key: const Key('act0_shell_play_screen'),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapMd,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        _PracticeHubHeaderV1(
          title: _playCopyV1(context, 'play_title', fallback: 'Practice'),
        ),
        const SizedBox(height: 12),
        if (featuredGroup != null) ...[
          _DailyTrainingHeroV1(
            group: featuredGroup,
            title: widget.recommendedTitle,
            subtitle: widget.recommendedSubtitle,
            reasonLabel: recommendedRepairGroup
                ? widget.recommendedReasonLabel
                : null,
            onStartGroup: widget.onStartGroup,
          ),
          const SizedBox(height: Act0VisualMetricsV1.sectionGap),
        ],
        if (widget.completionTitle != null &&
            widget.completionBody != null) ...[
          _PlayIntroCardV1(
            title: widget.completionTitle!,
            body: widget.completionBody!,
            onOpenPremiumPreview: widget.onOpenPremiumPreview,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapLg),
        ],
        if (primaryGroups.isNotEmpty ||
            hasRepairEmptyState ||
            topicShelfGroups.isNotEmpty) ...[
          if (primaryGroups.isNotEmpty || hasRepairEmptyState) ...[
            if (primaryGroups.isNotEmpty)
              _QuickRepsSurfaceV1(
                sectionKey: const Key('act0_shell_play_active_hub'),
                groups: primaryGroups.take(2).toList(growable: false),
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
            const SizedBox(height: Act0VisualMetricsV1.sectionGap),
          ],
          if (topicShelfGroups.isNotEmpty) ...[
            _SkillPacksPreviewV1(
              groups: topicShelfGroups.take(4).toList(growable: false),
              showLockedSummary: hasLockedTopicGroups,
              onStartGroup: widget.onStartGroup,
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

  int _topicPreviewSortIndex(Act0PracticeGroupV1 group) {
    return switch (group.groupId) {
      'actions' => 0,
      'blinds' => 1,
      'positions' => 2,
      'showdown' => 3,
      _ => 20 + _topicSortIndex(group),
    };
  }
}

class _PracticeHubHeaderV1 extends StatelessWidget {
  const _PracticeHubHeaderV1({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('act0_shell_play_header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Act0ShellTokensV1.actionBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.actionBlue,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.35,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _playCopyV1(
            context,
            'play_working_hub_headline',
            fallback: 'Sharpen your game',
          ),
          style: Act0ShellTokensV1.sectionTitle.copyWith(
            fontSize: 26,
            height: 1.06,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _playCopyV1(
            context,
            'play_working_hub_support',
            fallback: 'Short reps. Real spots. Stronger decisions.',
          ),
          key: const Key('act0_shell_play_subtitle'),
          style: Act0ShellTokensV1.body.copyWith(
            color: Act0ShellTokensV1.textMuted,
            height: 1.22,
          ),
        ),
      ],
    );
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

class _DailyTrainingHeroV1 extends StatelessWidget {
  const _DailyTrainingHeroV1({
    required this.group,
    required this.title,
    required this.subtitle,
    required this.reasonLabel,
    required this.onStartGroup,
  });

  final Act0PracticeGroupV1 group;
  final String title;
  final String subtitle;
  final String? reasonLabel;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;

  @override
  Widget build(BuildContext context) {
    final enabled = group.isEnabled;
    final isRepairGroup = _kRepairGroupIds.contains(group.groupId);
    final accentColor = isRepairGroup
        ? Act0ShellTokensV1.actionCyan
        : Act0ShellTokensV1.actionBlue;
    final dailyComplete = _dailyGroupCompleteV1(group);
    final heroTitle = group.groupId == 'daily' && !dailyComplete
        ? _playCopyV1(
            context,
            'play_daily_hero_title',
            fallback: 'Quick daily drill',
          )
        : title;
    final heroSubtitle = group.groupId == 'daily' && !dailyComplete
        ? _playCopyV1(
            context,
            'play_daily_hero_support',
            fallback: 'Short spots from completed lessons.',
          )
        : subtitle;
    final metaItems = _dailyHeroMetaItemsV1(group);
    return KeyedSubtree(
      key: const Key('act0_shell_play_v1_featured_premium_card'),
      child: Opacity(
        opacity: enabled ? 1 : 0.64,
        child: InkWell(
          key: const Key('act0_shell_play_featured_card'),
          onTap: enabled ? () => onStartGroup(group) : null,
          borderRadius: BorderRadius.circular(
            Act0VisualMetricsV1.primaryRadius,
          ),
          child: Container(
            key: const Key('act0_shell_play_daily_hero'),
            constraints: const BoxConstraints(minHeight: 214),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration:
                Act0ShellTokensV1.premiumActionSurfaceDecoration(
                  borderOpacity: enabled ? 0.30 : 0.16,
                  glowOpacity: enabled ? 0.16 : 0.06,
                ).copyWith(
                  borderRadius: BorderRadius.circular(
                    Act0VisualMetricsV1.primaryRadius,
                  ),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GroupIconV1(
                      groupId: group.groupId,
                      colorOverride: accentColor,
                      large: true,
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reasonLabel?.trim().isNotEmpty ?? false
                                ? reasonLabel!.trim()
                                : _playCopyV1(
                                    context,
                                    'play_daily_hero_eyebrow',
                                    fallback: 'Today\'s training',
                                  ),
                            key: reasonLabel?.trim().isNotEmpty ?? false
                                ? const Key('act0_shell_play_featured_reason')
                                : null,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: isRepairGroup
                                  ? Act0ShellTokensV1.gold
                                  : Act0ShellTokensV1.actionBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            heroTitle,
                            key: const Key('act0_shell_play_featured_title'),
                            style: Act0ShellTokensV1.sectionTitle.copyWith(
                              fontSize: 22,
                              height: 1.08,
                            ),
                          ),
                          if (metaItems.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                for (final item in metaItems)
                                  Text(
                                    item,
                                    style: Act0ShellTokensV1.body.copyWith(
                                      color: Act0ShellTokensV1.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  heroSubtitle,
                  key: const Key('act0_shell_play_featured_subtitle'),
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    height: 1.24,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _PracticeProofChipV1(
                      icon: Icons.timer_outlined,
                      label: _playCopyV1(
                        context,
                        'play_daily_chip_short_set',
                        fallback: 'Short set',
                      ),
                    ),
                    _PracticeProofChipV1(
                      icon: Icons.menu_book_outlined,
                      label: _playCopyV1(
                        context,
                        'play_daily_chip_no_lesson',
                        fallback: 'No full lesson',
                      ),
                    ),
                    _PracticeProofChipV1(
                      icon: Icons.my_location_rounded,
                      label: _playCopyV1(
                        context,
                        'play_daily_chip_table_reads',
                        fallback: 'Table reads',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  key: const Key('act0_shell_play_v1_featured_action_cta'),
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('act0_shell_play_featured_cta'),
                    onPressed: enabled ? () => onStartGroup(group) : null,
                    style: Act0ShellTokensV1.premiumActionButtonStyle(
                      height: Act0VisualMetricsV1.primaryCtaHeight,
                    ),
                    child: Text(_playActionLabelV1(context, group)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeProofChipV1 extends StatelessWidget {
  const _PracticeProofChipV1({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.62),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.actionCyan.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Act0ShellTokensV1.actionCyan),
          const SizedBox(width: 5),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
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
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.72),
        borderColor: Act0ShellTokensV1.actionBlue.withOpacity(0.18),
        glow: false,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0VisualCanonV1.greenTable.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Act0VisualCanonV1.greenTable,
              size: 20,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
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
                    fallback: 'Use skill packs for extra reps by topic.',
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
  const _PlayIntroCardV1({
    required this.title,
    required this.body,
    this.onOpenPremiumPreview,
  });

  final String title;
  final String body;
  final VoidCallback? onOpenPremiumPreview;

  @override
  Widget build(BuildContext context) {
    final isDailyCompletion = title == 'Session complete';
    return Container(
      key: const Key('act0_shell_play_intro_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: isDailyCompletion
            ? Act0ShellTokensV1.surface3
            : Act0ShellTokensV1.surface2,
        borderColor: isDailyCompletion
            ? Act0ShellTokensV1.primary.withOpacity(0.34)
            : null,
        glow: isDailyCompletion,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isDailyCompletion ? 44 : 38,
            height: isDailyCompletion ? 44 : 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isDailyCompletion
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Act0ShellTokensV1.primary.withOpacity(0.24),
                        Act0ShellTokensV1.info.withOpacity(0.12),
                      ],
                    )
                  : null,
              color: isDailyCompletion
                  ? null
                  : Act0ShellTokensV1.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: isDailyCompletion
                  ? Border.all(
                      color: Act0ShellTokensV1.primary.withOpacity(0.34),
                    )
                  : null,
            ),
            child: Icon(
              isDailyCompletion
                  ? Icons.check_circle_rounded
                  : Icons.bolt_rounded,
              color: Act0ShellTokensV1.primary,
              size: isDailyCompletion ? 22 : 20,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDailyCompletion) ...[
                  _DoneForTodayPillV1(
                    label: _playCopyV1(
                      context,
                      'play_result_done_for_today_label',
                      fallback: 'Done for today',
                    ),
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapXs),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isDailyCompletion
                      ? Act0ShellTokensV1.cardTitle.copyWith(fontSize: 17)
                      : Act0ShellTokensV1.body,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  body,
                  maxLines: isDailyCompletion ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted,
                ),
                if (isDailyCompletion && onOpenPremiumPreview != null) ...[
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                  OutlinedButton(
                    key: const Key('act0_shell_play_premium_preview_entry'),
                    onPressed: onOpenPremiumPreview,
                    style: Act0ShellTokensV1.quietButtonStyle(height: 38),
                    child: const Text('See what premium adds'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneForTodayPillV1 extends StatelessWidget {
  const _DoneForTodayPillV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: Act0ShellTokensV1.primary.withOpacity(0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.done_rounded,
              color: Act0ShellTokensV1.primary,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.textMuted,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayGridSectionV1 extends StatelessWidget {
  const _PlayGridSectionV1({
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
          return Wrap(
            spacing: Act0ShellTokensV1.gapSm,
            runSpacing: Act0ShellTokensV1.gapSm,
            children: [
              for (var index = 0; index < groups.length; index += 1)
                SizedBox(width: tileWidth, child: builder(groups[index])),
            ],
          );
        },
      ),
    );
  }
}

class _QuickRepsSurfaceV1 extends StatelessWidget {
  const _QuickRepsSurfaceV1({
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
        color: Act0ShellTokensV1.surface2.withOpacity(0.72),
        borderColor: Act0ShellTokensV1.actionBlue.withOpacity(0.18),
      ),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _playCopyV1(
              context,
              'play_quick_drills_label',
              fallback: 'Quick reps',
            ),
            style: Act0ShellTokensV1.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
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
              ? '$visibleLaneCount ${_playCopyV1(context, act0RussianPluralV1(visibleLaneCount, 'play_lanes_ready_plural_1', 'play_lanes_ready_plural_2', 'play_lanes_ready_plural_5'), fallback: 'линий готовы')}. Выбери одну и сделай несколько повторов.'
              : '$visibleLaneCount lanes ready. Pick one and run a few reps.')
        : (localeIsRu
              ? '$visibleLaneCount ${_playCopyV1(context, act0RussianPluralV1(visibleLaneCount, 'play_lanes_noun_plural_1', 'play_lanes_noun_plural_2', 'play_lanes_noun_plural_5'), fallback: 'линий')} по теме $selectedTopic.'
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

class _SkillPacksPreviewV1 extends StatelessWidget {
  const _SkillPacksPreviewV1({
    required this.groups,
    required this.showLockedSummary,
    required this.onStartGroup,
  });

  final List<Act0PracticeGroupV1> groups;
  final bool showLockedSummary;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('act0_shell_play_topic_hub'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _playCopyV1(
                  context,
                  'play_topic_packs_label',
                  fallback: 'Skill packs',
                ),
                style: Act0ShellTokensV1.sectionTitle.copyWith(fontSize: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _playCopyV1(
            context,
            'play_skill_pack_unlocks_hint',
            fallback: 'Topic reps unlock as your route grows.',
          ),
          style: Act0ShellTokensV1.body.copyWith(
            color: Act0ShellTokensV1.textMuted,
            height: 1.2,
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = constraints.maxWidth >= 700 ? 4 : 2;
            final tileWidth =
                (constraints.maxWidth -
                    (Act0ShellTokensV1.gapSm * (columnCount - 1))) /
                columnCount;
            return Wrap(
              spacing: Act0ShellTokensV1.gapSm,
              runSpacing: Act0ShellTokensV1.gapSm,
              children: [
                for (final group in groups)
                  SizedBox(
                    width: tileWidth,
                    child: _SkillPackPreviewCardV1(
                      group: group,
                      onStartGroup: onStartGroup,
                    ),
                  ),
              ],
            );
          },
        ),
        if (showLockedSummary) ...[
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          const _LockedPacksSummaryV1(),
        ],
      ],
    );
  }
}

class _SkillPackPreviewCardV1 extends StatelessWidget {
  const _SkillPackPreviewCardV1({
    required this.group,
    required this.onStartGroup,
  });

  final Act0PracticeGroupV1 group;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;

  @override
  Widget build(BuildContext context) {
    final enabled = group.isEnabled;
    final accentColor = _topicAccentColorV1(group.groupId);
    return Opacity(
      opacity: enabled ? 1 : 0.66,
      child: InkWell(
        key: Key('act0_shell_practice_group_${group.groupId}'),
        onTap: enabled ? () => onStartGroup(group) : null,
        borderRadius: BorderRadius.circular(
          Act0VisualMetricsV1.secondaryRadius,
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(10),
          decoration:
              Act0ShellTokensV1.surfaceDecoration(
                color: Act0ShellTokensV1.surface2.withOpacity(
                  enabled ? 0.72 : 0.48,
                ),
                borderColor: enabled
                    ? accentColor.withOpacity(0.24)
                    : Act0ShellTokensV1.border.withOpacity(0.70),
                glow: false,
              ).copyWith(
                borderRadius: BorderRadius.circular(
                  Act0VisualMetricsV1.secondaryRadius,
                ),
              ),
          child: Stack(
            children: [
              if (!enabled)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.lock_rounded,
                    color: Act0ShellTokensV1.textDim,
                    size: 15,
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GroupIconV1(
                    groupId: group.groupId,
                    colorOverride: accentColor,
                    compact: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _playTileTitleV1(context, group),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.cardTitle.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _topicPackSubtitleV1(context, group),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.muted.copyWith(height: 1.18),
                  ),
                  if (enabled) ...[
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: accentColor,
                      size: 17,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedPacksSummaryV1 extends StatelessWidget {
  const _LockedPacksSummaryV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_play_locked_packs_summary'),
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.62),
        borderColor: Act0ShellTokensV1.actionBlue.withOpacity(0.14),
        glow: false,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.textDim.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(color: Act0ShellTokensV1.border),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Act0ShellTokensV1.textMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _playCopyV1(
                    context,
                    'play_locked_packs_summary_title',
                    fallback: 'More packs unlock as you progress',
                  ),
                  style: Act0ShellTokensV1.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _playCopyV1(
                    context,
                    'play_locked_packs_summary_body',
                    fallback:
                        'Keep learning and playing to unlock more topics.',
                  ),
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
  const _GroupIconV1({
    required this.groupId,
    this.colorOverride,
    this.large = false,
    this.compact = false,
  });

  final String groupId;
  final Color? colorOverride;
  final bool large;
  final bool compact;

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
    final size = large ? 38.0 : (compact ? 30.0 : 38.0);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Icon(icon, color: color, size: large ? 20 : (compact ? 17 : 20)),
    );
  }
}
