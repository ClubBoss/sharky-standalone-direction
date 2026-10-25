import 'package:flutter/material.dart';
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
  static const aqua = Color(0xFF7EE6D5);
  static const aquaSoft = Color(0xFFB9F5E9);
  static const text = Color(0xFFF1FBF8);
  static const textMuted = Color(0xFF9DB8B2);
  static const rule = Color(0xFF23443F);
}

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
    this.pathProgressLabel,
    this.onOpenDevMenu,
  });

  final Act0ShellStateV1 state;
  final Act0SharkyCueV1 sharky;
  final String courseTitle;
  final String nextActionTitle;
  final String nextActionSubtitle;
  final String nextActionCtaLabel;
  final String? pathProgressLabel;
  final VoidCallback onContinue;
  final VoidCallback? onOpenDevMenu;

  @override
  Widget build(BuildContext context) {
    final progress = _CourseProgressV1.tryParse(pathProgressLabel);
    return ColoredBox(
      key: const Key('act0_shell_home_page_background'),
      color: Act0HomeNorthStarPaletteV1.ink,
      child: Stack(
        children: [
          const Positioned(
            top: -120,
            right: -90,
            child: _AtmosphereOrbV1(size: 310, opacity: 0.20),
          ),
          const Positioned(
            top: 330,
            left: -170,
            child: _AtmosphereOrbV1(size: 330, opacity: 0.10),
          ),
          // Decorative ink/felt light and original abstract chip motif.
          // No live cards, earned data or poker decisions are drawn here.
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _PokerAtmospherePainterV1()),
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
              const SizedBox(height: 18),
              _NextActionCardV1(
                courseTitle: courseTitle,
                title: nextActionTitle,
                subtitle: nextActionSubtitle,
                ctaLabel: nextActionCtaLabel,
                onContinue: onContinue,
              ),
              const SizedBox(height: 19),
              const _LearningCycleV1(),
              const SizedBox(height: 19),
              _CourseProgressStripV1(
                courseTitle: courseTitle,
                sourceLabel: pathProgressLabel,
                progress: progress,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Background-only premium poker material. The shapes represent generic felt,
/// chip silhouettes and soft lighting; they cannot encode a hand or grade.
class _PokerAtmospherePainterV1 extends CustomPainter {
  const _PokerAtmospherePainterV1();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.8, -0.62),
          radius: 1.0,
          colors: [
            const Color(0xFF159184).withValues(alpha: 0.21),
            const Color(0xFF0C3B37).withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    final rail = Path()
      ..moveTo(-w * 0.32, h * 0.68)
      ..cubicTo(w * 0.05, h * 0.54, w * 0.67, h * 0.57, w * 1.28, h * 0.35);
    canvas.drawPath(
      rail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = const Color(0xFF61E6D1).withValues(alpha: 0.24),
    );
    canvas.drawPath(
      rail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = const Color(0xFF61E6D1).withValues(alpha: 0.19),
    );

    // Layered, abstract chip stacks intentionally contain no numerals, suits,
    // currency amounts, rank symbols or other live poker semantics.
    void chips(double x, double y, double scale, int count) {
      final rx = 29.0 * scale;
      final ry = 9.0 * scale;
      for (var i = 0; i < count; i++) {
        final y0 = y - i * 10 * scale;
        final oval = Rect.fromCenter(
          center: Offset(x, y0),
          width: rx * 2,
          height: ry * 2,
        );
        final side = Rect.fromLTWH(
          x - rx,
          y0 - ry + 3 * scale,
          rx * 2,
          9 * scale,
        );
        canvas.drawRect(
          side,
          Paint()..color = const Color(0xFF1E716B).withValues(alpha: 0.18),
        );
        canvas.drawOval(
          oval,
          Paint()
            ..color = const Color(
              0xFF5FDCC9,
            ).withValues(alpha: i.isEven ? 0.17 : 0.10),
        );
        canvas.drawOval(
          oval.deflate(3 * scale),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6
            ..color = const Color(0xFFB2F7E8).withValues(alpha: 0.19),
        );
      }
    }

    chips(w * 0.93, h * 0.28, 1.05, 5);
    chips(w * 0.79, h * 0.37, 0.63, 3);
    chips(w * 1.02, h * 0.43, 0.78, 4);
  }

  @override
  bool shouldRepaint(covariant _PokerAtmospherePainterV1 oldDelegate) => false;
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
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.10),
            shape: BoxShape.circle,
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
            size: 30,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SHARKY',
                style: TextStyle(
                  color: Act0HomeNorthStarPaletteV1.aquaSoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Poker Academy',
                style: TextStyle(
                  color: Act0HomeNorthStarPaletteV1.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (streakDays > 0)
          Semantics(
            label: '$streakDays day streak',
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
            icon: const Icon(
              Icons.more_horiz_rounded,
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
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xEC123B35), Color(0xDC0A2421)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Act0HomeNorthStarPaletteV1.rule),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            courseTitle.toUpperCase(),
            key: const Key('act0_home_north_star_world_title'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Act0HomeNorthStarPaletteV1.aqua,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.35,
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
              fontSize: 27,
              height: 1.05,
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
            height: 52,
            child: FilledButton.icon(
              key: const Key('act0_shell_main_cta'),
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: Act0HomeNorthStarPaletteV1.aqua,
                foregroundColor: Act0HomeNorthStarPaletteV1.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
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
  const _LearningCycleV1();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Learning guide: Recall, Learn, Apply',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR LEARNING RHYTHM',
            style: TextStyle(
              color: Act0HomeNorthStarPaletteV1.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              _CycleStageV1(number: 1, label: 'Recall'),
              _CycleConnectorV1(),
              _CycleStageV1(number: 2, label: 'Learn'),
              _CycleConnectorV1(),
              _CycleStageV1(number: 3, label: 'Apply'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CycleStageV1 extends StatelessWidget {
  const _CycleStageV1({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: 'Step $number, $label',
        child: Column(
          children: [
            Container(
              key: Key('act0_home_north_star_stage_$number'),
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Act0HomeNorthStarPaletteV1.inkRaised,
                shape: BoxShape.circle,
                border: Border.all(color: Act0HomeNorthStarPaletteV1.teal),
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Act0HomeNorthStarPaletteV1.aquaSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 7),
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

class _CycleConnectorV1 extends StatelessWidget {
  const _CycleConnectorV1();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 27),
        color: Act0HomeNorthStarPaletteV1.rule,
      ),
    );
  }
}

class _CourseProgressStripV1 extends StatelessWidget {
  const _CourseProgressStripV1({
    required this.courseTitle,
    required this.sourceLabel,
    required this.progress,
  });

  final String courseTitle;
  final String? sourceLabel;
  final _CourseProgressV1? progress;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = sourceLabel?.trim();
    return Container(
      key: const Key('act0_home_north_star_course_progress'),
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
      decoration: BoxDecoration(
        color: Act0HomeNorthStarPaletteV1.inkRaised.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Act0HomeNorthStarPaletteV1.rule),
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

class _AtmosphereOrbV1 extends StatelessWidget {
  const _AtmosphereOrbV1({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Act0HomeNorthStarPaletteV1.teal.withValues(alpha: opacity),
              Act0HomeNorthStarPaletteV1.teal.withValues(alpha: 0),
            ],
          ),
        ),
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

  static _CourseProgressV1? tryParse(String? label) {
    final match = RegExp(
      r'\b(\d+)\s+of\s+(\d+)\s+lessons?\s+complete\b',
      caseSensitive: false,
    ).firstMatch(label?.trim() ?? '');
    final earned = int.tryParse(match?.group(1) ?? '');
    final total = int.tryParse(match?.group(2) ?? '');
    if (earned == null || total == null || total <= 0 || earned > total) {
      return null;
    }
    return _CourseProgressV1(earned: earned, total: total);
  }
}
