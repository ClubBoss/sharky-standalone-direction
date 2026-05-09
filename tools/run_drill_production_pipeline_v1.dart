import 'dart:io';

void main(List<String> args) async {
  final cfg = _parseArgs(args);
  if (cfg.error != null) {
    stderr.writeln('drill_pipeline_v1: ${cfg.error}');
    exitCode = 2;
    return;
  }

  final repoRoot = Directory.current.absolute.path;
  final workdir = Directory(cfg.workdir!).absolute;
  if (!_isSafeWorkdir(repoRoot, workdir.path) && !cfg.allowRepoWorkdir) {
    stderr.writeln(
      'drill_pipeline_v1: workdir must be outside repo (use --allow-repo-workdir to override): ${workdir.path}',
    );
    exitCode = 2;
    return;
  }

  if (!workdir.existsSync()) {
    workdir.createSync(recursive: true);
  }
  final bundlesDir = Directory('${workdir.path}/bundles');

  final runPrepare =
      cfg.prepare ||
      (!cfg.prepare && cfg.lintDir == null && cfg.ingestDir == null);
  final runLint = cfg.lintDir != null;
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

  List<String> lintFiles = const [];
  if (runLint) {
    lintFiles = _resolveTxtFiles(cfg.lintDir!);
    if (lintFiles.isEmpty) {
      stderr.writeln('drill_pipeline_v1: no lint bundle files found');
      exitCode = 2;
      return;
    }
    final code = await _runLint(lintFiles);
    if (code != 0) {
      exitCode = 3;
      return;
    }
    lintedCount = lintFiles.length;
  }

  if (runIngest) {
    final ingestFiles = _resolveTxtFiles(cfg.ingestDir!);
    if (ingestFiles.isEmpty) {
      stderr.writeln('drill_pipeline_v1: no ingest bundle files found');
      exitCode = 2;
      return;
    }
    if (!runLint) {
      stderr.writeln(
        'drill_pipeline_v1: --ingestDir requires --lintDir in the same invocation',
      );
      exitCode = 2;
      return;
    }
    final lintSet = lintFiles.toSet();
    for (final file in ingestFiles) {
      if (!lintSet.contains(file)) {
        stderr.writeln(
          'drill_pipeline_v1: ingest bundle was not linted in this invocation: $file',
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

  _printNextCommands(cfg, workdir.path);
  stdout.writeln(
    'drill_pipeline_v1: OK prepare=$runPrepare lint=$runLint ingest=$runIngest linted_bundles=$lintedCount ingested_bundles=$ingestedCount mode=${cfg.apply ? 'APPLIED' : 'DRY-RUN'} packets=${cfg.packets}',
  );
}

class _Config {
  const _Config({
    required this.workdir,
    required this.packets,
    required this.prepare,
    required this.lintDir,
    required this.ingestDir,
    required this.allowRepoWorkdir,
    required this.apply,
    this.error,
  });

  final String? workdir;
  final int packets;
  final bool prepare;
  final String? lintDir;
  final String? ingestDir;
  final bool allowRepoWorkdir;
  final bool apply;
  final String? error;
}

_Config _parseArgs(List<String> args) {
  String? workdir;
  int? packets;
  var prepare = false;
  String? lintDir;
  String? ingestDir;
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
      case '--lintDir':
        if (i + 1 >= args.length) return _err('missing value for --lintDir');
        lintDir = args[++i];
        break;
      case '--ingestDir':
        if (i + 1 >= args.length) return _err('missing value for --ingestDir');
        ingestDir = args[++i];
        break;
      case '--dry-run':
        break;
      case '--apply':
        apply = true;
        break;
      case '--allow-repo-workdir':
        allowRepoWorkdir = true;
        break;
      default:
        return _err('unknown argument: $a');
    }
  }

  if (workdir == null || workdir.isEmpty) return _err('--workdir is required');
  if (packets == null || packets < 1) return _err('--packets must be >=1');

  return _Config(
    workdir: workdir,
    packets: packets,
    prepare: prepare,
    lintDir: lintDir,
    ingestDir: ingestDir,
    allowRepoWorkdir: allowRepoWorkdir,
    apply: apply,
  );
}

_Config _err(String message) => _Config(
  workdir: null,
  packets: 0,
  prepare: false,
  lintDir: null,
  ingestDir: null,
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
    'drill_pipeline_v1: prepare shard packets=${cfg.packets} out=${workdir.path}',
  );
  final shardCode = await _runDartTool('tools/shard_world_drills_v1.dart', [
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
    'drill_pipeline_v1: prepare render in=${workdir.path}/packets_drills_v1.json out=${bundlesDir.path}',
  );
  return _runDartTool('tools/render_drill_bundle_templates_v1.dart', [
    '--in',
    '${workdir.path}/packets_drills_v1.json',
    '--out',
    bundlesDir.path,
  ]);
}

List<String> _resolveTxtFiles(String dirPath) {
  final dir = Directory(dirPath);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.txt'))
      .map((f) => f.path)
      .toList()
    ..sort();
}

Future<int> _runLint(List<String> bundleFiles) async {
  for (final bundle in bundleFiles) {
    stdout.writeln('drill_pipeline_v1: lint bundle=$bundle');
    final code = await _runDartTool('tools/lint_drill_bundle_v1.dart', [
      '--in',
      bundle,
    ]);
    if (code != 0) return code;
  }
  return 0;
}

Future<int> _runIngest(_Config cfg, List<String> bundleFiles) async {
  for (final bundle in bundleFiles) {
    stdout.writeln(
      'drill_pipeline_v1: ingest bundle=$bundle mode=${cfg.apply ? 'APPLIED' : 'DRY-RUN'}',
    );
    final args = <String>['--in', bundle];
    if (!cfg.apply) {
      args.add('--dry-run');
    }
    final code = await _runDartTool('tools/ingest_drill_bundle_v1.dart', args);
    if (code != 0) return code;
  }
  return 0;
}

void _printNextCommands(_Config cfg, String workdir) {
  final bundlesPath = '$workdir/bundles';
  stdout.writeln('drill_pipeline_v1: next lint dir command:');
  stdout.writeln(
    'drill_pipeline_v1:   dart run tools/run_drill_production_pipeline_v1.dart --lintDir $bundlesPath --packets ${cfg.packets} --workdir $workdir',
  );
  stdout.writeln('drill_pipeline_v1: next ingest dry-run command:');
  stdout.writeln(
    'drill_pipeline_v1:   dart run tools/run_drill_production_pipeline_v1.dart --lintDir $bundlesPath --ingestDir $bundlesPath --packets ${cfg.packets} --workdir $workdir --dry-run',
  );
  stdout.writeln('drill_pipeline_v1: next ingest apply command:');
  stdout.writeln(
    'drill_pipeline_v1:   dart run tools/run_drill_production_pipeline_v1.dart --lintDir $bundlesPath --ingestDir $bundlesPath --packets ${cfg.packets} --workdir $workdir --apply',
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
