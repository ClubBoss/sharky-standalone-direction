import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';

/// Seeds that record an open mistake or a repair opportunity, not a learner
/// achievement (Draft PR #322 F1 truth fix). They are never shown as earned;
/// the leaf surfaces open repair debt only through [openRepairCount].
const Set<String> act0AcademyYouOpenMistakeSeedIdsV1 = {
  act0AchievementSeedFirstRepairNoteV1,
  act0AchievementSeedFirstReviewHistoryItemV1,
};

/// Builds earned moments from the accepted projection, dropping open-mistake
/// seeds BEFORE the consumer's three-moment cap so later genuinely earned
/// moments are not hidden. Reuses the accepted consumer (labels, order, cap).
List<Act0AchievementMomentViewModelV1> act0AcademyYouEarnedMomentsV1(
  Act0AchievementSeedProjectionV1 projection,
) => Act0AchievementSeedConsumerV1.fromProjection(
  Act0AchievementSeedProjectionV1(
    seeds: projection.seeds
        .where((s) => !act0AcademyYouOpenMistakeSeedIdsV1.contains(s.id))
        .toList(growable: false),
  ),
).moments;

/// Source-owned You inputs.
/// - [earnedMoments]: from [act0AcademyYouEarnedMomentsV1]; open-mistake
///   seeds passed here anyway are filtered again defensively.
/// - [levelLabel]/[xpLine]: existing profile strings; XP is never computed.
/// - [completedTaskCount]: earned task completion; `null` hides the claim.
/// - [bankedRepairCount]/[reinforcedRepairCount]: cross-session proof.
/// - [openRepairCount]/[dueReviewCount]: open debt and genuinely due checks.
class Act0AcademyYouLeafInputV1 {
  const Act0AcademyYouLeafInputV1({
    this.displayName,
    this.levelLabel = '',
    this.xpLine = '',
    this.streakDays = 0,
    this.earnedMoments = const <Act0AchievementMomentViewModelV1>[],
    this.completedTaskCount,
    this.bankedRepairCount = 0,
    this.reinforcedRepairCount = 0,
    this.openRepairCount = 0,
    this.dueReviewCount = 0,
    this.onOpenReview,
    this.onOpenLearn,
    this.onOpenSettings,
  });

  final String? displayName;
  final String levelLabel;
  final String xpLine;
  final int streakDays;
  final List<Act0AchievementMomentViewModelV1> earnedMoments;
  final int? completedTaskCount;
  final int bankedRepairCount;
  final int reinforcedRepairCount;
  final int openRepairCount;
  final int dueReviewCount;
  final VoidCallback? onOpenReview;
  final VoidCallback? onOpenLearn;
  final VoidCallback? onOpenSettings;
}

String _plural(int n, String one, String many) => n == 1 ? one : many;

/// Premium Academy You leaf (You v2.3, Draft PR #314 + #322 truth fix).
class Act0AcademyYouLeafV1 extends StatelessWidget {
  const Act0AcademyYouLeafV1({super.key, required this.input});

  final Act0AcademyYouLeafInputV1 input;

  static const _text = Act0AcademyLeafPaletteV1.text;
  static const _muted = Act0AcademyLeafPaletteV1.textMuted;
  static const _gold = Color(0xFFE4BB68);

