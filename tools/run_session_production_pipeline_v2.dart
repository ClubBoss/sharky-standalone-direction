import 'dart:io';

void main(List<String> args) async {
  final cfg = _parseArgs(args);
  if (cfg.error != null) {
    stderr.writeln('pipeline_v2: ${cfg.error}');
    exitCode = 2;
    return;
  }

  final repoRoot = Directory.current.absolute.path;
  final workdir = Directory(cfg.workdir!).absolute;
  if (!_isSafeWorkdir(repoRoot, workdir.path) && !cfg.allowRepoWorkdir) {
    stderr.writeln(
      'pipeline_v2: workdir must be outside repo (use --allow-repo-workdir to override): ${workdir.path}',
    );
    exitCode = 2;
    return;
  }

  if (!workdir.existsSync()) {
    workdir.createSync(recursive: true);
  }
  final bundlesDir = Directory('${workdir.path}/bundles');

  final runPrepare = cfg.prepare || (!cfg.prepare && !cfg.hasLintInputs);
  final runLint = cfg.hasLintInputs;
  final runIngest = cfg.ingestDir != null;
  var lintedCount = 0;
  var ingestedCount = 0;

  if (runPrepare) {
    final code = await _runPrepare(cfg, workdir, bundlesDir);
    if (code != 0) {
      exitCode = 5;
      return;
    }
  }

  if (runLint) {
    final bundleFiles = _resolveLintBundleFiles(cfg, bundlesDir.path);
    if (bundleFiles.isEmpty) {
      stderr.writeln('pipeline_v2: no lint bundle files found');
      exitCode = 2;
      return;
    }
    final code = await _runLint(cfg, bundleFiles);
    if (code != 0) {
      exitCode = 3;
      return;
    }
    lintedCount = bundleFiles.length;
  }

  if (runIngest) {
    final ingestFiles = _resolveIngestBundleFiles(cfg);
    if (ingestFiles.isEmpty) {
      stderr.writeln('pipeline_v2: no ingest bundle files found');
      exitCode = 2;
      return;
    }

    // Safety contract: ingestDir requires lint in the same invocation.
    if (!runLint) {
      stderr.writeln(
        'pipeline_v2: --ingestDir requires --lintDir or --lint in the same invocation',
      );
      exitCode = 2;
      return;
    }

    // If both lint and ingest run, ensure ingest set is also linted.
    final lintSet = _resolveLintBundleFiles(cfg, bundlesDir.path).toSet();
    for (final path in ingestFiles) {
      if (!lintSet.contains(path)) {
        stderr.writeln(
          'pipeline_v2: ingest bundle was not linted in this invocation: $path',
        );
        exitCode = 3;
        return;
      }
    }

    final code = await _runIngest(cfg, ingestFiles);
    if (code != 0) {
      exitCode = 4;
      return;
    }
    ingestedCount = ingestFiles.length;
  }

  if (cfg.printNext) {
    _printNextCommands(cfg, workdir.path);
  }

  stdout.writeln(
    'pipeline_v2: OK prepare=$runPrepare lint=$runLint ingest=$runIngest linted_bundles=$lintedCount ingested_bundles=$ingestedCount mode=${cfg.apply ? 'APPLIED' : 'DRY-RUN'} packets=${cfg.packets}',
  );
}

class _Config {
  const _Config({
    required this.workdir,
    required this.packets,
    required this.prepare,
    required this.lintFiles,
    required this.lintDir,
    required this.ingestDir,
    required this.onlyPacket,
    required this.printNext,
    required this.allowRepoWorkdir,
    required this.apply,
    this.error,
  });

  final String? workdir;
  final int packets;
  final bool prepare;
  final List<String> lintFiles;
  final String? lintDir;
  final String? ingestDir;
  final int? onlyPacket;
  final bool printNext;
  final bool allowRepoWorkdir;
  final bool apply;
  final String? error;

  bool get hasLintInputs => lintFiles.isNotEmpty || lintDir != null;
}

