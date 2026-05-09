import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/content_module_loader_service.dart';
import '../services/module_progress_service.dart';
import '../services/xp_service.dart';
import '../services/drill_award_session_guard.dart';
import '../widgets/xp_award_badge.dart';
import '../widgets/xp_session_recap_banner.dart';

/// Example screen showing how to use ContentModuleLoaderService
///
/// This screen displays all available training modules organized by category.
/// Users can tap a module to view its theory content, drills, and demos.
class ModuleCatalogScreen extends StatefulWidget {
  ModuleCatalogScreen({super.key});

  @override
  State<ModuleCatalogScreen> createState() => _ModuleCatalogScreenState();
}

class _ModuleCatalogScreenState extends State<ModuleCatalogScreen> {
  String? _selectedCategory;
  CompletionFilter _completionFilter = CompletionFilter.all;
  List<ModuleMetadata> _modules = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  int _progressVersion = 0; // Track progress changes

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload modules when progress changes
    final progressService = context.watch<ModuleProgressService>();
    final currentVersion = progressService.getCompletedCount();

    if (currentVersion != _progressVersion) {
      _progressVersion = currentVersion;
      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadModules();
        }
      });
    }
  }

  Future<void> _loadModules() async {
    setState(() => _loading = true);

    try {
      final service = context.read<ContentModuleLoaderService>();

      _modules = await service.getModulesByCompletion(
        _completionFilter,
        category: _selectedCategory,
        query: _query.isEmpty ? null : _query,
      );
    } catch (e) {
      print('Error loading modules: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Training Module Catalog'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: _TotalXpBadge(),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String?>(
          icon: const Icon(Icons.filter_list),
          onSelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
            _loadModules();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: null, child: Text('All Categories')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'core', child: Text('Core')),
            const PopupMenuItem(value: 'cash', child: Text('Cash')),
            const PopupMenuItem(value: 'mtt', child: Text('MTT')),
            const PopupMenuItem(value: 'hu', child: Text('Heads-Up')),
            const PopupMenuItem(value: 'icm', child: Text('ICM')),
            const PopupMenuItem(value: 'math', child: Text('Math')),
            const PopupMenuItem(value: 'online', child: Text('Online')),
            const PopupMenuItem(value: 'live', child: Text('Live')),
            const PopupMenuItem(value: 'misc', child: Text('Misc')),
          ],
        ),
      ],
    ),
    body: Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Search modules',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                        _loadModules();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                setState(() {
                  _query = value;
                });
                _loadModules();
              });
            },
          ),
        ),
        // Completion filter toggle
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<CompletionFilter>(
            segments: const [
              ButtonSegment(
                value: CompletionFilter.all,
                label: Text('All'),
                icon: Icon(Icons.apps),
              ),
              ButtonSegment(
                value: CompletionFilter.completed,
                label: Text('Completed'),
                icon: Icon(Icons.check_circle),
              ),
              ButtonSegment(
                value: CompletionFilter.incomplete,
                label: Text('Incomplete'),
                icon: Icon(Icons.circle_outlined),
              ),
            ],
            selected: {_completionFilter},
            onSelectionChanged: (selected) {
              setState(() {
                _completionFilter = selected.first;
              });
              _loadModules();
            },
          ),
        ),
        // Module list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _modules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _query.isNotEmpty
                            ? Icons.search_off
                            : _completionFilter == CompletionFilter.completed
                            ? Icons.assignment_turned_in_outlined
                            : Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _query.isNotEmpty
                            ? 'No matching modules found'
                            : _completionFilter == CompletionFilter.completed
                            ? 'No completed modules yet'
                            : _completionFilter == CompletionFilter.incomplete
                            ? 'All modules completed!'
                            : 'No modules found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _query.isNotEmpty
                            ? 'Try another search term'
                            : _completionFilter == CompletionFilter.completed
                            ? 'Start learning to track your progress'
                            : _completionFilter == CompletionFilter.incomplete
                            ? 'Great job! You\'ve completed everything'
                            : 'Try changing the filter',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _modules.length,
                  itemBuilder: (context, index) {
                    final module = _modules[index];
                    return _ModuleListTile(metadata: module);
                  },
                ),
        ),
      ],
    ),
  );
}

