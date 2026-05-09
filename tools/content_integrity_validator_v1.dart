import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:poker_analyzer/services/drill_contract_v1.dart';

class ContentIntegrityIssueV1 {
  const ContentIntegrityIssueV1({
    required this.world,
    required this.sessionId,
    required this.drillId,
    required this.reason,
    required this.path,
    this.details,
  });

  final int world;
  final String sessionId;
  final String drillId;
  final String reason;
  final String path;
  final String? details;

  Map<String, Object> toJson() => <String, Object>{
    'world': world,
    'sessionId': sessionId,
    'drillId': drillId,
    'reason': reason,
    'path': path,
    if (details != null) 'details': details!,
  };
}

class ContentIntegrityReportV1 {
  const ContentIntegrityReportV1({
    required this.filesChecked,
    required this.issues,
  });

  final int filesChecked;
  final List<ContentIntegrityIssueV1> issues;

  bool get isSuccess => issues.isEmpty;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'filesChecked': filesChecked,
    'issueCount': issues.length,
    'issues': issues.map((item) => item.toJson()).toList(growable: false),
  };
}

const Set<int> _kDefaultIncludedWorldsV1 = <int>{
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
};

const Set<String> _kExpectedExemptKindsV1 = <String>{
  'board_texture_classifier_v1',
  'range_bucket_classifier_v1',
  'hand_chain_v1',
};

const Set<String> _kFeedbackRequiredKindsV1 = <String>{
  'showdown_winner_choice_v1',
  'position_thinking_choice_v1',
  'initiative_aggressor_choice_v1',
  'outs_count_choice_v1',
  'board_texture_classifier_v1',
  'range_bucket_classifier_v1',
};

const Map<String, int> _kStreetBoardCardCountsV1 = <String, int>{
  'preflop': 0,
  'flop': 3,
  'turn': 4,
  'river': 5,
};

class _DrillFileRefV1 {
  const _DrillFileRefV1({
    required this.world,
    required this.sessionId,
    required this.drillId,
    required this.path,
  });

  final int world;
  final String sessionId;
  final String drillId;
  final String path;
}

ContentIntegrityReportV1 buildContentIntegrityReportV1({
  String rootPath = '.',
  Set<int>? includedWorlds,
}) {
  final worlds = includedWorlds ?? _kDefaultIncludedWorldsV1;
  final refs = _collectDrillRefsV1(rootPath, worlds)..sort(_compareRefsV1);
  final issues = <ContentIntegrityIssueV1>[];

  for (final ref in refs) {
    final file = File('$rootPath/${ref.path}');
    if (!file.existsSync()) {
      issues.add(
        ContentIntegrityIssueV1(
          world: ref.world,
          sessionId: ref.sessionId,
          drillId: ref.drillId,
          reason: 'missing_drill_file',
          path: ref.path,
        ),
      );
      continue;
    }

    final source = file.readAsStringSync();
    final decoded = _decodeJsonObjectV1(ref, source, issues);
    if (decoded == null) {
      continue;
    }

    final blockingIssues = _collectBlockingIssuesV1(ref, decoded);
    issues.addAll(blockingIssues);
    if (blockingIssues.isNotEmpty) {
      continue;
    }

    final spec = _parseDrillSpecV1(ref, decoded, issues);
    if (spec == null) {
      continue;
    }

    issues.addAll(_collectKindSpecificIssuesV1(ref, decoded, spec));
  }

  final readinessReport = _collectWorld10TopologyReadinessIssuesV1(
    rootPath,
    worlds,
  );
  final canonicalSpatialReadinessReport =
      _collectWorld6To9TopologyReadinessIssuesV1(rootPath, worlds);
  issues.addAll(readinessReport.issues);
  issues.addAll(canonicalSpatialReadinessReport.issues);

  issues.sort(_compareIssuesV1);
  return ContentIntegrityReportV1(
    filesChecked:
        refs.length +
        readinessReport.filesChecked +
        canonicalSpatialReadinessReport.filesChecked,
    issues: List<ContentIntegrityIssueV1>.unmodifiable(issues),
  );
}

String renderContentIntegrityReportV1(ContentIntegrityReportV1 report) {
  final out = StringBuffer()
    ..writeln('FILES_CHECKED\t${report.filesChecked}')
    ..writeln('ISSUE_COUNT\t${report.issues.length}')
    ..writeln();
  if (report.issues.isEmpty) {
    out.writeln('STATUS\tOK');
    return out.toString().trimRight();
  }
  out.writeln('WORLD\tSESSION\tDRILL\tREASON\tPATH\tDETAILS');
  for (final issue in report.issues) {
    out.writeln(
      '${issue.world}\t${issue.sessionId}\t${issue.drillId}\t${issue.reason}\t${issue.path}\t${issue.details ?? ''}',
    );
  }
  return out.toString().trimRight();
}

String encodeContentIntegrityReportJsonV1(ContentIntegrityReportV1 report) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

void main(List<String> args) {
  var emitJson = false;
  final includedWorlds = <int>{};

  for (final arg in args) {
    if (arg == '--json') {
      emitJson = true;
      continue;
    }
    if (arg.startsWith('--world=')) {
      final value = int.tryParse(arg.substring('--world='.length));
      if (value == null) {
        stderr.writeln('invalid --world value: $arg');
        exitCode = 64;
        return;
      }
      includedWorlds.add(value);
      continue;
    }
    stderr.writeln('unknown argument: $arg');
    exitCode = 64;
    return;
  }

  final report = buildContentIntegrityReportV1(
    includedWorlds: includedWorlds.isEmpty ? null : includedWorlds,
  );
  stdout.writeln(
    emitJson
        ? encodeContentIntegrityReportJsonV1(report)
        : renderContentIntegrityReportV1(report),
  );
  exitCode = report.isSuccess ? 0 : 1;
}

