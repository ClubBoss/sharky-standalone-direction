import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

enum Act0StreetReplayStreetV1 { preflop, flop, turn, river }

enum Act0StreetReplayCompletenessV1 { complete, partialSafe, insufficient }

class Act0StreetReplayV1 {
  const Act0StreetReplayV1({
    required this.steps,
    required this.currentStreet,
    required this.completeness,
    required this.heroPosition,
    this.opponentPosition = '',
    this.effectiveStackBb = '',
    required this.currentDecisionActor,
    this.currentDecisionSummaryKey = '',
    this.sourceRefs = const <String>[],
    this.keyClue = '',
    this.decisionContext = '',
    this.sourceLabel = 'act0_table_action_trail_v1',
  });

  final List<Act0StreetReplayStepV1> steps;
  final Act0StreetReplayStreetV1 currentStreet;
  final Act0StreetReplayCompletenessV1 completeness;
  final String heroPosition;
  final String opponentPosition;
  final String effectiveStackBb;
  final String currentDecisionActor;
  final String currentDecisionSummaryKey;
  final List<String> sourceRefs;
  final String keyClue;
  final String decisionContext;
  final String sourceLabel;

  bool get isConsumerSafe =>
      completeness != Act0StreetReplayCompletenessV1.insufficient &&
      steps.isNotEmpty;
}

class Act0StreetReplayStepV1 {
  const Act0StreetReplayStepV1({
    required this.street,
    required this.actionSummary,
    required this.actorLabel,
    required this.actionTypeLabel,
    required this.order,
    this.amountLabel = '',
    this.boardCardsAtStreet = const <String>[],
    this.potAtStreet = '',
    this.isCurrentStreet = false,
    this.compactLabel = '',
  });

  final Act0StreetReplayStreetV1 street;
  final String actionSummary;
  final String actorLabel;
  final String actionTypeLabel;
  final String amountLabel;
  final int order;
  final List<String> boardCardsAtStreet;
  final String potAtStreet;
  final bool isCurrentStreet;
  final String compactLabel;

  String get streetLabel => switch (street) {
    Act0StreetReplayStreetV1.preflop => 'Preflop',
    Act0StreetReplayStreetV1.flop => 'Flop',
    Act0StreetReplayStreetV1.turn => 'Turn',
    Act0StreetReplayStreetV1.river => 'River',
  };

  String get youAreHereLabel => isCurrentStreet ? 'You are here' : '';
}

enum Act0BettingRoundOrderTruthV1 { unproved, consistent, contradiction }

/// Checks turn order and round boundaries only for an ordinary, fully supplied
/// blind-start history. This does not certify prices, minimum raises, pot
/// accounting, all-in reopening/side pots, catalog applicability, or an answer.
/// Explicit all-in actors cannot act again; this does not complete their hand.
///
/// Missing participation/stack facts or grammar outside the existing replay
/// parser leave this proof unproved. They must not be relabeled as valid poker.
Act0BettingRoundOrderTruthV1 act0BettingRoundOrderTruthForTableV1(
  Act0TableStateV1 table,
) => act0BettingRoundOrderProofForTableV1(table).truth;

/// The same proof with a stable reason code, so every unproved or
/// contradicting table names exactly why (for inventories and review).
({Act0BettingRoundOrderTruthV1 truth, String reason})
act0BettingRoundOrderProofForTableV1(Act0TableStateV1 table) {
  final result = _act0BettingRoundOrderProofV1(table);
  return (truth: result.$1, reason: result.$2);
}

/// A CONDITIONAL reading, kept apart from the proof above. It replays what the
/// source shows under explicitly named assumptions and reports every
/// assumption it used; it never adds a check, bet, call or raise:
/// - blinds_posted_unrecorded: a fragment without posts had the 0.5/1 blinds;
/// - unrecorded_exit_folded_in_turn: a seat out of the hand without a
///   recorded fold folded at its own turn (the only legal way out);
/// - unrecorded_exit_before_fragment: such a seat left before a fragment that
///   starts on a later street;
/// - unsized_call_matches_price: "X calls" without an amount calls the price;
/// - current_actor_has_chips / live_opponents_have_chips /
///   live_players_have_chips: unauthored stacks hold chips;
/// - shown_items_are_consecutive: no action is hidden between shown items;
/// - prefix_limps_unknown: seats still in the hand before an aggressive
///   first shown action may have limped; they must answer it either way.
/// A 'consistent' result here is "consistent if the assumptions hold", never a
/// proof. An explicit zero stack is never assumed away.
({Act0BettingRoundOrderTruthV1 truth, String reason, List<String> assumptions})
act0BettingRoundOrderConditionalProofForTableV1(Act0TableStateV1 table) {
  final assumptions = <String>{};
  final result = _act0BettingRoundOrderProofV1(table, assume: assumptions);
  final sorted = assumptions.toList()..sort();
  return (
    truth: result.$1,
    reason: sorted.isEmpty
        ? result.$2
        : result.$1 == Act0BettingRoundOrderTruthV1.consistent
        ? 'consistent_if_assumptions_hold'
        : result.$1 == Act0BettingRoundOrderTruthV1.contradiction
        ? 'contradiction_if_assumptions_hold:${result.$2}'
        : result.$2,
    assumptions: List<String>.unmodifiable(sorted),
  );
}

const _act0AllInVerbsV1 = <String>{'shove', 'shoves', 'jam', 'jams'};

