import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Internal handoff for a completed Act0 decision.
///
/// This is deliberately separate from telemetry and durable learning evidence.
/// It carries stable decision identity only; the shell retains ownership of
/// repair-intent construction and any future persistence policy.
enum Act0CompletedDecisionKindV1 { actionList, seat, sizing }

class Act0CompletedDecisionV1 {
  const Act0CompletedDecisionV1({
    this.schemaVersion = 1,
    required this.attemptKey,
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.sourceTaskId,
    required this.decisionKind,
    required this.selectedId,
    required this.expectedId,
    required this.isCorrect,
    required this.decisionTimeBucket,
    required this.taskFamily,
    required this.resultKind,
    this.errorType,
    this.skillAtomId,
    this.repairFocusId,
    this.missedSignalId,
  });

  final int schemaVersion;
  final String attemptKey;
  final String? worldId;
  final String lessonId;
  final String taskId;
  final String sourceTaskId;
  final Act0CompletedDecisionKindV1 decisionKind;
  final String selectedId;
  final String? expectedId;
  final bool isCorrect;
  final String decisionTimeBucket;
  final Act0TaskFamilyV1? taskFamily;
  final String resultKind;
  final String? errorType;
  final String? skillAtomId;
  final String? repairFocusId;
  final String? missedSignalId;
}
