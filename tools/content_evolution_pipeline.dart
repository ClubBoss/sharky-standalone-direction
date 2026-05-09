import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final stages = <Map<String, dynamic>>[];
  int stagesRun = 0;
  int stagesPass = 0;

  // Stage 1: Consistency
  final consistencyResult = await _runStage(
    'content_consistency_audit.dart',
    'Consistency',
  );
  stages.add(consistencyResult);
  stagesRun++;
  if (consistencyResult['pass'] == true) stagesPass++;

  // Stage 2: Semantic
  final semanticResult = await _runStage(
    'content_semantic_audit.dart',
    'Semantic',
  );
  stages.add(semanticResult);
  stagesRun++;
  if (semanticResult['pass'] == true) stagesPass++;

  // Stage 3: Drift
  final driftResult = await _runStage('content_drift_forecast.dart', 'Drift');
  stages.add(driftResult);
  stagesRun++;
  if (driftResult['pass'] == true) stagesPass++;

  final pipelineComplete = stagesRun == 3;
  final pass = pipelineComplete && stagesPass == stagesRun;

  final result = {
    'stages_run': stagesRun,
    'stages_pass': stagesPass,
    'pipeline_complete': pipelineComplete,
    'stages': stages,
    'pass': pass,
  };

  stdout.writeln(
    'Content Evolution Pipeline: ${pass ? "PASS" : "FAIL"} ($stagesPass/$stagesRun)',
  );
  stdout.writeln(jsonEncode(result));
}

Future<Map<String, dynamic>> _runStage(String script, String stageName) async {
  try {
    final result = await Process.run('dart', ['run', 'tools/$script']);

    if (result.exitCode != 0) {
      return {
        'stage': stageName,
        'pass': false,
        'error': 'Exit code ${result.exitCode}',
      };
    }

    final lines = (result.stdout as String).split('\n');
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      try {
        final data = jsonDecode(line) as Map<String, dynamic>;
        return {'stage': stageName, 'pass': data['pass'] == true, 'data': data};
      } catch (_) {}
    }

    return {'stage': stageName, 'pass': false, 'error': 'No valid JSON'};
  } catch (e) {
    return {'stage': stageName, 'pass': false, 'error': e.toString()};
  }
}
