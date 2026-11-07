import 'dart:convert';
import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show debugPrint;

import 'act0_hnp_trace_file_store_v1.dart';

class Act0TelemetryEventV1 {
  const Act0TelemetryEventV1({required this.name, required this.fields});

  final String name;
  final Map<String, Object?> fields;
}

abstract class Act0TelemetrySinkV1 {
  void record(Act0TelemetryEventV1 event);
}

class Act0InMemoryTelemetrySinkV1 implements Act0TelemetrySinkV1 {
  final List<Act0TelemetryEventV1> _events = <Act0TelemetryEventV1>[];

  List<Act0TelemetryEventV1> get events => _events;

  @override
  void record(Act0TelemetryEventV1 event) {
    events.add(event);
  }
}

/// Local-only, opt-in diagnostic capture. It is never learning evidence.
///
/// Snapshots and privacy filtering happen before memory, console or file output.
/// Capture sequence is local to this collector; it does not invent a decision,
/// run, session, repair or transfer link missing from the producer's payload.
class Act0HnpTelemetrySinkV1 extends Act0InMemoryTelemetrySinkV1 {
  Act0HnpTelemetrySinkV1({
    this.maxEvents = 256,
    Act0HnpTraceFileStoreV1? fileStore,
  }) : _fileStore = fileStore ?? createAct0HnpTraceFileStoreV1() {
    if (maxEvents < 1) throw ArgumentError.value(maxEvents, 'maxEvents');
    final store = _fileStore;
    if (store is Act0HnpTraceHistoryReaderV1) {
      // OBS-03: continue the previous process's verified trace instead of
      // overwriting it, so a restart keeps the incident's source events.
      _loadingPrior = true;
      _pendingExport = (store as Act0HnpTraceHistoryReaderV1)
          .readPrevious()
          .then<String?>((value) => value, onError: (_) => null)
          .then((prior) {
            _adoptPriorTrace(prior);
            _loadingPrior = false;
            final offset = _recorded;
            _recorded += _bufferedRecorded;
            _rejected += _bufferedRejected;
            _evicted += _bufferedEvicted;
            _redacted += _bufferedRedacted;
            for (final (sequence, event) in _bufferedEvents) {
              _retainSnapshot(event, offset + sequence);
            }
            _bufferedEvents.clear();
            _bufferedRecorded = 0;
            _bufferedRejected = 0;
            _bufferedEvicted = 0;
            _bufferedRedacted = 0;
          });
      unawaited(_pendingExport);
    }
    _scheduleExport();
  }

  final int maxEvents;
  final Act0HnpTraceFileStoreV1? _fileStore;
  final List<Act0TelemetryEventV1> _retainedEvents = [];
  final List<int> _sequences = [];
  int _recorded = 0;
  int _rejected = 0;
  int _evicted = 0;
  int _redacted = 0;
  Future<void> _pendingExport = Future<void>.value();
  bool _exportFailureReported = false;
  bool _exportPathReported = false;
  bool _exportScheduled = false;
  bool _exportRequested = false;
  bool _loadingPrior = false;
  String _priorCapture = 'none';
  final List<(int, Act0TelemetryEventV1)> _bufferedEvents = [];
  int _bufferedRecorded = 0;
  int _bufferedRejected = 0;
  int _bufferedEvicted = 0;
  int _bufferedRedacted = 0;

  @override
  List<Act0TelemetryEventV1> get events => List.unmodifiable(_retainedEvents);

  @override
  void record(Act0TelemetryEventV1 event) {
    if (_loadingPrior) {
      // The previous process's I/O may stall. Apply the same privacy and
      // capacity boundary before retaining anything during that wait.
      final sequence = ++_bufferedRecorded;
      final (snapshot, redacted) = _snapshotHnpEventV1(event);
      _bufferedRedacted += redacted;
      if (snapshot == null) {
        _bufferedRejected++;
      } else {
        if (_bufferedEvents.length >= maxEvents) {
          _bufferedEvents.removeAt(0);
          _bufferedEvicted++;
        }
        _bufferedEvents.add((sequence, snapshot));
      }
      return;
    }
    _recordNow(event);
  }

