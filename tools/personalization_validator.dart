import 'dart:io';

const files = {
  'lib/ai/personalization_engine.dart': [
    'PersonalizationEngine',
    'recordAccuracySignal',
    'recordSpeedSignal',
    'recordPressureResponseSignal',
    'recordStreetMisreadSignal',
    'recordDensityReadSignal',
    'recordBlockerAwarenessSignal',
    'recordFragilityReadSignal',
    'recordExploitWindowReadSignal',
    'currentProfile',
    'applyMicroTuning',
    'applyPathReordering',
    'applyDifficultyScaling',
    'applyHintDensity',
    'applyReinforcementIntensity',
    'applyTimingModulation',
    'emitPersonalizationTick',
    'emitPersonalizationUpdate',
    'emitPersonalizationRecommendation',
  ],
  'lib/ai/personalization_memory.dart': [
    'PersonalizationMemory',
    'accuracySignals',
    'speedSignals',
    'pressureResponseSignals',
    'streetMisreadSignals',
    'densityReadSignals',
    'blockerAwarenessSignals',
    'fragilityReadSignals',
    'exploitWindowReadSignals',
    'lastProfile',
    'clearAll',
    'clearSignals',
    'updateLastProfile',
  ],
  'lib/ai/personalization_rules.dart': [
    'PersonalizationRules',
    'evaluateProfileRule',
    'evaluateAdjustmentRule',
    'evaluateReinforcementRule',
    'evaluateTimingRule',
    'applyProfileRule',
    'applyAdjustmentRule',
    'applyReinforcementRule',
    'applyTimingRule',
  ],
  'lib/ai/personalization_orchestrator.dart': [
    'PersonalizationOrchestrator',
    'engine',
    'memory',
    'rules',
    'init',
    'reset',
    'routeAccuracy',
    'routeSpeed',
    'routePressureResponse',
    'routeStreetMisread',
    'routeDensityRead',
    'routeBlockerAwareness',
    'routeFragilityRead',
    'routeExploitWindowRead',
    'evaluateProfile',
    'evaluateAdjustments',
    'evaluateReinforcement',
    'evaluateTiming',
    'applyProfile',
    'applyAdjustments',
    'applyReinforcement',
    'applyTiming',
  ],
  'lib/ai/personalization_wiring.dart': [
    'PersonalizationWiring',
    'PersonalizationEngine',
    'PersonalizationMemory',
    'PersonalizationRules',
    'PersonalizationOrchestrator',
    'wire',
  ],
  'lib/ai/adaptive_ux_hooks.dart': [
    'AdaptiveUxHooks',
    'requestHint',
    'requestLightHint',
    'requestReinforcement',
    'requestDifficultyUp',
    'requestDifficultyDown',
    'requestTempoUp',
    'requestTempoDown',
    'requestAdaptiveBranch',
  ],
  'lib/ai/personalization_telemetry.dart': [
    'PersonalizationTelemetry',
    'emitSignalEvent',
    'emitProfileEvent',
    'emitAdjustmentEvent',
    'emitReinforcementEvent',
    'emitTimingEvent',
    'emitUxHookEvent',
  ],
};

Future<void> main() async {
  for (final entry in files.entries) {
    final path = entry.key;
    final requirements = entry.value;
    final file = File(path);
    if (!await file.exists()) {
      stderr.writeln('Missing file: $path');
      exit(1);
    }
    final content = await file.readAsString();
    if (!content.runes.every(
      (r) => r >= 32 && r <= 126 || r == 10 || r == 13,
    )) {
      stderr.writeln('Non-ASCII content in $path');
      exit(1);
    }
    for (final requirement in requirements) {
      if (!content.contains(requirement)) {
        stderr.writeln('$path missing "$requirement"');
        exit(1);
      }
    }
  }
  stdout.writeln('OK: Personalization structure valid');
}
