import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');

  final contentDir = Directory('content');
  if (!contentDir.existsSync()) {
    _printSummary(
      dryRun: dryRun,
      entries: 0,
      sentimentAvg: 0.0,
      emojiDensity: 0.0,
      consistency: 0.0,
    );
    return;
  }

  final files = await _collectJsonl(contentDir);
  if (files.isEmpty) {
    _printSummary(
      dryRun: dryRun,
      entries: 0,
      sentimentAvg: 0.0,
      emojiDensity: 0.0,
      consistency: 0.0,
    );
    return;
  }

  int totalEntries = 0;
  double totalSentiment = 0.0;
  double totalEmojis = 0.0;
  double totalCharacters = 0.0;
  final intensities = <double>[];

  for (final file in files) {
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(line) as Map<String, dynamic>?;
      } catch (_) {
        continue;
      }
      if (data == null) continue;

      final reaction = _asText(data['reaction_text']);
      final feedback = _asText(data['user_feedback']);
      if (reaction.isEmpty && feedback.isEmpty) continue;

      final merged = reaction.isEmpty ? feedback : '$reaction $feedback';
      final sanitized = _sanitizeAscii(merged);
      if (sanitized.trim().isEmpty) continue;

      totalEntries++;
      final sentiment = _computeSentiment(sanitized);
      totalSentiment += sentiment;

      final emojiCount = _countEmojis(sanitized);
      totalEmojis += emojiCount.toDouble();
      totalCharacters += sanitized.length.toDouble();

      intensities.add(sentiment.abs());
    }
  }

  final sentimentAvg = totalEntries == 0 ? 0.0 : totalSentiment / totalEntries;
  final emojiDensity = totalCharacters == 0.0
      ? 0.0
      : totalEmojis / max<double>(totalCharacters, 1.0);
  final consistency = intensities.isEmpty
      ? 0.0
      : _computeConsistency(intensities);

  _printSummary(
    dryRun: dryRun,
    entries: totalEntries,
    sentimentAvg: sentimentAvg,
    emojiDensity: emojiDensity,
    consistency: consistency,
  );
}

Future<List<File>> _collectJsonl(Directory root) async {
  final files = <File>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.jsonl')) {
      files.add(entity);
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

String _asText(Object? value) {
  if (value is String) return value;
  return '';
}

String _sanitizeAscii(String input) {
  final buffer = StringBuffer();
  for (final code in input.codeUnits) {
    if (code >= 32 && code <= 126) {
      buffer.writeCharCode(code);
    } else if (code == 9 || code == 10 || code == 13) {
      buffer.write(' ');
    }
  }
  return buffer.toString();
}

double _computeSentiment(String text) {
  final tokens = text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty);

  const positive = {
    'great',
    'good',
    'nice',
    'strong',
    'smart',
    'confident',
    'solid',
    'clean',
    'sharp',
    'well',
    'win',
    'value',
    'brilliant',
    'crisp',
  };

  const negative = {
    'bad',
    'weak',
    'confused',
    'tilt',
    'mistake',
    'loss',
    'poor',
    'risk',
    'leak',
    'wrong',
    'panic',
    'mess',
  };

  double score = 0.0;
  for (final token in tokens) {
    if (positive.contains(token)) score += 1.0;
    if (negative.contains(token)) score -= 1.0;
  }

  if (score == 0.0) return 0.0;
  return score.clamp(-5.0, 5.0) / 5.0;
}

int _countEmojis(String text) {
  final regex = RegExp(r'[\u2600-\u27BF\u1F300-\u1F6FF\u1F900-\u1F9FF]');
  return regex.allMatches(text).length;
}

double _computeConsistency(List<double> intensities) {
  if (intensities.length <= 1) return 1.0;
  final avg = intensities.reduce((a, b) => a + b) / intensities.length;
  double variance = 0.0;
  for (final value in intensities) {
    final diff = value - avg;
    variance += diff * diff;
  }
  variance /= intensities.length;
  final stdDev = sqrt(variance);
  final normalized = stdDev.clamp(0.0, 1.0);
  return double.parse((1.0 - normalized).toStringAsFixed(4));
}

void _printSummary({
  required bool dryRun,
  required int entries,
  required double sentimentAvg,
  required double emojiDensity,
  required double consistency,
}) {
  final mode = dryRun ? 'DRY-RUN' : 'APPLY';
  stdout.writeln(
    'Content Emotion Telemetry\n'
    'Mode: $mode\n'
    'Entries analyzed: $entries\n'
    'Avg sentiment: ${sentimentAvg.toStringAsFixed(3)}\n'
    'Emoji density: ${emojiDensity.toStringAsFixed(4)}\n'
    'Consistency score: ${consistency.toStringAsFixed(3)}',
  );
  stdout.writeln(
    jsonEncode({
      'entries': entries,
      'sentiment_avg': double.parse(sentimentAvg.toStringAsFixed(4)),
      'emoji_density': double.parse(emojiDensity.toStringAsFixed(6)),
      'consistency_score': consistency,
      'dry_run': dryRun,
      'pass': true,
    }),
  );
}
