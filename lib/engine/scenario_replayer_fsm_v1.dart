enum Street { preflop, flop, turn, river }

enum StreetPhase { acting, resolving }

enum ScenarioSeatOccupancyV1 { active, folded, empty }

class ScenarioBlindLevelStateV1 {
  const ScenarioBlindLevelStateV1({
    required this.smallBlindSeatIndexV1,
    required this.bigBlindSeatIndexV1,
    required this.smallBlindAmountV1,
    required this.bigBlindAmountV1,
    this.anteAmountV1,
  });

  final int smallBlindSeatIndexV1;
  final int bigBlindSeatIndexV1;
  final int smallBlindAmountV1;
  final int bigBlindAmountV1;
  final int? anteAmountV1;

  Map<String, Object?> toJson() => {
    'smallBlindSeatIndexV1': smallBlindSeatIndexV1,
    'bigBlindSeatIndexV1': bigBlindSeatIndexV1,
    'smallBlindAmountV1': smallBlindAmountV1,
    'bigBlindAmountV1': bigBlindAmountV1,
    'anteAmountV1': anteAmountV1,
  };

  static ScenarioBlindLevelStateV1 fromJson(Map<String, Object?> json) {
    return ScenarioBlindLevelStateV1(
      smallBlindSeatIndexV1: json['smallBlindSeatIndexV1'] as int,
      bigBlindSeatIndexV1: json['bigBlindSeatIndexV1'] as int,
      smallBlindAmountV1: json['smallBlindAmountV1'] as int,
      bigBlindAmountV1: json['bigBlindAmountV1'] as int,
      anteAmountV1: json['anteAmountV1'] as int?,
    );
  }
}

class SeatState {
  const SeatState({required this.stack, this.folded = false});

  final int stack;
  final bool folded;

  SeatState copyWith({int? stack, bool? folded}) {
    return SeatState(stack: stack ?? this.stack, folded: folded ?? this.folded);
  }
}

class DecisionNodeV1 {
  const DecisionNodeV1({
    required this.street,
    required this.legalActions,
    required this.solutionBestAction,
  });

  final Street street;
  final List<String> legalActions;
  final String solutionBestAction;

  Map<String, Object?> toJson() => {
    'street': street.name,
    'legalActions': legalActions,
    'solutionBestAction': solutionBestAction,
  };

  static DecisionNodeV1 fromJson(Map<String, Object?> json) {
    return DecisionNodeV1(
      street: Street.values.firstWhere((value) => value.name == json['street']),
      legalActions: List<String>.from(json['legalActions'] as List<dynamic>),
      solutionBestAction: json['solutionBestAction'] as String,
    );
  }
}

class ScenarioNodeV1 {
  const ScenarioNodeV1({
    required this.id,
    required this.street,
    required this.actingSeatIndex,
    required this.pot,
    required this.decisionNode,
    this.nextNodeId,
    this.nextByAction,
  });

  final String id;
  final Street street;
  final int actingSeatIndex;
  final int pot;
  final DecisionNodeV1 decisionNode;
  final String? nextNodeId;
  final Map<String, String>? nextByAction;

  Map<String, Object?> toJson() => {
    'id': id,
    'street': street.name,
    'actingSeatIndex': actingSeatIndex,
    'pot': pot,
    'decisionNode': decisionNode.toJson(),
    'nextNodeId': nextNodeId,
    'nextByAction': nextByAction,
  };

  static ScenarioNodeV1 fromJson(Map<String, Object?> json) {
    return ScenarioNodeV1(
      id: json['id'] as String,
      street: Street.values.firstWhere((value) => value.name == json['street']),
      actingSeatIndex: json['actingSeatIndex'] as int,
      pot: json['pot'] as int,
      decisionNode: DecisionNodeV1.fromJson(
        json['decisionNode']! as Map<String, Object?>,
      ),
      nextNodeId: json['nextNodeId'] as String?,
      nextByAction: (json['nextByAction'] as Map?)?.cast<String, String>(),
    );
  }
}

class ScenarioSpecV1 {
  ScenarioSpecV1({
    required this.seatCount,
    required this.heroSeat,
    required this.initialStacks,
    required this.actingSeatStart,
    required this.decisionNodeV1,
    this.seatOccupancies,
    this.blindLevelStateV1,
    this.nodes,
  });

  final int seatCount;
  final int heroSeat;
  final List<int> initialStacks;
  final int actingSeatStart;
  final DecisionNodeV1 decisionNodeV1;
  final List<ScenarioSeatOccupancyV1>? seatOccupancies;
  final ScenarioBlindLevelStateV1? blindLevelStateV1;
  final List<ScenarioNodeV1>? nodes;

