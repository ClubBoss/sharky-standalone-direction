import 'dart:convert';
import 'dart:io';

/// Content Narrative Binder
///
/// Adds short transition phrases between modules and contextual energy
/// cues for recap, quiz, and lab entries. Runs in dry-run mode unless
/// `--apply` is provided.

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');

  final contentDir = Directory('content');
  if (!contentDir.existsSync()) {
    _printSummary(
      dryRun: dryRun,
      addedTransitions: 0,
      linkedModules: 0,
      contextualized: 0,
    );
    return;
  }

  final files = await _collectJsonl(contentDir);
  if (files.isEmpty) {
    _printSummary(
      dryRun: dryRun,
      addedTransitions: 0,
      linkedModules: 0,
      contextualized: 0,
    );
    return;
  }

  final seenModules = <String>{};
  String? previousModule;
  int transitionsAdded = 0;
  int contextualized = 0;

  for (final file in files) {
    final original = await file.readAsString();
    if (original.isEmpty) continue;

    final hasTrailingNewline = original.codeUnitAt(original.length - 1) == 0x0A;
    final rawLines = original.split('\n');
    final updatedLines = <String>[];
    bool fileModified = false;

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

      final idValue = data['id'];
      final moduleKey = idValue is String ? _extractModuleKey(idValue) : null;

      if (moduleKey != null && !seenModules.contains(moduleKey)) {
        final phrase = _buildTransitionPhrase(previousModule, moduleKey);
        previousModule = moduleKey;
        seenModules.add(moduleKey);
        if (_needsTransition(data) && phrase != null) {
          data['narrative_transition'] = phrase;
          transitionsAdded++;
          fileModified = true;
        }
      }

      if (_applyEnergyCue(data)) {
        contextualized++;
        fileModified = true;
      }

      updatedLines.add(jsonEncode(data));
    }

    if (apply && fileModified) {
      final buffer = StringBuffer();
      for (var i = 0; i < updatedLines.length; i++) {
        buffer.write(updatedLines[i]);
        if (i < updatedLines.length - 1 || hasTrailingNewline) {
          buffer.write('\n');
        }
      }
      await file.writeAsString(buffer.toString());
    }
  }

  _printSummary(
    dryRun: dryRun,
    addedTransitions: transitionsAdded,
    linkedModules: seenModules.length,
    contextualized: contextualized,
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

bool _needsTransition(Map<String, dynamic> data) {
  final existing = data['narrative_transition'];
  if (existing is String && existing.trim().isNotEmpty) {
    return false;
  }
  return true;
}

String? _extractModuleKey(String idValue) {
  final lower = idValue.toLowerCase();
  for (final marker in const [
    '_drill_',
    '_demo_',
    '_recap_',
    '_quiz_',
    '_lab_',
  ]) {
    final index = lower.indexOf(marker);
    if (index > 0) {
      return lower.substring(0, index);
    }
  }
  return lower;
}

String? _buildTransitionPhrase(String? previousModule, String moduleKey) {
  final current = _focusName(moduleKey);
  if (current.isEmpty) return null;

  if (previousModule == null) {
    return ':zap: Fresh energy opens $current';
  }

  final prior = _focusName(previousModule);
  if (prior.isEmpty) {
    return ':zap: Carry energy into $current';
  }

  return ':zap: Carry energy from $prior';
}

String _focusName(String moduleKey) {
  final tokens = moduleKey
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.trim().isNotEmpty)
      .map((token) => token.trim())
      .toList();
  if (tokens.isEmpty) return '';

  final focusTokens = tokens.take(2).map(_titleCase).toList();
  return focusTokens.join(' ');
}

String _titleCase(String token) {
  if (token.isEmpty) return '';
  if (token.length == 1) return token.toUpperCase();
  return '${token[0].toUpperCase()}${token.substring(1)}';
}

bool _applyEnergyCue(Map<String, dynamic> data) {
  final idValue = data['id'];
  if (idValue is! String) return false;
  final lower = idValue.toLowerCase();

  String? targetKey;
  String? cue;

  if (lower.contains('recap')) {
    targetKey = 'reaction_text';
    cue = 'Recap energy: lock the gains.';
  } else if (lower.contains('quiz')) {
    targetKey = 'lesson_goal';
    cue = 'Quiz energy: apply the pattern.';
  } else if (lower.contains('lab')) {
    targetKey = 'reaction_text';
    cue = 'Lab energy: explore the edge.';
  } else {
    return false;
  }

  final existing = data[targetKey];
  if (existing is String && existing.trim().isNotEmpty) {
    return false;
  }

  data[targetKey] = cue;
  return true;
}

void _printSummary({
  required bool dryRun,
  required int addedTransitions,
  required int linkedModules,
  required int contextualized,
}) {
  final mode = dryRun ? 'DRY-RUN' : 'APPLY';
  stdout.writeln('Content Narrative Binder Tool');
  stdout.writeln('Mode: $mode');
  stdout.writeln('Transitions added: $addedTransitions');
  stdout.writeln('Modules linked: $linkedModules');
  stdout.writeln('Energy cues updated: $contextualized');
  stdout.writeln(
    jsonEncode({
      'added_transitions': addedTransitions,
      'linked_modules': linkedModules,
      'contextualized': contextualized,
      'dry_run': dryRun,
      'pass': true,
    }),
  );
}
