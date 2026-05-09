import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

/// Displays the latest adaptive reward history entries for QA review.
const String _defaultHistoryCachePath =
    'tools/_reports/adaptive_reward_cache.json';
const String _defaultHistoryExportPath =
    'tools/_reports/ux_reward_history.json';

class UxFeedbackHistoryScreen extends StatefulWidget {
  const UxFeedbackHistoryScreen({
    super.key,
    this.enableSnackBar = true,
    this.rewardCachePath = _defaultHistoryCachePath,
    this.exportPath = _defaultHistoryExportPath,
  });

  final bool enableSnackBar;
  final String rewardCachePath;
  final String exportPath;

  @override
  State<UxFeedbackHistoryScreen> createState() =>
      _UxFeedbackHistoryScreenState();
}

class _UxFeedbackHistoryScreenState extends State<UxFeedbackHistoryScreen> {
  static const int _maxRows = 15;

  late Future<List<_RewardHistoryItem>> _historyFuture;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<_RewardHistoryItem>> _loadHistory() async {
    final file = File(widget.rewardCachePath);
    if (!await file.exists()) {
      return const [];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return const [];
      }
      final history = decoded['history'];
      if (history is! List) {
        return const [];
      }

      final entries = history
          .whereType<Map>()
          .map(
            (raw) => _RewardHistoryItem.fromJson(raw.cast<String, Object?>()),
          )
          .where((item) => item != null)
          .cast<_RewardHistoryItem>()
          .toList();

      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return entries.take(_maxRows).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _exportHistory(List<_RewardHistoryItem> history) async {
    if (history.isEmpty || _isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final payload = <String, Object>{
        'exported_at': DateTime.now().toUtc().toIso8601String(),
        'count': history.length,
        'rewards': history.map((item) => item.toJson()).toList(),
      };

      final file = File(widget.exportPath);
      await file.create(recursive: true);
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(payload));

      unawaited(
        FirebaseLiteTelemetryService.instance.logEvent(
          'ux_history_exported',
          params: <String, Object?>{'count': history.length},
        ),
      );

      if (!mounted) {
        return;
      }
      if (widget.enableSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'History exported to tools/_reports/ux_reward_history.json',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      } else {
        _isExporting = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward History')),
      body: FutureBuilder<List<_RewardHistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? const [];
          if (history.isEmpty) {
            return const Center(
              child: Text(
                'No rewards recorded yet.',
                style: TextStyle(fontSize: 14),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Recent rewards (${history.length >= _maxRows ? _maxRows : history.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      key: const ValueKey('export_button'),
                      onPressed: _isExporting
                          ? null
                          : () => _exportHistory(history),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _isExporting ? 'Exporting...' : 'Export JSON',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'XP (base -> final)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Chips (base -> final)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Multiplier',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Padding(
                        key: ValueKey('history_row_$index'),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                'XP ${item.baseXp} -> ${item.adjustedXp}',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Chips ${item.baseChips} -> ${item.adjustedChips}',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'x${item.multiplier.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RewardHistoryItem {
  const _RewardHistoryItem({
    required this.timestamp,
    required this.baseXp,
    required this.adjustedXp,
    required this.baseChips,
    required this.adjustedChips,
    required this.multiplier,
  });

  final DateTime timestamp;
  final int baseXp;
  final int adjustedXp;
  final int baseChips;
  final int adjustedChips;
  final double multiplier;

  static _RewardHistoryItem? fromJson(Map<String, Object?> json) {
    final tsRaw = json['timestamp']?.toString();
    final parsedTimestamp = tsRaw == null ? null : DateTime.tryParse(tsRaw);
    final baseXp = (json['base_xp'] as num?)?.toInt();
    final adjustedXp = (json['adjusted_xp'] as num?)?.toInt();
    final baseChips = (json['base_chips'] as num?)?.toInt();
    final adjustedChips = (json['adjusted_chips'] as num?)?.toInt();
    final multiplier = (json['multiplier'] as num?)?.toDouble();

    if (parsedTimestamp == null ||
        baseXp == null ||
        adjustedXp == null ||
        baseChips == null ||
        adjustedChips == null ||
        multiplier == null) {
      return null;
    }

    return _RewardHistoryItem(
      timestamp: parsedTimestamp,
      baseXp: baseXp,
      adjustedXp: adjustedXp,
      baseChips: baseChips,
      adjustedChips: adjustedChips,
      multiplier: multiplier,
    );
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      'timestamp': timestamp.toUtc().toIso8601String(),
      'base_xp': baseXp,
      'adjusted_xp': adjustedXp,
      'base_chips': baseChips,
      'adjusted_chips': adjustedChips,
      'multiplier': double.parse(multiplier.toStringAsFixed(2)),
    };
  }
}
