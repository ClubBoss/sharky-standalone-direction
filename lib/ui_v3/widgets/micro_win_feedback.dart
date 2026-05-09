import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class MicroWinFeedback extends StatefulWidget {
  const MicroWinFeedback({
    super.key,
    this.duration = const Duration(seconds: 1),
  });

  final Duration duration;

  @override
  State<MicroWinFeedback> createState() => _MicroWinFeedbackState();
}

class _MicroWinFeedbackState extends State<MicroWinFeedback>
    with SingleTickerProviderStateMixin {
  static const List<String> _messages = <String>[
    'Nice fold!',
    'Great value bet!',
    'Smart patience!',
    'Strong call!',
    'Sharp read!',
  ];

  late final String _message;
  double _opacity = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _message = _messages[rng.nextInt(_messages.length)];
    FirebaseLiteTelemetryService.instance.logEvent(
      'micro_win_shown',
      params: {'micro_win_variant': _message},
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _opacity = 1);
      _timer = Timer(widget.duration, () {
        if (!mounted) return;
        setState(() => _opacity = 0);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: true,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: VisualThemeV3.speedNormal,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: VisualThemeV3.spacingM),
            padding: const EdgeInsets.symmetric(
              horizontal: VisualThemeV3.spacingL,
              vertical: VisualThemeV3.spacingS,
            ),
            decoration: BoxDecoration(
              color: VisualThemeV3.success.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
              boxShadow: const [VisualThemeV3.shadowMedium],
            ),
            child: Text(
              _message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