List<_DrillFileRefV1> _collectDrillRefsV1(String rootPath, Set<int> worlds) {
  final refs = <_DrillFileRefV1>[
    ..._loadManifestRefsV1(rootPath, worlds),
    ..._scanWorld10TrackRefsV1(rootPath, worlds),
  ];
  return refs;
}

List<_DrillFileRefV1> _loadManifestRefsV1(String rootPath, Set<int> worlds) {
  final file = File('$rootPath/content/_meta/world_drills_manifest_v1.json');
  if (!file.existsSync()) {
    return const <_DrillFileRefV1>[];
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    return const <_DrillFileRefV1>[];
  }
  final worldEntries = decoded['worlds'];
  if (worldEntries is! List<Object?>) {
    return const <_DrillFileRefV1>[];
  }

  final refs = <_DrillFileRefV1>[];
  for (final worldEntry in worldEntries) {
    if (worldEntry is! Map<String, Object?>) {
      continue;
    }
    final world = worldEntry['world'];
    if (world is! int || !worlds.contains(world)) {
      continue;
    }
    final sessions = worldEntry['sessions'];
    if (sessions is! List<Object?>) {
      continue;
    }
    for (final session in sessions) {
      if (session is! Map<String, Object?>) {
        continue;
      }
      final sessionId = (session['id'] ?? '').toString().trim();
      final drills = session['drills'];
      if (sessionId.isEmpty || drills is! List<Object?>) {
        continue;
      }
      for (final drill in drills) {
        if (drill is! Map<String, Object?>) {
          continue;
        }
        final drillId = (drill['id'] ?? '').toString().trim();
        final path = (drill['path'] ?? '').toString().trim();
        if (drillId.isEmpty || path.isEmpty) {
          continue;
        }
        refs.add(
          _DrillFileRefV1(
            world: world,
            sessionId: sessionId,
            drillId: drillId,
            path: path,
          ),
        );
      }
    }
  }
  return refs;
}

List<_DrillFileRefV1> _scanWorld10TrackRefsV1(
  String rootPath,
  Set<int> worlds,
) {
  if (!worlds.contains(10)) {
    return const <_DrillFileRefV1>[];
  }

  final refs = <_DrillFileRefV1>[];
  for (final track in const <String>['cash', 'mixed', 'tournament']) {
    final sessionsDir = Directory(
      '$rootPath/content/worlds/world10/v1/tracks/$track/sessions',
    );
    if (!sessionsDir.existsSync()) {
      continue;
    }
    final sessionDirs = sessionsDir.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final sessionDir in sessionDirs) {
      final sessionId = sessionDir.uri.pathSegments.lastWhere(
        (segment) => segment.isNotEmpty,
      );
      final drillsDir = Directory('${sessionDir.path}/drills');
      if (!drillsDir.existsSync()) {
        continue;
      }
      final drillFiles = drillsDir.listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      for (final drillFile in drillFiles) {
        if (!drillFile.path.endsWith('.json')) {
          continue;
        }
        refs.add(
          _DrillFileRefV1(
            world: 10,
            sessionId: sessionId,
            drillId: _inferDrillIdFromPathV1(drillFile.path),
            path: path.relative(drillFile.path, from: Directory(rootPath).path),
          ),
        );
      }
    }
  }
  return refs;
}

Map<String, Object?>? _decodeJsonObjectV1(
  _DrillFileRefV1 ref,
  String source,
  List<ContentIntegrityIssueV1> issues,
) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException catch (error) {
    issues.add(
      ContentIntegrityIssueV1(
        world: ref.world,
        sessionId: ref.sessionId,
        drillId: ref.drillId,
        reason: 'invalid_json',
        path: ref.path,
        details: error.message,
      ),
    );
    return null;
  }
  if (decoded is! Map<String, Object?>) {
    issues.add(
      ContentIntegrityIssueV1(
        world: ref.world,
        sessionId: ref.sessionId,
        drillId: ref.drillId,
        reason: 'invalid_drill_root',
        path: ref.path,
        details: 'root must be a JSON object',
      ),
    );
    return null;
  }
  return decoded;
}

List<ContentIntegrityIssueV1> _collectBlockingIssuesV1(
  _DrillFileRefV1 ref,
  Map<String, Object?> json,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final id = _readNonEmptyStringV1(json['id']);
  final kind = _readNonEmptyStringV1(json['kind']);
  final prompt = _readNonEmptyStringV1(json['prompt']);
  final errorClass = _readNonEmptyStringV1(json['error_class']);
  final expected = json['expected'];

  if (id == null) {
    issues.add(_issueV1(ref, 'missing_id'));
  }
  if (kind == null) {
    issues.add(_issueV1(ref, 'missing_kind'));
  }
  if (prompt == null) {
    issues.add(_issueV1(ref, 'missing_prompt'));
  }
  if (errorClass == null) {
    issues.add(_issueV1(ref, 'missing_error_class'));
  }
  if (kind != null &&
      !_kExpectedExemptKindsV1.contains(kind) &&
      expected is! Map<String, Object?>) {
    issues.add(_issueV1(ref, 'missing_expected'));
  }
  return issues;
}

