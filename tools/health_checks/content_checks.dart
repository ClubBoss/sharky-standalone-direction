// extracted from health_dashboard.dart — stage D13-refactor step 1
// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';

bool _shouldSkipContentChecks() {
  final flag = Platform.environment['CI_HAS_CONTENT_CHANGES'];
  if (flag == null) return false;
  final normalized = flag.trim().toLowerCase();
  return normalized == '0' || normalized == 'false' || normalized == 'no';
}

Map<String, dynamic> _skippedStatus(Map<String, dynamic> extra) {
  return {'pass': true, 'skipped': true, ...extra};
}

Map<String, dynamic> _buildSkippedSummary() {
  return {
    'content_id_autofix_status': _skippedStatus({'fixed': 0, 'total': 0}),
    'content_schema_upgrade_status': _skippedStatus({
      'upgraded': 0,
      'skipped': 0,
    }),
    'content_auto_enricher_status': _skippedStatus({'checked': 0, 'fixed': 0}),
    'content_flow_audit_status': _skippedStatus({
      'modules': 0,
      'files': 0,
      'difficulty_jumps': 0,
      'xp_spikes': 0,
      'missing_links': 0,
    }),
    'content_semantic_audit_status': _skippedStatus({
      'packs': 0,
      'aligned_packs': 0,
      'weak_packs': 0,
      'duplicate_rationales': 0,
    }),
    'content_semantic_autofix_status': _skippedStatus({
      'packs_bridged': 0,
      'rationales_tagged': 0,
    }),
    'content_ci_publisher_status': _skippedStatus({
      'status': 'pass',
      'export': {'packages': 0},
      'index': {'index_count': 0},
    }),
    'content_theme_binder_status': _skippedStatus({'checked': 0, 'fixed': 0}),
    'content_narrative_binder_status': _skippedStatus({
      'added_transitions': 0,
      'linked_modules': 0,
      'contextualized': 0,
    }),
    'content_persona_harmonizer_status': _skippedStatus({
      'entries': 0,
      'harmonized_count': 0,
      'tone_score': 0.0,
    }),
    'content_emotion_tuner_status': _skippedStatus({
      'emotional_shifts': 0,
      'engagement_score': 0.0,
      'average_intensity': 0.0,
    }),
    'content_emotion_telemetry_status': _skippedStatus({
      'sentiment_avg': 0.0,
      'emoji_density': 0.0,
      'consistency_score': 0.0,
      'entries': 0,
    }),
    'content_auto_fixer_status': _skippedStatus({
      'fixed_total': 0,
      'issues_remaining': 0,
    }),
    'content_beta_audit_status': _skippedStatus({
      'files': 0,
      'entries': 0,
      'invalid_schema': 0,
      'empty_goals': 0,
      'empty_reactions': 0,
      'parse_errors': 0,
    }),
    'content_xp_calibrator_status': _skippedStatus({'fixed': 0, 'checked': 0}),
    'content_tone_tuner_status': _skippedStatus({
      'rephrased': 0,
      'checked': 0,
      'top_shift': 'none',
    }),
    'content_integrity_audit_v2_status': _skippedStatus({}),
    'content_consistency_status': _skippedStatus({
      'duplicates': 0,
      'deprecated': 0,
      'broken': 0,
    }),
    'content_semantic_status': _skippedStatus({
      'collisions': 0,
      'ambiguous': 0,
    }),
    'content_drift_forecast_status': _skippedStatus({
      'risk': 0.0,
      'trend': 'skipped',
    }),
    'content_drift_feedback_status': _skippedStatus({'alerts': 0}),
    'content_remediation_status': _skippedStatus({
      'suggested': 0,
      'applied': 0,
    }),
    'content_evolution_pipeline_status': _skippedStatus({'stages': 0}),
  };
}

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

