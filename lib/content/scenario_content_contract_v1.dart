import 'dart:convert';

const int kScenarioContentSchemaVersionV1 = 1;

const String kScenarioContentSchemaVersionKey = 'schema_version';
const String kScenarioContentSeatCountKey = 'seatCount';
const String kScenarioContentHeroSeatKey = 'heroSeat';
const String kScenarioContentInitialStacksKey = 'initialStacks';
const String kScenarioContentActingSeatStartKey = 'actingSeatStart';
const String kScenarioContentDecisionNodeKey = 'decisionNodeV1';
const String kScenarioContentNodesKey = 'nodes';

const String kScenarioContentNodeIdKey = 'id';
const String kScenarioContentNodeStreetKey = 'street';
const String kScenarioContentNodeActingSeatIndexKey = 'actingSeatIndex';
const String kScenarioContentNodePotKey = 'pot';
const String kScenarioContentNodeDecisionNodeKey = 'decisionNode';
const String kScenarioContentNodeNextNodeIdKey = 'nextNodeId';
const String kScenarioContentNodeNextByActionKey = 'nextByAction';

const String kScenarioContentDecisionNodeStreetKey = 'street';
const String kScenarioContentDecisionNodeLegalActionsKey = 'legalActions';
const String kScenarioContentDecisionNodeSolutionBestActionKey =
    'solutionBestAction';
const String kScenarioContentDecisionNodeErrorClassKey = 'error_class';

class ScenarioContentDecisionNodeV1 {
  const ScenarioContentDecisionNodeV1({
    required this.street,
    required this.legalActions,
    required this.solutionBestAction,
    this.errorClass,
  });

  final String street;
  final List<String> legalActions;
  final String solutionBestAction;
  final String? errorClass;

  static ScenarioContentDecisionNodeV1 fromMap(Map<String, Object?> json) {
    return ScenarioContentDecisionNodeV1(
      street: _requireString(json, kScenarioContentDecisionNodeStreetKey),
      legalActions: _requireStringList(
        json,
        kScenarioContentDecisionNodeLegalActionsKey,
      ),
      solutionBestAction: _requireString(
        json,
        kScenarioContentDecisionNodeSolutionBestActionKey,
      ),
      errorClass: _readString(json, kScenarioContentDecisionNodeErrorClassKey),
    );
  }
}

class ScenarioContentNodeV1 {
  const ScenarioContentNodeV1({
    required this.id,
    required this.street,
    required this.actingSeatIndex,
    required this.pot,
    required this.decisionNode,
    this.nextNodeId,
    this.nextByAction,
  });

  final String id;
  final String street;
  final int actingSeatIndex;
  final int pot;
  final ScenarioContentDecisionNodeV1 decisionNode;
  final String? nextNodeId;
  final Map<String, String>? nextByAction;

  static ScenarioContentNodeV1 fromMap(Map<String, Object?> json) {
    final decisionRaw = _requireMap(json, kScenarioContentNodeDecisionNodeKey);
    return ScenarioContentNodeV1(
      id: _requireString(json, kScenarioContentNodeIdKey),
      street: _requireString(json, kScenarioContentNodeStreetKey),
      actingSeatIndex: _requireInt(
        json,
        kScenarioContentNodeActingSeatIndexKey,
      ),
      pot: _requireInt(json, kScenarioContentNodePotKey),
      decisionNode: ScenarioContentDecisionNodeV1.fromMap(decisionRaw),
      nextNodeId: _readString(json, kScenarioContentNodeNextNodeIdKey),
      nextByAction: _readStringMap(json, kScenarioContentNodeNextByActionKey),
    );
  }
}

class ScenarioContentSpecV1 {
  const ScenarioContentSpecV1({
    required this.schemaVersion,
    required this.context,
    required this.decisionNode,
    required this.nodes,
  });

  final int schemaVersion;
  final Map<String, Object?> context;
  final ScenarioContentDecisionNodeV1 decisionNode;
  final List<ScenarioContentNodeV1>? nodes;