  /// Adopts [jsonl] only if it is a complete, contiguous trace whose every
  /// row still passes this collector's event and field policy. Anything else
  /// is discarded (never merged) and the capture says so.
  void _adoptPriorTrace(String? jsonl) {
    if (jsonl == null || jsonl.trim().isEmpty) return;
    final rows = <Map<String, dynamic>>[];
    try {
      for (final line in const LineSplitter().convert(jsonl)) {
        if (line.trim().isEmpty) continue;
        final row = jsonDecode(line);
        if (row is! Map<String, dynamic>) throw const FormatException();
        rows.add(row);
      }
    } on FormatException {
      _priorCapture = 'discarded';
      return;
    }
    if (rows.isEmpty) return;
    final capture = rows.last['capture'];
    final healthOnly = rows.length == 1 && !rows.single.containsKey('name');
    if (healthOnly ||
        capture is! Map ||
        capture['schemaVersion'] is! int ||
        capture['schemaVersion'] != 1 ||
        capture['complete'] != true ||
        capture['rejectedEventCount'] is! int ||
        capture['rejectedEventCount'] != 0 ||
        capture['evictedEventCount'] is! int ||
        capture['evictedEventCount'] != 0 ||
        capture['recordedEventCount'] is! int ||
        capture['recordedEventCount'] != rows.length ||
        capture['redactedFieldCount'] is! int ||
        (capture['redactedFieldCount'] as int) < 0 ||
        rows.length > maxEvents) {
      _priorCapture = 'discarded';
      return;
    }
    final events = <Act0TelemetryEventV1>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final name = row['name'];
      final fields = row['fields'];
      if (row['sequence'] is! int ||
          row['sequence'] != i + 1 ||
          name is! String ||
          fields is! Map<String, dynamic>) {
        _priorCapture = 'discarded';
        return;
      }
      final event = Act0TelemetryEventV1(name: name, fields: fields);
      if (!_hnpEventNamesV1.contains(name) ||
          !_hnpSupportedEventVersionV1(event)) {
        _priorCapture = 'discarded';
        return;
      }
      final validatedFields = <String, Object?>{};
      for (final entry in fields.entries) {
        final filtered = _hnpFieldValueV1(entry.key, entry.value);
        if (filtered == null ||
            jsonEncode(filtered) != jsonEncode(entry.value)) {
          _priorCapture = 'discarded';
          return;
        }
        validatedFields[entry.key] = filtered;
      }
      events.add(
        Act0TelemetryEventV1(
          name: name,
          fields: Map.unmodifiable(validatedFields),
        ),
      );
    }
    _retainedEvents.addAll(events);
    _sequences.addAll([for (var i = 1; i <= events.length; i++) i]);
    _recorded = events.length;
    _redacted = capture['redactedFieldCount'] as int;
    _priorCapture = 'continued';
  }

  void _recordNow(Act0TelemetryEventV1 event) {
    final sequence = ++_recorded;
    final (snapshot, redacted) = _snapshotHnpEventV1(event);
    _redacted += redacted;
    if (snapshot == null) {
      _rejected++;
      _scheduleExport();
      return;
    }
    _retainSnapshot(snapshot, sequence);
    _scheduleExport();
  }

  void _retainSnapshot(Act0TelemetryEventV1 snapshot, int sequence) {
    if (_retainedEvents.length >= maxEvents) {
      _retainedEvents.removeAt(0);
      _sequences.removeAt(0);
      _evicted++;
    }
    _retainedEvents.add(snapshot);
    _sequences.add(sequence);
    // The console is diagnostic, but must have the same privacy boundary.
    debugPrint('HNP_TRACE_V1 ${jsonEncode(_row(_retainedEvents.length - 1))}');
  }

  Map<String, Object> get _capture => {
    'schemaVersion': 1,
    'recordedEventCount': _recorded,
    'rejectedEventCount': _rejected,
    'evictedEventCount': _evicted,
    'redactedFieldCount': _redacted,
    // Transport completeness only. It is not proof of semantic lineage,
    // learner independence, unseen transfer or elapsed retention.
    'complete': !_loadingPrior && _rejected == 0 && _evicted == 0,
    'pendingEventCount': _bufferedEvents.length,
    // 'continued': this file carries a verified prior-process trace;
    // 'discarded': a prior trace existed but failed verification.
    'priorCapture': _priorCapture,
  };

  Map<String, Object?> _row(int index) => {
    'name': _retainedEvents[index].name,
    'fields': _retainedEvents[index].fields,
    'sequence': _sequences[index],
    'capture': _capture,
  };

  String exportJson() => jsonEncode({
    'schema': 'act0_hnp_local_trace_v1',
    'capture': _capture,
    'events': [for (var i = 0; i < _retainedEvents.length; i++) _row(i)],
  });

  /// One complete retained row per physical line. A rejected or evicted event
  /// is visible in the capture counters and local sequence gaps. An empty
  /// JSONL is never evidence of a complete journey; inspect exportJson too.
  String exportJsonl() {
    final rows = [
      for (var i = 0; i < _retainedEvents.length; i++) jsonEncode(_row(i)),
    ];
    if (rows.isEmpty && _recorded > 0) {
      // Preserve rejection evidence even when no event was exportable.
      return '${jsonEncode({'capture': _capture})}\n';
    }
    return rows.isEmpty ? '' : '${rows.join('\n')}\n';
  }

  /// Local export is non-blocking; failures never affect learner execution.
  Future<void> flushExport() => _pendingExport;

  void _scheduleExport() {
    if (_fileStore == null) return;
    _exportRequested = true;
    if (_exportScheduled) return;
    _exportScheduled = true;
    _pendingExport = _pendingExport.then((_) async {
      do {
        _exportRequested = false;
        try {
          await _fileStore.replace(exportJsonl());
          if (!_exportPathReported) {
            _exportPathReported = true;
            // An OS path can contain a personal name. Do not log it.
            debugPrint('HNP_TRACE_EXPORT_V1 ready');
          }
        } catch (_) {
          if (!_exportFailureReported) {
            _exportFailureReported = true;
            debugPrint('HNP_TRACE_V1 local export unavailable.');
          }
        }
      } while (_exportRequested);
      _exportScheduled = false;
    });
    unawaited(_pendingExport);
  }
}

