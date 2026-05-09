import 'dart:io';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main(List<String> args) {
  final root = Directory('content');
  if (!root.existsSync()) {
    stderr.writeln('validate_theory_runner_content_v1: content/ not found');
    exitCode = 1;
    return;
  }

  final theoryFiles =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('/v1/theory.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final allTheoryModuleIds = <String>{};
  for (final file in theoryFiles) {
    final moduleId = _moduleIdFromTheoryPath(file.path);
    if (moduleId == null) continue;
    allTheoryModuleIds.add(moduleId);
  }

  final errors = <String>[];
  final modules = <String, _DirectiveModuleV1>{};

  for (final file in theoryFiles) {
    final moduleIdFromPath = _moduleIdFromTheoryPath(file.path);
    if (moduleIdFromPath == null) {
      continue;
    }
    final content = file.readAsStringSync();
    final parsed = _parseDirectiveHeaderV1(content, file.path, errors);
    if (parsed == null) continue;
    if (!parsed.hasAnyDirective) continue;

    final meta = parsed.meta;
    final runner = parsed.runner;
    final deps = parsed.deps;
    for (final key in const <String>[
      'v',
      'module_id',
      'world',
      'kind',
      'title',
    ]) {
      if (!meta.containsKey(key)) {
        errors.add('${file.path}: missing @meta $key');
      }
    }
    final version = int.tryParse(meta['v'] ?? '');
    if (version != 1) {
      errors.add('${file.path}: @meta v must be 1');
    }
    final moduleId = meta['module_id'] ?? '';
    if (moduleId.isEmpty) {
      errors.add('${file.path}: @meta module_id must be non-empty');
    } else if (moduleId != moduleIdFromPath) {
      errors.add(
        '${file.path}: @meta module_id=$moduleId does not match path module id $moduleIdFromPath',
      );
    }
    final world = int.tryParse(meta['world'] ?? '');
    if (world == null || world <= 0) {
      errors.add('${file.path}: @meta world must be a positive integer');
    }
    final kind = meta['kind'] ?? '';
    if (!_kAllowedKindsV1.contains(kind)) {
      errors.add(
        '${file.path}: @meta kind must be one of ${_kAllowedKindsV1.join(', ')}',
      );
    }
    if (kind == 'theory_runner') {
      final packId = runner['pack_id'];
      if (packId == null || packId.trim().isEmpty) {
        errors.add('${file.path}: theory_runner requires @runner pack_id');
      } else if (!kCampaignPacksV1.containsKey(packId.trim())) {
        errors.add(
          '${file.path}: @runner pack_id $packId not found in campaign registry',
        );
      }
    }
    for (final dep in deps) {
      if (!allTheoryModuleIds.contains(dep)) {
        errors.add(
          '${file.path}: @deps id=$dep does not exist as a content theory module',
        );
      }
    }
    if (moduleId.isNotEmpty) {
      if (modules.containsKey(moduleId)) {
        errors.add('${file.path}: duplicate directive module_id $moduleId');
      } else {
        modules[moduleId] = _DirectiveModuleV1(
          moduleId: moduleId,
          path: file.path,
          deps: deps,
        );
      }
    }
  }

  _validateAcyclicV1(modules, errors);

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln('validate_theory_runner_content_v1: $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'validate_theory_runner_content_v1: OK (${modules.length} directive module(s), ${theoryFiles.length} theory file(s) scanned)',
  );
}

const Set<String> _kAllowedKindsV1 = <String>{'theory_runner', 'theory_only'};
const Set<String> _kAllowedMetaKeysV1 = <String>{
  'v',
  'module_id',
  'world',
  'kind',
  'title',
};
const Set<String> _kAllowedRunnerKeysV1 = <String>{
  'pack_id',
  'intro',
  'step',
  'outcome',
};
const Set<String> _kAllowedDepsKeysV1 = <String>{'id'};

String? _moduleIdFromTheoryPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final match = RegExp(
    r'^content/([^/]+)/v1/theory\.md$',
  ).firstMatch(normalized);
  return match?.group(1);
}

class _DirectiveModuleV1 {
  const _DirectiveModuleV1({
    required this.moduleId,
    required this.path,
    required this.deps,
  });

  final String moduleId;
  final String path;
  final List<String> deps;
}

class _DirectiveParseResultV1 {
  const _DirectiveParseResultV1({
    required this.meta,
    required this.runner,
    required this.deps,
    required this.hasAnyDirective,
  });

  final Map<String, String> meta;
  final Map<String, String> runner;
  final List<String> deps;
  final bool hasAnyDirective;
}

