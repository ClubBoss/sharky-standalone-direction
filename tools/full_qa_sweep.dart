import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Entry point for the full QA sweep pipeline.
Future<void> main(List<String> args) async {
  final clockStart = DateTime.now().toUtc();
  final options = _Options.parse(args);
  final runner = _QaRunner(options);
  final summary = await runner.execute();
  final totalDuration = DateTime.now().toUtc().difference(clockStart);
  await _FullReportWriter(summary, totalDuration, options).write();
  stdout.writeln(jsonEncode(summary.telemetryPayload(totalDuration)));
  if (!summary.overallSuccess) {
    exit(1);
  }
}

class _Options {
  _Options({
    required this.fast,
    required this.testPattern,
    required this.maxRetry,
    required this.timeout,
    required this.updateQuarantine,
  });

  final bool fast;
  final String? testPattern;
  final int maxRetry;
  final Duration timeout;
  final bool updateQuarantine;

  static _Options parse(List<String> args) {
    var fast = false;
    String? testPattern;
    var maxRetry = 1;
    Duration timeout = const Duration(minutes: 5);
    var updateQuarantine = true;

    for (final arg in args) {
      if (arg == '--fast') {
        fast = true;
      } else if (arg.startsWith('--tests=')) {
        testPattern = arg.substring('--tests='.length).trim();
        if (testPattern.isEmpty) {
          testPattern = null;
        }
      } else if (arg.startsWith('--max-retry=')) {
        final raw = int.tryParse(arg.substring('--max-retry='.length));
        if (raw != null && raw >= 0) {
          maxRetry = raw;
        }
      } else if (arg.startsWith('--timeout-seconds=')) {
        final raw = int.tryParse(arg.substring('--timeout-seconds='.length));
        if (raw != null && raw > 0) {
          timeout = Duration(seconds: raw);
        }
      } else if (arg == '--no-quarantine-update') {
        updateQuarantine = false;
      }
    }

    return _Options(
      fast: fast,
      testPattern: testPattern,
      maxRetry: maxRetry,
      timeout: timeout,
      updateQuarantine: updateQuarantine,
    );
  }
}

class _QaRunner {
  _QaRunner(this.options);

  final _Options options;
  final _PipelineSummary summary = _PipelineSummary();

  Future<_PipelineSummary> execute() async {
    stdout.writeln(_cyan('=== Poker Analyzer Full QA Sweep ==='));

    if (!await _runVisualAudit()) {
      return summary;
    }
    if (!await _runLaunchReadiness()) {
      return summary;
    }
    if (!await _runMarketingAudit()) {
      return summary;
    }
    if (!await _runGovernanceAudit()) {
      return summary;
    }
    if (!await _runStakeholderReport()) {
      return summary;
    }
    if (!await _runLocalizationAudit()) {
      return summary;
    }
    if (!await _runAiReliabilityAudit()) {
      return summary;
    }
    if (!await _runFormat()) {
      return summary;
    }
    if (!await _runAnalyze()) {
      return summary;
    }
    if (!await _runPackValidation()) {
      return summary;
    }
    if (!await _runTests()) {
      return summary;
    }
    if (!await _runSimulation()) {
      return summary;
    }
    if (!options.fast) {
      if (!await _runTelemetryDashboard()) {
        return summary;
      }
      if (!await _runDeveloperMetrics()) {
        return summary;
      }
      if (!await _runAnalyticsDashboard()) {
        return summary;
      }
    } else {
      summary.markSkipped(_Step.telemetry);
      summary.markSkipped(_Step.metrics);
      summary.markSkipped(_Step.analytics);
    }

    if (!await _runQaCiPerfection()) {
      return summary;
    }

    summary.overallSuccess = true;
    return summary;
  }

  Future<bool> _runFormat() async {
    summary.markRunning(_Step.format);
    final result = await _runProcess(
      name: 'FORMAT',
      command: ['dart', 'format', '--set-exit-if-changed', '.'],
    );
    summary.complete(_Step.format, result);
    return result.success;
  }

