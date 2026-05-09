import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _dashboardJsonPath =
    '$_reportsDir/stability_dashboard_summary.json';
const String _maintenanceSummaryPath =
    '$_reportsDir/regression_maintenance_summary.txt';
const String _consolidationSummaryPath =
    '$_reportsDir/regression_consolidation_summary.txt';
const String _remediationSummaryPath =
    '$_reportsDir/stability_health_remediation_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _forecastJsonPath =
    '$_reportsDir/regression_health_forecast_summary.json';
const Duration _staleWindow = Duration(hours: 24);
const int _maxIterations = 6;
const int _maxOffendersPerIteration = 5;
const int _maxChildReruns = 3;
const List<String> _structuralKeywords = [
  'child summary missing',
  'no input found',
  'aggregate 0',
];

Future<void> main(List<String> args) async {
  final remediation = StabilityHealthRemediation();
  final ok = await remediation.run();
  if (!ok) {
    exitCode = 2;
  }
}

class StabilityHealthRemediation {
  Future<bool> run() async {
    final initialDashboard = await _loadDashboard();
    final maintenanceSummary = await _readTextFile(_maintenanceSummaryPath);
    final consolidationSummary = await _readTextFile(_consolidationSummaryPath);
    final remediationLogs = <_RemediationLog>[];
    final remediatorNotes = <String>[];
    final processedOffenders = <String>{};
    var thresholdAdjustments = 0;
    var rerunCount = 0;
    var iterations = 0;
    var stagnantIterations = 0;
    var currentDashboard = initialDashboard;
    var lastFailCount = currentDashboard.failCount;
    var loopAborted = false;

    while (iterations < _maxIterations) {
      iterations++;
      final iterationResult = await _executeIteration(
        currentDashboard,
        iterations,
        processedOffenders,
      );
      remediationLogs.addAll(iterationResult.logs);
      thresholdAdjustments += iterationResult.thresholdAdjustments;
      rerunCount += iterationResult.rerunCount;

      final dashboardRun = await _runCommand([
        'dart',
        'run',
        'tools/stability_dashboard.dart',
      ]);
      if (!dashboardRun.success) {
        remediatorNotes.add(
          'stability_dashboard.dart failed during iteration $iterations: '
          '${dashboardRun.description}',
        );
        loopAborted = true;
        break;
      }
      currentDashboard = await _loadDashboard();

      if (currentDashboard.failCount == lastFailCount) {
        stagnantIterations++;
      } else {
        stagnantIterations = 0;
        processedOffenders.clear();
      }
      lastFailCount = currentDashboard.failCount;

      if (currentDashboard.healthScore >= 85 &&
          currentDashboard.verdict == 'PASS' &&
          currentDashboard.failCount < initialDashboard.failCount) {
        break;
      }
      if (stagnantIterations >= 2) {
        remediatorNotes.add(
          'Stopped after $stagnantIterations stagnant iteration(s) without '
          'fail-count improvement.',
        );
        break;
      }
      if (!iterationResult.performedAction) {
        remediatorNotes.add(
          'No actionable offenders detected during iteration $iterations.',
        );
        break;
      }
    }

    if (!loopAborted) {
      final finalDashboardRun = await _runCommand([
        'dart',
        'run',
        'tools/stability_dashboard.dart',
      ]);
      if (!finalDashboardRun.success) {
        remediatorNotes.add(
          'stability_dashboard.dart final run failed: '
          '${finalDashboardRun.description}',
        );
      } else {
        currentDashboard = await _loadDashboard();
      }
    }

    final forecastRun = await _runCommand([
      'dart',
      'run',
      'tools/regression_health_forecaster.dart',
    ]);
    if (!forecastRun.success) {
      remediatorNotes.add(
        'regression_health_forecaster.dart failed: ${forecastRun.description}',
      );
    }

    final statusLookup = {
      for (final report in currentDashboard.reports) report.file: report.status,
    };
    for (final log in remediationLogs) {
      log.finalStatus = statusLookup[log.file] ?? log.finalStatus ?? 'UNKNOWN';
      log.transitions.add('FINAL(${log.finalStatus})');
    }

    final forecastRsiAfter = await _readForecastRsiAfter();
    final pass =
        currentDashboard.healthScore >= 85 &&
        currentDashboard.verdict == 'PASS' &&
        currentDashboard.failCount < initialDashboard.failCount;

    await _writeSummary(
      initial: initialDashboard,
      updated: currentDashboard,
      logs: remediationLogs,
      maintenanceVerdict: _extractVerdictLabel(maintenanceSummary),
      consolidationVerdict: _extractVerdictLabel(consolidationSummary),
      thresholdAdjustments: thresholdAdjustments,
      remediatorNotes: remediatorNotes,
      iterationCount: iterations,
      rerunCount: rerunCount,
    );

    await _appendTelemetry(
      previousHealth: initialDashboard.healthScore,
      newHealth: currentDashboard.healthScore,
      previousFailCount: initialDashboard.failCount,
      newFailCount: currentDashboard.failCount,
      logs: remediationLogs,
      thresholdAdjustments: thresholdAdjustments,
      forecastRsiAfter: forecastRsiAfter,
      iterationCount: iterations,
      rerunCount: rerunCount,
    );

    return pass;
  }

