import '../skin/act0_skin_components_v1.dart';
import '../skin/act0_skin_tokens_v1.dart';
import '../act0_shell_state_v1.dart';
import '../act0_curriculum_pilot_v1.dart';
import '../act0_learning_record_card_v1.dart';
import '../act0_w14_skill_state_v1.dart';
import '../act0_skill_progress_v1.dart';
import '../act0_leak_dashboard_v1.dart';
import '../act0_profile_evidence_projection_v1.dart';
import 'package:flutter/material.dart';
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
    this.practiceDaysLastWeek = 0,
    this.earnedMoments = const <Act0AchievementMomentViewModelV1>[],
    this.completedTaskCount,
    this.learningRecord,
    this.bankedRepairCount = 0,
    this.reinforcedRepairCount = 0,
    this.openRepairCount = 0,
    this.dueReviewCount = 0,
    this.worlds = const [],
    this.independentAnswers = 0,
    this.repairedAnswers = 0,
    this.skills = const <Act0W14SkillStateV1>[],
    this.skillProgress = const [],
    this.skillPractice = const {},
    this.openLeakDashboard,
    this.checkedW1Topics = const <String>[],
    this.onOpenReview,
    this.onOpenPractice,
    this.onOpenLearn,
    this.onOpenSettings,
  });

  final String? displayName;
  final String levelLabel;
  final String xpLine;
  final int practiceDaysLastWeek;
  final List<Act0AchievementMomentViewModelV1> earnedMoments;
  final int? completedTaskCount;
  final Act0ProfileEvidenceProjectionV1? learningRecord;
  final int bankedRepairCount;
  final int reinforcedRepairCount;
  final int openRepairCount;
  final int dueReviewCount;
  final List<Act0WorldCardV1> worlds;
  final int independentAnswers;
  final int repairedAnswers;
  final List<Act0W14SkillStateV1> skills;
  final List<Act0SkillProgressV1> skillProgress;
  final Map<String, VoidCallback> skillPractice;
  final Act0LeakDashboardV1? Function()? openLeakDashboard;
  final List<String> checkedW1Topics;
  final VoidCallback? onOpenReview;
  final VoidCallback? onOpenPractice;
  final VoidCallback? onOpenLearn;
  final VoidCallback? onOpenSettings;
}

String _plural(int n, String one, String many) => n == 1 ? one : many;

/// Premium Academy You leaf (You v2.3, Draft PR #314 + #322 truth fix).
class Act0AcademyYouLeafV1 extends StatelessWidget {
  const Act0AcademyYouLeafV1({super.key, required this.input});

  final Act0AcademyYouLeafInputV1 input;