  Future<bool> _runVisualAudit() async {
    summary.markRunning(_Step.visual);
    final result = await _runProcess(
      name: 'VISUAL',
      command: ['dart', 'run', 'tools/visual_integrity_audit.dart'],
    );
    summary.complete(_Step.visual, result);
    return result.success;
  }

  Future<bool> _runLaunchReadiness() async {
    summary.markRunning(_Step.launch);
    final result = await _runProcess(
      name: 'LAUNCH',
      command: ['dart', 'run', 'tools/launch_readiness_audit.dart'],
    );
    summary.complete(_Step.launch, result);
    return result.success;
  }

  Future<bool> _runMarketingAudit() async {
    summary.markRunning(_Step.marketing);
    final result = await _runProcess(
      name: 'MARKETING',
      command: ['dart', 'run', 'tools/marketing_asset_audit.dart'],
    );
    summary.complete(_Step.marketing, result);
    return result.success;
  }

  Future<bool> _runGovernanceAudit() async {
    summary.markRunning(_Step.governance);
    final result = await _runProcess(
      name: 'GOVERNANCE',
      command: ['dart', 'run', 'tools/governance_integrity_audit.dart'],
    );
    summary.complete(_Step.governance, result);
    return result.success;
  }

  Future<bool> _runStakeholderReport() async {
    summary.markRunning(_Step.stakeholder);
    final result = await _runProcess(
      name: 'STAKE',
      command: ['dart', 'run', 'tools/release_stakeholder_report.dart'],
    );
    summary.complete(_Step.stakeholder, result);
    return result.success;
  }

  Future<bool> _runLocalizationAudit() async {
    summary.markRunning(_Step.localization);
    final result = await _runProcess(
      name: 'LOCALIZATION',
      command: ['dart', 'run', 'tools/localization_content_audit.dart'],
    );
    summary.complete(_Step.localization, result);
    return result.success;
  }

  Future<bool> _runAiReliabilityAudit() async {
    summary.markRunning(_Step.aiReliability);
    final result = await _runProcess(
      name: 'AI REL',
      command: ['dart', 'run', 'tools/ai_reliability_audit.dart'],
    );
    summary.complete(_Step.aiReliability, result);
    return result.success;
  }

  Future<bool> _runQaCiPerfection() async {
    summary.markRunning(_Step.qaCi);
    final result = await _runProcess(
      name: 'QA CI',
      command: ['dart', 'run', 'tools/qa_ci_perfection_sweep.dart'],
    );
    summary.complete(_Step.qaCi, result);
    return result.success;
  }

  Future<bool> _runAnalyze() async {
    summary.markRunning(_Step.analyze);
    final result = await _runProcess(
      name: 'ANALYZE',
      command: ['dart', 'analyze'],
    );
    summary.analyzerOutput = result.stdout;
    summary.complete(_Step.analyze, result);
    return result.success;
  }

  Future<bool> _runPackValidation() async {
    summary.markRunning(_Step.packs);
    final result = await _runProcess(
      name: 'PACKS',
      command: ['dart', 'run', 'tools/pack_validation_cli.dart'],
    );
    summary.packValidationOutput = result.allOutput;
    summary.complete(_Step.packs, result);
    return result.success;
  }

  Future<bool> _runTests() async {
    summary.markRunning(_Step.tests);
    final tester = _TestRunner(options);
    final testResult = await tester.execute();
    summary.testResult = testResult;
    summary.complete(
      _Step.tests,
      _StepResult(
        command: testResult.command,
        stdout: testResult.stdout,
        stderr: testResult.stderr,
        duration: testResult.duration,
        success: testResult.success,
      ),
    );
    if (testResult.flakyTests.isNotEmpty &&
        options.updateQuarantine &&
        testResult.success) {
      await _updateFlakyQuarantine(testResult.flakyTests);
    }
    return testResult.success;
  }

  Future<bool> _runSimulation() async {
    summary.markRunning(_Step.simulation);
    final result = await _runProcess(
      name: 'SIM',
      command: ['dart', 'run', 'tools/simulation_ai_test.dart', '--hands=20'],
    );
    final outputTrimmed = result.stdout.trim();
    final simOk = result.success && outputTrimmed.isNotEmpty;
    if (!simOk) {
      summary.simulationNotes = 'Simulation output empty or command failed.';
    }
    summary.complete(_Step.simulation, result.copyWith(success: simOk));
    return simOk;
  }