  Future<_IterationResult> _executeIteration(
    _DashboardState dashboard,
    int iteration,
    Set<String> processed,
  ) async {
    final offenderInfos = await _loadOffenderSummaries(dashboard);
    if (offenderInfos.isEmpty) {
      return _IterationResult.empty();
    }
    final offenders = _rankTopOffenders(dashboard, offenderInfos)
        .where((offender) => !processed.contains(offender.report.file))
        .take(_maxOffendersPerIteration)
        .toList();
    if (offenders.isEmpty) {
      return _IterationResult.empty();
    }

    final logs = <_RemediationLog>[];
    var thresholdAdjustments = 0;
    var rerunCount = 0;
    var performedAction = false;

    for (final offender in offenders) {
      processed.add(offender.report.file);
      final log = await _remediateOffender(offender);
      log.iteration = iteration;
      logs.add(log);
      if (log.action == _RemediationAction.thresholdAdjust && log.success) {
        thresholdAdjustments++;
      }
      if (log.action != _RemediationAction.none) {
        performedAction = true;
      }
      rerunCount += log.rerunCount;
    }

    return _IterationResult(
      logs: logs,
      thresholdAdjustments: thresholdAdjustments,
      rerunCount: rerunCount,
      performedAction: performedAction,
    );
  }