  @override
  Widget build(BuildContext context) {
    final moments = input.earnedMoments
        .where((m) => !act0AcademyYouOpenMistakeSeedIdsV1.contains(m.seedId))
        .toList(growable: false);
    final fresh =
        moments.isEmpty &&
        input.streakDays == 0 &&
        (input.completedTaskCount ?? 0) == 0;
    final name = input.displayName?.trim() ?? '';
    final subtitleParts = [
      input.levelLabel.trim(),
      input.xpLine.trim(),
    ].where((s) => s.isNotEmpty).toList();
    return ColoredBox(
      key: const Key('act0_academy_you_leaf'),
      color: Act0AcademyLeafPaletteV1.ink,
      child: ListView(
        key: const Key('act0_academy_you_leaf_scroll'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'You',
                  style: TextStyle(
                    color: _text,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (input.onOpenSettings != null)
                IconButton(
                  key: const Key('act0_academy_you_leaf_settings'),
                  tooltip: 'Settings',
                  onPressed: input.onOpenSettings,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: const Act0AcademyLeafGlyphV1(
                    kind: Act0AcademyLeafGlyphKindV1.settings,
                    color: _muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Act0AcademyLeafSurfaceV1(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _medallion(Act0AcademyLeafGlyphKindV1.you, _gold, 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fresh
                              ? 'Your journey'
                              : name.isEmpty || name == 'New player'
                              ? 'Your poker journey'
                              : name,
                          key: const Key('act0_academy_you_leaf_name'),
                          style: const TextStyle(
                            color: _text,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fresh
                              ? 'Build your first poker read'
                              : subtitleParts.join(' - '),
                          key: const Key('act0_academy_you_leaf_level'),
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                        if (input.streakDays > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              '${input.streakDays} '
                              '${_plural(input.streakDays, 'day', 'days')}'
                              ' - Learning streak',
                              key: const Key('act0_academy_you_leaf_streak'),
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _heading(
            moments.isEmpty ? 'Your first earned moment' : 'Earned moments',
            moments.isEmpty ? 'Not earned yet' : '${moments.length} earned',
          ),
          const SizedBox(height: 9),
          if (moments.isEmpty)
            Act0AcademyLeafSurfaceV1(
              key: const Key('act0_academy_you_leaf_not_earned'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _medallion(Act0AcademyLeafGlyphKindV1.practice, _muted, 64),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOT EARNED YET',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'First correct read',
                            style: TextStyle(
                              color: _text,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Make your first independent correct decision.',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            for (var i = 0; i < moments.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _moment(moments[i], featured: i == 0),
            ],
          if (input.dueReviewCount > 0 || input.openRepairCount > 0) ...[
            const SizedBox(height: 12),
            _entry(
              key: const Key('act0_academy_you_leaf_review'),
              title: input.dueReviewCount > 0
                  ? 'Ready for a recheck'
                  : 'Spots to repair',
              subtitle: [
                if (input.dueReviewCount > 0)
                  '${input.dueReviewCount} independent '
                      '${_plural(input.dueReviewCount, 'review', 'reviews')} due',
                if (input.openRepairCount > 0)
                  '${input.openRepairCount} '
                      '${_plural(input.openRepairCount, 'spot', 'spots')}'
                      ' to repair',
              ].join(' - '),
              glyph: Act0AcademyLeafGlyphKindV1.review,
              onTap: input.onOpenReview,
            ),
          ],
          const SizedBox(height: 10),
          _heading(
            fresh ? 'Your record begins here' : 'Your record',
            'Saved as you learn',
          ),
          if (!fresh)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Wrap(
                spacing: 14,
                runSpacing: 5,
                children: [
                  Text(
                    input.completedTaskCount == null
                        ? 'Your learning, saved'
                        : '${input.completedTaskCount} '
                              '${_plural(input.completedTaskCount!, 'task', 'tasks')}'
                              ' completed',
                    key: const Key('act0_academy_you_leaf_tasks'),
                    style: const TextStyle(color: _text, fontSize: 13),
                  ),
                  if (input.bankedRepairCount > 0)
                    Text(
                      '${input.bankedRepairCount} repairs banked',
                      key: const Key('act0_academy_you_leaf_banked'),
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  if (input.reinforcedRepairCount > 0)
                    Text(
                      '${input.reinforcedRepairCount} with later supporting '
                      'evidence',
                      key: const Key('act0_academy_you_leaf_reinforced'),
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                ],
              ),
            ),
          if (input.onOpenLearn != null) ...[
            const SizedBox(height: 12),
            _entry(
              key: const Key('act0_academy_you_leaf_learn'),
              title: fresh ? 'Start learning' : 'Open Learn',
              subtitle: 'Return to your learning path',
              glyph: Act0AcademyLeafGlyphKindV1.learn,
              onTap: input.onOpenLearn,
            ),
          ],
        ],
      ),
    );
  }

  Widget _medallion(Act0AcademyLeafGlyphKindV1 kind, Color tone, double size) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tone.withValues(alpha: 0.10),
          border: Border.all(color: tone.withValues(alpha: 0.45)),
        ),
        alignment: Alignment.center,
        child: Act0AcademyLeafGlyphV1(kind: kind, color: tone, size: size * .5),
      );

  Widget _heading(String title, String trailing) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(trailing, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    ),
  );

  Widget _moment(
    Act0AchievementMomentViewModelV1 m, {
    required bool featured,
  }) => Act0AcademyLeafSurfaceV1(
    key: Key('act0_academy_you_leaf_moment_${m.seedId}'),
    emphasized: featured,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _medallion(
            Act0AcademyLeafGlyphKindV1.placement,
            _gold,
            featured ? 56 : 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EARNED',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.label,
                  style: TextStyle(
                    color: _text,
                    fontSize: featured ? 18 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _entry({
    required Key key,
    required String title,
    required String subtitle,
    required Act0AcademyLeafGlyphKindV1 glyph,
    VoidCallback? onTap,
  }) => Act0AcademyLeafSurfaceV1(
    child: TextButton(
      key: key,
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        minimumSize: const Size(0, 64),
        foregroundColor: _text,
        disabledForegroundColor: _text,
      ),
      child: Row(
        children: [
          Act0AcademyLeafGlyphV1(
            kind: glyph,
            color: Act0AcademyLeafPaletteV1.aquaSoft,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
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
          if (onTap != null)
            const Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.forward,
              color: _muted,
              size: 18,
            ),
        ],
      ),
    ),
  );
}
