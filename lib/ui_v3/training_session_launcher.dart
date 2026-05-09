import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/user_path_profile.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class TrainingSessionLauncher extends StatefulWidget {
  const TrainingSessionLauncher({super.key, this.profile});

  final UserPathProfile? profile;

  @override
  State<TrainingSessionLauncher> createState() =>
      _TrainingSessionLauncherState();
}

class _TrainingSessionLauncherState extends State<TrainingSessionLauncher> {
  late Future<List<_PackSummary>> _packsFuture;

  @override
  void initState() {
    super.initState();
    _packsFuture = _loadPacks();
    FirebaseLiteTelemetryService.instance.logEvent('training_launcher_opened');
  }

  Future<List<_PackSummary>> _loadPacks() async {
    final discipline = widget.profile?.discipline ?? 'Cash Games';
    final normalized = _normalizeDiscipline(discipline);
    final root = Directory('content');
    if (!await root.exists()) {
      return const <_PackSummary>[];
    }
    final summaries = <_PackSummary>[];
    await for (final entity in root.list()) {
      if (entity is! Directory) continue;
      final pathLower = entity.path.toLowerCase();
      if (normalized != 'other' && !pathLower.contains(normalized)) continue;
      final v1 = Directory('${entity.path}/v1');
      if (!await v1.exists()) continue;
      final spec = File('${v1.path}/spec.yml');
      final drills = File('${v1.path}/drills.jsonl');
      final demos = File('${v1.path}/demos.jsonl');
      final theory = File('${v1.path}/theory.md');
      if (!await spec.exists()) continue;
      final meta = await spec.readAsString();
      final title = _extractTitle(meta) ?? entity.path.split('/').last;
      final drillsCount = await _countJsonLines(drills);
      final demosCount = await _countJsonLines(demos);
      final theoryLines = await theory.exists()
          ? (await theory.readAsLines()).length
          : 0;
      final total = drillsCount + demosCount + (theoryLines > 0 ? 1 : 0);
      summaries.add(
        _PackSummary(
          id: entity.path,
          title: title,
          drills: drillsCount,
          demos: demosCount,
          theoryLines: theoryLines,
          completed: 0,
          total: total == 0 ? 1 : total,
        ),
      );
    }
    return summaries;
  }

  String? _extractTitle(String yaml) {
    for (final line in yaml.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('title:')) {
        return trimmed.substring('title:'.length).trim().replaceAll('"', '');
      }
    }
    return null;
  }

  String _normalizeDiscipline(String discipline) {
    final lower = discipline.toLowerCase();
    if (lower.contains('cash')) return 'cash';
    if (lower.contains('mtt')) return 'mtt';
    if (lower.contains('live')) return 'live';
    return 'other';
  }

  Future<int> _countJsonLines(File file) async {
    if (!await file.exists()) return 0;
    var count = 0;
    await for (final line
        in file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (line.trim().isEmpty) continue;
      count += 1;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: VisualThemeV3.theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Training Packs')),
        body: FutureBuilder<List<_PackSummary>>(
          future: _packsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final packs = snapshot.data ?? const <_PackSummary>[];
            if (packs.isEmpty) {
              return const Center(
                child: Text('No packs found for this discipline.'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(VisualThemeV3.spacingM),
              itemCount: packs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: VisualThemeV3.spacingM),
              itemBuilder: (context, index) =>
                  _buildPackCard(context, packs[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPackCard(BuildContext context, _PackSummary pack) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = pack.completed / pack.total;
    return AnimatedContainer(
      duration: VisualThemeV3.speedNormal,
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pack.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: VisualThemeV3.spacingS),
          Text('Theory lines: ${pack.theoryLines}'),
          Text('Drills: ${pack.drills}  Demos: ${pack.demos}'),
          const SizedBox(height: VisualThemeV3.spacingS),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: VisualThemeV3.spacingS),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _startPack(pack),
              child: const Text('Start'),
            ),
          ),
        ],
      ),
    );
  }

  void _startPack(_PackSummary pack) {
    FirebaseLiteTelemetryService.instance.logEvent(
      'pack_selected',
      params: {'pack_id': pack.id, 'title': pack.title},
    );
    FirebaseLiteTelemetryService.instance.logEvent(
      'session_started',
      params: {'pack_id': pack.id},
    );
    // TODO(Φ5): launch simulation session
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preparing session for ${pack.title}...')),
    );
  }
}

class _PackSummary {
  const _PackSummary({
    required this.id,
    required this.title,
    required this.drills,
    required this.demos,
    required this.theoryLines,
    required this.completed,
    required this.total,
  });

  final String id;
  final String title;
  final int drills;
  final int demos;
  final int theoryLines;
  final int completed;
  final int total;
}
