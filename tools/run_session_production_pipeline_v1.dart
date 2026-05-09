import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final cfg = _parseArgs(args);
  if (cfg.error != null) {
    stderr.writeln('pipeline_v1: ${cfg.error}');
    exitCode = 2;
    return;
  }

  final workdir = Directory(cfg.workdir!);
  if (!workdir.existsSync()) {
    workdir.createSync(recursive: true);
  }
  final bundlesDir = Directory('${workdir.path}/bundles');
  if ((cfg.prepare || cfg.all) && !bundlesDir.existsSync()) {
    bundlesDir.createSync(recursive: true);
  }

  var lintRan = false;
  var ingestRan = false;
  final ingestedSessionIds = <String>{};

  if (cfg.prepare || cfg.all) {
    final prepareCode = await _runPrepare(cfg, workdir, bundlesDir);
    if (prepareCode != 0) {
      exitCode = prepareCode;
      return;
    }
  }

  if (cfg.lint || cfg.all) {
    final bundles = _resolveBundles(cfg.bundlesPath ?? bundlesDir.path);
    final lintRes = await _runLint(cfg, bundles);
    lintRan = true;
    if (lintRes.exitCode != 0) {
      exitCode = 3;
      return;
    }
  }

  if (cfg.ingest || cfg.all) {
    final bundles = _resolveBundles(cfg.bundlesPath ?? bundlesDir.path);
    final lintForIds = await _runLint(cfg, bundles, collectIds: true);
    lintRan = true;
    if (lintForIds.exitCode != 0) {
      exitCode = 3;
      return;
    }
    ingestedSessionIds.addAll(lintForIds.sessionIds);

    final ingestCode = await _runIngest(cfg, bundles);
    ingestRan = true;
    if (ingestCode != 0) {
      exitCode = 4;
      return;
    }
  }

  if (cfg.hash) {
    final hashCode = await _emitHashes(
      workdir: workdir,
      bundlesDir: bundlesDir,
      includeIngestedContent: ingestRan && !cfg.dryRun,
      ingestedSessionIds: ingestedSessionIds,
    );
    if (hashCode != 0) {
      exitCode = hashCode;
      return;
    }
  }

  if (!(cfg.prepare || cfg.lint || cfg.ingest || cfg.all || cfg.hash)) {
    stderr.writeln('pipeline_v1: no mode selected');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'pipeline_v1: OK prepare=${cfg.prepare || cfg.all} lint=${lintRan || cfg.lint || cfg.all} ingest=${cfg.ingest || cfg.all} dry_run=${cfg.dryRun}',
  );
}

class _Config {
  _Config({
    this.prepare = false,
    this.lint = false,
    this.ingest = false,
    this.all = false,
    this.hash = false,
    this.packets,
    this.workdir,
    this.bundlesPath,
    this.dryRun = false,
    this.error,
  });

  final bool prepare;
  final bool lint;
  final bool ingest;
  final bool all;
  final bool hash;
  final int? packets;
  final String? workdir;
  final String? bundlesPath;
  final bool dryRun;
  final String? error;
}

_Config _parseArgs(List<String> args) {
  var prepare = false;
  var lint = false;
  var ingest = false;
  var all = false;
  var hash = false;
  var dryRun = false;
  var packets = 3;
  String? workdir;
  String? bundles;

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    switch (a) {
      case '--prepare':
        prepare = true;
        break;
      case '--lint':
        lint = true;
        break;
      case '--ingest':
        ingest = true;
        break;
      case '--all':
        all = true;
        break;
      case '--hash':
        hash = true;
        break;
      case '--dry-run':
        dryRun = true;
        break;
      case '--packets':
        if (i + 1 >= args.length)
          return _Config(error: 'missing value for --packets');
        packets = int.tryParse(args[++i]) ?? -1;
        break;
      case '--workdir':
        if (i + 1 >= args.length)
          return _Config(error: 'missing value for --workdir');
        workdir = args[++i];
        break;
      case '--bundles':
        if (i + 1 >= args.length)
          return _Config(error: 'missing value for --bundles');
        bundles = args[++i];
        break;
      default:
        return _Config(error: 'unknown argument: $a');
    }
  }
  if (packets < 1) return _Config(error: '--packets must be >=1');
  if (workdir == null || workdir.isEmpty)
    return _Config(error: '--workdir is required');
  return _Config(
    prepare: prepare,
    lint: lint,
    ingest: ingest,
    all: all,
    hash: hash,
    packets: packets,
    workdir: workdir,
    bundlesPath: bundles,
    dryRun: dryRun,
  );
}

