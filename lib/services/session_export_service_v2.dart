import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../ui_v2/hand_analyzer_mode.dart';
import '../ui_v2/session_playback_engine.dart';

class SessionExportSummary {
  const SessionExportSummary({
    required this.pathOriginal,
    required this.actionsCount,
    required this.analysisCount,
  });

  final String pathOriginal;
  final int actionsCount;
  final int analysisCount;
}

Future<SessionExportSummary> exportAnalyzedSession({
  required List<PlaybackAction> actions,
  required List<HandAnalyzerEntry> analysis,
  required List<String> positions,
  required List<String> board,
  required List<int> potHistory,
}) async {
  final directory = Directory('export/sessions');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final timestamp = DateTime.now().toIso8601String();
  final fileName = 'session_${timestamp.replaceAll(':', '-')}.json';
  final file = File(p.join(directory.path, fileName));

  final payload = _ExportPayload(
    timestamp: timestamp,
    actions: actions,
    analysis: analysis,
    positions: positions,
    board: board,
    potHistory: potHistory,
  );

  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload.toJson()),
  );

  return SessionExportSummary(
    pathOriginal: file.path,
    actionsCount: actions.length,
    analysisCount: analysis.length,
  );
}

Future<_ExportPayload> importAnalyzedSession(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw ArgumentError('File not found: $path');
  }
  final raw = await file.readAsString();
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid session export payload');
  }
  return _ExportPayload.fromJson(decoded);
}

Future<void> validateExport(String path) async {
  final payload = await importAnalyzedSession(path);
  if (payload.timestamp.isEmpty) {
    throw const FormatException('Missing timestamp');
  }
  final timestamp = DateTime.tryParse(payload.timestamp);
  if (timestamp == null) {
    throw FormatException('Invalid timestamp ${payload.timestamp}');
  }
  if (payload.actions.isEmpty) {
    throw const FormatException('No actions recorded');
  }
  if (payload.board.length > 5) {
    throw const FormatException('Board cards exceed 5 entries');
  }
}

class _ExportPayload {
  _ExportPayload({
    required this.timestamp,
    required this.actions,
    required this.analysis,
    required this.positions,
    required this.board,
    required this.potHistory,
  });

  final String timestamp;
  final List<PlaybackAction> actions;
  final List<HandAnalyzerEntry> analysis;
  final List<String> positions;
  final List<String> board;
  final List<int> potHistory;

  Map<String, Object?> toJson() {
    return {
      'timestamp': timestamp,
      'positions': positions,
      'board': board,
      'pot_history': potHistory,
      'actions': actions.map(_serializeAction).toList(),
      'analysis': analysis.map(_serializeAnalysis).toList(),
    };
  }

  static _ExportPayload fromJson(Map<String, dynamic> json) {
    final timestamp = json['timestamp']?.toString() ?? '';
    final positions =
        (json['positions'] as List?)?.map((e) => e.toString()).toList() ??
        const [];
    final board =
        (json['board'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final potHistory =
        (json['pot_history'] as List?)
            ?.map((e) => int.tryParse(e.toString()) ?? 0)
            .toList() ??
        const [];
    final actions =
        (json['actions'] as List?)
            ?.map((e) => _deserializeAction(e as Map<String, dynamic>))
            .toList() ??
        const <PlaybackAction>[];
    final analysis =
        (json['analysis'] as List?)
            ?.map((e) => _deserializeAnalysis(e as Map<String, dynamic>))
            .toList() ??
        const <HandAnalyzerEntry>[];

    return _ExportPayload(
      timestamp: timestamp,
      actions: actions,
      analysis: analysis,
      positions: positions,
      board: board,
      potHistory: potHistory,
    );
  }
}

Map<String, Object?> _serializeAction(PlaybackAction action) {
  return {
    'seat': action.seat,
    'type': action.type.name,
    'amount': action.amount,
    'description': action.description,
  };
}

PlaybackAction _deserializeAction(Map<String, dynamic> json) {
  final typeName = json['type']?.toString() ?? PlaybackActionType.none.name;
  final type = PlaybackActionType.values.firstWhere(
    (value) => value.name == typeName,
    orElse: () => PlaybackActionType.none,
  );
  return PlaybackAction(
    seat: json['seat'] as int? ?? 0,
    type: type,
    amount: json['amount'] as int? ?? 0,
    description: json['description']?.toString(),
  );
}

Map<String, Object?> _serializeAnalysis(HandAnalyzerEntry entry) {
  return {
    'index': entry.actionIndex,
    'correct_action': entry.correctAction.name,
    'ev_diff': entry.evDiff,
    'rationale': entry.rationale,
  };
}

HandAnalyzerEntry _deserializeAnalysis(Map<String, dynamic> json) {
  final typeName =
      json['correct_action']?.toString() ?? PlaybackActionType.none.name;
  final type = PlaybackActionType.values.firstWhere(
    (value) => value.name == typeName,
    orElse: () => PlaybackActionType.none,
  );
  return HandAnalyzerEntry(
    actionIndex: json['index'] as int? ?? 0,
    correctAction: type,
    evDiff: (json['ev_diff'] as num?)?.toDouble() ?? 0.0,
    rationale: json['rationale']?.toString() ?? '',
  );
}
