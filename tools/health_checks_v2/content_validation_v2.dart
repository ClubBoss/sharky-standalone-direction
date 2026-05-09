import 'dart:io';

import '../content_validator.dart' as legacy_validator;

Future<Map<String, dynamic>> runContentValidationV2({
  required Future<Map<String, dynamic>> Function(
    String label,
    Future<Map<String, dynamic>> Function(),
  )
  safeWrap,
  required Map<String, dynamic>? Function(String path) readJsonCached,
}) async {
  Future<Map<String, dynamic>> _runValidator() async {
    try {
      final result = await legacy_validator.validateContent();
      return Map<String, dynamic>.from(result);
    } catch (_) {
      return _runFallback();
    }
  }

  final validation = await safeWrap('content_validation', _runValidator);
  final contentValidation = Map<String, dynamic>.from(validation);

  // Warm cache for downstream lookups if the report exists.
  readJsonCached('tools/_reports/content_validation.json');

  final coverageRaw = contentValidation['xp_coverage'];
  int xpTagged = 0;
  int xpTotal = 0;
  if (coverageRaw is Map) {
    xpTagged = (coverageRaw['xpTagged'] as num?)?.toInt() ?? 0;
    xpTotal = (coverageRaw['totalSpots'] as num?)?.toInt() ?? 0;
  }

  final difficultyRaw = contentValidation['xp_difficulty'];
  double diffAvg = 0.0;
  int diffCount = 0;
  bool diffPass = false;
  if (difficultyRaw is Map) {
    diffAvg = (difficultyRaw['avg'] as num?)?.toDouble() ?? 0.0;
    diffCount = (difficultyRaw['count'] as num?)?.toInt() ?? 0;
    diffPass = difficultyRaw['pass'] == true;
  }

  final coverage = <String, Object>{
    'tagged': xpTagged,
    'total': xpTotal,
    'pass': xpTotal > 0 && xpTagged == xpTotal,
  };

  final difficultyBalance = <String, Object>{
    'avg': diffAvg,
    'count': diffCount,
    'pass': diffPass,
  };

  return {
    'content_validation': contentValidation,
    'content_xp_coverage': coverage,
    'xp_difficulty_balance': difficultyBalance,
  };
}

Future<Map<String, dynamic>> _runFallback() async {
  try {
    final proc = await Process.run('dart', [
      'run',
      'tools/validate_training_content.dart',
      '--ci',
    ]);
    final ok = proc.exitCode == 0;
    return {
      'valid': ok ? 0 : 0,
      'total': 0,
      'errors': ok ? <String>[] : <String>['content validation failed'],
    };
  } catch (e) {
    return {
      'valid': 0,
      'total': 0,
      'errors': <String>['$e'],
    };
  }
}