DrillSpecV1? _parseDrillSpecV1(
  _DrillFileRefV1 ref,
  Map<String, Object?> json,
  List<ContentIntegrityIssueV1> issues,
) {
  try {
    return DrillSpecV1.fromJson(json);
  } on FormatException catch (error) {
    issues.add(_issueV1(ref, 'invalid_drill_contract', details: error.message));
  } on StateError catch (error) {
    issues.add(_issueV1(ref, 'invalid_drill_contract', details: error.message));
  }
  return null;
}

List<ContentIntegrityIssueV1> _collectKindSpecificIssuesV1(
  _DrillFileRefV1 ref,
  Map<String, Object?> json,
  DrillSpecV1 spec,
) {
  final issues = <ContentIntegrityIssueV1>[];
  final kind = _readNonEmptyStringV1(json['kind'])!;

  if (_kFeedbackRequiredKindsV1.contains(kind)) {
    if (_readNonEmptyStringV1(json['feedback_correct_v1']) == null) {
      issues.add(_issueV1(ref, 'missing_feedback_correct_v1'));
    }
    if (_readNonEmptyStringV1(json['feedback_incorrect_v1']) == null) {
      issues.add(_issueV1(ref, 'missing_feedback_incorrect_v1'));
    }
  }

  final street = _readNonEmptyStringV1(json['street_v1'])?.toLowerCase();
  final boardCards = _readStringListV1(json['board_cards_v1']);
  if (street != null &&
      boardCards != null &&
      _kStreetBoardCardCountsV1.containsKey(street) &&
      boardCards.length != _kStreetBoardCardCountsV1[street]) {
    issues.add(_issueV1(ref, 'invalid_board_card_count_for_street_v1'));
  }

  switch (kind) {
    case 'action_choice':
      if (_expectedActionIdV1(json) == null) {
        issues.add(_issueV1(ref, 'missing_expected_action_id'));
      }
      break;
    case 'bet_sizing_choice_v1':
      if (_expectedPresetIdV1(json) == null) {
        issues.add(_issueV1(ref, 'missing_expected_preset_id'));
      }
      break;
    case 'seat_tap':
      if (_expectedSeatIdV1(json) == null && _expectedRoleV1(json) == null) {
        issues.add(_issueV1(ref, 'missing_expected_seat_or_role'));
      }
      break;
    case 'board_tap':
      if (_expectedBoardSlotV1(json) == null) {
        issues.add(_issueV1(ref, 'missing_expected_board_slot'));
      }
      break;
    case 'hole_cards_tap':
      if (_expectedCardSlotV1(json) == null) {
        issues.add(_issueV1(ref, 'missing_expected_card_slot'));
      }
      break;
    case 'showdown_winner_choice_v1':
      _requireStringFieldV1(json, 'street_v1', ref, issues);
      _requireStringListFieldV1(json, 'hero_hole_cards_v1', ref, issues);
      _requireStringListFieldV1(json, 'villain_hole_cards_v1', ref, issues);
      _requireStringListFieldV1(json, 'board_cards_v1', ref, issues);
      _requireActionAlignmentV1(
        ref: ref,
        availableActions: _readStringListV1(json['available_actions_v1']),
        expectedActionId: _expectedActionIdV1(json),
        issues: issues,
      );
      break;
    case 'position_thinking_choice_v1':
      _requireStringFieldV1(json, 'street_v1', ref, issues);
      _requireIntFieldV1(json, 'player_count_v1', ref, issues);
      _requireStringFieldV1(json, 'hero_seat_v1', ref, issues);
      _requireStringFieldV1(json, 'villain_seat_v1', ref, issues);
      _requireStringListFieldV1(json, 'active_seats_v1', ref, issues);
      _requireActionAlignmentV1(
        ref: ref,
        availableActions: _readStringListV1(json['available_actions_v1']),
        expectedActionId: _expectedActionIdV1(json),
        issues: issues,
      );
      break;
    case 'initiative_aggressor_choice_v1':
      _requireStringFieldV1(json, 'street_v1', ref, issues);
      _requireIntFieldV1(json, 'player_count_v1', ref, issues);
      _requireStringFieldV1(json, 'hero_seat_v1', ref, issues);
      _requireStringFieldV1(json, 'villain_seat_v1', ref, issues);
      _requireStringListFieldV1(json, 'active_seats_v1', ref, issues);
      _requireStringFieldV1(json, 'last_aggressor_v1', ref, issues);
      _requireStringFieldV1(json, 'initiative_owner_v1', ref, issues);
      _requireActionAlignmentV1(
        ref: ref,
        availableActions: _readStringListV1(json['available_actions_v1']),
        expectedActionId: _expectedActionIdV1(json),
        issues: issues,
      );
      break;
    case 'outs_count_choice_v1':
      _requireStringFieldV1(json, 'street_v1', ref, issues);
      _requireStringListFieldV1(json, 'hero_hole_cards_v1', ref, issues);
      _requireStringListFieldV1(json, 'board_cards_v1', ref, issues);
      _requireActionAlignmentV1(
        ref: ref,
        availableActions: _readStringListV1(json['available_actions_v1']),
        expectedActionId: _expectedActionIdV1(json),
        issues: issues,
      );
      break;
    case 'board_texture_classifier_v1':
      _requireStringFieldV1(json, 'board_texture_v1', ref, issues);
      if (_readNonEmptyStringV1(json['expected_action']) == null) {
        issues.add(_issueV1(ref, 'missing_expected_action'));
      }
      break;
    case 'range_bucket_classifier_v1':
      _requireStringFieldV1(json, 'range_bucket_v1', ref, issues);
      if (_readNonEmptyStringV1(json['expected_action']) == null) {
        issues.add(_issueV1(ref, 'missing_expected_action'));
      }
      break;
    case 'hand_chain_v1':
      if (spec.chainStepsV1 == null || spec.chainStepsV1!.isEmpty) {
        issues.add(_issueV1(ref, 'missing_chain_steps'));
      }
      break;
  }

  return issues;
}

