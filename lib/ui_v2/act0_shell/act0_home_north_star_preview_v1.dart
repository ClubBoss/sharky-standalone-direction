import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_iconography_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const bool kAct0HomeNorthStarPreviewV1 = bool.fromEnvironment(
  'SHARKY_HOME_NORTH_STAR_PREVIEW',
);

abstract final class Act0HomeNorthStarPaletteV1 {
  static const ink = Color(0xFF06100F);
  static const inkRaised = Color(0xFF0A1D1B);
  static const tealDeep = Color(0xFF0B3530);
  static const teal = Color(0xFF177D70);
  static const aqua = Color(0xFF23E6D2);
  static const aquaSoft = Color(0xFFB9F5E9);
  static const text = Color(0xFFF1FBF8);
  static const textMuted = Color(0xFF9DB8B2);
  static const rule = Color(0xFF23443F);
}

/// Visual label for an EXISTING source-owned recommendation, not a daily engine.
enum Act0HomeTrainingPhaseV1 { recall, learn, apply }

class Act0HomeNorthStarPreviewV1 extends StatelessWidget {
  const Act0HomeNorthStarPreviewV1({
    super.key,
    required this.state,
    required this.sharky,
    required this.courseTitle,
    required this.nextActionTitle,
    required this.nextActionSubtitle,
    required this.nextActionCtaLabel,
    required this.onContinue,
    this.earnedLessonCount,
    this.courseLessonCount,
    this.trainingPhase,
    this.onOpenDevMenu,
  });

  final Act0ShellStateV1 state;
  final Act0SharkyCueV1 sharky;
  final String courseTitle;
  final String nextActionTitle;
  final String nextActionSubtitle;
  final String nextActionCtaLabel;
  final int? earnedLessonCount;
  final int? courseLessonCount;
  final Act0HomeTrainingPhaseV1? trainingPhase;
  final VoidCallback onContinue;
  final VoidCallback? onOpenDevMenu;

