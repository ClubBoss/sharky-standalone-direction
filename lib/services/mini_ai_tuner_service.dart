import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui/session_player/spot_specs.dart' as specs;

class MiniAiResult {
  MiniAiResult({
    required this.sessionId,
    required this.advice,
    required this.unmappedTags,
    required this.timestampUtc,
  });

  final String sessionId;
  final List<AdviceEntry> advice;
  final List<String> unmappedTags;
  final DateTime timestampUtc;

  int get verifiedCount => advice.length;
  bool get pass => verifiedCount > 0;

  Map<String, Object?> toJson() => {
    'session_id': sessionId,
    'verified_count': verifiedCount,
    'skipped_unmapped': unmappedTags,
    'timestamp_utc': timestampUtc.toIso8601String(),
    'pass': pass,
    'advice': advice.map((e) => e.toJson()).toList(),
  };
}

class AdviceEntry {
  AdviceEntry({
    required this.tag,
    required this.severity,
    required this.suggestion,
    required this.relatedModule,
  });

  final String tag;
  final double severity;
  final String suggestion;
  final String relatedModule;

  Map<String, Object?> toJson() => {
    'tag': tag,
    'severity': severity,
    'suggestion': suggestion,
    'related_module': relatedModule,
    'verified': true,
  };
}

class MiniAiTunerService {
  MiniAiTunerService({
    this.sessionsDirectory = 'export/sessions',
    this.reportPath = 'tools/_reports/ai_tuner_summary.json',
  });

  final String sessionsDirectory;
  final String reportPath;

  Future<MiniAiResult> analyzeSession(
    String sessionIdentifier, {
    bool writeReport = true,
  }) async {
    final sessionFile = _resolveSessionFile(sessionIdentifier);
    if (!sessionFile.existsSync()) {
      throw StateError('Session file not found: ${sessionFile.path}');
    }
    final raw = sessionFile.readAsStringSync();
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e) {
      throw StateError('Invalid session JSON (${sessionFile.path}): $e');
    }

    final records = <_MistakeRecord>[];
    _collectMistakes(decoded, records);

    final stats = <String, _TagStats>{};
    for (final record in records) {
      final stat = stats.putIfAbsent(record.tag, () => _TagStats(record.tag));
      stat.add(record.evLoss);
    }

    final sortedStats = stats.values.toList()
      ..sort((a, b) => b.severity.compareTo(a.severity));

    final advice = <AdviceEntry>[];
    final skipped = <String>[];

    for (final stat in sortedStats) {
      final mapping = verifyAndMapTag(stat.tag);
      if (mapping == null) {
        skipped.add(stat.tag);
        continue;
      }
      if (stat.severity <= 0) {
        continue;
      }
      final subtitle = mapping['subtitle']!;
      final moduleId = mapping['moduleId']!;
      final suggestion =
          'Review $subtitle — focus on key mistake pattern (${stat.tag}).';
      advice.add(
        AdviceEntry(
          tag: stat.tag,
          severity: double.parse(
            stat.severity.toStringAsFixed(4),
          ), // deterministic
          suggestion: suggestion,
          relatedModule: moduleId,
        ),
      );
      if (advice.length == 3) break;
    }

    final result = MiniAiResult(
      sessionId: p.basenameWithoutExtension(sessionFile.path),
      advice: advice,
      unmappedTags: skipped,
      timestampUtc: DateTime.now().toUtc(),
    );