Future<int> _runPrepare(
  _Config cfg,
  Directory workdir,
  Directory bundlesDir,
) async {
  stdout.writeln(
    'pipeline_v1: prepare shard packets=${cfg.packets} out=${workdir.path}',
  );
  var code = await _runDartTool('tools/shard_world_sessions_v1.dart', [
    '--packets',
    '${cfg.packets}',
    '--out',
    workdir.path,
  ]);
  if (code != 0) return code;
  stdout.writeln(
    'pipeline_v1: prepare render in=${workdir.path}/packets_v1.json out=${bundlesDir.path}',
  );
  code = await _runDartTool('tools/render_session_bundle_templates_v1.dart', [
    '--in',
    '${workdir.path}/packets_v1.json',
    '--out',
    bundlesDir.path,
  ]);
  return code;
}

class _LintRunResult {
  const _LintRunResult(this.exitCode, this.sessionIds);
  final int exitCode;
  final Set<String> sessionIds;
}

Future<_LintRunResult> _runLint(
  _Config cfg,
  List<String> bundles, {
  bool collectIds = false,
}) async {
  final ids = <String>{};
  for (final bundle in bundles) {
    stdout.writeln('pipeline_v1: lint bundle=$bundle');
    final res = await _runDartToolCapture('tools/lint_session_bundle_v1.dart', [
      '--in',
      bundle,
    ]);
    if (res.exitCode != 0) {
      _printProcOutput(res);
      return _LintRunResult(res.exitCode, ids);
    }
    _printProcOutput(res);
    if (collectIds) {
      for (final line in const LineSplitter().convert(res.stdout)) {
        final p = 'lint_session_bundle_v1: sessions=';
        if (!line.startsWith(p)) continue;
        final idx = line.indexOf(' ids=');
        if (idx < 0) continue;
        final rawIds = line.substring(idx + 5).trim();
        if (rawIds.isEmpty) continue;
        for (final id in rawIds.split(',')) {
          if (id.isNotEmpty) ids.add(id);
        }
      }
    }
  }
  return _LintRunResult(0, ids);
}

Future<int> _runIngest(_Config cfg, List<String> bundles) async {
  for (final bundle in bundles) {
    stdout.writeln('pipeline_v1: ingest bundle=$bundle dry_run=${cfg.dryRun}');
    final args = <String>['--in', bundle];
    if (cfg.dryRun) args.add('--dry-run');
    final code = await _runDartTool(
      'tools/ingest_session_bundle_v1.dart',
      args,
    );
    if (code != 0) return code;
  }
  return 0;
}

List<String> _resolveBundles(String spec) {
  final file = File(spec);
  if (file.existsSync()) return <String>[file.path];
  final dir = Directory(spec);
  if (dir.existsSync()) {
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.txt'))
            .map((f) => f.path)
            .toList()
          ..sort();
    return files;
  }
  if (spec.contains('*')) {
    final normalized = spec.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    final baseDir = slash >= 0 ? normalized.substring(0, slash) : '.';
    final pattern = slash >= 0 ? normalized.substring(slash + 1) : normalized;
    final regex = RegExp(
      '^' + RegExp.escape(pattern).replaceAll('\\*', '.*') + r'$',
    );
    final d = Directory(baseDir);
    if (!d.existsSync()) return const <String>[];
    final files =
        d
            .listSync()
            .whereType<File>()
            .where((f) => regex.hasMatch(f.uri.pathSegments.last))
            .map((f) => f.path)
            .toList()
          ..sort();
    return files;
  }
  return const <String>[];
}