  @override
  Widget build(BuildContext context) {
    final progress = _CourseProgressV1.fromCounts(
      earnedLessonCount,
      courseLessonCount,
    );
    return ColoredBox(
      key: const Key('act0_shell_home_page_background'),
      color: Act0HomeNorthStarPaletteV1.ink,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 510,
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: Image(
                  image: AssetImage(
                    'assets/design/sharky/home/poker_lounge_v1.png',
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomRight,
                ),
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
                      Color(0x0006100F),
                      Color(0x0006100F),
                      Color(0xFF06100F),
                    ],
                    stops: [0, 0.46, 0.76],
                  ),
                ),
              ),
            ),
          ),
          ListView(
            key: const Key('act0_shell_home_screen'),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
            children: [
              _ImmersiveHeaderV1(
                sharky: sharky,
                streakDays: state.streakDays,
                onOpenDevMenu: onOpenDevMenu,
              ),
              const SizedBox(height: 28),
              const SizedBox(
                height: 154,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to your table',
                      style: TextStyle(
                        color: Act0HomeNorthStarPaletteV1.textMuted,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Build your\npoker edge.',
                      style: TextStyle(
                        color: Act0HomeNorthStarPaletteV1.text,
                        fontSize: 32,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              _LearningCycleV1(currentPhase: trainingPhase),
              const SizedBox(height: 22),
              _NextActionCardV1(
                courseTitle: courseTitle,
                title: nextActionTitle,
                subtitle: nextActionSubtitle,
                ctaLabel: nextActionCtaLabel,
                onContinue: onContinue,
              ),
              const SizedBox(height: 12),
              _CourseProgressStripV1(
                courseTitle: courseTitle,
                progress: progress,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImmersiveHeaderV1 extends StatelessWidget {
  const _ImmersiveHeaderV1({
    required this.sharky,
    required this.streakDays,
    this.onOpenDevMenu,
  });

  final Act0SharkyCueV1 sharky;
  final int streakDays;
  final VoidCallback? onOpenDevMenu;

  @override
  Widget build(BuildContext context) {
    final tone = act0SharkyToneForMoodV1(sharky.preSessionMood);
    return Row(
      key: const Key('act0_shell_home_identity_row'),
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: tone.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: Act0HomeNorthStarPaletteV1.teal.withValues(alpha: 0.18),
                blurRadius: 18,
              ),
            ],
          ),
          child: Act0SharkyPresenceMascotV1(
            mood: sharky.preSessionMood,
            tone: tone,
            size: 40,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sharky',
                style: TextStyle(
                  color: Act0HomeNorthStarPaletteV1.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Poker Academy',
                style: TextStyle(
                  color: Act0HomeNorthStarPaletteV1.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
              key: const Key('act0_home_north_star_streak'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Act0HomeNorthStarPaletteV1.aqua.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Act0HomeNorthStarPaletteV1.rule.withValues(
                    alpha: 0.42,
                  ),
                ),
              ),
              child: Text(
                '$streakDays day streak',
                style: const TextStyle(
                  color: Act0HomeNorthStarPaletteV1.aquaSoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (onOpenDevMenu != null) ...[
          const SizedBox(width: 4),
          IconButton(
            key: const Key('act0_shell_home_dev_menu_button'),
            onPressed: onOpenDevMenu,
            tooltip: 'Dev menu',
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            icon: const Act0AcademyGlyphV1(
              asset: Act0AcademyIconographyV1.overflow,
              color: Act0HomeNorthStarPaletteV1.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _NextActionCardV1 extends StatelessWidget {
  const _NextActionCardV1({
    required this.courseTitle,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onContinue,
  });

  final String courseTitle;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_home_mission_command_card'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xD20B2928), Color(0xE006171B)],
        ),
        borderRadius: BorderRadius.circular(18),
        // The atmospheric surface, not a hard outlined panel, carries the action.
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
          Text(
            'YOUR NEXT STEP',
            key: const Key('act0_home_north_star_world_title'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Act0HomeNorthStarPaletteV1.aqua,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            key: const Key('act0_shell_home_primary_route_title'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Act0HomeNorthStarPaletteV1.text,
              fontSize: 24,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            key: const Key('act0_shell_home_next_action_subtitle'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Act0HomeNorthStarPaletteV1.textMuted,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            key: const Key('act0_shell_home_v6_primary_cta'),
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              key: const Key('act0_shell_main_cta'),
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: Act0HomeNorthStarPaletteV1.aqua,
                foregroundColor: Act0HomeNorthStarPaletteV1.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Act0AcademyGlyphV1(
                asset: Act0AcademyIconographyV1.forward,
                size: 19,
                color: Act0HomeNorthStarPaletteV1.ink,
              ),
              label: Text(
                ctaLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

  final Act0HomeTrainingPhaseV1? currentPhase;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Learning guide, in order: Recall, Learn, Apply. No step is marked complete.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Positioned(
                top: 26,
                left: 52,
                right: 52,
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x1255BFB3),
                        Color(0xB255BFB3),
                        Color(0x1255BFB3),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _CycleStageV1(
                    isCurrent: currentPhase == Act0HomeTrainingPhaseV1.recall,
                    number: 1,
                    label: 'Recall',
                    icon: Act0AcademyIconographyV1.recall,
                  ),
                  _CycleStageV1(
                    number: 2,
                    isCurrent: currentPhase == Act0HomeTrainingPhaseV1.learn,
                    label: 'Learn',
                    icon: Act0AcademyIconographyV1.learn,
                  ),
                  _CycleStageV1(
                    number: 3,
                    isCurrent: currentPhase == Act0HomeTrainingPhaseV1.apply,
                    label: 'Apply',
                    icon: Act0AcademyIconographyV1.apply,
                  ),
                ],
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
    required this.icon,
  });

  final int number;
  final bool isCurrent;
  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: isCurrent
            ? 'Current training phase: $label'
            : 'Step $number, $label',
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  key: Key('act0_home_north_star_stage_$number'),
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF17443D)
                        : Act0HomeNorthStarPaletteV1.inkRaised,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? Act0HomeNorthStarPaletteV1.aqua
                          : Act0HomeNorthStarPaletteV1.teal,
                      width: isCurrent ? 2 : 1.5,
                    ),
                    boxShadow: isCurrent
                        ? const [
                            BoxShadow(
                              color: Color(0x4250DBC1),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Act0AcademyGlyphV1(
                    asset: icon,
                    key: isCurrent
                        ? Key('act0_home_north_star_active_stage_$number')
                        : null,
                    color: isCurrent
                        ? Act0HomeNorthStarPaletteV1.aqua
                        : Act0HomeNorthStarPaletteV1.aquaSoft,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Act0HomeNorthStarPaletteV1.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
  final _CourseProgressV1? progress;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = progress == null
        ? null
        : '${progress!.earned} of ${progress!.total} lessons complete';
    return Container(
      key: const Key('act0_home_north_star_course_progress'),
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
      decoration: BoxDecoration(
        color: Act0HomeNorthStarPaletteV1.inkRaised.withValues(alpha: 0.31),
        borderRadius: BorderRadius.circular(18),
        // Progress is a quiet continuation of the page, not another card.
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  courseTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Act0HomeNorthStarPaletteV1.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (progress != null)
                Text(
                  '${progress!.percent}%',
                  key: const Key('act0_home_north_star_progress_percent'),
                  style: const TextStyle(
                    color: Act0HomeNorthStarPaletteV1.aqua,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          if (cleanLabel != null && cleanLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              cleanLabel,
              key: const Key('act0_home_north_star_progress_source_label'),
              style: const TextStyle(
                color: Act0HomeNorthStarPaletteV1.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: progress?.ratio ?? 0,
              backgroundColor: Act0HomeNorthStarPaletteV1.rule,
              color: Act0HomeNorthStarPaletteV1.aqua,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseProgressV1 {
  const _CourseProgressV1({required this.earned, required this.total});

  final int earned;
  final int total;

  double get ratio => total <= 0 ? 0 : (earned / total).clamp(0, 1);
  int get percent => (ratio * 100).round();

  static _CourseProgressV1? fromCounts(int? earned, int? total) {
    if (earned == null ||
        total == null ||
        earned < 0 ||
        total <= 0 ||
        earned > total) {
      return null;
    }
    return _CourseProgressV1(earned: earned, total: total);
  }
}
