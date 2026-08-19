import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

/// Maps the bounded Sharky Companion Visual State onto the existing
/// [Act0SharkyMoodV1] tone family. Visual production admission remains
/// separate from these typed semantics.
Act0SharkyMoodV1 act0SharkyMoodForCompanionStateV1(
  Act0SharkyCompanionStateV1 state,
) {
  return switch (state) {
    Act0SharkyCompanionStateV1.neutral => Act0SharkyMoodV1.neutral,
    Act0SharkyCompanionStateV1.coach => Act0SharkyMoodV1.thinking,
    Act0SharkyCompanionStateV1.repair => Act0SharkyMoodV1.repair,
    Act0SharkyCompanionStateV1.confirm => Act0SharkyMoodV1.happy,
    Act0SharkyCompanionStateV1.improve => Act0SharkyMoodV1.happy,
    Act0SharkyCompanionStateV1.milestone => Act0SharkyMoodV1.celebrate,
  };
}

/// Only `improve` and `milestone` earn the extra accent ring — a stronger
/// evidence echo for improve, the strongest contained treatment for a real
/// completion boundary. Every other state renders the plain frame.
bool act0SharkyCompanionStateHasAccentRingV1(Act0SharkyCompanionStateV1 state) {
  return state == Act0SharkyCompanionStateV1.improve ||
      state == Act0SharkyCompanionStateV1.milestone;
}

Color act0SharkyToneForMoodV1(Act0SharkyMoodV1 mood) {
  return switch (mood) {
    Act0SharkyMoodV1.repair => Act0ShellTokensV1.gold,
    Act0SharkyMoodV1.celebrate => Act0ShellTokensV1.primary,
    Act0SharkyMoodV1.happy => Act0ShellTokensV1.primary,
    Act0SharkyMoodV1.thinking => Act0ShellTokensV1.info,
    Act0SharkyMoodV1.neutral => Act0ShellTokensV1.textMuted,
  };
}

const String act0SharkyLogoMarkAssetV1 = 'assets/brand/logo.svg';

const String _act0SharkyNeutralFallbackAssetV1 =
    'assets/images/mascot/sharky_neutral_fallback_v1.png';

String act0SharkyCompanionAssetForMoodV1(Act0SharkyMoodV1 mood) {
  // Provisional single neutral Alpha fallback: production state art is not
  // admitted. Future approved state assets replace these mappings only.
  return _act0SharkyNeutralFallbackAssetV1;
}

/// Every distinct asset [act0SharkyCompanionAssetForMoodV1] can resolve to.
///
/// Every mood currently resolves to the same provisional asset, so this is a
/// one-element set today. It stays mood-driven rather than a single hardcoded
/// path so a future per-mood art admission is precached automatically without
/// another call site to remember.
Set<String> act0SharkyCompanionAssetPathsV1() =>
    Act0SharkyMoodV1.values.map(act0SharkyCompanionAssetForMoodV1).toSet();

/// Decodes every Sharky companion mascot asset ahead of first paint.
///
/// [Act0SharkyPresenceMascotV1] already degrades gracefully to a lettered
/// avatar while its image decodes (`frameBuilder`), but that placeholder is
/// only correct for a genuinely cold cache. Once precached, `ImageCache`
/// serves the decoded frame synchronously for the rest of the process, so the
/// very first coaching card a learner sees — often before any other screen
/// has ever shown Sharky, e.g. a returning learner who lands straight in the
/// Learning Scene — never has to show that fallback letter at all. Sharky is
/// the voice of the scene; a bare "S" on his own coaching card is a
/// coach-surface cohesion regression, not a defensible degrade.
Future<void> act0PrecacheSharkyCompanionAssetsV1(BuildContext context) {
  return Future.wait(<Future<void>>[
    for (final path in act0SharkyCompanionAssetPathsV1())
      precacheImage(AssetImage(path), context),
  ]);
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
    this.growthStage = Act0SharkyGrowthStageV1.foundation,
  });

  final String eyebrow;
  final String line;
  final String? detail;
  final Act0SharkyMoodV1 mood;
  final Color tone;
  final String? badgeLabel;
  final bool compact;

  /// Sharky's persistent growth stage. Defaults to
  /// [Act0SharkyGrowthStageV1.foundation] so every existing caller renders
  /// byte-identically unless it explicitly passes structured stage truth.
  final Act0SharkyGrowthStageV1 growthStage;

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
                          growthStage: growthStage,
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
                      growthStage: growthStage,
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
    this.ringed = false,
    this.growthStage = Act0SharkyGrowthStageV1.foundation,
  });

  final String line;
  final Act0SharkyMoodV1 mood;
  final Color? tone;
  final String? detail;
  final Key? textKey;
  final double mascotSize;
  final EdgeInsetsGeometry? bubblePadding;

  /// Reserved for the companion states that earn a stronger evidence echo
  /// (`improve`, `milestone`). Defaults to false so every existing caller
  /// renders byte-identically.
  final bool ringed;

  /// Sharky's persistent growth stage. Defaults to
  /// [Act0SharkyGrowthStageV1.foundation] so every existing caller renders
  /// byte-identically unless it explicitly passes structured stage truth.
  final Act0SharkyGrowthStageV1 growthStage;

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
          ringed: ringed,
          growthStage: growthStage,
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
    this.ringed = false,
    this.growthStage = Act0SharkyGrowthStageV1.foundation,
  });

  final Act0SharkyMoodV1 mood;
  final Color tone;
  final double size;
  final bool animated;
  final bool simpleFrame;

  /// Reserved for the companion states that earn a stronger evidence echo
  /// (`improve`, `milestone`). Defaults to false so every existing caller
  /// renders byte-identically.
  final bool ringed;

  /// Sharky's persistent growth stage. Defaults to
  /// [Act0SharkyGrowthStageV1.foundation] so every existing caller renders
  /// byte-identically unless it explicitly passes structured stage truth.
  final Act0SharkyGrowthStageV1 growthStage;

  bool get _isDeveloping => growthStage == Act0SharkyGrowthStageV1.developing;

  @override
  Widget build(BuildContext context) {
    final mascot = animated
        ? Act0SharkyPresenceMascotV1(mood: mood, tone: tone, size: size * 0.84)
        : Image.asset(
            act0SharkyCompanionAssetForMoodV1(mood),
            fit: BoxFit.contain,
          );
    final frame = Container(
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
        borderRadius: BorderRadius.circular(
          size * Act0ShellTokensV1.sharkyTileRadiusRatio,
        ),
        border: simpleFrame
            ? null
            : Border.all(
                color: tone.withValues(alpha: _isDeveloping ? 0.30 : 0.22),
                width: _isDeveloping ? 1.3 : 1.0,
              ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.withValues(alpha: _isDeveloping ? 0.25 : 0.18),
            blurRadius: size * (_isDeveloping ? 0.34 : 0.28),
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: mascot,
    );

    Widget layered = frame;
    var effectiveSize = size;
    if (ringed) {
      final ringBox = effectiveSize + 8;
      layered = SizedBox(
        key: const Key('act0_shell_sharky_mascot_frame_accent_ring'),
        width: ringBox,
        height: ringBox,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: ringBox,
              height: ringBox,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ringBox * Act0ShellTokensV1.sharkyTileRadiusRatio,
                ),
                border: Border.all(
                  color: tone.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            layered,
          ],
        ),
      );
      effectiveSize = ringBox;
    }
    if (_isDeveloping) {
      final growthBox = effectiveSize + 6;
      layered = SizedBox(
        key: const Key('act0_shell_sharky_mascot_frame_growth_ring'),
        width: growthBox,
        height: growthBox,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: growthBox,
              height: growthBox,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  growthBox * Act0ShellTokensV1.sharkyTileRadiusRatio,
                ),
                border: Border.all(
                  color: Act0ShellTokensV1.primary.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
            ),
            layered,
          ],
        ),
      );
    }
    return layered;
  }
}

