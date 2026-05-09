import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/content_module_loader_service.dart';
import '../../services/module_progress_service.dart';
import '../../screens/module_catalog_screen.dart';

/// A banner that promotes the next uncompleted Core module.
///
/// Selection logic:
/// - Load the module index from assets
/// - Filter by category == 'core'
/// - Pick the first module not marked completed in ModuleProgressService
/// - If all completed or nothing found, the banner stays hidden
class MainMenuFeaturedModuleBanner extends StatefulWidget {
  const MainMenuFeaturedModuleBanner({super.key});

  @override
  State<MainMenuFeaturedModuleBanner> createState() =>
      _MainMenuFeaturedModuleBannerState();
}

class _MainMenuFeaturedModuleBannerState
    extends State<MainMenuFeaturedModuleBanner> {
  ModuleMetadata? _featured;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final index = await context
          .read<ContentModuleLoaderService>()
          .getModuleIndex();
      final progress = context.read<ModuleProgressService>();
      // Keep the listed order from the index
      final core = index.where((m) => m.category == 'core');
      final first = core.firstWhere(
        (m) => !progress.isModuleCompleted(m.id),
        orElse: () => ModuleMetadata(id: '', title: '', category: '', uri: ''),
      );
      if (!mounted) return;
      setState(() {
        _featured = first.id.isEmpty ? null : first;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _featured == null) return const SizedBox.shrink();
    final module = _featured!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.grey[850],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Featured Module',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.title.isNotEmpty ? module.title : module.id,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ModuleDetailScreen(moduleId: module.id),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
