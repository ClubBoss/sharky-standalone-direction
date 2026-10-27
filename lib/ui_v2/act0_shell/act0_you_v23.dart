part of 'act0_profile_shell_v1.dart';

const kAct0YouV23Preview = bool.fromEnvironment('SHARKY_YOU_V23_PREVIEW');

bool act0YouV23TargetExists(
  Act0ShellStateV1 state,
  String worldId,
  String lessonId,
  String taskId,
) => state.worlds.any(
  (w) =>
      w.worldId == worldId &&
      w.lessons.any(
        (l) =>
            l.lessonId == lessonId && l.taskList.any((t) => t.taskId == taskId),
      ),
);

class _YouV23 extends StatelessWidget {
  const _YouV23(this.source);
  final Act0ProfileShellV1 source;
  static const ink = Act0HomeNorthStarPaletteV1.ink;
  static const text = Act0HomeNorthStarPaletteV1.text;
  static const muted = Act0HomeNorthStarPaletteV1.textMuted;
  static const aqua = Act0HomeNorthStarPaletteV1.aqua;
  static const gold = Color(0xFFE4BB68);
  @override
  Widget build(BuildContext context) {
    final p = source.profile;
    final moments = source.achievementSeedConsumer.moments;
    final proof = source.crossSessionProof;
    final fresh =
        moments.isEmpty &&
        p.streakDays == 0 &&
        RegExp(r'^0 of ').hasMatch(p.lessonsLine);
    return ColoredBox(
      color: ink,
      child: ListView(
        key: const Key('act0_shell_profile_screen'),
        cacheExtent: 1200,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'You',
                  style: TextStyle(
                    color: text,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Intro & placement',
                onPressed: () => _showFirstStartToolsSheetV1(
                  context,
                  onRetakePlacement: source.onRetakePlacement,
                  onReplayWelcome: source.onReplayWelcome,
                ),
                icon: const Act0AcademyGlyphV1(
                  asset: Act0AcademyIconographyV1.overflow,
                  color: muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _surface(
            child: Row(
              children: [
                _medallion(Act0AcademyIconographyV1.you, gold, 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fresh
                            ? 'Your journey'
                            : p.playerName == 'New player'
                            ? 'Your poker journey'
                            : p.playerName,
                        style: const TextStyle(
                          color: text,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fresh
                            ? 'Build your first poker read'
                            : '${p.level} · ${p.xpLine}',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                      if (p.streakDays > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '${p.streakDays} days · Learning streak',
                            key: const Key('you_v23_streak'),
                            style: const TextStyle(color: gold, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _heading(
            moments.isEmpty ? 'Your first earned moment' : 'Earned moments',
            moments.isEmpty ? 'Not earned yet' : '${moments.length} earned',
          ),
          const SizedBox(height: 9),
          if (moments.isEmpty)
            _featured(
              child: Row(
                children: [
                  _medallion(Act0AcademyIconographyV1.practice, muted, 76),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOT EARNED YET',
                          style: TextStyle(
                            color: muted,
                            fontSize: 9,
                            letterSpacing: 1.3,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'First correct read',
                          style: TextStyle(
                            color: text,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Make your first independent correct decision.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              earned: false,
            )
          else ...[
            _moment(moments.first, true),
            if (moments.length > 1) ...[
              const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 1; i < moments.length; i++) ...[
                      if (i > 1) const SizedBox(width: 8),
                      Expanded(child: _moment(moments[i], false)),
                    ],
                  ],
                ),
              ),
            ],
          ],
          if (source.youDueCount > 0 || source.youRepairCount > 0) ...[
            const SizedBox(height: 12),
            _entry(
              key: const Key('you_v23_review'),
              title: source.youDueCount > 0
                  ? 'Ready for a recheck'
                  : 'Spots to repair',
              subtitle: [
                if (source.youDueCount > 0)
                  '${source.youDueCount} independent review${source.youDueCount == 1 ? '' : 's'} due',
                if (source.youRepairCount > 0)
                  '${source.youRepairCount} spot${source.youRepairCount == 1 ? '' : 's'} to repair',
              ].join(' · '),
              asset: Act0AcademyIconographyV1.review,
              onTap: source.onOpenReview,
            ),
          ],
          const SizedBox(height: 10),
          _heading(
            fresh ? 'Your record begins here' : 'Your record',
            'Saved as you learn',
          ),
          if (!fresh)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Wrap(
                spacing: 14,
                runSpacing: 5,
                children: [
                  Text(
                    p.completedTaskCount == null
                        ? 'Your learning, saved'
                        : '${p.completedTaskCount} task${p.completedTaskCount == 1 ? '' : 's'} completed',
                    style: const TextStyle(color: muted, fontSize: 13),
                  ),
                  if (proof != null && proof.totalBankedFixCount > 0)
                    Text(
                      '${proof.totalBankedFixCount} repairs banked',
                      key: const Key('you_v23_banked'),
                      style: const TextStyle(color: gold, fontSize: 13),
                    ),
                  if (proof != null && proof.reinforcedFixCount > 0)
                    Text(
                      '${proof.reinforcedFixCount} with later supporting evidence',
                      key: const Key('you_v23_reinforced'),
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _entry(
            key: const Key('you_v23_learn'),
            title: fresh ? 'Start learning' : 'Open Learn',
            subtitle: 'Return to your learning path',
            asset: Act0AcademyIconographyV1.learn,
            onTap: source.onGoToLearn,
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text(
              'Learning details',
              style: TextStyle(color: muted, fontSize: 14),
            ),
            iconColor: muted,
            collapsedIconColor: muted,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _detailHeading('Progress & evidence'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        p.lessonsLine,
                        key: const Key('you_v23_tasks'),
                        style: const TextStyle(color: text, fontSize: 16),
                      ),
                    ),
                    if (p.recommendedFocusTitle.isNotEmpty)
                      _detailLine('Current focus', p.recommendedFocusTitle),
                    if (p.recommendedFocusBody.isNotEmpty)
                      _detailLine('Learning path', p.recommendedFocusBody),
                    if (source.evidenceSignal != null)
                      _detailLine(
                        source.evidenceSignal!.skillLabel,
                        source.evidenceSignal!.proofLine,
                      ),
                    if (proof != null && proof.hasProof) ...[
                      _detailLine(
                        'Repair record',
                        '${proof.totalBankedFixCount} repairs banked · ${proof.reinforcedFixCount} with later supporting evidence',
                      ),
                      for (final item in proof.recentProofItems)
                        _detailLine(
                          _profileCopyV1(
                            context,
                            atomId: item.conceptLabelKey,
                            fallback: 'Recorded repair',
                          ),
                          item.isReinforced
                              ? 'Later supporting evidence recorded'
                              : 'Repair completed',
                        ),
                    ],
                    for (final gain in p.recentSkillGains)
                      _detailLine(gain.label, gain.source),
                    if (p.skillStats.isNotEmpty) ...[
                      _detailHeading('Skills'),
                      for (final stat in p.skillStats)
                        _detailAction(
                          onPressed: () =>
                              _showSkillDetailsSheet(context, stat),
                          label: stat.label,
                        ),
                      _detailAction(
                        onPressed: () =>
                            _showAllSkillsSheet(context, p.skillStats, {
                              for (final gain in _dedupedRecentSkillGainsV1(
                                p.recentSkillGains,
                              ))
                                gain.label: gain,
                            }),
                        label: 'View all skills',
                      ),
                    ],
                    _detailHeading('Your tools'),
                    if (p.achievements.isNotEmpty)
                      _detailAction(
                        onPressed: () => _showAchievementsSheet(context, p),
                        label: 'View achievements',
                      ),
                    if (p.streakLast7.isNotEmpty)
                      _detailAction(
                        onPressed: () => _showRhythmWeekSheet(context, p),
                        label: 'View week',
                      ),
                    _detailAction(
                      onPressed: () => _showFirstStartToolsSheetV1(
                        context,
                        onRetakePlacement: source.onRetakePlacement,
                        onReplayWelcome: source.onReplayWelcome,
                      ),
                      label: 'Intro & placement',
                    ),
                    if (source.onGoToHome != null)
                      _detailAction(
                        onPressed: source.onGoToHome!,
                        label: 'Open Home',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailHeading(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      title,
      style: const TextStyle(
        color: aqua,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: .6,
      ),
    ),
  );
  Widget _detailAction({
    required String label,
    required VoidCallback onPressed,
  }) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 10),
      minimumSize: const Size(0, 48),
      shape: const RoundedRectangleBorder(),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: text, fontSize: 14)),
        ),
        const Act0AcademyGlyphV1(
          asset: Act0AcademyIconographyV1.forward,
          color: muted,
          size: 16,
        ),
      ],
    ),
  );
  Widget _detailLine(String title, String body) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          body,
          style: const TextStyle(color: text, fontSize: 14, height: 1.4),
        ),
      ],
    ),
  );

  Widget _heading(String a, String b) => Row(
    children: [
      Expanded(
        child: Text(
          a,
          style: const TextStyle(
            color: text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        b,
        style: const TextStyle(
          color: Act0HomeNorthStarPaletteV1.aquaSoft,
          fontSize: 11,
        ),
      ),
    ],
  );
  Widget _surface({
    required Widget child,
    Color border = const Color(0xFF24605A),
  }) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0B3234), Color(0xFF041E23)],
      ),
      border: Border.all(color: border.withValues(alpha: .5)),
      borderRadius: BorderRadius.circular(17),
    ),
    child: child,
  );
  Widget _featured({required Widget child, bool earned = true}) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: gold.withValues(alpha: earned ? .7 : .3)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: earned
            ? const [Color(0xFF66502C), Color(0xFF263E36), Color(0xFF092A2C)]
            : const [Color(0xFF1D3434), Color(0xFF0A2529)],
      ),
      boxShadow: [
        BoxShadow(
          color: gold.withValues(alpha: earned ? .07 : 0),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
  Widget _medallion(String asset, Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: SweepGradient(
        colors: [
          color.withValues(alpha: .35),
          color,
          const Color(0xFFFAF0C3),
          color.withValues(alpha: .4),
          color,
        ],
      ),
      boxShadow: [
        BoxShadow(color: color.withValues(alpha: .18), blurRadius: 14),
      ],
    ),
    padding: EdgeInsets.all(size * .055),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: .7),
          width: size * .025,
        ),
        gradient: RadialGradient(
          center: const Alignment(-.4, -.5),
          colors: [
            color.withValues(alpha: .6),
            const Color(0xFF16312F),
            const Color(0xFF071B20),
          ],
        ),
      ),
      padding: EdgeInsets.all(size * .16),
      child: Act0AcademyGlyphV1(asset: asset, color: color, size: size / 2),
    ),
  );
  Widget _moment(Act0AchievementMomentViewModelV1 m, bool featured) {
    final color = featured
        ? gold
        : m.seedId == act0AchievementSeedFirstSessionCompleteV1
        ? const Color(0xFF7BACD9)
        : const Color(0xFF65C9BA);
    final icon = switch (m.seedId) {
      act0AchievementSeedFirstCorrectReadV1 =>
        Act0AcademyIconographyV1.practice,
      act0AchievementSeedFirstRepairNoteV1 ||
      act0AchievementSeedFirstReviewHistoryItemV1 =>
        Act0AcademyIconographyV1.review,
      act0AchievementSeedFirstSessionCompleteV1 =>
        Act0AcademyIconographyV1.learn,
      _ => Act0AcademyIconographyV1.recall,
    };
    final contents = Row(
      children: [
        _medallion(icon, color, featured ? 76 : 42),
        SizedBox(width: featured ? 14 : 8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (featured)
                const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    'EARNED MOMENT',
                    style: TextStyle(
                      color: gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
              Text(
                m.label,
                style: TextStyle(
                  color: text,
                  fontSize: featured ? 20 : 13,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              if (featured && m.seedId == act0AchievementSeedFirstCorrectReadV1)
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'An independent correct decision',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    return KeyedSubtree(
      key: Key('act0_shell_profile_earned_moment_${m.seedId}'),
      child: featured
          ? _featured(child: contents)
          : Container(
              constraints: const BoxConstraints(minHeight: 78),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: .17),
                    const Color(0xFF062329),
                  ],
                ),
                border: Border.all(color: color.withValues(alpha: .3)),
              ),
              child: contents,
            ),
    );
  }

  Widget _entry({
    required Key key,
    required String title,
    required String subtitle,
    required String asset,
    VoidCallback? onTap,
  }) => _surface(
    child: TextButton(
      key: key,
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 48),
      ),
      child: Row(
        children: [
          Act0AcademyGlyphV1(asset: asset, color: aqua, size: 25),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Act0AcademyGlyphV1(
            asset: Act0AcademyIconographyV1.forward,
            color: aqua,
            size: 20,
          ),
        ],
      ),
    ),
  );
}
