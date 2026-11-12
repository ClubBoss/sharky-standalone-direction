import 'act0_betting_price_contract_v1.dart';
import 'act0_hlp02_math_core_v1.dart';
import 'act0_shell_state_v1.dart';

/// Why a lesson Price Bar shows, or withholds, a source price.
enum Hlp02SourcePriceStatusV1 {
  /// Proven pot and uncapped call: the threshold may be shown.
  verified,

  /// Proven table with nothing to call: no threshold exists.
  noCallPrice,

  /// Proven facts, but an all-in or a stack-capped call may require
  /// side-pot/uncalled-return modelling. No eligibility engine exists here.
  sidePotUnmodelled,

  /// Missing, unsupported or unproved source facts.
  unavailable,

  /// Supplied facts or table labels cannot all be true.
  contradiction,
}

/// Result of [hlp02SourcePriceReadV1]. [price] is non-null only for
/// [Hlp02SourcePriceStatusV1.verified]; [potBeforeCallBb] only when the table
/// facts themselves are proven. [reason] is the canonical reason code.
final class Hlp02SourcePriceReadV1 {
  const Hlp02SourcePriceReadV1._(
    this.status,
    this.reason, {
    this.price,
    this.potBeforeCallBb,
  });

  final Hlp02SourcePriceStatusV1 status;
  final String reason;
  final Hlp02CallPriceV1? price;
  final double? potBeforeCallBb;
}

/// A read-only consumer of the canonical table-only price read
/// ([act0TablePriceV1]); never a new ledger, pot parser or Call option.
/// Amounts are BB. Display labels alone, unproved results and test fixtures
/// are never promoted into verified source values. HLP's route policy remains
/// responsible for keeping all tools away from an independent assessed choice.
/// Pure: no XP, completion, evidence, exposure or grade is produced.
Hlp02SourcePriceReadV1 hlp02SourcePriceReadV1({
  required Act0LessonTaskV1? sourceTask,
  required String taskId,
}) {
  const unavailable = Hlp02SourcePriceStatusV1.unavailable;
  if (sourceTask == null || sourceTask.taskId != taskId) {
    return const Hlp02SourcePriceReadV1._(unavailable, 'no_source_task');
  }
  final table = sourceTask.runner.table;
  final read = act0TablePriceV1(table);
  final facts = read.facts;
  if (facts == null) {
    return Hlp02SourcePriceReadV1._(
      read.readiness == Act0TablePriceReadinessV1.contradiction
          ? Hlp02SourcePriceStatusV1.contradiction
          : unavailable,
      read.reason,
    );
  }
  // The canonical read does not expose side-pot eligibility. Any recorded
  // all-in or a stack-capped call may require side-pot/uncalled-return
  // modelling and keeps the ordinary pot binding closed.
  final allInHistory = facts.hasRecordedAllIn;
  if (allInHistory || facts.callIsStackCapped) {
    return Hlp02SourcePriceReadV1._(
      Hlp02SourcePriceStatusV1.sidePotUnmodelled,
      allInHistory ? 'all_in_history' : 'stack_capped_call',
      potBeforeCallBb: facts.potBeforeActionBb,
    );
  }
  if (!facts.facesWager) {
    return Hlp02SourcePriceReadV1._(
      Hlp02SourcePriceStatusV1.noCallPrice,
      'no_call_price',
      potBeforeCallBb: facts.potBeforeActionBb,
    );
  }
  try {
    final price = hlp02CallPriceV1(
      potBeforeCallChips: facts.potBeforeActionBb,
      additionalCallChips: facts.callCostBb,
    );
    if (price == null) {
      return const Hlp02SourcePriceReadV1._(unavailable, 'math_rejected');
    }
    return Hlp02SourcePriceReadV1._(
      Hlp02SourcePriceStatusV1.verified,
      read.reason,
      price: price,
      potBeforeCallBb: facts.potBeforeActionBb,
    );
  } on ArgumentError {
    return const Hlp02SourcePriceReadV1._(unavailable, 'math_rejected');
  }
}

/// Null means that this task cannot establish an ordinary contestable call
/// price. Kept for existing callers; see [hlp02SourcePriceReadV1].
Hlp02CallPriceV1? hlp02VerifiedSourcePriceV1({
  required Act0LessonTaskV1? sourceTask,
  required String taskId,
}) => hlp02SourcePriceReadV1(sourceTask: sourceTask, taskId: taskId).price;