(Act0BettingRoundOrderTruthV1, String) _act0BettingRoundOrderProofV1(
  Act0TableStateV1 table, {
  Set<String>? assume,
}) {
  const unproved = Act0BettingRoundOrderTruthV1.unproved;
  const contradiction = Act0BettingRoundOrderTruthV1.contradiction;
  const consistent = Act0BettingRoundOrderTruthV1.consistent;
  final deduce = assume != null;
  // Assumptions used by the conditional reading (always empty in the proof).
  final used = assume ?? <String>{};
  if (table.scope != Act0TableScopeV1.playedHand ||
      !table.usesCanonicalPlayerCount ||
      table.seats.length != table.playerCount) {
    return (unproved, 'not_ordinary_played_hand');
  }
  // A source-recorded shove ends only this player's betting eligibility.
  // Check this before unsupported grammar or sparse stacks can erase it.
  final allInActors = <String>{};
  for (final item in table.actionTrail) {
    if (item.isNote) continue;
    final label = item.label.trim();
    final prefix = _act0StreetReplayStreetFromTrailLabelV1(label);
    final parsed = _act0StreetReplayParseActionV1(
      _act0StreetReplayActionLabelV1(label, prefix),
    );
    if (parsed == null) continue;
    final actor = parsed.actorLabel.toUpperCase();
    if (allInActors.contains(actor)) {
      return (contradiction, 'all_in_actor_acts_again');
    }
    if (_act0AllInVerbsV1.contains(parsed.actionTypeLabel.toLowerCase())) {
      allInActors.add(actor);
    }
  }
  final currentActor = _act0StreetReplaySeatByIdV1(table, table.activeSeatId);
  if (currentActor != null &&
      (allInActors.contains(currentActor.seatLabel.trim().toUpperCase()) ||
          currentActor.bet?.kind == Act0SeatBetKindV1.allIn)) {
    return (contradiction, 'current_actor_all_in');
  }
  final canonicalOrder = table.canonicalSeatOrder;
  final emptySeats = <String>{};
  final seatByActor = <String, Act0SeatStateV1>{};
  final seatIds = <String>{};
  var stacksUnproved = false;
  var zeroStackSeen = false;
  final positiveStack = <String>{};
  final zeroStack = <String>{};
  final stackPattern = RegExp(r'^(\d+(?:\.\d+)?)\s+BB$', caseSensitive: false);
  for (final seat in table.seats) {
    final actor = seat.seatLabel.trim().toUpperCase();
    final stack = stackPattern.firstMatch(seat.stackLabel?.trim() ?? '');
    final remaining = double.tryParse(stack?.group(1) ?? '');
    // An empty seat is not a player: it never posts, acts or owes a reply.
    if (!seat.isOccupied &&
        canonicalOrder.contains(actor) &&
        !emptySeats.contains(actor) &&
        seatIds.add(seat.seatId)) {
      emptySeats.add(actor);
      continue;
    }
    // A seat marked all-in is only usable when the trail records its shove.
    if (!seat.isOccupied ||
        !canonicalOrder.contains(actor) ||
        seatByActor.containsKey(actor) ||
        !seatIds.add(seat.seatId) ||
        (seat.bet?.kind == Act0SeatBetKindV1.allIn &&
            !allInActors.contains(actor))) {
      return (unproved, 'roster_incomplete_or_marked_all_in');
    }
    // A positive remaining stack is supplied evidence that this participant
    // is not already all-in. Missing/zero stacks do not invent an obligation.
    if (remaining == null || !remaining.isFinite || remaining <= 0) {
      stacksUnproved = true;
      if (remaining != null && remaining <= 0) {
        zeroStack.add(actor);
        // A recorded shove explains zero chips behind.
        if (!allInActors.contains(actor)) zeroStackSeen = true;
      }
    } else {
      positiveStack.add(actor);
    }
    seatByActor[actor] = seat;
  }
  // One label on both an empty and an occupied seat is an ambiguous roster.
  if (emptySeats.any(seatByActor.containsKey)) {
    return (unproved, 'roster_incomplete_or_marked_all_in');
  }
  // A dead button or an empty blind is outside the ordinary blind-start proof.
  if (const {'BTN', 'SB', 'BB'}.any(emptySeats.contains)) {
    return (unproved, 'dead_button_or_empty_blind');
  }
  final order = [
    for (final actor in canonicalOrder)
      if (!emptySeats.contains(actor)) actor,
  ];

  // A trailing "<SEAT> acts" / "Hero acts" item is the authored current-
  // decision marker, not a betting action. It must be the last recorded item
  // and name the active seat; it never moves chips or closes a round.
  String? markedActor;
  final recorded = [
    for (final item in table.actionTrail)
      if (!item.isNote) item.label.trim(),
  ];
  final markerPattern = RegExp(r'^(\S+)\s+acts$', caseSensitive: false);
  for (var i = 0; i < recorded.length; i++) {
    final marker = markerPattern.firstMatch(
      _act0StreetReplayActionLabelV1(
        recorded[i],
        _act0StreetReplayStreetFromTrailLabelV1(recorded[i]),
      ),
    );
    if (marker == null) continue;
    if (i != recorded.length - 1) {
      return (contradiction, 'decision_marker_not_last');
    }
    final token = marker.group(1)!.toUpperCase();
    markedActor = token == 'HERO'
        ? table.heroSeat.seatLabel.trim().toUpperCase()
        : token;
    final active = _act0StreetReplaySeatByIdV1(table, table.activeSeatId);
    if (active != null &&
        active.seatLabel.trim().toUpperCase() != markedActor) {
      return (contradiction, 'decision_marker_not_active_seat');
    }
  }

  final actions =
      <
        ({
          Act0StreetReplayStreetV1 street,
          String actor,
          String verb,
          double? amount,
          bool additional,
        })
      >[];
  var parsedStreet = Act0StreetReplayStreetV1.preflop;
  var streetKnown = false;
  var prefixSeen = false;
  var leadingUnprefixed = 0;
  for (final item in table.actionTrail) {
    if (item.isNote) continue;
    final label = item.label.trim();
    final prefix = _act0StreetReplayStreetFromTrailLabelV1(label);
    if (prefix != null) {
      parsedStreet = prefix;
      prefixSeen = true;
    }
    // A trail that starts with the blinds, or any street prefix, fixes the
    // street; a bare mid-street fragment does not.
    if (prefix != null ||
        RegExp(
          r'^SB\s+(blind|posts)\b',
          caseSensitive: false,
        ).hasMatch(label)) {
      streetKnown = true;
    }
    final action = _act0StreetReplayActionLabelV1(label, prefix);
    if (markedActor != null && markerPattern.hasMatch(action)) {
      // The decision belongs to the street the snapshot shows.
      if (streetKnown &&
          parsedStreet !=
              _act0StreetReplayStreetFromLabelV1(table.streetLabel)) {
        return (contradiction, 'decision_marker_wrong_street');
      }
      if (prefix != null &&
          (parsedStreet != Act0StreetReplayStreetV1.preflop ||
              actions.length >= 2)) {
        actions.add((
          street: parsedStreet,
          actor: '',
          verb: '',
          amount: null,
          additional: false,
        ));
      }
      continue;
    }
    if (action.isEmpty) {
      // A source street marker is still a round boundary even without an
      // actor. Do not discard the obligation to finish the preceding round.
      if (prefix != null &&
          (parsedStreet != Act0StreetReplayStreetV1.preflop ||
              actions.length >= 2)) {
        actions.add((
          street: parsedStreet,
          actor: '',
          verb: '',
          amount: null,
          additional: false,
        ));
      }
      continue;
    }
    final opens = RegExp(
      r'^(\S+)\s+opens\s+(\d+(?:\.\d+)?)\s+BB$',
      caseSensitive: false,
    ).firstMatch(action);
    final parsed = opens != null
        ? (
            actorLabel: opens.group(1)!,
            actionTypeLabel: 'opens',
            amountLabel: '${opens.group(2)} BB',
          )
        : _act0StreetReplayParseActionV1(action);
    if (parsed == null) return (unproved, 'unsupported_grammar');
    final actor = parsed.actorLabel.trim().toUpperCase();
    final verb = parsed.actionTypeLabel.toLowerCase();
    final passive = const {'check', 'checks', 'fold', 'folds'}.contains(verb);
    final numeric = const {
      'blind',
      'posts',
      'call',
      'calls',
      'bet',
      'bets',
      'raise',
      'raises',
      'opens',
      ..._act0AllInVerbsV1,
    }.contains(verb);
    if (emptySeats.contains(actor)) {
      return (contradiction, 'empty_seat_acts');
    }
    if (!seatByActor.containsKey(actor) || (!passive && !numeric)) {
      return (unproved, 'unsupported_grammar');
    }
    // An unsized call is read only in the conditional mode, as a call to the
    // current price; the proof keeps requiring an authored amount.
    final unsizedCall =
        deduce &&
        const {'call', 'calls'}.contains(verb) &&
        parsed.amountLabel.isEmpty &&
        action.split(RegExp(r'\s+')).length == 2;
    // The declared first hand authors both raise-to and additional-call
    // amounts. Keep those meanings distinct; arbitrary suffixes still fail.
    final additional =
        const {'call', 'calls'}.contains(verb) &&
        action.toLowerCase().endsWith(' bb more');
    var comparableAction = action.split(RegExp(r'\s+')).join(' ');
    if (verb == 'opens') {
      comparableAction = '${parsed.actorLabel} opens ${parsed.amountLabel}';
    }
    if (const {'raise', 'raises', ..._act0AllInVerbsV1}.contains(verb)) {
      comparableAction = comparableAction.replaceFirst(
        RegExp(r'\s+to\s+', caseSensitive: false),
        ' ',
      );
    }
    if (additional) {
      comparableAction = comparableAction.substring(
        0,
        comparableAction.length - 5,
      );
    }
    final expected =
        '${parsed.actorLabel} ${parsed.actionTypeLabel}'
        '${numeric && !unsizedCall ? ' ${parsed.amountLabel}' : ''}';
    if (comparableAction.toUpperCase() != expected.toUpperCase()) {
      return (unproved, 'unsupported_grammar');
    }
    final amount = numeric && !unsizedCall
        ? double.tryParse(parsed.amountLabel.split(' ').first)
        : null;
    if (numeric &&
        !unsizedCall &&
        (amount == null || !amount.isFinite || amount <= 0)) {
      return (unproved, 'unsupported_amount');
    }
    if (unsizedCall) used.add('unsized_call_matches_price');
    if (!prefixSeen) leadingUnprefixed++;
    actions.add((
      street: parsedStreet,
      actor: actor,
      verb: verb,
      amount: amount,
      additional: additional,
    ));
  }
  bool isPost(String verb) => verb == 'blind' || verb == 'posts';
  bool isAggressive(String verb) => const {
    'bet',
    'bets',
    'raise',
    'raises',
    'opens',
    ..._act0AllInVerbsV1,
  }.contains(verb);
  if (actions.every((action) => action.verb.isEmpty)) {
    // A snapshot without any recorded action makes no sequence claim.
    return (unproved, 'no_recorded_history');
  }
  final snapshotStreet = _act0StreetReplayStreetFromLabelV1(table.streetLabel);
  if (snapshotStreet == null) return (unproved, 'unknown_snapshot_street');
  final startsWithBlinds =
      actions.length >= 2 &&
      actions[0].street == Act0StreetReplayStreetV1.preflop &&
      actions[1].street == Act0StreetReplayStreetV1.preflop &&
      actions[0].actor == 'SB' &&
      actions[1].actor == 'BB' &&
      isPost(actions[0].verb) &&
      isPost(actions[1].verb) &&
      actions[0].amount == 0.5 &&
      actions[1].amount == 1;
  if (actions.skip(startsWithBlinds ? 2 : 0).any((a) => isPost(a.verb))) {
    return (unproved, 'history_starts_after_blinds');
  }
  // Conditional mode only: a fragment without posts. Unprefixed leading items
  // belong to the street before the first prefixed one, else the snapshot's.
  var fragmentStart = false;
  String? prefixUnknownActor;
  if (!startsWithBlinds) {
    if (!deduce) return (unproved, 'history_starts_after_blinds');
    final firstPrefixed = leadingUnprefixed < actions.length
        ? actions[leadingUnprefixed].street
        : null;
    final leadStreet = firstPrefixed == null
        ? snapshotStreet
        : Act0StreetReplayStreetV1.values[firstPrefixed.index == 0
              ? 0
              : firstPrefixed.index - 1];
    for (var i = 0; i < leadingUnprefixed; i++) {
      final a = actions[i];
      actions[i] = (
        street: leadStreet,
        actor: a.actor,
        verb: a.verb,
        amount: a.amount,
        additional: a.additional,
      );
    }
    if (actions.first.street == Act0StreetReplayStreetV1.preflop) {
      if (!seatByActor.containsKey('SB') || !seatByActor.containsKey('BB')) {
        return (unproved, 'history_starts_after_blinds');
      }
      used.add('blinds_posted_unrecorded');
      // Seats between the big blind and the first shown actor must have acted
      // before it. Out of the hand: they folded (deduced below). Still in the
      // hand: they limped, which the fragment does not show, unless the first
      // shown action is an open, which excludes limpers outright.
      final first = actions.first;
      final from = order.indexOf('BB');
      final to = order.indexOf(first.actor);
      final before = <String>[
        for (
          var i = (from + 1) % order.length;
          i != to;
          i = (i + 1) % order.length
        )
          order[i],
      ];
      final liveBefore = before.where(
        (seat) => seatByActor[seat]!.isInHand && !seatByActor[seat]!.isFolded,
      );
      if (liveBefore.isNotEmpty) {
        if (first.verb == 'opens') {
          return (contradiction, 'open_with_seats_still_in_hand_before');
        }
        // Possible limps before an aggressive first action do not change who
        // must answer it; anything else leaves the start of the hand unknown.
        if (!isAggressive(first.verb)) {
          return (unproved, 'fragment_prefix_unknown');
        }
        used.add('prefix_limps_unknown');
        prefixUnknownActor = first.actor;
      }
      actions.insertAll(0, [
        (
          street: Act0StreetReplayStreetV1.preflop,
          actor: 'SB',
          verb: 'blind',
          amount: 0.5,
          additional: false,
        ),
        (
          street: Act0StreetReplayStreetV1.preflop,
          actor: 'BB',
          verb: 'blind',
          amount: 1,
          additional: false,
        ),
      ]);
    } else {
      fragmentStart = true;
    }
  }
  final executedFolds = actions
      .where((action) => action.verb == 'fold' || action.verb == 'folds')
      .map((action) => action.actor)
      .toSet();
  final recordedActors = {for (final a in actions) a.actor};
  // Seats out of the hand at the snapshot with no recorded fold.
  final unrecordedExits = <String>{
    for (final entry in seatByActor.entries)
      if ((!entry.value.isInHand || entry.value.isFolded) &&
          !executedFolds.contains(entry.key))
        entry.key,
  };
  if (unrecordedExits.isNotEmpty && !deduce) {
    // Snapshot flags cannot supply an omitted historical fold or establish
    // the time at which a participant left the hand.
    return (unproved, 'out_of_hand_without_recorded_fold');
  }

  // The final source street is itself a boundary even before its first action.
  // It cannot erase a response still owed on the preceding street.
  if (actions.last.street != snapshotStreet) {
    actions.add((
      street: snapshotStreet,
      actor: '',
      verb: '',
      amount: null,
      additional: false,
    ));
  }

  final live = order.toSet();
  final allIn = <String>{};
  var pending = order.toSet();
  final committed = <String, double>{'SB': 0.5, 'BB': 1};
  var price = 1.0;
  var street = Act0StreetReplayStreetV1.preflop;
  var lastActorIndex = order.indexOf('BB');
  var preflopVoluntaryCommit = false;
  var lastFullIncrement = 1.0;
  var incompleteAllInOnStreet = false;
  final lastVerb = <String, String>{};
  var startIndex = 2;
  if (prefixUnknownActor != null) {
    // The first shown aggressive action is taken as in turn after the posts.
    lastActorIndex =
        (order.indexOf(prefixUnknownActor) - 1 + order.length) % order.length;
  }
  if (fragmentStart) {
    // A fragment that starts on a later street: seats out of the hand that
    // never act in it left before it (assumed, and named).
    startIndex = 0;
    street = actions.first.street;
    for (final seat in unrecordedExits) {
      if (!recordedActors.contains(seat)) {
        live.remove(seat);
        used.add('unrecorded_exit_before_fragment');
      }
    }
    pending = live.toSet();
    committed.clear();
    price = 0;
    final first = actions.first;
    final explicitStart = leadingUnprefixed == 0;
    if (!explicitStart) {
      // Its first shown action is not known to open the street; only an
      // aggressive action fixes who must respond afterwards.
      if (!isAggressive(first.verb))
        return (unproved, 'fragment_start_unknown');
      lastActorIndex =
          (order.indexOf(first.actor) - 1 + order.length) % order.length;
    } else {
      lastActorIndex = order.indexOf('BTN');
    }
  }
  String? nextActor() {
    for (var offset = 1; offset <= order.length; offset++) {
      final actor = order[(lastActorIndex + offset) % order.length];
      if (pending.contains(actor)) return actor;
    }
    return null;
  }

  bool foldDeducedExit(String? seat, bool later) {
    if (!deduce || seat == null || later) return false;
    if (!unrecordedExits.contains(seat) || !live.contains(seat)) return false;
    live.remove(seat);
    pending.remove(seat);
    lastActorIndex = order.indexOf(seat);
    used.add('unrecorded_exit_folded_in_turn');
    return true;
  }

  for (
    var actionIndex = startIndex;
    actionIndex < actions.length;
    actionIndex++
  ) {
    final action = actions[actionIndex];
    bool actsLater(String actor) => actions
        .skip(actionIndex)
        .any((later) => later.actor == actor && later.verb.isNotEmpty);
    if (action.street != street) {
      if (action.street.index != street.index + 1) {
        return (contradiction, 'street_skipped_or_backwards');
      }
      // Deduced exits still owing a reply fold in turn before the street ends.
      while (deduce &&
          pending.isNotEmpty &&
          foldDeducedExit(nextActor(), actsLater(nextActor() ?? ''))) {}
      if (deduce && pending.isNotEmpty && live.length >= 2) {
        used
          ..add('shown_items_are_consecutive')
          ..add('live_players_have_chips');
        return (contradiction, 'round_not_closed_or_hand_over');
      }
      if (pending.isNotEmpty || live.length < 2) {
        // Unknown all-in/stack states may explain a pending response.
        // A source-recorded later action proves that participant cannot have
        // been all-in and silently exempt from the preceding response.
        return !stacksUnproved || pending.any(actsLater) || live.length < 2
            ? (contradiction, 'round_not_closed_or_hand_over')
            : (unproved, 'pending_response_may_be_all_in');
      }
      street = action.street;
      pending = live.difference(allIn);
      // With fewer than two players able to bet, no betting round happens.
      if (pending.length < 2) pending.clear();
      committed.clear();
      price = 0;
      lastFullIncrement = 1;
      incompleteAllInOnStreet = false;
      lastActorIndex = order.indexOf('BTN');
    }
    if (action.verb.isEmpty) continue;
    if (live.length < 2 || pending.isEmpty) {
      // Once the betting round or hand ends, no stack interpretation can
      // restore a turn on the same street.
      return (contradiction, 'action_after_round_or_hand_closed');
    }
    // A recorded fold irrevocably ends this actor's participation. Unknown
    // display stacks cannot make the already-folded player eligible again.
    if (!live.contains(action.actor)) {
      return (contradiction, 'folded_actor_acts');
    }
    while (action.actor != nextActor() &&
        foldDeducedExit(nextActor(), actsLater(nextActor() ?? ''))) {}
    if (action.actor != nextActor()) {
      // The last actor cannot act twice without another player's reopening
      // action. This also rejects BTN acting first postflop in a live
      // two-player pot; unknown stacks cannot make such an action legal.
      if (action.actor == order[lastActorIndex]) {
        return (contradiction, 'same_actor_acts_twice');
      }
      if (actsLater(nextActor()!)) return (contradiction, 'out_of_turn_actor');
      if (deduce) {
        // Read as shown: consecutive items, live players holding chips.
        used
          ..add('shown_items_are_consecutive')
          ..add('live_players_have_chips');
        return (contradiction, 'out_of_turn_actor');
      }
      return stacksUnproved
          ? (unproved, 'out_of_turn_may_skip_all_in')
          : (contradiction, 'out_of_turn_actor');
    }
    Set<String> reopened() =>
        live.where((a) => a != action.actor && !allIn.contains(a)).toSet();
    // Aggression needs someone who can still answer it, and a raise after an
    // incomplete all-in raise depends on the reopen rule (PKR-06 sizing).
    if (isAggressive(action.verb) && (action.amount ?? 0) > price) {
      if (reopened().isEmpty) {
        // A raise nobody can answer is contradictory. An all-in above the
        // price may instead contain uncalled excess, but no return/refund is
        // recorded here, so the supplied history cannot prove its final pot.
        if (_act0AllInVerbsV1.contains(action.verb)) {
          return (unproved, 'uncalled_all_in_excess_unproved');
        }
        return (contradiction, 'aggression_without_responder');
      }
      if (incompleteAllInOnStreet) {
        return (unproved, 'raise_after_incomplete_all_in');
      }
    }
    switch (action.verb) {
      case 'fold':
      case 'folds':
        live.remove(action.actor);
        pending.remove(action.actor);
      case 'check':
      case 'checks':
        if ((committed[action.actor] ?? 0) != price) {
          return (contradiction, 'illegal_check_facing_bet');
        }
        pending.remove(action.actor);
      case 'call':
      case 'calls':
        final callTo = action.amount == null
            ? price
            : action.additional
            ? (committed[action.actor] ?? 0) + action.amount!
            : action.amount;
        if (price <= 0 || callTo != price) {
          return (unproved, 'unsupported_call_amount');
        }
        committed[action.actor] = price;
        pending.remove(action.actor);
      case 'opens':
        // An open is the first voluntary preflop raise; it cannot follow one.
        // Limpers count: an open after any voluntary commitment is not first-in.
        if (street != Act0StreetReplayStreetV1.preflop ||
            price != 1 ||
            preflopVoluntaryCommit) {
          return (unproved, 'open_not_first_in_preflop');
        }
        if (action.amount! <= price) return (unproved, 'unsupported_amount');
        lastFullIncrement = action.amount! - price;
        price = action.amount!;
        committed[action.actor] = price;
        pending = reopened();
      case 'bet':
      case 'bets':
      case 'raise':
      case 'raises':
        final isBet = action.verb == 'bet' || action.verb == 'bets';
        if (action.amount! <= price || isBet != (price == 0)) {
          return (unproved, 'unsupported_amount');
        }
        lastFullIncrement = action.amount! - price;
        price = action.amount!;
        committed[action.actor] = price;
        pending = reopened();
      case 'shove':
      case 'shoves':
      case 'jam':
      case 'jams':
        // All-in: above the price it reopens like a bet/raise to that total;
        // at or below it, it is an all-in call. Either way the actor is done.
        allIn.add(action.actor);
        if (action.amount! > price) {
          if (action.amount! - price < lastFullIncrement) {
            incompleteAllInOnStreet = true;
          } else {
            lastFullIncrement = action.amount! - price;
          }
          price = action.amount!;
          committed[action.actor] = price;
          pending = reopened();
        } else {
          committed[action.actor] = action.amount!;
          pending.remove(action.actor);
        }
      default:
        return (unproved, 'unsupported_grammar');
    }
    if (street == Act0StreetReplayStreetV1.preflop &&
        action.verb != 'fold' &&
        action.verb != 'folds' &&
        action.verb != 'check' &&
        action.verb != 'checks') {
      preflopVoluntaryCommit = true;
    }
    lastVerb[action.actor] = action.verb;
    lastActorIndex = order.indexOf(action.actor);
    if (live.length < 2) pending.clear();
  }

  // Recorded actions are source evidence that their actor had chips at that
  // moment, so a fully discharged history needs no stack labels. A decision
  // that has not happened yet needs a positive authored stack for its actor
  // (the marker alone is not that evidence), and an explicit zero stack makes
  // the actor unable to decide. Facing no bet, a decision also needs an
  // opponent who can still act: a positive authored stack, or a check as the
  // last recorded action (a check commits nothing, so its chips remain).
  bool opponentCanAct(String actor, {required bool assumeChips}) => live.any(
    (p) =>
        p != actor &&
        !allIn.contains(p) &&
        !zeroStack.contains(p) &&
        (positiveStack.contains(p) ||
            lastVerb[p] == 'check' ||
            lastVerb[p] == 'checks' ||
            assumeChips),
  );
  (Act0BettingRoundOrderTruthV1, String) decision(String actor) {
    if (zeroStack.contains(actor)) {
      return (contradiction, 'current_actor_has_no_chips');
    }
    final facingBet = (committed[actor] ?? 0) < price;
    if (!facingBet &&
        !opponentCanAct(actor, assumeChips: true) &&
        live.where((p) => p != actor).every(allIn.contains)) {
      return (contradiction, 'no_opponent_can_act');
    }
    if (!positiveStack.contains(actor)) {
      if (!deduce) return (unproved, 'current_actor_stack_unknown');
      used.add('current_actor_has_chips');
    }
    if (!facingBet && !opponentCanAct(actor, assumeChips: false)) {
      if (!deduce) return (unproved, 'opponents_may_be_all_in');
      used.add('live_opponents_have_chips');
    }
    return (consistent, 'consistent_current_decision');
  }

  // Deduced exits ahead of the decision fold in turn first (conditional only).
  void foldExitsBefore(String? decider) {
    while (deduce &&
        pending.isNotEmpty &&
        nextActor() != decider &&
        foldDeducedExit(nextActor(), false)) {}
  }

  final activeId = table.activeSeatId?.trim() ?? '';
  if (activeId.isEmpty) {
    if (markedActor != null) {
      foldExitsBefore(markedActor);
      if (pending.isEmpty || live.length < 2) {
        return (contradiction, 'decision_after_round_or_hand_closed');
      }
      if (!live.contains(markedActor)) {
        return (contradiction, 'active_actor_folded');
      }
      if (markedActor != nextActor()) {
        if (deduce) {
          used
            ..add('shown_items_are_consecutive')
            ..add('live_players_have_chips');
          return (contradiction, 'current_actor_out_of_turn');
        }
        return stacksUnproved
            ? (unproved, 'current_actor_may_skip_all_in')
            : (contradiction, 'current_actor_out_of_turn');
      }
      if (zeroStackSeen && !zeroStack.contains(markedActor)) {
        return (unproved, 'zero_stack_outside_proof');
      }
      return decision(markedActor);
    }
    foldExitsBefore(null);
    if (zeroStackSeen) return (unproved, 'zero_stack_outside_proof');
    return pending.isEmpty
        ? (consistent, 'consistent_closed_history')
        : (unproved, 'pending_response_without_current_actor');
  }
  final active = _act0StreetReplaySeatByIdV1(table, activeId);
  if (active == null) return (unproved, 'active_seat_missing');
  final activeActor = active.seatLabel.trim().toUpperCase();
  foldExitsBefore(activeActor);
  if (pending.isEmpty || live.length < 2) {
    return (contradiction, 'decision_after_round_or_hand_closed');
  }
  if (!live.contains(activeActor)) {
    return (contradiction, 'active_actor_folded');
  }
  if (activeActor != nextActor()) {
    if (activeActor == order[lastActorIndex]) {
      return (contradiction, 'current_actor_acts_twice');
    }
    if (deduce) {
      used
        ..add('shown_items_are_consecutive')
        ..add('live_players_have_chips');
      return (contradiction, 'current_actor_out_of_turn');
    }
    return stacksUnproved
        ? (unproved, 'current_actor_may_skip_all_in')
        : (contradiction, 'current_actor_out_of_turn');
  }
  if (zeroStackSeen && !zeroStack.contains(activeActor)) {
    return (unproved, 'zero_stack_outside_proof');
  }
  return decision(activeActor);
}