void _requireActionAlignmentV1({
  required _DrillFileRefV1 ref,
  required List<String>? availableActions,
  required String? expectedActionId,
  required List<ContentIntegrityIssueV1> issues,
}) {
  if (availableActions == null || availableActions.isEmpty) {
    issues.add(_issueV1(ref, 'missing_available_actions_v1'));
    return;
  }
  if (expectedActionId == null || expectedActionId.isEmpty) {
    issues.add(_issueV1(ref, 'missing_expected_action'));
    return;
  }
  if (!availableActions.contains(expectedActionId)) {
    issues.add(_issueV1(ref, 'expected_action_not_in_available_actions_v1'));
  }
}

void _requireStringFieldV1(
  Map<String, Object?> json,
  String key,
  _DrillFileRefV1 ref,
  List<ContentIntegrityIssueV1> issues,
) {
  if (_readNonEmptyStringV1(json[key]) == null) {
    issues.add(_issueV1(ref, 'missing_$key'));
  }
}

void _requireIntFieldV1(
  Map<String, Object?> json,
  String key,
  _DrillFileRefV1 ref,
  List<ContentIntegrityIssueV1> issues,
) {
  if (json[key] is! int) {
    issues.add(_issueV1(ref, 'missing_$key'));
  }
}

void _requireStringListFieldV1(
  Map<String, Object?> json,
  String key,
  _DrillFileRefV1 ref,
  List<ContentIntegrityIssueV1> issues,
) {
  final values = _readStringListV1(json[key]);
  if (values == null || values.isEmpty) {
    issues.add(_issueV1(ref, 'missing_$key'));
  }
}

ContentIntegrityIssueV1 _issueV1(
  _DrillFileRefV1 ref,
  String reason, {
  String? details,
}) {
  return ContentIntegrityIssueV1(
    world: ref.world,
    sessionId: ref.sessionId,
    drillId: ref.drillId,
    reason: reason,
    path: ref.path,
    details: details,
  );
}

