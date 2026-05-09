import '../v4_theme_builder.dart';
import '../v4_preview_switch.dart';
import '../v4_theme_controller.dart';
import 'v4_theme_blending_proxy_v1.dart';
import 'persona_adaptive_theme_builder_v3.dart';
import '../../persona/emotion_engine_tier_a.dart';
import '../../persona/emotional_state_machine_v1.dart';
import '../../persona/attention_tone_model_v1.dart';
import '../../persona/behavioral_fusion_v1.dart';
import '../../persona/behavioral_dynamics_v1.dart';
import '../../persona/fusion_consistency_engine_v1.dart';
import '../../persona/persona_driven_signals_v1.dart';
import '../../persona/persona_signal_aggregator_v1.dart';
import '../../persona/persona_advice_engine_v1.dart';
import 'theme_runtime_injection_gate_v1.dart';
import 'theme_runtime_synthesis_v1.dart';

class PersonaFusionSurfaceV1 {
  const PersonaFusionSurfaceV1({
    required this.themeRuntimeInjectionGateV1,
    required this.themeRuntimeSynthesisV1,
    required this.themeBuilder,
    required this.v4PreviewSwitch,
    required this.v4Controller,
    required this.v4ThemeBlendingProxyV1,
    required this.personaAdaptiveThemeBuilderV3,
    required this.emotionEngineTierA,
    required this.esmV1,
    required this.atmV1,
    required this.behavioralFusionV1,
    required this.behavioralDynamicsV1,
    required this.fusionConsistencyEngineV1,
    required this.personaDrivenSignalsV1,
    required this.personaSignalAggregatorV1,
    required this.personaAdviceEngineV1,
  });

  final ThemeRuntimeInjectionGateV1 themeRuntimeInjectionGateV1;
  final ThemeRuntimeSynthesisV1 themeRuntimeSynthesisV1;
  final V4ThemeDataBuilder themeBuilder;
  final V4PreviewSwitch v4PreviewSwitch;
  final V4ThemeController v4Controller;
  final V4ThemeBlendingProxyV1 v4ThemeBlendingProxyV1;
  final PersonaAdaptiveThemeBuilderV3 personaAdaptiveThemeBuilderV3;
  final EmotionEngineTierA emotionEngineTierA;
  final EmotionalStateMachineV1 esmV1;
  final AttentionToneModelV1 atmV1;
  final BehavioralFusionV1 behavioralFusionV1;
  final BehavioralDynamicsV1 behavioralDynamicsV1;
  final FusionConsistencyEngineV1 fusionConsistencyEngineV1;
  final PersonaDrivenSignalsV1 personaDrivenSignalsV1;
  final PersonaSignalAggregatorV1 personaSignalAggregatorV1;
  final PersonaAdviceEngineV1 personaAdviceEngineV1;

  Map<String, String> asReadOnlyMap() {
    return const <String, String>{
      'theme_runtime_injection_gate_v1': '<opaque>',
      'theme_runtime_synthesis_v1': '<opaque>',
      'theme_builder': '<opaque>',
      'v4_preview_switch': '<opaque>',
      'v4_controller': '<opaque>',
      'v4_theme_blending_proxy_v1': '<opaque>',
      'persona_adaptive_theme_builder_v3': '<opaque>',
      'emotion_engine_tier_a': '<opaque>',
      'esm_v1': '<opaque>',
      'atm_v1': '<opaque>',
      'behavioral_fusion_v1': '<opaque>',
      'behavioral_dynamics_v1': '<opaque>',
      'fusion_consistency_engine_v1': '<opaque>',
      'persona_driven_signals_v1': '<opaque>',
      'persona_signal_aggregator_v1': '<opaque>',
      'persona_advice_engine_v1': '<opaque>',
    };
  }
}
