import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

/// Adaptive Loop Engine
/// - Reads ui_metrics.json to get latest adaptive drift avgPercent
/// - Reads content/**/*.jsonl and computes new difficulty scores:
///     newDifficulty = oldDifficulty * (1 + (avgDrift/100) * 0.5)
///   clamped to [1, 5] and rounded to 2 decimals (ASCII-only)
/// - Writes a replica of content under build/adaptive_content without
///   modifying originals
/// - Writes summary to adaptive_loop_report.json
Future<Map<String, Object>> runAdaptiveLoop({
  String contentRoot = 'content',
  String replicaRoot = 'build/adaptive_content',
  String uiMetricsPath = 'ui_metrics.json',
  String reportPath = 'adaptive_loop_report.json',
}) async {
  // Read avg drift from ui_metrics.json
  final avgDrift = await _readAvgDrift(uiMetricsPath);
  // Adaptation factor (deterministic)
  final factor = 1.0 + (avgDrift / 100.0) * 0.5;

  final srcDir = Directory(contentRoot);
  if (!await srcDir.exists()) {
    final result = {
      'avgDelta': 0.0,
      'count': 0,
      'pass': true,
      'note': 'content directory not found',
    };
    await File(reportPath).writeAsString(jsonEncode(result));
    return result;
  }

  // Prepare replica root
  final replicaDir = Directory(replicaRoot);
  if (await replicaDir.exists()) {
    // Clean old replica
    await replicaDir.delete(recursive: true);
  }
  await replicaDir.create(recursive: true);

  int spotCount = 0;
  double deltaSumPct = 0.0;
  int filesProcessed = 0;
  int filesCopied = 0;

  await for (final entity in srcDir.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final relPath = entity.path
        .substring(srcDir.path.length)
        .replaceFirst(RegExp(r'^/'), '');
    final outPath = '${replicaDir.path}/$relPath';
    await Directory(File(outPath).parent.path).create(recursive: true);

    if (entity.path.endsWith('.jsonl')) {
      final lines = await entity.readAsLines();
      final outSink = File(outPath).openWrite();
      for (final raw in lines) {
        final line = raw.trimRight();
        if (line.isEmpty) {
          outSink.writeln('');
          continue;
        }
        dynamic obj;
        try {
          obj = jsonDecode(line);
        } catch (_) {
          // Write as-is if not JSON
          outSink.writeln(line);
          continue;
        }
        if (obj is Map && obj.containsKey('difficulty_score')) {
          final oldDiffNum = obj['difficulty_score'];
          if (oldDiffNum is num) {
            final oldDiff = oldDiffNum.toDouble();
            final newDiff = _round2(_clamp(oldDiff * factor, 1.0, 5.0));
            // Accumulate average delta percent
            if (oldDiff > 0) {
              final deltaPct = ((newDiff - oldDiff) / oldDiff) * 100.0;
              deltaSumPct += deltaPct;
              spotCount++;
            }
            obj['difficulty_score'] = newDiff;
          }
        }
        // Ensure ASCII-only output
        final jsonStr = jsonEncode(obj);
        final ascii = _toAscii(jsonStr);
        outSink.writeln(ascii);
      }
      await outSink.close();
      filesProcessed++;
    } else {
      // Copy other files as-is to preserve structure
      await entity.copy(outPath);
      filesCopied++;
    }
  }

  final avgDelta = spotCount > 0 ? _round2(deltaSumPct / spotCount) : 0.0;
  final summary = {
    'avgDelta': avgDelta,
    'count': spotCount,
    'filesProcessed': filesProcessed,
    'filesCopied': filesCopied,
    'driftPercentUsed': _round2(avgDrift),
    'factor': _round2(factor),
    'replicaRoot': replicaDir.path,
    'pass': true,
    'timestamp': DateTime.now().toIso8601String(),
  };

  await File(reportPath).writeAsString(jsonEncode(summary));
  return summary;
}

Future<double> _readAvgDrift(String uiMetricsPath) async {
  try {
    final f = File(uiMetricsPath);
    if (await f.exists()) {
      final raw = await f.readAsString();
      final data = jsonDecode(raw);
      if (data is Map) {
        // Prefer latest object if present
        final latest = data['adaptive_drift_latest'];
        if (latest is Map && latest['avgPercent'] is num) {
          return (latest['avgPercent'] as num).toDouble();
        }
        // Otherwise compute from history mean if available
        final hist = data['adaptive_drift_history'];
        if (hist is List && hist.isNotEmpty) {
          final vals = hist.whereType<num>().map((e) => e.toDouble()).toList();
          if (vals.isNotEmpty) {
            final sum = vals.reduce((a, b) => a + b);
            return sum / vals.length;
          }
        }
      }
    }
  } catch (_) {}
  return 0.0; // default to no drift
}

String _toAscii(String s) {
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    b.writeCharCode(c <= 127 ? c : 63); // replace non-ASCII with '?'
  }
  return b.toString();
}

double _clamp(double v, double lo, double hi) => math.min(hi, math.max(lo, v));

double _round2(double v) => double.parse(v.toStringAsFixed(2));
