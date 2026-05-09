import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/training_coverage_service.dart';
import '../pack_coverage_stats_screen.dart';
import '../theory_coverage_dashboard.dart';
import '../yaml_coverage_stats_screen.dart';
import '../pack_tag_counter_debugger_screen.dart';

class CoverageSection extends StatefulWidget {
  CoverageSection({super.key});

  @override
  State<CoverageSection> createState() => _CoverageSectionState();
}

class _CoverageSectionState extends State<CoverageSection> {
  bool _exporting = false;

  Future<void> _exportCoverage() async {
    if (_exporting || !kDebugMode) return;
    setState(() => _exporting = true);
    final ok = await compute(_coverageTask, '');
    if (!mounted) return;
    setState(() => _exporting = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(ok ? 'Готово' : 'Ошибка')));
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (kDebugMode)
        ListTile(
          title: const Text('📊 Покрытие тем (coverage_report.json)'),
          onTap: _exporting ? null : _exportCoverage,
        ),
      if (kDebugMode)
        ListTile(
          title: const Text('📊 Покрытие YAML'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => YamlCoverageStatsScreen()),
            );
          },
        ),
      if (kDebugMode)
        ListTile(
          title: const Text('📊 Pack Coverage Stats'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PackCoverageStatsScreen()),
            );
          },
        ),
      if (kDebugMode)
        ListTile(
          title: const Text('📊 Tag Coverage'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PackTagCounterDebuggerScreen()),
            );
          },
        ),
      if (kDebugMode)
        ListTile(
          title: const Text('📊 Theory Coverage Dashboard'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TheoryCoverageDashboard()),
            );
          },
        ),
    ],
  );
}

Future<bool> _coverageTask(String _) async {
  try {
    await TrainingCoverageService().exportCoverageReport();
    return true;
  } catch (_) {
    return false;
  }
}