    if (writeReport) {
      final reportFile = File(reportPath);
      reportFile.parent.createSync(recursive: true);
      reportFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(result.toJson()),
      );
    }

    return result;
  }

  Map<String, String>? verifyAndMapTag(String tag) {
    final normalized = _canonicalize(tag);
    final kind = _resolveSpotKind(normalized);
    if (kind == null) {
      stderr.writeln('MiniAiTuner unmapped tag: $tag');
      return null;
    }

    final prefix = specs.subtitlePrefix[kind];
    if (prefix == null || prefix.trim().isEmpty) {
      stderr.writeln('MiniAiTuner unmapped tag: $tag');
      return null;
    }

    return {'moduleId': kind.name, 'subtitle': prefix.trim()};
  }

  String? resolveLatestSessionId() {
    final dir = Directory(sessionsDirectory);
    if (!dir.existsSync()) return null;
    final candidates = dir
        .listSync()
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.json') &&
              !file.path.endsWith('_review.json'),
        )
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );
    return p.basenameWithoutExtension(candidates.first.path);
  }

  File _resolveSessionFile(String identifier) {
    final candidate = identifier.trim();
    final direct = File(candidate);
    if (direct.existsSync()) {
      return direct;
    }

    final withExtension = candidate.endsWith('.json')
        ? candidate
        : '$candidate.json';
    final resolved = File(p.join(sessionsDirectory, withExtension));
    return resolved;
  }

  void _collectMistakes(dynamic node, List<_MistakeRecord> out) {
    if (node is Map) {
      final tags = node['mistake_tags'];
      final evLoss = node['ev_loss'] ?? node['evLoss'];
      if (tags is List && evLoss is num) {
        final loss = evLoss.toDouble();
        for (final rawTag in tags) {
          if (rawTag is! String) continue;
          final cleaned = rawTag.trim();
          if (cleaned.isEmpty) continue;
          out.add(_MistakeRecord(cleaned, loss));
        }
      }
      for (final value in node.values) {
        _collectMistakes(value, out);
      }
    } else if (node is List) {
      for (final item in node) {
        _collectMistakes(item, out);
      }
    }
  }

  String _canonicalize(String tag) => tag
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp('_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  SpotKind? _resolveSpotKind(String normalized) {
    for (final kind in SpotKind.values) {
      if (kind.name == normalized) {
        return kind;
      }
    }
    final compact = normalized.replaceAll('_', '');
    for (final kind in SpotKind.values) {
      if (kind.name.replaceAll('_', '') == compact) {
        return kind;
      }
    }
    return null;
  }
}

class _MistakeRecord {
  _MistakeRecord(this.tag, this.evLoss);

  final String tag;
  final double evLoss;
}

class _TagStats {
  _TagStats(this.tag);

  final String tag;
  int _count = 0;
  double _totalEvLoss = 0;

  void add(double evLoss) {
    _count += 1;
    _totalEvLoss += evLoss;
  }

  int get frequency => _count;
  double get meanEvLoss => _count == 0 ? 0 : _totalEvLoss / _count;
  double get severity => frequency * meanEvLoss.abs();
}

Future<void> main(List<String> args) async {
  String? sessionId;
  for (final arg in args) {
    if (arg.startsWith('--session=')) {
      sessionId = arg.substring('--session='.length);
    }
  }

  final service = MiniAiTunerService();
  sessionId ??= service.resolveLatestSessionId();

  if (sessionId == null) {
    final empty = {
      'session_id': null,
      'verified_count': 0,
      'skipped_unmapped': <String>[],
      'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
      'pass': false,
      'reason': 'no_session_found',
      'advice': <Object>[],
    };
    final reportFile = File(service.reportPath);
    reportFile.parent.createSync(recursive: true);
    reportFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(empty),
    );
    stdout.writeln('Mini AI Tuner: no sessions available to analyze.');
    print(jsonEncode(empty));
    exitCode = 1;
    return;
  }

  try {
    final result = await service.analyzeSession(sessionId);
    stdout.writeln(
      'Mini AI Tuner analyzed session $sessionId '
      '(${result.verifiedCount} verified recommendations).',
    );
    print(jsonEncode(result.toJson()));
  } catch (e) {
    final failure = {
      'session_id': sessionId,
      'verified_count': 0,
      'skipped_unmapped': <String>[],
      'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
      'pass': false,
      'reason': e.toString(),
      'advice': <Object>[],
    };
    final reportFile = File(service.reportPath);
    reportFile.parent.createSync(recursive: true);
    reportFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(failure),
    );
    stderr.writeln('Mini AI Tuner failed: $e');
    print(jsonEncode(failure));
    exitCode = 1;
  }
}
