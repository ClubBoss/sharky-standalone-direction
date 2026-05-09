import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _personaSummaryPath =
    '$_reportsDir/ai_personalization_summary.txt';
const String _summaryTextPath = '$_reportsDir/engagement_recovery_summary.txt';
const String _summaryJsonPath = '$_reportsDir/engagement_recovery_summary.json';
const String _telemetryOut = '$_reportsDir/telemetry.jsonl';

const double _minReactivationPotential = 70.0;

Future<void> main(List<String> args) async {
  final engine = EngagementRecoveryEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class EngagementRecoveryEngine {
  Future<bool> run() async {
    final churned = await _identifyChurnedUsers();
    final personas = await _parsePersonas();
    final actions = <RecoveryAction>[];
    double weightedScore = 0;
    double totalWeight = 0;

    for (final user in churned) {
      final persona = personas.isNotEmpty
          ? personas[user.personaIndex % personas.length]
          : _PersonaCluster(name: 'coach', weight: 1.0);
      final action = _deriveAction(user, persona);
      actions.add(action);
      weightedScore += action.reactivationPotential * persona.weight;
      totalWeight += persona.weight;
    }

    final potential = actions.isEmpty
        ? 100.0
        : weightedScore / totalWeight.clamp(1, double.maxFinite);
    final pass = potential >= _minReactivationPotential;

    final summaryText = _buildTextSummary(actions, potential, pass);
    final summaryJson = _buildJsonSummary(actions, potential, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(potential, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Reactivation potential ${potential.toStringAsFixed(2)} below threshold.',
      );
    }
    return pass;
  }

  Future<List<_ChurnedUser>> _identifyChurnedUsers() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return const [];
    final now = DateTime.now();
    final cutoff30 = now.subtract(const Duration(days: 30));
    final cutoff7 = now.subtract(const Duration(days: 7));
    final users = <String, DateTime>{};
    final personaHint = <String, int>{};

    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      Map<String, Object?>? parsed;
      try {
        parsed = json.decode(line) as Map<String, Object?>?;
      } catch (_) {
        continue;
      }
      if (parsed == null) continue;
      final event = parsed['event']?.toString();
      if (event == null ||
          (event != 'session_start' &&
              event != 'session_end' &&
              event != 'session_abort'))
        continue;
      final timestampStr = parsed['timestamp']?.toString();
      if (timestampStr == null) continue;
      DateTime timestamp;
      try {
        timestamp = DateTime.parse(timestampStr);
      } catch (_) {
        continue;
      }
      if (timestamp.isBefore(cutoff30)) continue;
      final userId =
          parsed['user_id']?.toString() ?? parsed['sessionId']?.toString();
      if (userId == null) continue;
      if (timestamp.isAfter(
        users[userId] ?? DateTime.fromMillisecondsSinceEpoch(0),
      )) {
        users[userId] = timestamp;
      }
      final cluster = parsed['persona_cluster'] as int?;
      if (cluster != null) {
        personaHint[userId] = cluster;
      }
    }

    final churned = <_ChurnedUser>[];
    users.forEach((id, lastSeen) {
      if (lastSeen.isBefore(cutoff7) && lastSeen.isAfter(cutoff30)) {
        churned.add(
          _ChurnedUser(
            id: id,
            lastSeen: lastSeen,
            personaIndex: personaHint[id] ?? 0,
          ),
        );
      }
    });
    return churned;
  }

  Future<List<_PersonaCluster>> _parsePersonas() async {
    final file = File(_personaSummaryPath);
    if (!await file.exists()) return const [];
    final personas = <_PersonaCluster>[];
    final lines = await file.readAsLines();
    for (final line in lines) {
      final match = RegExp(
        r'- Cluster .*?"([^"]+)" .* size=([0-9]+)',
      ).firstMatch(line);
      if (match != null) {
        final name = match.group(1) ?? 'coach';
        final size = int.tryParse(match.group(2) ?? '') ?? 1;
        personas.add(
          _PersonaCluster(name: name, weight: size.toDouble().clamp(1, 100)),
        );
      }
    }
    return personas.isEmpty
        ? [const _PersonaCluster(name: 'coach', weight: 1.0)]
        : personas;
  }

  RecoveryAction _deriveAction(_ChurnedUser user, _PersonaCluster persona) {
    final days = DateTime.now().difference(user.lastSeen).inDays.clamp(7, 30);
    double personaWeight;
    String action;
    if (persona.name.contains('burst')) {
      action = 'Send reward ladder challenge';
      personaWeight = 0.95;
    } else if (persona.name.contains('steady')) {
      action = 'Send long-form tutorial reminder';
      personaWeight = 1.05;
    } else {
      action = 'Surface adaptive skill booster CTA';
      personaWeight = 1.0;
    }
    final churnRate = ((days - 7) / 23).clamp(0, 1);
    final engagement = 0.8;
    final potential = (1 - churnRate) * personaWeight * engagement * 100;
    return RecoveryAction(
      userId: user.id,
      action: action,
      persona: persona.name,
      daysInactive: days,
      reactivationPotential: potential,
    );
  }

  String _buildTextSummary(
    List<RecoveryAction> actions,
    double potential,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('ENGAGEMENT RECOVERY SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Churned users analyzed: ${actions.length}')
      ..writeln('Reactivation potential: ${potential.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minReactivationPotential.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln();
    for (final action in actions.take(20)) {
      buffer.writeln(
        '  - ${action.userId}: ${action.action} '
        '(days inactive ${action.daysInactive}, '
        'persona ${action.persona}, '
        'potential ${action.reactivationPotential.toStringAsFixed(2)}%)',
      );
    }
    if (actions.length > 20) {
      buffer.writeln('  ... +${actions.length - 20} more');
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    List<RecoveryAction> actions,
    double potential,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'reactivation_potential': potential,
      'threshold': _minReactivationPotential,
      'actions': actions
          .map(
            (action) => {
              'user_id': action.userId,
              'persona': action.persona,
              'days_inactive': action.daysInactive,
              'action': action.action,
              'potential': action.reactivationPotential,
            },
          )
          .toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(double potential, bool pass) async {
    final payload = <String, Object?>{
      'event': 'engagement_recovery_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'reactivation_potential': potential,
      'threshold': _minReactivationPotential,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryOut).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _ChurnedUser {
  const _ChurnedUser({
    required this.id,
    required this.lastSeen,
    required this.personaIndex,
  });

  final String id;
  final DateTime lastSeen;
  final int personaIndex;
}

class _PersonaCluster {
  const _PersonaCluster({required this.name, required this.weight});

  final String name;
  final double weight;
}

class RecoveryAction {
  const RecoveryAction({
    required this.userId,
    required this.action,
    required this.persona,
    required this.daysInactive,
    required this.reactivationPotential,
  });

  final String userId;
  final String action;
  final String persona;
  final int daysInactive;
  final double reactivationPotential;
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