Act0StreetReplayV1? act0StreetReplayFromTableV1(Act0TableStateV1 table) {
  // Scope is authored independently of parser success. A seat map or chip
  // diagram must never become a hand history merely because a label parses.
  if (table.scope != Act0TableScopeV1.playedHand) return null;
  final trailLabels = table.actionTrail
      // Keep the original source index when a note is skipped.
      .map((item) => item.isNote ? '' : item.label.trim())
      .toList(growable: false);
  final currentStreet = _act0StreetReplayStreetFromLabelV1(table.streetLabel);
  if (!trailLabels.any((label) => label.isNotEmpty) || currentStreet == null) {
    return null;
  }

  final heroSeat = table.heroSeat;
  final heroPosition = heroSeat.seatLabel.trim();
  final activeSeat = _act0StreetReplaySeatByIdV1(table, table.activeSeatId);
  final currentDecisionActor = activeSeat?.displayName.trim().isNotEmpty == true
      ? activeSeat!.displayName.trim()
      : activeSeat?.seatLabel.trim() ?? '';
  final opponentPosition = table.seats
      .where((seat) => !seat.isHero)
      .map((seat) => seat.seatLabel.trim())
      .firstWhere((label) => label.isNotEmpty, orElse: () => '');
  final effectiveStackBb = _act0StreetReplayEffectiveStackV1(table);
  final sourceRefs = <String>[
    'streetLabel',
    'actionTrail',
    if ((table.activeSeatId ?? '').trim().isNotEmpty) 'activeSeatId',
    if ((table.heroSeatId ?? '').trim().isNotEmpty) 'heroSeatId',
  ];

  if (heroPosition.isEmpty || currentDecisionActor.isEmpty) {
    return Act0StreetReplayV1(
      steps: const <Act0StreetReplayStepV1>[],
      currentStreet: currentStreet,
      completeness: Act0StreetReplayCompletenessV1.insufficient,
      heroPosition: heroPosition,
      opponentPosition: opponentPosition,
      effectiveStackBb: effectiveStackBb,
      currentDecisionActor: currentDecisionActor,
      currentDecisionSummaryKey: table.centerLabel.trim(),
      sourceRefs: List<String>.unmodifiable(sourceRefs),
      keyClue: table.focusCalloutLabel.trim(),
      decisionContext: _act0StreetReplayDecisionContextV1(table),
    );
  }

  final steps = <Act0StreetReplayStepV1>[];
  var activeStreet = Act0StreetReplayStreetV1.preflop;
  var failedActionTruth =
      act0BettingRoundOrderTruthForTableV1(table) ==
      Act0BettingRoundOrderTruthV1.contradiction;
  final foldedActors = <String>{};
  String? previousVoluntaryActor;
  for (var index = 0; index < trailLabels.length; index++) {
    final rawLabel = trailLabels[index];
    final parsedStreet = _act0StreetReplayStreetFromTrailLabelV1(rawLabel);
    if (parsedStreet != null) {
      // Never present a reconstructed history that moves backwards or reads
      // actions from a street the learner has not reached yet.
      if (parsedStreet.index < activeStreet.index ||
          parsedStreet.index > currentStreet.index) {
        failedActionTruth = true;
        break;
      }
      if (parsedStreet != activeStreet) previousVoluntaryActor = null;
      activeStreet = parsedStreet;
    }
    final action = _act0StreetReplayActionLabelV1(rawLabel, parsedStreet);
    if (action.isEmpty) {
      continue;
    }
    final parsedAction = _act0StreetReplayParseActionV1(action);
    if (parsedAction == null) {
      failedActionTruth = true;
      break;
    }
    final actor = parsedAction.actorLabel.trim().toUpperCase();
    final actionType = parsedAction.actionTypeLabel.toLowerCase();
    // Forced posts are not turns. A voluntary action must pass to another
    // actor before this seat can act again on the same street.
    if (actionType != 'blind' && actionType != 'posts') {
      if (previousVoluntaryActor == actor) {
        failedActionTruth = true;
        break;
      }
      previousVoluntaryActor = actor;
    }
    // A folded seat cannot take another action in the same hand. The label
    // is a conservative source-owned seat token, not an invented action.
    if (foldedActors.contains(actor)) {
      failedActionTruth = true;
      break;
    }
    if (parsedAction.actionTypeLabel.toLowerCase() == 'folds' ||
        parsedAction.actionTypeLabel.toLowerCase() == 'fold') {
      foldedActors.add(actor);
    }
    steps.add(
      Act0StreetReplayStepV1(
        street: activeStreet,
        actionSummary: action,
        actorLabel: parsedAction.actorLabel,
        actionTypeLabel: parsedAction.actionTypeLabel,
        amountLabel: parsedAction.amountLabel,
        order: index,
        boardCardsAtStreet: _act0StreetReplayBoardCardsForStreetV1(
          table.boardCards,
          activeStreet,
        ),
        potAtStreet: activeStreet == currentStreet ? table.potLabel.trim() : '',
        isCurrentStreet: activeStreet == currentStreet,
        compactLabel: activeStreet == currentStreet ? 'Current street' : '',
      ),
    );
  }

  // Final source flags and executed folds both constrain the pending actor.
  // Historical folded opponents may still appear before their own fold.
  if (activeSeat?.isFolded == true ||
      foldedActors.contains(activeSeat?.seatLabel.trim().toUpperCase())) {
    failedActionTruth = true;
  }
  if (_act0StreetReplayHasSoleSurvivorV1(table, foldedActors, steps)) {
    failedActionTruth = true;
  }

  return Act0StreetReplayV1(
    steps: failedActionTruth
        ? const <Act0StreetReplayStepV1>[]
        : List<Act0StreetReplayStepV1>.unmodifiable(steps),
    currentStreet: currentStreet,
    completeness: failedActionTruth || steps.isEmpty
        ? Act0StreetReplayCompletenessV1.insufficient
        : _act0StreetReplayCompletenessV1(
            table: table,
            heroPosition: heroPosition,
            currentDecisionActor: currentDecisionActor,
          ),
    heroPosition: heroPosition,
    opponentPosition: opponentPosition,
    effectiveStackBb: effectiveStackBb,
    currentDecisionActor: currentDecisionActor,
    currentDecisionSummaryKey: table.centerLabel.trim(),
    sourceRefs: List<String>.unmodifiable(sourceRefs),
    keyClue: table.focusCalloutLabel.trim(),
    decisionContext: _act0StreetReplayDecisionContextV1(table),
  );
}

