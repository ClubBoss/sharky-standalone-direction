// extracted from health_dashboard.dart — stage D13-refactor step 1
// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';

Future<ProcessResult> _safeRunTool(
  List<String> args, {
  Duration timeout = const Duration(seconds: 60),
  String executable = 'dart',
}) async {
  try {
    return await Process.run(executable, args).timeout(
      timeout,
      onTimeout: () {
        stderr.writeln('[TIMEOUT] $executable ${args.join(' ')}');
        return ProcessResult(pid, 124, '', 'Timeout');
      },
    );
  } catch (e) {
    stderr.writeln('[ERROR] $executable ${args.join(' ')}: $e');
    return ProcessResult(0, 1, '', e.toString());
  }
}

Map<String, Object?> _parseLastJsonLine(String stdout) {
  if (stdout.trim().isEmpty) return const {};
  final lines = const LineSplitter().convert(stdout).reversed;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final parsed = jsonDecode(trimmed);
        if (parsed is Map) return parsed as Map<String, Object?>;
      } catch (_) {
        continue;
      }
    }
  }
  return const {};
}

Future<Map<String, dynamic>> _checkReleasePackStatus() async {
  try {
    final proc = await _safeRunTool(['run', 'tools/release_packager.dart']);
    Map<String, dynamic> data = {};
    if (proc.stdout is String) {
      try {
        final decoded = jsonDecode((proc.stdout as String).trim());
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}
    }
    final pass = (data['status'] == 'pass') && proc.exitCode == 0;
    return {...data, 'pass': pass};
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkFullReadinessAuditStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/full_readiness_audit.dart',
      '--embedded',
    ]);
    final reportFile = File('tools/_reports/full_readiness_summary.json');
    Map<String, dynamic> data = {};
    if (reportFile.existsSync()) {
      final raw = reportFile.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    }
    final pass = (data['status'] == 'pass') && proc.exitCode == 0;
    return {...data, 'pass': pass};
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkLandingPageStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/landing_page_generator.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {
      'pass': pass,
      'readiness_score':
          (summary['readiness_score'] as num?)?.toDouble() ?? 0.0,
      'modules': (summary['modules'] as num?)?.toInt() ?? 0,
      'index': summary['index'] ?? 'release/landing/index.html',
      'metadata': summary['metadata'] ?? 'release/landing/metadata.json',
    };
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, Object>> _checkDesignTokensStatus() async {
  try {
    final tokensDoc = File('lib/ui_v2/theme/design_tokens.md');
    final brandTheme = File('lib/ui_v2/theme/ui_v2_brand_theme.dart');
    final colors = File('lib/ui_v2/theme/ui_v2_colors.dart');
    final typography = File('lib/ui_v2/theme/ui_v2_typography.dart');

    final hasDoc = await tokensDoc.exists();
    final hasBrand = await brandTheme.exists();
    final hasColors = await colors.exists();
    final hasTypo = await typography.exists();

    final ready = hasDoc && hasBrand && hasColors && hasTypo;

    return {
      'hasDoc': hasDoc,
      'hasBrandTheme': hasBrand,
      'hasColors': hasColors,
      'hasTypography': hasTypo,
      'ready': ready,
      'pass': ready,
    };
  } catch (e) {
    return {
      'hasDoc': false,
      'hasBrandTheme': false,
      'hasColors': false,
      'hasTypography': false,
      'ready': false,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> runAllChecks() async {
  final summary = <String, dynamic>{};
  summary['release_pack_status'] = await _checkReleasePackStatus();
  summary['full_readiness_status'] = await _checkFullReadinessAuditStatus();
  summary['landing_page_status'] = await _checkLandingPageStatus();
  summary['design_tokens_status'] = await _checkDesignTokensStatus();
  return summary;
}
