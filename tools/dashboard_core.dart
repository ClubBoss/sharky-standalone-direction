// === Dashboard Core Split (Stage59A) ===
//
// Core utilities for health_dashboard.dart:
// - _safeRunTool: process execution with 60s timeout
// - _parseLastJsonLine: extract JSON from tool stdout
//
// This module is imported by health_dashboard.dart and provides
// foundational helpers for executing child tools and parsing their output.

part of 'health_dashboard.dart';

/// Execute a tool with 60-second timeout protection.
///
/// Returns ProcessResult with exitCode 124 on timeout.
/// Catches exceptions and returns ProcessResult with exitCode 1.
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

/// Parse last valid JSON line from tool stdout
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
