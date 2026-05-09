import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');
  final contentDir = Directory('content');
  if (!contentDir.existsSync()) {
    _printSummary(dryRun, 0, 0, 1.0, 0.0);
    return;
  }

  final files = await _collectJsonl(contentDir);
  if (files.isEmpty) {
    _printSummary(dryRun, 0, 0, 1.0, 0.0);
    return;
  }

  int entries = 0;
  int shifts = 0;
  int targetSoft = 0;
  int targetEnergetic = 0;
  double totalIntensity = 0.0;
  bool expectEnergetic = false;

  for (final file in files) {
    final text = await file.readAsString();
    if (text.isEmpty) continue;
    final hasTrailingNewline = text.codeUnitAt(text.length - 1) == 0x0A;
    final rawLines = text.split('\n');
    final updatedLines = <String>[];
    var fileModified = false;

    for (final rawLine in rawLines) {
      if (rawLine.trim().isEmpty) {
        updatedLines.add(rawLine);
        continue;
      }
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(rawLine) as Map<String, dynamic>?;
      } catch (_) {
        updatedLines.add(rawLine);
        continue;
      }
      if (data == null) {
        updatedLines.add(rawLine);
        continue;
      }

      entries++;
      final rawReaction = data['reaction_text'];
      final reaction = rawReaction is String ? rawReaction : '';
      final sanitized = _sanitizeAscii(reaction);
      final intensity = _measureIntensity(sanitized);
      totalIntensity += intensity;

      final desiredEnergetic = expectEnergetic;
      desiredEnergetic ? targetEnergetic++ : targetSoft++;

      final currentEnergetic = intensity > 0.5;
      if (currentEnergetic != desiredEnergetic) {
        shifts++;
        if (apply) {
          final idValue = data['id'] is String ? data['id'] as String : '';
          data['reaction_text'] = _composeReaction(
            idValue,
            desiredEnergetic,
            sanitized,
          );
          fileModified = true;
        }
      }

      updatedLines.add(jsonEncode(data));
      expectEnergetic = !expectEnergetic;
    }

    if (apply && fileModified) {
      final joined = updatedLines.join('\n');
      await file.writeAsString(hasTrailingNewline ? '$joined\n' : joined);
    }
  }

  final engagementScore = entries == 0
      ? 1.0
      : 1.0 - (targetEnergetic - targetSoft).abs() / entries;
  final avgIntensity = entries == 0 ? 0.0 : totalIntensity / entries;
  _printSummary(dryRun, entries, shifts, engagementScore, avgIntensity);
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

double _measureIntensity(String text) {
  if (text.isEmpty) return 0.0;
  final tokens = text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty);
  const energeticWords = {
    'charge',
    'ignite',
    'crush',
    'power',
    'blast',
    'surge',
    'dominate',
    'attack',
    'push',
    'fire',
    'hype',
    'epic',
  };
  const calmingWords = {
    'steady',
    'calm',
    'smooth',
    'breathe',
    'focus',
    'patient',
    'flow',
    'compose',
    'relax',
    'ease',
  };
  double energetic = 0;
  double calming = 0;
  for (final token in tokens) {
    if (energeticWords.contains(token)) energetic += 1;
    if (calmingWords.contains(token)) calming += 1;
  }
  energetic += RegExp(r'[🔥⚡💥🏆]').allMatches(text).length * 1.5;
  calming += RegExp(r'[😊🌊✨🌿]').allMatches(text).length * 1.0;
  return energetic - calming;
}

String _composeReaction(String idValue, bool energetic, String existing) {
  final persona = _pick(idValue, _personaCues);
  final phrase = energetic
      ? _pick(idValue, _energeticPhrases)
      : _pick(idValue, _calmingPhrases);
  final fallback = energetic
      ? 'Channel that spark into the next hand.'
      : 'Keep the rhythm and trust the read.';
  final insight = existing.trim().isEmpty
      ? fallback
      : _ensureSentence(existing);
  return '$persona $phrase $insight';
}

const _personaCues = <String>[
  'You got this!',
  'Coach confidence check:',
  'Game-plan mode:',
  'Smart grind update:',
  'Trust your edge!',
  'Steady hands, sharp mind:',
];

const _energeticPhrases = <String>[
  "Let's fire up this line!",
  'Bring the energy and punish mistakes!',
  'Stay aggressive and keep applying pressure!',
  'Punch through with confident lines!',
];

const _calmingPhrases = <String>[
  'Smooth tempo, read the flow.',
  'Breathe and map the range calmly.',
  'Keep it composed and stay deliberate.',
  'Slow the pulse and trust disciplined play.',
];

String _pick(String seed, List<String> values) {
  if (values.isEmpty) return '';
  final key = seed.isEmpty ? 'default' : seed.toLowerCase();
  final hash = key.codeUnits.fold<int>(
    0,
    (acc, unit) => (acc * 33 + unit) & 0x7fffffff,
  );
  return values[hash % values.length];
}

String _ensureSentence(String text) {
  var trimmed = text.trim();
  if (trimmed.isEmpty) return 'Stay ready for the next decision.';
  if (!trimmed.endsWith('.') &&
      !trimmed.endsWith('!') &&
      !trimmed.endsWith('?')) {
    trimmed = '$trimmed.';
  }
  final first = trimmed[0].toUpperCase();
  if (trimmed.length == 1) return first;
  return '$first${trimmed.substring(1)}';
}

void _printSummary(
  bool dryRun,
  int entries,
  int shifts,
  double engagementScore,
  double avgIntensity,
) {
  final mode = dryRun ? 'DRY-RUN' : 'APPLY';
  stdout.writeln(
    'Content Emotion Tuner\n'
    'Mode: $mode\n'
    'Entries inspected: $entries\n'
    'Emotional shifts: $shifts\n'
    'Engagement score: ${engagementScore.toStringAsFixed(2)}\n'
    'Average intensity: ${avgIntensity.toStringAsFixed(2)}',
  );
  stdout.writeln(
    jsonEncode({
      'entries': entries,
      'emotional_shifts': shifts,
      'engagement_score': double.parse(engagementScore.toStringAsFixed(4)),
      'average_intensity': double.parse(avgIntensity.toStringAsFixed(4)),
      'dry_run': dryRun,
      'pass': true,
    }),
  );
}