  @override
  Widget build(BuildContext context) {
    final moments = input.earnedMoments
        .where((m) => !act0AcademyYouOpenMistakeSeedIdsV1.contains(m.seedId))
        .toList();
    final fresh =
        input.completedTaskCount == 0 &&
        input.practiceDaysLastWeek == 0 &&
        input.independentAnswers == 0 &&
        input.repairedAnswers == 0 &&
        input.bankedRepairCount == 0 &&
        input.reinforcedRepairCount == 0 &&
        input.openRepairCount == 0 &&
        input.dueReviewCount == 0 &&
        input.checkedW1Topics.isEmpty &&
        moments.isEmpty &&
        !input.skills.any((skill) => skill.answeredTasks > 0) &&
        !(input.learningRecord?.studiedTopics.isNotEmpty ?? false);
    final activity = [
      input.levelLabel.trim(),
      input.xpLine.trim(),
    ].where((value) => value.isNotEmpty).join(' - ');
    final name = input.displayName?.trim() ?? '';
    return ColoredBox(
      key: const Key('act0_academy_you_leaf'),
      color: Act0SkinTokensV1.background,
      child: ListView(
        key: const Key('act0_academy_you_leaf_scroll'),
        padding: const EdgeInsets.all(Act0SkinTokensV1.screenGutter),
        children: [
          Act0SkinScreenHeaderV1(
            title: 'You',
            trailing: input.onOpenSettings == null
                ? null
                : IconButton(
                    key: const Key('act0_academy_you_leaf_settings'),
                    tooltip: 'Settings',
                    onPressed: input.onOpenSettings,
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Act0SkinTokensV1.muted,
                    ),
                  ),
          ),
          const SizedBox(height: Act0SkinTokensV1.gapSm),
          if (fresh)
            const Act0SkinCardV1(
              child: Act0SkinEmptyStateV1(
                title: 'Your journey',
                titleKey: Key('act0_academy_you_leaf_name'),
                description:
                    'Your world and skill progress, independent answers, and repairs will appear here.',
              ),
            )
          else
            Act0SkinCardV1(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (name.isNotEmpty && name != 'New player')
                    Text(
                      name,
                      key: const Key('act0_academy_you_leaf_name'),
                      style: Act0SkinTokensV1.secondary,
                    ),
                  Text(
                    'Course progress',
                    key: name.isEmpty || name == 'New player'
                        ? const Key('act0_academy_you_leaf_name')
                        : null,
                    style: Act0SkinTokensV1.headline,
                  ),
                  const SizedBox(height: Act0SkinTokensV1.gapSm),
                  Text(
                    input.completedTaskCount == null
                        ? 'Your learning, saved'
                        : '${input.completedTaskCount} ${_plural(input.completedTaskCount!, 'task', 'tasks')} completed',
                    key: const Key('act0_academy_you_leaf_tasks'),
                    style: Act0SkinTokensV1.body,
                  ),
                  if (input.worlds.isNotEmpty)
                    _progressDetails('Worlds', [
                      for (final world in input.worlds)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            world.title,
                            style: Act0SkinTokensV1.body,
                          ),
                          subtitle: Text(
                            world.progressLabel,
                            style: Act0SkinTokensV1.secondary,
                          ),
                        ),
                    ]),
                  if (input.skills.isNotEmpty) _skillsDetails(),
                  Act0SkinStatTileV1(
                    label: 'Recent saved decisions',
                    compact: true,
                    value:
                        '${input.independentAnswers} correct without help · ${input.repairedAnswers} repaired',
                  ),
                  if (input.bankedRepairCount > 0)
                    Text(
                      '${input.bankedRepairCount} ${_plural(input.bankedRepairCount, 'mistake', 'mistakes')} corrected',
                      key: const Key('act0_academy_you_leaf_banked'),
                      style: Act0SkinTokensV1.secondary,
                    ),
                  if (input.reinforcedRepairCount > 0)
                    Text(
                      '${input.reinforcedRepairCount} with later supporting evidence',
                      key: const Key('act0_academy_you_leaf_reinforced'),
                      style: Act0SkinTokensV1.secondary,
                    ),
                ],
              ),
            ),
          if (fresh && input.skills.isNotEmpty)
            Act0SkinCardV1(child: _skillsDetails()),
          if (input.skillProgress.isNotEmpty) ...[
            const SizedBox(height: Act0SkinTokensV1.gapMd),
            _skillProgressCard(context),
          ],
          if (activity.isNotEmpty) ...[
            const SizedBox(height: Act0SkinTokensV1.gapMd),
            Text(
              activity,
              key: const Key('act0_academy_you_leaf_level'),
              style: Act0SkinTokensV1.captionStyle,
            ),
          ],
          if (input.practiceDaysLastWeek > 0)
            Text(
              '${input.practiceDaysLastWeek} ${_plural(input.practiceDaysLastWeek, 'day', 'days')} practiced in the last 7 days',
              key: const Key('act0_academy_you_leaf_streak'),
              style: Act0SkinTokensV1.captionStyle,
            ),
          if (!fresh && (activity.isNotEmpty || input.practiceDaysLastWeek > 0))
            Text(
              input.xpLine.trim().isEmpty
                  ? 'This tracks your practice. Try new hands without help to see what you remember.'
                  : 'Level, XP, and practice days track your activity. Try new hands without help to see what you remember.',
              key: const Key('act0_academy_you_leaf_activity_boundary'),
              style: Act0SkinTokensV1.captionStyle,
            ),
          const SizedBox(height: Act0SkinTokensV1.gapMd),
          if (!fresh)
            Text(
              moments.isEmpty ? 'Not earned yet' : '${moments.length} earned',
              style: Act0SkinTokensV1.sectionLabel,
            ),
          for (final moment in moments)
            Act0SkinListRowV1(
              controlKey: Key('act0_academy_you_leaf_moment_${moment.seedId}'),
              title: moment.label,
              subtitle: '',
              onTap: null,
            ),
          if (input.dueReviewCount > 0 || input.openRepairCount > 0)
            Act0SkinListRowV1(
              controlKey: const Key('act0_academy_you_leaf_review'),
              title: input.dueReviewCount > 0
                  ? 'Ready for a recheck'
                  : 'Spots to repair',
              subtitle: [
                if (input.dueReviewCount > 0)
                  '${input.dueReviewCount} ${_plural(input.dueReviewCount, 'review', 'reviews')} due',
                if (input.openRepairCount > 0)
                  '${input.openRepairCount} ${_plural(input.openRepairCount, 'spot', 'spots')} to repair',
              ].join(' - '),
              icon: Icons.history,
              onTap: input.onOpenReview,
            ),
          if (input.onOpenLearn != null)
            Act0SkinListRowV1(
              controlKey: const Key('act0_academy_you_leaf_learn'),
              title: fresh ? 'Start learning' : 'Open Learn',
              subtitle: 'Return to your learning path',
              icon: Icons.school_outlined,
              onTap: input.onOpenLearn,
            ),
          if (!fresh && input.learningRecord != null) ...[
            const SizedBox(height: Act0SkinTokensV1.gapMd),
            Act0LearningRecordCardV1(
              projection: input.learningRecord!,
              onOpenPractice: input.onOpenPractice,
            ),
          ],
        ],
      ),
    );
  }

  Widget _skillProgressCard(BuildContext context) {
    final weak = Act0SkillProgressV1.topNeedsWork(input.skillProgress);
    return Act0SkinCardV1(
      key: const Key('act0_you_skill_progress'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Skills', style: Act0SkinTokensV1.headline),
          const Text(
            'Saved answers, not a mastery score.',
            style: Act0SkinTokensV1.secondary,
          ),
          if (weak.isEmpty)
            Text(
              input.skillProgress.every((skill) => skill.answersNeeded > 0)
                  ? 'Not enough answers yet'
                  : 'No sufficiently sampled skills with misses yet.',
              style: Act0SkinTokensV1.body,
            )
          else
            for (final skill in weak) _skillRow(skill, 'top'),
          _progressDetails('See all', [
            for (final skill in input.skillProgress) _skillRow(skill, 'all'),
          ], key: const Key('act0_you_skill_see_all')),
          if (input.openLeakDashboard != null)
            Act0SkinListRowV1(
              controlKey: const Key('act0_you_skill_leak_dashboard'),
              title: Act0LeakDashboardV1.title,
              onTap: () {
                final dashboard = input.openLeakDashboard!();
                if (dashboard != null) _showLeakDashboard(context, dashboard);
              },
            ),
        ],
      ),
    );
  }

  Widget _skillRow(Act0SkillProgressV1 skill, String section) {
    final launch = skill.needsWork ? input.skillPractice[skill.skill] : null;
    return Act0SkinListRowV1(
      controlKey: Key('act0_you_skill_${section}_${skill.skill}'),
      title: skill.skill,
      subtitle: [
        skill.status,
        skill.counts,
        if (skill.needsWork && launch == null) 'No unlocked drill yet',
      ].join('\n'),
      onTap: launch,
    );
  }

  void _showLeakDashboard(BuildContext context, Act0LeakDashboardV1 dashboard) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Act0SkinTokensV1.background,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Act0SkinTokensV1.screenGutter),
          children: [
            const Act0SkinSheetHeaderV1(title: Act0LeakDashboardV1.title),
            if (dashboard.overall.accuracy == null)
              const Act0SkinEmptyStateV1(
                title: Act0LeakDashboardV1.insufficientDataLabel,
                description: 'More independent first answers are needed.',
              ),
            for (final dimension in Act0LeakDimensionV1.values)
              if (dashboard.breakdown.keys.any(
                (key) => key.$1 == dimension,
              )) ...[
                Text(dimension.name, style: Act0SkinTokensV1.sectionLabel),
                for (final entry in dashboard.breakdown.entries)
                  if (entry.key.$1 == dimension)
                    Act0SkinListRowV1(
                      title: entry.key.$2,
                      subtitle: entry.value.accuracy == null
                          ? Act0LeakDashboardV1.insufficientDataLabel
                          : '${entry.value.correctFirstAttempts} of '
                                '${entry.value.firstAttempts} first answers correct',
                      onTap: null,
                    ),
              ],
          ],
        ),
      ),
    );
  }

  int get _skillMapLastWorld {
    if (!act0CurriculumPilotEnabledV1) return act0SkillMapLastWorldV1;
    final lastWorld = input.worlds.fold<int>(0, (last, world) {
      final number = world.worldNumber;
      return number > last && number <= act0SkillMapLastWorldV1 ? number : last;
    });
    return lastWorld == 0 ? act0SkillMapLastWorldV1 : lastWorld;
  }

  Widget _skillsDetails() => _progressDetails(
    'Skills · W1–W$_skillMapLastWorld',
    [
      if (input.checkedW1Topics.isNotEmpty) ...[
        const Text(
          'Topics checked in the W1 rules check',
          style: Act0SkinTokensV1.body,
        ),
        Text(
          input.checkedW1Topics.join(' · '),
          style: Act0SkinTokensV1.secondary,
        ),
      ],
      for (final skill in input.skills)
        ListTile(
          key: Key('act0_w14_skill_${skill.label}'),
          title: Text(skill.label, style: Act0SkinTokensV1.body),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(skill.stateLabel, style: Act0SkinTokensV1.secondary),
              Text(skill.explanation, style: Act0SkinTokensV1.secondary),
              Text(
                '${skill.lessonCount} ${_plural(skill.lessonCount, 'lesson', 'lessons')} · ${skill.taskCount} tasks',
                style: Act0SkinTokensV1.captionStyle,
              ),
            ],
          ),
        ),
    ],
    key: const Key('act0_w14_skills'),
    subtitle: input.checkedW1Topics.isNotEmpty
        ? 'W1 skipped by rules check'
        : 'Saved answers, not a mastery score.',
  );

  Widget _progressDetails(
    String title,
    List<Widget> children, {
    Key? key,
    String? subtitle,
  }) => ExpansionTile(
    key: key,
    tilePadding: EdgeInsets.zero,
    shape: const Border(),
    collapsedShape: const Border(),
    iconColor: Act0SkinTokensV1.muted,
    collapsedIconColor: Act0SkinTokensV1.muted,
    title: Text(title, style: Act0SkinTokensV1.body),
    subtitle: subtitle == null
        ? null
        : Text(subtitle, style: Act0SkinTokensV1.secondary),
    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );
}
