import "dart:core" as core;
import 'dart:core';
import 'package:flutter/material.dart';

class TrainingTplFabPanel extends StatelessWidget {
  late final bool narrow;
  final VoidCallback onShowFilters;
  final VoidCallback onQuickGenerate;
  final VoidCallback onGenerateFinalTable;
  final VoidCallback onGenerateFavorites;

  const TrainingTplFabPanel({
    super.key,
    required this.narrow,
    required this.onShowFilters,
    required this.onQuickGenerate,
    required this.onGenerateFinalTable,
    required this.onGenerateFavorites,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (narrow)
        FloatingActionButton(
          heroTag: 'filterTplFab',
          onPressed: onShowFilters,
          child: const Icon(Icons.filter_list),
        ),
      if (narrow) const SizedBox(height: 12),
      FloatingActionButton.extended(
        heroTag: 'quickGenTplFab',
        onPressed: onQuickGenerate,
        label: const Text('Quick Generate'),
      ),
      const SizedBox(height: 12),
      FloatingActionButton.extended(
        heroTag: 'finalTableTplFab',
        onPressed: onGenerateFinalTable,
        tooltip: 'Generate Final Table Pack',
        label: const Text('Final Table'),
      ),
      const SizedBox(height: 12),
      FloatingActionButton.extended(
        heroTag: 'favoritesTplFab',
        onPressed: onGenerateFavorites,
        icon: const Icon(Icons.star),
        label: const Text('Favorites Pack'),
      ),
    ],
  );
}
