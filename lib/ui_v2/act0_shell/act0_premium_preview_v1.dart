import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

class Act0PremiumPreviewSheetV1 extends StatelessWidget {
  const Act0PremiumPreviewSheetV1({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.valuePoints,
    required this.trustLine,
    this.footerLine,
  });

  final String eyebrow;
  final String title;
  final String summary;
  final List<String> valuePoints;
  final String trustLine;
  final String? footerLine;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.gapLg,
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.gapLg,
        ),
        child: Container(
          key: const Key('act0_shell_premium_preview_sheet'),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface2,
            borderColor: Act0ShellTokensV1.gold.withValues(alpha: 0.24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusLg,
                      ),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Act0ShellTokensV1.gold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Text(
                    eyebrow,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.gold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Text(
                title,
                key: const Key('act0_shell_premium_preview_title'),
                style: Act0ShellTokensV1.sectionTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(summary, style: Act0ShellTokensV1.muted),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Text(
                'Free right now',
                key: const Key('act0_shell_premium_preview_free_label'),
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.primary,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Container(
                key: const Key('act0_shell_premium_preview_trust_line'),
                padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.surface3.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusLg,
                  ),
                  border: Border.all(color: Act0ShellTokensV1.border),
                ),
                child: Text(
                  trustLine,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Text(
                'Premium adds later',
                key: const Key('act0_shell_premium_preview_value_label'),
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.gold,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              for (var i = 0; i < valuePoints.length; i++) ...[
                _PremiumPreviewValueLineV1(
                  key: Key('act0_shell_premium_preview_value_$i'),
                  label: valuePoints[i],
                ),
                if (i < valuePoints.length - 1)
                  const SizedBox(height: Act0ShellTokensV1.gapXs),
              ],
              if (footerLine != null && footerLine!.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  footerLine!,
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.textDim,
                  ),
                ),
              ],
              const SizedBox(height: Act0ShellTokensV1.gapLg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('act0_shell_premium_preview_continue_free'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: Act0ShellTokensV1.primaryButtonStyle(),
                  child: const Text('Stay on free route'),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('act0_shell_premium_preview_not_now'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: Act0ShellTokensV1.quietButtonStyle(height: 42),
                  child: const Text('Maybe later'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumPreviewValueLineV1 extends StatelessWidget {
  const _PremiumPreviewValueLineV1({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: Act0ShellTokensV1.primary,
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        Expanded(
          child: Text(
            label,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
            ),
          ),
        ),
      ],
    );
  }
}
