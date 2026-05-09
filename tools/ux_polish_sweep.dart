import 'dart:io';
import 'dart:convert';

/// Stage D2 UX Final Polish Sweep
/// Scans lib/ui_v3/** for raw padding/margin/duration/color values
/// and validates they use VisualThemeV3 tokens.

void main() async {
  print('=== UX POLISH SWEEP (Stage D2) ===\n');

  final auditor = UxPolishAuditor();
  await auditor.scan();
  auditor.printSummary();
  await auditor.writeReport();
  await auditor.emitTelemetry();

  print('\n=== SWEEP COMPLETE ===');
  exit(0);
}

class UxPolishAuditor {
  final List<FileIssue> _issues = [];
  final Map<String, int> _screenWarnings = {};
  int _filesScanned = 0;
  int _totalWarnings = 0;

  Future<void> scan() async {
    print('[Scan] Starting UI v3 scan...\n');

    final uiV3Dir = Directory('lib/ui_v3');
    if (!await uiV3Dir.exists()) {
      print('[ERROR] lib/ui_v3 directory not found');
      return;
    }

    await for (final entity in uiV3Dir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File && entity.path.endsWith('.dart')) {
        await _scanFile(entity);
      }
    }

    print('[Scan] Scanned $_filesScanned files\n');
  }

  Future<void> _scanFile(File file) async {
    _filesScanned++;

    final lines = await file.readAsLines();
    final relativePath = file.path.replaceFirst(
      RegExp(r'^.*lib/ui_v3/'),
      'lib/ui_v3/',
    );

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNum = i + 1;

      // Skip comments and imports
      if (line.trim().startsWith('//') ||
          line.trim().startsWith('import ') ||
          line.trim().startsWith('* ')) {
        continue;
      }

      // Check for raw padding/margin values
      _checkPaddingMargin(line, relativePath, lineNum);

      // Check for raw duration values
      _checkDuration(line, relativePath, lineNum);

      // Check for raw color values
      _checkColor(line, relativePath, lineNum);

      // Check for raw double literals (spacing candidates)
      _checkSpacing(line, relativePath, lineNum);
    }

    final warningCount = _issues.where((i) => i.file == relativePath).length;
    if (warningCount > 0) {
      _screenWarnings[relativePath] = warningCount;
      _totalWarnings += warningCount;
    }
  }

  void _checkPaddingMargin(String line, String file, int lineNum) {
    // EdgeInsets.all(8.0) -> should use VisualThemeV3.spacingS
    final allPattern = RegExp(r'EdgeInsets\.all\((\d+(?:\.\d+)?)\)');
    final allMatch = allPattern.firstMatch(line);
    if (allMatch != null) {
      final value = allMatch.group(1);
      if (!_isTokenReference(line)) {
        _addIssue(
          file,
          lineNum,
          'RAW_PADDING',
          'EdgeInsets.all($value) -> use VisualThemeV3.spacingXS/S/M/L/XL',
          line.trim(),
        );
      }
    }

    // EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
    final symmetricPattern = RegExp(
      r'EdgeInsets\.symmetric\([^)]*(?:horizontal|vertical):\s*(\d+(?:\.\d+)?)[^)]*\)',
    );
    if (symmetricPattern.hasMatch(line) && !_isTokenReference(line)) {
      _addIssue(
        file,
        lineNum,
        'RAW_PADDING',
        'EdgeInsets.symmetric with raw values -> use VisualThemeV3.spacing*',
        line.trim(),
      );
    }

    // EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5)
    final onlyPattern = RegExp(
      r'EdgeInsets\.only\([^)]*(?:left|right|top|bottom):\s*(\d+(?:\.\d+)?)[^)]*\)',
    );
    if (onlyPattern.hasMatch(line) && !_isTokenReference(line)) {
      _addIssue(
        file,
        lineNum,
        'RAW_PADDING',
        'EdgeInsets.only with raw values -> use VisualThemeV3.spacing*',
        line.trim(),
      );
    }

    // Padding(padding: EdgeInsets.all(12.0))
    if (line.contains('Padding(') &&
        line.contains('EdgeInsets.') &&
        !_isTokenReference(line)) {
      final paddingMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(line);
      if (paddingMatch != null) {
        _addIssue(
          file,
          lineNum,
          'RAW_PADDING',
          'Padding widget with raw value -> use VisualThemeV3.spacing*',
          line.trim(),
        );
      }
    }
  }

  void _checkDuration(String line, String file, int lineNum) {
    // Duration(milliseconds: 200) -> should use VisualThemeV3.speedFast/Normal/Slow
    final durationPattern = RegExp(r'Duration\(milliseconds:\s*(\d+)\)');
    final durationMatch = durationPattern.firstMatch(line);
    if (durationMatch != null) {
      final ms = int.parse(durationMatch.group(1)!);
      if (!_isTokenReference(line)) {
        String suggestion = 'VisualThemeV3.speedNormal';
        if (ms <= 150) {
          suggestion = 'VisualThemeV3.speedFast';
        } else if (ms >= 250) {
          suggestion = 'VisualThemeV3.speedSlow';
        } else if (ms <= 180) {
          suggestion = 'VisualThemeV3.motionFast';
        } else if (ms <= 260) {
          suggestion = 'VisualThemeV3.motionMedium';
        } else if (ms <= 420) {
          suggestion = 'VisualThemeV3.motionSlow';
        }

        _addIssue(
          file,
          lineNum,
          'RAW_DURATION',
          'Duration(milliseconds: $ms) -> use $suggestion',
          line.trim(),
        );
      }
    }
  }

  void _checkColor(String line, String file, int lineNum) {
    // Color(0xFFFFFFFF) -> should use VisualThemeV3.primary/success/danger/warning
    final colorPattern = RegExp(r'Color\((0x[0-9A-Fa-f]{8})\)');
    final colorMatch = colorPattern.firstMatch(line);
    if (colorMatch != null) {
      if (!_isTokenReference(line) &&
          !line.contains('VisualThemeV3.') &&
          !line.contains('Theme.of(context)') &&
          !line.contains('ColorScheme.') &&
          !line.contains('Colors.transparent') &&
          !line.contains('.withValues(') &&
          !line.contains('// legacy') &&
          !line.contains('// exception')) {
        final hex = colorMatch.group(1);
        _addIssue(
          file,
          lineNum,
          'RAW_COLOR',
          'Color($hex) -> use VisualThemeV3.primary/success/danger/warning or Theme.of(context).colorScheme',
          line.trim(),
        );
      }
    }

    // Colors.blue -> should use theme tokens
    final colorsPattern = RegExp(
      r'Colors\.(blue|red|green|orange|grey|yellow|purple|teal|cyan|amber|lime|indigo|pink)(?!\.)',
    );
    if (colorsPattern.hasMatch(line) &&
        !line.contains('Colors.white') &&
        !line.contains('Colors.black') &&
        !line.contains('Colors.transparent') &&
        !_isTokenReference(line) &&
        !line.contains('// exception')) {
      _addIssue(
        file,
        lineNum,
        'RAW_COLOR',
        'Colors.* -> use VisualThemeV3.primary/success/danger/warning or Theme.of(context).colorScheme',
        line.trim(),
      );
    }
  }

  void _checkSpacing(String line, String file, int lineNum) {
    // SizedBox(height: 16.0) -> should use VisualThemeV3.spacingM
    final sizedBoxPattern = RegExp(
      r'SizedBox\((?:width|height):\s*(\d+(?:\.\d+)?)\)',
    );
    final sizedBoxMatch = sizedBoxPattern.firstMatch(line);
    if (sizedBoxMatch != null) {
      final value = double.parse(sizedBoxMatch.group(1)!);
      if (!_isTokenReference(line) && _isSpacingValue(value)) {
        final suggestion = _getSpacingSuggestion(value);
        _addIssue(
          file,
          lineNum,
          'RAW_SPACING',
          'SizedBox with raw value $value -> use $suggestion',
          line.trim(),
        );
      }
    }

    // Container(width: 24.0, height: 24.0)
    final containerSizePattern = RegExp(
      r'Container\([^)]*(?:width|height):\s*(\d+(?:\.\d+)?)[^)]*\)',
    );
    if (containerSizePattern.hasMatch(line) && !_isTokenReference(line)) {
      final matches = RegExp(r'(\d+(?:\.\d+)?)').allMatches(line);
      for (final match in matches) {
        final value = double.tryParse(match.group(1)!);
        if (value != null && _isSpacingValue(value)) {
          final suggestion = _getSpacingSuggestion(value);
          _addIssue(
            file,
            lineNum,
            'RAW_SPACING',
            'Container size with raw value $value -> consider $suggestion',
            line.trim(),
          );
          break; // Only report once per line
        }
      }
    }
  }

  bool _isTokenReference(String line) {
    return line.contains('VisualThemeV3.') ||
        line.contains('Theme.of(context)') ||
        line.contains('ColorScheme.') ||
        line.contains('ThemeData.') ||
        line.contains('TextTheme.');
  }

  bool _isSpacingValue(double value) {
    // Check if value matches spacing token values
    return value == 4.0 ||
        value == 8.0 ||
        value == 12.0 ||
        value == 16.0 ||
        value == 24.0 ||
        value == 32.0;
  }

  String _getSpacingSuggestion(double value) {
    if (value == 4.0) return 'VisualThemeV3.spacingXS';
    if (value == 8.0) return 'VisualThemeV3.spacingS';
    if (value == 12.0) return 'VisualThemeV3.spacingSM';
    if (value == 16.0) return 'VisualThemeV3.spacingM';
    if (value == 24.0) return 'VisualThemeV3.spacingL';
    if (value == 32.0) return 'VisualThemeV3.spacingXL';
    return 'VisualThemeV3.spacing*';
  }

  void _addIssue(
    String file,
    int lineNum,
    String type,
    String message,
    String codeLine,
  ) {
    _issues.add(
      FileIssue(
        file: file,
        line: lineNum,
        type: type,
        message: message,
        code: codeLine,
      ),
    );
  }

  void printSummary() {
    print('--- ASCII SUMMARY ---\n');

    if (_screenWarnings.isEmpty) {
      print('[PASS] All screens use VisualThemeV3 tokens correctly!');
      print('[PASS] $_filesScanned files scanned, 0 warnings');
      return;
    }

    print(
      '[WARN] Found $_totalWarnings warnings across ${_screenWarnings.length} files:\n',
    );

    final sortedScreens = _screenWarnings.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedScreens) {
      final status = entry.value > 5 ? 'WARN' : 'WARN';
      print('  [$status] ${entry.key}: ${entry.value} warnings');
    }

    print('\n[Stats] $_filesScanned files scanned');
    print('[Stats] ${_issues.length} total warnings');

    // Breakdown by type
    final byType = <String, int>{};
    for (final issue in _issues) {
      byType[issue.type] = (byType[issue.type] ?? 0) + 1;
    }

    print('\n[Breakdown]');
    for (final entry in byType.entries) {
      print('  ${entry.key}: ${entry.value} warnings');
    }
  }

  Future<void> writeReport() async {
    final reportsDir = Directory('release/_reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final reportFile = File('release/_reports/ux_polish_sweep.txt');
    final buffer = StringBuffer();

    buffer.writeln('=== UX POLISH SWEEP REPORT (Stage D2) ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Files scanned: $_filesScanned');
    buffer.writeln('Total warnings: $_totalWarnings');
    buffer.writeln('Screens with warnings: ${_screenWarnings.length}');
    buffer.writeln();

    if (_issues.isEmpty) {
      buffer.writeln('[PASS] All screens use VisualThemeV3 tokens correctly!');
      buffer.writeln();
      buffer.writeln('No hardcoded values found:');
      buffer.writeln(
        '  - All padding/margin uses VisualThemeV3.spacing* tokens',
      );
      buffer.writeln(
        '  - All durations use VisualThemeV3.speed* or motion* tokens',
      );
      buffer.writeln(
        '  - All colors use VisualThemeV3.* or Theme.of(context).colorScheme',
      );
    } else {
      buffer.writeln('DETAILED WARNINGS:\n');

      // Group by file
      final byFile = <String, List<FileIssue>>{};
      for (final issue in _issues) {
        byFile.putIfAbsent(issue.file, () => []).add(issue);
      }

      final sortedFiles = byFile.entries.toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length));

      for (final entry in sortedFiles) {
        buffer.writeln('--- ${entry.key} (${entry.value.length} warnings) ---');
        for (final issue in entry.value) {
          buffer.writeln(
            '  Line ${issue.line}: [${issue.type}] ${issue.message}',
          );
          buffer.writeln('    Code: ${issue.code}');
        }
        buffer.writeln();
      }

      buffer.writeln('\nRECOMMENDATIONS:\n');
      buffer.writeln(
        '1. Replace raw padding/margin with VisualThemeV3.spacing* tokens:',
      );
      buffer.writeln('   - spacingXS (4.0), spacingS (8.0), spacingSM (12.0)');
      buffer.writeln('   - spacingM (16.0), spacingL (24.0), spacingXL (32.0)');
      buffer.writeln();
      buffer.writeln(
        '2. Replace raw durations with VisualThemeV3.speed* tokens:',
      );
      buffer.writeln(
        '   - speedFast (150ms), speedNormal (200ms), speedSlow (250ms)',
      );
      buffer.writeln(
        '   - motionFast (180ms), motionMedium (260ms), motionSlow (420ms)',
      );
      buffer.writeln();
      buffer.writeln(
        '3. Replace raw colors with VisualThemeV3.* or Theme.of(context).colorScheme:',
      );
      buffer.writeln('   - primary, success, danger, warning, secondaryAccent');
      buffer.writeln('   - Theme.of(context).colorScheme.primary/surface/etc.');
      buffer.writeln();
      buffer.writeln(
        '4. Non-critical warnings (spacing values) can be addressed in follow-up sweep.',
      );
    }

    buffer.writeln('\n=== END OF REPORT ===');

    await reportFile.writeAsString(buffer.toString());
    print('\n[Report] Written to: ${reportFile.path}');
  }

  Future<void> emitTelemetry() async {
    final telemetryFile = File('release/_reports/telemetry.jsonl');
    final event = {
      'event': 'ux_polish_sweep_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'warningCount': _totalWarnings,
      'screenCount': _filesScanned,
      'screensWithWarnings': _screenWarnings.length,
      'passStatus': _totalWarnings == 0 ? 'PASS' : 'WARN',
    };

    final eventLine = jsonEncode(event);

    if (await telemetryFile.exists()) {
      await telemetryFile.writeAsString('$eventLine\n', mode: FileMode.append);
    } else {
      await telemetryFile.parent.create(recursive: true);
      await telemetryFile.writeAsString('$eventLine\n');
    }

    print('[Telemetry] Event logged: ux_polish_sweep_completed');
  }
}

class FileIssue {
  const FileIssue({
    required this.file,
    required this.line,
    required this.type,
    required this.message,
    required this.code,
  });

  final String file;
  final int line;
  final String type;
  final String message;
  final String code;
}
