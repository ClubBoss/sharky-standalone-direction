import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

Color act0SharkyToneForMoodV1(Act0SharkyMoodV1 mood) {
  return switch (mood) {
    Act0SharkyMoodV1.repair => Act0ShellTokensV1.gold,
    Act0SharkyMoodV1.celebrate => Act0ShellTokensV1.primary,
    Act0SharkyMoodV1.happy => Act0ShellTokensV1.primary,
    Act0SharkyMoodV1.thinking => Act0ShellTokensV1.info,
    Act0SharkyMoodV1.neutral => Act0ShellTokensV1.textMuted,
  };
}

class Act0SharkyGuideCardV1 extends StatelessWidget {
  const Act0SharkyGuideCardV1({
    super.key,
    required this.eyebrow,
    required this.line,
    this.detail,
    required this.mood,
    this.tone = Act0ShellTokensV1.primary,
    this.badgeLabel,
    this.compact = false,
  });

  final String eyebrow;
  final String line;
  final String? detail;
  final Act0SharkyMoodV1 mood;
  final Color tone;
  final String? badgeLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mascotSize = compact ? 72.0 : 92.0;
    final detailText = detail?.trim() ?? '';
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = compact && constraints.maxWidth < 360;
        final content = _SharkyGuideContentV1(
          eyebrow: eyebrow,
          line: line,
          detailText: detailText,
          tone: tone,
          badgeLabel: badgeLabel,
          compact: compact,
        );
        return Container(
          decoration: Act0ShellTokensV1.surfaceDecoration(
            borderColor: tone.withValues(alpha: compact ? 0.22 : 0.28),
            glow: !compact,
            color: compact
                ? Act0ShellTokensV1.surface2
                : Act0ShellTokensV1.surface,
          ),
          padding: EdgeInsets.all(
            compact ? Act0ShellTokensV1.gapMd : Act0ShellTokensV1.gapLg,
          ),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SharkyMascotFrameV1(
                          mood: mood,
                          tone: tone,
                          size: mascotSize,
                          animated: true,
                        ),
                        const SizedBox(width: Act0ShellTokensV1.gapMd),
                        Expanded(child: content),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SharkyMascotFrameV1(
                      mood: mood,
                      tone: tone,
                      size: mascotSize,
                      animated: true,
                    ),
                    SizedBox(
                      width: compact
                          ? Act0ShellTokensV1.gapMd
                          : Act0ShellTokensV1.gapLg,
                    ),
                    Expanded(child: content),
                  ],
                ),
        );
      },
    );
  }
}

class _SharkyGuideContentV1 extends StatelessWidget {
  const _SharkyGuideContentV1({
    required this.eyebrow,
    required this.line,
    required this.detailText,
    required this.tone,
    required this.badgeLabel,
    required this.compact,
  });

