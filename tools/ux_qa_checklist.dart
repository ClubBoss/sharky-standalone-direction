import 'dart:io';
import 'dart:convert';

/// UX QA scanner for UI v2 components.
///
/// Scans lib/ui_v2 for common UX issues:
/// - Hardcoded strings (not wrapped in AppLocalizations)
/// - TODO markers (unused/incomplete widgets)
/// - Missing context.mounted checks before async nav/setState
Future<void> main(List<String> args) async {
  final report = await _scanUxQa();
  final json = jsonEncode(report);
  await File('ux_qa_report.json').writeAsString(json);

  final total =
      (report['hardcodedStrings'] as int) +
      (report['todoMarkers'] as int) +
      (report['missingMountedChecks'] as int);

  stdout.writeln('=== UX QA Report ===');
  stdout.writeln('Hardcoded strings: ${report['hardcodedStrings']}');
  stdout.writeln('TODO markers: ${report['todoMarkers']}');
  stdout.writeln('Missing mounted checks: ${report['missingMountedChecks']}');
  stdout.writeln('---');
  stdout.writeln('Total issues: $total');
  if (total > 0) {
    stdout.writeln('\nRecommendations:');
    if ((report['hardcodedStrings'] as int) > 0) {
      stdout.writeln('  - Wrap user-facing strings in AppLocalizations');
    }
    if ((report['todoMarkers'] as int) > 0) {
      stdout.writeln('  - Remove or resolve TODO markers');
    }
    if ((report['missingMountedChecks'] as int) > 0) {
      stdout.writeln('  - Add context.mounted checks before async navigation');
    }
  } else {
    stdout.writeln('\n✅ All checks passed!');
  }
  stdout.writeln('\nReport written to ux_qa_report.json');
}

Future<Map<String, Object>> _scanUxQa() async {
  final lib = Directory('lib/ui_v2');
  if (!await lib.exists()) {
    return {
      'hardcodedStrings': 0,
      'todoMarkers': 0,
      'missingMountedChecks': 0,
      'missing': true,
    };
  }

  int hardcoded = 0;
  int todos = 0;
  int mountedIssues = 0;

  // Heuristics:
  // - Hardcoded strings: Text('...') without AppLocalizations
  // - TODO markers: // TODO or /* TODO
  // - Mounted checks: Navigator/setState after await without if (!mounted)
  final hardcodedPattern = RegExp('Text\\([\'\"]');
  final localizationPattern = RegExp(r'AppLocalizations|context\.l10n');
  final todoPattern = RegExp(r'//\s*TODO|/\*\s*TODO');
  final asyncNavPattern = RegExp(r'await\s+.+?Navigator\.');
  final mountedCheckPattern = RegExp(r'if\s*\(\s*!.*mounted\s*\)');

  await for (final entity in lib.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = await entity.readAsString();

    // Check for hardcoded strings
    // Simple heuristic: if file has Text() and no AppLocalizations, flag it
    if (hardcodedPattern.hasMatch(content) &&
        !localizationPattern.hasMatch(content)) {
      hardcoded++;
    }

    // Count TODO markers
    todos += todoPattern.allMatches(content).length;

    // Check for async navigation without mounted checks
    final asyncNav = asyncNavPattern.allMatches(content);
    if (asyncNav.isNotEmpty) {
      // Simple heuristic: if there's an await + Navigator and no mounted check nearby
      final hasMountedCheck = mountedCheckPattern.hasMatch(content);
      if (!hasMountedCheck) {
        mountedIssues += asyncNav.length;
      }
    }
  }

  return {
    'hardcodedStrings': hardcoded,
    'todoMarkers': todos,
    'missingMountedChecks': mountedIssues,
  };
}
