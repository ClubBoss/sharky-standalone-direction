import 'dart:convert';
import 'dart:io';

/// Adaptive Content Feedback Loop (Stage 20A)
///
/// Adjusts difficulty_score and xp_reward in content JSONL files based on
/// actual player performance metrics from telemetry. Creates a "self-learning"
/// content system that improves with usage.
///
/// Reads:
/// - build/adaptive_learning_summary.json (performanceFactor)
/// - build/adaptive_behavior_summary.json (adjustmentFactor)
/// - content/**/*.jsonl (all training content)
///
/// Writes:
/// - build/adaptive_content_feedback/ (modified content copies)
/// - build/adaptive_content_feedback_report.json (summary stats)
///
/// Constraints:
/// - Deterministic (no randomness)
/// - Corrections limited to ±25%
/// - Never modifies original content

Future<Map<String, dynamic>> applyAdaptiveFeedback() async {
  // Read learning summary for performance factor
  double performanceFactor = 0.0;
  final learningSummaryFile = File('build/adaptive_learning_summary.json');
  if (learningSummaryFile.existsSync()) {
    try {
      final data = jsonDecode(await learningSummaryFile.readAsString());
      if (data is Map) {
        performanceFactor =
            (data['performance_factor'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (_) {}
  }

  // Read behavior summary for adjustment factor
  double adjustmentFactor = 1.0;
  final behaviorSummaryFile = File('build/adaptive_behavior_summary.json');
  if (behaviorSummaryFile.existsSync()) {
    try {
      final data = jsonDecode(await behaviorSummaryFile.readAsString());
      if (data is Map) {
        adjustmentFactor = (data['adjustment'] as num?)?.toDouble() ?? 1.0;
      }
    } catch (_) {}
  }

  // Compute correction coefficients
  // Performance factor influences difficulty adjustment
  // If performance is high (>0.7), slightly increase difficulty
  // If performance is low (<0.5), slightly decrease difficulty
  double difficultyCorrection = 1.0;
  if (performanceFactor > 0.7) {
    difficultyCorrection = 1.0 + ((performanceFactor - 0.7) * 0.5);
  } else if (performanceFactor < 0.5) {
    difficultyCorrection = 1.0 - ((0.5 - performanceFactor) * 0.5);
  }
  // Clamp to ±25% (0.75 to 1.25)
  difficultyCorrection = difficultyCorrection.clamp(0.75, 1.25);

  // Adjustment factor directly influences XP correction (already bounded)
  final xpCorrection = adjustmentFactor.clamp(0.75, 1.25);

  // Scan content directory
  final contentDir = Directory('content');
  if (!contentDir.existsSync()) {
    return {
      'pass': false,
      'error': 'content/ directory not found',
      'deltaDifficulty': 0.0,
      'deltaXp': 0.0,
      'count': 0,
    };
  }

  // Prepare output directory
  final outputDir = Directory('build/adaptive_content_feedback');
  if (outputDir.existsSync()) {
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync(recursive: true);

  // Process all JSONL files
  int spotCount = 0;
  double totalDifficultyDelta = 0.0;
  double totalXpDelta = 0.0;

  final jsonlFiles = contentDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.jsonl'));

  for (final file in jsonlFiles) {
    final lines = await file.readAsLines();
    final processedLines = <String>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        processedLines.add(line);
        continue;
      }

      try {
        final spot = jsonDecode(line) as Map<String, dynamic>;

        // Apply difficulty correction
        if (spot.containsKey('difficulty_score')) {
          final originalDifficulty =
              (spot['difficulty_score'] as num?)?.toDouble() ?? 1.0;
          final newDifficulty = (originalDifficulty * difficultyCorrection)
              .clamp(1.0, 5.0);
          final roundedDifficulty =
              (newDifficulty * 100).round() / 100; // 2 decimals
          final delta =
              ((newDifficulty - originalDifficulty) / originalDifficulty * 100)
                  .abs();
          totalDifficultyDelta += delta;
          spot['difficulty_score'] = roundedDifficulty;
        }

        // Apply XP correction
        if (spot.containsKey('xp_reward')) {
          final originalXp = (spot['xp_reward'] as num?)?.toInt() ?? 50;
          final newXp = (originalXp * xpCorrection).round().clamp(1, 999999);
          final delta = ((newXp - originalXp) / originalXp * 100).abs();
          totalXpDelta += delta;
          spot['xp_reward'] = newXp;
        }

        spotCount++;
        processedLines.add(jsonEncode(spot));
      } catch (_) {
        // If line can't be parsed, keep it unchanged
        processedLines.add(line);
      }
    }

    // Write to output directory, preserving relative path structure
    final relativePath = file.path.substring(contentDir.path.length + 1);
    final outputFile = File('${outputDir.path}/$relativePath');
    outputFile.parent.createSync(recursive: true);
    await outputFile.writeAsString(processedLines.join('\n') + '\n');
  }

  // Compute average deltas
  final avgDifficultyDelta = spotCount > 0
      ? totalDifficultyDelta / spotCount
      : 0.0;
  final avgXpDelta = spotCount > 0 ? totalXpDelta / spotCount : 0.0;

  // Write report
  final report = {
    'deltaDifficulty': double.parse(avgDifficultyDelta.toStringAsFixed(2)),
    'deltaXp': double.parse(avgXpDelta.toStringAsFixed(2)),
    'count': spotCount,
    'performanceFactor': performanceFactor,
    'adjustmentFactor': adjustmentFactor,
    'difficultyCorrection': double.parse(
      difficultyCorrection.toStringAsFixed(4),
    ),
    'xpCorrection': double.parse(xpCorrection.toStringAsFixed(4)),
    'timestamp': DateTime.now().toIso8601String(),
    'pass': true,
  };

  final reportFile = File('build/adaptive_content_feedback_report.json');
  await reportFile.writeAsString(jsonEncode(report));

  return report;
}

Future<void> main() async {
  final result = await applyAdaptiveFeedback();
  stdout.writeln(jsonEncode(result));
}
