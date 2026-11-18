// Controlled native render-fault probe, using the real AppRoot and saved data.
// flutter build ios --simulator --debug --target=tools/act0_render_recovery_probe_v1.dart
// Open: Inject fault -> Retry (still broken) -> Allow recovery -> Retry -> Back.
// The normal main.dart entry and release binary do not import this tool.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _RecoveryProbe());
}

class _RecoveryProbe extends StatefulWidget {
  const _RecoveryProbe();

  @override
  State<_RecoveryProbe> createState() => _RecoveryProbeState();
}

class _RecoveryProbeState extends State<_RecoveryProbe> {
  final _navigator = GlobalKey<NavigatorState>();
  late final _app = AppRoot(navigatorKey: _navigator);
  bool _fail = false;

  void _inject() {
    final navigator = _navigator.currentState;
    if (navigator == null) return;
    _fail = true;
    unawaited(
      navigator.push<void>(
        PageRouteBuilder<void>(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => Builder(
            builder: (context) {
              if (_fail) throw StateError('Controlled A6 render fault');
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Recovery succeeded'),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back to Sharky'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Stack(
      fit: StackFit.expand,
      children: [
        _app,
        Positioned(
          top: 48,
          right: 8,
          child: Material(
            color: const Color(0xFF18222D),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _inject,
                  child: const Text('Inject fault'),
                ),
                TextButton(
                  onPressed: () => _fail = false,
                  child: const Text('Allow recovery'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