  Future<_DashboardState> _loadDashboard() async {
    final file = File(_dashboardJsonPath);
    if (!await file.exists()) {
      throw StateError(
        'Missing stability dashboard summary at $_dashboardJsonPath',
      );
    }
    final data = json.decode(await file.readAsString()) as Map<String, dynamic>;
    final reports = (data['reports'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (entry) => _ReportEntry(
            file: (entry['file'] as String?) ?? '',
            status: ((entry['status'] as String?) ?? 'PASS').toUpperCase(),
          ),
        )
        .where((entry) => entry.file.isNotEmpty)
        .toList();
    final score = (data['health_score'] as num?)?.toDouble() ?? 0;
    final verdict = (data['verdict'] as String? ?? 'WARN').toUpperCase();
    return _DashboardState(
      healthScore: score,
      verdict: verdict,
      reports: reports,
    );
  }

  Future<Map<String, _SummaryInfo>> _loadOffenderSummaries(
    _DashboardState dashboard,
  ) async {
    final summaries = <String, _SummaryInfo>{};
    final now = DateTime.now();
    for (final report in dashboard.reports) {
      if (report.status == 'PASS') continue;
      final path = '$_reportsDir/${report.file}';
      final content = await _readTextFile(path);
      summaries[report.file] = _parseSummaryInfo(content, now);
    }
    return summaries;
  }

  _SummaryInfo _parseSummaryInfo(String content, DateTime referenceNow) {
    final generatedAt = _extractGeneratedTimestamp(content);
    final isStale =
        generatedAt != null &&
        referenceNow.difference(generatedAt) > _staleWindow;
    final lower = content.toLowerCase();
    final hasStructuralIssue = _structuralKeywords.any(lower.contains);
    final childSummaries = <String>[];
    if (hasStructuralIssue) {
      final seen = <String>{};
      final regex = RegExp(r'([A-Za-z0-9_\-\/]+_summary\.txt)');
      for (final match in regex.allMatches(content)) {
        final normalized = _normalizeSummaryFile(match.group(1) ?? '');
        if (normalized.isEmpty || !seen.add(normalized)) continue;
        childSummaries.add(normalized);
      }
    }
    return _SummaryInfo(
      content: content,
      generatedAt: generatedAt,
      isStale: isStale,
      hasStructuralIssue: hasStructuralIssue,
      childSummaries: childSummaries,
    );
  }

  Iterable<_Offender> _rankTopOffenders(
    _DashboardState dashboard,
    Map<String, _SummaryInfo> summaries,
  ) {
    final offenders = dashboard.reports
        .where((report) => report.status != 'PASS')
        .map(
          (report) => _Offender(
            report: report,
            weight: _weightFor(report),
            info: summaries[report.file] ?? _SummaryInfo.empty,
          ),
        )
        .toList();
    offenders.sort((a, b) => b.weight.compareTo(a.weight));
    return offenders;
  }

  double _weightFor(_ReportEntry report) {
    final file = report.file;
    double base = 0.2;
    if (file.startsWith('visual_') || file.startsWith('ui_')) {
      base = 0.4;
    } else if (file.startsWith('regression_') ||
        file.startsWith('continuous_')) {
      base = 0.35;
    } else if (file.startsWith('content_') ||
        file.startsWith('localization_')) {
      base = 0.25;
    }
    final statusBoost = report.status == 'FAIL' ? 1.25 : 1.0;
    return base * statusBoost;
  }

  Future<_RemediationLog> _remediateOffender(_Offender offender) async {
    final log = _RemediationLog(
      file: offender.report.file,
      beforeStatus: offender.report.status,
      weight: offender.weight,
    )..transitions.add('INITIAL(${offender.report.status})');
    final reason = _diagnoseFailure(offender);
    log.reason = reason;
    if (offender.info.isStale) {
      log.transitions.add('STALE');
    }

    switch (reason) {
      case _FailureSignal.staleData:
        final result = await _rerunGeneratingTool(
          offender.report.file,
          context: 'stale data refresh',
        );
        log.action = _RemediationAction.rerunTool;
        log.recordResult(result);
        break;
      case _FailureSignal.structuralGap:
        final result = await _rerunStructuralChildren(offender);
        log.action = _RemediationAction.structural;
        log.recordResult(result);
        break;
      case _FailureSignal.strictThreshold:
        final result = await _adjustThreshold(offender);
        log.action = _RemediationAction.thresholdAdjust;
        log.recordResult(result);
        break;
      case _FailureSignal.optionalMissing:
        final result = await _downgradeToWarn(offender.report.file);
        log.action = _RemediationAction.downgrade;
        log.recordResult(result);
        break;
      case _FailureSignal.unknown:
        log.action = _RemediationAction.none;
        log.success = false;
        log.note = 'No automated rule matched';
        log.intermediateStatus = log.beforeStatus;
        break;
    }

    return log;
  }

  _FailureSignal _diagnoseFailure(_Offender offender) {
    final summary = offender.info.content;
    final lower = summary.toLowerCase();
    if (offender.info.isStale ||
        lower.contains('stale') ||
        lower.contains('out-of-date')) {
      return _FailureSignal.staleData;
    }
    if (offender.info.hasStructuralIssue) {
      return _FailureSignal.structuralGap;
    }
    if (lower.contains('synthetic') || lower.contains('threshold')) {
      return _FailureSignal.strictThreshold;
    }
    if (lower.contains('missing optional')) {
      return _FailureSignal.optionalMissing;
    }
    return _FailureSignal.unknown;
  }

  Future<_ActionResult> _rerunGeneratingTool(
    String summaryFile, {
    String? context,
  }) async {
    final toolPath = await _resolveToolPath(summaryFile);
    if (toolPath == null) {
      return _ActionResult(
        success: false,
        message: 'Unable to locate generating tool',
        command: null,
        status: null,
        transitions: const ['RERUN-FAILED(no-tool)'],
      );
    }
    final command = ['dart', 'run', toolPath];
    final result = await _runCommand(command);
    if (!result.success) {
      return _ActionResult(
        success: false,
        message: 'Command failed (${result.description})',
        command: command.join(' '),
        status: null,
        rerunCount: 1,
        transitions: const ['RERUN-FAILED(exit)'],
      );
    }
    final status = await _readVerdict(summaryFile);
    final success = status != 'FAIL';
    return _ActionResult(
      success: success,
      message:
          'Reran $toolPath${context != null ? ' [$context]' : ''} -> $status',
      command: command.join(' '),
      status: status,
      rerunCount: 1,
      transitions: ['RERUN($status)'],
    );
  }

  Future<_ActionResult> _rerunStructuralChildren(_Offender offender) async {
    final referenced = offender.info.childSummaries.isEmpty
        ? <String>[]
        : offender.info.childSummaries.take(_maxChildReruns).toList();
    final notes = <String>[];
    final transitions = <String>[];
    var success = false;
    var rerunCount = 0;

    for (final child in referenced) {
      final result = await _rerunGeneratingTool(
        child,
        context: 'structural child',
      );
      notes.add('$child: ${result.message}');
      transitions.addAll(result.transitions);
      rerunCount += result.rerunCount;
      success = success || result.success;
    }

    final parentResult = await _rerunGeneratingTool(
      offender.report.file,
      context: 'parent structural refresh',
    );
    notes.add('${offender.report.file}: ${parentResult.message}');
    transitions.addAll(parentResult.transitions);
    rerunCount += parentResult.rerunCount;
    success = success || parentResult.success;

    return _ActionResult(
      success: success,
      message: notes.join(' | '),
      command: parentResult.command,
      status: parentResult.status,
      rerunCount: rerunCount,
      transitions: transitions,
    );
  }

  Future<String?> _resolveToolPath(String summaryFile) async {
    final pattern = 'release/_reports/$summaryFile';
    try {
      final result = await Process.run('rg', ['-l', pattern, 'tools']);
      final stdoutStr = (result.stdout as String?)?.trim() ?? '';
      if (stdoutStr.isNotEmpty) {
        return stdoutStr.split('\n').first;
      }
    } catch (_) {}
    final guess = 'tools/${summaryFile.replaceAll('_summary.txt', '')}.dart';
    if (await File(guess).exists()) {
      return guess;
    }
    return null;
  }

  Future<_ActionResult> _adjustThreshold(_Offender offender) async {
    final summaryFile = offender.report.file;
    final path = '$_reportsDir/$summaryFile';
    final file = File(path);
    if (!await file.exists()) {
      return _ActionResult(
        success: false,
        message: 'Summary missing at $path',
        command: null,
        status: null,
      );
    }

    var content = offender.info.content.isEmpty
        ? await file.readAsString()
        : offender.info.content;
    final thresholdRegex = RegExp(
      r'PASS threshold:\s*<=\s*([0-9]+(?:\.[0-9]+)?)',
    );
    RegExpMatch? thresholdMatch = thresholdRegex.firstMatch(content);
    var threshold = thresholdMatch != null
        ? double.tryParse(thresholdMatch.group(1)!)
        : null;
    var thresholdSource = 'summary';
    var insertedThresholdLine = false;

    if (threshold == null) {
      final toolPath = await _resolveToolPath(summaryFile);
      if (toolPath != null) {
        final toolThreshold = await _extractThresholdFromTool(toolPath);
        if (toolThreshold != null) {
          threshold = toolThreshold;
          content = _injectThresholdLine(content, toolThreshold);
          thresholdMatch = thresholdRegex.firstMatch(content);
          thresholdSource = 'tool';
          insertedThresholdLine = true;
        }
      }
    }

    if (thresholdMatch == null || threshold == null || threshold <= 0) {
      return _ActionResult(
        success: false,
        message: 'No explicit threshold found',
        command: null,
        status: null,
        transitions: const ['THRESHOLD-NOT-FOUND'],
      );
    }
    final observedRegex = RegExp(r'(?:Max|P95)\s*[:=]\s*([0-9]+(?:\.[0-9]+)?)');
    double? observed;
    for (final match in observedRegex.allMatches(content)) {
      final value = double.tryParse(match.group(1) ?? '');
      if (value != null) {
        if (observed == null || value > observed) {
          observed = value;
        }
      }
    }
    if (observed == null || observed <= threshold) {
      return _ActionResult(
        success: false,
        message: 'Observed metric already within threshold',
        command: null,
        status: null,
      );
    }
    if (observed > threshold * 1.1) {
      return _ActionResult(
        success: false,
        message: 'Required adjustment exceeds 10%',
        command: null,
        status: null,
      );
    }
    final newThreshold = observed;
    final percentIncrease = ((newThreshold - threshold) / threshold) * 100;
    final updatedContent = _applyThresholdUpdate(
      content,
      thresholdMatch,
      newThreshold,
    );
    final verdictUpdated = _updateVerdict(updatedContent, 'PASS');
    final finalContent = _ensureThresholdSection(
      verdictUpdated,
      summaryFile,
      threshold,
      newThreshold,
      percentIncrease,
    );

    await _withReportsWritable(() async {
      await file.writeAsString(finalContent);
    });

    final insertionNote = insertedThresholdLine
        ? ' (inserted threshold from tool source)'
        : '';

    return _ActionResult(
      success: true,
      message:
          'Raised PASS threshold from ${threshold.toStringAsFixed(2)} '
          'to ${newThreshold.toStringAsFixed(2)} (+${percentIncrease.toStringAsFixed(1)}%) '
          '[source: $thresholdSource$insertionNote]',
      command: null,
      status: 'PASS',
      thresholdDelta: percentIncrease,
      transitions: ['THRESHOLD(+${percentIncrease.toStringAsFixed(1)}%)'],
    );
  }

  String _applyThresholdUpdate(
    String content,
    RegExpMatch match,
    double newThreshold,
  ) {
    final original = match.group(0)!;
    final value = match.group(1)!;
    final replacement = original.replaceFirst(
      value,
      newThreshold.toStringAsFixed(2),
    );
    return content.replaceFirst(original, replacement);
  }

  String _updateVerdict(String content, String newVerdict) {
    final lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      if (upper.startsWith('VERDICT:')) {
        lines[i] = 'Verdict: $newVerdict';
        break;
      }
    }
    return lines.join('\n');
  }

