import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

typedef _ChecklistSelector = String Function(AppLocalizations l10n);

/// Self-evaluation checklist screen for user reflection.
///
/// Features:
/// - 5-7 poker skill checklist items
/// - Toggleable via CheckboxListTile
/// - Persistent state via SharedPreferences
/// - Reset button to clear all checkboxes
class XpSelfEvalScreen extends StatefulWidget {
  XpSelfEvalScreen({super.key});

  @override
  State<XpSelfEvalScreen> createState() => _XpSelfEvalScreenState();
}

class _XpSelfEvalScreenState extends State<XpSelfEvalScreen> {
  static const String _storageKey = 'self_eval_checklist';

  static final List<_ChecklistSelector> _checklistSelectors = [
    (l10n) => l10n.xpSelfEvalItemPushCall,
    (l10n) => l10n.xpSelfEvalItemBubblePush,
    (l10n) => l10n.xpSelfEvalItemIcmAwareness,
    (l10n) => l10n.xpSelfEvalItemAdjustCharts,
    (l10n) => l10n.xpSelfEvalItemStackAwareness,
    (l10n) => l10n.xpSelfEvalItemReviewMistakes,
    (l10n) => l10n.xpSelfEvalItemDeviateCharts,
  ];

  int get _itemCount => _checklistSelectors.length;

  late List<bool> _checkedState;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _checkedState = decoded.map((e) => e as bool).toList();

        // Handle list length mismatches (items added/removed)
        while (_checkedState.length < _itemCount) {
          _checkedState.add(false);
        }
        if (_checkedState.length > _itemCount) {
          _checkedState = _checkedState.sublist(0, _itemCount);
        }
      } catch (e) {
        _checkedState = List.filled(_itemCount, false);
      }
    } else {
      _checkedState = List.filled(_itemCount, false);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_checkedState));
  }

  void _toggleItem(int index) {
    setState(() {
      _checkedState[index] = !_checkedState[index];
    });
    _saveState();
  }

  Future<void> _resetAll() async {
    setState(() {
      _checkedState = List.filled(_itemCount, false);
    });
    await _saveState();

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.xpSelfEvalResetConfirmation),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.xpSelfEvalTitle),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.xpSelfEvalResetTooltip,
            onPressed: _resetAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 16),
                ..._buildChecklistItems(l10n),
                const SizedBox(height: 24),
                _buildResetButton(l10n),
              ],
            ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final checkedCount = _checkedState.where((e) => e).length;
    final total = _itemCount;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  l10n.xpSelfEvalProgressHeader,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: total > 0 ? checkedCount / total : 0,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.xpSelfEvalSkillsCompleted(checkedCount, total),
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChecklistItems(AppLocalizations l10n) {
    final localizedItems = _checklistSelectors
        .map((selector) => selector(l10n))
        .toList();

    return List.generate(
      _itemCount,
      (index) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 1,
        child: CheckboxListTile(
          value: _checkedState[index],
          onChanged: (_) => _toggleItem(index),
          title: Text(
            localizedItems[index],
            style: TextStyle(
              fontSize: 14,
              decoration: _checkedState[index]
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: _checkedState[index] ? Colors.grey[600] : Colors.black87,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildResetButton(AppLocalizations l10n) => Center(
    child: OutlinedButton.icon(
      onPressed: _resetAll,
      icon: const Icon(Icons.refresh, size: 18),
      label: Text(l10n.xpSelfEvalResetButton),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red[700],
        side: BorderSide(color: Colors.red[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}