Future<Map<String, dynamic>> _checkContentIdAutofixStatus() async {
  try {
    final proc = await _safeRunTool(['run', 'tools/content_id_autofix.dart']);
    final summary = _parseLastJsonLine(proc.stdout);
    final fixed = (summary['fixed'] as num?)?.toInt() ?? 0;
    final total = (summary['total'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{'fixed': fixed, 'total': total, 'pass': pass};
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {'fixed': 0, 'total': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentSchemaUpgradeStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_schema_upgrade.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final upgraded = (summary['upgraded'] as num?)?.toInt() ?? 0;
    final skipped = (summary['skipped'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'upgraded': upgraded,
      'skipped': skipped,
      'pass': pass,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {'upgraded': 0, 'skipped': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentAutoEnricherStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_auto_enricher.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final checked = (summary['checked'] as num?)?.toInt() ?? 0;
    final fixed = (summary['fixed'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'checked': checked,
      'fixed': fixed,
      'pass': pass,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {'checked': 0, 'fixed': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentFlowAuditStatus() async {
  try {
    final proc = await _safeRunTool(['run', 'tools/content_flow_audit.dart']);
    final reportFile = File('tools/_reports/content_flow_audit.json');
    Map<String, dynamic> data = {};
    if (reportFile.existsSync()) {
      final raw = reportFile.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    }
    final pass = (data['pass'] == true) && proc.exitCode == 0;
    return {...data, 'pass': pass};
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentSemanticAuditStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_semantic_audit.dart',
    ]);
    final reportFile = File('tools/_reports/content_semantic_audit.json');
    Map<String, dynamic> data = {};
    if (reportFile.existsSync()) {
      final raw = reportFile.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    }
    final pass = (data['pass'] == true) && proc.exitCode == 0;
    return {...data, 'pass': pass};
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentSemanticAutofixStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_semantic_autofix.dart',
    ]);
    final reportFile = File('tools/_reports/content_semantic_autofix.json');
    Map<String, dynamic> data = {};
    if (reportFile.existsSync()) {
      final raw = reportFile.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    }
    final pass = (data['pass'] == true) && proc.exitCode == 0;
    return {...data, 'pass': pass};
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentCiPublisherStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_ci_auto_publisher.dart',
    ]);
    final reportFile = File('tools/_reports/content_publish_summary.json');
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

Future<Map<String, dynamic>> _checkContentThemeBinderStatus() async {
  try {
    final proc = await _safeRunTool(['run', 'tools/content_theme_binder.dart']);
    final summary = _parseLastJsonLine(proc.stdout);
    final checked = (summary['checked'] as num?)?.toInt() ?? 0;
    final fixed = (summary['fixed'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'checked': checked,
      'fixed': fixed,
      'pass': pass,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {'checked': 0, 'fixed': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentNarrativeBinderStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_narrative_binder.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final added = (summary['added_transitions'] as num?)?.toInt() ?? 0;
    final linked = (summary['linked_modules'] as num?)?.toInt() ?? 0;
    final contextualized = (summary['contextualized'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'added_transitions': added,
      'linked_modules': linked,
      'contextualized': contextualized,
      'pass': pass,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {
      'added_transitions': 0,
      'linked_modules': 0,
      'contextualized': 0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkContentPersonaHarmonizerStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_persona_harmonizer.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final entries = (summary['entries'] as num?)?.toInt() ?? 0;
    final harmonized = (summary['harmonized_count'] as num?)?.toInt() ?? 0;
    final toneScore = (summary['tone_score'] as num?)?.toDouble() ?? 0.0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'entries': entries,
      'harmonized_count': harmonized,
      'tone_score': toneScore,
      'pass': pass,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {
      'entries': 0,
      'harmonized_count': 0,
      'tone_score': 0.0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkContentEmotionTunerStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_emotion_tuner.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final entries = (summary['entries'] as num?)?.toInt() ?? 0;
    final shifts = (summary['emotional_shifts'] as num?)?.toInt() ?? 0;
    final engagement = (summary['engagement_score'] as num?)?.toDouble() ?? 0.0;
    final intensity = (summary['average_intensity'] as num?)?.toDouble() ?? 0.0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'entries': entries,
      'emotional_shifts': shifts,
      'engagement_score': engagement,
      'average_intensity': intensity,
      'pass': pass,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {
      'entries': 0,
      'emotional_shifts': 0,
      'engagement_score': 0.0,
      'average_intensity': 0.0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkContentEmotionTelemetryStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_emotion_telemetry.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final alerts = (summary['alerts'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'alerts': alerts, 'pass': pass};
  } catch (e) {
    return {'alerts': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentAutoFixerStatus() async {
  try {
    final proc = await _safeRunTool(['run', 'tools/content_auto_fixer.dart']);
    final summary = _parseLastJsonLine(proc.stdout);
    final fixedTotal = (summary['fixed_total'] as num?)?.toInt() ?? 0;
    final issues = (summary['issues_remaining'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'fixed_total': fixedTotal,
      'issues_remaining': issues,
      'pass': pass,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {
      'fixed_total': 0,
      'issues_remaining': 0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkContentBetaAuditStatus() async {
  try {
    final proc = await _safeRunTool(['run', 'tools/content_beta_audit.dart']);
    final summary = _parseLastJsonLine(proc.stdout);
    final files = (summary['files'] as num?)?.toInt() ?? 0;
    final entries = (summary['entries'] as num?)?.toInt() ?? 0;
    final invalid = (summary['invalid_schema'] as num?)?.toInt() ?? 0;
    final emptyGoals = (summary['empty_goals'] as num?)?.toInt() ?? 0;
    final emptyReactions = (summary['empty_reactions'] as num?)?.toInt() ?? 0;
    final parseErrors = (summary['parse_errors'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'files': files,
      'entries': entries,
      'invalid_schema': invalid,
      'empty_goals': emptyGoals,
      'empty_reactions': emptyReactions,
      'parse_errors': parseErrors,
      'pass': pass,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {
      'files': 0,
      'entries': 0,
      'invalid_schema': 0,
      'empty_goals': 0,
      'empty_reactions': 0,
      'parse_errors': 0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkContentXpCalibratorStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_xp_calibrator.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final recalibrations = (summary['recalibrations'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'recalibrations': recalibrations, 'pass': pass};
  } catch (e) {
    return {'recalibrations': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentToneTunerStatus() async {
  try {
    final proc = await _safeRunTool(['run', 'tools/content_tone_tuner.dart']);
    final summary = _parseLastJsonLine(proc.stdout);
    final tonesCovered = (summary['tones_covered'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'tones_covered': tonesCovered, 'pass': pass};
  } catch (e) {
    return {'tones_covered': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentIntegrityAuditV2Status() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_integrity_audit_v2.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final checked = (summary['checked'] as num?)?.toInt() ?? 0;
    final fixed = (summary['fixed'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    final map = <String, Object>{
      'checked': checked,
      'fixed': fixed,
      'pass': pass,
      'duplicates': (summary['duplicates'] as num?)?.toInt() ?? 0,
      'xp_mismatches': (summary['xp_mismatches'] as num?)?.toInt() ?? 0,
      'reference_issues': (summary['reference_issues'] as num?)?.toInt() ?? 0,
      'drill_issues': (summary['drill_issues'] as num?)?.toInt() ?? 0,
    };
    if (summary['error'] is String) {
      map['error'] = summary['error'] as Object;
    }
    return map;
  } catch (e) {
    return {'checked': 0, 'fixed': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentConsistencyStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_consistency_audit.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final duplicates = (summary['duplicates'] as num?)?.toInt() ?? 0;
    final deprecated = (summary['deprecated'] as num?)?.toInt() ?? 0;
    final broken = (summary['broken'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {
      'duplicates': duplicates,
      'deprecated': deprecated,
      'broken': broken,
      'pass': pass,
    };
  } catch (e) {
    return {
      'duplicates': 0,
      'deprecated': 0,
      'broken': 0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkContentSemanticStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_semantic_audit.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final collisions = (summary['collisions'] as num?)?.toInt() ?? 0;
    final ambiguous = (summary['ambiguous'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'collisions': collisions, 'ambiguous': ambiguous, 'pass': pass};
  } catch (e) {
    return {
      'collisions': 0,
      'ambiguous': 0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkContentDriftForecastStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_drift_forecast.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final risk = (summary['risk'] as num?)?.toDouble() ?? 0.0;
    final trend = summary['trend'] ?? 'stable';
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'risk': risk, 'trend': trend, 'pass': pass};
  } catch (e) {
    return {
      'risk': 0.0,
      'trend': 'error',
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkContentDriftFeedbackStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_drift_feedback.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final alerts = (summary['alerts'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'alerts': alerts, 'pass': pass};
  } catch (e) {
    return {'alerts': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentRemediationStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_remediation_engine.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final suggested = (summary['suggested'] as num?)?.toInt() ?? 0;
    final applied = (summary['applied'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'suggested': suggested, 'applied': applied, 'pass': pass};
  } catch (e) {
    return {'suggested': 0, 'applied': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkContentEvolutionPipelineStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/content_evolution_pipeline.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final stages = (summary['stages'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'stages': stages, 'pass': pass};
  } catch (e) {
    return {'stages': 0, 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> runAllChecks() async {
  if (_shouldSkipContentChecks()) {
    return _buildSkippedSummary();
  }
  final summary = <String, dynamic>{};
  summary['content_id_autofix_status'] = await _checkContentIdAutofixStatus();
  summary['content_schema_upgrade_status'] =
      await _checkContentSchemaUpgradeStatus();
  summary['content_auto_enricher_status'] =
      await _checkContentAutoEnricherStatus();
  summary['content_flow_audit_status'] = await _checkContentFlowAuditStatus();
  summary['content_semantic_audit_status'] =
      await _checkContentSemanticAuditStatus();
  summary['content_semantic_autofix_status'] =
      await _checkContentSemanticAutofixStatus();
  summary['content_ci_publisher_status'] =
      await _checkContentCiPublisherStatus();
  summary['content_theme_binder_status'] =
      await _checkContentThemeBinderStatus();
  summary['content_narrative_binder_status'] =
      await _checkContentNarrativeBinderStatus();
  summary['content_persona_harmonizer_status'] =
      await _checkContentPersonaHarmonizerStatus();
  summary['content_emotion_tuner_status'] =
      await _checkContentEmotionTunerStatus();
  summary['content_emotion_telemetry_status'] =
      await _checkContentEmotionTelemetryStatus();
  summary['content_auto_fixer_status'] = await _checkContentAutoFixerStatus();
  summary['content_beta_audit_status'] = await _checkContentBetaAuditStatus();
  summary['content_xp_calibrator_status'] =
      await _checkContentXpCalibratorStatus();
  summary['content_tone_tuner_status'] = await _checkContentToneTunerStatus();
  summary['content_integrity_audit_v2_status'] =
      await _checkContentIntegrityAuditV2Status();
  summary['content_consistency_status'] =
      await _checkContentConsistencyStatus();
  summary['content_semantic_status'] = await _checkContentSemanticStatus();
  summary['content_drift_forecast_status'] =
      await _checkContentDriftForecastStatus();
  summary['content_drift_feedback_status'] =
      await _checkContentDriftFeedbackStatus();
  summary['content_remediation_status'] =
      await _checkContentRemediationStatus();
  summary['content_evolution_pipeline_status'] =
      await _checkContentEvolutionPipelineStatus();
  return summary;
}
