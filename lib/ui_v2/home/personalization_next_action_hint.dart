import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/infra/telemetry_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/section_surface.dart';
import 'package:poker_analyzer/personalization/personalization_next_action_router_v1.dart';

const _artifactPath = 'release/_reports/personalization_next_action.jsonl';
const _lastAcceptedActionKey = 'release_reports_personalization_last_action';
const _lastAcceptedActionTimestampKey =
    'release_reports_personalization_last_action_ts';
const _bootstrapAction = 'run_phase1';
const _bootstrapReason = 'bootstrap default path for cold start';
const _partialFallbackReason = 'phase2 safety net fallback';
const _lastActionReason = 'last accepted action';
const _focusReason = 'focus signal';
const _focusLabelStorageKey = 'lesson_focus_label_v1';
const _bootstrapData = PersonalizationNextActionData(
  action: _bootstrapAction,
  reason: _bootstrapReason,
);
const _phase2FallbackData = PersonalizationNextActionData(
  action: _bootstrapAction,
  reason: _partialFallbackReason,
);

class PersonalizationNextActionData {
  const PersonalizationNextActionData({
    required this.action,
    required this.reason,
  });

  final String action;
  final String reason;

  bool get isIdle => action == 'idle';
}

Future<PersonalizationNextActionData?> loadPersonalizationNextAction() async {
  final file = File(_artifactPath);
  if (!await file.exists()) {
    return null;
  }
  Map<String, Object?>? lastReport;
  await for (final line
      in file
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    try {
      final payload = jsonDecode(trimmed);
      if (payload is Map &&
          payload['schema'] == 'personalization_next_action_v1') {
        lastReport = payload.cast<String, Object?>();
      }
    } catch (_) {
      continue;
    }
  }
  if (lastReport == null) {
    return null;
  }
  final action = lastReport['next_action'];
  final reason = lastReport['reason'];
  if (action is! String || reason is! String) {
    return null;
  }
  return PersonalizationNextActionData(action: action, reason: reason);
}

String _friendlyActionLabel(String action) {
  switch (action) {
    case 'repeat_phase1':
      return 'Repeat Phase 1';
    case 'run_phase2':
      return 'Repeat Phase 2';
    case 'run_phase3':
      return 'Run Phase 3';
    default:
      return action.replaceAll('_', ' ');
  }
}

typedef PersonalizationNextActionLoader =
    Future<PersonalizationNextActionData?> Function();

class PersonalizationNextActionHint extends StatefulWidget {
  const PersonalizationNextActionHint({super.key, this.loader});

  @override
  State<PersonalizationNextActionHint> createState() =>
      _PersonalizationNextActionHintState();

  final PersonalizationNextActionLoader? loader;
}

