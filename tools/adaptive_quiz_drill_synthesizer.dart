import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _semanticSummaryPath =
    '$_reportsDir/semantic_expansion_summary.txt';
const String _summaryOutPath =
    '$_reportsDir/adaptive_quiz_drill_synthesis_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const String _schemasDir = 'content/_schemas';
const List<String> _requiredSchemas = [
  'drills.schema.json',
  'quiz.schema.json',
];

Future<void> main(List<String> args) async {
  final synthesizer = AdaptiveQuizDrillSynthesizer();
  final ok = await synthesizer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveQuizDrillSynthesizer {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    await _ensureSchemas();
    final semanticSummary = await _parseSemanticSummary();
    if (semanticSummary.isEmpty) {
      stderr.writeln('No semantic templates found.');
      return false;
    }

    final topics = <String, List<_SemanticTemplate>>{};
    for (final template in semanticSummary) {
      topics.putIfAbsent(template.topic, () => []).add(template);
    }

    final synthesisResults = <_SynthesisResult>[];
    var filesGenerated = 0;
    for (final entry in topics.entries) {
      final topic = entry.key;
      final templates = entry.value;
      final targetDir = Directory('content_adaptive_generated/$topic/v1');
      await targetDir.create(recursive: true);

      final drillTemplates = templates.where((t) => t.kind == 'DRILL').toList();
      final quizTemplates = templates.where((t) => t.kind == 'QUIZ').toList();

      if (drillTemplates.isNotEmpty) {
        final file = File('${targetDir.path}/drills.jsonl');
        await _writeJsonl(
          file,
          drillTemplates
              .asMap()
              .entries
              .map((entry) => _buildDrill(entry.value, topic, entry.key))
              .toList(),
        );
        filesGenerated++;
      }

      if (quizTemplates.isNotEmpty) {
        final file = File('${targetDir.path}/quiz.jsonl');
        await _writeJsonl(
          file,
          quizTemplates
              .asMap()
              .entries
              .map((entry) => _buildQuiz(entry.value, topic, entry.key))
              .toList(),
        );
        filesGenerated++;
      }

      synthesisResults.add(
        _SynthesisResult(
          topic: topic,
          outputPath: targetDir.path,
          drills: drillTemplates.length,
          quizzes: quizTemplates.length,
        ),
      );
    }

    if (filesGenerated == 0) {
      stderr.writeln(
        'Synthesizer did not generate any files. Ensure semantic summary contains DRILL/QUIZ templates.',
      );
      return false;
    }

    final summary = _buildSummary(
      results: synthesisResults,
      filesGenerated: filesGenerated,
      durationMs: stopwatch.elapsedMilliseconds,
    );

    await _withReportsWritable(() async {
      await File(_summaryOutPath).writeAsString(summary);
      await _appendTelemetry(
        filesGenerated: filesGenerated,
        durationMs: stopwatch.elapsedMilliseconds,
        results: synthesisResults,
      );
    });

    return true;
  }

  Future<void> _ensureSchemas() async {
    final dir = Directory(_schemasDir);
    if (!await dir.exists()) {
      throw StateError('Schema directory not found: $_schemasDir');
    }
    for (final schema in _requiredSchemas) {
      final file = File('${dir.path}/$schema');
      if (!await file.exists()) {
        throw StateError('Missing schema file: ${file.path}');
      }
      // basic validation: ensure file contains JSON
      try {
        json.decode(await file.readAsString());
      } catch (_) {
        throw StateError('Invalid JSON schema: ${file.path}');
      }
    }
  }

  Future<List<_SemanticTemplate>> _parseSemanticSummary() async {
    final file = File(_semanticSummaryPath);
    if (!await file.exists()) {
      throw StateError(
        'Semantic expansion summary missing at $_semanticSummaryPath',
      );
    }
    final templates = <_SemanticTemplate>[];
    String? currentTopic;
    List<String> currentKeywords = const [];
    _TemplateBuilder? builder;
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- Topic:')) {
        currentTopic = trimmed
            .substring('- Topic:'.length)
            .split('(')
            .first
            .trim();
        currentKeywords = const [];
      } else if (trimmed.startsWith('Keywords:')) {
        final raw = trimmed.substring('Keywords:'.length).trim();
        if (raw.isEmpty) {
          currentKeywords = const [];
        } else {
          currentKeywords = raw
              .split(',')
              .map((word) => word.trim())
              .where((word) => word.isNotEmpty)
              .toList(growable: false);
        }
      } else if (trimmed.startsWith('•')) {
        final match = RegExp(r'•\s*([A-Z]+):\s*(.+)').firstMatch(trimmed);
        if (match == null) continue;
        final kind = match.group(1)!;
        final title = match.group(2)!;
        builder = _TemplateBuilder(
          topic: currentTopic ?? 'unknown_topic',
          kind: kind,
          title: title,
          keywords: List<String>.from(currentKeywords),
        );
      } else if (trimmed.startsWith('desc=')) {
        if (builder != null) {
          builder.description = trimmed.substring(5);
        }
      } else if (trimmed.startsWith('difficulty=')) {
        if (builder == null) continue;
        final match = RegExp(
          r'difficulty=([0-9.]+)\s+targetAcc=([0-9.]+)\s+strategy=([\w_]+)',
        ).firstMatch(trimmed);
        if (match == null) continue;
        final difficulty = double.tryParse(match.group(1)!) ?? 0.5;
        final target = double.tryParse(match.group(2)!) ?? 0.8;
        final strategy = match.group(3)!;
        templates.add(
          builder.toTemplate(
            difficulty: difficulty,
            targetAccuracy: target,
            strategy: strategy,
          ),
        );
        builder = null;
      }
    }
    return templates;
  }

  Map<String, Object?> _buildDrill(
    _SemanticTemplate template,
    String topic,
    int index,
  ) {
    final theme = _themeFor(template.strategy);
    return {
      'id': '${topic}_drill_${index + 1}',
      'title': template.title,
      'description': template.description,
      'difficulty': template.difficulty,
      'recommended_for': _recommendationsFor(template.strategy),
      'visual_theme_v3_token': theme,
      'target_accuracy': template.targetAccuracy,
      'keywords': template.keywords,
      'strategy': template.strategy,
      'source': 'semantic_expansion',
    };
  }

  Map<String, Object?> _buildQuiz(
    _SemanticTemplate template,
    String topic,
    int index,
  ) {
    final theme = _themeFor(template.strategy);
    return {
      'id': '${topic}_quiz_${index + 1}',
      'title': template.title,
      'difficulty': template.difficulty,
      'recommended_for': _recommendationsFor(template.strategy),
      'visual_theme_v3_token': theme,
      'target_accuracy': template.targetAccuracy,
      'question_count': 5 + index % 3,
      'keywords': template.keywords,
      'strategy': template.strategy,
      'source': 'semantic_expansion',
    };
  }

  List<String> _recommendationsFor(String strategy) {
    switch (strategy) {
      case 'onboarding':
        return ['newcomer', 'burst_learning'];
      case 'precision_check':
        return ['steady_grinder', 'immersive_pro'];
      case 'advanced':
        return ['immersive_pro'];
      default:
        return [strategy];
    }
  }

  String _themeFor(String strategy) {
    switch (strategy) {
      case 'onboarding':
        return 'nova_light';
      case 'precision_check':
        return 'nova_contrast';
      case 'advanced':
        return 'nova_dark';
      default:
        return 'nova_dynamic';
    }
  }

  String _buildSummary({
    required List<_SynthesisResult> results,
    required int filesGenerated,
    required int durationMs,
  }) {
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE QUIZ/DRILL SYNTHESIS SUMMARY')
      ..writeln('=====================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Files generated: $filesGenerated')
      ..writeln();
    for (final result in results) {
      buffer
        ..writeln('- Topic: ${result.topic}')
        ..writeln('  Output: ${result.outputPath}')
        ..writeln('  Drills: ${result.drills} | Quizzes: ${result.quizzes}')
        ..writeln();
    }
    return buffer.toString();
  }

  Future<void> _appendTelemetry({
    required int filesGenerated,
    required int durationMs,
    required List<_SynthesisResult> results,
  }) async {
    final payload = {
      'event': 'adaptive_quiz_drill_synthesis_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'files_generated': filesGenerated,
      'topics': results
          .map(
            (result) => {
              'topic': result.topic,
              'drills': result.drills,
              'quizzes': result.quizzes,
            },
          )
          .toList(),
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _SynthesisResult {
  _SynthesisResult({
    required this.topic,
    required this.outputPath,
    required this.drills,
    required this.quizzes,
  });

  final String topic;
  final String outputPath;
  final int drills;
  final int quizzes;
}

class _SemanticTemplate {
  _SemanticTemplate({
    required this.topic,
    required this.kind,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.targetAccuracy,
    required this.strategy,
    required this.keywords,
  });

  final String topic;
  final String kind;
  final String title;
  final String description;
  final double difficulty;
  final double targetAccuracy;
  final String strategy;
  final List<String> keywords;
}

class _TemplateBuilder {
  _TemplateBuilder({
    required this.topic,
    required this.kind,
    required this.title,
    required this.keywords,
  });

  final String topic;
  final String kind;
  final String title;
  final List<String> keywords;
  String? description;

  _SemanticTemplate toTemplate({
    required double difficulty,
    required double targetAccuracy,
    required String strategy,
  }) {
    final desc = description ?? title;
    return _SemanticTemplate(
      topic: topic,
      kind: kind,
      title: title,
      description: desc,
      difficulty: difficulty,
      targetAccuracy: targetAccuracy,
      strategy: strategy,
      keywords: keywords,
    );
  }
}

Future<void> _writeJsonl(File file, List<Map<String, Object?>> rows) async {
  final sink = file.openWrite();
  for (final row in rows) {
    sink.writeln(jsonEncode(row));
  }
  await sink.close();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