_Config _parseArgs(List<String> args) {
  String? workdir;
  int? packets;
  var prepare = false;
  final lintFiles = <String>[];
  String? lintDir;
  String? ingestDir;
  int? onlyPacket;
  var printNext = true;
  var allowRepoWorkdir = false;
  var apply = false;

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    switch (a) {
      case '--workdir':
        if (i + 1 >= args.length) return _err('missing value for --workdir');
        workdir = args[++i];
        break;
      case '--packets':
        if (i + 1 >= args.length) return _err('missing value for --packets');
        packets = int.tryParse(args[++i]);
        break;
      case '--prepare':
        prepare = true;
        break;
      case '--lint':
        if (i + 1 >= args.length) return _err('missing value for --lint');
        lintFiles.add(args[++i]);
        break;
      case '--lintDir':
        if (i + 1 >= args.length) return _err('missing value for --lintDir');
        lintDir = args[++i];
        break;
      case '--ingestDir':
        if (i + 1 >= args.length) return _err('missing value for --ingestDir');
        ingestDir = args[++i];
        break;
      case '--dry-run':
        // Default ingest mode is already dry-run unless --apply is passed.
        break;
      case '--apply':
        apply = true;
        break;
      case '--only-packet':
        if (i + 1 >= args.length)
          return _err('missing value for --only-packet');
        onlyPacket = int.tryParse(args[++i]);
        break;
      case '--print-next':
        printNext = true;
        break;
      case '--no-print-next':
        printNext = false;
        break;
      case '--allow-repo-workdir':
        allowRepoWorkdir = true;
        break;
      default:
        return _err('unknown argument: $a');
    }
  }

  if (workdir == null || workdir.isEmpty) return _err('--workdir is required');
  if (packets == null) return _err('--packets is required');
  if (packets < 1) return _err('--packets must be >=1');
  if (onlyPacket != null && onlyPacket < 0) {
    return _err('--only-packet must be >=0');
  }
  if (lintDir != null && lintFiles.isNotEmpty) {
    return _err('use either --lint (repeatable) or --lintDir, not both');
  }
  if (ingestDir != null && ingestDir.isEmpty) {
    return _err('--ingestDir must not be empty');
  }

  return _Config(
    workdir: workdir,
    packets: packets,
    prepare: prepare,
    lintFiles: lintFiles,
    lintDir: lintDir,
    ingestDir: ingestDir,
    onlyPacket: onlyPacket,
    printNext: printNext,
    allowRepoWorkdir: allowRepoWorkdir,
    apply: apply,
  );
}

_Config _err(String message) => _Config(
  workdir: null,
  packets: 0,
  prepare: false,
  lintFiles: const [],
  lintDir: null,
  ingestDir: null,
  onlyPacket: null,
  printNext: true,
  allowRepoWorkdir: false,
  apply: false,
  error: message,
);

bool _isSafeWorkdir(String repoRoot, String workdir) {
  final repo = _normAbs(repoRoot);
  final wd = _normAbs(workdir);
  return !(wd == repo || wd.startsWith('$repo/'));
}

String _normAbs(String path) => Directory(
  path,
).absolute.path.replaceAll('\\', '/').replaceAll(RegExp('/+'), '/');