/// Small XP badge shown under the AppBar title, aligned to the right.
class _TotalXpBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the service via context.watch() so the widget rebuilds if the provider changes.
    final xpService = context.watch<XpService>();

    return StreamBuilder<int>(
      stream: xpService.watchTotalXp(),
      initialData: 0,
      builder: (context, snapshot) {
        final totalXp = snapshot.data ?? 0;
        final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
        final fg = Theme.of(context).colorScheme.onSurfaceVariant;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, size: 14, color: fg.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(
                'XP:',
                style: TextStyle(
                  fontSize: 12,
                  color: fg.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$totalXp',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: fg,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModuleListTile extends StatelessWidget {
  final ModuleMetadata metadata;

  const _ModuleListTile({required this.metadata});

  @override
  Widget build(BuildContext context) {
    final progressService = context.watch<ModuleProgressService>();
    final isCompleted = progressService.isModuleCompleted(metadata.id);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCompleted ? Colors.green : null,
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white)
            : Text(metadata.category.substring(0, 1).toUpperCase()),
      ),
      title: Row(
        children: [
          Expanded(child: Text(metadata.title)),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
      subtitle: Text('${metadata.category} • ${metadata.id}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModuleDetailScreen(moduleId: metadata.id),
          ),
        );
      },
    );
  }
}

/// Detail screen showing full module content
class ModuleDetailScreen extends StatefulWidget {
  final String moduleId;

  ModuleDetailScreen({super.key, required this.moduleId});

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen>
    with SingleTickerProviderStateMixin {
  TrainingModule? _module;
  bool _loading = true;
  late TabController _tabController;
  bool _awardedTheoryXp = false;
  final DrillAwardSessionGuard _drillGuard = DrillAwardSessionGuard();
  bool _showXpBadge = false;
  Timer? _xpBadgeTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _tabController.index == 0 &&
          !_awardedTheoryXp) {
        // Award +1 XP for viewing Theory tab (once per screen session)
        context.read<XpService>().awardTheoryView(widget.moduleId);
        _awardedTheoryXp = true;
      }
    });
    _loadModule();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _xpBadgeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadModule() async {
    setState(() => _loading = true);

    try {
      final service = context.read<ContentModuleLoaderService>();
      final module = await service.loadModule(widget.moduleId);

      setState(() {
        _module = module;
        _loading = false;
      });
      // If Theory tab is already selected, award XP
      if (_tabController.index == 0 && !_awardedTheoryXp) {
        context.read<XpService>().awardTheoryView(widget.moduleId);
        _awardedTheoryXp = true;
      }
    } catch (e) {
      print('Error loading module: $e');
      setState(() => _loading = false);
    }
  }

  void _triggerXpBadge() {
    setState(() => _showXpBadge = true);
    _xpBadgeTimer?.cancel();
    _xpBadgeTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showXpBadge = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressService = context.watch<ModuleProgressService>();
    final isCompleted =
        _module != null && progressService.isModuleCompleted(widget.moduleId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_module?.title ?? widget.moduleId),
        actions: [
          if (_module != null) ...[
            // Share button - only visible when module is completed
            if (isCompleted)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  final moduleName = _module?.title ?? widget.moduleId;
                  final text =
                      'I just completed the module "$moduleName" in Poker Analyzer!\nhttps://pokeranalyzer.app';
                  await Share.share(text);
                },
                tooltip: 'Share',
              ),
            // Completion toggle button
            IconButton(
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                color: isCompleted ? Colors.green : null,
              ),
              onPressed: () async {
                if (isCompleted) {
                  await progressService.markModuleIncomplete(widget.moduleId);
                } else {
                  // Mark as completed and award XP
                  final wasNewlyCompleted = await progressService
                      .markModuleCompleted(widget.moduleId);
                  // Award +10 XP once for completing module
                  final xpAwarded = await context
                      .read<XpService>()
                      .awardModuleCompleted(widget.moduleId);
                  // Show XP badge only if this was a new completion
                  if (wasNewlyCompleted && xpAwarded) {
                    _triggerXpBadge();
                  }
                }
                // Refresh the module to update completion status
                context
                    .read<ContentModuleLoaderService>()
                    .refreshModuleCompletion(widget.moduleId);
                setState(() {});
              },
              tooltip: isCompleted ? 'Mark as incomplete' : 'Mark as completed',
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Theory', icon: Icon(Icons.book)),
            Tab(text: 'Drills', icon: Icon(Icons.quiz)),
            Tab(text: 'Demos', icon: Icon(Icons.play_circle)),
          ],
        ),
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _module == null
              ? const Center(child: Text('Module not found'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _TheoryTab(module: _module!, moduleId: widget.moduleId),
                    _DrillsTab(
                      module: _module!,
                      moduleId: widget.moduleId,
                      guard: _drillGuard,
                    ),
                    _DemosTab(module: _module!),
                  ],
                ),
          XpAwardBadge(visible: _showXpBadge, overrideXp: 10),
        ],
      ),
    );
  }
}

