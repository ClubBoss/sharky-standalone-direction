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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        border: Border.all(color: eyebrowTone.withOpacity(0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            eyebrowTone.withOpacity(0.14),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.info.withOpacity(0.06),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: eyebrowTone.withOpacity(0.10),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (normalizedEyebrow.isNotEmpty) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: eyebrowTone.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Flexible(
                        child: Text(
                          normalizedEyebrow,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: eyebrowTone,
                            letterSpacing: 0.28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
                Text(
                  title,
                  key: titleKey,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.screenTitle.copyWith(
                    fontSize: 23,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  subtitle,
                  key: subtitleKey,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
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
      ),
    );
  }
}
