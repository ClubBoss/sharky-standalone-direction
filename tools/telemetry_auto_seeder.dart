import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryPath = '$_reportsDir/telemetry_auto_seed_summary.txt';
const int _defaultUsers = 50;
const int _minSessionsPerUser = 5;
const int _maxSessionsPerUser = 10;
const int _replayLimit = 30;

Future<void> main(List<String> args) async {
  final options = _SeedOptions.parse(args);
  final seeder = TelemetryAutoSeeder(options);
  final ok = await seeder.run();
  if (!ok) {
    exitCode = 2;
  }
}

class TelemetryAutoSeeder {
  TelemetryAutoSeeder(this.options);

  final _SeedOptions options;

  Future<bool> run() async {
    return _withReportsWritable(() async {
      if (options.replay) {
        return _replayTelemetry();
      }
      return _seedTelemetry();
    });
  }

  Future<bool> _seedTelemetry() async {
    final stopwatch = Stopwatch()..start();
    final random = Random(42);
    final eventCounts = <String, int>{};
    var sessionCount = 0;
    final runId = DateTime.now().millisecondsSinceEpoch;
    final writer = await _openTelemetrySink();
    final start = DateTime.now().subtract(const Duration(days: 7));

    try {
      for (var userIndex = 0; userIndex < options.userCount; userIndex++) {
        final userId = 'user_${runId}_${userIndex.toString().padLeft(4, '0')}';
        final signupOffset = Duration(minutes: userIndex * 15);
        final signupTime = start.add(signupOffset);
        final tutorialStart = signupTime.add(const Duration(minutes: 2));
        final tutorialFinish = tutorialStart.add(const Duration(minutes: 5));

        void addEvent(
          String event,
          DateTime timestamp,
          Map<String, Object?> payload,
        ) {
          final entry = <String, Object?>{
            'event': event,
            'timestamp': timestamp.toIso8601String(),
            'user_id': userId,
            'seed_run': runId,
            ...payload,
          };
          writer.writeln(jsonEncode(entry));
          eventCounts[event] = (eventCounts[event] ?? 0) + 1;
        }

        addEvent('signup_completed', signupTime, {
          'channel': random.nextBool() ? 'organic' : 'paid_A',
        });
        addEvent('tutorial_started', tutorialStart, {'step': 1});
        final completedTutorial = random.nextDouble() > 0.4;
        if (completedTutorial) {
          addEvent('tutorial_finished', tutorialFinish, {'score': 100});
        }

        final includeSessionEnd =
            completedTutorial && random.nextDouble() > 0.3;
        final sessions = completedTutorial
            ? _minSessionsPerUser +
                  random.nextInt(_maxSessionsPerUser - _minSessionsPerUser + 1)
            : 1 + random.nextInt(2); // still simulate short sessions
        for (var sessionIndex = 0; sessionIndex < sessions; sessionIndex++) {
          final sessionId = '${userId}_session_$sessionIndex';
          final sessionStart = tutorialFinish.add(
            Duration(hours: sessionIndex * 6 + random.nextInt(120)),
          );
          final sessionEnd = sessionStart.add(
            Duration(minutes: 15 + random.nextInt(25)),
          );
          sessionCount++;

          addEvent('session_start', sessionStart, {'session_id': sessionId});
          final lessonCount = 1 + random.nextInt(3);
          for (var lesson = 0; lesson < lessonCount; lesson++) {
            final lessonTime = sessionStart.add(
              Duration(minutes: lesson * 5 + random.nextInt(3)),
            );
            addEvent('lesson_open', lessonTime, {
              'lesson_id': 'L${random.nextInt(50)}',
            });
            addEvent(
              'ad_impression',
              lessonTime.add(const Duration(minutes: 1)),
              {
                'placement': random.nextBool()
                    ? 'home_banner'
                    : 'lesson_midroll',
              },
            );
            if (random.nextBool()) {
              addEvent(
                'quiz_complete',
                lessonTime.add(const Duration(minutes: 2)),
                {
                  'quiz_id': 'Q${random.nextInt(200)}',
                  'score': 70 + random.nextInt(25),
                },
              );
            }
            if (random.nextBool()) {
              addEvent(
                'recap_view',
                lessonTime.add(const Duration(minutes: 3)),
                {'recap_id': 'R${random.nextInt(120)}'},
              );
            }
          }
          if (includeSessionEnd && random.nextDouble() > 0.05) {
            addEvent('session_end', sessionEnd, {'session_id': sessionId});
          }
        }
      }

      final summary = StringBuffer()
        ..writeln('TELEMETRY AUTO SEED SUMMARY')
        ..writeln('===========================')
        ..writeln('Generated: ${DateTime.now().toIso8601String()}')
        ..writeln('Users seeded: ${options.userCount}')
        ..writeln('Sessions generated: $sessionCount')
        ..writeln('Duration: ${stopwatch.elapsedMilliseconds}ms')
        ..writeln()
        ..writeln('Event counts:');
      final sorted = eventCounts.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      for (final entry in sorted) {
        summary.writeln('- ${entry.key}: ${entry.value}');
      }
      await File(_summaryPath).writeAsString(summary.toString());

      await _appendTelemetry({
        'event': 'telemetry_auto_seeded',
        'timestamp': DateTime.now().toIso8601String(),
        'users': options.userCount,
        'sessions': sessionCount,
        'duration_ms': stopwatch.elapsedMilliseconds,
      });
    } finally {
      await writer.flush();
      await writer.close();
    }

    return true;
  }

  Future<bool> _replayTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      stderr.writeln('No telemetry file found to replay.');
      return false;
    }
    final lines = await file.readAsLines();
    final limited = lines.take(_replayLimit).toList();
    stdout.writeln('Replaying ${limited.length} events at 1 event/sec...');
    for (final line in limited) {
      try {
        final payload = json.decode(line);
        if (payload is! Map<String, Object?>) continue;
        stdout.writeln(
          '[${payload['timestamp']}] ${payload['event']} '
          '${payload['user_id'] ?? ''}',
        );
      } catch (_) {
        stdout.writeln('Malformed telemetry line: $line');
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    final summary = StringBuffer()
      ..writeln('TELEMETRY AUTO REPLAY SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Events replayed: ${limited.length}')
      ..writeln('Replay duration (approx): ${limited.length} seconds');
    await File(_summaryPath).writeAsString(summary.toString());
    return true;
  }

  Future<IOSink> _openTelemetrySink() async {
    final file = File(_telemetryPath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return file.openWrite(mode: FileMode.append);
  }

  Future<void> _appendTelemetry(Map<String, Object?> payload) async {
    final sink = await _openTelemetrySink();
    sink.writeln(jsonEncode(payload));
    await sink.flush();
    await sink.close();
  }
}

class _SeedOptions {
  _SeedOptions({required this.userCount, required this.replay});

  final int userCount;
  final bool replay;

  static _SeedOptions parse(List<String> args) {
    var users = _defaultUsers;
    var replay = false;
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      if (arg == '--replay') {
        replay = true;
      } else if (arg.startsWith('--seed=')) {
        final value = arg.split('=').last;
        users = int.tryParse(value) ?? users;
      } else if (arg == '--seed' && i + 1 < args.length) {
        users = int.tryParse(args[++i]) ?? users;
      }
    }
    return _SeedOptions(userCount: users, replay: replay);
  }
}

Future<bool> _withReportsWritable(Future<bool> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    return await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
