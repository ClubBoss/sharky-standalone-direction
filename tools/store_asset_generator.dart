// Stage I2 — Landing / Store Asset Generator
//
// This tool produces a deterministic bundle under release/store_bundle/ with:
// - store_landing.html: ASCII-only, responsive HTML landing page
// - metadata.json: version, readiness, XP coverage, monetization summary
// - assets/: copied screenshots/icons from assets/store_previews/ (if any)
// - Telemetry event: store_assets_generated
//
// Usage:
//   dart run tools/store_asset_generator.dart
//
// Notes:
// - The generator is deterministic: files are written with a stable order and
//   without timestamps inside the HTML (except metadata.json 'generated_at').
// - Missing optional sources (like assets/store_previews) are handled gracefully.

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart' as yaml;

Future<void> main(List<String> args) async {
  final outDir = Directory('release/store_bundle');
  await _ensureDir(outDir);
  final assetsOutDir = Directory('${outDir.path}/assets');
  await _ensureDir(assetsOutDir);

  final pubspec = await _readPubspec();
  final versionJson = await _readJsonIfExists('release/version.json');
  final healthJson = await _readJsonIfExists('health_dashboard.json');
  final econTuning = await _readJsonIfExists('economy_tuning.json');
  final econTelemetry = await _readJsonIfExists(
    'economy_telemetry_analyzer.json',
  );

  final appName = (pubspec['name'] as String?) ?? 'app';
  final pubspecVersion = (pubspec['version'] as String?) ?? '0.0.0+0';
  final versionLabel = (versionJson['version_label'] as String?) ?? '';

  final readiness =
      _asDouble(versionJson['readiness_score']) ??
      _asDouble(healthJson['readiness_score']) ??
      0.0;

  // Extract XP coverage from health_dashboard.json (content_xp_coverage: {tagged,total})
  double xpCoveragePct = 0.0;
  int xpTagged = 0;
  int xpTotal = 0;
  final contentXp = _asMap(healthJson['content_xp_coverage']);
  if (contentXp.isNotEmpty) {
    xpTagged = (contentXp['tagged'] as num?)?.toInt() ?? 0;
    xpTotal = (contentXp['total'] as num?)?.toInt() ?? 0;
    xpCoveragePct = xpTotal > 0 ? (xpTagged * 100.0 / xpTotal) : 0.0;
  }

  // Monetization summary (from economy reports)
  final monetization = <String, Object?>{
    'xp_factor':
        _asDouble(econTuning['xpFactor']) ??
        _asDouble(econTuning['xp_factor']) ??
        1.0,
    'refill_minutes':
        (econTuning['refillMinutes'] as num?)?.toInt() ??
        (econTuning['refill'] as num?)?.toInt() ??
        30,
    'trend': (econTelemetry['trend'] as String?) ?? 'stable',
    'risk': _asDouble(econTelemetry['risk']) ?? 0.5,
    'pass': (econTelemetry['pass'] as bool?) ?? true,
  };

  // Copy previews (if any) from assets/store_previews/* to release/store_bundle/assets/*
  final previewRoot = Directory('assets/store_previews');
  final copiedPreviews = <String>[];
  if (await previewRoot.exists()) {
    final files = await _listFilesRecursively(previewRoot);
    files.sort((a, b) => a.path.compareTo(b.path));
    for (final f in files) {
      final rel = f.path
          .substring(previewRoot.path.length)
          .replaceAll('\\', '/');
      final dest = File('${assetsOutDir.path}$rel');
      await dest.parent.create(recursive: true);
      await f.copy(dest.path);
      // Use POSIX-style relative path for HTML/metadata
      final relAsset = 'assets$rel';
      copiedPreviews.add(relAsset);
    }
  }

  // Write metadata.json
  final metadata = <String, Object?>{
    'app_name': appName,
    'pubspec_version': pubspecVersion,
    'version_label': versionLabel,
    'readiness_score': double.parse(readiness.toStringAsFixed(1)),
    'xp_coverage_percent': double.parse(xpCoveragePct.toStringAsFixed(1)),
    'xp_tagged': xpTagged,
    'xp_total': xpTotal,
    'monetization': monetization,
    'previews': copiedPreviews,
    'download_links': await _discoverDownloads(),
    'generated_at': DateTime.now().toUtc().toIso8601String(),
  };
  await File(
    '${outDir.path}/metadata.json',
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(metadata));

  // Write store_landing.html (ASCII-only)
  final html = _buildHtml(
    appName: appName,
    versionLabel: versionLabel.isEmpty ? pubspecVersion : versionLabel,
    readiness: readiness,
    xpCoveragePct: xpCoveragePct,
    monetization: monetization,
    previewPaths: copiedPreviews,
  );
  await File('${outDir.path}/store_landing.html').writeAsString(html);

  // Telemetry (file-based best-effort for CLI environment)
  await _appendTelemetryEvent('store_assets_generated', <String, Object?>{
    'version': versionLabel.isEmpty ? pubspecVersion : versionLabel,
    'previews_count': copiedPreviews.length,
    'xp_pct': double.parse(xpCoveragePct.toStringAsFixed(1)),
    'readiness': double.parse(readiness.toStringAsFixed(1)),
  });

  stdout.writeln('Store asset bundle generated at: ${outDir.path}');
}