  Future<bool> _runTelemetryDashboard() async {
    summary.markRunning(_Step.telemetry);
    final result = await _runProcess(
      name: 'TELEMETRY',
      command: ['dart', 'run', 'tools/telemetry_dashboard_cli.dart'],
    );
    summary.complete(_Step.telemetry, result);
    return result.success;
  }

  Future<bool> _runDeveloperMetrics() async {
    summary.markRunning(_Step.metrics);
    final result = await _runProcess(
      name: 'METRICS',
      command: ['dart', 'run', 'tools/developer_metrics_dashboard.dart'],
    );
    summary.complete(_Step.metrics, result);
    return result.success;
  }

  Future<bool> _runAnalyticsDashboard() async {
    summary.markRunning(_Step.analytics);
    final result = await _runProcess(
      name: 'ANALYTICS',
      command: ['dart', 'run', 'tools/analytics_dashboard_v3.dart'],
    );
    summary.complete(_Step.analytics, result);
    return result.success;
  }

  Future<_StepResult> _runProcess({
    required String name,
    required List<String> command,
  }) async {
    final start = DateTime.now();
    stdout.writeln(_cyan('[$name] ${command.join(' ')}'));
    final process = await Process.start(command.first, command.sublist(1));
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    final stdoutSub = process.stdout.transform(utf8.decoder).listen((data) {
      stdoutBuffer.write(data);
      stdout.write(data);
    });
    final stderrSub = process.stderr.transform(utf8.decoder).listen((data) {
      stderrBuffer.write(data);
      stderr.write(data);
    });

    final exitCode = await process.exitCode;
    await stdoutSub.cancel();
    await stderrSub.cancel();

    final duration = DateTime.now().difference(start);
    final success = exitCode == 0;
    final icon = success ? _green('✅') : _red('❌');
    stdout.writeln('[$name] $icon completed in ${_fmtDuration(duration)}');
    return _StepResult(
      command: command.join(' '),
      stdout: stdoutBuffer.toString(),
      stderr: stderrBuffer.toString(),
      duration: duration,
      success: success,
    );
  }

  Future<void> _updateFlakyQuarantine(Set<_TestCase> flakies) async {
    if (flakies.isEmpty) {
      return;
    }
    final file = File('tools/_config/flaky_tests.txt');
    await file.parent.create(recursive: true);
    final existing = <String>{};
    if (await file.exists()) {
      final lines = await file.readAsLines();
      existing.addAll(
        lines.map((line) => line.trim()).where((line) => line.isNotEmpty),
      );
    }
    for (final flaky in flakies) {
      existing.add(flaky.description);
    }
    final sorted = existing.toList()..sort();
    await file.writeAsString('${sorted.join('\n')}\n');
  }
}

class _TestRunner {
  _TestRunner(this.options);

  final _Options options;

  Future<_TestSummary> execute() async {
    final command = _buildBaseCommand();
    stdout.writeln(_cyan('[TESTS] ${command.join(' ')}'));
    final stopwatch = Stopwatch()..start();
    final firstPass = await _runOnce(command);
    if (!firstPass.success &&
        options.maxRetry > 0 &&
        firstPass.failures.isNotEmpty) {
      final retryResult = await _retryFailures(firstPass.failures);
      stopwatch.stop();
      final combined = firstPass.mergeWithRetry(retryResult);
      combined.duration = stopwatch.elapsed;
      return combined;
    }
    stopwatch.stop();
    firstPass.duration = stopwatch.elapsed;
    return firstPass;
  }

  List<String> _buildBaseCommand() {
    final args = <String>['dart', 'test', '--reporter=json'];
    if (options.timeout.inSeconds > 0) {
      args.add('--timeout=${options.timeout.inSeconds}s');
    }
    if (options.testPattern != null) {
      args.addAll(_splitPattern(options.testPattern!));
    }
    return args;
  }

