// ignore_for_file: unused_element, unused_element_parameter, prefer_expression_function_bodies

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/action_entry.dart';
import '../models/player_model.dart' show PlayerType;
import '../services/action_history_service.dart';
import '../services/pot_sync_service.dart';
import '../theme/app_colors.dart';
import '../widgets/collapsible_action_history.dart';
import '../widgets/street_actions_list.dart';

class _CollapsibleActionHistorySection extends StatelessWidget {
  final ActionHistoryService actionHistory;
  final Map<int, String> playerPositions;
  final int heroIndex;
  const _CollapsibleActionHistorySection({
    required this.actionHistory,
    required this.playerPositions,
    required this.heroIndex,
  });
  @override
  Widget build(BuildContext context) {
    return CollapsibleActionHistory(
      actionHistory: actionHistory,
      playerPositions: playerPositions,
      heroIndex: heroIndex,
    );
  }
}

class _HandNotesSection extends StatelessWidget {
  final TextEditingController commentController;
  final TextEditingController tagsController;
  const _HandNotesSection({
    required this.commentController,
    required this.tagsController,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: commentController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Комментарий к раздаче',
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: tagsController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Теги',
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TournamentInfoSection extends StatefulWidget {
  final TextEditingController idController;
  final TextEditingController buyInController;
  final TextEditingController prizePoolController;
  final TextEditingController entrantsController;
  final TextEditingController gameTypeController;
  const _TournamentInfoSection({
    required this.idController,
    required this.buyInController,
    required this.prizePoolController,
    required this.entrantsController,
    required this.gameTypeController,
  });
  @override
  State<_TournamentInfoSection> createState() => _TournamentInfoSectionState();
}

class _TournamentInfoSectionState extends State<_TournamentInfoSection> {
  bool _open = false;
  bool get _allEmpty =>
      widget.idController.text.isEmpty &&
      widget.buyInController.text.isEmpty &&
      widget.prizePoolController.text.isEmpty &&
      widget.entrantsController.text.isEmpty &&
      widget.gameTypeController.text.isEmpty;
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final summary = <Widget>[];
    if (widget.idController.text.isNotEmpty)
      summary.add(_summaryRow('ID', widget.idController.text));
    if (widget.buyInController.text.isNotEmpty)
      summary.add(_summaryRow('Buy-In', widget.buyInController.text));
    if (widget.prizePoolController.text.isNotEmpty)
      summary.add(_summaryRow('Prize Pool', widget.prizePoolController.text));
    if (widget.entrantsController.text.isNotEmpty)
      summary.add(_summaryRow(l.entrants, widget.entrantsController.text));
    if (widget.gameTypeController.text.isNotEmpty)
      summary.add(_summaryRow(l.gameType, widget.gameTypeController.text));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tournament Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          if (!_open && summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: summary,
              ),
            ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 300),
              heightFactor: _open ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: widget.idController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Tournament ID',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: widget.buyInController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Buy-In',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: widget.prizePoolController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Prize Pool',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: widget.entrantsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: l.entrants,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: widget.gameTypeController.text.isEmpty
                          ? null
                          : widget.gameTypeController.text,
                      decoration: InputDecoration(
                        labelText: l.gameType,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      dropdownColor: Colors.grey[900],
                      items: [
                        DropdownMenuItem(
                          value: "Hold'em NL",
                          child: Text(l.holdemNl),
                        ),
                        DropdownMenuItem(
                          value: 'Omaha PL',
                          child: Text(l.omahaPl),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text(l.otherGameType),
                        ),
                      ],
                      onChanged: (v) => setState(
                        () => widget.gameTypeController.text = v ?? '',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreetActionsSection extends StatelessWidget {
  final int street;
  final ActionHistoryService actionHistory;
  final List<int> pots;
  final Map<int, int> stackSizes;
  final Map<int, String> playerPositions;
  final PotSyncService? potSync;
  final List<ActionEntry>? allActions;
  final void Function(int, ActionEntry) onEdit;
  final void Function(int) onDelete;
  final void Function(int, ActionEntry)? onInsert;
  final void Function(int)? onDuplicate;
  final void Function(int, int)? onReorder;
  final int? visibleCount;
  final String Function(ActionEntry)? evaluateActionQuality;
  const _StreetActionsSection({
    required this.street,
    required this.actionHistory,
    required this.pots,
    required this.stackSizes,
    required this.playerPositions,
    this.potSync,
    this.allActions,
    required this.onEdit,
    required this.onDelete,
    this.onInsert,
    this.onDuplicate,
    this.onReorder,
    this.visibleCount,
    this.evaluateActionQuality,
  });
  @override
  Widget build(BuildContext context) {
    final pot = street < pots.length ? pots[street] : 0;
    double? sprValue;
    final potSyncService = potSync;
    if (pot > 0 && potSyncService != null) {
      final sourceActions =
          allActions ??
          actionHistory.actionsForStreet(street, collapsed: false);
      final effStack = potSyncService.calculateEffectiveStackForStreet(
        street,
        sourceActions,
        playerPositions.length,
      );
      sprValue = effStack / pot;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: StreetActionsList(
        street: street,
        actions: actionHistory.actionsForStreet(street, collapsed: false),
        pots: pots,
        stackSizes: stackSizes,
        playerPositions: playerPositions,
        numberOfPlayers: playerPositions.length,
        onEdit: onEdit,
        onDelete: onDelete,
        onInsert: onInsert,
        onDuplicate: onDuplicate,
        onReorder: onReorder,
        visibleCount: visibleCount,
        evaluateActionQuality: evaluateActionQuality,
        sprValue: sprValue,
      ),
    );
  }
}

class _AnalyzeButtonSection extends StatelessWidget {
  final VoidCallback onAnalyze;
  const _AnalyzeButtonSection({required this.onAnalyze});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onAnalyze,
      child: const Text('🔍 Проанализировать'),
    );
  }
}

class _HandHeaderSection extends StatelessWidget {
  final String handName;
  final int playerCount;
  final String streetName;
  final VoidCallback onEdit;
  const _HandHeaderSection({
    required this.handName,
    required this.playerCount,
    required this.streetName,
    required this.onEdit,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardCornerRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      handName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$playerCount players • $streetName',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerCountSelector extends StatelessWidget {
  final int numberOfPlayers;
  final Map<int, String> playerPositions;
  final Map<int, PlayerType> playerTypes;
  final ValueChanged<int>? onChanged;
  final bool disabled;
  const _PlayerCountSelector({
    required this.numberOfPlayers,
    required this.playerPositions,
    required this.playerTypes,
    this.onChanged,
    this.disabled = false,
  });
  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: numberOfPlayers,
      dropdownColor: Colors.black,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: [
        for (int i = 2; i <= 10; i++)
          DropdownMenuItem(value: i, child: Text('Игроков: $i')),
      ],
      onChanged: disabled
          ? null
          : (value) {
              if (value != null && onChanged != null) onChanged!(value);
            },
    );
  }
}

class _HandProgressIndicator extends StatelessWidget {
  final int step;
  const _HandProgressIndicator({required this.step});
  @override
  Widget build(BuildContext context) {
    const labels = ['Игроки', 'Карты', 'Действия', 'Шоудаун'];
    const icons = [Icons.people, Icons.style, Icons.list_alt, Icons.flag];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(labels.length, (i) {
          final active = step >= i;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? Colors.blueAccent : Colors.white12,
                  ),
                  child: Icon(icons[i], size: 16, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.cardCornerRadius),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}

class _HandEditorSection extends StatelessWidget {
  final ActionHistoryService actionHistory;
  final Map<int, String> playerPositions;
  final int heroIndex;
  final TextEditingController commentController;
  final TextEditingController tagsController;
  final TextEditingController tournamentIdController;
  final TextEditingController buyInController;
  final TextEditingController prizePoolController;
  final TextEditingController entrantsController;
  final TextEditingController gameTypeController;
  final int currentStreet;
  final List<int> pots;
  final Map<int, int> stackSizes;
  final void Function(int, ActionEntry) onEdit;
  final void Function(int) onDelete;
  final void Function(int, ActionEntry)? onInsert;
  final void Function(int)? onDuplicate;
  final void Function(int, int)? onReorder;
  final List<ActionEntry>? actions;
  final PotSyncService? potSync;
  final int? visibleCount;
  final String Function(ActionEntry)? evaluateActionQuality;
  final VoidCallback onAnalyze;
  const _HandEditorSection({
    required this.actionHistory,
    required this.playerPositions,
    required this.heroIndex,
    required this.commentController,
    required this.tagsController,
    required this.tournamentIdController,
    required this.buyInController,
    required this.prizePoolController,
    required this.entrantsController,
    required this.gameTypeController,
    required this.currentStreet,
    required this.pots,
    required this.stackSizes,
    required this.onEdit,
    required this.onDelete,
    this.onInsert,
    this.onDuplicate,
    this.onReorder,
    this.actions,
    this.potSync,
    this.visibleCount,
    this.evaluateActionQuality,
    required this.onAnalyze,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CollapsibleActionHistorySection(
          actionHistory: actionHistory,
          playerPositions: playerPositions,
          heroIndex: heroIndex,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _HandNotesSection(
                  commentController: commentController,
                  tagsController: tagsController,
                ),
                _TournamentInfoSection(
                  idController: tournamentIdController,
                  buyInController: buyInController,
                  prizePoolController: prizePoolController,
                  entrantsController: entrantsController,
                  gameTypeController: gameTypeController,
                ),
                _StreetActionsSection(
                  street: currentStreet,
                  actionHistory: actionHistory,
                  pots: pots,
                  stackSizes: stackSizes,
                  playerPositions: playerPositions,
                  potSync: potSync,
                  allActions: actions,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onInsert: onInsert,
                  onDuplicate: onDuplicate,
                  onReorder: onReorder,
                  visibleCount: visibleCount,
                  evaluateActionQuality: evaluateActionQuality,
                ),
                const SizedBox(height: 10),
                _AnalyzeButtonSection(onAnalyze: onAnalyze),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