String? _readNonEmptyStringV1(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

List<String>? _readStringListV1(Object? raw) {
  if (raw is! List<Object?>) {
    return null;
  }
  final values = raw
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  if (values.isEmpty || values.length != raw.length) {
    return null;
  }
  return values;
}

int? _readPositiveIntV1(Object? raw) {
  if (raw is! int || raw <= 0) {
    return null;
  }
  return raw;
}

Map<String, Object?>? _expectedMapV1(Map<String, Object?> json) {
  final raw = json['expected'];
  if (raw is! Map<String, Object?>) {
    return null;
  }
  return raw;
}

String? _expectedActionIdV1(Map<String, Object?> json) {
  return _readNonEmptyStringV1(_expectedMapV1(json)?['actionId']);
}

String? _expectedPresetIdV1(Map<String, Object?> json) {
  return _readNonEmptyStringV1(_expectedMapV1(json)?['presetId']);
}

String? _expectedSeatIdV1(Map<String, Object?> json) {
  return _readNonEmptyStringV1(_expectedMapV1(json)?['seatId']);
}

String? _expectedRoleV1(Map<String, Object?> json) {
  return _readNonEmptyStringV1(_expectedMapV1(json)?['role']);
}

String? _expectedBoardSlotV1(Map<String, Object?> json) {
  return _readNonEmptyStringV1(_expectedMapV1(json)?['boardSlot']);
}

String? _expectedCardSlotV1(Map<String, Object?> json) {
  return _readNonEmptyStringV1(_expectedMapV1(json)?['cardSlot']);
}

String? _expectedCardIdV1(Map<String, Object?> json) {
  return _readNonEmptyStringV1(_expectedMapV1(json)?['cardId']);
}

String _inferDrillIdFromPathV1(String path) {
  final name = path.split(Platform.pathSeparator).last;
  if (name.startsWith('d.') && name.endsWith('.json')) {
    return name.substring(2, name.length - 5);
  }
  if (name.endsWith('.json')) {
    return name.substring(0, name.length - 5);
  }
  return name;
}

int _compareRefsV1(_DrillFileRefV1 a, _DrillFileRefV1 b) {
  final byWorld = a.world.compareTo(b.world);
  if (byWorld != 0) return byWorld;
  final bySession = a.sessionId.compareTo(b.sessionId);
  if (bySession != 0) return bySession;
  return a.path.compareTo(b.path);
}

const Set<String> _kCanonicalTopologySeatsV1 = <String>{
  'btn',
  'sb',
  'bb',
  'co',
  'hj',
  'lj',
  'utg',
  'utg1',
  'mp1',
  'mp',
};

const List<String> _kCanonicalTopology10MaxSeatOrderV1 = <String>[
  'btn',
  'co',
  'hj',
  'lj',
  'utg',
  'utg1',
  'mp1',
  'mp',
  'sb',
  'bb',
];

const List<String> _kCanonicalTopology9MaxSeatOrderV1 = <String>[
  'btn',
  'co',
  'hj',
  'lj',
  'utg',
  'utg1',
  'mp',
  'sb',
  'bb',
];

const List<String> _kCanonicalTopology8MaxSeatOrderV1 = <String>[
  'btn',
  'co',
  'hj',
  'lj',
  'utg',
  'utg1',
  'sb',
  'bb',
];

const List<String> _kCanonicalTopology7MaxSeatOrderV1 = <String>[
  'btn',
  'co',
  'hj',
  'lj',
  'utg',
  'sb',
  'bb',
];

const List<String> _kCanonicalTopology6MaxSeatOrderV1 = <String>[
  'btn',
  'co',
  'hj',
  'sb',
  'bb',
  'utg',
];

const List<String> _kCanonicalTopology2MaxSeatOrderV1 = <String>['sb', 'bb'];

List<ContentIntegrityIssueV1> _collectCanonicalBlindLevelReadinessIssuesV1({
  required _DrillFileRefV1 ref,
  required Map<String, Object?> shared,
  required Set<String> activeSeats,
}) {
  final smallBlindSeat = _readNonEmptyStringV1(
    shared['small_blind_seat_v1'],
  )?.trim().toLowerCase();
  final bigBlindSeat = _readNonEmptyStringV1(
    shared['big_blind_seat_v1'],
  )?.trim().toLowerCase();
  final smallBlindAmount = _readPositiveIntV1(shared['small_blind_amount_v1']);
  final bigBlindAmount = _readPositiveIntV1(shared['big_blind_amount_v1']);
  final anteAmount = _readPositiveIntV1(shared['ante_amount_v1']);

  final hasAnyBlindLevelField =
      smallBlindSeat != null ||
      bigBlindSeat != null ||
      smallBlindAmount != null ||
      bigBlindAmount != null ||
      anteAmount != null;
  if (!hasAnyBlindLevelField) {
    return const <ContentIntegrityIssueV1>[];
  }

  final hasCompleteBlindPair =
      smallBlindSeat != null &&
      bigBlindSeat != null &&
      smallBlindAmount != null &&
      bigBlindAmount != null;
  if (!hasCompleteBlindPair) {
    return <ContentIntegrityIssueV1>[
      _issueV1(
        ref,
        'blind_level_pair_incomplete_v1',
        details:
            'small_blind_seat_v1, big_blind_seat_v1, small_blind_amount_v1, and big_blind_amount_v1 must appear together; ante_amount_v1 is only valid with a complete blind pair',
      ),
    ];
  }

  final issues = <ContentIntegrityIssueV1>[];
  if (!activeSeats.contains(smallBlindSeat)) {
    issues.add(_issueV1(ref, 'small_blind_seat_not_in_active_seats_v1'));
  }
  if (!activeSeats.contains(bigBlindSeat)) {
    issues.add(_issueV1(ref, 'big_blind_seat_not_in_active_seats_v1'));
  }
  if (smallBlindSeat == bigBlindSeat) {
    issues.add(_issueV1(ref, 'blind_level_seats_not_distinct_v1'));
  }
  if (bigBlindAmount < smallBlindAmount) {
    issues.add(_issueV1(ref, 'blind_level_amount_order_invalid_v1'));
  }
  return issues;
}

ContentIntegrityReportV1 _collectWorld6To9TopologyReadinessIssuesV1(
  String rootPath,
  Set<int> worlds,
) {
  final scopedWorlds = worlds.intersection(const <int>{6, 7, 8, 9});
  if (scopedWorlds.isEmpty) {
    return const ContentIntegrityReportV1(
      filesChecked: 0,
      issues: <ContentIntegrityIssueV1>[],
    );
  }

  final issues = <ContentIntegrityIssueV1>[];
  var filesChecked = 0;
  final orderedWorlds = scopedWorlds.toList()..sort();
  for (final world in orderedWorlds) {
    final defaultsPath =
        'content/worlds/world$world/v1/sessions/spatial_projection_defaults_v1.json';
    final file = File('$rootPath/$defaultsPath');
    if (!file.existsSync()) {
      continue;
    }
    filesChecked++;
    final dynamic decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException catch (error) {
      issues.add(
        ContentIntegrityIssueV1(
          world: world,
          sessionId: 'world$world.sessions',
          drillId: '__session_defaults__',
          reason: 'invalid_session_projection_defaults_json_v1',
          path: defaultsPath,
          details: error.message,
        ),
      );
      continue;
    }
    if (decoded is! Map<String, Object?>) {
      issues.add(
        ContentIntegrityIssueV1(
          world: world,
          sessionId: 'world$world.sessions',
          drillId: '__session_defaults__',
          reason: 'invalid_session_projection_defaults_root_v1',
          path: defaultsPath,
          details: 'root must be a JSON object',
        ),
      );
      continue;
    }
    final sessions = decoded['sessions'];
    if (sessions is! Map<String, Object?>) {
      issues.add(
        ContentIntegrityIssueV1(
          world: world,
          sessionId: 'world$world.sessions',
          drillId: '__session_defaults__',
          reason: 'missing_session_projection_defaults_sessions_v1',
          path: defaultsPath,
        ),
      );
      continue;
    }
    final sessionEntries = sessions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final sessionEntry in sessionEntries) {
      final sessionId = sessionEntry.key;
      final sessionMap = sessionEntry.value;
      final ref = _DrillFileRefV1(
        world: world,
        sessionId: sessionId,
        drillId: '__session_defaults__',
        path: defaultsPath,
      );
      if (sessionMap is! Map<String, Object?>) {
        issues.add(
          _issueV1(ref, 'invalid_session_projection_defaults_entry_v1'),
        );
        continue;
      }
      final shared = sessionMap['shared'];
      if (shared is! Map<String, Object?>) {
        issues.add(
          _issueV1(ref, 'missing_session_projection_defaults_shared_v1'),
        );
        continue;
      }
      final playerCount = shared['player_count_v1'];
      final activeSeats = _readStringListV1(shared['active_seats_v1']);
      final heroSeat = _readNonEmptyStringV1(shared['hero_seat_v1']);
      final villainSeat = _readNonEmptyStringV1(shared['villain_seat_v1']);
      if (playerCount is! int) {
        issues.add(_issueV1(ref, 'missing_player_count_v1'));
      }
      if (activeSeats == null || activeSeats.isEmpty) {
        issues.add(_issueV1(ref, 'missing_active_seats_v1'));
      }
      if (heroSeat == null) {
        issues.add(_issueV1(ref, 'missing_hero_seat_v1'));
      }
      if (villainSeat == null) {
        issues.add(_issueV1(ref, 'missing_villain_seat_v1'));
      }
      if (playerCount is! int || activeSeats == null || activeSeats.isEmpty) {
        continue;
      }
      final normalizedSeats = activeSeats
          .map((seat) => seat.trim().toLowerCase())
          .toList(growable: false);
      final uniqueSeats = normalizedSeats.toSet();
      if (normalizedSeats.length != uniqueSeats.length) {
        issues.add(_issueV1(ref, 'duplicate_active_seats_v1'));
      }
      if (playerCount != normalizedSeats.length) {
        issues.add(
          _issueV1(
            ref,
            'player_count_active_seat_count_mismatch_v1',
            details:
                'player_count_v1=$playerCount but active_seats_v1 has ${normalizedSeats.length} entries',
          ),
        );
      }
      final unknownSeats = uniqueSeats.difference(_kCanonicalTopologySeatsV1);
      if (unknownSeats.isNotEmpty) {
        final sortedUnknownSeats = unknownSeats.toList()..sort();
        issues.add(
          _issueV1(
            ref,
            'unknown_active_seat_token_v1',
            details: sortedUnknownSeats.join(','),
          ),
        );
      }
      if (playerCount == 7 &&
          !_listsEqualV1(normalizedSeats, _kCanonicalTopology7MaxSeatOrderV1)) {
        issues.add(
          _issueV1(
            ref,
            'seven_max_active_seat_order_mismatch_v1',
            details:
                'expected ${_kCanonicalTopology7MaxSeatOrderV1.join(",")} but found ${normalizedSeats.join(",")}',
          ),
        );
      }
      if (playerCount == 8 &&
          !_listsEqualV1(normalizedSeats, _kCanonicalTopology8MaxSeatOrderV1)) {
        issues.add(
          _issueV1(
            ref,
            'eight_max_active_seat_order_mismatch_v1',
            details:
                'expected ${_kCanonicalTopology8MaxSeatOrderV1.join(",")} but found ${normalizedSeats.join(",")}',
          ),
        );
      }
      if (heroSeat != null &&
          !uniqueSeats.contains(heroSeat.trim().toLowerCase())) {
        issues.add(_issueV1(ref, 'hero_seat_not_in_active_seats_v1'));
      }
      if (villainSeat != null &&
          !uniqueSeats.contains(villainSeat.trim().toLowerCase())) {
        issues.add(_issueV1(ref, 'villain_seat_not_in_active_seats_v1'));
      }
      issues.addAll(
        _collectCanonicalSeatTapRoleReadinessIssuesV1(
          rootPath: rootPath,
          world: world,
          sessionId: sessionId,
          drillsDirPath:
              '$rootPath/content/worlds/world$world/v1/sessions/$sessionId/drills',
          activeSeats: uniqueSeats,
          heroSeat: heroSeat?.trim().toLowerCase(),
        ),
      );
    }
  }

  return ContentIntegrityReportV1(
    filesChecked: filesChecked,
    issues: List<ContentIntegrityIssueV1>.unmodifiable(issues),
  );
}