bool _act0StreetReplayHasSoleSurvivorV1(
  Act0TableStateV1 table,
  Set<String> foldedActors,
  List<Act0StreetReplayStepV1> steps,
) {
  // Only a complete, unambiguous source roster can prove every opponent out.
  // Missing seats or isInHand=false alone must not invent an executed fold.
  if (table.seats.length != table.playerCount) return false;
  final occupied = table.seats.where((seat) => seat.isOccupied).toList();
  final actors = occupied
      .map((seat) => seat.seatLabel.trim().toUpperCase())
      .toSet();
  if (occupied.length < 2 ||
      actors.length != occupied.length ||
      actors.any((actor) => !_act0StreetReplayLooksLikeActorV1(actor)) ||
      steps.any(
        (step) => !actors.contains(step.actorLabel.trim().toUpperCase()),
      )) {
    return false;
  }
  return occupied
          .where(
            (seat) =>
                !seat.isFolded &&
                !foldedActors.contains(seat.seatLabel.trim().toUpperCase()),
          )
          .length ==
      1;
}

Act0StreetReplayStreetV1? _act0StreetReplayStreetFromLabelV1(String label) {
  final normalized = label.trim().toLowerCase();
  return switch (normalized) {
    'preflop' => Act0StreetReplayStreetV1.preflop,
    'flop' => Act0StreetReplayStreetV1.flop,
    'turn' => Act0StreetReplayStreetV1.turn,
    'river' => Act0StreetReplayStreetV1.river,
    _ => null,
  };
}

