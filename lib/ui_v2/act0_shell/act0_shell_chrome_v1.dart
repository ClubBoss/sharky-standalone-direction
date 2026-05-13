import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

class Act0ShellScreenHeaderV1 extends StatelessWidget {
  const Act0ShellScreenHeaderV1({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.eyebrowTone = Act0ShellTokensV1.primary,
    this.trailing,
    this.titleKey,
    this.subtitleKey,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final Color eyebrowTone;
  final Widget? trailing;
  final Key? titleKey;
  final Key? subtitleKey;

  @override
  Widget build(BuildContext context) {
    final normalizedEyebrow = eyebrow?.trim() ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (normalizedEyebrow.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: eyebrowTone.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    border: Border.all(color: eyebrowTone.withOpacity(0.22)),
                  ),
                  child: Text(
                    normalizedEyebrow,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: eyebrowTone,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
              ],
              Text(title, key: titleKey, style: Act0ShellTokensV1.screenTitle),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                subtitle,
                key: subtitleKey,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Act0ShellTokensV1.muted,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          trailing!,
        ],
      ],
    );
  }
}
