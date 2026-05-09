import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/home/direct_loader.dart';

class LegacyDrillCanonicalHostLaunchInputV1 {
  const LegacyDrillCanonicalHostLaunchInputV1({
    required this.moduleId,
    this.debugItemsOverrideV1,
  });

  final String moduleId;
  final List<Map<String, dynamic>>? debugItemsOverrideV1;
}

Future<List<Map<String, dynamic>>> loadLegacyDrillCanonicalHostItemsV1(
  String moduleId,
) async {
  final loaded = <Map<String, dynamic>>[];
  await _loadLegacyDrillCanonicalJsonlV1(moduleId, 'drills.jsonl', loaded);
  await _loadLegacyDrillCanonicalJsonlV1(moduleId, 'quiz.jsonl', loaded);

  if (loaded.isNotEmpty) {
    loaded.shuffle();
  }

  return loaded;
}

Future<void> _loadLegacyDrillCanonicalJsonlV1(
  String moduleId,
  String fileName,
  List<Map<String, dynamic>> target,
) async {
  try {
    final content = await DirectLoader.loadContentFile(moduleId, fileName);
    final lines = LineSplitter.split(content);
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        target.add(jsonDecode(line) as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing $fileName line: $e');
      }
    }
  } catch (e) {
    print('Missing $fileName for $moduleId: $e');
  }
}

class LegacyDrillCanonicalHostAdapterV1 extends StatefulWidget {
  const LegacyDrillCanonicalHostAdapterV1({super.key, required this.input});

  final LegacyDrillCanonicalHostLaunchInputV1 input;

  @override
  State<LegacyDrillCanonicalHostAdapterV1> createState() =>
      _LegacyDrillCanonicalHostAdapterV1State();
}

class _LegacyDrillCanonicalHostAdapterV1State
    extends State<LegacyDrillCanonicalHostAdapterV1> {
  List<Map<String, dynamic>>? _resolvedItemsV1;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _resolveLaunchV1();
  }

  @override
  void didUpdateWidget(LegacyDrillCanonicalHostAdapterV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.input.moduleId != widget.input.moduleId ||
        oldWidget.input.debugItemsOverrideV1 !=
            widget.input.debugItemsOverrideV1) {
      _resolveLaunchV1();
    }
  }

  Future<void> _resolveLaunchV1() async {
    final debugItems = widget.input.debugItemsOverrideV1;
    if (debugItems != null) {
      setState(() {
        _resolvedItemsV1 = List<Map<String, dynamic>>.from(debugItems);
        _loading = false;
        _loadError = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final items = await loadLegacyDrillCanonicalHostItemsV1(
        widget.input.moduleId,
      );
      if (!mounted) return;
      setState(() {
        _resolvedItemsV1 = items;
        _loading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resolvedItemsV1 = const <Map<String, dynamic>>[];
        _loading = false;
        _loadError = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        key: const Key('legacy_drill_canonical_host_adapter_loading_v1'),
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              SharkyTokensV1.brandPrimary,
            ),
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        key: const Key('legacy_drill_canonical_host_adapter_error_v1'),
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              _loadError!,
              style: AppTypography.body.copyWith(
                color: SharkyTokensV1.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return CanonicalTerminalRunnerSurfaceV1(
      resolvedHostLaunchV1: CanonicalTerminalResolvedHostLaunchV1.legacyDrill(
        runtimeConfigV1: CanonicalTerminalLegacyDrillRuntimeConfigV1(
          moduleIdV1: widget.input.moduleId,
          resolvedItemsV1: _resolvedItemsV1 ?? const <Map<String, dynamic>>[],
        ),
      ),
    );
  }
}