// Shared by immediate and restore-pending capture. The returned payload owns
// its immutable, privacy-filtered values rather than the producer's raw map.
(Act0TelemetryEventV1?, int) _snapshotHnpEventV1(Act0TelemetryEventV1 event) {
  if (!_hnpEventNamesV1.contains(event.name) ||
      !_hnpSupportedEventVersionV1(event)) {
    return (null, 0);
  }
  final fields = <String, Object?>{};
  var redacted = 0;
  for (final entry in event.fields.entries) {
    final value = _hnpFieldValueV1(entry.key, entry.value);
    if (value == null) {
      redacted++;
    } else {
      fields[entry.key] = value;
    }
  }
  return (
    Act0TelemetryEventV1(name: event.name, fields: Map.unmodifiable(fields)),
    redacted,
  );
}

// Versioned local export policy, derived from ACT0_TELEMETRY_TRUTH_MAP_v1.
// Unknown fields/events require explicit privacy review before export. No raw
// maps, arbitrary objects, exact timestamps, copy or identity fields are allowed.
Object? _hnpFieldValueV1(String key, Object? value) {
  if (_hnpCountFieldsV1.contains(key)) {
    return value is int && value >= 0 ? value : null;
  }
  if (_hnpBooleanFieldsV1.contains(key)) return value is bool ? value : null;
  if (key == 'acceptable_action_ids') {
    if (value is! List || value.length > 64) return null;
    if (value.any((item) => item is! String || !_hnpSafeTokenV1(item)))
      return null;
    return List<String>.unmodifiable(value.cast<String>());
  }
  if (!_hnpTokenFieldsV1.contains(key)) return null;
  final token = value is Enum ? value.name : value;
  return token is String && _hnpSafeTokenV1(token) ? token : null;
}