  List<String> _splitPattern(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const <String>[];
    }
    return trimmed.split(RegExp(r'\s+'));
  }

  Future<_TestSummary> _runOnce(List<String> command) async {
    final process = await Process.start(command.first, command.sublist(1));
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();
    final parser = _TestJsonParser();

    final stdoutFuture = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
          stdoutBuffer.writeln(line);
          parser.handleLine(line);
        });

    final stderrFuture = process.stderr
        .transform(utf8.decoder)
        .forEach(stderrBuffer.write);

    final exitCode = await process.exitCode;
    await stdoutFuture;
    await stderrFuture;

    final success = exitCode == 0;
    final icon = success ? _green('✅') : _red('❌');
    stdout.writeln('[TESTS] $icon completed (${parser.totalTests} tests)');

    return _TestSummary(
      command: command.join(' '),
      stdout: stdoutBuffer.toString(),
      stderr: stderrBuffer.toString(),
      success: success,
      totalTests: parser.totalTests,
      failures: parser.failures,
    );
  }

  Future<_RetryOutcome> _retryFailures(Set<_TestCase> failures) async {
    final flaky = <_TestCase>{};
    final stillFailing = <_TestCase>{};
    for (final test in failures) {
      final retryCommand = _buildRetryCommand(test);
      stdout.writeln(_yellow('[TESTS] Retrying ${test.description}'));
      final result = await _runOnce(retryCommand);
      if (result.success) {
        flaky.add(test);
      } else {
        stillFailing.add(test);
      }
    }
    return _RetryOutcome(flaky: flaky, remainingFailures: stillFailing);
  }

  List<String> _buildRetryCommand(_TestCase test) {
    final args = <String>[
      'dart',
      'test',
      '--reporter=json',
      '--name=${test.name}',
    ];
    if (options.timeout.inSeconds > 0) {
      args.add('--timeout=${options.timeout.inSeconds}s');
    }
    if (options.testPattern != null) {
      args.addAll(_splitPattern(options.testPattern!));
    } else if (test.suitePath != null) {
      args.add(test.suitePath!);
    }
    return args;
  }
}

class _TestJsonParser {
  final Map<int, _TestInfo> tests = <int, _TestInfo>{};
  final Map<int, String> suites = <int, String>{};
  final Map<int, List<String>> failureDetails = <int, List<String>>{};

  int totalTests = 0;
  final Set<_TestCase> failures = <_TestCase>{};

  void handleLine(String line) {
    if (line.isEmpty) {
      return;
    }
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(line) as Map<String, dynamic>;
    } catch (_) {
      stdout.writeln(line);
      return;
    }
    switch (decoded['type']) {
      case 'suite':
        final suite = decoded['suite'] as Map<String, dynamic>?;
        if (suite != null) {
          final id = suite['id'] as int?;
          final path = suite['path']?.toString();
          if (id != null && path != null) {
            suites[id] = path;
          }
        }
        break;
      case 'testStart':
        final test = decoded['test'] as Map<String, dynamic>?;
        if (test != null) {
          final id = test['id'] as int?;
          if (id != null) {
            tests[id] = _TestInfo(
              id: id,
              name: test['name']?.toString() ?? 'unnamed test',
              suiteID: test['suiteID'] as int?,
            );
          }
        }
        break;
      case 'print':
        final message = decoded['message']?.toString();
        if (message != null) {
          stdout.writeln(message);
        }
        break;
      case 'error':
        final testID = decoded['testID'] as int?;
        final error = decoded['error']?.toString();
        final stack = decoded['stackTrace']?.toString();
        if (testID != null) {
          failureDetails.putIfAbsent(testID, () => <String>[]);
          if (error != null) {
            failureDetails[testID]!.add(error);
          }
          if (stack != null && stack.isNotEmpty) {
            failureDetails[testID]!.add(stack);
          }
        }
        break;
      case 'testDone':
        totalTests += 1;
        final testID = decoded['testID'] as int?;
        final result = decoded['result']?.toString();
        if (testID != null && (result == 'error' || result == 'failure')) {
          final info = tests[testID];
          if (info != null) {
            final suitePath = info.suiteID != null
                ? suites[info.suiteID!]
                : null;
            final details = failureDetails[testID]?.join('\n');
            failures.add(
              _TestCase(
                name: info.name,
                suitePath: suitePath,
                details: details ?? '',
              ),
            );
          }
        }
        break;
      default:
        break;
    }
  }
}