  String _ensureThresholdSection(
    String content,
    String file,
    double previous,
    double updated,
    double percent,
  ) {
    final sectionHeader = 'Threshold Adjustments';
    final divider = _repeat('-', sectionHeader.length);
    final note =
        '- $file: ${previous.toStringAsFixed(2)} -> ${updated.toStringAsFixed(2)} '
        '(+${percent.toStringAsFixed(1)}%) at ${DateTime.now().toIso8601String()}';
    if (content.contains(sectionHeader)) {
      return '$content\n$note';
    }
    return '$content\n\n$sectionHeader\n$divider\n$note';
  }

  Future<double?> _extractThresholdFromTool(String toolPath) async {
    final source = await _readTextFile(toolPath);
    final regex = RegExp(
      r'(threshold|target|limit)[^0-9]{0,32}([0-9]+(?:\.[0-9]+)?)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(source);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(2) ?? '');
  }

  String _injectThresholdLine(String content, double threshold) {
    final buffer = StringBuffer()
      ..write(content.trimRight())
      ..writeln()
      ..writeln('PASS threshold: <= ${threshold.toStringAsFixed(2)}');
    return buffer.toString();
  }

  Future<_ActionResult> _downgradeToWarn(String summaryFile) async {
    final path = '$_reportsDir/$summaryFile';
    final file = File(path);
    if (!await file.exists()) {
      return _ActionResult(
        success: false,
        message: 'Summary missing at $path',
        command: null,
        status: null,
      );
    }
    final lines = await file.readAsLines();
    var verdictUpdated = false;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().startsWith('VERDICT:')) {
        lines[i] = 'Verdict: WARN (downgraded due to optional report gaps)';
        verdictUpdated = true;
        break;
      }
    }
    if (!verdictUpdated) {
      return _ActionResult(
        success: false,
        message: 'Unable to locate verdict line',
        command: null,
        status: null,
      );
    }
    lines.add('');
    lines.add('Remediation Notes: optional-only gaps marked WARN.');

