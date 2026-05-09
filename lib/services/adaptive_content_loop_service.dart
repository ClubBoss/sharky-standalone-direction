import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';

import 'training_pack_template_service.dart';

/// Snapshot of metrics the Adaptive Content Loop will use to decide when and
/// what to regenerate. Serves as the shared contract between tooling and the
/// in-app orchestrator.
class AdaptiveContentLoopSnapshot {
  const AdaptiveContentLoopSnapshot({
    required this.adjustmentFactor,
    required this.momentum,
    required this.fatigue,
    required this.driftPercent,
    required this.filesProcessed,
    required this.pass,
    required this.lastRunAt,
    required this.targets,
  });

  /// Behavior scaling factor produced by adaptive_behavior_summary.json.
  final double adjustmentFactor;

  /// Momentum signal (0..1) from adaptive_learning_summary.json.
  final double momentum;

  /// Fatigue signal (0..1) normalised from learning summary.
  final double fatigue;

  /// Drift correction (percentage) from the last content loop tool run.
  final double driftPercent;

  /// Number of files the tooling touched during the last pass.
  final int filesProcessed;

  /// Whether the last tooling run reported success.
  final bool pass;

  /// Timestamp of the last tooling run, if available.
  final DateTime? lastRunAt;

  /// Candidate templates that should be prioritised when generating new spots.
  final List<AdaptiveContentTarget> targets;

  /// Convenience boolean signalling whether the loop may safely execute again.
  bool get isReadyForNextPass => pass && filesProcessed > 0;

  Map<String, Object?> toJson() => {
    'adjustmentFactor': adjustmentFactor,
    'momentum': momentum,
    'fatigue': fatigue,
    'driftPercent': driftPercent,
    'filesProcessed': filesProcessed,
    'pass': pass,
    'lastRunAt': lastRunAt?.toIso8601String(),
    'targets': [for (final t in targets) t.toJson()],
  };
}

/// Minimal description of a template the adaptive loop may extend.
class AdaptiveContentTarget {
  const AdaptiveContentTarget({
    required this.templateId,
    required this.name,
    required this.completionRatio,
    required this.outstandingSpots,
  });

  final String templateId;
  final String name;
  final double completionRatio;
  final int outstandingSpots;

  Map<String, Object?> toJson() => {
    'templateId': templateId,
    'name': name,
    'completionRatio': completionRatio,
    'outstandingSpots': outstandingSpots,
  };
}

/// Base-layer orchestrator for Adaptive Content Loop v1.
///
/// This service stitches together telemetry emitted by tooling and the current
/// state of local training templates. Tooling can feed the resulting snapshot
/// back into automated generation passes, while the UI can surface a concise
/// status to creators.
class AdaptiveContentLoopService {
  AdaptiveContentLoopService._();

  static final AdaptiveContentLoopService instance =
      AdaptiveContentLoopService._();

  /// Builds a fresh snapshot by reading the latest tooling outputs and
  /// inspecting the local training templates.
  Future<AdaptiveContentLoopSnapshot> loadSnapshot({int maxTargets = 5}) async {
    final behavior = await _readJsonMap('adaptive_behavior_summary.json');
    final learning = await _readJsonMap('adaptive_learning_summary.json');
    final loop = await _readJsonMap('adaptive_loop_report.json');

    final adjustment =
        (behavior['adjustment'] as num?)?.toDouble().clamp(0.75, 1.25) ?? 1.0;
    final momentum =
        (learning['momentum'] as num?)?.toDouble().clamp(0.0, 1.0) ?? 0.0;
    double fatigue = (learning['fatigue'] as num?)?.toDouble() ?? 0.0;
    // Some pipelines emit fatigue in percent form (>1); normalise if needed.
    if (fatigue > 1.0) {
      fatigue = (fatigue / 100.0).clamp(0.0, 1.0);
    } else {
      fatigue = fatigue.clamp(0.0, 1.0);
    }
    final drift =
        (loop['driftPercentUsed'] as num?)?.toDouble() ??
        (loop['avgDelta'] as num?)?.toDouble() ??
        0.0;
    final filesProcessed = (loop['filesProcessed'] as num?)?.toInt() ?? 0;
    final pass = loop.isEmpty ? false : loop['pass'] != false;
    final lastRunAt = DateTime.tryParse(loop['timestamp']?.toString() ?? '');

    final templates = TrainingPackTemplateService.getAllTemplates();
    final targets = templates
        .where((tpl) => tpl.goalTarget > 0 && tpl.goalProgress < tpl.goalTarget)
        .map(
          (tpl) => AdaptiveContentTarget(
            templateId: tpl.id,
            name: tpl.name,
            completionRatio: tpl.goalTarget == 0
                ? 1.0
                : tpl.goalProgress / tpl.goalTarget,
            outstandingSpots: tpl.spots.isNotEmpty
                ? tpl.spots.length
                : tpl.spotCount,
          ),
        )
        .sorted((a, b) => a.completionRatio.compareTo(b.completionRatio))
        .take(maxTargets)
        .toList(growable: false);

    return AdaptiveContentLoopSnapshot(
      adjustmentFactor: adjustment,
      momentum: momentum,
      fatigue: fatigue,
      driftPercent: drift,
      filesProcessed: filesProcessed,
      pass: pass,
      lastRunAt: lastRunAt,
      targets: targets,
    );
  }

  Future<Map<String, dynamic>> _readJsonMap(String path) async {
    final file = File(path);
    if (!await file.exists()) return const {};
    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return const {};
  }
}