Act0StreetReplayStreetV1? _act0StreetReplayStreetFromTrailLabelV1(
  String label,
) {
  final match = RegExp(
    r'^(flop|turn|river)(?::|\s)',
    caseSensitive: false,
  ).firstMatch(label.trim());
  if (match == null) {
    return null;
  }
  return _act0StreetReplayStreetFromLabelV1(match.group(1) ?? '');
}

String _act0StreetReplayActionLabelV1(
  String label,
  Act0StreetReplayStreetV1? street,
) {
  final trimmed = label.trim();
  if (street == null) {
    return trimmed;
  }
  final streetLabel = switch (street) {
    Act0StreetReplayStreetV1.preflop => 'Preflop',
    Act0StreetReplayStreetV1.flop => 'Flop',
    Act0StreetReplayStreetV1.turn => 'Turn',
    Act0StreetReplayStreetV1.river => 'River',
  };
  final colonPrefix = RegExp('^$streetLabel:\\s*', caseSensitive: false);
  final barePrefix = RegExp('^$streetLabel\\s+', caseSensitive: false);
  final withoutColon = trimmed.replaceFirst(colonPrefix, '').trim();
  if (withoutColon != trimmed) {
    return withoutColon;
  }
  return trimmed.replaceFirst(barePrefix, '').trim();
}