Future<int> _emitHashes({
  required Directory workdir,
  required Directory bundlesDir,
  required bool includeIngestedContent,
  required Set<String> ingestedSessionIds,
}) async {
  final files = <String>[];
  final packets = File('${workdir.path}/packets_v1.json');
  if (packets.existsSync()) files.add(packets.path);
  if (bundlesDir.existsSync()) {
    final templates = bundlesDir
        .listSync()
        .whereType<File>()
        .where(
          (f) =>
              f.uri.pathSegments.last.startsWith('bundle_template_packet_') &&
              f.path.endsWith('_v1.txt'),
        )
        .map((f) => f.path)
        .toList();
    templates.sort();
    files.addAll(templates);
  }
  if (includeIngestedContent && ingestedSessionIds.isNotEmpty) {
    final manifest = _loadManifestMap();
    final ids = ingestedSessionIds.toList()..sort();
    for (final id in ids) {
      final base = manifest[id];
      if (base == null) continue;
      files.add('${base}drills/index.md');
      files.add('${base}notes.md');
      files.add('${base}session.md');
    }
  }
  files.sort();
  for (final path in files) {
    if (!File(path).existsSync()) continue;
    final rel = _relativeToCwd(path);
    final hash = await _sha1ViaSystem(path);
    if (hash == null) {
      stderr.writeln(
        'pipeline_v1: hash tool not available (need shasum or sha1sum)',
      );
      return 2;
    }
    stdout.writeln('pipeline_v1: hash $hash  $rel');
  }
  return 0;
}

Future<int> _runDartTool(String toolPath, List<String> toolArgs) async {
  final res = await _runDartToolCapture(toolPath, toolArgs);
  _printProcOutput(res);
  return res.exitCode;
}

class _ProcResult {
  const _ProcResult(this.exitCode, this.stdout, this.stderr);
  final int exitCode;
  final String stdout;
  final String stderr;
}

Future<_ProcResult> _runDartToolCapture(
  String toolPath,
  List<String> toolArgs,
) async {
  final args = <String>['run', toolPath, ...toolArgs];
  final res = await Process.run('dart', args);
  return _ProcResult(
    res.exitCode,
    (res.stdout ?? '').toString(),
    (res.stderr ?? '').toString(),
  );
}

void _printProcOutput(_ProcResult res) {
  if (res.stdout.isNotEmpty) stdout.write(res.stdout);
  if (res.stderr.isNotEmpty) stderr.write(res.stderr);
}

Map<String, String> _loadManifestMap() {
  final file = File('content/_meta/world_sessions_manifest_v1.json');
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final worlds = decoded['worlds'] as List<dynamic>;
  final out = <String, String>{};
  for (final w in worlds) {
    final sessions = (w as Map)['sessions'] as List<dynamic>;
    for (final s in sessions) {
      final m = s as Map;
      out[m['id'] as String] = m['path'] as String;
    }
  }
  return out;
}

String _relativeToCwd(String path) {
  final cwd = Directory.current.path.replaceAll('\\', '/');
  final norm = path.replaceAll('\\', '/');
  return norm.startsWith('$cwd/') ? norm.substring(cwd.length + 1) : norm;
}

Future<String?> _sha1ViaSystem(String path) async {
  for (final cmd in const ['shasum', 'sha1sum']) {
    try {
      final res = await Process.run(cmd, [path]);
      if (res.exitCode == 0) {
        final out = (res.stdout ?? '').toString().trim();
        if (out.isEmpty) continue;
        return out.split(RegExp(r'\s+')).first;
      }
    } catch (_) {
      continue;
    }
  }
  return null;
}