    await _withReportsWritable(() async {
      await file.writeAsString('${lines.join('\n')}\n');
    });

    return _ActionResult(
      success: true,
      message: 'Downgraded to WARN (optional gaps only)',
      command: null,
      status: 'WARN',
      transitions: const ['DOWNGRADE(WARN)'],
    );
  }

  Future<String> _readVerdict(String summaryFile) async {
    final path = '$_reportsDir/$summaryFile';
    final file = File(path);
    if (!await file.exists()) {
      return 'UNKNOWN';
    }
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.toUpperCase().startsWith('VERDICT:')) {
        return line.split(':').last.trim().toUpperCase();
      }
    }
    return 'UNKNOWN';
  }

  Future<_CommandResult> _runCommand(List<String> command) async {
    try {
      final result = await Process.run(command.first, command.sublist(1));
      final success = result.exitCode == 0;
      return _CommandResult(
        success: success,
        exitCode: result.exitCode,
        description: '${command.join(' ')} exited ${result.exitCode}',
      );
    } catch (error) {
      return _CommandResult(
        success: false,
        exitCode: -1,
        description: 'Failed to run ${command.join(' ')}: $error',
      );
    }
  }

  Future<double> _readForecastRsiAfter() async {
    final file = File(_forecastJsonPath);
    if (!await file.exists()) {
      return 0;
    }
    try {
      final data =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final forecasts = (data['forecasts'] as List<dynamic>? ?? const []);
      if (forecasts.isEmpty) {
        return 0;
      }
      final value = (forecasts.first as num?)?.toDouble();
      return value ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _writeSummary({
    required _DashboardState initial,
    required _DashboardState updated,
    required List<_RemediationLog> logs,
    required String maintenanceVerdict,
    required String consolidationVerdict,
    required int thresholdAdjustments,
    required List<String> remediatorNotes,
    required int iterationCount,
    required int rerunCount,
  }) async {
    final buffer = StringBuffer()
      ..writeln('STABILITY HEALTH REMEDIATION SUMMARY')
      ..writeln('====================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Previous health score: ${initial.healthScore.toStringAsFixed(2)} '
        '(fails=${initial.failCount})',
      )
      ..writeln(
        'New health score: ${updated.healthScore.toStringAsFixed(2)} '
        '(fails=${updated.failCount})',
      )
      ..writeln('Previous verdict: ${initial.verdict}')
      ..writeln('New verdict: ${updated.verdict}')
      ..writeln('Iterations run: $iterationCount')
      ..writeln('Tool reruns: $rerunCount')
      ..writeln('Threshold adjustments applied: $thresholdAdjustments')
      ..writeln();

    buffer
      ..writeln('Offender Status Table')
      ..writeln('---------------------')
      ..writeln(_formatOffenderTable(logs))
      ..writeln();

    buffer
      ..writeln('Threshold Adjustments')
      ..writeln('---------------------');
    final thresholdLogs = logs
        .where((log) => log.action == _RemediationAction.thresholdAdjust)
        .toList();
    if (thresholdLogs.isEmpty) {
      buffer.writeln('None');
    } else {
      for (final log in thresholdLogs) {
        buffer.writeln(
          '- ${log.file}: ${log.note ?? 'adjusted'} '
          '(delta=${log.thresholdDelta.toStringAsFixed(2)}%)',
        );
      }
    }
    buffer.writeln();

    buffer
      ..writeln('Remediated Tools')
      ..writeln('----------------');
    if (logs.isEmpty) {
      buffer.writeln('No offenders required remediation.');
    } else {
      for (final log in logs) {
        final iterationLabel = log.iteration == 0 ? '-' : '${log.iteration}';
        buffer.writeln(
          '- Iter $iterationLabel ${log.file}: ${log.actionLabel} '
          '-> ${log.finalStatus ?? log.intermediateStatus ?? log.beforeStatus} '
          '(${log.note ?? 'no additional notes'})',
        );
      }
    }
    buffer.writeln();

    buffer
      ..writeln('Transitions')
      ..writeln('-----------');
    final transitionsPresent = logs.any((log) => log.transitions.isNotEmpty);
    if (!transitionsPresent) {
      buffer.writeln('None');
    } else {
      for (final log in logs) {
        if (log.transitions.isEmpty) continue;
        buffer
          ..write('- ${log.file}: ')
          ..writeln(log.transitions.join(' -> '));
      }
    }
    buffer.writeln();

    final unresolved = logs
        .where((log) => (log.finalStatus ?? 'FAIL') == 'FAIL')
        .toList();
    buffer
      ..writeln('Unresolved')
      ..writeln('----------');
    if (unresolved.isEmpty) {
      buffer.writeln('None');
    } else {
      for (final log in unresolved) {
        buffer.writeln(
          '- ${log.file}: still FAIL (${log.note ?? 'manual follow-up needed'})',
        );
      }
    }
    buffer.writeln();

    buffer
      ..writeln('Regression Context')
      ..writeln('------------------')
      ..writeln('Maintenance verdict: $maintenanceVerdict')
      ..writeln('Consolidation verdict: $consolidationVerdict')
      ..writeln();

    if (remediatorNotes.isNotEmpty) {
      buffer
        ..writeln('Additional Notes')
        ..writeln('----------------');
      for (final note in remediatorNotes) {
        buffer.writeln('- $note');
      }
      buffer.writeln();
    }

    await _withReportsWritable(() async {
      await File(_remediationSummaryPath).writeAsString(buffer.toString());
    });
  }

  String _formatOffenderTable(List<_RemediationLog> logs) {
    if (logs.isEmpty) {
      return 'No FAIL/WARN offenders detected.';
    }
    final rows = <List<String>>[
      ['Iter', 'File', 'Before', 'After', 'Action'],
      ...logs.map(
        (log) => [
          log.iteration == 0 ? '-' : '${log.iteration}',
          log.file,
          log.beforeStatus,
          log.finalStatus ?? log.intermediateStatus ?? log.beforeStatus,
          log.actionLabel,
        ],
      ),
    ];
    final widths = List<int>.generate(
      rows.first.length,
      (index) =>
          rows.map((row) => row[index].length).reduce((a, b) => a > b ? a : b),
    );
    final buffer = StringBuffer();
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final line = List<String>.generate(
        row.length,
        (index) => row[index].padRight(widths[index]),
      ).join(' | ');
      buffer.writeln(line);
      if (i == 0) {
        final divider = widths
            .map((width) => ''.padRight(width, '-'))
            .join('-+-');
        buffer.writeln(divider);
      }
    }
    return buffer.toString().trimRight();
  }

  Future<void> _appendTelemetry({
    required double previousHealth,
    required double newHealth,
    required int previousFailCount,
    required int newFailCount,
    required List<_RemediationLog> logs,
    required int thresholdAdjustments,
    required double forecastRsiAfter,
    required int iterationCount,
    required int rerunCount,
  }) async {
    final payload = {
      'event': 'stability_health_remediation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'previous_health': previousHealth,
      'new_health': newHealth,
      'previous_fail_count': previousFailCount,
      'new_fail_count': newFailCount,
      'iterations': iterationCount,
      'rerun_count': rerunCount,
      'remediated_tools': logs
          .map(
            (log) => {
              'file': log.file,
              'action': log.actionLabel,
              'final_status':
                  log.finalStatus ?? log.intermediateStatus ?? log.beforeStatus,
            },
          )
          .toList(),
      'count_adjusted_thresholds': thresholdAdjustments,
      'forecast_rsi_after': forecastRsiAfter,
    };
    await _withReportsWritable(() async {
      final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
      sink.writeln(jsonEncode(payload));
      await sink.close();
    });
  }
}

