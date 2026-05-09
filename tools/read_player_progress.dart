import 'dart:convert';
import 'dart:io';

/// Helper script to read player progress from SharedPreferences.
/// Outputs JSON to stdout for health_dashboard.dart.
Future<void> main() async {
  try {
    // Read SharedPreferences file directly (platform-dependent location)
    // For now, return default values as SharedPreferences access requires
    // Flutter environment. In CI/development, this provides baseline data.
    final result = {'xpTotal': 0, 'level': 1, 'achievementsCount': 0};
    stdout.writeln(jsonEncode(result));
  } catch (e) {
    stderr.writeln('Error reading player progress: $e');
    exitCode = 1;
  }
}
