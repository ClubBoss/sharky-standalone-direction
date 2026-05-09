import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ux_emotional_resonance_service.dart';

const String _reportsDir = 'release/_reports';
const String _profilesDir = 'release/_profiles';
const String _statsPath = '$_reportsDir/player_stats_profile.json';
const String _traitsPath = '$_reportsDir/player_traits_profile.json';

class ProfilePersistenceService {
  ProfilePersistenceService({UxEmotionalResonanceService? resonanceService})
    : _resonanceService = resonanceService ?? UxEmotionalResonanceService();

  final UxEmotionalResonanceService _resonanceService;

  Future<PlayerProfileSnapshot?> saveProfile(String id) async {
    final snapshot = await _captureSnapshot(id);
    if (snapshot == null) return null;
    await _withProfilesWritable(() async {
      final file = File('$_profilesDir/profile_$id.json');
      await file.create(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(snapshot.toJson()),
      );
    });
    return snapshot;
  }

  Future<PlayerProfileSnapshot?> loadProfile(String id) async {
    final file = File('$_profilesDir/profile_$id.json');
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return PlayerProfileSnapshot.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<bool> verifyIntegrity(String id) async {
    final snapshot = await loadProfile(id);
    if (snapshot == null) return false;
    if (snapshot.mastery.isEmpty || snapshot.traits.isEmpty) return false;
    if (snapshot.xpTotal <= 0 || snapshot.uxResonance <= 0) return false;
    return snapshot.mastery.every(
          (m) =>
              m.progress >= 0 &&
              m.progress <= 1 &&
              m.level > 0 &&
              m.name.isNotEmpty,
        ) &&
        snapshot.traits.every((t) => t.name.isNotEmpty && t.rarity.isNotEmpty);
  }

  Future<void> syncWithRemote(String id) async {
    // Stub: simulate upload latency.
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Future<PlayerProfileSnapshot?> _captureSnapshot(String id) async {
    final stats = await _readJson(_statsPath);
    final traitsJson = await _readJson(_traitsPath);
    if (stats == null || traitsJson == null) return null;
    final mastery = <MasteryProgress>[];
    double xpTotal = 0;
    stats.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final level = (value['level'] as num?)?.toInt() ?? 0;
        final progress = (value['progress_0_1'] as num?)?.toDouble() ?? 0.0;
        final xp = (value['xp'] as num?)?.toDouble() ?? 0;
        xpTotal += xp;
        mastery.add(
          MasteryProgress(
            name: key,
            level: level,
            progress: progress.clamp(0, 1).toDouble(),
            xp: xp,
          ),
        );
      }
    });

    final traitsRaw = traitsJson['traits'];
    if (traitsRaw is! List) return null;
    final traits = traitsRaw
        .whereType<Map<String, dynamic>>()
        .map(
          (map) => PlayerTrait(
            name: map['name']?.toString() ?? 'unknown',
            rarity: map['rarity']?.toString() ?? 'Common',
            temporary: map['temporary'] == true,
          ),
        )
        .toList();

    final resonanceResult = await _resonanceService.calculate();
    final resonance = (resonanceResult.globalScore / 100)
        .clamp(0, 1)
        .toDouble();

    return PlayerProfileSnapshot(
      id: id,
      savedAt: DateTime.now().toIso8601String(),
      xpTotal: xpTotal,
      mastery: mastery,
      traits: traits,
      uxResonance: resonance,
    );
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

class PlayerProfileSnapshot {
  const PlayerProfileSnapshot({
    required this.id,
    required this.savedAt,
    required this.xpTotal,
    required this.mastery,
    required this.traits,
    required this.uxResonance,
  });

  final String id;
  final String savedAt;
  final double xpTotal;
  final List<MasteryProgress> mastery;
  final List<PlayerTrait> traits;
  final double uxResonance;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'saved_at': savedAt,
      'xp_total': xpTotal,
      'ux_resonance': uxResonance,
      'mastery': mastery.map((m) => m.toJson()).toList(),
      'traits': traits.map((t) => t.toJson()).toList(),
    };
  }

  static PlayerProfileSnapshot fromJson(Map<String, dynamic> json) {
    return PlayerProfileSnapshot(
      id: json['id']?.toString() ?? 'unknown',
      savedAt: json['saved_at']?.toString() ?? '',
      xpTotal: (json['xp_total'] as num?)?.toDouble() ?? 0,
      uxResonance: (json['ux_resonance'] as num?)?.toDouble() ?? 0,
      mastery: (json['mastery'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MasteryProgress.fromJson)
          .toList(),
      traits: (json['traits'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PlayerTrait.fromJson)
          .toList(),
    );
  }
}

class MasteryProgress {
  const MasteryProgress({
    required this.name,
    required this.level,
    required this.progress,
    required this.xp,
  });

  final String name;
  final int level;
  final double progress;
  final double xp;

  Map<String, Object?> toJson() {
    return {'name': name, 'level': level, 'progress': progress, 'xp': xp};
  }

  static MasteryProgress fromJson(Map<String, dynamic> json) {
    return MasteryProgress(
      name: json['name']?.toString() ?? 'unknown',
      level: (json['level'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      xp: (json['xp'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PlayerTrait {
  const PlayerTrait({
    required this.name,
    required this.rarity,
    required this.temporary,
  });

  final String name;
  final String rarity;
  final bool temporary;

  Map<String, Object?> toJson() {
    return {'name': name, 'rarity': rarity, 'temporary': temporary};
  }

  static PlayerTrait fromJson(Map<String, dynamic> json) {
    return PlayerTrait(
      name: json['name']?.toString() ?? 'unknown',
      rarity: json['rarity']?.toString() ?? 'Common',
      temporary: json['temporary'] == true,
    );
  }
}

Future<void> _withProfilesWritable(Future<void> Function() action) async {
  final dir = Directory(_profilesDir);
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