Future<Map<String, Object?>> _readPubspec() async {
  final file = File('pubspec.yaml');
  if (!await file.exists()) return <String, Object?>{};
  final doc = yaml.loadYaml(await file.readAsString()) as yaml.YamlMap?;
  final map = <String, Object?>{};
  if (doc != null) {
    for (final entry in doc.entries) {
      map[entry.key.toString()] = entry.value;
    }
  }
  return map;
}

Future<Map<String, dynamic>> _readJsonIfExists(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) return <String, dynamic>{};
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
}

Future<void> _ensureDir(Directory dir) async {
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
}

Map<String, Object?> _asMap(Object? v) {
  if (v is Map) return Map<String, Object?>.from(v);
  return const <String, Object?>{};
}

double? _asDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) {
    final p = double.tryParse(v);
    return p;
  }
  return null;
}

Future<List<File>> _listFilesRecursively(Directory root) async {
  final files = <File>[];
  await for (final ent in root.list(recursive: true, followLinks: false)) {
    if (ent is File) {
      files.add(ent);
    }
  }
  return files;
}

Future<List<Map<String, String>>> _discoverDownloads() async {
  final links = <Map<String, String>>[];
  final pbZip = File('release/public_beta/beta_full_bundle.zip');
  if (await pbZip.exists()) {
    links.add({
      'label': 'Public Beta Bundle',
      'href': '../public_beta/beta_full_bundle.zip',
    });
  }
  final pbIndex = File('release/public_beta/index.html');
  if (await pbIndex.exists()) {
    links.add({
      'label': 'Public Beta Landing',
      'href': '../public_beta/index.html',
    });
  }
  final relNotes = File('docs/RELEASE_NOTES.md');
  if (await relNotes.exists()) {
    links.add({
      'label': 'Release Notes',
      'href': '../../docs/RELEASE_NOTES.md',
    });
  }
  return links;
}

