import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/services/adaptive_progression_service.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class AdaptiveFeedbackBanner extends StatefulWidget {
  const AdaptiveFeedbackBanner({
    super.key,
    required this.notifier,
    this.displayDuration = const Duration(seconds: 1),
  });

  final ValueListenable<AdaptiveFeedbackSignal?> notifier;
  final Duration displayDuration;

  @override
  State<AdaptiveFeedbackBanner> createState() => _AdaptiveFeedbackBannerState();
}

class _AdaptiveFeedbackBannerState extends State<AdaptiveFeedbackBanner> {
  AdaptiveFeedbackSignal? _current;
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_handleSignal);
  }

  @override
  void didUpdateWidget(covariant AdaptiveFeedbackBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_handleSignal);
      widget.notifier.addListener(_handleSignal);
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_handleSignal);
    _timer?.cancel();
    super.dispose();
  }

  void _handleSignal() {
    final signal = widget.notifier.value;
    if (signal == null) return;
    _timer?.cancel();
    setState(() {
      _current = signal;
      _visible = true;
    });
    _emitTelemetry(signal);
    _timer = Timer(widget.displayDuration, _hide);
  }

  void _hide() {
    if (!_visible) return;
    setState(() {
      _visible = false;
    });
  }

  void _dismissEarly() {
    _timer?.cancel();
    _hide();
  }

  void _emitTelemetry(AdaptiveFeedbackSignal signal) {
    FirebaseLiteTelemetryService.instance.logEvent(
      TelemetryEvents.adaptiveFeedbackShown,
      params: {
        'delta': signal.delta,
        'duration_ms': widget.displayDuration.inMilliseconds,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) {
      return const SizedBox.shrink();
    }
    final delta = _current!.delta;
    final color = _colorForDelta(delta);
    final label = 'Difficulty ${_formatDelta(delta)}';

    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedOpacity(
        duration: VisualThemeV3.speedNormal,
        opacity: _visible ? 1 : 0,
        child: GestureDetector(
          onTap: _dismissEarly,
          child: AnimatedContainer(
            duration: VisualThemeV3.speedSlow,
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: VisualThemeV3.spacingS),
            padding: const EdgeInsets.symmetric(
              horizontal: VisualThemeV3.spacingL,
              vertical: VisualThemeV3.spacingS,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
              border: Border.all(color: color.withValues(alpha: 0.6)),
              boxShadow: const [VisualThemeV3.shadowLight],
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: color),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForDelta(int delta) {
    if (delta > 0) return VisualThemeV3.success;
    if (delta < 0) return VisualThemeV3.danger;
    return VisualThemeV3.neutralGrey;
  }

  String _formatDelta(int delta) {
    if (delta > 0) return '+$delta';
    return delta.toString();
  }
}
