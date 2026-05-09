import 'package:flutter/widgets.dart';

import '../theme/v4_token_registry.dart';
import '../persona/components_v3/panel_v3.dart';

class SRRibbonV1 extends StatelessWidget {
  const SRRibbonV1({super.key, required this.prompt, required this.hint});

  final String? prompt;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    if (prompt == null && hint == null) {
      return const SizedBox.shrink();
    }
    final tokens = const V4TokenRegistry();
    final spacing = tokens.v4SpacingMedium;
    final textStyle = const TextStyle(fontSize: 14);
    return PanelV3(
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prompt != null)
              Text(
                prompt!,
                style: textStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            if (hint != null && hint!.isNotEmpty) ...[
              SizedBox(height: spacing * 0.5),
              Text(hint!, style: textStyle),
            ],
          ],
        ),
      ),
    );
  }
}