class _TestSummary {
  _TestSummary({
    required this.command,
    required this.stdout,
    required this.stderr,
    required this.success,
    required this.totalTests,
    required this.failures,
  });

  final String command;
  final String stdout;
  final String stderr;
  final bool success;
  final int totalTests;
  final Set<_TestCase> failures;
  Duration duration = Duration.zero;
  final Set<_TestCase> flakyTests = <_TestCase>{};

  _TestSummary mergeWithRetry(_RetryOutcome retry) {
    final stillFailing = retry.remainingFailures;
    final newSummary = _TestSummary(
      command: command,
      stdout: stdout,
      stderr: stderr,
      success: stillFailing.isEmpty,
      totalTests: totalTests,
      failures: stillFailing,
    );
    newSummary.flakyTests.addAll(retry.flaky);
    newSummary.duration = duration;
    return newSummary;
  }
}

class _RetryOutcome {
  _RetryOutcome({required this.flaky, required this.remainingFailures});

  final Set<_TestCase> flaky;
  final Set<_TestCase> remainingFailures;
}

class _TestCase {
  _TestCase({
    required this.name,
    required this.suitePath,
    required this.details,
  });

  final String name;
  final String? suitePath;
  final String details;

  String get description => suitePath != null ? '$name ($suitePath)' : name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _TestCase &&
        other.name == name &&
        other.suitePath == suitePath;
  }

  @override
  int get hashCode => Object.hash(name, suitePath);
}

class _TestInfo {
  _TestInfo({required this.id, required this.name, required this.suiteID});

  final int id;
  final String name;
  final int? suiteID;
}

enum _Step {
  visual('VISUAL'),
  launch('LAUNCH'),
  marketing('MARKETING'),
  governance('GOV'),
  stakeholder('STAKE'),
  localization('LOCAL'),
  aiReliability('AI REL'),
  format('FORMAT'),
  analyze('ANALYZE'),
  packs('PACKS'),
  tests('TESTS'),
  simulation('SIM'),
  telemetry('TELEMETRY'),
  metrics('METRICS'),
  analytics('ANALYTICS'),
  qaCi('QA CI');

  const _Step(this.label);
  final String label;
}

class _StepResult {
  const _StepResult({
    required this.command,
    required this.stdout,
    required this.stderr,
    required this.duration,
    required this.success,
  });

  final String command;
  final String stdout;
  final String stderr;
  final Duration duration;
  final bool success;

  String get allOutput => '$stdout$stderr';

  _StepResult copyWith({bool? success}) {
    return _StepResult(
      command: command,
      stdout: stdout,
      stderr: stderr,
      duration: duration,
      success: success ?? this.success,
    );
  }
}

class _PipelineSummary {
  final Map<_Step, _TrackedStep> steps = <_Step, _TrackedStep>{};
  String analyzerOutput = '';
  String packValidationOutput = '';
  _TestSummary? testResult;
  String? simulationNotes;
  bool overallSuccess = false;

  void markRunning(_Step step) {
    steps[step] = _TrackedStep(state: _StepState.running);
  }

  void markSkipped(_Step step) {
    steps[step] = _TrackedStep(state: _StepState.skipped);
  }

  void complete(_Step step, _StepResult result) {
    steps[step] = _TrackedStep(
      state: result.success ? _StepState.success : _StepState.failure,
      result: result,
    );
    if (!result.success) {
      overallSuccess = false;
      _markRemainingSkipped(step);
    }
  }

  void _markRemainingSkipped(_Step failingStep) {
    final index = _Step.values.indexOf(failingStep);
    for (var i = index + 1; i < _Step.values.length; i++) {
      final step = _Step.values[i];
      steps.putIfAbsent(step, () => _TrackedStep(state: _StepState.skipped));
    }
  }

