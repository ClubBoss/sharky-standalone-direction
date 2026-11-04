import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0SharkyMoodV1;

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

/// Premium Academy Home leaf (owner-approved immersive Home, Draft PR #308).
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
    return ColoredBox(
      key: const Key('act0_academy_home_leaf'),
      color: Act0AcademyLeafPaletteV1.ink,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Act0AcademyLeafBackdropV1(image: input.backdrop),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00020E13),
                      Color(0x00020E13),
                      Color(0xFF020E13),
                    ],
                    stops: [0, 0.30, 0.47],
                  ),
                ),
              ),
            ),
          ),
          ListView(
            key: const Key('act0_academy_home_leaf_scroll'),
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _HomeHeaderV1(
                  mood: input.mood,
                  streakDays: input.streakDays,
                  onOpenDevMenu: input.onOpenDevMenu,
                ),
              ),
              const SizedBox(height: 20),
              const _HomeGreetingV1(),
              _LearningCycleV1(currentPhase: input.phase),
              const SizedBox(height: 20),
              if (next != null) ...[
                _NextActionCardV1(action: next),
                const SizedBox(height: 10),
              ],
              _CourseProgressStripV1(
                courseTitle: input.courseTitle,
                progress: progress,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeGreetingV1 extends StatelessWidget {
  const _HomeGreetingV1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      // Min height keeps the donor rhythm; text scaling may grow it.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 204),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: TextStyle(
                color: Act0AcademyLeafPaletteV1.textMuted,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Let's learn",
              style: TextStyle(
                color: Act0AcademyLeafPaletteV1.text,
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Build your\npoker edge.',
              style: TextStyle(
                color: Act0AcademyLeafPaletteV1.textMuted,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeaderV1 extends StatelessWidget {
  const _HomeHeaderV1({
    required this.mood,
    required this.streakDays,
    this.onOpenDevMenu,
  });

  final Act0SharkyMoodV1 mood;
  final int streakDays;
  final VoidCallback? onOpenDevMenu;

  @override
  Widget build(BuildContext context) {
    final tone = act0SharkyToneForMoodV1(mood);
    return Row(
      key: const Key('act0_academy_home_leaf_identity_row'),
      children: [
        Container(
          width: 52,
          height: 56,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: tone.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: Act0AcademyLeafPaletteV1.teal.withValues(alpha: 0.18),
                blurRadius: 18,
              ),
            ],
          ),
          child: Act0SharkyPresenceMascotV1(mood: mood, tone: tone, size: 48),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sharky',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Act0AcademyLeafPaletteV1.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Poker Academy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Act0AcademyLeafPaletteV1.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (streakDays > 0)
          Semantics(
            label: '$streakDays day streak',
            excludeSemantics: true,
            child: Container(
              key: const Key('act0_academy_home_leaf_streak'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Act0AcademyLeafPaletteV1.aqua.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Act0AcademyLeafPaletteV1.rule.withValues(alpha: 0.42),
                ),
              ),
              child: Text(
                '$streakDays ${streakDays == 1 ? 'day' : 'days'}',
                maxLines: 1,
                style: const TextStyle(
                  color: Act0AcademyLeafPaletteV1.aquaSoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (onOpenDevMenu != null) ...[
          const SizedBox(width: 4),
          IconButton(
            key: const Key('act0_academy_home_leaf_dev_menu'),
            onPressed: onOpenDevMenu,
            tooltip: 'Dev menu',
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            icon: const Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.overflow,
              color: Act0AcademyLeafPaletteV1.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _NextActionCardV1 extends StatelessWidget {
  const _NextActionCardV1({required this.action});

  final Act0AcademyHomeNextActionV1 action;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_academy_home_leaf_next_card'),
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xB2082128), Color(0xC005141C)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x4043D9D0), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR NEXT STEP',
            maxLines: 1,
            style: TextStyle(
              color: Act0AcademyLeafPaletteV1.aqua,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.title,
            key: const Key('act0_academy_home_leaf_next_title'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Act0AcademyLeafPaletteV1.text,
              fontSize: 25,
              height: 1.08,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            action.subtitle,
            key: const Key('act0_academy_home_leaf_next_subtitle'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Act0AcademyLeafPaletteV1.textMuted,
              fontSize: 15,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF43ECDD), Color(0xFF00D6C9)],
                ),
              ),
              child: FilledButton.icon(
                key: const Key('act0_academy_home_leaf_cta'),
                onPressed: action.onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Act0AcademyLeafPaletteV1.ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Act0AcademyLeafGlyphV1(
                  kind: Act0AcademyLeafGlyphKindV1.forward,
                  size: 19,
                  color: Act0AcademyLeafPaletteV1.ink,
                ),
                label: Text(
                  action.ctaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
          Positioned(
            top: 30,
            left: 55,
            right: 55,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x8035DAD2),
                    Color(0xFF54E6DF),
                    Color(0xFF163542),
                  ],
                ),
              ),
            ),
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
            SizedBox(
              height: 60,
              child: Center(
                child: Container(
                  key: Key('act0_academy_home_leaf_stage_$number'),
                  width: isCurrent ? 60 : 50,
                  height: isCurrent ? 60 : 50,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF073C40)
                        : Act0AcademyLeafPaletteV1.inkRaised,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? Act0AcademyLeafPaletteV1.aqua
                          : const Color(0xFF20404C),
                      width: isCurrent ? 2 : 1,
                    ),
                    boxShadow: isCurrent
                        ? const [
                            BoxShadow(
                              color: Color(0x8050EAE3),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Act0AcademyLeafGlyphV1(
                    key: isCurrent
                        ? Key('act0_academy_home_leaf_active_stage_$number')
                        : null,
                    kind: glyph,
                    color: isCurrent
                        ? Act0AcademyLeafPaletteV1.text
                        : Act0AcademyLeafPaletteV1.textMuted,
                    size: isCurrent ? 26 : 23,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Act0AcademyLeafPaletteV1.text,
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Act0AcademyLeafPaletteV1.textMuted,
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseProgressStripV1 extends StatelessWidget {
  const _CourseProgressStripV1({
    required this.courseTitle,
    required this.progress,
  });

  final String courseTitle;
  final Act0AcademyHomeProgressV1? progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    return Container(
      key: const Key('act0_academy_home_leaf_course_progress'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minHeight: 94),
      decoration: BoxDecoration(
        color: Act0AcademyLeafPaletteV1.inkRaised.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF102832), width: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF146092), Color(0xFF287DAE)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Act0AcademyLeafGlyphV1(
              kind: Act0AcademyLeafGlyphKindV1.learn,
              color: Act0AcademyLeafPaletteV1.text,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        courseTitle,
                        key: const Key('act0_academy_home_leaf_course_title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Act0AcademyLeafPaletteV1.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (p != null)
                      Text(
                        '${p.percent}%',
                        key: const Key('act0_academy_home_leaf_percent'),
                        style: const TextStyle(
                          color: Act0AcademyLeafPaletteV1.aqua,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (p != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${p.earned} of ${p.total} lessons complete',
                    key: const Key('act0_academy_home_leaf_progress_label'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Act0AcademyLeafPaletteV1.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // A missing/invalid count draws an empty decorative track
                // only; it must not announce "0%" to assistive tech.
                ExcludeSemantics(
                  excluding: p == null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: LinearProgressIndicator(
                      key: const Key('act0_academy_home_leaf_progress_bar'),
                      minHeight: 12,
                      value: p?.ratio ?? 0,
                      semanticsLabel: p == null ? null : 'Course progress',
                      semanticsValue: p == null ? null : '${p.percent}%',
                      backgroundColor: const Color(0xFF102A35),
                      color: Act0AcademyLeafPaletteV1.aqua,
                    ),
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
