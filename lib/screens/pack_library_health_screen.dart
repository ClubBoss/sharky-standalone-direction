import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/training_pack_health_report_service.dart';
import '../models/training_health_report.dart';
import '../theme/app_colors.dart';

class PackLibraryHealthScreen extends StatefulWidget {
  PackLibraryHealthScreen({super.key});

  @override
  State<PackLibraryHealthScreen> createState() =>
      _PackLibraryHealthScreenState();
}

class _PackLibraryHealthScreenState extends State<PackLibraryHealthScreen> {
  bool _loading = true;
  final List<(String, String)> _issues = [];
  int _errors = 0;
  int _warnings = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final map = await compute(_healthTask, '');
    if (!mounted) return;
    final report = TrainingHealthReport.fromJson(map);
    setState(() {
      _issues
        ..clear()
        ..addAll(report.issues);
      _errors = report.errors;
      _warnings = report.warnings;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Проверка библиотеки')),
    backgroundColor: AppColors.background,
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ElevatedButton(
                onPressed: _load,
                child: const Text('🔄 Обновить'),
              ),
              const SizedBox(height: 16),
              Text('Ошибок: $_errors, Предупреждений: $_warnings'),
              const SizedBox(height: 16),
              for (final i in _issues)
                ListTile(
                  title: Text(
                    File(i.$1).path.split(Platform.pathSeparator).last,
                  ),
                  subtitle: Text(i.$2),
                ),
            ],
          ),
  );
}

Future<Map<String, dynamic>> _healthTask(String _) async {
  final report = await TrainingPackHealthReportService().generateReport();
  return report.toJson();
}