  Map<String, Object?> telemetryPayload(Duration totalDuration) {
    final testSummary = testResult;
    final testsFailed = testSummary?.failures.length ?? 0;
    final testsPassed = (testSummary?.totalTests ?? 0) - testsFailed;
    final flakies = testSummary?.flakyTests.length ?? 0;
    return <String, Object?>{
      'event': 'full_qa_completed',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': totalDuration.inMilliseconds,
      'localization_ok': _isSuccess(_Step.localization) ? 1 : 0,
      'ai_reliability_ok': _isSuccess(_Step.aiReliability) ? 1 : 0,
      'visual_ok': _isSuccess(_Step.visual) ? 1 : 0,
      'launch_ok': _isSuccess(_Step.launch) ? 1 : 0,
      'marketing_ok': _isSuccess(_Step.marketing) ? 1 : 0,
      'governance_ok': _isSuccess(_Step.governance) ? 1 : 0,
      'stakeholder_ok': _isSuccess(_Step.stakeholder) ? 1 : 0,
      'format': _isSuccess(_Step.format) ? 1 : 0,
      'analyze': _isSuccess(_Step.analyze) ? 1 : 0,
      'packs': _isSuccess(_Step.packs) ? 1 : 0,
      'tests_passed': testsPassed,
      'tests_failed': testsFailed,
      'flakies': flakies,
      'sim_ok': _isSuccess(_Step.simulation) ? 1 : 0,
      'telemetry_ok': _isSuccess(_Step.telemetry) ? 1 : 0,
      'metrics_ok': _isSuccess(_Step.metrics) ? 1 : 0,
      'analytics_ok': _isSuccess(_Step.analytics) ? 1 : 0,
      'qa_ci_ok': _isSuccess(_Step.qaCi) ? 1 : 0,
    };
  }

  bool _isSuccess(_Step step) => steps[step]?.state == _StepState.success;
}

enum _StepState { running, success, failure, skipped }

class _TrackedStep {
  _TrackedStep({required this.state, this.result});

  final _StepState state;
  final _StepResult? result;
}

class _FullReportWriter {
  _FullReportWriter(this.summary, this.totalDuration, this.options);

  final _PipelineSummary summary;
  final Duration totalDuration;
  final _Options options;

  Future<void> write() async {
    final reportDir = Directory('release/_reports');
    await reportDir.create(recursive: true);
    final reportFile = File('${reportDir.path}/full_qa_report.txt');
    final buffer = StringBuffer()
      ..writeln('=== FULL QA REPORT ===')
      ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('Total Duration: ${_fmtDuration(totalDuration)}')
      ..writeln('');

    for (final step in _Step.values) {
      final tracked = summary.steps[step];
      final label = step.label.padRight(10);
      if (tracked == null || tracked.state == _StepState.running) {
        buffer.writeln('$label ⏳ pending');
        continue;
      }
      final result = tracked.result;
      final icon = switch (tracked.state) {
        _StepState.success => '✅',
        _StepState.failure => '❌',
        _StepState.skipped => '⏭️',
        _StepState.running => '⏳',
      };
      final duration = result?.duration ?? Duration.zero;
      final note = tracked.state == _StepState.skipped && options.fast
          ? '(skipped via --fast)'
          : '';
      buffer.writeln(
        '$label $icon ${_fmtDuration(duration)} $note'.trimRight(),
      );
    }

    buffer
      ..writeln('')
      ..writeln('Failed Tests:');
    final failures = summary.testResult?.failures ?? <_TestCase>{};
    if (failures.isEmpty) {
      buffer.writeln(' - None');
    } else {
      for (final test in failures) {
        buffer.writeln(' - ${test.description}');
        if (test.details.isNotEmpty) {
          buffer.writeln('   ${test.details.replaceAll('\n', '\n   ')}');
        }
      }
    }

    buffer
      ..writeln('')
      ..writeln('Flaky Tests:');
    final flakies = summary.testResult?.flakyTests ?? <_TestCase>{};
    if (flakies.isEmpty) {
      buffer.writeln(' - None');
    } else {
      for (final test in flakies) {
        buffer.writeln(' - ${test.description}');
      }
    }

    buffer
      ..writeln('')
      ..writeln('Pack Failures:');
    final packFailures = _extractPackFailures(summary.packValidationOutput);
    if (packFailures.isEmpty) {
      buffer.writeln(' - None');
    } else {
      for (final entry in packFailures) {
        buffer.writeln(' - $entry');
      }
    }

    buffer
      ..writeln('')
      ..writeln('Analyzer Issues (Top 10):');
    final issues = _extractAnalyzerIssues(summary.analyzerOutput);
    if (issues.isEmpty) {
      buffer.writeln(' - None');
    } else {
      for (final issue in issues) {
        buffer.writeln(' - $issue');
      }
    }

    buffer
      ..writeln('')
      ..writeln('Next Actions:');
    final nextActions = _deriveNextActions(
      formatOk: summary.steps[_Step.format]?.state == _StepState.success,
      analyzeOk: summary.steps[_Step.analyze]?.state == _StepState.success,
      packsOk: summary.steps[_Step.packs]?.state == _StepState.success,
      testsOk: summary.steps[_Step.tests]?.state == _StepState.success,
      simOk: summary.steps[_Step.simulation]?.state == _StepState.success,
      telemetryOk: summary.steps[_Step.telemetry]?.state == _StepState.success,
      metricsOk: summary.steps[_Step.metrics]?.state == _StepState.success,
      analyticsOk: summary.steps[_Step.analytics]?.state == _StepState.success,
      failures: failures,
      flakies: flakies,
    );
    if (nextActions.isEmpty) {
      buffer.writeln(' - None');
    } else {
      for (final action in nextActions) {
        buffer.writeln(' - $action');
      }
    }

    await reportFile.writeAsString('${buffer.toString()}\n');
    stdout.writeln(_green('Report written to ${reportFile.path}'));
  }