class _PersonalizationNextActionHintState
    extends State<PersonalizationNextActionHint> {
  late final Future<PersonalizationNextActionData?> _future;
  String? _lastAcceptedAction;
  bool _clearScheduled = false;
  bool _hintShownLogged = false;
  bool _hintCtaLogged = false;
  bool _hintRoutedLogged = false;
  bool _fallbackLogged = false;
  bool _focusConsumed = false;
  bool _focusMappingHit = false;

  @visibleForTesting
  bool get debugFocusConsumed => _focusConsumed;

  @visibleForTesting
  bool get debugFocusMappingHit => _focusMappingHit;

  @override
  void initState() {
    super.initState();
    _future = _loadActionWithFocus();
    _loadLastAcceptedAction();
  }

  // Lesson Focus Bridge v1: closed (changes require new phase decision).
  Future<PersonalizationNextActionData?> _loadActionWithFocus() async {
    final loader = widget.loader != null
        ? widget.loader!
        : loadPersonalizationNextAction;
    final data = await loader();
    final focusLabel = await _consumeFocusLabel();
    final mappingAction = focusLabel == null
        ? null
        : focusLabelToNextAction(focusLabel);
    _focusConsumed = focusLabel != null;
    _focusMappingHit = mappingAction != null;
    if (mappingAction == null) return data;
    return PersonalizationNextActionData(
      action: mappingAction,
      reason: _focusReason,
    );
  }

  Future<String?> _consumeFocusLabel() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_focusLabelStorageKey);
    if (value == null || value.trim().isEmpty) return null;
    await prefs.remove(_focusLabelStorageKey);
    return value.trim().toLowerCase();
  }

  Future<void> _loadLastAcceptedAction() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastAcceptedAction = prefs.getString(_lastAcceptedActionKey);
    });
  }

  Future<void> _storeAcceptedAction(String action) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAcceptedActionKey, action);
    await prefs.setString(
      _lastAcceptedActionTimestampKey,
      DateTime.now().toUtc().toIso8601String(),
    );
    setState(() {
      _lastAcceptedAction = action;
    });
  }

  Future<void> _clearLastAcceptedAction() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAcceptedActionKey);
    await prefs.remove(_lastAcceptedActionTimestampKey);
    setState(() {
      _lastAcceptedAction = null;
      _clearScheduled = false;
    });
  }

  void _logHintShown(String action) {
    if (_hintShownLogged) return;
    _hintShownLogged = true;
    Telemetry.logEvent(
      'hint_shown',
      buildTelemetry(
        sessionId: 'home_personalization_hint',
        data: {
          'next_action': action,
          'focus_consumed': _focusConsumed,
          'focus_mapping_hit': _focusMappingHit,
        },
      ),
    );
  }

  void _logHintCta(String action) {
    if (_hintCtaLogged) return;
    _hintCtaLogged = true;
    Telemetry.logEvent(
      'hint_cta_tapped',
      buildTelemetry(
        sessionId: 'home_personalization_hint',
        data: {'next_action': action},
      ),
    );
  }

  void _logHintRouted(PersonalizationNextActionTarget target) {
    if (_hintRoutedLogged) return;
    _hintRoutedLogged = true;
    Telemetry.logEvent(
      'hint_routed_to_phase',
      buildTelemetry(
        sessionId: 'home_personalization_hint',
        data: {'phase_id': _phaseIdForTarget(target)},
      ),
    );
  }

  void _logFallback(String type, String reason) {
    if (_fallbackLogged) return;
    _fallbackLogged = true;
    Telemetry.logEvent(
      'personalization_fallback_used',
      buildTelemetry(
        sessionId: 'home_personalization_hint',
        data: {'fallback_type': type, 'reason': reason},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PersonalizationNextActionData?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final artifact = snapshot.data;
        final artifactValid =
            artifact != null &&
            !artifact.isIdle &&
            isRoutableNextAction(artifact.action);
        final validArtifact = artifactValid ? artifact : null;
        String? fallbackType;
        final data =
            validArtifact ??
            (() {
              if (_lastAcceptedAction != null &&
                  isRoutableNextAction(_lastAcceptedAction!)) {
                fallbackType = 'last_accepted';
                return PersonalizationNextActionData(
                  action: _lastAcceptedAction!,
                  reason: _lastActionReason,
                );
              }
              if (artifact == null) {
                fallbackType = 'bootstrap';
                return _bootstrapData;
              }
              fallbackType = 'phase2_safety_net';
              return _phase2FallbackData;
            })();
        if (fallbackType != null) {
          _logFallback(fallbackType!, data.reason);
        }
        if (data.isIdle) {
          return const SizedBox.shrink();
        }
        if (!isRoutableNextAction(data.action)) {
          return const SizedBox.shrink();
        }
        if (_lastAcceptedAction != null && _lastAcceptedAction == data.action) {
          return const SizedBox.shrink();
        }
        if (_lastAcceptedAction != null &&
            _lastAcceptedAction != data.action &&
            !_clearScheduled) {
          _clearScheduled = true;
          Future.microtask(_clearLastAcceptedAction);
        }
        final label = _friendlyActionLabel(data.action);
        final message = 'Recommended next: $label';
        final actionButton = _buildRunnerButton(context, data.action);
        _logHintShown(data.action);
        return SectionSurface(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondaryDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Why this is recommended: ${data.reason}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondaryDark.withOpacity(0.75),
                  height: 1.3,
                ),
              ),
              if (actionButton != null) ...[
                const SizedBox(height: AppSpacing.sm),
                actionButton,
              ],
            ],
          ),
        );
      },
    );
  }

  Widget? _buildRunnerButton(BuildContext context, String action) {
    final target = targetForNextAction(action);
    final routeBuilder = _routeBuilderForTarget(target);
    if (routeBuilder == null) return null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          _logHintCta(action);
          if (target != PersonalizationNextActionTarget.none) {
            _logHintRouted(target);
          }
          await _storeAcceptedAction(action);
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => routeBuilder()));
        },
        child: const Text('Run recommended next'),
      ),
    );
  }

  Widget Function()? _routeBuilderForTarget(
    PersonalizationNextActionTarget target,
  ) {
    switch (target) {
      case PersonalizationNextActionTarget.phase1:
        return () => const CanonicalLauncherV1.phase1();
      case PersonalizationNextActionTarget.phase2:
        return () => const CanonicalLauncherV1.phase2();
      case PersonalizationNextActionTarget.phase3:
        return () => const CanonicalLauncherV1.phase3();
      case PersonalizationNextActionTarget.none:
        return null;
    }
  }

  String _phaseIdForTarget(PersonalizationNextActionTarget target) {
    switch (target) {
      case PersonalizationNextActionTarget.phase1:
        return 'phase1';
      case PersonalizationNextActionTarget.phase2:
        return 'phase2';
      case PersonalizationNextActionTarget.phase3:
        return 'phase3';
      case PersonalizationNextActionTarget.none:
        return 'none';
    }
  }
}
