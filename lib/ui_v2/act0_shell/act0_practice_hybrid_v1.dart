import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_iconography_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_north_star_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Owner-selected presentation only. All eligibility/targets remain shell-owned.
const kAct0PracticeHybridV1 = bool.fromEnvironment(
  'SHARKY_PRACTICE_HYBRID_PREVIEW',
);

class Act0PracticeHybridV1 extends StatefulWidget {
  const Act0PracticeHybridV1({
    super.key,
    required this.groups,
    required this.recommendedGroupId,
    required this.recommendedTitle,
    required this.recommendedSubtitle,
    required this.onStartGroup,
    this.onOpenReview,
    this.onOpenLearn,
    this.completionTitle,
    this.completionBody,
  });

  final List<Act0PracticeGroupV1> groups;
  final String recommendedGroupId;
  final String recommendedTitle;
  final String recommendedSubtitle;
  final ValueChanged<Act0PracticeGroupV1> onStartGroup;
  final VoidCallback? onOpenReview;
  final VoidCallback? onOpenLearn;
  final String? completionTitle;
  final String? completionBody;

  @override
  State<Act0PracticeHybridV1> createState() => _Act0PracticeHybridV1State();
}

class _Act0PracticeHybridV1State extends State<Act0PracticeHybridV1> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Resolve exactly the recommendation supplied by the existing source. Never
    // display one group's copy while launching a preferred/fallback group.
    final group = widget.groups
        .where((g) => g.groupId == widget.recommendedGroupId)
        .firstOrNull;
    final canStart = group != null && group.isEnabled;
    // Voluntary daily replay is not proof of improvement or genuinely due work.
    // The existing Complete status controls only this presentation copy.
    final dailyComplete =
        group?.groupId == 'daily' &&
        group?.sessionLabel.trim().toLowerCase() == 'complete';
    final subtitle = dailyComplete
        ? 'Your daily set is complete. Extra reps are optional.'
        : group?.groupId == 'daily' && canStart
        ? 'Short reps from your available practice topics.'
        : widget.recommendedSubtitle;
    final topics = widget.groups
        .where(
          (g) => !const {
            'daily',
            'weak_spots',
            'continue',
            'placement',
          }.contains(g.groupId),
        )
        .toList(growable: false);
    final visibleTopics = _expanded ? topics : topics.take(2).toList();
    return ColoredBox(
      color: Act0HomeNorthStarPaletteV1.ink,
      child: ListView(
        key: const Key('act0_shell_play_screen'),
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        children: [
          SizedBox(
            height: 224,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  left: -14,
                  right: -14,
                  top: 0,
                  bottom: -18,
                  child: ExcludeSemantics(
                    child: Image(
                      image: AssetImage(
                        'assets/design/sharky/home/poker_lounge_reference_v2.png',
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
                const Positioned.fill(
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 15, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practice',
                        style: TextStyle(
                          color: Act0HomeNorthStarPaletteV1.text,
                          fontSize: 36,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.8,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Train real decisions.\nBuild your skills step by step.',
                        style: TextStyle(
                          color: Act0HomeNorthStarPaletteV1.textMuted,
                          fontSize: 16,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _surface(
            key: const Key('act0_practice_hybrid_recommendation'),
            emphasized: true,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR NEXT PRACTICE',
                    style: TextStyle(
                      color: Act0HomeNorthStarPaletteV1.aqua,
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
                          widget.recommendedTitle,
                          key: const Key('act0_practice_hybrid_title'),
                          style: const TextStyle(
                            color: Act0HomeNorthStarPaletteV1.text,
                            fontSize: 25,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Act0AcademyGlyphV1(
                        asset: Act0AcademyIconographyV1.practice,
                        color: Act0HomeNorthStarPaletteV1.aquaSoft,
                        size: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Act0HomeNorthStarPaletteV1.textMuted,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 17),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      key: const Key('act0_practice_hybrid_start'),
                      onPressed: canStart
                          ? () => widget.onStartGroup(group)
                          : widget.onOpenLearn,
                      style: FilledButton.styleFrom(
                        backgroundColor: Act0HomeNorthStarPaletteV1.aqua,
                        foregroundColor: Act0HomeNorthStarPaletteV1.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              !canStart
                                  ? 'Continue learning'
                                  : group.groupId == 'weak_spots'
                                  ? 'Practice this spot'
                                  : 'Start practice',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Act0AcademyGlyphV1(
                            asset: Act0AcademyIconographyV1.forward,
                            color: Act0HomeNorthStarPaletteV1.ink,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.completionTitle != null && widget.completionBody != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
              child: Text(
                '${widget.completionTitle}\n${widget.completionBody}',
                style: const TextStyle(
                  color: Act0HomeNorthStarPaletteV1.textMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          if (widget.onOpenReview != null) ...[
            const SizedBox(height: 10),
            _surface(
              child: TextButton(
                key: const Key('act0_practice_hybrid_review'),
                onPressed: widget.onOpenReview,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  minimumSize: const Size(0, 64),
                  foregroundColor: Act0HomeNorthStarPaletteV1.text,
                ),
                child: const Row(
                  children: [
                    Act0AcademyGlyphV1(
                      asset: Act0AcademyIconographyV1.review,
                      color: Act0HomeNorthStarPaletteV1.aquaSoft,
                      size: 26,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Repairs and due checks live here.',
                            style: TextStyle(
                              color: Act0HomeNorthStarPaletteV1.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Act0AcademyGlyphV1(
                      asset: Act0AcademyIconographyV1.forward,
                      color: Act0HomeNorthStarPaletteV1.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (topics.isNotEmpty) ...[
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'PRACTICE BY TOPIC',
                      style: TextStyle(
                        color: Act0HomeNorthStarPaletteV1.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                ),
                if (topics.length > 2)
                  TextButton(
                    key: const Key('act0_practice_hybrid_expand'),
                    onPressed: () => setState(() => _expanded = !_expanded),
                    style: TextButton.styleFrom(
                      foregroundColor: Act0HomeNorthStarPaletteV1.aqua,
                      minimumSize: const Size(64, 44),
                    ),
                    child: Text(_expanded ? 'Show less' : 'See all'),
                  ),
              ],
            ),
            _surface(
              child: Column(
                children: [
                  for (var i = 0; i < visibleTopics.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Act0HomeNorthStarPaletteV1.rule,
                      ),
                    _topic(visibleTopics[i]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _surface({Key? key, required Widget child, bool emphasized = false}) =>
      Container(
        key: key,
        decoration: BoxDecoration(
          color: Act0HomeNorthStarPaletteV1.inkRaised,
          borderRadius: BorderRadius.circular(emphasized ? 22 : 18),
          border: Border.all(
            color: emphasized
                ? const Color(0xFF19796F)
                : Act0HomeNorthStarPaletteV1.rule,
          ),
          boxShadow: emphasized
              ? const [
                  BoxShadow(
                    color: Color(0x38000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: child,
      );

  Widget _topic(Act0PracticeGroupV1 group) => TextButton(
    key: Key('act0_practice_hybrid_topic_${group.groupId}'),
    onPressed: group.isEnabled ? () => widget.onStartGroup(group) : null,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      minimumSize: const Size(0, 64),
      foregroundColor: Act0HomeNorthStarPaletteV1.text,
      disabledForegroundColor: Act0HomeNorthStarPaletteV1.textMuted,
    ),
    child: Row(
      children: [
        Act0AcademyGlyphV1(
          asset: Act0AcademyIconographyV1.practice,
          color: group.isEnabled
              ? Act0HomeNorthStarPaletteV1.aquaSoft
              : Act0HomeNorthStarPaletteV1.textMuted,
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
                  color: Act0HomeNorthStarPaletteV1.textMuted,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Act0AcademyGlyphV1(
          asset: group.isEnabled
              ? Act0AcademyIconographyV1.forward
              : Act0AcademyIconographyV1.lock,
          color: Act0HomeNorthStarPaletteV1.textMuted,
          size: 18,
        ),
      ],
    ),
  );
}