ContentIntegrityReportV1 _collectWorld10TopologyReadinessIssuesV1(
  String rootPath,
  Set<int> worlds,
) {
  if (!worlds.contains(10)) {
    return const ContentIntegrityReportV1(
      filesChecked: 0,
      issues: <ContentIntegrityIssueV1>[],
    );
  }

  final issues = <ContentIntegrityIssueV1>[];
  var filesChecked = 0;
  for (final track in const <String>['cash', 'mixed', 'tournament']) {
    final defaultsPath =
        'content/worlds/world10/v1/tracks/$track/sessions/spatial_projection_defaults_v1.json';
    final file = File('$rootPath/$defaultsPath');
    if (!file.existsSync()) {
      continue;
    }
    filesChecked++;
    final dynamic decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException catch (error) {
      issues.add(
        ContentIntegrityIssueV1(
          world: 10,
          sessionId: '$track.sessions',
          drillId: '__session_defaults__',
          reason: 'invalid_session_projection_defaults_json_v1',
          path: defaultsPath,
          details: error.message,
        ),
      );
      continue;
    }
    if (decoded is! Map<String, Object?>) {
      issues.add(
        ContentIntegrityIssueV1(
          world: 10,
          sessionId: '$track.sessions',
          drillId: '__session_defaults__',
          reason: 'invalid_session_projection_defaults_root_v1',
          path: defaultsPath,
          details: 'root must be a JSON object',
        ),
      );
      continue;
    }
    final sessions = decoded['sessions'];
    if (sessions is! Map<String, Object?>) {
      issues.add(
        ContentIntegrityIssueV1(
          world: 10,
          sessionId: '$track.sessions',
          drillId: '__session_defaults__',
          reason: 'missing_session_projection_defaults_sessions_v1',
          path: defaultsPath,
        ),
      );
      continue;
    }
    final sessionEntries = sessions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final sessionEntry in sessionEntries) {
      final sessionId = sessionEntry.key;
      final sessionMap = sessionEntry.value;
      final ref = _DrillFileRefV1(
        world: 10,
        sessionId: sessionId,
        drillId: '__session_defaults__',
        path: defaultsPath,
      );
      if (sessionMap is! Map<String, Object?>) {
        issues.add(
          _issueV1(ref, 'invalid_session_projection_defaults_entry_v1'),
        );
        continue;
      }
      final shared = sessionMap['shared'];
      if (shared is! Map<String, Object?>) {
        issues.add(
          _issueV1(ref, 'missing_session_projection_defaults_shared_v1'),
        );
        continue;
      }
      final playerCount = shared['player_count_v1'];
      final activeSeats = _readStringListV1(shared['active_seats_v1']);
      final heroSeat = _readNonEmptyStringV1(shared['hero_seat_v1']);
      final villainSeat = _readNonEmptyStringV1(shared['villain_seat_v1']);
      if (playerCount is! int) {
        issues.add(_issueV1(ref, 'missing_player_count_v1'));
      }
      if (activeSeats == null || activeSeats.isEmpty) {
        issues.add(_issueV1(ref, 'missing_active_seats_v1'));
      }
      if (heroSeat == null) {
        issues.add(_issueV1(ref, 'missing_hero_seat_v1'));
      }
      if (villainSeat == null) {
        issues.add(_issueV1(ref, 'missing_villain_seat_v1'));
      }
      if (playerCount is! int || activeSeats == null || activeSeats.isEmpty) {
        continue;
      }
      final normalizedSeats = activeSeats
          .map((seat) => seat.trim().toLowerCase())
          .toList(growable: false);
      final uniqueSeats = normalizedSeats.toSet();
      if (normalizedSeats.length != uniqueSeats.length) {
        issues.add(_issueV1(ref, 'duplicate_active_seats_v1'));
      }
      if (playerCount != normalizedSeats.length) {
        issues.add(
          _issueV1(
            ref,
            'player_count_active_seat_count_mismatch_v1',
            details:
                'player_count_v1=$playerCount but active_seats_v1 has ${normalizedSeats.length} entries',
          ),
        );
      }
      final unknownSeats = uniqueSeats.difference(_kCanonicalTopologySeatsV1);
      if (unknownSeats.isNotEmpty) {
        final sortedUnknownSeats = unknownSeats.toList()..sort();
        issues.add(
          _issueV1(
            ref,
            'unknown_active_seat_token_v1',
            details: sortedUnknownSeats.join(','),
          ),
        );
      }
      if (playerCount == 10 &&
          !_listsEqualV1(
            normalizedSeats,
            _kCanonicalTopology10MaxSeatOrderV1,
          )) {
        issues.add(
          _issueV1(
            ref,
            'ten_max_active_seat_order_mismatch_v1',
            details:
                'expected ${_kCanonicalTopology10MaxSeatOrderV1.join(",")} but found ${normalizedSeats.join(",")}',
          ),
        );
      }
      if (playerCount == 9 &&
          !_listsEqualV1(normalizedSeats, _kCanonicalTopology9MaxSeatOrderV1)) {
        issues.add(
          _issueV1(
            ref,
            'nine_max_active_seat_order_mismatch_v1',
            details:
                'expected ${_kCanonicalTopology9MaxSeatOrderV1.join(",")} but found ${normalizedSeats.join(",")}',
          ),
        );
      }
      if (playerCount == 6 &&
          !_listsEqualV1(normalizedSeats, _kCanonicalTopology6MaxSeatOrderV1)) {
        issues.add(
          _issueV1(
            ref,
            'six_max_active_seat_order_mismatch_v1',
            details:
                'expected ${_kCanonicalTopology6MaxSeatOrderV1.join(",")} but found ${normalizedSeats.join(",")}',
          ),
        );
      }
      if (playerCount == 2 &&
          !_listsEqualV1(normalizedSeats, _kCanonicalTopology2MaxSeatOrderV1)) {
        issues.add(
          _issueV1(
            ref,
            'two_max_active_seat_order_mismatch_v1',
            details:
                'expected ${_kCanonicalTopology2MaxSeatOrderV1.join(",")} but found ${normalizedSeats.join(",")}',
          ),
        );
      }
      if (heroSeat != null &&
          !uniqueSeats.contains(heroSeat.trim().toLowerCase())) {
        issues.add(_issueV1(ref, 'hero_seat_not_in_active_seats_v1'));
      }
      if (villainSeat != null &&
          !uniqueSeats.contains(villainSeat.trim().toLowerCase())) {
        issues.add(_issueV1(ref, 'villain_seat_not_in_active_seats_v1'));
      }
      issues.addAll(
        _collectCanonicalBlindLevelReadinessIssuesV1(
          ref: ref,
          shared: shared,
          activeSeats: uniqueSeats,
        ),
      );
      issues.addAll(
        _collectCanonicalSeatTapRoleReadinessIssuesV1(
          rootPath: rootPath,
          world: 10,
          sessionId: sessionId,
          drillsDirPath:
              '$rootPath/content/worlds/world10/v1/tracks/$track/sessions/$sessionId/drills',
          activeSeats: uniqueSeats,
          heroSeat: heroSeat?.trim().toLowerCase(),
        ),
      );
    }
  }
  return ContentIntegrityReportV1(
    filesChecked: filesChecked,
    issues: List<ContentIntegrityIssueV1>.unmodifiable(issues),
  );
}