  void validate() {
    if (seatCount < 2 || seatCount > 10) {
      throw ArgumentError('seatCount must be between 2 and 10');
    }
    if (heroSeat < 0 || heroSeat >= seatCount) {
      throw ArgumentError('heroSeat must be within seatCount');
    }
    if (actingSeatStart < 0 || actingSeatStart >= seatCount) {
      throw ArgumentError('actingSeatStart must be within seatCount');
    }
    if (initialStacks.length != seatCount) {
      throw ArgumentError('initialStacks length must match seatCount');
    }
    if (seatOccupancies != null && seatOccupancies!.length != seatCount) {
      throw ArgumentError('seatOccupancies length must match seatCount');
    }
    final blindLevelState = blindLevelStateV1;
    if (blindLevelState != null) {
      _validateBlindLevelState(blindLevelState);
    }
    final occupancies = resolvedSeatOccupanciesV1;
    if (occupancies[heroSeat] == ScenarioSeatOccupancyV1.empty) {
      throw ArgumentError('heroSeat cannot be empty');
    }
    if (occupancies[actingSeatStart] != ScenarioSeatOccupancyV1.active) {
      throw ArgumentError('actingSeatStart must reference an active seat');
    }
    for (var i = 0; i < seatCount; i++) {
      if (occupancies[i] == ScenarioSeatOccupancyV1.empty &&
          initialStacks[i] != 0) {
        throw ArgumentError('empty seats must have zero stack');
      }
    }
    if (nodes != null && nodes!.isEmpty) {
      throw ArgumentError('nodes list cannot be empty');
    }
    if (nodes != null) {
      final ids = nodes!.map((node) => node.id).toSet();
      for (final node in nodes!) {
        _validateNode(node, seatCount, ids);
      }
    }
  }

  void _validateBlindLevelState(ScenarioBlindLevelStateV1 blindLevelState) {
    if (blindLevelState.smallBlindSeatIndexV1 < 0 ||
        blindLevelState.smallBlindSeatIndexV1 >= seatCount) {
      throw ArgumentError(
        'smallBlindSeatIndexV1 must be within seatCount when present',
      );
    }
    if (blindLevelState.bigBlindSeatIndexV1 < 0 ||
        blindLevelState.bigBlindSeatIndexV1 >= seatCount) {
      throw ArgumentError(
        'bigBlindSeatIndexV1 must be within seatCount when present',
      );
    }
    if (blindLevelState.smallBlindSeatIndexV1 ==
        blindLevelState.bigBlindSeatIndexV1) {
      throw ArgumentError(
        'smallBlindSeatIndexV1 and bigBlindSeatIndexV1 must differ',
      );
    }
    if (blindLevelState.smallBlindAmountV1 <= 0) {
      throw ArgumentError('smallBlindAmountV1 must be positive when present');
    }
    if (blindLevelState.bigBlindAmountV1 <= 0) {
      throw ArgumentError('bigBlindAmountV1 must be positive when present');
    }
    if (blindLevelState.bigBlindAmountV1 < blindLevelState.smallBlindAmountV1) {
      throw ArgumentError(
        'bigBlindAmountV1 must be greater than or equal to smallBlindAmountV1',
      );
    }
    final anteAmount = blindLevelState.anteAmountV1;
    if (anteAmount != null && anteAmount <= 0) {
      throw ArgumentError('anteAmountV1 must be positive when present');
    }
  }

  void _validateNode(ScenarioNodeV1 node, int seatCount, Set<String> ids) {
    if (node.actingSeatIndex < 0 || node.actingSeatIndex >= seatCount) {
      throw StateError(
        'node ${node.id} actingSeatIndex ${node.actingSeatIndex} out of range',
      );
    }
    if (node.nextNodeId != null) {
      _validateNextNodeIds(node.nextNodeId!, ids, node.id);
    }
    if (node.nextByAction != null) {
      _validateNextByAction(node, ids);
    }
  }

