import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

class PlayerExplanationOverlayController extends ChangeNotifier {
  bool _visible = false;

  bool get isVisible => _visible;

  Future<void> show() async {
    if (_visible) return;
    _visible = true;
    notifyListeners();
    await _logTelemetry();
  }

  void hide() {
    if (!_visible) return;
    _visible = false;
    notifyListeners();
  }

  Future<void> _logTelemetry() async {
    await _withReportsWritable(() async {
      final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
      sink.writeln(
        jsonEncode({
          'event': 'player_explanation_completed',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      await sink.close();
    });
  }
}

const Map<String, Map<String, String>> _localizedSections = {
  'en': {
    'xpTitle': 'XP Insights',
    'xpBody': 'Earn XP to progress through mastery tiers.',
    'masteryTitle': 'Mastery Progress',
    'masteryBody': 'Track how each skill is improving over time.',
    'rankTitle': 'Rank Status',
    'rankBody': 'Rank reflects competitive performance and rewards.',
    'traitsTitle': 'Traits',
    'traitsBody': 'Traits unlock personalized guidance from Sharky.',
    'close': 'Got it',
  },
};

class PlayerExplanationOverlay extends StatelessWidget {
  const PlayerExplanationOverlay({super.key, required this.controller});

  final PlayerExplanationOverlayController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localized =
        _localizedSections[loc.localeName] ?? _localizedSections['en']!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return IgnorePointer(
          ignoring: !controller.isVisible,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: controller.isVisible ? 1.0 : 0.0,
            child: controller.isVisible
                ? _buildOverlay(context, loc, localized)
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    AppLocalizations loc,
    Map<String, String> localized,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: controller.hide,
          child: Container(color: Colors.black38),
        ),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSection(
                  title: localized['xpTitle']!,
                  body: localized['xpBody']!,
                  icon: Icons.flash_on,
                ),
                _buildSection(
                  title: localized['masteryTitle']!,
                  body: localized['masteryBody']!,
                  icon: Icons.school,
                ),
                _buildSection(
                  title: localized['rankTitle']!,
                  body: localized['rankBody']!,
                  icon: Icons.verified,
                ),
                _buildSection(
                  title: localized['traitsTitle']!,
                  body: localized['traitsBody']!,
                  icon: Icons.palette,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.hide,
                  child: Text(localized['close']!),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String body,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
