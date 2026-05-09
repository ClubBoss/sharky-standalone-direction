import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/ui_v2.dart';
import 'package:poker_analyzer/ui_v2/ui_v2_adaptive_dashboard_screen.dart';
import 'package:poker_analyzer/ui_v2/ui_v2_beta_shell.dart';
import 'package:poker_analyzer/ui_v2/ui_v2_feedback_panel.dart';
import '../../app_config.dart';
import '../../config/app_flags.dart';
import '../../state/ui_version_controller.dart';

/// Dev menu section for UI experiments and feature flags.
class UiV2Section extends StatefulWidget {
  const UiV2Section({super.key});

  @override
  State<UiV2Section> createState() => _UiV2SectionState();
}

class _UiV2SectionState extends State<UiV2Section> {
  static const _prefsKey = 'feature_use_ui_v2';
  static const _prefsKeyV3 = 'feature_use_ui_v3';
  bool _loading = true;
  bool _enabled = false;
  bool _useUiV3 = kUseUiV3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_prefsKey) ?? appConfig.useUiV2;
    final v3 = prefs.getBool(_prefsKeyV3) ?? kUseUiV3;
    setState(() {
      _enabled = v;
      _useUiV3 = v3;
      _loading = false;
    });
    appConfig.useUiV2 = v;
    appConfig.useUiV3 = v3;
    uiVersionController.value = v3;
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    appConfig.useUiV2 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  Future<void> _toggleUiV3(bool value) async {
    setState(() => _useUiV3 = value);
    appConfig.useUiV3 = value;
    uiVersionController.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyV3, value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile.adaptive(
          value: _useUiV3,
          onChanged: _toggleUiV3,
          title: const Text('Use UI V3'),
          subtitle: const Text('Switch between v2 legacy shell and v3 flow'),
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          value: _enabled,
          onChanged: _toggle,
          title: const Text('Disable UI v2 (Legacy Mode)'),
          subtitle: const Text(
            'Turn off to revert to legacy result screen; production default is ON',
          ),
        ),
        const SizedBox(height: 8),
        if (_enabled)
          const Text(
            'UI v2 is ENABLED (production default). Complete a training to see the new result screen.',
            style: TextStyle(color: Colors.white70),
          )
        else
          const Text(
            'UI v2 is DISABLED (legacy mode). Old result screen will be used.',
            style: TextStyle(color: Colors.white70),
          ),
        const SizedBox(height: 16),
        if (_enabled) ...[
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => buildCanonicalPathRootV1(),
                ),
              );
            },
            icon: const Icon(Icons.map),
            label: const Text('Open Progress Map'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const UiV2PremiumHub()),
              );
            },
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Open Premium Hub'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const UiV2AdaptiveDashboardScreen(),
                ),
              );
            },
            icon: const Icon(Icons.analytics),
            label: const Text('Adaptive Dashboard'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              UiV2FeedbackPanel.show(context);
            },
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Open Feedback Panel'),
          ),
        ],
      ],
    );
  }
}