bool _hnpSafeTokenV1(String token) =>
    _hnpTokenV1.matchAsPrefix(token)?.end == token.length;

final _hnpTokenV1 = RegExp(r'^[A-Za-z0-9_][A-Za-z0-9_:|.\-]{0,511}$');

bool _hnpSupportedEventVersionV1(Act0TelemetryEventV1 event) {
  final version = event.fields['schemaVersion'];
  return version is int &&
      (version == 1 ||
          (version == 2 &&
              const {'user_choice', 'decision_made'}.contains(event.name)));
}

const _hnpEventNamesV1 = <String>{
  'decision_evidence_recorded',
  'transfer_evaluated',
  'elapsed_learning_observed',
  'repair_outcome_recorded',
  'sequence_repair_observed',
  'evidence_lineage_unavailable',
  'action_payoff_generated',
  'action_payoff_primary_action_selected',
  'action_payoff_shown',
  'action_sequence_completed',
  'action_sequence_recheck_entry',
  'action_sequence_repair_entry',
  'board_texture_personalization_classified',
  'board_texture_personalization_payoff',
  'board_texture_personalization_recheck',
  'day2_return',
  'decision_made',
  'feedback_viewed',
  'first_value_daily_rep_launched',
  'first_value_today_consumed',
  'first_value_today_shown',
  'fix_landed',
  'learning_effect_delta_completed',
  'learning_effect_delta_viewed',
  'learning_run_closed',
  'learning_run_outcome_recorded',
  'learning_run_payoff_eligible',
  'learning_run_started',
  'lesson_started',
  'next_practice_recommended',
  'personalized_next_step_opened',
  'personalized_next_step_selected',
  'position_personalization_classified',
  'position_personalization_payoff',
  'position_personalization_recheck',
  'practice_completed',
  'practice_started',
  'price_personalization_classified',
  'price_personalization_payoff',
  'price_personalization_recheck',
  'progress_persist_result',
  'prove_completed',
  'recheck_completed',
  'recheck_result',
  'recheck_started',
  'recommendation_accepted',
  'recommendation_generated',
  'recommendation_shown',
  'repair_attempted',
  'repair_completed',
  'repair_entered',
  'repair_item_completed',
  'repair_item_shown',
  'repair_item_started',
  'repair_started',
  'session_complete',
  'session_exited',
  'session_focus_selected',
  'session_payoff_completed',
  'session_payoff_generated',
  'session_payoff_skipped_insufficient_evidence',
  'session_payoff_viewed',
  'session_skill_outcome',
  'session_start',
  'starting_hand_personalization_classified',
  'starting_hand_personalization_payoff',
  'starting_hand_personalization_recheck',
  'task_result',
  'task_shown',
  'theory_completed',
  'user_choice',
  'world_complete',
};

const _hnpCountFieldsV1 = <String>{
  'created_order',
  'run_ordinal',
  'eligible_evidence_count',
  'schemaVersion',
  'worldNumber',
  'attemptOrdinal',
  'attempt_ordinal',
  'cleanRepCount',
  'clean_rep_count',
  'completedClearCount',
  'completedRepCount',
  'completed_clear_count',
  'completed_rep_count',
  'perfectClearCount',
  'perfect_clear_count',
  'successfulRecheckCount',
  'meaningful_outcome_count',
  'elapsed_run_ms',
  'event_order',
  'priority_class',
  'request_generation',
  'evidence_count',
  'openRepairCount',
  'futureRecheckCount',
  'futureProveCount',
  'completedTaskCount',
  'proveCount',
};