  final String eyebrow;
  final String line;
  final String detailText;
  final Color tone;
  final String? badgeLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final detailBlocks = _splitSharkyGuideDetailBlocksV1(
      detailText,
      compact: compact,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          key: const Key('act0_shell_sharky_guide_eyebrow'),
          style: Act0ShellTokensV1.label.copyWith(
            color: tone,
            letterSpacing: 0.4,
          ),
        ),
        if (badgeLabel != null && badgeLabel!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: _GuideBadgeV1(label: badgeLabel!, tone: tone),
          ),
        ],
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          _formatSharkyGuideCopyV1(line),
          key: const Key('act0_shell_sharky_guide_line'),
          style: Act0ShellTokensV1.body.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: compact ? 14 : 16,
            height: 1.18,
            color: Act0ShellTokensV1.text,
          ),
        ),
        if (detailBlocks.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          KeyedSubtree(
            key: const Key('act0_shell_sharky_guide_detail'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < detailBlocks.length; index++) ...[
                  if (index > 0)
                    SizedBox(height: compact ? 8 : Act0ShellTokensV1.gapSm),
                  Text(
                    detailBlocks[index],
                    key: Key('act0_shell_sharky_guide_detail_block_$index'),
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class Act0SharkyPresenceBubbleV1 extends StatelessWidget {
  const Act0SharkyPresenceBubbleV1({
    super.key,
    required this.line,
    required this.mood,
    this.tone,
    this.detail,
    this.textKey,
    this.mascotSize = 64,
    this.bubblePadding,
  });

  final String line;
  final Act0SharkyMoodV1 mood;
  final Color? tone;
  final String? detail;
  final Key? textKey;
  final double mascotSize;
  final EdgeInsetsGeometry? bubblePadding;

  @override
  Widget build(BuildContext context) {
    final resolvedTone = tone ?? act0SharkyToneForMoodV1(mood);
    final resolvedLine = _resolveSharkyUtilityLineV1(line: line, mood: mood);
    final detailText = detail?.trim() ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _SharkyMascotFrameV1(
          mood: mood,
          tone: resolvedTone,
          size: mascotSize,
          animated: true,
          simpleFrame: true,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -8,
                bottom: 14,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.surface.withValues(alpha: 0.96),
                      border: Border(
                        left: BorderSide(
                          color: resolvedTone.withValues(alpha: 0.28),
                        ),
                        bottom: BorderSide(
                          color: resolvedTone.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding:
                    bubblePadding ??
                    const EdgeInsets.symmetric(
                      horizontal: Act0ShellTokensV1.gapMd,
                      vertical: 12,
                    ),
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.surface.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusLg,
                  ),
                  border: Border.all(
                    color: resolvedTone.withValues(alpha: 0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolvedLine,
                      key: textKey,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: resolvedTone,
                        fontWeight: FontWeight.w800,
                        height: 1.24,
                      ),
                    ),
                    if (detailText.isNotEmpty) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapXs),
                      Text(
                        detailText,
                        style: Act0ShellTokensV1.muted.copyWith(
                          color: Act0ShellTokensV1.textMuted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _resolveSharkyUtilityLineV1({
  required String line,
  required Act0SharkyMoodV1 mood,
}) {
  final trimmed = line.trim();
  if (trimmed.isEmpty) {
    return _fallbackSharkyUtilityLineV1(mood);
  }
  final normalized = trimmed.toLowerCase();
  const genericLines = <String>{
    'good',
    'nice',
    'great',
    'okay',
    'ok',
    'well done',
    'good job',
  };
  if (genericLines.contains(normalized)) {
    return _fallbackSharkyUtilityLineV1(mood);
  }
  return trimmed;
}

String _fallbackSharkyUtilityLineV1(Act0SharkyMoodV1 mood) {
  return switch (mood) {
    Act0SharkyMoodV1.repair =>
      'Fix one pressure spot first. Then continue with a clear head.',
    Act0SharkyMoodV1.celebrate =>
      'Keep the rhythm warm with one short clean rep now.',
    Act0SharkyMoodV1.happy =>
      'Lock this read in and carry it into the next hand.',
    Act0SharkyMoodV1.thinking =>
      'Take one calm read first, then choose one clear action.',
    Act0SharkyMoodV1.neutral =>
      'Start with the table read. Clean reads build real edge.',
  };
}

String _formatSharkyGuideCopyV1(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  final sentenceBreak = trimmed.indexOf('. ');
  if (sentenceBreak > 18 && sentenceBreak < trimmed.length - 4) {
    return '${trimmed.substring(0, sentenceBreak + 1)}\n'
        '${trimmed.substring(sentenceBreak + 2)}';
  }
  final dashBreak = trimmed.indexOf(' - ');
  if (dashBreak > 16 && dashBreak < trimmed.length - 4) {
    return '${trimmed.substring(0, dashBreak)}\n'
        '${trimmed.substring(dashBreak + 3)}';
  }
  return trimmed;
}

List<String> _splitSharkyGuideDetailBlocksV1(
  String text, {
  required bool compact,
}) {
  final blocks = act0BuildInstructionBlocksV1(text: text, compact: compact);
  if (blocks.isEmpty) {
    return const <String>[];
  }
  return blocks.map(_formatSharkyGuideCopyV1).toList();
}

class _SharkyMascotFrameV1 extends StatelessWidget {
  const _SharkyMascotFrameV1({
    required this.mood,
    required this.tone,
    required this.size,
    this.animated = false,
    this.simpleFrame = false,
  });

  final Act0SharkyMoodV1 mood;
  final Color tone;
  final double size;
  final bool animated;
  final bool simpleFrame;

  @override
  Widget build(BuildContext context) {
    final mascot = animated
        ? Act0SharkyPresenceMascotV1(mood: mood, tone: tone, size: size * 0.84)
        : Image.asset(_mascotAssetForMood(mood), fit: BoxFit.contain);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: simpleFrame
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.white.withValues(alpha: 0.12),
                  tone.withValues(alpha: 0.06),
                ],
              ),
        borderRadius: BorderRadius.circular(size * 0.34),
        border: simpleFrame
            ? null
            : Border.all(color: tone.withValues(alpha: 0.22)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.withValues(alpha: 0.18),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: mascot,
    );
  }
}

class Act0SharkyPresenceMascotV1 extends StatefulWidget {
  const Act0SharkyPresenceMascotV1({
    super.key,
    required this.mood,
    required this.tone,
    this.size = 40,
  });

  final Act0SharkyMoodV1 mood;
  final Color tone;
  final double size;

  @override
  State<Act0SharkyPresenceMascotV1> createState() =>
      _Act0SharkyPresenceMascotV1State();
}

class _Act0SharkyPresenceMascotV1State extends State<Act0SharkyPresenceMascotV1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = switch (widget.mood) {
      Act0SharkyMoodV1.celebrate => (scale: 0.032, tilt: 0.05, lift: 2.6),
      Act0SharkyMoodV1.happy => (scale: 0.022, tilt: -0.03, lift: 1.8),
      Act0SharkyMoodV1.repair => (scale: 0.016, tilt: -0.04, lift: 1.2),
      Act0SharkyMoodV1.thinking => (scale: 0.018, tilt: 0.025, lift: 1.5),
      Act0SharkyMoodV1.neutral => (scale: 0.014, tilt: 0.0, lift: 1.2),
    };
    return SizedBox(
      key: const Key('act0_shell_sharky_presence_mascot'),
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _act0SharkyPresencePhaseV1(_controller.value);
          final centered = ((t - 0.5) * 2).clamp(-1.0, 1.0);
          return Transform.translate(
            offset: Offset(0, -motion.lift * t),
            child: Transform.rotate(
              angle: motion.tilt * centered,
              child: Transform.scale(
                scale: 1 + (motion.scale * t),
                child: child,
              ),
            ),
          );
        },
        child: Image.asset(
          _mascotAssetForMood(widget.mood),
          key: Key('act0_shell_sharky_presence_mascot_${widget.mood.name}'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

double _act0SharkyPresencePhaseV1(double value) {
  if (value <= 0.5) {
    return Curves.easeOut.transform(value / 0.5);
  }
  return Curves.easeInOut.transform((1 - value) / 0.5);
}

class _GuideBadgeV1 extends StatelessWidget {
  const _GuideBadgeV1({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: tone,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

String _mascotAssetForMood(Act0SharkyMoodV1 mood) {
  return switch (mood) {
    Act0SharkyMoodV1.neutral => 'assets/images/mascot/sharky_neutral.png',
    Act0SharkyMoodV1.happy => 'assets/images/mascot/sharky_happy.png',
    Act0SharkyMoodV1.thinking => 'assets/images/mascot/sharky_thinking.png',
    Act0SharkyMoodV1.repair => 'assets/images/mascot/sharky_repair.png',
    Act0SharkyMoodV1.celebrate => 'assets/images/mascot/sharky_celebrate.png',
  };
}
