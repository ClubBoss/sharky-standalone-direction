import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

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
    return Container(
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: tone.withValues(alpha: compact ? 0.22 : 0.28),
        glow: !compact,
        color: compact ? Act0ShellTokensV1.surface2 : Act0ShellTokensV1.surface,
      ),
      padding: EdgeInsets.all(
        compact ? Act0ShellTokensV1.gapMd : Act0ShellTokensV1.gapLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SharkyMascotFrameV1(mood: mood, tone: tone, size: mascotSize),
          SizedBox(
            width: compact ? Act0ShellTokensV1.gapMd : Act0ShellTokensV1.gapLg,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        eyebrow,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: tone,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (badgeLabel != null && badgeLabel!.trim().isNotEmpty)
                      _GuideBadgeV1(label: badgeLabel!, tone: tone),
                  ],
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  line,
                  maxLines: compact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.body.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 14 : 16,
                    height: 1.18,
                    color: Act0ShellTokensV1.text,
                  ),
                ),
                if (detailText.isNotEmpty) ...[
                  const SizedBox(height: Act0ShellTokensV1.gapXs),
                  Text(
                    detailText,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _SharkyMascotFrameV1 extends StatelessWidget {
  const _SharkyMascotFrameV1({
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.12),
            tone.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.34),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.withValues(alpha: 0.18),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: Image.asset(_mascotAssetForMood(mood), fit: BoxFit.contain),
    );
  }
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