  List<String> _extractPackFailures(String output) {
    final failures = <String>{};
    final lines = const LineSplitter().convert(output);
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final containsFail = trimmed.contains('FAIL') || trimmed.contains('❌');
      if (containsFail && trimmed.contains('|')) {
        failures.add(trimmed);
      }
    }
    return failures.toList();
  }

  List<String> _extractAnalyzerIssues(String output) {
    final lines = const LineSplitter().convert(output);
    final issues = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.contains(' • ')) {
        continue;
      }
      issues.add(trimmed);
      if (issues.length >= 10) {
        break;
      }
    }
    return issues;
  }

  List<String> _deriveNextActions({
    required bool? formatOk,
    required bool? analyzeOk,
    required bool? packsOk,
    required bool? testsOk,
    required bool? simOk,
    required bool? telemetryOk,
    required bool? metricsOk,
    required bool? analyticsOk,
    required Set<_TestCase> failures,
    required Set<_TestCase> flakies,
  }) {
    final actions = <String>{};
    if (formatOk == false) {
      actions.add('Fix formatting issues (run dart format).');
    }
    if (analyzeOk == false) {
      actions.add('Resolve analyzer findings listed above.');
    }
    if (packsOk == false) {
      actions.add('Repair pack validation errors (see Pack Failures).');
    }
    if (testsOk == false && failures.isNotEmpty) {
      final names = failures.map((f) => f.description).join('; ');
      actions.add('Fix failing tests: $names');
    }
    if (flakies.isNotEmpty) {
      final names = flakies.map((f) => f.description).join('; ');
      actions.add('Stabilize flaky tests: $names');
    }
    if (simOk == false) {
      actions.add('Investigate simulation_ai_test issues.');
    }
    if (!options.fast) {
      if (telemetryOk == false) {
        actions.add('Review telemetry dashboard errors.');
      }
      if (metricsOk == false) {
        actions.add('Resolve developer metrics dashboard output.');
      }
      if (analyticsOk == false) {
        actions.add('Fix analytics dashboard CLI.');
      }
    }
    return actions.toList();
  }
}

String _fmtDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '${hours}h${minutes}m${seconds}s';
  }
  final ms = duration.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
  final minutesTotal = duration.inMinutes.toString();
  return '$minutesTotal:$seconds.${ms.substring(0, 2)}';
}

String _cyan(String text) => '\x1B[36m$text\x1B[0m';
String _green(String text) => '\x1B[32m$text\x1B[0m';
String _yellow(String text) => '\x1B[33m$text\x1B[0m';
String _red(String text) => '\x1B[31m$text\x1B[0m';
