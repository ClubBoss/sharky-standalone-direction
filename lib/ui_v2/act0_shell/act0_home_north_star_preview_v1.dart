import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_iconography_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const bool kAct0HomeNorthStarPreviewV1 = bool.fromEnvironment(
  'SHARKY_HOME_NORTH_STAR_PREVIEW',
);

abstract final class Act0HomeNorthStarPaletteV1 {
  static const ink = Color(0xFF020E13);
  static const inkRaised = Color(0xFF071C24);
  static const tealDeep = Color(0xFF0B3530);
  static const teal = Color(0xFF177D70);
  static const aqua = Color(0xFF23E6D2);
  static const aquaSoft = Color(0xFFB9F5E9);
  static const text = Color(0xFFF1FBF8);
  static const textMuted = Color(0xFFB6C8D5);
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
            height: 350,
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: Image(
                  image: AssetImage(
                    'assets/design/sharky/home/poker_lounge_reference_v2.png',
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.topRight,
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
            key: const Key('act0_shell_home_screen'),
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _ImmersiveHeaderV1(
                  sharky: sharky,
                  streakDays: state.streakDays,
                  onOpenDevMenu: onOpenDevMenu,
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 204,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          color: Act0HomeNorthStarPaletteV1.textMuted,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Let’s learn',
                        style: TextStyle(
                          color: Act0HomeNorthStarPaletteV1.text,
                          fontSize: 38,
                          height: 1.08,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Build your\npoker edge.',
                        style: TextStyle(
                          color: Act0HomeNorthStarPaletteV1.textMuted,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _LearningCycleV1(currentPhase: trainingPhase),
              const SizedBox(height: 20),
              _NextActionCardV1(
                courseTitle: courseTitle,
                title: nextActionTitle,
                subtitle: nextActionSubtitle,
                ctaLabel: nextActionCtaLabel,
                onContinue: onContinue,
              ),
              const SizedBox(height: 10),
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
          width: 52,
          height: 56,
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
            size: 48,
          ),
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
                  color: Act0HomeNorthStarPaletteV1.text,
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
                  color: Act0HomeNorthStarPaletteV1.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
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
                '$streakDays ${streakDays == 1 ? 'day' : 'days'}',
                maxLines: 1,
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
      constraints: const BoxConstraints(minHeight: 198),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xD20B2928), Color(0xE006171B)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x8043D9D0), width: 0.8),
        image: const DecorationImage(
          image: AssetImage(
            'assets/design/sharky/home/poker_lounge_reference_v2.png',
          ),
          fit: BoxFit.cover,
          alignment: Alignment(1, 0.55),
          colorFilter: ColorFilter.mode(Color(0xFF64777C), BlendMode.modulate),
        ),
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
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            key: const Key('act0_shell_home_primary_route_title'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Act0HomeNorthStarPaletteV1.text,
              fontSize: 25,
              height: 1.08,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            key: const Key('act0_shell_home_next_action_subtitle'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Act0HomeNorthStarPaletteV1.textMuted,
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            key: const Key('act0_shell_home_v6_primary_cta'),
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
                key: const Key('act0_shell_main_cta'),
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Act0HomeNorthStarPaletteV1.ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
                top: 32,
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
                    isCurrent: currentPhase == Act0HomeTrainingPhaseV1.recall,
                    number: 1,
                    label: 'Recall',
                    description: 'Past lesson',
                    icon: Act0AcademyIconographyV1.recall,
                  ),
                  _CycleStageV1(
                    number: 2,
                    isCurrent: currentPhase == Act0HomeTrainingPhaseV1.learn,
                    label: 'Learn',
                    description: 'New concept',
                    icon: Act0AcademyIconographyV1.learn,
                  ),
                  _CycleStageV1(
                    number: 3,
                    isCurrent: currentPhase == Act0HomeTrainingPhaseV1.apply,
                    label: 'Apply',
                    description: 'Try a hand',
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
    required this.description,
    required this.icon,
  });

  final int number;
  final bool isCurrent;
  final String label;
  final String description;
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
            SizedBox(
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    key: Key('act0_home_north_star_stage_$number'),
                    width: isCurrent ? 64 : 54,
                    height: isCurrent ? 64 : 54,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF073C40)
                          : Act0HomeNorthStarPaletteV1.inkRaised,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent
                            ? Act0HomeNorthStarPaletteV1.aqua
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
                    child: Act0AcademyGlyphV1(
                      asset: icon,
                      key: isCurrent
                          ? Key('act0_home_north_star_active_stage_$number')
                          : null,
                      color: isCurrent
                          ? Act0HomeNorthStarPaletteV1.text
                          : Act0HomeNorthStarPaletteV1.textMuted,
                      size: isCurrent ? 28 : 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Act0HomeNorthStarPaletteV1.text,
                fontSize: 14,
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
                color: Act0HomeNorthStarPaletteV1.textMuted,
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
  final _CourseProgressV1? progress;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = progress == null
        ? null
        : '${progress!.earned} of ${progress!.total} lessons complete';
    return Container(
      key: const Key('act0_home_north_star_course_progress'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minHeight: 94),
      decoration: BoxDecoration(
        color: Act0HomeNorthStarPaletteV1.inkRaised.withValues(alpha: 0.48),
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
            child: const Act0AcademyGlyphV1(
              asset: Act0AcademyIconographyV1.learn,
              color: Act0HomeNorthStarPaletteV1.text,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Act0HomeNorthStarPaletteV1.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (progress != null)
                      Text(
                        '${progress!.percent}%',
                        key: const Key('act0_home_north_star_progress_percent'),
                        style: const TextStyle(
                          color: Act0HomeNorthStarPaletteV1.aqua,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (cleanLabel != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    cleanLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    key: const Key(
                      'act0_home_north_star_progress_source_label',
                    ),
                    style: const TextStyle(
                      color: Act0HomeNorthStarPaletteV1.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: LinearProgressIndicator(
                    minHeight: 12,
                    value: progress?.ratio ?? 0,
                    backgroundColor: const Color(0xFF102A35),
                    color: Act0HomeNorthStarPaletteV1.aqua,
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
