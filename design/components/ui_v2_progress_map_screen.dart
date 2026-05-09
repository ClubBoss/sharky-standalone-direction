import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/services/training_pack_template_service.dart';
import 'package:poker_analyzer/models/v2/training_pack_template.dart';
import 'package:poker_analyzer/screens/v2/training_pack_play_screen.dart';
import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/services/energy_service.dart';
import 'package:poker_analyzer/services/chips_wallet_service.dart';
import 'package:poker_analyzer/ui_v2/ui_v2.dart' show UiV2PremiumHub;

/// UI v2 Progress Map: adaptive grid of training packs with premium/completion badges.
class UiV2ProgressMapScreen extends StatefulWidget {
  static const String route = '/ui_v2/progress_map';

  const UiV2ProgressMapScreen({super.key});

  @override
  State<UiV2ProgressMapScreen> createState() => _UiV2ProgressMapScreenState();
}

class _UiV2ProgressMapScreenState extends State<UiV2ProgressMapScreen> {
  late Future<_ProgressState> _stateFuture;

  @override
  void initState() {
    super.initState();
    _stateFuture = _loadState();
  }

  Future<_ProgressState> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final templates = TrainingPackTemplateService.getAllTemplates(context);

    // Completed flags
    final completed = <String>{
      for (final t in templates)
        if (prefs.getBool('completed_tpl_${t.id}') == true) t.id,
    };

    // Find most recent in-progress (current) by timestamp
    String? currentId;
    int lastTs = -1;
    for (final t in templates) {
      final ts = prefs.getInt('tpl_ts_${t.id}') ?? -1;
      if (ts > lastTs) {
        lastTs = ts;
        currentId = t.id;
      }
    }

    final isPremium = await PremiumService().isPremiumActive();

    return _ProgressState(
      templates: templates,
      completed: completed,
      currentId: currentId,
      isPremium: isPremium,
    );
  }

  bool _isPremiumPack(TrainingPackTemplate tpl) {
    // Heuristics: explicit meta flag or tag; otherwise consider advanced stacks premium (>= 15bb)
    final metaPremium = (tpl.meta['premium'] == true);
    final tagPremium = tpl.tags.any((t) => t.toLowerCase().contains('premium'));
    final advanced = tpl.heroBbStack >= 15 && tpl.spotCount >= 20;
    return metaPremium || tagPremium || advanced;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Map'),
        actions: [
          FutureBuilder<int>(
            future: EnergyService().getCurrentEnergy(),
            builder: (context, snapshot) {
              final energy = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Text(
                    '\u26A1 $energy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: energy > 0 ? Colors.yellowAccent : Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
          FutureBuilder<int>(
            future: ChipsWalletService().getBalance(),
            builder: (context, snapshot) {
              final chips = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    '\uD83D\uDCB0 $chips',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<_ProgressState>(
        future: _stateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data =
              snapshot.data ??
              _ProgressState(
                templates: const [],
                completed: const {},
                currentId: null,
                isPremium: false,
              );
          if (data.templates.isEmpty) {
            return const Center(child: Text('No training packs found'));
          }
          // Adaptive columns by width
          final width = MediaQuery.of(context).size.width;
          final cross = width >= 1200
              ? 5
              : width >= 900
              ? 4
              : width >= 600
              ? 3
              : 2;
          return GridView.builder(
            padding: EdgeInsets.all(brand?.spacingMedium ?? 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: brand?.spacingMedium ?? 16,
              crossAxisSpacing: brand?.spacingMedium ?? 16,
              childAspectRatio: 4 / 3,
            ),
            itemCount: data.templates.length,
            itemBuilder: (context, i) {
              final tpl = data.templates[i];
              final isCompleted = data.completed.contains(tpl.id);
              final isCurrent = data.currentId == tpl.id;
              final premiumPack = _isPremiumPack(tpl);
              return _PackCard(
                template: tpl,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isPremiumPack: premiumPack,
                premiumActive: data.isPremium,
                onOpen: () async {
                  if (premiumPack && !data.isPremium) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Premium required'),
                        action: SnackBarAction(
                          label: 'Upgrade',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const UiV2PremiumHub(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                    return;
                  }
                  if (!context.mounted) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          TrainingPackPlayScreen(template: tpl, original: tpl),
                    ),
                  );
                  if (!mounted) return;
                  setState(() => _stateFuture = _loadState());
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final TrainingPackTemplate template;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPremiumPack;
  final bool premiumActive;
  final VoidCallback onOpen;

  const _PackCard({
    required this.template,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPremiumPack,
    required this.premiumActive,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    return InkWell(
      borderRadius: BorderRadius.circular((brand?.radius ?? 12).toDouble()),
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular((brand?.radius ?? 12).toDouble()),
          border: Border.all(color: AppColors.outlineSoft),
        ),
        padding: EdgeInsets.all(brand?.spacingMedium ?? 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (isPremiumPack)
                  Icon(
                    Icons.star,
                    color: premiumActive
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary.withValues(alpha: .7),
                    size: 20,
                  ),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 8,
              children: [
                if (isCurrent)
                  const _Badge(icon: Icons.play_circle, label: 'Current'),
                if (isCompleted)
                  const _Badge(icon: Icons.check_circle, label: 'Done'),
                _Badge(
                  icon: Icons.assessment,
                  label: '${template.spotCount} spots',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProgressState {
  final List<TrainingPackTemplate> templates;
  final Set<String> completed;
  final String? currentId;
  final bool isPremium;
  const _ProgressState({
    required this.templates,
    required this.completed,
    required this.currentId,
    required this.isPremium,
  });
}

/// Premium Hub route class reference for navigation without importing from here.
// Route name exposed via UiV2PremiumHub.route
