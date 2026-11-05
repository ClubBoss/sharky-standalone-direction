import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart'
    show act0LocalizedSurfaceAtomV1;
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0PracticeGroupV1;

/// Group ids the shell already treats as non-topic surfaces (mirrors
/// `act0_play_shell_v1.dart` exclusions; Draft PR #311 hybrid).
const Set<String> act0AcademyPracticeNonTopicGroupIdsV1 = {
  'daily',
  'weak_spots',
  'continue',
  'placement',
};

/// Same launchability rule as the accepted Practice shell
/// (`_canLaunchPracticeQueueTargetV1`): only an active-repair target with a
/// complete launch request may expose a repair CTA.
bool act0AcademyPracticeRepairItemLaunchableV1(
  Act0PracticeRepairQueueItemViewModelV1 item,
) {
  final target = item.launchTarget;
  final request = item.launchRequest;
  return item.isLaunchable &&
      target != null &&
      request != null &&
      target.targetType == act0PracticeRepairQueueTargetTypeActiveRepairV1 &&
      request.targetType == act0PracticeRepairQueueTargetTypeActiveRepairV1;
}

/// Source-owned Practice inputs. This leaf is presentation only: it never
/// schedules, filters eligibility, grades or resolves a repair. Groups,
/// recommendation and repair queue come straight from the shell's existing
/// `practiceGroups`, `practiceSurfaceRecommendation` and
/// `Act0PracticeRepairQueueConsumerV1.fromProjection(...)` values, and every
/// press is forwarded unchanged to the shell's own callbacks.
class Act0AcademyPracticeLeafInputV1 {
  const Act0AcademyPracticeLeafInputV1({
    required this.groups,
    required this.recommendedGroupId,
    required this.recommendedTitle,
    required this.recommendedSubtitle,
    required this.onStartGroup,
    this.recommendedReasonLabel = '',
    this.repairQueue = const Act0PracticeRepairQueueConsumerV1(),
    this.onLaunchRepair,
    this.onOpenReview,
    this.onOpenLearn,
    this.completionTitle,
    this.completionBody,
    this.backdrop,
  });

  final List<Act0PracticeGroupV1> groups;
  final String recommendedGroupId;
  final String recommendedTitle;
  final String recommendedSubtitle;
  final String recommendedReasonLabel;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;
  final Act0PracticeRepairQueueConsumerV1 repairQueue;
  final ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>? onLaunchRepair;
  final VoidCallback? onOpenReview;
  final VoidCallback? onOpenLearn;
  final String? completionTitle;
  final String? completionBody;
  final ImageProvider? backdrop;
}

/// Premium Academy Practice leaf (owner-selected cinematic hybrid, Draft PR
/// #311), adapted to keep the accepted repair queue on the surface.
class Act0AcademyPracticeLeafV1 extends StatefulWidget {
  const Act0AcademyPracticeLeafV1({super.key, required this.input});

  final Act0AcademyPracticeLeafInputV1 input;

  @override
  State<Act0AcademyPracticeLeafV1> createState() =>
      _Act0AcademyPracticeLeafV1State();
}

class _Act0AcademyPracticeLeafV1State extends State<Act0AcademyPracticeLeafV1> {
  bool _expanded = false;

  String _copy(String atomId, String fallback) =>
      act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

