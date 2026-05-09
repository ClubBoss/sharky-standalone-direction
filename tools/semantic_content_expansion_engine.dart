import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _adaptiveSummaryPath =
    '$_reportsDir/adaptive_content_evolution_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryOutPath = '$_reportsDir/semantic_expansion_summary.txt';

const double _lowWeightThreshold = 0.22;
const double _accuracyThreshold = 0.75;

Future<void> main(List<String> args) async {
  final engine = SemanticContentExpansionEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SemanticContentExpansionEngine {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final adaptiveSummary = await _parseAdaptiveSummary();
    if (adaptiveSummary.topics.isEmpty) {
      stderr.writeln(
        'Adaptive content evolution summary missing topic entries.',
      );
      return false;
    }

    final contentTopics = await _scanContentTopics();
    if (contentTopics.isEmpty) {
      stderr.writeln('No content modules detected under content/**/v1/.');
      return false;
    }

    final expansions = <_ExpansionTemplate>[];
    for (final topic in contentTopics) {
      final adaptive = adaptiveSummary.topics[topic.name];
      final weight = adaptive?.weight ?? 0.25;
      final needsReinforcement =
          (adaptive?.reinforcement ?? false) || weight <= _lowWeightThreshold;
      final accuracy = topic.accuracy;
      final lowAccuracy = accuracy < _accuracyThreshold;
      if (needsReinforcement || lowAccuracy) {
        final templates = _generateTemplates(topic, weight, accuracy);
        if (templates.isNotEmpty) {
          expansions.addAll(templates);
        }
      }
    }

    if (expansions.isEmpty) {
      stderr.writeln(
        'Semantic engine did not create any templates (no weak topics detected).',
      );
      return false;
    }

    final summary = _buildSummary(
      expansions: expansions,
      durationMs: stopwatch.elapsedMilliseconds,
    );

    await _withReportsWritable(() async {
      await File(_summaryOutPath).writeAsString(summary);
      await _appendTelemetry(
        expansions: expansions,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    return true;
  }

  Future<_AdaptiveSummary> _parseAdaptiveSummary() async {
    final file = File(_adaptiveSummaryPath);
    if (!await file.exists()) {
      throw StateError(
        'Adaptive content evolution summary missing at $_adaptiveSummaryPath',
      );
    }
    final topics = <String, _AdaptiveTopic>{};
    String? currentTopic;
    var currentWeight = 0.0;
    var reinforcement = false;
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- Topic:')) {
        if (currentTopic != null) {
          topics[currentTopic] = _AdaptiveTopic(
            weight: currentWeight,
            reinforcement: reinforcement,
          );
        }
        currentTopic = trimmed.substring('- Topic:'.length).trim();
        currentWeight = 0;
        reinforcement = false;
      } else if (trimmed.contains('weight=')) {
        final match = RegExp(r'weight=([0-9.]+)').firstMatch(trimmed);
        if (match != null) {
          currentWeight = double.tryParse(match.group(1)!) ?? 0;
        }
      } else if (trimmed.contains('Reinforcement required')) {
        reinforcement = true;
      }
    }
    if (currentTopic != null) {
      topics[currentTopic] = _AdaptiveTopic(
        weight: currentWeight,
        reinforcement: reinforcement,
      );
    }
    return _AdaptiveSummary(topics: topics);
  }

  Future<List<_ContentTopic>> _scanContentTopics() async {
    final contentDir = Directory('content');
    if (!await contentDir.exists()) return const [];
    final topics = <_ContentTopic>[];
    await for (final entity in contentDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! Directory) continue;
      final segments = entity.path.split(Platform.pathSeparator);
      if (segments.isEmpty || segments.last != 'v1') continue;
      final topicName = segments[segments.length - 2];
      final drillsFile = File('${entity.path}/drills.jsonl');
      final quizFile = File('${entity.path}/quiz.jsonl');
      final accuracy = await _meanAccuracy(drillsFile, quizFile);
      topics.add(
        _ContentTopic(
          name: topicName,
          path: entity.path,
          accuracy: accuracy,
          keywords: _extractKeywords(topicName),
        ),
      );
    }
    return topics;
  }

  Future<double> _meanAccuracy(File drillsFile, File quizFile) async {
    final accuracies = <double>[];
    Future<void> parseFile(File file) async {
      if (!await file.exists()) return;
      for (final line in await file.readAsLines()) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map<String, Object?>) {
            final accuracy =
                (decoded['accuracy'] as num?)?.toDouble() ?? double.nan;
            if (accuracy.isFinite) {
              accuracies.add(accuracy.clamp(0, 1));
            }
          }
        } catch (_) {
          // ignore malformed
        }
      }
    }

    await parseFile(drillsFile);
    await parseFile(quizFile);
    if (accuracies.isEmpty) {
      return 0.6; // assume under-performing if no data
    }
    return accuracies.reduce((a, b) => a + b) / accuracies.length;
  }

  List<String> _extractKeywords(String topicName) {
    final cleaned = topicName
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim().toLowerCase())
        .toList();
    return cleaned.take(5).toList();
  }

  List<_ExpansionTemplate> _generateTemplates(
    _ContentTopic topic,
    double weight,
    double accuracy,
  ) {
    final keywords = topic.keywords;
    if (keywords.isEmpty) return const [];
    final engagementFocus = weight < _lowWeightThreshold
        ? 'onboarding'
        : 'advanced';
    final accuracyLabel = accuracy < _accuracyThreshold
        ? 'accuracy_gap'
        : 'refresh';
    final templates = <_ExpansionTemplate>[];
    final seed = keywords.first;
    final keywordSnippet = keywords.take(4).toList();
    templates.add(
      _ExpansionTemplate(
        topicName: topic.name,
        kind: 'drill',
        title: 'Adaptive Drill: ${_capitalize(seed)} Scenarios',
        description:
            'Focus on ${keywords.take(3).join(', ')} with targeted EV checkpoints.',
        difficulty: max(0.3, weight),
        accuracyTarget: 0.82,
        strategy: engagementFocus,
        keywords: keywordSnippet,
      ),
    );
    templates.add(
      _ExpansionTemplate(
        topicName: topic.name,
        kind: 'quiz',
        title: 'Semantic Quiz: ${_capitalize(keywords[0])} Branch',
        description:
            'Branching questions covering ${keywords.join(', ')} to close $accuracyLabel.',
        difficulty: min(0.9, weight + 0.2),
        accuracyTarget: 0.85,
        strategy: 'precision_check',
        keywords: keywordSnippet,
      ),
    );
    templates.add(
      _ExpansionTemplate(
        topicName: topic.name,
        kind: 'recap',
        title: 'Recap: ${keywords.map(_capitalize).join(' vs ')}',
        description:
            'Narrative recap reinforcing cluster personas with contextual hints.',
        difficulty: 0.4,
        accuracyTarget: 0.8,
        strategy: 'memory_anchor',
        keywords: keywordSnippet,
      ),
    );
    return templates;
  }

  String _buildSummary({
    required List<_ExpansionTemplate> expansions,
    required int durationMs,
  }) {
    final buffer = StringBuffer()
      ..writeln('SEMANTIC CONTENT EXPANSION SUMMARY')
      ..writeln('=================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Templates generated: ${expansions.length}')
      ..writeln();
    final grouped = <String, List<_ExpansionTemplate>>{};
    for (final expansion in expansions) {
      grouped.putIfAbsent(expansion.topicName, () => []).add(expansion);
    }
    grouped.forEach((topic, templates) {
      buffer
        ..writeln('- Topic: $topic (${templates.length} templates)')
        ..writeln(
          '  Keywords: ${templates.first.keywords?.join(', ') ?? 'n/a'}',
        );
      for (final template in templates) {
        buffer
          ..writeln('  • ${template.kind.toUpperCase()}: ${template.title}')
          ..writeln('    desc=${template.description}')
          ..writeln(
            '    difficulty=${template.difficulty.toStringAsFixed(2)} targetAcc=${template.accuracyTarget.toStringAsFixed(2)} strategy=${template.strategy}',
          );
      }
      buffer.writeln();
    });
    return buffer.toString();
  }

  Future<void> _appendTelemetry({
    required List<_ExpansionTemplate> expansions,
    required int durationMs,
  }) async {
    final payload = {
      'event': 'semantic_expansion_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'template_count': expansions.length,
      'topics': expansions
          .map(
            (expansion) => {
              'topic': expansion.topicName,
              'kind': expansion.kind,
              'title': expansion.title,
              'difficulty': expansion.difficulty,
              'target_accuracy': expansion.accuracyTarget,
              'keywords': expansion.keywords,
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

class _AdaptiveSummary {
  _AdaptiveSummary({required this.topics});

  final Map<String, _AdaptiveTopic> topics;
}

class _AdaptiveTopic {
  _AdaptiveTopic({required this.weight, required this.reinforcement});

  final double weight;
  final bool reinforcement;
}

class _ContentTopic {
  _ContentTopic({
    required this.name,
    required this.path,
    required this.accuracy,
    required this.keywords,
  });

  final String name;
  final String path;
  final double accuracy;
  final List<String> keywords;
}

class _ExpansionTemplate {
  _ExpansionTemplate({
    required this.topicName,
    required this.kind,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.accuracyTarget,
    required this.strategy,
    this.keywords,
  });

  final String topicName;
  final String kind;
  final String title;
  final String description;
  final double difficulty;
  final double accuracyTarget;
  final String strategy;
  final List<String>? keywords;
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
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