List<String> _act0StreetReplayBoardCardsForStreetV1(
  List<Act0CardStateV1> boardCards,
  Act0StreetReplayStreetV1 street,
) {
  final count = switch (street) {
    Act0StreetReplayStreetV1.preflop => 0,
    Act0StreetReplayStreetV1.flop => 3,
    Act0StreetReplayStreetV1.turn => 4,
    Act0StreetReplayStreetV1.river => 5,
  };
  return boardCards
      .take(count)
      .map((card) => card.label)
      .where((label) => label.trim().isNotEmpty && !label.contains('?'))
      .toList(growable: false);
}

String _act0StreetReplayDecisionContextV1(Act0TableStateV1 table) {
  final parts = <String>[
    table.centerLabel.trim(),
    table.potLabel.trim(),
    table.toCallLabel.trim(),
  ].where((part) => part.isNotEmpty).toList(growable: false);
  if (parts.isEmpty) {
    return '';
  }
  return '${parts.join('. ')}.';
}

({String actorLabel, String actionTypeLabel, String amountLabel})?
_act0StreetReplayParseActionV1(String action) {
  final tokens = action.trim().split(RegExp(r'\s+'));
  if (tokens.length < 2) {
    return null;
  }
  final actor = tokens.first.trim();
  final actionType = tokens[1].trim();
  if (!_act0StreetReplayLooksLikeActorV1(actor) ||
      !_act0StreetReplayLooksLikeActionV1(actionType)) {
    return null;
  }
  final amountMatch = RegExp(
    r'(\d+(?:\.\d+)?)\s*BB\b',
    caseSensitive: false,
  ).firstMatch(action);
  return (
    actorLabel: actor,
    actionTypeLabel: actionType,
    amountLabel: amountMatch == null ? '' : '${amountMatch.group(1)} BB',
  );
}