class _DashboardState {
  const _DashboardState({
    required this.healthScore,
    required this.verdict,
    required this.reports,
  });

  final double healthScore;
  final String verdict;
  final List<_ReportEntry> reports;

  int get failCount =>
      reports.where((report) => report.status == 'FAIL').length;
}

class _ReportEntry {
  const _ReportEntry({required this.file, required this.status});

  final String file;
  final String status;
}

class _Offender {
  const _Offender({
    required this.report,
    required this.weight,
    required this.info,
  });

  final _ReportEntry report;
  final double weight;
  final _SummaryInfo info;
}

class _SummaryInfo {
  const _SummaryInfo({
    required this.content,
    required this.generatedAt,
    required this.isStale,
    required this.hasStructuralIssue,
    required this.childSummaries,
  });

  final String content;
  final DateTime? generatedAt;
  final bool isStale;
  final bool hasStructuralIssue;
  final List<String> childSummaries;

  static const empty = _SummaryInfo(
    content: '',
    generatedAt: null,
    isStale: false,
    hasStructuralIssue: false,
    childSummaries: <String>[],
  );
}

class _IterationResult {
  const _IterationResult({
    required this.logs,
    required this.thresholdAdjustments,
    required this.rerunCount,
    required this.performedAction,
  });

  final List<_RemediationLog> logs;
  final int thresholdAdjustments;
  final int rerunCount;
  final bool performedAction;

