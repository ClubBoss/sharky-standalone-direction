import 'package:flutter/material.dart';
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

bool _isRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

String _playCopyV1(
  BuildContext context,
  String atomId, {
  required String fallback,
}) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

class Act0PlayShellV1 extends StatefulWidget {
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
    this.screenSubtitle = 'Start one rep. Keep the route moving.',
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
  State<Act0PlayShellV1> createState() => _Act0PlayShellV1State();
}

class _Act0PlayShellV1State extends State<Act0PlayShellV1> {
  String _selectedTopic = 'All topics';

  @override
  Widget build(BuildContext context) {
    final localeIsRu = _isRuLocaleV1(context);
    final allTopicsLabel = localeIsRu ? 'Все темы' : 'All topics';
    final quickDrillGroup = _groupById(widget.groups, 'daily');
    final fixLeakGroup = _groupById(widget.groups, 'weak_spots');
    final topicGroups =
        widget.groups
            .where(
              (group) => !<String>{
                if (quickDrillGroup != null) quickDrillGroup.groupId,
                if (fixLeakGroup != null) fixLeakGroup.groupId,
                'continue',
                'placement',
              }.contains(group.groupId),
            )
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
    final topicFilters =
        <String>{
          allTopicsLabel,
          for (final group in topicGroups) _topicFamilyForGroup(context, group),
        }.toList()..sort(
          (a, b) =>
              _topicFilterSortIndex(a).compareTo(_topicFilterSortIndex(b)),
        );
    if (!topicFilters.contains(_selectedTopic)) {
      _selectedTopic = allTopicsLabel;
    }
    final visibleTopicGroups = _selectedTopic == allTopicsLabel
        ? topicGroups
        : topicGroups
              .where(
                (group) =>
                    _topicFamilyForGroup(context, group) == _selectedTopic,
              )
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
        Text(
          _playCopyV1(context, 'play_title', fallback: 'Play'),
          style: Act0ShellTokensV1.screenTitle,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          _playCopyV1(
            context,
            'play_screen_subtitle',
            fallback: widget.screenSubtitle,
          ),
          key: const Key('act0_shell_play_subtitle'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Act0ShellTokensV1.muted,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),

        if (quickDrillGroup != null) ...[
          _SectionHeaderV1(
            label: _playCopyV1(
              context,
              'play_quick_practice_label',
              fallback: 'Quick practice',
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          _PracticeGroupCardV1(
            group: quickDrillGroup,
            onStartGroup: widget.onStartGroup,
          ),
        ],

        if (fixLeakGroup != null) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _SectionHeaderV1(
            label: _playCopyV1(
              context,
              'play_recommended_repair_label',
              fallback: 'Recommended repair',
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          if (fixLeakGroup.isEnabled)
            _PracticeGroupCardV1(
              group: fixLeakGroup,
              onStartGroup: widget.onStartGroup,
            )
          else
            _PlayRepairEmptyCardV1(localeIsRu: localeIsRu),
        ],

        if (topicGroups.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          _SectionHeaderV1(
            label: _playCopyV1(
              context,
              'play_practice_lanes_label',
              fallback: 'Practice lanes',
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          _PlayLaneIntroV1(
            localeIsRu: localeIsRu,
            selectedTopic: _selectedTopic,
            visibleLaneCount: visibleTopicGroups.length,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Wrap(
            key: const Key('act0_shell_play_topic_filters'),
            spacing: Act0ShellTokensV1.gapSm,
            runSpacing: Act0ShellTokensV1.gapSm,
            children: [
              for (final filter in topicFilters)
                _TopicFilterChipV1(
                  label: filter,
                  selected: _selectedTopic == filter,
                  onTap: () {
                    setState(() {
                      _selectedTopic = filter;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Container(
            key: const Key('act0_shell_play_topic_hub'),
            decoration: Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface2,
            ),
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
            child: Column(
              children: [
                for (var i = 0; i < visibleTopicGroups.length; i++) ...[
                  _TopicPracticeCardV1(
                    group: visibleTopicGroups[i],
                    onStartGroup: widget.onStartGroup,
                  ),
                  if (i < visibleTopicGroups.length - 1)
                    const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
              ],
            ),
          ),
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
    final allTopicsLabel = localeIsRu ? 'Все темы' : 'All topics';
    final subtitle = selectedTopic == allTopicsLabel
        ? (localeIsRu
              ? '$visibleLaneCount линий готовы. Выбери одну и сделай несколько репов.'
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
              borderRadius: BorderRadius.circular(12),
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
    final accentColor = _groupIconColor(group.groupId);
    final topicLabel = switch (group.groupId) {
      'actions' => _playCopyV1(
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
    final supportBits = [
      if (group.countLabel.isNotEmpty) group.countLabel,
      if (group.durationLabel.isNotEmpty) group.durationLabel,
    ];
    return Opacity(
      opacity: enabled ? 1 : 0.56,
      child: InkWell(
        key: Key('act0_shell_practice_group_${group.groupId}'),
        onTap: enabled ? () => onStartGroup(group) : null,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface3,
            borderColor: enabled
                ? accentColor.withOpacity(0.24)
                : Act0ShellTokensV1.border,
            glow: false,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _GroupIconV1(groupId: group.groupId),
                  const SizedBox(width: Act0ShellTokensV1.gapMd),
                  Expanded(
                    child: Wrap(
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
                            color: accentColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusPill,
                            ),
                            border: Border.all(
                              color: accentColor.withOpacity(0.18),
                            ),
                          ),
                          child: Text(
                            topicLabel,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: accentColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        if (supportBits.isNotEmpty)
                          Text(
                            supportBits.join(' · '),
                            style: Act0ShellTokensV1.label.copyWith(
                              color: Act0ShellTokensV1.textDim,
                              letterSpacing: 0.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(group.title, style: Act0ShellTokensV1.cardTitle),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                group.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Act0ShellTokensV1.muted,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.sessionLabel,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.textDim,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Act0ShellTokensV1.gapSm,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: enabled
                          ? accentColor.withOpacity(0.10)
                          : Act0ShellTokensV1.surface2,
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: enabled
                            ? accentColor.withOpacity(0.24)
                            : Act0ShellTokensV1.border,
                      ),
                    ),
                    child: Text(
                      enabled
                          ? group.ctaLabel
                          : _playCopyV1(
                              context,
                              'play_later_cta',
                              fallback: 'Later',
                            ),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: enabled
                            ? accentColor
                            : Act0ShellTokensV1.textDim,
                        letterSpacing: 0.2,
                      ),
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

class _SectionHeaderV1 extends StatelessWidget {
  const _SectionHeaderV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(label, style: Act0ShellTokensV1.sectionTitle)],
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
                    Text(group.subtitle, style: Act0ShellTokensV1.muted),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Act0ShellTokensV1.gapSm,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? accentColor.withOpacity(0.10)
                      : Act0ShellTokensV1.surface3,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(
                    color: enabled
                        ? accentColor.withOpacity(0.24)
                        : Act0ShellTokensV1.border,
                  ),
                ),
                child: Text(
                  enabled
                      ? group.ctaLabel
                      : _playCopyV1(
                          context,
                          'play_later_cta',
                          fallback: 'Later',
                        ),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: enabled ? accentColor : Act0ShellTokensV1.textDim,
                    letterSpacing: 0.2,
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

class _GroupIconV1 extends StatelessWidget {
  const _GroupIconV1({required this.groupId});

  final String groupId;

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
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