bool _act0StreetReplayLooksLikeActorV1(String value) {
  final normalized = value.trim().toUpperCase();
  if (normalized.isEmpty) return false;
  return normalized == 'SB' ||
      normalized == 'BB' ||
      normalized == 'BTN' ||
      normalized == 'CO' ||
      normalized == 'HJ' ||
      normalized == 'LJ' ||
      normalized == 'UTG' ||
      normalized == 'MP' ||
      normalized.startsWith('UTG+');
}

bool _act0StreetReplayLooksLikeActionV1(String value) {
  return switch (value.trim().toLowerCase()) {
    'blind' ||
    'posts' ||
    'checks' ||
    'check' ||
    'bets' ||
    'bet' ||
    'raises' ||
    'raise' ||
    'calls' ||
    'call' ||
    'folds' ||
    'fold' ||
    'shoves' ||
    'shove' ||
    'jams' ||
    'jam' => true,
    _ => false,
  };
}

Act0SeatStateV1? _act0StreetReplaySeatByIdV1(
  Act0TableStateV1 table,
  String? seatId,
) {
  final normalized = seatId?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final seat in table.seats) {
    if (seat.seatId == normalized) {
      return seat;
    }
  }
  return null;
}

String _act0StreetReplayEffectiveStackV1(Act0TableStateV1 table) {
  final labels = table.seats
      .map((seat) => seat.stackLabel?.trim() ?? '')
      .where((label) => label.isNotEmpty)
      .toList(growable: false);
  if (labels.isEmpty) {
    return '';
  }
  return labels.first;
}

Act0StreetReplayCompletenessV1 _act0StreetReplayCompletenessV1({
  required Act0TableStateV1 table,
  required String heroPosition,
  required String currentDecisionActor,
}) {
  final hasCompleteContext =
      heroPosition.trim().isNotEmpty &&
      currentDecisionActor.trim().isNotEmpty &&
      table.potLabel.trim().isNotEmpty &&
      table.centerLabel.trim().isNotEmpty;
  return hasCompleteContext
      ? Act0StreetReplayCompletenessV1.complete
      : Act0StreetReplayCompletenessV1.partialSafe;
}
