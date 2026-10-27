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
          const SizedBox(height: 14),
          _surface(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _medallion(Act0AcademyIconographyV1.you, gold, 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fresh ? 'Your journey' : p.playerName,
                        style: const TextStyle(
                          color: text,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fresh
                            ? 'Build your first poker read'
                            : '${p.level} · ${p.xpLine}',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      if (p.streakDays > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${p.streakDays} days · Learning streak',
                            key: const Key('you_v23_streak'),
                            style: const TextStyle(color: gold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _heading(
            moments.isEmpty ? 'Your first earned moment' : 'Earned moments',
            moments.isEmpty ? 'Not earned yet' : '${moments.length} earned',
          ),
          const SizedBox(height: 10),
          if (moments.isEmpty)
            _surface(
              border: gold.withValues(alpha: .4),
              child: Row(
                children: [
                  _medallion(Act0AcademyIconographyV1.recall, muted, 62),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOT EARNED YET',
                          style: TextStyle(
                            color: muted,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'First correct read',
                          style: TextStyle(
                            color: text,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Make your first independent correct decision.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            _moment(moments.first, true),
            if (moments.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 1; i < moments.length; i++) ...[
                    if (i > 1) const SizedBox(width: 10),
                    Expanded(child: _moment(moments[i], false)),
                  ],
                ],
              ),
            ],
          ],
          if (source.youDueCount > 0 || source.youRepairCount > 0) ...[
            const SizedBox(height: 16),
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
          const SizedBox(height: 18),
          _heading(
            fresh ? 'Your record begins here' : 'Your record',
            fresh ? 'Saved as you learn' : 'Saved progress',
          ),
          if (!fresh) ...[
            const SizedBox(height: 10),
            _surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.lessonsLine,
                    key: const Key('you_v23_tasks'),
                    style: const TextStyle(
                      color: text,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Tasks completed',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  if (proof != null && proof.totalBankedFixCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '${proof.totalBankedFixCount} repairs banked',
                        key: const Key('you_v23_banked'),
                        style: const TextStyle(color: text, fontSize: 16),
                      ),
                    ),
                  if (proof != null && proof.reinforcedFixCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${proof.reinforcedFixCount} with later supporting evidence',
                        key: const Key('you_v23_reinforced'),
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _entry(
            key: const Key('you_v23_learn'),
            title: fresh ? 'Start learning' : 'Open Learn',
            subtitle: 'Return to your learning path',
            asset: Act0AcademyIconographyV1.learn,
            onTap: source.onGoToLearn,
          ),
          const SizedBox(height: 20),
          ExpansionTile(
            title: const Text(
              'Learning details',
              style: TextStyle(color: muted, fontSize: 14),
            ),
            iconColor: muted,
            collapsedIconColor: muted,
            children: [
              _ProfileNextMilestoneCardV1(
                profile: p,
                onGoToHome: source.onGoToHome,
              ),
              _ProfileProgressProofCardV1(profile: p, crossSessionProof: proof),
              if (source.evidenceSignal != null)
                _ProfileEvidenceSignalCardV1(signal: source.evidenceSignal!),
              if (p.skillStats.isNotEmpty)
                _ProfileSkillStatsStripV1(profile: p),
              if (p.achievements.isNotEmpty)
                _ProfileMilestonesCardV1(profile: p),
              _ProfileAccountSettingsRowV1(
                onRetakePlacement: source.onRetakePlacement,
                onReplayWelcome: source.onReplayWelcome,
              ),
              if (source.onGoToHome != null)
                TextButton(
                  onPressed: source.onGoToHome,
                  child: const Text('Open Home'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heading(String a, String b) => Row(
    children: [
      Expanded(
        child: Text(
          a,
          style: const TextStyle(
            color: text,
            fontSize: 20,
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
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0B3234), Color(0xFF041E23)],
      ),
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
  Widget _medallion(String asset, Color color, double size) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size / 5),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 2),
      gradient: RadialGradient(colors: [color.withValues(alpha: .25), ink]),
    ),
    child: Act0AcademyGlyphV1(asset: asset, color: color, size: size / 2),
  );
  Widget _moment(Act0AchievementMomentViewModelV1 m, bool featured) {
    final color = featured ? gold : aqua;
    final icon = m.seedId.contains('return') || m.seedId.contains('back')
        ? Act0AcademyIconographyV1.review
        : Act0AcademyIconographyV1.recall;
    return KeyedSubtree(
      key: Key('act0_shell_profile_earned_moment_${m.seedId}'),
      child: _surface(
        border: color.withValues(alpha: .6),
        child: featured
            ? Row(
                children: [
                  _medallion(icon, color, 68),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      m.label,
                      style: const TextStyle(
                        color: text,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _medallion(icon, color, 40),
                  const SizedBox(height: 8),
                  Text(
                    m.label,
                    style: const TextStyle(
                      color: text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.4,
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