Future<int> _runPrepare(
  _Config cfg,
  Directory workdir,
  Directory bundlesDir,
) async {
  stdout.writeln(
    'pipeline_v2: prepare shard packets=${cfg.packets} out=${workdir.path}',
  );
  final shardCode = await _runDartTool('tools/shard_world_sessions_v1.dart', [
    '--packets',
    '${cfg.packets}',
    '--out',
    workdir.path,
  ]);
  if (shardCode != 0) return shardCode;

  if (!bundlesDir.existsSync()) {
    bundlesDir.createSync(recursive: true);
  }
  stdout.writeln(
    'pipeline_v2: prepare render in=${workdir.path}/packets_v1.json out=${bundlesDir.path}',
  );
  final renderCode = await _runDartTool(
    'tools/render_session_bundle_templates_v1.dart',
    ['--in', '${workdir.path}/packets_v1.json', '--out', bundlesDir.path],
  );
  if (renderCode != 0) return renderCode;

  if (cfg.onlyPacket != null) {
    final expected = 'bundle_template_packet_${cfg.onlyPacket}_v1.txt';
    final templates =
        bundlesDir
            .listSync()
            .whereType<File>()
            .where(
              (f) =>
                  f.uri.pathSegments.last.startsWith('bundle_template_packet_'),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    var found = false;
    for (final f in templates) {
      if (f.uri.pathSegments.last == expected) {
        found = true;
        continue;
      }
      f.deleteSync();
    }
    if (!found) {
      stderr.writeln(
        'pipeline_v2: --only-packet ${cfg.onlyPacket} not found after render',
      );
      return 1;
    }
    stdout.writeln(
      'pipeline_v2: prepare retained only packet=${cfg.onlyPacket}',
    );
  }

  return 0;
}

List<String> _resolveLintBundleFiles(_Config cfg, String defaultBundlesDir) {
  if (cfg.lintFiles.isNotEmpty) {
    final files = cfg.lintFiles.map((p) => File(p).path).toList()..sort();
    return files;
  }

  final dirPath = cfg.lintDir ?? defaultBundlesDir;
  final dir = Directory(dirPath);
  if (!dir.existsSync()) return const [];
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

Future<int> _runLint(_Config cfg, List<String> bundleFiles) async {
  for (final bundle in bundleFiles) {
    stdout.writeln('pipeline_v2: lint bundle=$bundle');
    final args = <String>['--in', bundle];
    final code = await _runDartTool('tools/lint_session_bundle_v1.dart', args);
    if (code != 0) return code;
  }
  return 0;
}

List<String> _resolveIngestBundleFiles(_Config cfg) {
  final dirPath = cfg.ingestDir;
  if (dirPath == null) return const [];
  final dir = Directory(dirPath);
  if (!dir.existsSync()) return const [];
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

Future<int> _runIngest(_Config cfg, List<String> bundleFiles) async {
  for (final bundle in bundleFiles) {
    stdout.writeln(
      'pipeline_v2: ingest bundle=$bundle mode=${cfg.apply ? 'APPLIED' : 'DRY-RUN'}',
    );
    final args = <String>['--in', bundle];
    if (!cfg.apply) {
      args.add('--dry-run');
    }
    final code = await _runDartTool(
      'tools/ingest_session_bundle_v1.dart',
      args,
    );
    if (code != 0) return code;
  }
  return 0;
}

void _printNextCommands(_Config cfg, String workdir) {
  final bundlesPath = '${workdir}/bundles';
  stdout.writeln('pipeline_v2: next lint dir command:');
  stdout.writeln(
    'pipeline_v2:   dart run tools/run_session_production_pipeline_v2.dart --lintDir $bundlesPath --packets ${cfg.packets} --workdir $workdir',
  );
  stdout.writeln('pipeline_v2: next ingest dry-run command (v1 driver):');
  stdout.writeln(
    'pipeline_v2:   dart run tools/run_session_production_pipeline_v1.dart --ingest --dry-run --packets ${cfg.packets} --workdir $workdir --bundles $bundlesPath',
  );
  stdout.writeln('pipeline_v2: next one-command lint+ingest dry-run (v2):');
  stdout.writeln(
    'pipeline_v2:   dart run tools/run_session_production_pipeline_v2.dart --lintDir $bundlesPath --ingestDir $bundlesPath --packets ${cfg.packets} --workdir $workdir --dry-run',
  );
  stdout.writeln('pipeline_v2: next one-command lint+ingest apply (v2):');
  stdout.writeln(
    'pipeline_v2:   dart run tools/run_session_production_pipeline_v2.dart --lintDir $bundlesPath --ingestDir $bundlesPath --packets ${cfg.packets} --workdir $workdir --apply',
  );
}

Future<int> _runDartTool(String toolPath, List<String> toolArgs) async {
  final res = await Process.run('dart', ['run', toolPath, ...toolArgs]);
  final out = (res.stdout ?? '').toString();
  final err = (res.stderr ?? '').toString();
  if (out.isNotEmpty) stdout.write(out);
  if (err.isNotEmpty) stderr.write(err);
  return res.exitCode;
}