/// The shared Sharky Companion Visual State renderer. Accepts only the
/// semantic state and a size — no mood, score, level, percentage, rarity,
/// animation config, arbitrary color, arbitrary icon, or random seed. State
/// determines the mood/tone/ring exactly as defined by
/// [act0SharkyMoodForCompanionStateV1] and
/// [act0SharkyCompanionStateHasAccentRingV1]; no new Sharky asset is used.
class Act0SharkyCompanionAvatarV1 extends StatelessWidget {
  const Act0SharkyCompanionAvatarV1({
    super.key,
    required this.state,
    this.size = 64,
    this.simpleFrame = false,
    this.growthStage = Act0SharkyGrowthStageV1.foundation,
  });

  final Act0SharkyCompanionStateV1 state;
  final double size;
  final bool simpleFrame;

  /// Sharky's persistent growth stage — a separate axis from [state].
  /// Consumers pass structured stage truth (see
  /// `act0SharkyGrowthStageForWorldNumberV1`), never a style token.
  final Act0SharkyGrowthStageV1 growthStage;

  @override
  Widget build(BuildContext context) {
    final mood = act0SharkyMoodForCompanionStateV1(state);
    final tone = act0SharkyToneForMoodV1(mood);
    return KeyedSubtree(
      key: Key('act0_shell_sharky_companion_avatar_${state.name}'),
      child: _SharkyMascotFrameV1(
        mood: mood,
        tone: tone,
        size: size,
        animated: true,
        simpleFrame: simpleFrame,
        ringed: act0SharkyCompanionStateHasAccentRingV1(state),
        growthStage: growthStage,
      ),
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
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller?.dispose();
      _controller = null;
      return;
    }
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
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
    final mascotImage = Image.asset(
      act0SharkyCompanionAssetForMoodV1(widget.mood),
      key: Key('act0_shell_sharky_presence_mascot_${widget.mood.name}'),
      fit: BoxFit.contain,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _SharkyMascotAssetFallbackV1(
          mood: widget.mood,
          tone: widget.tone,
          size: widget.size,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _SharkyMascotAssetFallbackV1(
          mood: widget.mood,
          tone: widget.tone,
          size: widget.size,
        );
      },
    );
    if (MediaQuery.of(context).disableAnimations) {
      return SizedBox(
        key: const Key('act0_shell_sharky_presence_mascot'),
        width: widget.size,
        height: widget.size,
        child: mascotImage,
      );
    }
    final controller = _controller!;
    return SizedBox(
      key: const Key('act0_shell_sharky_presence_mascot'),
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        key: const Key('act0_shell_sharky_presence_motion'),
        animation: controller,
        builder: (context, child) {
          final t = _act0SharkyPresencePhaseV1(controller.value);
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
        child: mascotImage,
      ),
    );
  }
}

class _SharkyMascotAssetFallbackV1 extends StatelessWidget {
  const _SharkyMascotAssetFallbackV1({
    required this.mood,
    required this.tone,
    required this.size,
  });

  final Act0SharkyMoodV1 mood;
  final Color tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_sharky_presence_asset_fallback'),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tone.withValues(alpha: 0.16),
        border: Border.all(color: tone.withValues(alpha: 0.34)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _SharkyMascotLetterFallbackV1(tone: tone, size: size),
    );
  }
}

class _SharkyMascotLetterFallbackV1 extends StatelessWidget {
  const _SharkyMascotLetterFallbackV1({required this.tone, required this.size});

  final Color tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'S',
        style: Act0ShellTokensV1.screenTitle.copyWith(
          color: tone,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
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