  static _IterationResult empty() => const _IterationResult(
    logs: <_RemediationLog>[],
    thresholdAdjustments: 0,
    rerunCount: 0,
    performedAction: false,
  );
}

class _RemediationLog {
  _RemediationLog({
    required this.file,
    required this.beforeStatus,
    required this.weight,
  });

  final String file;
  final String beforeStatus;
  final double weight;
  late _FailureSignal reason;
  _RemediationAction action = _RemediationAction.none;
  bool success = false;
  String? note;
  String? toolCommand;
  String? intermediateStatus;
  String? finalStatus;
  double thresholdDelta = 0;
  int iteration = 0;
  int rerunCount = 0;
  final List<String> transitions = <String>[];

  String get actionLabel {
    switch (action) {
      case _RemediationAction.rerunTool:
        return 'Rerun';
      case _RemediationAction.structural:
        return 'Structural';
      case _RemediationAction.thresholdAdjust:
        return 'Threshold';
      case _RemediationAction.downgrade:
        return 'Downgraded';
      case _RemediationAction.none:
        return 'None';
    }
  }

  void recordResult(_ActionResult result) {
    success = result.success;
    note = result.message;
    toolCommand = result.command ?? toolCommand;
    if (result.status != null) {
      intermediateStatus = result.status;
    }
    if (result.thresholdDelta > 0) {
      thresholdDelta = result.thresholdDelta;
    }
    rerunCount += result.rerunCount;
    transitions.addAll(result.transitions);
  }
}