  static ScenarioContentSpecV1 parse(String jsonText) {
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map) {
      throw FormatException('Scenario spec must be a JSON object');
    }
    return ScenarioContentSpecV1.fromMap(decoded.cast<String, Object?>());
  }

  static ScenarioContentSpecV1 fromMap(Map<String, Object?> json) {
    final version =
        (json[kScenarioContentSchemaVersionKey] as int?) ??
        kScenarioContentSchemaVersionV1;
    if (version > kScenarioContentSchemaVersionV1) {
      throw StateError('schema_version $version is not supported');
    }
    final context = Map<String, Object?>.from(json)
      ..remove(kScenarioContentNodesKey);

    final decisionRaw = _requireMap(context, kScenarioContentDecisionNodeKey);
    final decisionNode = ScenarioContentDecisionNodeV1.fromMap(decisionRaw);

    final nodesRaw = json[kScenarioContentNodesKey];
    List<ScenarioContentNodeV1>? nodes;
    if (nodesRaw != null) {
      if (nodesRaw is! List) {
        throw FormatException('nodes must be a list');
      }
      nodes = nodesRaw.map((entry) {
        if (entry is! Map) {
          throw FormatException('node must be a map');
        }
        return ScenarioContentNodeV1.fromMap(entry.cast<String, Object?>());
      }).toList();
    }
    if (version >= kScenarioContentSchemaVersionV1) {
      _validateRequiredSnapshotKeysV1(context, nodes);
    }

    return ScenarioContentSpecV1(
      schemaVersion: version,
      context: context,
      decisionNode: decisionNode,
      nodes: nodes,
    );
  }

  int get seatCount => _requireInt(context, kScenarioContentSeatCountKey);

  int get heroSeat => _requireInt(context, kScenarioContentHeroSeatKey);

  List<int> get initialStacks =>
      _requireIntList(context, kScenarioContentInitialStacksKey);

  int get actingSeatStart =>
      _requireInt(context, kScenarioContentActingSeatStartKey);
}

void _validateRequiredSnapshotKeysV1(
  Map<String, Object?> context,
  List<ScenarioContentNodeV1>? nodes,
) {
  final missing = <String>[];
  for (final key in [
    kScenarioContentSeatCountKey,
    kScenarioContentHeroSeatKey,
    kScenarioContentInitialStacksKey,
    kScenarioContentActingSeatStartKey,
    kScenarioContentDecisionNodeKey,
  ]) {
    if (!context.containsKey(key)) {
      missing.add(key);
    }
  }
  if (missing.isNotEmpty) {
    throw FormatException(
      'Missing required snapshot keys: ${missing.join(', ')}',
    );
  }
  if (nodes == null || nodes.isEmpty) {
    throw FormatException('Missing required snapshot nodes: nodes');
  }
  final seatCount = _requireInt(context, kScenarioContentSeatCountKey);
  final heroSeat = _requireInt(context, kScenarioContentHeroSeatKey);
  if (heroSeat < 0 || heroSeat >= seatCount) {
    throw FormatException('Invalid heroSeat: $heroSeat');
  }
  final actingSeatStart = _requireInt(
    context,
    kScenarioContentActingSeatStartKey,
  );
  if (actingSeatStart < 0 || actingSeatStart >= seatCount) {
    throw FormatException('Invalid actingSeatStart: $actingSeatStart');
  }
  final stacks = _requireIntList(context, kScenarioContentInitialStacksKey);
  if (stacks.length != seatCount) {
    throw FormatException(
      'Invalid initialStacks length: expected $seatCount got ${stacks.length}',
    );
  }
  for (final node in nodes) {
    if (node.actingSeatIndex < 0 || node.actingSeatIndex >= seatCount) {
      throw FormatException(
        'Invalid actingSeatIndex ${node.actingSeatIndex} for node ${node.id}',
      );
    }
  }
}

String _requireString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Missing or invalid $key');
  }
  return value;
}

String? _readString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Invalid $key');
  }
  return value;
}

int _requireInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Missing or invalid $key');
  }
  return value;
}

List<String> _requireStringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Missing or invalid $key');
  }
  return value.map((item) => item.toString()).toList();
}

List<int> _requireIntList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Missing or invalid $key');
  }
  return value.map((item) {
    if (item is! int) {
      throw FormatException('Invalid $key item');
    }
    return item;
  }).toList();
}

Map<String, Object?> _requireMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw FormatException('Missing or invalid $key');
  }
  return value.cast<String, Object?>();
}

Map<String, String>? _readStringMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! Map) {
    throw FormatException('Invalid $key');
  }
  return value.map((k, v) => MapEntry(k.toString(), v.toString()));
}
