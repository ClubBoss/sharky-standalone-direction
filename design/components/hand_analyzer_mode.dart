import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

import 'session_playback_engine.dart';

/// Describes external evaluation for a specific action index.
class HandAnalyzerEntry {
  const HandAnalyzerEntry({
    required this.actionIndex,
    required this.correctAction,
    required this.evDiff,
    required this.rationale,
  });

  final int actionIndex;
  final PlaybackActionType correctAction;
  final double evDiff;
  final String rationale;
}

enum HandAnalyzerSeverity { optimal, review, mistake }

class HandAnalyzerResult {
  const HandAnalyzerResult({
    required this.severity,
    required this.deltaEv,
    required this.correctAction,
    required this.rationale,
  });

  final HandAnalyzerSeverity severity;
  final double deltaEv;
  final PlaybackActionType correctAction;
  final String rationale;
}

class HandAnalyzerEngine {
  HandAnalyzerEngine(List<HandAnalyzerEntry> entries)
    : _entries = Map<int, HandAnalyzerEntry>.fromIterable(
        entries,
        key: (e) => (e as HandAnalyzerEntry).actionIndex,
        value: (e) => e as HandAnalyzerEntry,
      );

  final Map<int, HandAnalyzerEntry> _entries;
  final StreamController<HandAnalyzerResult?> _controller =
      StreamController<HandAnalyzerResult?>.broadcast();

  Stream<HandAnalyzerResult?> get results => _controller.stream;

  int _currentIndex = -1;

  void updateIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    if (!_controller.isClosed) {
      _controller.add(_evaluate(index));
    }
  }

  HandAnalyzerResult? _evaluate(int index) {
    final entry = _entries[index];
    if (entry == null) return null;

    final severity = _computeSeverity(entry.evDiff, entry.correctAction);
    return HandAnalyzerResult(
      severity: severity,
      deltaEv: entry.evDiff,
      correctAction: entry.correctAction,
      rationale: entry.rationale,
    );
  }

  HandAnalyzerSeverity _computeSeverity(
    double evDiff,
    PlaybackActionType correctAction,
  ) {
    final absDiff = evDiff.abs();
    if (correctAction == PlaybackActionType.none) {
      return HandAnalyzerSeverity.optimal;
    }
    if (absDiff < 0.15) return HandAnalyzerSeverity.optimal;
    if (absDiff < 0.45) return HandAnalyzerSeverity.review;
    return HandAnalyzerSeverity.mistake;
  }

  void dispose() {
    _controller.close();
  }
}

class HandAnalyzerOverlay extends StatelessWidget {
  const HandAnalyzerOverlay({super.key, required this.result});

  final HandAnalyzerResult result;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final color = _colorForSeverity(result.severity, brand);
    final textTheme = Theme.of(context).textTheme;
    final deltaLabel = _formatDelta(result.deltaEv);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EV $deltaLabel',
                style: textTheme.titleSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                result.rationale,
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                'Optimal: ${_labelForAction(result.correctAction)}',
                style: textTheme.labelSmall?.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDelta(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)} bb';
  }

  String _labelForAction(PlaybackActionType action) {
    switch (action) {
      case PlaybackActionType.bet:
        return 'Bet';
      case PlaybackActionType.raise:
        return 'Raise';
      case PlaybackActionType.call:
        return 'Call';
      case PlaybackActionType.fold:
        return 'Fold';
      case PlaybackActionType.check:
        return 'Check';
      case PlaybackActionType.win:
        return 'Win';
      case PlaybackActionType.none:
        return 'Any';
    }
  }

  Color _colorForSeverity(HandAnalyzerSeverity severity, BrandTheme? brand) {
    switch (severity) {
      case HandAnalyzerSeverity.optimal:
        return (brand?.primaryBrand ?? AppColors.accentSuccess).withValues(
          alpha: 0.85,
        );
      case HandAnalyzerSeverity.review:
        return AppColors.accentWarning.withValues(alpha: 0.9);
      case HandAnalyzerSeverity.mistake:
        return AppColors.error.withValues(alpha: 0.85);
    }
  }
}