class _TheoryTab extends StatefulWidget {
  final TrainingModule module;
  final String moduleId;

  const _TheoryTab({required this.module, required this.moduleId});

  @override
  State<_TheoryTab> createState() => _TheoryTabState();
}

class _TheoryTabState extends State<_TheoryTab> {
  bool _showRecapBanner = false;

  @override
  Widget build(BuildContext context) {
    final progressService = context.watch<ModuleProgressService>();
    final isCompleted = progressService.isModuleCompleted(widget.moduleId);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('What it is'),
                _buildSection('Why it matters'),
                _buildSection('Rules of thumb'),
                _buildSection('Mini example'),
                _buildSection('Common mistakes'),
                _buildSection('Mini-glossary'),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (_showRecapBanner) const XpSessionRecapBanner(xp: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isCompleted) {
                        await progressService.markModuleIncomplete(
                          widget.moduleId,
                        );
                        setState(() => _showRecapBanner = false);
                      } else {
                        final wasNewlyCompleted = await progressService
                            .markModuleCompleted(widget.moduleId);
                        // Award +10 XP once for completing module
                        final xpAwarded = await context
                            .read<XpService>()
                            .awardModuleCompleted(widget.moduleId);
                        if (wasNewlyCompleted && xpAwarded) {
                          setState(() => _showRecapBanner = true);
                        }
                      }
                      // Refresh the module in cache
                      context
                          .read<ContentModuleLoaderService>()
                          .refreshModuleCompletion(widget.moduleId);
                    },
                    icon: Icon(isCompleted ? Icons.replay : Icons.check),
                    label: Text(
                      isCompleted ? 'Mark as Incomplete' : 'Mark as Completed',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.grey : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String sectionName) {
    final content = widget.module.getTheorySection(sectionName);

    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}

class _DrillsTab extends StatefulWidget {
  final TrainingModule module;
  final String moduleId;
  final DrillAwardSessionGuard guard;

  const _DrillsTab({
    required this.module,
    required this.moduleId,
    required this.guard,
  });

  @override
  State<_DrillsTab> createState() => _DrillsTabState();
}

class _DrillsTabState extends State<_DrillsTab> {
  final Set<int> _flash = <int>{};

  @override
  Widget build(BuildContext context) {
    if (widget.module.drills.isEmpty) {
      return const Center(child: Text('No drills available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.module.drills.length,
      itemBuilder: (context, index) {
        final drill = widget.module.drills[index];
        return Stack(
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Drill ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('Difficulty ${drill.difficulty}'),
                          backgroundColor: _difficultyColor(drill.difficulty),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      drill.prompt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      title: const Text('Show Answer'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Answer: ${drill.answer}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(drill.rationale),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _buildAwardButton(context, index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // "+5 XP" transient overlay
            Positioned(
              right: 16,
              top: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _flash.contains(index) ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        '+5 XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAwardButton(BuildContext context, int index) {
    final already = widget.guard.isAwarded(widget.moduleId, index);
    if (already) {
      return const Chip(
        label: Text('Awarded +5 XP'),
        avatar: Icon(Icons.check, size: 16),
      );
    }

    return ElevatedButton.icon(
      onPressed: () async {
        final ok = widget.guard.shouldAward(widget.moduleId, index);
        if (!ok) {
          return;
        }
        await context.read<XpService>().awardDrillCompleted(widget.moduleId);
        setState(() {
          _flash.add(index);
        });
        // hide flash after delay
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            _flash.remove(index);
          });
        });
      },
      icon: const Icon(Icons.verified, size: 18),
      label: const Text('I was correct (+5 XP)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _difficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green.shade100;
      case 2:
        return Colors.blue.shade100;
      case 3:
        return Colors.orange.shade100;
      case 4:
        return Colors.red.shade100;
      case 5:
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}

class _DemosTab extends StatelessWidget {
  final TrainingModule module;

  const _DemosTab({required this.module});

  @override
  Widget build(BuildContext context) {
    if (module.demos.isEmpty) {
      return const Center(child: Text('No demos available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: module.demos.length,
      itemBuilder: (context, index) {
        final demo = module.demos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...demo.steps.asMap().entries.map((entry) {
                  final stepIndex = entry.key;
                  final step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          child: Text('${stepIndex + 1}'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (demo.tokens.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: demo.tokens
                        .map((token) => Chip(label: Text(token)))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