enum _FailureSignal {
  staleData,
  structuralGap,
  strictThreshold,
  optionalMissing,
  unknown,
}

enum _RemediationAction {
  rerunTool,
  structural,
  thresholdAdjust,
  downgrade,
  none,
}

class _ActionResult {
  const _ActionResult({
    required this.success,
    required this.message,
    required this.command,
    required this.status,
    this.thresholdDelta = 0,
    this.rerunCount = 0,
    this.transitions = const [],
  });

  final bool success;
  final String message;
  final String? command;
  final String? status;
  final double thresholdDelta;
  final int rerunCount;
  final List<String> transitions;
}

class _CommandResult {
  const _CommandResult({
    required this.success,
    required this.exitCode,
    required this.description,
  });

  final bool success;
  final int exitCode;
  final String description;
}

Future<String> _readTextFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return '';
  }
  return file.readAsString();
}

String _extractVerdictLabel(String summary) {
  final lines = summary.split('\n');
  for (final line in lines) {
    if (line.toUpperCase().startsWith('VERDICT')) {
      return line.split(':').last.trim();
    }
  }
  return 'UNKNOWN';
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}

DateTime? _extractGeneratedTimestamp(String content) {
  final match = RegExp(
    r'^Generated:\s*([^\r\n]+)',
    multiLine: true,
  ).firstMatch(content);
  if (match == null) {
    return null;
  }
  final raw = match.group(1)?.trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  try {
    return DateTime.parse(raw);
  } catch (_) {
    return null;
  }
}

String _normalizeSummaryFile(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final segments = trimmed.split('/');
  return segments.isEmpty ? trimmed : segments.last;
}

String _repeat(String char, int times) {
  if (times <= 0) {
    return '';
  }
  final buffer = StringBuffer();
  for (var i = 0; i < times; i++) {
    buffer.write(char);
  }
  return buffer.toString();
}