const _hnpBooleanFieldsV1 = <String>{
  'source_current',
  'history_lineage_complete',
  'independent_repair',
  'correct',
  'is_correct',
  'isCorrect',
  'correctness',
  'recommended',
  'causal_feedback_shown',
  'counterfactual_available',
  'payoff_eligible',
  'repair_attempted',
  'resumeInRunner',
};

const _hnpTokenFieldsV1 = <String>{
  'run_kind',
  'source_fingerprint',
  'evidence_status',
  'repair_occurrence_id',
  'baseline_attempt_id',
  'baseline_session_id',
  'comparison_attempt_id',
  'comparison_session_id',
  'elapsed_basis',
  'elapsed_bucket',
  'previous_attempt_id',
  'previous_session_id',
  'retention_state',
  'source_session_id',
  'repair_state',
  'transfer_verdict',
  'route_review_kind',
  'sequence_source_attempt_id',
  'worldId',
  'world_id',
  'lessonId',
  'lesson_id',
  'taskId',
  'task_id',
  'taskFamily',
  'phase',
  'choiceId',
  'chosen_action',
  'selected_action',
  'expected_action',
  'correct_action',
  'assistance_kind',
  'result',
  'resultSummary',
  'result_summary',
  'result_classification',
  'errorType',
  'error_type',
  'repairFamilyId',
  'repair_family_id',
  'repairStatus',
  'repairTargetTaskId',
  'repair_target_task_id',
  'repairTaskId',
  'repair_task_id',
  'repair_focus_id',
  'repairItemId',
  'sourceTaskId',
  'source_task_id',
  'targetTaskId',
  'source_attempt_key',
  'attempt_id',
  'review_kind',
  'route_source_owner',
  'operation',
  'source_user_choice',
  'user_choice',
  'proof_source',
  'delta_kind',
  'missed_signal_id',
  'source_surface',
  'sessionId',
  'session_id',
  'runId',
  'run_id',
  'sequenceId',
  'sequence_id',
  'sequence_stage',
  'decisionTimeBucket',
  'time_to_decision_bucket',
  'street_v1',
  'drill_kind',
  'option_quality',
  'feedbackSignal',
  'feedbackType',
  'feedback_classification',
  'skillReceiptId',
  'skillAtomId',
  'nextRepId',
  'skillReceiptOutcome',
  'practiceGroupId',
  'practice_group_id',
  'closure_reason',
  'completionTaskId',
  'concept_family_id',
  'createdFrom',
  'mappedTargetTaskId',
  'mappingType',
  'next_target',
  'outcome',
  'payoff_type',
  'primary_action',
  'proof_result',
  'proof_status',
  'receiptOutcome',
  'recheckTaskId',
  'recheck_task_id',
  'recheck_result',
  'recommendation_id',
  'recommendation_reason',
  'recommendation_source',
  'recommendation_target',
  'selected_focus',
  'skill_id',
  'source',
  'status',
  'surface',
  'retentionStatus',
  'reason_type',
  'evidence_kind',
  'verdict',
  'relationship',
  'outcome_type',
  'missed_signal',
  'recommendation_signal',
  'reason',
  'sourceTaskFamily',
  'targetTaskFamily',
  'resumePhase',
  'resumeState',
  'lastVisibleSurface',
  'progressState',
  'startedBy',
};

/// The one canonical-entry policy: HNP capture is debug-only and opt-in.
Act0TelemetrySinkV1? act0CanonicalTelemetrySinkV1({
  required bool hnpEnabled,
  required bool isReleaseMode,
}) => hnpEnabled && !isReleaseMode ? Act0HnpTelemetrySinkV1() : null;
