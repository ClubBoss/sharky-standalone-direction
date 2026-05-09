import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/session_summary_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class SessionSummaryCard extends StatefulWidget {
  const SessionSummaryCard({
    super.key,
    required this.metrics,
    required this.onContinue,
  });

  final SessionMetrics metrics;
  final VoidCallback onContinue;

  @override
  State<SessionSummaryCard> createState() => _SessionSummaryCardState();
}

class _SessionSummaryCardState extends State<SessionSummaryCard>
    with SingleTickerProviderStateMixin {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    FirebaseLiteTelemetryService.instance.logEvent(
      'session_summary_rendered',
      params: {
        'accuracy': widget.metrics.accuracy,
        'avg_pot_ev': widget.metrics.averagePotEv,
        'time_spent': widget.metrics.timeSpentSeconds,
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _opacity = 1);
    });
  }

  Color _accuracyColor(ColorScheme scheme) {
    final accuracy = widget.metrics.accuracy;
    if (accuracy >= 0.8) return VisualThemeV3.success;
    if (accuracy >= 0.5) return VisualThemeV3.warning;
    return VisualThemeV3.danger;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      opacity: _opacity,
      duration: VisualThemeV3.speedNormal,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(VisualThemeV3.spacingM),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: VisualThemeV3.spacingS),
            _buildRow(
              context,
              label: 'Accuracy',
              value: '${(widget.metrics.accuracy * 100).toStringAsFixed(1)}%',
              color: _accuracyColor(colorScheme),
            ),
            _buildRow(
              context,
              label: 'Avg Pot EV',
              value: widget.metrics.averagePotEv.toStringAsFixed(1),
            ),
            _buildRow(
              context,
              label: 'Time Spent',
              value: '${widget.metrics.timeSpentSeconds}s',
            ),
            const SizedBox(height: VisualThemeV3.spacingS),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  FirebaseLiteTelemetryService.instance.logEvent(
                    'session_continue_tapped',
                    params: {'time_spent': widget.metrics.timeSpentSeconds},
                  );
                  widget.onContinue();
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VisualThemeV3.spacingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