String _buildHtml({
  required String appName,
  required String versionLabel,
  required double readiness,
  required double xpCoveragePct,
  required Map<String, Object?> monetization,
  required List<String> previewPaths,
}) {
  // Simple, responsive, ASCII-only HTML with inline CSS
  final buf = StringBuffer();
  buf.writeln('<!DOCTYPE html>');
  buf.writeln('<html lang="en">');
  buf.writeln('<head>');
  buf.writeln('  <meta charset="utf-8" />');
  buf.writeln(
    '  <meta name="viewport" content="width=device-width, initial-scale=1" />',
  );
  buf.writeln('  <title>$appName Store Landing</title>');
  buf.writeln('  <style>');
  buf.writeln(
    '    body { font-family: Arial, Helvetica, sans-serif; margin: 0; color: #222; background: #fff; }',
  );
  buf.writeln(
    '    .wrap { max-width: 1080px; margin: 0 auto; padding: 16px; }',
  );
  buf.writeln('    h1 { font-size: 24px; margin: 8px 0; }');
  buf.writeln('    h2 { font-size: 18px; margin: 16px 0 8px; }');
  buf.writeln('    p { line-height: 1.5; }');
  buf.writeln('    .meta { font-size: 14px; color: #555; }');
  buf.writeln(
    '    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 12px; }',
  );
  buf.writeln(
    '    .card { border: 1px solid #ddd; border-radius: 8px; padding: 8px; }',
  );
  buf.writeln(
    '    .shot { width: 100%; height: auto; display: block; border-radius: 6px; border: 1px solid #eee; }',
  );
  buf.writeln('    ul { padding-left: 18px; }');
  buf.writeln(
    '    a.btn { display: inline-block; padding: 10px 14px; margin: 6px 6px 0 0; color: #fff; background: #1d7b72; text-decoration: none; border-radius: 6px; }',
  );
  buf.writeln('    .section { margin: 16px 0; }');
  buf.writeln('    .row { display: flex; flex-wrap: wrap; gap: 12px; }');
  buf.writeln('    .row > div { flex: 1; min-width: 260px; }');
  buf.writeln('  </style>');
  buf.writeln('</head>');
  buf.writeln('<body>');
  buf.writeln('  <div class="wrap">');
  buf.writeln('    <h1>$appName</h1>');
  buf.writeln(
    '    <div class="meta">Version: $versionLabel &nbsp;|&nbsp; Readiness: ${readiness.toStringAsFixed(1)}% &nbsp;|&nbsp; XP Coverage: ${xpCoveragePct.toStringAsFixed(1)}%</div>',
  );
  buf.writeln('    <div class="section">');
  buf.writeln(
    '      <p>Adaptive poker training. Practice push and fold decisions, review hands, and track progress. Designed for responsive performance and clear progression, ready for public beta evaluation.</p>',
  );
  buf.writeln('      <div>');
  buf.writeln(
    '        <a class="btn" href="../public_beta/beta_full_bundle.zip">Download Beta Bundle</a>',
  );
  buf.writeln(
    '        <a class="btn" href="../public_beta/index.html">Public Beta Landing</a>',
  );
  buf.writeln(
    '        <a class="btn" href="../../docs/RELEASE_NOTES.md">Release Notes</a>',
  );
  buf.writeln('      </div>');
  buf.writeln('    </div>');
  buf.writeln('    <div class="row section">');
  buf.writeln('      <div>');
  buf.writeln('        <h2>Main Features</h2>');
  buf.writeln('        <ul>');
  buf.writeln('          <li>League dashboard (live progression)</li>');
  buf.writeln('          <li>Level up overlay (celebration)</li>');
  buf.writeln('          <li>Session summary card with league progress</li>');
  buf.writeln('          <li>AI coach overlay (action feedback)</li>');
  buf.writeln('          <li>Replay and simulation tools</li>');
  buf.writeln('        </ul>');
  buf.writeln('      </div>');
  buf.writeln('      <div>');
  buf.writeln('        <h2>Monetization and Tuning</h2>');
  buf.writeln('        <ul>');
  buf.writeln(
    '          <li>XP factor: ${_safeNum(monetization['xp_factor'])}</li>',
  );
  buf.writeln(
    '          <li>Energy refill: ${_safeNum(monetization['refill_minutes'])} minutes</li>',
  );
  buf.writeln('          <li>Trend: ${monetization['trend']}</li>');
  buf.writeln('          <li>Risk: ${_safeNum(monetization['risk'])}</li>');
  buf.writeln(
    '          <li>Status: ${(monetization['pass'] == true) ? 'pass' : 'review'}</li>',
  );
  buf.writeln('        </ul>');
  buf.writeln('      </div>');
  buf.writeln('    </div>');
  buf.writeln('    <div class="section">');
  buf.writeln('      <h2>Screenshots</h2>');
  if (previewPaths.isEmpty) {
    buf.writeln(
      '      <p>No previews found. Add files under assets/store_previews/.</p>',
    );
  } else {
    buf.writeln('      <div class="grid">');
    for (final p in previewPaths) {
      final esc = p.replaceAll('"', '');
      buf.writeln(
        '        <div class="card"><img class="shot" src="$esc" alt="preview" /></div>',
      );
    }
    buf.writeln('      </div>');
  }
  buf.writeln('    </div>');
  buf.writeln('  </div>');
  buf.writeln('</body>');
  buf.writeln('</html>');
  return buf.toString();
}

String _safeNum(Object? v) {
  if (v is num)
    return v
        .toStringAsFixed(v is int ? 0 : 2)
        .replaceFirst(RegExp(r'\.00$'), '');
  if (v is String) return v;
  return '0';
}

Future<void> _appendTelemetryEvent(
  String name,
  Map<String, Object?> params,
) async {
  try {
    final file = File('tools/_reports/store_assets_events.jsonl');
    await file.parent.create(recursive: true);
    final record = <String, Object?>{
      'event': name,
      'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
      'params': params,
    };
    await file.writeAsString('${jsonEncode(record)}\n', mode: FileMode.append);
  } catch (_) {
    // Ignore failures in telemetry write
  }
}