  @override
  Widget build(BuildContext context) {
    final input = widget.input;
    // Resolve exactly the recommendation the source supplied. Never show one
    // group's copy while launching another.
    final group = input.groups
        .where((g) => g.groupId == input.recommendedGroupId)
        .firstOrNull;
    final canStart = group != null && group.isEnabled;
    final launchableRepair = input.repairQueue.items.any(
      act0AcademyPracticeRepairItemLaunchableV1,
    );
    final repairGroup = input.groups
        .where((g) => g.groupId == 'weak_spots')
        .firstOrNull;
    final showRepairEmpty =
        !input.repairQueue.hasItems &&
        repairGroup != null &&
        !repairGroup.isEnabled;
    // Enabled topics first; source order is otherwise kept (stable). The
    // recommended group is already featured above and is not repeated.
    final topicSource = input.groups
        .where(
          (g) =>
              !act0AcademyPracticeNonTopicGroupIdsV1.contains(g.groupId) &&
              g.groupId != input.recommendedGroupId,
        )
        .toList(growable: false);
    final topics = [
      ...topicSource.where((g) => g.isEnabled),
      ...topicSource.where((g) => !g.isEnabled),
    ];
    // Quick reps mirror the accepted shell: Daily is always reachable and an
    // enabled Weak spots group stays launchable even when it is not the
    // recommendation.
    final quickReps = [
      for (final id in const ['daily', 'weak_spots'])
        ...input.groups.where(
          (g) =>
              g.groupId == id &&
              g.groupId != input.recommendedGroupId &&
              (id == 'daily' || g.isEnabled),
        ),
    ];
    final visibleTopics = _expanded ? topics : topics.take(2).toList();
    final isEmpty = input.groups.isEmpty && !input.repairQueue.hasItems;

    return ColoredBox(
      key: const Key('act0_academy_practice_leaf'),
      color: Act0AcademyLeafPaletteV1.ink,
      child: ListView(
        key: const Key('act0_academy_practice_leaf_scroll'),
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        children: [
          _PracticeHeroV1(
            title: _copy('play_title', 'Practice'),
            backdrop: input.backdrop,
          ),
          if (isEmpty)
            _PracticeEmptyV1(onOpenLearn: input.onOpenLearn)
          else ...[
            if (launchableRepair) ...[
              _RepairQueueSectionV1(
                consumer: input.repairQueue,
                onLaunch: input.onLaunchRepair,
                primary: true,
                ctaLabel: _copy(
                  'play_action_practice_repair',
                  'Practice repair',
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (input.groups.isNotEmpty)
              _RecommendationCardV1(
                title: input.recommendedTitle,
                subtitle: input.recommendedSubtitle,
                reasonLabel:
                    canStart &&
                        group.groupId == 'weak_spots' &&
                        input.recommendedReasonLabel.trim().isNotEmpty
                    ? input.recommendedReasonLabel.trim()
                    : null,
                canStart: canStart,
                secondary: launchableRepair,
                onStart: canStart ? () => input.onStartGroup(group) : null,
                onOpenLearn: input.onOpenLearn,
              ),
            if (input.completionTitle != null && input.completionBody != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                child: Text(
                  '${input.completionTitle}\n${input.completionBody}',
                  key: const Key('act0_academy_practice_leaf_completion'),
                  style: const TextStyle(
                    color: Act0AcademyLeafPaletteV1.textMuted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            if (input.repairQueue.hasItems && !launchableRepair) ...[
              const SizedBox(height: 12),
              _RepairQueueSectionV1(
                consumer: input.repairQueue,
                onLaunch: input.onLaunchRepair,
                primary: false,
                ctaLabel: _copy(
                  'play_action_practice_repair',
                  'Practice repair',
                ),
              ),
            ],
            if (showRepairEmpty) ...[
              const SizedBox(height: 12),
              _RepairEmptyV1(
                title: _copy(
                  'play_repair_empty_title',
                  'Repair unlocks from real misses',
                ),
                body: _copy(
                  'play_repair_empty_body',
                  'Miss a lesson spot and Practice brings back the same clue.',
                ),
              ),
            ],
            if (quickReps.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'QUICK REPS',
                  style: TextStyle(
                    color: Act0AcademyLeafPaletteV1.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              Act0AcademyLeafSurfaceV1(
                key: const Key('act0_academy_practice_leaf_quick_reps'),
                child: Column(
                  children: [
                    for (var i = 0; i < quickReps.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Act0AcademyLeafPaletteV1.rule,
                        ),
                      _TopicRowV1(
                        group: quickReps[i],
                        onStartGroup: input.onStartGroup,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (input.onOpenReview != null) ...[
              const SizedBox(height: 10),
              _ReviewEntryV1(onPressed: input.onOpenReview!),
            ],
            if (topics.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'PRACTICE BY TOPIC',
                        style: TextStyle(
                          color: Act0AcademyLeafPaletteV1.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),
                  if (topics.length > 2)
                    TextButton(
                      key: const Key('act0_academy_practice_leaf_expand'),
                      onPressed: () => setState(() => _expanded = !_expanded),
                      style: TextButton.styleFrom(
                        foregroundColor: Act0AcademyLeafPaletteV1.aqua,
                        minimumSize: const Size(64, 44),
                      ),
                      child: Text(_expanded ? 'Show less' : 'See all'),
                    ),
                ],
              ),
              Act0AcademyLeafSurfaceV1(
                child: Column(
                  children: [
                    for (var i = 0; i < visibleTopics.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Act0AcademyLeafPaletteV1.rule,
                        ),
                      _TopicRowV1(
                        group: visibleTopics[i],
                        onStartGroup: input.onStartGroup,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PracticeHeroV1 extends StatelessWidget {
  const _PracticeHeroV1({required this.title, required this.backdrop});

  final String title;
  final ImageProvider? backdrop;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 204),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -14,
            right: -14,
            top: 0,
            bottom: -18,
            child: Act0AcademyLeafBackdropV1(
              image: backdrop,
              alignment: Alignment.centerRight,
            ),
          ),
          const Positioned(
            left: -14,
            right: -14,
            top: 0,
            bottom: -18,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x28020E13),
                      Color(0x00020E13),
                      Color(0xFF020E13),
                    ],
                    stops: [0, .65, 1],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 15, 0, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  key: const Key('act0_academy_practice_leaf_title'),
                  style: const TextStyle(
                    color: Act0AcademyLeafPaletteV1.text,
                    fontSize: 36,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Train real decisions.\nBuild your skills step by step.',
                  style: TextStyle(
                    color: Act0AcademyLeafPaletteV1.textMuted,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeEmptyV1 extends StatelessWidget {
  const _PracticeEmptyV1({required this.onOpenLearn});

  final VoidCallback? onOpenLearn;

  @override
  Widget build(BuildContext context) {
    return Act0AcademyLeafSurfaceV1(
      key: const Key('act0_academy_practice_leaf_empty'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nothing to practice yet',
              style: TextStyle(
                color: Act0AcademyLeafPaletteV1.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Practice opens from lessons you have played.',
              style: TextStyle(
                color: Act0AcademyLeafPaletteV1.textMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (onOpenLearn != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                key: const Key('act0_academy_practice_leaf_empty_learn'),
                onPressed: onOpenLearn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Act0AcademyLeafPaletteV1.aqua,
                  side: const BorderSide(color: Act0AcademyLeafPaletteV1.teal),
                  minimumSize: const Size(0, 48),
                ),
                child: const Text('Continue learning'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendationCardV1 extends StatelessWidget {
  const _RecommendationCardV1({
    required this.title,
    required this.subtitle,
    required this.reasonLabel,
    required this.canStart,
    required this.secondary,
    required this.onStart,
    required this.onOpenLearn,
  });

  final String title;
  final String subtitle;
  final String? reasonLabel;
  final bool canStart;
  final bool secondary;
  final VoidCallback? onStart;
  final VoidCallback? onOpenLearn;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = canStart ? onStart : onOpenLearn;
    final label = canStart ? 'Start practice' : 'Continue learning';
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Act0AcademyLeafGlyphV1(
          kind: Act0AcademyLeafGlyphKindV1.forward,
          color: secondary
              ? Act0AcademyLeafPaletteV1.aqua
              : Act0AcademyLeafPaletteV1.ink,
          size: 22,
        ),
      ],
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return Act0AcademyLeafSurfaceV1(
      key: const Key('act0_academy_practice_leaf_recommendation'),
      emphasized: !secondary,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YOUR NEXT PRACTICE',
              style: TextStyle(
                color: Act0AcademyLeafPaletteV1.aqua,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    key: const Key('act0_academy_practice_leaf_rec_title'),
                    style: const TextStyle(
                      color: Act0AcademyLeafPaletteV1.text,
                      fontSize: 25,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Act0AcademyLeafGlyphV1(
                  kind: canStart
                      ? Act0AcademyLeafGlyphKindV1.practice
                      : Act0AcademyLeafGlyphKindV1.lock,
                  color: Act0AcademyLeafPaletteV1.aquaSoft,
                  size: 30,
                ),
              ],
            ),
            if (reasonLabel != null) ...[
              const SizedBox(height: 6),
              Text(
                reasonLabel!,
                key: const Key('act0_academy_practice_leaf_rec_reason'),
                style: const TextStyle(
                  color: Act0AcademyLeafPaletteV1.repair,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 9),
            Text(
              subtitle,
              key: const Key('act0_academy_practice_leaf_rec_subtitle'),
              style: const TextStyle(
                color: Act0AcademyLeafPaletteV1.textMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: secondary
                    ? OutlinedButton(
                        key: const Key('act0_academy_practice_leaf_start'),
                        onPressed: action,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Act0AcademyLeafPaletteV1.aqua,
                          side: const BorderSide(
                            color: Act0AcademyLeafPaletteV1.teal,
                          ),
                          shape: shape,
                        ),
                        child: buttonChild,
                      )
                    : FilledButton(
                        key: const Key('act0_academy_practice_leaf_start'),
                        onPressed: action,
                        style: FilledButton.styleFrom(
                          backgroundColor: Act0AcademyLeafPaletteV1.aqua,
                          foregroundColor: Act0AcademyLeafPaletteV1.ink,
                          shape: shape,
                        ),
                        child: buttonChild,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RepairQueueSectionV1 extends StatelessWidget {
  const _RepairQueueSectionV1({
    required this.consumer,
    required this.onLaunch,
    required this.primary,
    required this.ctaLabel,
  });

  final Act0PracticeRepairQueueConsumerV1 consumer;
  final ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>? onLaunch;
  final bool primary;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    final items = consumer.items;
    return Act0AcademyLeafSurfaceV1(
      key: const Key('act0_academy_practice_leaf_repair_queue'),
      emphasized: primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              primary ? 'ACTIVE REPAIR FIRST' : 'OPEN REPAIRS',
              style: const TextStyle(
                color: Act0AcademyLeafPaletteV1.repair,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Unresolved until you answer it on your own.',
              style: TextStyle(
                color: Act0AcademyLeafPaletteV1.textMuted,
                fontSize: 12,
              ),
            ),
            for (var i = 0; i < items.length; i++)
              _RepairRowV1(
                key: Key('act0_academy_practice_leaf_repair_item_$i'),
                item: items[i],
                ctaLabel: ctaLabel,
                onLaunch: onLaunch,
              ),
          ],
        ),
      ),
    );
  }
}

class _RepairRowV1 extends StatelessWidget {
  const _RepairRowV1({
    super.key,
    required this.item,
    required this.ctaLabel,
    required this.onLaunch,
  });

  final Act0PracticeRepairQueueItemViewModelV1 item;
  final String ctaLabel;
  final ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>? onLaunch;

  @override
  Widget build(BuildContext context) {
    final launch = onLaunch;
    final launchable =
        act0AcademyPracticeRepairItemLaunchableV1(item) && launch != null;
    final detail = item.detail;
    final actionLine = item.actionLine;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Act0AcademyLeafGlyphV1(
            kind: Act0AcademyLeafGlyphKindV1.recall,
            color: item.isPinned
                ? Act0AcademyLeafPaletteV1.repair
                : Act0AcademyLeafPaletteV1.textMuted,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Act0AcademyLeafPaletteV1.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Act0AcademyLeafPaletteV1.textMuted,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                if (actionLine != null)
                  Text(
                    actionLine,
                    style: const TextStyle(
                      color: Act0AcademyLeafPaletteV1.textMuted,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          if (launchable) ...[
            const SizedBox(width: 8),
            FilledButton(
              key: Key('act0_academy_practice_leaf_repair_cta_${item.itemId}'),
              onPressed: () => launch(item.launchRequest!),
              style: FilledButton.styleFrom(
                backgroundColor: Act0AcademyLeafPaletteV1.repair,
                foregroundColor: Act0AcademyLeafPaletteV1.ink,
                minimumSize: const Size(0, 44),
              ),
              child: Text(ctaLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _RepairEmptyV1 extends StatelessWidget {
  const _RepairEmptyV1({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Act0AcademyLeafSurfaceV1(
      key: const Key('act0_academy_practice_leaf_repair_empty'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.recall,
              color: Act0AcademyLeafPaletteV1.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Act0AcademyLeafPaletteV1.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Act0AcademyLeafPaletteV1.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewEntryV1 extends StatelessWidget {
  const _ReviewEntryV1({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Act0AcademyLeafSurfaceV1(
      child: TextButton(
        key: const Key('act0_academy_practice_leaf_review'),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          minimumSize: const Size(0, 64),
          foregroundColor: Act0AcademyLeafPaletteV1.text,
        ),
        child: const Row(
          children: [
            Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.review,
              color: Act0AcademyLeafPaletteV1.aquaSoft,
              size: 26,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Repairs and due checks live here.',
                    style: TextStyle(
                      color: Act0AcademyLeafPaletteV1.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.forward,
              color: Act0AcademyLeafPaletteV1.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicRowV1 extends StatelessWidget {
  const _TopicRowV1({required this.group, required this.onStartGroup});

  final Act0PracticeGroupV1 group;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;

  @override
  Widget build(BuildContext context) {
    final enabled = group.isEnabled;
    // The TextButton keeps its own button/tap semantics; a locked row adds a
    // "locked" label to the merged node instead of replacing the action.
    return TextButton(
      key: Key('act0_academy_practice_leaf_topic_${group.groupId}'),
      onPressed: enabled ? () => onStartGroup(group) : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        minimumSize: const Size(0, 64),
        foregroundColor: Act0AcademyLeafPaletteV1.text,
        disabledForegroundColor: Act0AcademyLeafPaletteV1.textMuted,
      ),
      child: Row(
        children: [
          Act0AcademyLeafGlyphV1(
            kind: Act0AcademyLeafGlyphKindV1.practice,
            color: enabled
                ? Act0AcademyLeafPaletteV1.aquaSoft
                : Act0AcademyLeafPaletteV1.textMuted,
            size: 25,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  group.subtitle,
                  style: const TextStyle(
                    color: Act0AcademyLeafPaletteV1.textMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: enabled ? null : 'locked',
            child: Act0AcademyLeafGlyphV1(
              kind: enabled
                  ? Act0AcademyLeafGlyphKindV1.forward
                  : Act0AcademyLeafGlyphKindV1.lock,
              color: Act0AcademyLeafPaletteV1.textMuted,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
