import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/infra/telemetry_builder.dart';
import 'package:poker_analyzer/models/training_pack_meta.dart';
import 'package:poker_analyzer/ui/modules/cash_packs.dart';
import 'package:poker_analyzer/ui/modules/icm_bb_packs.dart';
import 'package:poker_analyzer/ui/modules/icm_mix_packs.dart';
import 'package:poker_analyzer/ui/modules/icm_packs.dart';
import 'package:poker_analyzer/ui/modules/icm_bubble_packs.dart';
import 'package:poker_analyzer/ui/modules/icm_ladder_packs.dart';

// ignore: unused_import
import '../../../tooling/curriculum_ids.dart' as ssot;
import 'package:poker_analyzer/content/manifest.dart';

import '../../services/spot_importer.dart';
import '../session_player/models.dart';
import '../session_player/mvs_player.dart';
import '../session_player/mini_toast.dart';
import 'package:poker_analyzer/ui_v2/widgets/section_header.dart';
import 'package:poker_analyzer/ui_v2/widgets/section_surface.dart';

class ModulesScreen extends StatefulWidget {
  final List<UiSpot> spots;
  const ModulesScreen({super.key, required this.spots});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  Future<void> _pasteSpots() async {
    final data = await Clipboard.getData('text/plain');
    final content = data?.text?.trim();
    if (content == null || content.isEmpty) {
      showMiniToast(context, 'Clipboard is empty');
      return;
    }
    try {
      // Tolerant: 'json' also accepts JSON Lines via importer fallback.
      final report = SpotImporter.parse(content, format: 'json');
      final dupToast = report.skippedDuplicates > 0
          ? ', dups ${report.skippedDuplicates}'
          : '';
      showMiniToast(
        context,
        'Imported ${report.added} (skipped ${report.skipped}$dupToast)',
      );
      for (final e in report.errors) {
        showMiniToast(context, e);
      }
      if (report.spots.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MvsSessionPlayer(spots: report.spots, packId: 'import:clipboard'),
        ),
      );
    } catch (_) {
      showMiniToast(context, 'Import failed');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Modules')),
    body: ListView(
      children: [
        SectionSurface(
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Module quick actions',
                subtitle: 'Run imports, cash packs, or custom spots',
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Start last import'),
                    onPressed: () {
                      if (widget.spots.isEmpty) {
                        showMiniToast(context, 'Import spots first');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MvsSessionPlayer(
                              spots: widget.spots,
                              packId: 'import:last',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ActionChip(
                    label: const Text('Start Cash L3'),
                    onPressed: () {
                      final spots = loadCashL3V1();
                      if (spots.isEmpty) {
                        showMiniToast(context, 'Pack is empty');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MvsSessionPlayer(
                              spots: spots,
                              packId: 'cash:l3:v1',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ActionChip(
                    label: const Text('Start ICM L4 SB'),
                    onPressed: () {
                      final spots = loadIcmL4SbV1();
                      if (spots.isEmpty) {
                        showMiniToast(context, 'Pack is empty');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MvsSessionPlayer(
                              spots: spots,
                              packId: 'icm:l4:sb:v1',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ActionChip(
                    label: const Text('Start ICM L4 BB'),
                    onPressed: () {
                      final spots = loadIcmL4BbV1();
                      if (spots.isEmpty) {
                        showMiniToast(context, 'Pack is empty');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MvsSessionPlayer(
                              spots: spots,
                              packId: 'icm:l4:bb:v1',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ActionChip(
                    label: const Text('Paste spots'),
                    onPressed: _pasteSpots,
                  ),
                  ActionChip(
                    label: const Text('Start ICM L4 Mix'),
                    onPressed: () {
                      final spots = loadIcmL4MixV1();
                      if (spots.isEmpty) {
                        showMiniToast(context, 'Pack is empty');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MvsSessionPlayer(
                              spots: spots,
                              packId: 'icm:l4:mix:v1',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ActionChip(
                    label: const Text('Start ICM L4 Bubble'),
                    onPressed: () {
                      final spots = loadIcmL4BubbleV1();
                      if (spots.isEmpty) {
                        showMiniToast(context, 'Pack is empty');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MvsSessionPlayer(
                              spots: spots,
                              packId: 'icm:l4:bubble:v1',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ActionChip(
                    label: const Text('Start ICM L4 Ladder'),
                    onPressed: () {
                      final spots = loadIcmL4LadderV1();
                      if (spots.isEmpty) {
                        showMiniToast(context, 'Pack is empty');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MvsSessionPlayer(
                              spots: spots,
                              packId: 'icm:l4:ladder:v1',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final moduleId in ssot.kCurriculumIds)
          Builder(
            builder: (context) {
              final ready = isReady(moduleId);
              final title = moduleId;
              return ListTile(
                title: Text(title),
                subtitle: Text(moduleId),
                trailing: ready ? null : const Chip(label: Text('Coming soon')),
                enabled: ready,
                onTap: ready
                    ? () {
                        unawaited(
                          Telemetry.logEvent(
                            'theory_viewed',
                            buildTheoryViewed(
                              moduleId: moduleId,
                              theoryId: 'intro',
                            ),
                          ),
                        );
                        unawaited(
                          Telemetry.logEvent(
                            'demo_completed',
                            buildDemoCompleted(
                              moduleId: moduleId,
                              demoId: 'demo1',
                            ),
                          ),
                        );
                        if (moduleId == 'cash:l3:v1') {
                          final spots = loadCashL3V1();
                          if (spots.isEmpty) {
                            showMiniToast(context, 'Pack is empty');
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MvsSessionPlayer(
                                  spots: spots,
                                  packId: 'cash:l3:v1',
                                ),
                              ),
                            );
                          }
                          return;
                        }
                        if (moduleId == 'icm:l4:ladder:v1') {
                          final spots = loadIcmL4LadderV1();
                          if (spots.isEmpty) {
                            showMiniToast(context, 'Pack is empty');
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MvsSessionPlayer(
                                  spots: spots,
                                  packId: 'icm:l4:ladder:v1',
                                ),
                              ),
                            );
                          }
                          return;
                        }
                        // fallback for other modules until wired
                        showMiniToast(context, moduleId);
                      }
                    : null,
              );
            },
          ),
      ],
    ),
  );
}

class PackCatalogTile extends StatelessWidget {
  const PackCatalogTile({super.key, required this.meta});

  final TrainingPackMeta meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difficulty = _difficultyLabel(meta.difficultyTier);
    final availability = _availabilityLabel(meta.availability);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(meta.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(difficulty, style: theme.textTheme.bodySmall),
          if (availability != null) ...[
            const SizedBox(height: 6),
            Text(availability, style: theme.textTheme.labelMedium),
          ],
        ],
      ),
    );
  }
}

String _difficultyLabel(int tier) {
  switch (tier) {
    case 3:
      return 'Advanced';
    case 2:
      return 'Intermediate';
    default:
      return 'Beginner';
  }
}

String? _availabilityLabel(PackAvailabilityV1 availability) {
  switch (availability) {
    case PackAvailabilityV1.available:
      return null;
    case PackAvailabilityV1.comingSoon:
      return 'Coming soon';
    case PackAvailabilityV1.locked:
      return 'Locked';
  }
}