_DirectiveParseResultV1? _parseDirectiveHeaderV1(
  String markdown,
  String path,
  List<String> errors,
) {
  final meta = <String, String>{};
  final runner = <String, String>{};
  final deps = <String>[];
  final seenDeps = <String>{};
  var hasAnyDirective = false;
  final lines = markdown.split('\n');

  for (var index = 0; index < lines.length; index++) {
    final raw = lines[index];
    final line = raw.trim();
    if (line.isEmpty) {
      if (hasAnyDirective) continue;
      continue;
    }
    if (!line.startsWith('@')) break;
    hasAnyDirective = true;
    final space = line.indexOf(' ');
    final directive =
        (space == -1 ? line.substring(1) : line.substring(1, space))
            .trim()
            .toLowerCase();
    final payload = space == -1 ? '' : line.substring(space + 1).trim();
    final tokens = _parseDirectiveKvTokensV1(payload);
    if (tokens == null) {
      errors.add('$path:${index + 1} invalid directive payload syntax');
      continue;
    }
    switch (directive) {
      case 'meta':
        for (final entry in tokens.entries) {
          if (!_kAllowedMetaKeysV1.contains(entry.key)) {
            errors.add('$path:${index + 1} unknown @meta key ${entry.key}');
            continue;
          }
          if (meta.containsKey(entry.key)) {
            errors.add('$path:${index + 1} duplicate @meta key ${entry.key}');
            continue;
          }
          meta[entry.key] = entry.value;
        }
      case 'runner':
        for (final entry in tokens.entries) {
          if (!_kAllowedRunnerKeysV1.contains(entry.key)) {
            errors.add('$path:${index + 1} unknown @runner key ${entry.key}');
            continue;
          }
          if (runner.containsKey(entry.key)) {
            errors.add('$path:${index + 1} duplicate @runner key ${entry.key}');
            continue;
          }
          runner[entry.key] = entry.value;
        }
      case 'deps':
        if (tokens.isEmpty) {
          errors.add('$path:${index + 1} @deps requires id=<module_id>');
        }
        for (final entry in tokens.entries) {
          if (!_kAllowedDepsKeysV1.contains(entry.key)) {
            errors.add('$path:${index + 1} unknown @deps key ${entry.key}');
            continue;
          }
          final dep = entry.value.trim();
          if (dep.isEmpty) {
            errors.add('$path:${index + 1} @deps id must be non-empty');
            continue;
          }
          if (!seenDeps.add(dep)) {
            errors.add('$path:${index + 1} duplicate @deps id $dep');
            continue;
          }
          deps.add(dep);
        }
      default:
        errors.add('$path:${index + 1} unknown directive @$directive');
    }
  }

  return _DirectiveParseResultV1(
    meta: meta,
    runner: runner,
    deps: deps,
    hasAnyDirective: hasAnyDirective,
  );
}

Map<String, String>? _parseDirectiveKvTokensV1(String input) {
  final result = <String, String>{};
  var i = 0;
  while (i < input.length) {
    while (i < input.length && input.codeUnitAt(i) == 32) {
      i++;
    }
    if (i >= input.length) break;
    final keyStart = i;
    while (i < input.length && input.codeUnitAt(i) != 61) {
      if (input.codeUnitAt(i) == 32) return null;
      i++;
    }
    if (i >= input.length) return null;
    final key = input.substring(keyStart, i).trim();
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(key)) return null;
    i++;
    if (i >= input.length) return null;

    String value;
    if (input.codeUnitAt(i) == 34) {
      i++;
      final buffer = StringBuffer();
      var closed = false;
      while (i < input.length) {
        final ch = input.codeUnitAt(i);
        if (ch == 92) {
          if (i + 1 >= input.length) return null;
          final next = input.codeUnitAt(i + 1);
          if (next == 34 || next == 92) {
            buffer.writeCharCode(next);
            i += 2;
            continue;
          }
          return null;
        }
        if (ch == 34) {
          i++;
          closed = true;
          break;
        }
        buffer.writeCharCode(ch);
        i++;
      }
      if (!closed) return null;
      value = buffer.toString();
    } else {
      final valueStart = i;
      while (i < input.length && input.codeUnitAt(i) != 32) {
        i++;
      }
      value = input.substring(valueStart, i).trim();
    }

    result[key] = value;
  }
  return result;
}

void _validateAcyclicV1(
  Map<String, _DirectiveModuleV1> modules,
  List<String> errors,
) {
  final state = <String, int>{}; // 0=visiting,1=done
  final stack = <String>[];

  bool dfs(String id) {
    final current = state[id];
    if (current == 0) {
      final cycleStart = stack.indexOf(id);
      final cycle = <String>[
        ...stack.sublist(cycleStart < 0 ? 0 : cycleStart),
        id,
      ];
      errors.add('dependency cycle detected: ${cycle.join(' -> ')}');
      return false;
    }
    if (current == 1) return true;
    state[id] = 0;
    stack.add(id);
    for (final dep in modules[id]?.deps ?? const <String>[]) {
      if (modules.containsKey(dep) && !dfs(dep)) {
        stack.removeLast();
        state[id] = 1;
        return false;
      }
    }
    stack.removeLast();
    state[id] = 1;
    return true;
  }

  for (final id in modules.keys) {
    dfs(id);
  }
}