List<ContentIntegrityIssueV1> _collectCanonicalSeatTapRoleReadinessIssuesV1({
  required String rootPath,
  required int world,
  required String sessionId,
  required String drillsDirPath,
  required Set<String> activeSeats,
  required String? heroSeat,
}) {
  final issues = <ContentIntegrityIssueV1>[];
  final drillsDir = Directory(drillsDirPath);
  if (!drillsDir.existsSync()) {
    return issues;
  }
  final drillFiles = drillsDir.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final drillFile in drillFiles) {
    if (!drillFile.path.endsWith('.json')) {
      continue;
    }
    final dynamic raw;
    try {
      raw = jsonDecode(drillFile.readAsStringSync());
    } on FormatException {
      continue;
    }
    if (raw is! Map<String, Object?>) {
      continue;
    }
    if (_readNonEmptyStringV1(raw['kind']) != 'seat_tap') {
      continue;
    }
    final expectedRole = _expectedRoleV1(raw)?.trim().toLowerCase();
    if (expectedRole == null) {
      continue;
    }
    final ref = _DrillFileRefV1(
      world: world,
      sessionId: sessionId,
      drillId: _inferDrillIdFromPathV1(drillFile.path),
      path: path.relative(drillFile.path, from: Directory(rootPath).path),
    );
    final promptRole = _expectedSeatRoleFromPromptV1(
      _readNonEmptyStringV1(raw['prompt'])?.toLowerCase() ?? '',
    );
    if (promptRole != null && promptRole != expectedRole) {
      issues.add(
        _issueV1(
          ref,
          'seat_tap_prompt_role_mismatch_v1',
          details:
              'prompt implies $promptRole but expected.role is $expectedRole',
        ),
      );
    }
    if (!activeSeats.contains(expectedRole)) {
      issues.add(
        _issueV1(
          ref,
          'seat_tap_expected_role_not_in_active_seats_v1',
          details:
              'expected.role=$expectedRole active_seats_v1=${activeSeats.toList()..sort()}',
        ),
      );
    }
    if (heroSeat != null &&
        heroSeat != 'btn' &&
        expectedRole == heroSeat &&
        ref.drillId == 'find_role_anchor') {
      issues.add(
        _issueV1(
          ref,
          'seat_tap_role_anchor_collides_with_non_button_hero_v1',
          details:
              'hero_seat_v1=$heroSeat expected.role=$expectedRole requires explicit non-hero role-anchor wording before live alternative seating authoring',
        ),
      );
    }
  }
  return issues;
}

