import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_components_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0SharkyMoodV1;

typedef _T = Act0ClubNightTokensV1;

/// Visual label for an EXISTING source-owned recommendation, not a daily
/// engine. Provenance: Draft PR #308 `Act0HomeTrainingPhaseV1`.
enum Act0AcademyHomePhaseV1 { recall, learn, apply }

/// One already-resolved next action. The leaf never decides what is next;
/// the caller passes the shell's own recommendation and its own callback.
class Act0AcademyHomeNextActionV1 {
  const Act0AcademyHomeNextActionV1({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onPressed;
}

/// Source-owned Home inputs. Every field maps to an accepted model value:
/// - [streakDays]: `Act0ShellStateV1.streakDays`.
/// - [mood]: `Act0SharkyCueV1.preSessionMood`.
/// - [earnedLessonCount]/[courseLessonCount]: earned lesson completion for
///   the selected world (NOT routing or Placement closure). `null` hides the
///   numeric claim entirely.
/// - [phase]: projection of the existing recommendation; `null` marks no
///   stage as current.
/// - [nextAction]: `null` when the source has no launchable next step; the
///   leaf then shows no CTA instead of inventing one.
class Act0AcademyHomeLeafInputV1 {
  const Act0AcademyHomeLeafInputV1({
    required this.courseTitle,
    required this.streakDays,
    required this.mood,
    this.nextAction,
    this.earnedLessonCount,
    this.courseLessonCount,
    this.phase,
    this.backdrop,
    this.onOpenDevMenu,
    this.onStartDailyPractice,
    this.dayGoalDone,
    this.returningAfterBreak = false,
    this.resumeLabel,
    this.onResumeLesson,
  });

  final String courseTitle;
  final int streakDays;
  final Act0SharkyMoodV1 mood;
  final Act0AcademyHomeNextActionV1? nextAction;
  final int? earnedLessonCount;
  final int? courseLessonCount;
  final Act0AcademyHomePhaseV1? phase;
  final ImageProvider? backdrop;
  final VoidCallback? onOpenDevMenu;
  final VoidCallback? onStartDailyPractice;
  final bool? dayGoalDone;
  final bool returningAfterBreak;
  final String? resumeLabel;
  final VoidCallback? onResumeLesson;
}

/// Validated earned progress. Invalid or missing counts produce `null` so no
/// percentage or "x of y" claim is rendered.
class Act0AcademyHomeProgressV1 {
  const Act0AcademyHomeProgressV1._(this.earned, this.total);

  final int earned;
  final int total;

  double get ratio => (earned / total).clamp(0, 1).toDouble();
  int get percent => (ratio * 100).round();

  static Act0AcademyHomeProgressV1? fromCounts(int? earned, int? total) {
    if (earned == null ||
        total == null ||
        earned < 0 ||
        total <= 0 ||
        earned > total) {
      return null;
    }
    return Act0AcademyHomeProgressV1._(earned, total);
  }
}

/// Home renders the source-owned next action, with its artwork in a
/// separate area of the card. The photo stacks above the details at larger
/// text sizes.
class Act0AcademyHomeLeafV1 extends StatelessWidget {
  const Act0AcademyHomeLeafV1({super.key, required this.input});

  final Act0AcademyHomeLeafInputV1 input;

  @override
  Widget build(BuildContext context) {
    final progress = Act0AcademyHomeProgressV1.fromCounts(
      input.earnedLessonCount,
      input.courseLessonCount,
    );
    final next = input.nextAction;
    final resume = input.onResumeLesson;
    final resumeLabel = input.resumeLabel;
    return ColoredBox(
      key: const Key('act0_academy_home_leaf'),
      color: _T.wall,
      child: Act0ClubTextScaleV1(
        key: input.backdrop == null
            ? const Key('act0_academy_leaf_backdrop_fallback')
            : null,
        child: ListView(
          key: const Key('act0_academy_home_leaf_scroll'),
          padding: const EdgeInsets.fromLTRB(
            _T.screenGutter,
            _T.gapLg,
            _T.screenGutter,
            _T.gapXl,
          ),
          children: [
            _HomeHeaderV1(
              returningAfterBreak: input.returningAfterBreak,
              streakDays: input.streakDays,
              onOpenDevMenu: input.onOpenDevMenu,
            ),
            if (input.dayGoalDone == null) ...[
              const SizedBox(height: _T.gapXl),
              _LearningCycleV1(currentPhase: input.phase),
            ],
            if (next != null) ...[
              const SizedBox(height: _T.gapXl),
              _NextActionCardV1(action: next, cover: input.backdrop),
            ] else if (input.backdrop case final artwork?) ...[
              const SizedBox(height: _T.gapXl),
              _NextActionArtworkV1(image: artwork, sideBySide: false),
            ],
            if (resume != null && resumeLabel != null) ...[
              const SizedBox(height: _T.gapMd),
              _ResumeLessonRowV1(label: resumeLabel, onPressed: resume),
            ],
            if (input.dayGoalDone case final done?) ...[
              const SizedBox(height: _T.gapXl),
              _DayGoalV1(done: done),
            ],
            if (input.onStartDailyPractice != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('act0_home_daily_practice'),
                  onPressed: input.onStartDailyPractice,
                  style: TextButton.styleFrom(
                    foregroundColor: _T.text,
                    minimumSize: const Size(_T.minTouch, _T.minTouch),
                    textStyle: _T.link,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Daily practice'),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: _T.gapXl),
            _CourseProgressCardV1(
              courseTitle: input.courseTitle,
              progress: progress,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeaderV1 extends StatelessWidget {
  const _HomeHeaderV1({
    required this.returningAfterBreak,
    required this.streakDays,
    this.onOpenDevMenu,
  });

  final bool returningAfterBreak;
  final int streakDays;
  final VoidCallback? onOpenDevMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('act0_academy_home_leaf_identity_row'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                returningAfterBreak ? 'Welcome back' : 'Welcome,',
                style: _T.captionStyle,
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text("Let's learn", style: _T.title),
              ),
              const SizedBox(height: 2),
              const Text('Build your poker edge.', style: _T.secondary),
            ],
          ),
        ),
        if (streakDays > 0)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Semantics(
              label: '$streakDays day streak',
              excludeSemantics: true,
              child: KeyedSubtree(
                key: const Key('act0_academy_home_leaf_streak'),
                child: Act0ClubTagV1(
                  label: '$streakDays ${streakDays == 1 ? 'day' : 'days'}',
                  tone: Act0ClubTagToneV1.neutral,
                ),
              ),
            ),
          ),
        if (onOpenDevMenu != null)
          IconButton(
            key: const Key('act0_academy_home_leaf_dev_menu'),
            onPressed: onOpenDevMenu,
            tooltip: 'Dev menu',
            constraints: const BoxConstraints.tightFor(
              width: _T.minTouch,
              height: _T.minTouch,
            ),
            icon: const Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.overflow,
              color: _T.caption,
            ),
          ),
      ],
    );
  }
}

class _NextActionCardV1 extends StatelessWidget {
  const _NextActionCardV1({required this.action, this.cover});

  final Act0AcademyHomeNextActionV1 action;
  final ImageProvider? cover;

  @override
  Widget build(BuildContext context) {
    return Act0ClubCardV1(
      key: const Key('act0_academy_home_leaf_next_card'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final image = cover;
          final sideBySide =
              constraints.maxWidth >= 284 &&
              MediaQuery.textScalerOf(context).scale(16) <= 17;
          final art = image == null
              ? null
              : _NextActionArtworkV1(image: image, sideBySide: sideBySide);
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your next step', style: _T.sectionLabel),
              const SizedBox(height: _T.gapSm),
              Text(
                action.title,
                key: const Key('act0_academy_home_leaf_next_title'),
                style: _T.question.copyWith(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: _T.gapSm),
              Text(
                action.subtitle,
                key: const Key('act0_academy_home_leaf_next_subtitle'),
                style: _T.secondary,
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (art != null && sideBySide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: _T.gapMd),
                    art,
                  ],
                )
              else ...[
                if (art != null) ...[art, const SizedBox(height: _T.gapLg)],
                details,
              ],
              const SizedBox(height: _T.gapLg),
              Act0ClubButtonsV1.primary(
                key: const Key('act0_academy_home_leaf_cta'),
                label: action.ctaLabel,
                onPressed: action.onPressed,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NextActionArtworkV1 extends StatelessWidget {
  const _NextActionArtworkV1({required this.image, required this.sideBySide});

  final ImageProvider image;
  final bool sideBySide;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_T.radiusControl),
      child: SizedBox(
        width: sideBySide ? 104 : double.infinity,
        height: sideBySide ? 122 : 136,
        child: Act0AcademyLeafBackdropV1(
          image: image,
          alignment: const Alignment(0.76, 0.17),
        ),
      ),
    );
  }
}

class _ResumeLessonRowV1 extends StatelessWidget {
  const _ResumeLessonRowV1({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_T.radiusCard);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        key: const Key('act0_home_resume_lesson'),
        onTap: onPressed,
        borderRadius: radius,
        child: Semantics(
          button: true,
          child: Act0ClubCardV1(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                Expanded(child: Text(label, style: _T.headline)),
                const SizedBox(width: _T.gapMd),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _T.caption,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayGoalV1 extends StatelessWidget {
  const _DayGoalV1({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _T.gapXs),
      child: Row(
        children: [
          SizedBox.square(
            dimension: _T.minTouch,
            child: ExcludeSemantics(
              child: CircularProgressIndicator(
                key: const Key('act0_home_today_goal_ring'),
                value: done ? 1 : 0,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                color: _T.brass,
                backgroundColor: _T.track,
              ),
            ),
          ),
          const SizedBox(width: _T.gapLg),
          Expanded(
            child: Text(
              done
                  ? 'Today’s goal complete'
                  : 'Today’s goal: one lesson or review',
              key: const Key('act0_home_today_goal'),
              style: _T.headline.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCycleV1 extends StatelessWidget {
  const _LearningCycleV1({required this.currentPhase});

  final Act0AcademyHomePhaseV1? currentPhase;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Learning guide, in order: Recall, Learn, Apply. '
          'No step is marked complete.',
      child: Stack(
        children: [
          const Positioned(
            top: 21,
            left: 60,
            right: 60,
            child: SizedBox(height: 2, child: ColoredBox(color: _T.track)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CycleStageV1(
                number: 1,
                isCurrent: currentPhase == Act0AcademyHomePhaseV1.recall,
                label: 'Recall',
                description: 'Past lesson',
                glyph: Act0AcademyLeafGlyphKindV1.recall,
              ),
              _CycleStageV1(
                number: 2,
                isCurrent: currentPhase == Act0AcademyHomePhaseV1.learn,
                label: 'Learn',
                description: 'New concept',
                glyph: Act0AcademyLeafGlyphKindV1.learn,
              ),
              _CycleStageV1(
                number: 3,
                isCurrent: currentPhase == Act0AcademyHomePhaseV1.apply,
                label: 'Apply',
                description: 'Try a hand',
                glyph: Act0AcademyLeafGlyphKindV1.practice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CycleStageV1 extends StatelessWidget {
  const _CycleStageV1({
    required this.number,
    required this.isCurrent,
    required this.label,
    required this.description,
    required this.glyph,
  });

  final int number;
  final bool isCurrent;
  final String label;
  final String description;
  final Act0AcademyLeafGlyphKindV1 glyph;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: isCurrent
            ? 'Current training phase: $label'
            : 'Step $number, $label',
        child: Column(
          children: [
            Container(
              key: Key('act0_academy_home_leaf_stage_$number'),
              width: _T.minTouch,
              height: _T.minTouch,
              decoration: BoxDecoration(
                color: _T.raised,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? _T.text : _T.hairlineStrong,
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Act0AcademyLeafGlyphV1(
                key: isCurrent
                    ? Key('act0_academy_home_leaf_active_stage_$number')
                    : null,
                kind: glyph,
                color: isCurrent ? _T.text : _T.caption,
                size: 22,
              ),
            ),
            const SizedBox(height: _T.gapSm),
            Text(
              label,
              maxLines: 1,
              style: _T.sectionLabel.copyWith(
                color: isCurrent ? _T.text : _T.text2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _T.captionStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseProgressCardV1 extends StatelessWidget {
  const _CourseProgressCardV1({
    required this.courseTitle,
    required this.progress,
  });

  final String courseTitle;
  final Act0AcademyHomeProgressV1? progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    return Act0ClubCardV1(
      key: const Key('act0_academy_home_leaf_course_progress'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  courseTitle,
                  key: const Key('act0_academy_home_leaf_course_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _T.headline,
                ),
              ),
              if (p != null)
                Text(
                  '${p.percent}%',
                  key: const Key('act0_academy_home_leaf_percent'),
                  style: _T.headline.copyWith(fontFeatures: _T.tabular),
                ),
            ],
          ),
          if (p != null) ...[
            const SizedBox(height: 2),
            Text(
              '${p.earned} of ${p.total} lessons complete',
              key: const Key('act0_academy_home_leaf_progress_label'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _T.captionStyle.copyWith(fontFeatures: _T.tabular),
            ),
          ],
          const SizedBox(height: _T.gapMd),
          // A missing/invalid count draws an empty decorative track only;
          // it must not announce "0%" to assistive tech.
          ExcludeSemantics(
            excluding: p == null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                key: const Key('act0_academy_home_leaf_progress_bar'),
                minHeight: 4,
                value: p?.ratio ?? 0,
                semanticsLabel: p == null ? null : 'Course progress',
                semanticsValue: p == null ? null : '${p.percent}%',
                backgroundColor: _T.track,
                color: _T.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
