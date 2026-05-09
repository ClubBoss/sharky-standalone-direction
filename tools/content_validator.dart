import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

/// Content QA validator for training pack files in content/**
/// Validates JSONL, MD, and TXT files for format, structure, and quality.
Future<Map<String, Object>> validateContent() async {
  final contentDir = Directory('content');
  if (!await contentDir.exists()) {
    return {
      'valid': 0,
      'total': 0,
      'errors': ['content/ directory not found'],
    };
  }

  int valid = 0;
  int total = 0;
  int xpTaggedTotal = 0;
  int xpSpotTotal = 0;
  double diffSum = 0.0;
  int diffCount = 0;
  final errors = <String>[];
  final files = <String, Map<String, Object>>{};

  await for (final entity in contentDir.list(recursive: true)) {
    if (entity is! File) continue;

    final path = entity.path;
    if (path.endsWith('.jsonl')) {
      total++;
      final validation = await _validateJsonl(entity);
      if (validation['valid'] == true) {
        valid++;
      } else {
        errors.add('$path: ${validation['error']}');
      }
      // Accumulate XP coverage across JSONL content
      final spots = (validation['spots'] as num?)?.toInt() ?? 0;
      final tagged = (validation['xpTagged'] as num?)?.toInt() ?? 0;
      xpSpotTotal += spots;
      xpTaggedTotal += tagged;
      // Accumulate difficulty stats
      final dSum = (validation['difficultySum'] as num?)?.toDouble() ?? 0.0;
      final dCnt = (validation['difficultyCount'] as num?)?.toInt() ?? 0;
      diffSum += dSum;
      diffCount += dCnt;
      files[path] = validation;
    } else if (path.endsWith('.md') || path.endsWith('.txt')) {
      total++;
      final validation = await _validateTextFile(entity);
      if (validation['valid'] == true) {
        valid++;
      } else {
        errors.add('$path: ${validation['error']}');
      }
      files[path] = validation;
    }
  }

  return {
    'valid': valid,
    'total': total,
    'errors': errors,
    'files': files,
    'xp_coverage': {'xpTagged': xpTaggedTotal, 'totalSpots': xpSpotTotal},
    'xp_difficulty': {
      'avg': diffCount > 0
          ? double.parse((diffSum / diffCount).toStringAsFixed(2))
          : 0.0,
      'count': diffCount,
      'pass': diffCount > 0 && diffCount == xpSpotTotal,
    },
  };
}

/// Validate JSONL file: ASCII-only, valid JSON per line, required fields
Future<Map<String, Object>> _validateJsonl(File file) async {
  try {
    final content = await file.readAsString();

    // Check ASCII-only
    if (!_isAsciiOnly(content)) {
      return {'valid': false, 'error': 'Non-ASCII characters detected'};
    }

    final lines = const LineSplitter().convert(content);
    int lineNum = 0;
    int validSpots = 0;
    int xpTagged = 0;
    double difficultySum = 0.0;
    int difficultyCount = 0;

    for (final line in lines) {
      lineNum++;
      if (line.trim().isEmpty) continue;

      // Parse JSON
      dynamic obj;
      try {
        obj = jsonDecode(line);
      } catch (e) {
        return {
          'valid': false,
          'error':
              'Invalid JSON at line $lineNum: ${e.toString().split('\n').first}',
        };
      }

      // Check required fields for drill spots
      if (obj is Map) {
        if (!obj.containsKey('id')) {
          return {
            'valid': false,
            'error': 'Missing "id" field at line $lineNum',
          };
        }
        if (!obj.containsKey('spot_kind')) {
          return {
            'valid': false,
            'error': 'Missing "spot_kind" field at line $lineNum',
          };
        }

        // Validate spot_kind is non-empty
        final spotKind = obj['spot_kind'];
        if (spotKind == null || spotKind.toString().trim().isEmpty) {
          return {'valid': false, 'error': 'Empty spot_kind at line $lineNum'};
        }

        // xp_reward presence check
        if (!obj.containsKey('xp_reward')) {
          return {
            'valid': false,
            'error': 'Missing "xp_reward" field at line $lineNum',
          };
        }
        final xp = obj['xp_reward'];
        if (xp is! num || xp <= 0) {
          return {
            'valid': false,
            'error': 'Invalid xp_reward at line $lineNum (must be > 0)',
          };
        }

        // difficulty_score presence and correlation check
        if (!obj.containsKey('difficulty_score')) {
          return {
            'valid': false,
            'error': 'Missing "difficulty_score" field at line $lineNum',
          };
        }
        final diff = obj['difficulty_score'];
        if (diff is! num) {
          return {
            'valid': false,
            'error':
                'Invalid difficulty_score at line $lineNum (must be number 1..5)',
          };
        }
        final d = diff.toDouble();
        if (d < 1.0 || d > 5.0) {
          return {
            'valid': false,
            'error':
                'Invalid difficulty_score at line $lineNum (out of range 1..5)',
          };
        }
        final expectedRaw = math.log((xp).toDouble() / 50.0);
        final expected = expectedRaw.clamp(1.0, 5.0);
        final expectedRounded = double.parse(expected.toStringAsFixed(2));
        if ((d - expectedRounded).abs() > 0.01) {
          return {
            'valid': false,
            'error':
                'difficulty_score mismatch with xp_reward at line $lineNum (got $d, expected ~$expectedRounded)',
          };
        }

        validSpots++;
        xpTagged++;
        difficultySum += d;
        difficultyCount++;
      }
    }

    if (validSpots == 0) {
      return {'valid': false, 'error': 'No valid spot entries found'};
    }

    return {
      'valid': true,
      'spots': validSpots,
      'xpTagged': xpTagged,
      'difficultySum': difficultySum,
      'difficultyCount': difficultyCount,
    };
  } catch (e) {
    return {'valid': false, 'error': 'File read error: ${e.toString()}'};
  }
}

/// Validate text file (MD/TXT): ASCII-only, non-empty
Future<Map<String, Object>> _validateTextFile(File file) async {
  try {
    final content = await file.readAsString();

    // Check ASCII-only
    if (!_isAsciiOnly(content)) {
      return {'valid': false, 'error': 'Non-ASCII characters detected'};
    }

    // Check non-empty
    if (content.trim().isEmpty) {
      return {'valid': false, 'error': 'File is empty'};
    }

    // Check reasonable size (not suspiciously small)
    if (content.length < 50) {
      return {'valid': false, 'error': 'File too short (< 50 chars)'};
    }

    return {'valid': true, 'length': content.length};
  } catch (e) {
    return {'valid': false, 'error': 'File read error: ${e.toString()}'};
  }
}

/// Check if string contains only ASCII characters
bool _isAsciiOnly(String str) {
  for (int i = 0; i < str.length; i++) {
    if (str.codeUnitAt(i) > 127) return false;
  }
  return true;
}

Future<void> main(List<String> args) async {
  final results = await validateContent();

  stdout.writeln('Content Validation Report');
  stdout.writeln('========================');
  stdout.writeln('Valid: ${results['valid']}/${results['total']}');

  final errors = results['errors'] as List;
  if (errors.isNotEmpty) {
    stdout.writeln('\nErrors:');
    for (final error in errors) {
      stdout.writeln('  - $error');
    }
    exitCode = 1;
  } else {
    stdout.writeln('All content files passed validation ✅');
  }

  if (args.contains('--json')) {
    stdout.writeln('\n${jsonEncode(results)}');
  }
}