  void _validateNextNodeIds(String nextNodeId, Set<String> ids, String nodeId) {
    final nextIds = nextNodeId
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty);
    for (final nextId in nextIds) {
      if (!ids.contains(nextId)) {
        throw StateError('node $nodeId references unknown nextNodeId $nextId');
      }
    }
  }

  void _validateNextByAction(ScenarioNodeV1 node, Set<String> ids) {
    final legal = node.decisionNode.legalActions
        .map((a) => a.toLowerCase())
        .toSet();
    for (final entry in node.nextByAction!.entries) {
      final actionKey = entry.key.toLowerCase();
      if (!legal.contains(actionKey)) {
        throw StateError(
          'node ${node.id} nextByAction ${entry.key} not allowed',
        );
      }
      if (!ids.contains(entry.value)) {
        throw StateError(
          'node ${node.id} nextByAction targets unknown node ${entry.value}',
        );
      }
    }
  }

  Map<String, Object?> toJson() {
    final map = <String, Object?>{
      'seatCount': seatCount,
      'heroSeat': heroSeat,
      'initialStacks': initialStacks,
      'seatOccupancies': resolvedSeatOccupanciesV1
          .map((value) => value.name)
          .toList(),
      'schema_version': 1,
      'actingSeatStart': actingSeatStart,
      'decisionNodeV1': decisionNodeV1.toJson(),
      'blindLevelStateV1': blindLevelStateV1?.toJson(),
    };
    if (nodes != null) {
      map['nodes'] = nodes!.map((node) => node.toJson()).toList();
    }
    return map;
  }

  static ScenarioSpecV1 fromJson(Map<String, Object?> json) {
    final version = (json['schema_version'] as int?) ?? 1;
    if (version > 1) {
      throw StateError('schema_version $version is not supported');
    }
    final nodesJson = json['nodes'] as List<Object?>?;
    return ScenarioSpecV1(
      seatCount: json['seatCount'] as int,
      heroSeat: json['heroSeat'] as int,
      initialStacks: List<int>.from(json['initialStacks'] as List<dynamic>),
      actingSeatStart: json['actingSeatStart'] as int,
      decisionNodeV1: DecisionNodeV1.fromJson(
        json['decisionNodeV1']! as Map<String, Object?>,
      ),
      seatOccupancies: (json['seatOccupancies'] as List<Object?>?)
          ?.map(
            (value) => ScenarioSeatOccupancyV1.values.firstWhere(
              (entry) => entry.name == value,
            ),
          )
          .toList(),
      blindLevelStateV1:
          (json['blindLevelStateV1'] as Map<Object?, Object?>?) == null
          ? null
          : ScenarioBlindLevelStateV1.fromJson(
              (json['blindLevelStateV1']! as Map).cast<String, Object?>(),
            ),
      nodes: nodesJson
          ?.cast<Map<String, Object?>>()
          .map(ScenarioNodeV1.fromJson)
          .toList(),
    );
  }

  List<ScenarioSeatOccupancyV1> get resolvedSeatOccupanciesV1 {
    final occupancies = seatOccupancies;
    if (occupancies != null) {
      return occupancies;
    }
    return List<ScenarioSeatOccupancyV1>.generate(
      seatCount,
      (index) => initialStacks[index] <= 0
          ? ScenarioSeatOccupancyV1.folded
          : ScenarioSeatOccupancyV1.active,
      growable: false,
    );
  }

  List<ScenarioNodeV1> get resolvedNodes {
    if (nodes != null && nodes!.isNotEmpty) {
      return nodes!;
    }
    return [
      ScenarioNodeV1(
        id: 'legacy',
        street: decisionNodeV1.street,
        actingSeatIndex: actingSeatStart,
        pot: 0,
        decisionNode: decisionNodeV1,
      ),
    ];
  }
}

abstract class ScenarioState {
  const ScenarioState();
}

class SetupState extends ScenarioState {
  const SetupState({required this.spec});

  final ScenarioSpecV1 spec;
}

class StreetActiveState extends ScenarioState {
  const StreetActiveState({
    required this.street,
    required this.phase,
    required this.actingSeat,
    required this.pot,
    required this.seats,
    required this.legalActions,
  });

  final Street street;
  final StreetPhase phase;
  final int actingSeat;
  final int pot;
  final List<SeatState> seats;
  final List<String> legalActions;
}

class EvaluationState extends ScenarioState {
  const EvaluationState({
    required this.street,
    required this.actingSeat,
    required this.action,
  });

  final Street street;
  final int actingSeat;
  final String action;
}

class OutcomeState extends ScenarioState {
  const OutcomeState({required this.result});

  final String result;
}

class ScenarioReplayerFsmV1 {
  ScenarioReplayerFsmV1._(this._state, this._spec, this._nodes)
    : _nodeIndexById = {
        for (var i = 0; i < _nodes.length; i++) _nodes[i].id: i,
      };

  final ScenarioSpecV1 _spec;
  final List<ScenarioNodeV1> _nodes;
  final Map<String, int> _nodeIndexById;
  late int _currentNodeIndex;
  ScenarioState _state;
  String? _lastAction;

