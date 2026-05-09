import 'package:flutter/widgets.dart';

class V4AdaptivePersonaWidgetStubV1 extends StatelessWidget {
  const V4AdaptivePersonaWidgetStubV1({
    super.key,
    required this.visualSurface,
    required this.personaContext,
  });

  final Object visualSurface;
  final Object personaContext;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  Map<String, String> asReadOnlyMap() => {
    'visual_surface': visualSurface.toString(),
    'persona_ctx': personaContext.toString(),
  };
}