String? _expectedSeatRoleFromPromptV1(String prompt) {
  final lowered = prompt.toLowerCase();
  for (final entry in const <MapEntry<String, String>>[
    MapEntry<String, String>(r'\bmp\+1\b', 'mp1'),
    MapEntry<String, String>(r'\bmp1\b', 'mp1'),
    MapEntry<String, String>(r'\butg\+1\b', 'utg1'),
    MapEntry<String, String>(r'\butg1\b', 'utg1'),
    MapEntry<String, String>(r'\bbtn\b', 'btn'),
    MapEntry<String, String>(r'\bsb\b', 'sb'),
    MapEntry<String, String>(r'\bbb\b', 'bb'),
    MapEntry<String, String>(r'\bco\b', 'co'),
    MapEntry<String, String>(r'\bhj\b', 'hj'),
    MapEntry<String, String>(r'\blj\b', 'lj'),
    MapEntry<String, String>(r'\butg\b', 'utg'),
    MapEntry<String, String>(r'\bmp\b', 'mp'),
  ]) {
    if (RegExp(entry.key).hasMatch(lowered)) {
      return entry.value;
    }
  }
  return null;
}

bool _listsEqualV1(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

int _compareIssuesV1(ContentIntegrityIssueV1 a, ContentIntegrityIssueV1 b) {
  final byWorld = a.world.compareTo(b.world);
  if (byWorld != 0) return byWorld;
  final bySession = a.sessionId.compareTo(b.sessionId);
  if (bySession != 0) return bySession;
  final byDrill = a.drillId.compareTo(b.drillId);
  if (byDrill != 0) return byDrill;
  final byReason = a.reason.compareTo(b.reason);
  if (byReason != 0) return byReason;
  return a.path.compareTo(b.path);
}
