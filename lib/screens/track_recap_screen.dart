import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/v3/lesson_track.dart';
import '../models/v3/lesson_step.dart';
import '../models/player_profile.dart';
import '../services/lesson_loader_service.dart';
import '../services/lesson_path_progress_service.dart';
import '../services/learning_track_engine.dart';
import '../services/track_visibility_filter_engine.dart';
import '../services/tag_mastery_service.dart';
import '../screens/lesson_track_library_screen.dart';

class TrackRecapScreen extends StatefulWidget {
  final LessonTrack track;
  TrackRecapScreen({super.key, required this.track});

  @override
  State<TrackRecapScreen> createState() => _TrackRecapScreenState();
}

class _TrackRecapScreenState extends State<TrackRecapScreen> {
  bool _loading = true;
  List<LessonStep> _steps = [];
  Map<String, double> _mastery = {};
  LessonTrack? _next;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allSteps = await LessonLoaderService.instance.loadAllLessons();
    _steps = [
      for (final id in widget.track.stepIds)
        allSteps.firstWhereOrNull((s) => s.id == id),
    ].whereType<LessonStep>().toList();

    final masteryService = context.read<TagMasteryService>();
    final masteryMap = await masteryService.computeMastery();
    final entries = masteryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _mastery = {for (final e in entries.take(5)) e.key: e.value};

    final path = LessonPathProgressService.instance;
    final progress = await path.computeTrackProgress();
    final tracks = LearningTrackEngine().getTracks();
    final profile = PlayerProfile();
    final visible = await TrackVisibilityFilterEngine().filterUnlockedTracks(
      tracks,
      profile,
    );
    _next = visible.firstWhereOrNull(
      (t) => t.id != widget.track.id && (progress[t.id] ?? 0) < 100,
    );

    if (mounted) setState(() => _loading = false);
  }

  void _openLibrary() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LessonTrackLibraryScreen()),
    );
  }

  Widget _buildMasteryChart(Color accent) {
    if (_mastery.isEmpty) return const SizedBox.shrink();
    final labels = _mastery.keys.toList();
    final values = _mastery.values.toList();
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < values.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i],
              width: 14,
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [accent.withValues(alpha: 0.7), accent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: 1,
          minY: 0,
          alignment: BarChartAlignment.spaceBetween,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    labels[i],
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: groups,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(title: const Text('Резюме трека')),
      backgroundColor: const Color(0xFF121212),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '🎉 ${widget.track.title} завершён',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Вы прошли все уроки этого трека. Отличная работа!',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                if (_steps.isNotEmpty) ...[
                  const Text(
                    'Выполненные шаги:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final s in _steps)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '✔ ${s.title}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                if (_mastery.isNotEmpty) ...[
                  const Text(
                    'Сильные стороны:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMasteryChart(accent),
                  const SizedBox(height: 16),
                ],
                if (_next != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _openLibrary,
                      style: ElevatedButton.styleFrom(backgroundColor: accent),
                      child: const Text('Начать следующий трек'),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text('В меню'),
                    ),
                  ),
              ],
            ),
    );
  }
}