  ScenarioState get state => _state;

  static ScenarioReplayerFsmV1 start(ScenarioSpecV1 spec) {
    spec.validate();
    final seats = List<SeatState>.unmodifiable(
      List<SeatState>.generate(
        spec.seatCount,
        (index) => SeatState(
          stack: spec.initialStacks[index],
          folded:
              spec.resolvedSeatOccupanciesV1[index] !=
              ScenarioSeatOccupancyV1.active,
        ),
        growable: false,
      ),
    );
    final nodes = spec.resolvedNodes;
    final state = StreetActiveState(
      street: nodes.first.street,
      phase: StreetPhase.acting,
      actingSeat: nodes.first.actingSeatIndex,
      pot: nodes.first.pot,
      seats: seats,
      legalActions: nodes.first.decisionNode.legalActions,
    );
    final engine = ScenarioReplayerFsmV1._(state, spec, nodes);
    engine._currentNodeIndex = 0;
    engine._state = state;
    return engine;
  }

  ScenarioState applyUserAction(String action) {
    final current = _requireState<StreetActiveState>();
    _lastAction = action;
    _state = EvaluationState(
      street: current.street,
      actingSeat: current.actingSeat,
      action: action,
    );
    return _state;
  }

  ScenarioState advance() {
    final current = _state;
    if (current is EvaluationState) {
      _state = OutcomeState(
        result: _nodes[_currentNodeIndex].decisionNode.solutionBestAction,
      );
      return _state;
    }
    if (current is OutcomeState) {
      final nextIndex = _determineNextNodeIndex();
      if (!_hasSuccessor(_nodes[_currentNodeIndex])) {
        return _state; // terminal node stays in Outcome
      }
      _currentNodeIndex = nextIndex;
      _state = _buildStreetActiveState(_nodes[_currentNodeIndex]);
      _lastAction = null;
      return _state;
    }
    throw StateError('advance() requires Evaluation or Outcome state');
  }

  static int advanceActingSeat(int current, List<SeatState> seats) {
    if (seats.isEmpty) {
      return current;
    }
    final count = seats.length;
    for (var offset = 1; offset <= count; offset++) {
      final index = (current + offset) % count;
      if (!seats[index].folded) {
        return index;
      }
    }
    return current;
  }

  int _determineNextNodeIndex() {
    final currentNode = _nodes[_currentNodeIndex];
    if (_lastAction != null && currentNode.nextByAction != null) {
      final lower = _lastAction!.toLowerCase();
      final targetEntry = currentNode.nextByAction!.entries.firstWhere(
        (entry) => entry.key.toLowerCase() == lower,
        orElse: () => MapEntry('', ''),
      );
      if (targetEntry.key.isNotEmpty &&
          _nodeIndexById.containsKey(targetEntry.value)) {
        return _nodeIndexById[targetEntry.value]!;
      }
    }
    if (currentNode.nextNodeId != null) {
      final nextIds = currentNode.nextNodeId!.split(',');
      for (final nextId in nextIds) {
        final trimmed = nextId.trim();
        if (_nodeIndexById.containsKey(trimmed)) {
          return _nodeIndexById[trimmed]!;
        }
      }
    }
    if (!_hasSuccessor(currentNode)) {
      return _currentNodeIndex;
    }
    return _currentNodeIndex;
  }

  bool _hasSuccessor(ScenarioNodeV1 node) {
    if (node.nextByAction != null && node.nextByAction!.isNotEmpty) {
      return true;
    }
    if (node.nextNodeId != null &&
        node.nextNodeId!.split(',').any((id) => id.trim().isNotEmpty)) {
      return true;
    }
    return false;
  }

  StreetActiveState _buildStreetActiveState(ScenarioNodeV1 node) {
    return StreetActiveState(
      street: node.street,
      phase: StreetPhase.acting,
      actingSeat: node.actingSeatIndex,
      pot: node.pot,
      seats: List<SeatState>.unmodifiable(
        List<SeatState>.generate(
          _spec.seatCount,
          (index) => SeatState(
            stack: _spec.initialStacks[index],
            folded:
                _spec.resolvedSeatOccupanciesV1[index] !=
                ScenarioSeatOccupancyV1.active,
          ),
          growable: false,
        ),
      ),
      legalActions: node.decisionNode.legalActions,
    );
  }

  T _requireState<T extends ScenarioState>() {
    final current = _state;
    if (current is T) {
      return current;
    }
    throw StateError('Unexpected state: ${current.runtimeType}');
  }
}
