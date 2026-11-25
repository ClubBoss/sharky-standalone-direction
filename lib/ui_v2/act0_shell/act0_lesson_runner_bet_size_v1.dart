part of 'act0_lesson_runner_shell_v1.dart';

class _BetSizePromptV1 extends StatelessWidget {
  const _BetSizePromptV1({
    required this.question,
    required this.presets,
    required this.selectedPresetId,
    required this.onSelect,
    required this.onConfirm,
  });

  final String question;
  final List<Act0SizingPresetV1> presets;
  final String? selectedPresetId;
  final ValueChanged<Act0SizingPresetV1>? onSelect;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(question, style: Act0SkinTokensV1.question),
      const SizedBox(height: Act0SkinTokensV1.gapSm),
      Wrap(
        spacing: Act0SkinTokensV1.gapSm,
        runSpacing: Act0SkinTokensV1.gapXs,
        children: [
          for (final preset in presets)
            Act0SkinChipV1(
              key: Key('act0_bet_size_${preset.id}'),
              label: preset.label,
              semanticLabel: preset.semanticLabel,
              selected: selectedPresetId == preset.id,
              tone: selectedPresetId == preset.id
                  ? Act0SkinChipToneV1.brass
                  : Act0SkinChipToneV1.neutral,
              onPressed: onSelect == null ? null : () => onSelect!(preset),
            ),
        ],
      ),
      const SizedBox(height: Act0SkinTokensV1.gapSm),
      Act0SkinPrimaryButtonV1(
        compact: true,
        controlKey: const Key('act0_bet_size_confirm'),
        label: 'Confirm size',
        onPressed: presets.any((preset) => preset.id == selectedPresetId)
            ? onConfirm
            : null,
      ),
    ],
  );
}
