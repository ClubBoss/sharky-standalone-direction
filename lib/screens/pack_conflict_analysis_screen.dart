import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/pack_library_loader_service.dart';
import '../services/yaml_pack_conflict_detector.dart';
import '../theme/app_colors.dart';

class PackConflictAnalysisScreen extends StatefulWidget {
  PackConflictAnalysisScreen({super.key});
  @override
  State<PackConflictAnalysisScreen> createState() =>
      _PackConflictAnalysisScreenState();
}

class _PackConflictAnalysisScreenState
    extends State<PackConflictAnalysisScreen> {
  bool _loading = true;
  final List<YamlPackConflict> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await PackLibraryLoaderService.instance.loadLibrary();
    final list = PackLibraryLoaderService.instance.library;
    final res = YamlPackConflictDetector().detectConflicts(list);
    if (!mounted) return;
    setState(() {
      _items
        ..clear()
        ..addAll(res);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Анализ конфликтов')),
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
                for (final c in _items)
                  ListTile(
                    title: Text('${c.packA.name} ↔ ${c.packB.name}'),
                    subtitle: Text(
                      '${c.type} ${(c.similarityScore * 100).toStringAsFixed(0)}%',
                    ),
                  ),
              ],
            ),
    );
  }
}
