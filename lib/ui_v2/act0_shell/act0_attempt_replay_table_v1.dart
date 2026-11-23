import 'act0_attempt_archive_v1.dart';
import 'act0_authored_source_proof_v1.dart';
import 'act0_shell_state_v1.dart';
import 'act0_table_choreography_contract_v1.dart';

/// Projects saved journal positions through the existing table choreography.
class Act0AttemptReplayTableV1 {
  const Act0AttemptReplayTableV1._(this._table, this._plan);

  final Act0TableStateV1 _table;
  final Act0TableChoreographyPlanV1 _plan;

  static Act0AttemptReplayTableV1? fromAttempt(Act0ArchivedAttemptV1 attempt) {
    final table = act0VerifiedReplayTableV1(
      attempt.evidence,
      attempt.tableFingerprint,
    );
    if (table == null || attempt.events.length < table.actionTrail.length) {
      return null;
    }
    for (final (index, source) in table.actionTrail.indexed) {
      final saved = attempt.events[index];
      if (source.kind != saved.kind || source.label != saved.label) {
        return null;
      }
    }
    if (attempt.events
        .skip(table.actionTrail.length)
        .any((event) => !event.isNote)) {
      return null;
    }
    final plan = act0TableChoreographyPlanForTableV1(table);
    return plan == null ? null : Act0AttemptReplayTableV1._(table, plan);
  }

  ({Act0TableStateV1 table, bool newCommitment})? atPosition(int position) {
    if (position <= 0) return null;
    final index = _plan.beats.lastIndexWhere(
      (beat) => beat.sourceIndex != null && beat.sourceIndex! < position,
    );
    if (index < 0) return null;
    final frame = act0TableChoreographyFrameAfterBeatV1(_plan, index);
    return (
      table: act0TableForChoreographyFrameV1(
        _table,
        frame,
        showDecisionSeatDetails: false,
      ),
      newCommitment:
          frame.latestCommitmentSeatId != null &&
          _plan.beats[index].sourceIndex == position - 1,
    );
  }
}
