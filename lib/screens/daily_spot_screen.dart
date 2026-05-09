import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_hand.dart';
import '../services/training_pack_storage_service.dart';
import '../widgets/replay_spot_widget.dart';
import '../services/training_import_export_service.dart';
import '../widgets/sync_status_widget.dart';

class DailySpotScreen extends StatefulWidget {
  final SavedHand hand;
  DailySpotScreen({super.key, required this.hand});

  @override
  State<DailySpotScreen> createState() => _DailySpotScreenState();
}

class _DailySpotScreenState extends State<DailySpotScreen> {
  bool _show = false;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    final packs = context.read<TrainingPackStorageService>().packs;
    String? id;
    for (int i = 0; i < packs.length; i++) {
      final j = packs[i].hands.indexOf(widget.hand);
      if (j != -1) {
        id = '$i:$j';
        break;
      }
    }
    final now = DateTime.now();
    await prefs.setString('daily_spot_date', now.toIso8601String());
    final history = prefs.getStringList('daily_spot_history') ?? [];
    history.add(now.toIso8601String());
    await prefs.setStringList('daily_spot_history', history);
    if (id != null) await prefs.setString('daily_spot_id', id);
    if (mounted) {
      unawaited(
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DailySpotDoneScreen()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spot = TrainingImportExportService().fromSavedHand(widget.hand);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Спот дня'),
        centerTitle: true,
        actions: [SyncStatusIcon.of(context)],
      ),
      backgroundColor: const Color(0xFF121212),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReplaySpotWidget(
            spot: spot,
            expectedAction: _show ? widget.hand.expectedAction : null,
            gtoAction: _show ? widget.hand.gtoAction : null,
            evLoss: _show ? widget.hand.evLoss : null,
            feedbackText: _show ? widget.hand.feedbackText : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _show ? _finish : () => setState(() => _show = true),
            child: Text(_show ? 'Завершить' : 'Показать ответ'),
          ),
        ],
      ),
    );
  }
}

class DailySpotDoneScreen extends StatelessWidget {
  DailySpotDoneScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Спот дня'),
      actions: [SyncStatusIcon.of(context)],
    ),
    backgroundColor: const Color(0xFF121212),
    body: const Center(
      child: Text(
        '🎯 Спот дня выполнен! Возвращайся завтра.',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
